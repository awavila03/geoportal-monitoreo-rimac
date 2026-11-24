#!/usr/bin/env python3
"""Genera db/05_datos_simulados.sql con monitoreos y mediciones SIMULADOS.

Solo librería estándar. Semilla fija: la salida es idéntica en cada ejecución.
Además imprime el resultado esperado del semáforo (misma lógica que
geoportal.vista_semaforo en db/02_referencia.sql) para compararlo con la vista.

Uso:  python3 db/generar_datos_simulados.py
"""

import math
import random
import uuid
from collections import Counter
from datetime import datetime, timedelta
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

SEMILLA = 20261124
SALIDA = Path(__file__).resolve().parent / "05_datos_simulados.sql"
NS_BASE = "geoportal-monitoreo-rimac/simulado"

ESTACIONES = ["E01", "E02", "E03", "E04", "E05"]
MESES = [6, 7, 8, 9, 10, 11]
ANIO = 2026
DESFASE_LIMA_UTC = timedelta(hours=5)  # America/Lima = UTC-5, sin horario de verano

PARAMETROS = ["ph", "conductividad", "solidos_disueltos_totales", "temperatura"]

# Conductividad base (µS/cm), mayor aguas abajo
COND_BASE = {"E01": 800, "E02": 875, "E03": 950, "E04": 1025, "E05": 1100}

# Límites ECA 1-A2 cargados en db/04_datos_referencia.sql
LIMITES = {
    "ph": {"minimo": 5.5, "maximo": 9.0},
    "conductividad": {"maximo": 1600.0},
    "solidos_disueltos_totales": {"maximo": 1000.0},
    "temperatura": {"variacion": 3.0},
}

# Visita especial: E01 en octubre, 31/10/2026 23:30 hora de Lima (ya 1/11 en UTC)
VISITA_ESPECIAL = {("E01", 10): datetime(2026, 10, 31, 23, 30)}

# Casos deliberados: (estación, mes, parámetro) -> (valor, descripción)
# "lb+x" indica temperatura relativa a la línea base.
CASOS = {
    ("E02", 7, "ph"): (9.35, "pH alto"),
    ("E04", 9, "ph"): (9.60, "pH alto"),
    ("E05", 6, "ph"): (5.20, "pH bajo"),
    ("E05", 8, "conductividad"): (1780, "conductividad alta (TDS = 0,6 x cond.)"),
    ("E04", 11, "conductividad"): (1690, "conductividad alta (TDS = 0,6 x cond.)"),
    ("E03", 10, "conductividad"): (1615, "conductividad apenas sobre 1 600"),
    ("E03", 10, "solidos_disueltos_totales"): (985, "TDS apenas bajo 1 000 (limitación)"),
    ("E03", 8, "temperatura"): ("lb+3.8", "temperatura sobre la línea base"),
    ("E02", 10, "temperatura"): ("lb-3.6", "temperatura bajo la línea base"),
    ("E01", 7, "solidos_disueltos_totales"): (None, "sin dato"),
    ("E05", 9, "temperatura"): (None, "sin dato"),
    ("E01", 10, "temperatura"): (13.4, "visita 31/10 23:30 Lima: mes de línea base = octubre"),
}


def linea_base(estacion, mes):
    """Réplica exacta de la fórmula de db/04_datos_referencia.sql.

    PostgreSQL: (17.0 + 2.5*cos(...)) en double; (n-1)*0.4 es numeric exacto y
    se convierte a double al sumar; el cast double -> numeric usa 15 dígitos
    significativos; round(numeric) redondea las mitades hacia arriba.
    """
    k = int(estacion[-1]) - 1
    x = 17.0 + 2.5 * math.cos(2 * math.pi * (mes - 2) / 12.0)
    x = x + float(Decimal(k) * Decimal("0.4"))
    return Decimal(f"{x:.15g}").quantize(Decimal("0.1"), rounding=ROUND_HALF_UP)


def uuid_det(*partes):
    return str(uuid.uuid5(uuid.NAMESPACE_URL, "/".join([NS_BASE, *partes])))


def generar():
    rnd = random.Random(SEMILLA)
    monitoreos = []
    for est in ESTACIONES:
        for mes in MESES:
            # Siempre se consumen los mismos números aleatorios, haya caso o no
            dia = rnd.randint(1, 22 if mes == 11 else 28)
            hora = rnd.randint(7, 11)
            minuto = rnd.randrange(0, 60, 5)
            lima = VISITA_ESPECIAL.get((est, mes), datetime(ANIO, mes, dia, hora, minuto))
            lb = linea_base(est, mes)  # mes de la visita en hora de Lima

            ph = round(min(8.4, max(7.2, rnd.gauss(7.8, 0.2))), 2)
            cond = round(min(1400, max(700, COND_BASE[est] + rnd.uniform(-100, 100))))
            tds = round(0.6 * cond * (1 + rnd.uniform(-0.03, 0.03)))
            temp = round(float(lb) + rnd.uniform(-1.5, 1.5), 1)
            valores = {"ph": ph, "conductividad": cond,
                       "solidos_disueltos_totales": tds, "temperatura": temp}

            casos = {}
            for par in PARAMETROS:
                if (est, mes, par) in CASOS:
                    v, desc = CASOS[(est, mes, par)]
                    if isinstance(v, str) and v.startswith("lb"):
                        v = round(float(lb) + float(v[2:]), 1)
                    valores[par] = v
                    casos[par] = desc
            # TDS de las conductividades altas: 0,6 x cond., sin ruido (queda > 1 000)
            if ((est, mes, "conductividad") in CASOS
                    and (est, mes, "solidos_disueltos_totales") not in CASOS):
                valores["solidos_disueltos_totales"] = round(0.6 * valores["conductividad"])

            clave = f"{est}/{ANIO}-{mes:02d}"
            monitoreos.append({
                "estacion": est, "mes": mes, "lima": lima,
                "utc": lima + DESFASE_LIMA_UTC, "lb": lb,
                "uuid": uuid_det("monitoreo", clave),
                "mediciones": [
                    {"parametro": par, "valor": valores[par],
                     "uuid": uuid_det("medicion", clave, par), "caso": casos.get(par)}
                    for par in PARAMETROS
                ],
            })
    monitoreos.sort(key=lambda m: (m["utc"], m["estacion"]))
    return monitoreos


def semaforo(parametro, valor, lb):
    """Misma lógica que geoportal.vista_semaforo."""
    mins, maxs = [], []
    for tipo, lim in LIMITES[parametro].items():
        if tipo == "minimo":
            mins.append(lim)
        elif tipo == "maximo":
            maxs.append(lim)
        elif tipo == "variacion" and lb is not None:
            mins.append(float(lb) - lim)
            maxs.append(float(lb) + lim)
    lmin = max(mins) if mins else None
    lmax = min(maxs) if maxs else None
    if valor is None or (lmin is None and lmax is None):
        return "sin dato"
    if (lmin is not None and valor < lmin) or (lmax is not None and valor > lmax):
        return "no cumple"
    return "cumple"


def fmt_valor(parametro, v):
    if v is None:
        return "NULL"
    if parametro == "ph":
        return f"{v:.2f}"
    if parametro == "temperatura":
        return f"{v:.1f}"
    return str(int(v))


def escribir_sql(monitoreos):
    L = [
        "-- ============================================================",
        "-- DATOS SIMULADOS. No son mediciones reales de campo.",
        "-- ============================================================",
        "-- Generado por db/generar_datos_simulados.py (semilla %d). No editar a mano:" % SEMILLA,
        "-- modificar el script y volver a generar.",
        "-- 30 monitoreos (E01-E05, junio-noviembre de 2026) y 120 mediciones,",
        "-- con origen = 'simulado'. Incluye casos deliberados para probar el semáforo.",
        "-- Ejecutar como aavila, después de 04_datos_referencia.sql, en una sola",
        "-- transacción:  psql -1 -v ON_ERROR_STOP=1 -f db/05_datos_simulados.sql",
        "-- (sin BEGIN/COMMIT internos). Los uuid son deterministas (uuid5): una",
        "-- segunda ejecución falla por UNIQUE y no inserta nada.",
        "-- codigo queda NULL: lo asigna el trigger; los monitoreos van en orden cronológico.",
        "-- fecha_hora_utc = hora de Lima + 5 h.",
        "",
    ]
    for m in monitoreos:
        L.append(f"-- {m['estacion']} | Lima {m['lima']:%Y-%m-%d %H:%M} | línea base {m['lb']} °C")
        L.append(
            "INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,\n"
            "    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)\n"
            f"VALUES ('{m['uuid']}', NULL,\n"
            f"    (SELECT uuid FROM campo.estacion WHERE codigo = '{m['estacion']}'),\n"
            f"    TIMESTAMP '{m['utc']:%Y-%m-%d %H:%M:%S}', 'validado', 'simulado',\n"
            f"    'Multiparámetro portátil (simulado)', DATE '{m['lima']:%Y-%m-%d}',\n"
            "    'Calibración simulada con soluciones patrón', NULL);"
        )
        filas = []
        for med in m["mediciones"]:
            nota = f"  -- caso: {med['caso']}" if med["caso"] else ""
            filas.append(
                f"  ('{med['uuid']}', '{m['uuid']}',\n"
                f"   (SELECT uuid FROM campo.parametro WHERE codigo = '{med['parametro']}'), "
                f"{fmt_valor(med['parametro'], med['valor'])})"
                + "{SEP}" + nota
            )
        cuerpo = "\n".join(
            f.replace("{SEP}", "," if i < len(filas) - 1 else ";") for i, f in enumerate(filas)
        )
        L.append("INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES\n" + cuerpo)
        L.append("")
    SALIDA.write_text("\n".join(L), encoding="utf-8", newline="\n")


def resumen(monitoreos):
    total, por_par, casos = Counter(), {p: Counter() for p in PARAMETROS}, []
    for i, m in enumerate(monitoreos, start=1):
        for med in m["mediciones"]:
            s = semaforo(med["parametro"], med["valor"], m["lb"])
            total[s] += 1
            por_par[med["parametro"]][s] += 1
            if med["caso"]:
                casos.append((i, m, med, s))

    estados = ["cumple", "no cumple", "sin dato"]
    print(f"SQL escrito en: {SALIDA}")
    print(f"Monitoreos: {len(monitoreos)}  Mediciones: {sum(total.values())}\n")
    print("Semáforo esperado (origen = 'simulado'):")
    print(f"  {'parámetro':<27}" + "".join(f"{e:>11}" for e in estados))
    for p in PARAMETROS:
        print(f"  {p:<27}" + "".join(f"{por_par[p][e]:>11}" for e in estados))
    print(f"  {'TOTAL':<27}" + "".join(f"{total[e]:>11}" for e in estados))
    print("\nCasos deliberados (MON-xxxx esperado si la secuencia empieza en 1):")
    for i, m, med, s in casos:
        print(f"  MON-{i:04d} {m['estacion']} {m['lima']:%Y-%m-%d %H:%M} "
              f"{med['parametro']:<26} {fmt_valor(med['parametro'], med['valor']):>7}  "
              f"lb={m['lb']}  -> {s:<9} ({med['caso']})")
    esp = next(m for m in monitoreos if (m["estacion"], m["mes"]) in VISITA_ESPECIAL)
    t = next(x["valor"] for x in esp["mediciones"] if x["parametro"] == "temperatura")
    lb_utc = linea_base(esp["estacion"], esp["utc"].month)
    print(f"\nControl hora de Lima: {esp['estacion']} {t} °C -> con mes Lima "
          f"(lb {esp['lb']}): {semaforo('temperatura', t, esp['lb'])}; "
          f"con mes UTC (lb {lb_utc}): {semaforo('temperatura', t, lb_utc)}")
    print("\nComparar con la vista real:")
    print("  SELECT semaforo, count(*) FROM geoportal.vista_semaforo\n"
          "  WHERE origen = 'simulado' GROUP BY 1 ORDER BY 1;")
    print("  SELECT parametro, semaforo, count(*) FROM geoportal.vista_semaforo\n"
          "  WHERE origen = 'simulado' GROUP BY 1, 2 ORDER BY 1, 2;")


if __name__ == "__main__":
    mons = generar()
    escribir_sql(mons)
    resumen(mons)
