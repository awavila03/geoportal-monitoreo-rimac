# geoportal-monitoreo-rimac

Geoportal de la red de monitoreo de calidad del agua del río Rímac, tramo Chosica.
Las mediciones se capturan en campo con Mergin Maps, se guardan en PostGIS y se
publican en un mapa web con un semáforo de cumplimiento del ECA para Agua,
categoría 1-A2.

> **Incluye datos simulados.** Las mediciones con `origen = 'simulado'` son de
> demostración y no corresponden a muestreos reales. El mapa lo indica con un
> aviso visible y con la columna *Origen* de la tabla.

## Arquitectura

```
 Mergin Maps (campo) ──db-sync──▶ PostGIS 16
                                   ├─ campo.*        estaciones, monitoreos, mediciones
                                   ├─ referencia.*   límites ECA, categorías, línea base
                                   └─ geoportal.vista_semaforo   ◀── único objeto legible
                                              │                      por el rol geoportal_ro
                                              ▼   (solo SELECT)
                     contenedor geoportal-rimac (FastAPI + uvicorn, usuario no root)
                       ├─ /api/...  JSON / GeoJSON, solo GET
                       └─ /         estáticos del mapa (web/: HTML, CSS, JS, Leaflet local)
                                              ▲
                     Caddy (TLS) ── reverse_proxy ──┘   red docker externa, sin puertos publicados
```

- **Un solo contenedor** sirve el API y el front: no hay CORS ni un segundo despliegue.
- **Solo lectura**: la API se conecta con el rol `geoportal_ro`, que únicamente
  puede hacer `SELECT` sobre `geoportal.vista_semaforo`. Las sesiones además
  fuerzan `default_transaction_read_only` y un `statement_timeout` corto.
- **El semáforo se calcula en la base** (la vista) y ni la API ni el front lo
  recalculan: `cumple` (verde), `no cumple` (rojo) y `sin dato` (gris). Para cada
  estación, el mapa muestra el peor resultado de su monitoreo más reciente, con
  este orden: no cumple > sin dato > cumple.
- **Hora de Lima**: la base guarda UTC sin zona y la vista la convierte a
  `America/Lima` (UTC−5). El front muestra el texto tal cual, sin reconvertirlo.

## Estructura del repositorio

```
api/        FastAPI: main.py (app y rutas), consultas.py (SQL), config.py (mapa base), tests/
web/        index.html, css/, js/, vendor/ (Leaflet 1.9.4 y Source Sans 3, servidos localmente)
db/         DDL y datos: 01_campo, 02_referencia, 03_roles, 04_datos_referencia,
            05_datos_simulados (+ generador), 06_vista_codigo
deploy/     Dockerfile, compose.yaml, Caddyfile.rimac (bloque de ejemplo)
```

## Base de datos

Los scripts de `db/` se ejecutan en orden (01 → 06). `06_vista_codigo.sql`
añade `estacion_codigo` al final de la vista sin cambiar las columnas existentes
ni los permisos, y **la API lo necesita**. La contraseña de `geoportal_ro` no
está en el repo: se asigna aparte (`\password geoportal_ro`).

## API

Solo `GET`. Las consultas son fijas y parametrizadas, y los filtros se validan
(un valor inválido devuelve 422).

| Ruta | Descripción |
|---|---|
| `/api/salud` | `{"estado":"ok","base":"ok"}`, o 503 si la base no responde |
| `/api/config` | Lo que el mapa necesita: URL de teselas, zoom máximo y atribución |
| `/api/estaciones` | GeoJSON FeatureCollection. Por estación: `codigo`, `nombre`, `monitoreo_codigo`, `fecha_hora_lima`, `origen`, `semaforo_peor` y `mediciones` (con valor, unidad, límites y semáforo) de su monitoreo más reciente |
| `/api/mediciones` | Filtros opcionales: `estacion` (uuid), `parametro`, `desde` y `hasta` (`YYYY-MM-DD`, hora Lima, inclusivos) y `limite` (1–5000, por defecto 1000). Devuelve `{total, devueltas, mediciones[]}`, de la más reciente a la más antigua |
| `/api/parametros` | Parámetros distintos con su unidad |

Todas las respuestas llevan una Content-Security-Policy estricta
(`default-src 'self'`; las imágenes solo pueden venir además del servidor de teselas).

## Configuración

Por variables de entorno, en un archivo `.env` que nunca se versiona. Como
plantilla está [.env.example](.env.example).

| Variable | Uso |
|---|---|
| `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD` | Conexión libpq estándar, siempre con `geoportal_ro` |
| `CARTO_API_KEY` | Key de CARTO Basemaps (ver abajo) |
| `MAPA_BASE_URL` | Opcional. Plantilla `https://…/{z}/{x}/{y}…` de otro proveedor de teselas |
| `POOL_MAX` | Opcional. Tamaño máximo del pool de conexiones (5 por defecto) |

**Mapa base.** Por defecto se usa CARTO Positron. CARTO exige una key
(`?key=…`) en todas sus teselas: sin ella aparecen con la marca *API KEY
REQUIRED*. La key llega al navegador a través de `/api/config`, así que
cualquier visitante puede verla, como pasa con toda key de teselas. Por eso
conviene restringirla al dominio del geoportal desde el panel de CARTO. La
atribución "© OpenStreetMap contributors © CARTO" se mantiene visible en el mapa.

## Ejecutar en local

La API necesita acceso a la base. Si la base está en un servidor y solo escucha
en su `127.0.0.1:5432`, usa un túnel SSH: la base no queda expuesta y el túnel
solo escucha en tu propia máquina.

```bash
ssh -N -L 15432:127.0.0.1:5432 usuario@servidor      # en otra terminal, déjalo abierto

cp .env.example .env     # PGHOST=127.0.0.1, PGPORT=15432, PGPASSWORD y CARTO_API_KEY
python3 -m venv .venv && .venv/bin/pip install -r api/requirements-dev.txt
set -a; . ./.env; set +a
.venv/bin/uvicorn api.main:app --reload             # http://127.0.0.1:8000
```

Pruebas (no necesitan base de datos):

```bash
.venv/bin/pytest -q api/tests
```

## Despliegue

En el servidor, con el repo clonado y un `.env` en su raíz (`chmod 600`):

```bash
docker compose -f deploy/compose.yaml up -d --build
```

- La imagen corre con un usuario no root, el sistema de archivos en solo lectura y sin capabilities.
- El contenedor `geoportal-rimac` entra en la red externa `geoavila-net`, que es la misma de la base y de Caddy, y **no publica puertos**.
- Tiene healthcheck contra `/api/salud` y `restart: unless-stopped`.
- Caddy hace de proxy con el bloque de [deploy/Caddyfile.rimac](deploy/Caddyfile.rimac), sustituyendo el dominio, y se recarga en caliente con `caddy reload`.

## Limitaciones declaradas

- **Datos simulados.** Todas las mediciones actuales tienen `origen = 'simulado'`
  y se generaron con `db/generar_datos_simulados.py` para probar el semáforo.
- **Sólidos disueltos totales estimados a partir de la conductividad**, no
  medidos directamente.
- **Temperatura**: el límite es la variación de ±3 °C sobre una **línea base
  mensual simulada** por estación. No hay todavía una línea base real.
- La vista no distingue el estado del monitoreo (borrador, enviado, validado…):
  se publican todos.
- Una estación sin mediciones no aparece en el mapa, porque la geometría sale de la vista.
- Fuente de los límites: ECA para Agua, categoría 1-A2 (D.S. N.° 004-2017-MINAM).
  Clasificación del cuerpo de agua: R.J. N.° 056-2018-ANA.

## Licencias de terceros

- [Leaflet](https://leafletjs.com) 1.9.4: BSD-2-Clause (`web/vendor/leaflet/LICENSE`).
- Source Sans 3: SIL Open Font License 1.1 (`web/vendor/fonts/LICENSE-OFL.txt`).
- Mapa base: © OpenStreetMap contributors (ODbL), © CARTO (términos de CARTO Basemaps).
