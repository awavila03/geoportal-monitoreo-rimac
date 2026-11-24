/* Pestaña "Mediciones": filtros (estación, parámetro, desde, hasta) y tabla. */

import { obtenerMediciones, obtenerParametros } from "./api.js";
import { el, fechaLima, numero, pildora, textoLimite } from "./dom.js";

const $ = (id) => document.getElementById(id);
let pedidoActual = 0;
let cargada = false;

export function iniciarMediciones(features) {
  const selector = $("filtro-estacion");
  for (const f of features) {
    const p = f.properties;
    selector.append(el("option", { value: p.estacion_uuid }, `${p.codigo} · ${p.nombre}`));
  }
  obtenerParametros().then((lista) => {
    for (const p of lista) {
      $("filtro-parametro").append(el("option", { value: p.parametro }, p.unidad ? `${p.parametro} (${p.unidad})` : p.parametro));
    }
  }).catch(() => { /* el filtro queda solo con "Todos" */ });

  const form = $("filtros");
  form.addEventListener("submit", (ev) => { ev.preventDefault(); cargarMediciones(); });
  form.addEventListener("reset", () => setTimeout(cargarMediciones, 0));
}

/* Carga la tabla la primera vez que se abre la pestaña. */
export function asegurarCargada() {
  if (!cargada) cargarMediciones();
}

export function filtrarPorEstacion(uuid) {
  $("filtro-estacion").value = uuid;
  cargarMediciones();
}

function leerFiltros() {
  const q = {};
  for (const [k, v] of new FormData($("filtros"))) if (String(v).trim()) q[k] = String(v).trim();
  return q;
}

function mostrarEstado(texto, esError = false) {
  const nodo = $("estado-tabla");
  nodo.textContent = texto;
  nodo.classList.toggle("estado--error", esError);
}

export async function cargarMediciones() {
  cargada = true;
  const desde = $("filtro-desde");
  const hasta = $("filtro-hasta");
  const rangoMalo = Boolean(desde.value && hasta.value && desde.value > hasta.value);
  desde.setAttribute("aria-invalid", String(rangoMalo));
  hasta.setAttribute("aria-invalid", String(rangoMalo));
  if (rangoMalo) {
    mostrarEstado("La fecha «Desde» no puede ser posterior a «Hasta».", true);
    return;
  }

  const tabla = $("tabla");
  const boton = document.querySelector("#filtros [type=submit]");
  const id = ++pedidoActual;
  tabla.setAttribute("aria-busy", "true");
  boton.disabled = true;
  mostrarEstado("Cargando mediciones…");

  try {
    const datos = await obtenerMediciones(leerFiltros());
    if (id !== pedidoActual) return;   // llegó una respuesta más nueva
    const filas = document.createDocumentFragment();
    for (const m of datos.mediciones) {
      filas.append(el("tr", {},
        el("td", {}, fechaLima(m.fecha_hora_lima)),
        el("td", {}, `${m.estacion_codigo || ""} · ${m.estacion || ""}`),
        el("td", {}, m.parametro || "—"),
        el("td", { class: "num valor" }, numero(m.valor)),
        el("td", {}, m.unidad || ""),
        el("td", {}, textoLimite(m.limite_min, m.limite_max)),
        el("td", {}, pildora(m.semaforo)),
        el("td", {}, el("span", { class: `origen origen--${m.origen === "simulado" ? "simulado" : "campo"}` }, m.origen || "—")),
        el("td", {}, m.monitoreo_codigo || "—"),
      ));
    }
    $("tabla-cuerpo").replaceChildren(filas);

    if (!datos.total) {
      mostrarEstado("Ninguna medición coincide con los filtros. Amplía el rango de fechas o quita algún filtro.");
    } else if (datos.devueltas < datos.total) {
      mostrarEstado(`Mostrando las ${datos.devueltas} más recientes de ${datos.total} mediciones. Acota el rango de fechas para ver el resto.`);
    } else {
      mostrarEstado(`${datos.total} ${datos.total === 1 ? "medición" : "mediciones"}, de la más reciente a la más antigua.`);
    }
  } catch (e) {
    if (id !== pedidoActual) return;
    $("tabla-cuerpo").replaceChildren();
    mostrarEstado(e.status === 422
      ? `Revisa los filtros: ${e.message}`
      : "No se pudieron cargar las mediciones. Vuelve a intentarlo en unos segundos.", true);
  } finally {
    if (id === pedidoActual) {
      tabla.setAttribute("aria-busy", "false");
      boton.disabled = false;
    }
  }
}
