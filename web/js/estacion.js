/* Pestaña "Estación": cabecera con el estado actual y detalle de la estación. */

import { obtenerMediciones } from "./api.js";
import { el, fechaLima, numero, pildora, textoLimite } from "./dom.js";
import { graficoBarras } from "./graficos.js";

const $ = (id) => document.getElementById(id);

// Orden de la cuadrícula 2x2 (por prefijo del nombre); otros parámetros van al final.
const ORDEN = ["pH", "Conductividad", "Sólidos", "Temperatura"];
const NOTAS = {
  "Sólidos": "Estimado a partir de la conductividad.",
  "Temperatura": "Línea base mensual simulada; la banda cambia por mes.",
};
const prefijo = (nombre) => ORDEN.find((o) => nombre.startsWith(o));

const cache = new Map();   // estacion_uuid -> mediciones (orden cronológico)
let actual = null;         // { uuid, series }
let pedido = 0;
let observador = null;
let ultimoAncho = 0;

export function mostrarEstacion(feature, { alVerTabla }) {
  const p = feature.properties;
  $("estacion-vacia").hidden = true;
  const detalle = $("estacion-detalle");
  detalle.hidden = false;

  const verTabla = el("button", { type: "button", class: "boton boton--chico" }, "Ver en la tabla");
  verTabla.addEventListener("click", () => alVerTabla(p.estacion_uuid));

  const cabecera = el("div", { class: "ficha" },
    el("div", { class: "ficha__titulo" },
      el("span", { class: "ficha__codigo" }, p.codigo || ""),
      el("h2", { class: "ficha__nombre", id: "estacion-titulo" }, p.nombre || ""),
    ),
    el("div", { class: "ficha__estado" }, pildora(p.semaforo_peor), verTabla),
    el("p", { class: "ficha__meta" },
      `Monitoreo más reciente ${p.monitoreo_codigo || "—"}: ${fechaLima(p.fecha_hora_lima)} (hora Lima) · origen `,
      el("span", { class: `origen origen--${p.origen === "simulado" ? "simulado" : "campo"}` }, p.origen || "—"),
    ),
  );

  const filas = (p.mediciones || []).map((m) => el("tr", {},
    el("th", { scope: "row" }, m.parametro),
    el("td", { class: "num" }, `${numero(m.valor)} ${m.unidad || ""}`.trim()),
    el("td", {}, textoLimite(m.limite_min, m.limite_max)),
    el("td", {}, pildora(m.semaforo)),
  ));
  const ultimo = el("table", { class: "mini-tabla" },
    el("caption", {}, "Último monitoreo"),
    el("thead", {}, el("tr", {},
      el("th", { scope: "col" }, "Parámetro"),
      el("th", { scope: "col", class: "num" }, "Valor"),
      el("th", { scope: "col" }, "Límite ECA"),
      el("th", { scope: "col" }, "Semáforo"),
    )),
    el("tbody", {}, ...filas),
  );

  const graficos = el("div", { id: "graficos", class: "graficos", "aria-live": "polite" },
    el("p", { class: "graficos__estado" }, "Cargando gráficos…"));
  detalle.replaceChildren(cabecera,
    el("h3", { class: "panel__subtitulo panel__subtitulo--graficos" }, "Historial por parámetro"),
    graficos,
    el("div", { class: "mini-tabla-contenedor", role: "region", "aria-label": "Último monitoreo", tabindex: "0" }, ultimo));
  cargarGraficos(p.estacion_uuid);
}

async function cargarGraficos(uuid) {
  const id = ++pedido;
  actual = null;
  try {
    if (!cache.has(uuid)) {
      const datos = await obtenerMediciones({ estacion: uuid, limite: 1000 });
      // Orden cronológico: el texto "YYYY-MM-DD HH:MM" se ordena bien como texto.
      cache.set(uuid, [...datos.mediciones].sort((a, b) => a.fecha_hora_lima.localeCompare(b.fecha_hora_lima)));
    }
    if (id !== pedido) return;
    const series = new Map();
    for (const m of cache.get(uuid)) {
      if (!series.has(m.parametro)) series.set(m.parametro, { parametro: m.parametro, unidad: m.unidad, filas: [] });
      series.get(m.parametro).filas.push(m);
    }
    const ordenadas = [...series.values()].sort((a, b) => {
      const ia = ORDEN.indexOf(prefijo(a.parametro)), ib = ORDEN.indexOf(prefijo(b.parametro));
      return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib);
    });
    actual = { uuid, series: ordenadas };
    ultimoAncho = 0;
    dibujar();
    vigilarAncho();
  } catch {
    if (id !== pedido) return;
    $("graficos").replaceChildren(el("p", { class: "graficos__estado graficos__estado--error" },
      "No se pudieron cargar los gráficos. Vuelve a elegir la estación en unos segundos."));
  }
}

/* Dibuja los gráficos al ancho real de su celda (se repite si cambia el ancho). */
function dibujar() {
  const caja = $("graficos");
  if (!actual || !caja || caja.clientWidth === 0) return;
  const ancho = caja.clientWidth;
  if (ancho === ultimoAncho) return;
  ultimoAncho = ancho;
  const columnas = getComputedStyle(caja).gridTemplateColumns.split(" ").length;
  const hueco = parseFloat(getComputedStyle(caja).columnGap) || 0;
  const anchoCelda = (ancho - hueco * (columnas - 1)) / columnas - 2;   // -2: borde de la figura

  if (!actual.series.length) {
    caja.replaceChildren(el("p", { class: "graficos__estado" }, "Esta estación no tiene mediciones."));
    return;
  }
  caja.replaceChildren(...actual.series.map((s) => {
    const nota = NOTAS[prefijo(s.parametro)];
    return el("figure", { class: "grafico-figura" },
      el("figcaption", { class: "grafico-figura__titulo" }, s.parametro),
      graficoBarras({ ...s, ancho: anchoCelda }),
      nota ? el("p", { class: "grafico-figura__nota" }, nota) : null,
    );
  }));
}

function vigilarAncho() {
  if (observador) return;
  let pendiente = false;
  observador = new ResizeObserver(() => {
    if (pendiente) return;
    pendiente = true;
    requestAnimationFrame(() => { pendiente = false; dibujar(); });
  });
  observador.observe($("panel-estacion"));
}
