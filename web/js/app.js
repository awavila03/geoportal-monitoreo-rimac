/* Geoportal Rímac: mapa de estaciones y tabla de mediciones.
 * El semáforo llega calculado desde la base (vista geoportal.vista_semaforo);
 * aquí solo se muestra. Las fechas llegan ya en hora de Lima como texto
 * "YYYY-MM-DD HH:MM" y no se convierten con Date (evita la zona del navegador).
 * Todo el contenido con datos se construye con textContent, nunca innerHTML.
 */
"use strict";

const SEMAFORO = {
  "cumple":    { clase: "cumple",    texto: "Cumple" },
  "no cumple": { clase: "no-cumple", texto: "No cumple" },
  "sin dato":  { clase: "sin-dato",  texto: "Sin dato" },
};

const ICONO_TRAZOS = {
  "cumple":    ["M5 12.5l4.5 4.5L19 7.5"],
  "no cumple": ["M7 7l10 10", "M17 7L7 17"],
  "sin dato":  ["M6 12h12"],
};

const fmtNumero = new Intl.NumberFormat("es-PE", { maximumFractionDigits: 2 });

const estado = {
  mapa: null,
  marcadores: new Map(),   // estacion_uuid -> L.Marker
  haySimulado: false,
};

/* ---------- utilidades DOM ---------- */

function el(tag, attrs = {}, ...hijos) {
  const nodo = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (v === null || v === undefined || v === false) continue;
    if (k === "class") nodo.className = v;
    else if (k === "text") nodo.textContent = v;
    else nodo.setAttribute(k, v === true ? "" : v);
  }
  for (const h of hijos) {
    if (h === null || h === undefined) continue;
    nodo.append(h instanceof Node ? h : document.createTextNode(String(h)));
  }
  return nodo;
}

function icono(semaforo) {
  const ns = "http://www.w3.org/2000/svg";
  const svg = document.createElementNS(ns, "svg");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("aria-hidden", "true");
  svg.setAttribute("class", "icono");
  for (const d of ICONO_TRAZOS[semaforo] || ICONO_TRAZOS["sin dato"]) {
    const p = document.createElementNS(ns, "path");
    p.setAttribute("d", d);
    svg.append(p);
  }
  return svg;
}

function infoSemaforo(valor) {
  return SEMAFORO[valor] || { clase: "sin-dato", texto: valor || "Sin dato" };
}

function pildora(valor) {
  const s = infoSemaforo(valor);
  return el("span", { class: `semaforo semaforo--${s.clase}` }, icono(valor), s.texto);
}

function numero(v) {
  return v === null || v === undefined ? "—" : fmtNumero.format(v);
}

function textoLimite(min, max) {
  if (min !== null && max !== null) return `${numero(min)} – ${numero(max)}`;
  if (max !== null) return `≤ ${numero(max)}`;
  if (min !== null) return `≥ ${numero(min)}`;
  return "—";
}

/* "2026-11-15 09:00" -> "15/11/2026 09:00" sin pasar por Date */
function fechaLima(texto) {
  if (!texto) return "—";
  const [f, h = ""] = texto.split(" ");
  const [a, m, d] = f.split("-");
  return `${d}/${m}/${a} ${h}`.trim();
}

async function pedir(ruta) {
  const r = await fetch(ruta, { headers: { Accept: "application/json" } });
  if (!r.ok) {
    let detalle = "";
    try {
      const cuerpo = await r.json();
      detalle = typeof cuerpo.detail === "string" ? cuerpo.detail : (cuerpo.detalle || "");
    } catch { /* cuerpo no JSON */ }
    const e = new Error(detalle || `Error ${r.status}`);
    e.status = r.status;
    throw e;
  }
  return r.json();
}

/* ---------- mapa ---------- */

function crearMapa(config) {
  const mapa = L.map("mapa", { zoomControl: true, scrollWheelZoom: true });
  mapa.setView([-11.97, -76.78], 12);
  L.control.scale({ imperial: false }).addTo(mapa);
  // El contenedor cambia de alto al llenarse el panel lateral: Leaflet debe saberlo.
  new ResizeObserver(() => mapa.invalidateSize()).observe(document.getElementById("mapa"));
  const mb = config && config.mapa_base;
  if (mb) {
    L.tileLayer(mb.url, {
      subdomains: mb.subdominios || "abc",
      maxZoom: mb.max_zoom || 19,
      attribution: mb.atribucion,
    }).addTo(mapa);
  }
  return mapa;
}

function contenidoPopup(p) {
  const tabla = el("table", { class: "popup__tabla" });
  const cuerpo = el("tbody");
  for (const m of p.mediciones || []) {
    cuerpo.append(el("tr", {},
      el("td", { text: m.parametro }),
      el("td", { class: "num" }, `${numero(m.valor)} ${m.unidad || ""}`.trim()),
      el("td", {}, pildora(m.semaforo)),
    ));
  }
  tabla.append(cuerpo);

  const boton = el("button", { type: "button", class: "boton boton--chico popup__accion" }, "Ver sus mediciones");
  boton.addEventListener("click", () => verMedicionesDe(p.estacion_uuid));

  return el("div", { class: "popup" },
    el("p", { class: "popup__titulo" }, `${p.codigo || ""} · ${p.nombre || ""}`),
    el("p", { class: "popup__meta" },
      `Monitoreo ${p.monitoreo_codigo || "—"} · ${fechaLima(p.fecha_hora_lima)} (hora Lima) · origen ${p.origen || "—"}`),
    tabla,
    boton,
  );
}

function pintarEstaciones(geojson) {
  const lista = document.getElementById("lista-estaciones");
  const selector = document.getElementById("filtro-estacion");
  lista.replaceChildren();
  const limites = [];
  const conteo = { "cumple": 0, "no cumple": 0, "sin dato": 0 };

  for (const f of geojson.features) {
    const p = f.properties;
    if (p.origen === "simulado") estado.haySimulado = true;
    conteo[p.semaforo_peor] = (conteo[p.semaforo_peor] || 0) + 1;
    const s = infoSemaforo(p.semaforo_peor);

    // Marcador: icono + código, así el estado no depende solo del color.
    if (f.geometry && estado.mapa) {
      const [lon, lat] = f.geometry.coordinates;
      const marca = el("span", { class: `marca marca--${s.clase}` }, icono(p.semaforo_peor), p.codigo || "");
      const marcador = L.marker([lat, lon], {
        icon: L.divIcon({ className: "marca-icono", html: marca, iconSize: null }),
        title: `${p.codigo} · ${p.nombre}: ${s.texto}`,
        alt: `${p.codigo} · ${p.nombre}: ${s.texto}`,
        riseOnHover: true,
      }).addTo(estado.mapa);
      marcador.bindPopup(() => contenidoPopup(p), { maxWidth: 340 });
      marcador.on("popupopen", () => marcarActual(p.estacion_uuid));
      estado.marcadores.set(p.estacion_uuid, marcador);
      limites.push([lat, lon]);
    }

    // Fila en la lista lateral
    const boton = el("button", { type: "button", class: "estacion", "data-uuid": p.estacion_uuid },
      el("span", { class: "estacion__codigo" }, p.codigo || ""),
      el("span", {},
        el("span", { class: "estacion__nombre" }, p.nombre || ""),
        el("span", { class: "estacion__fecha" }, `${fechaLima(p.fecha_hora_lima)} (Lima)`),
      ),
      pildora(p.semaforo_peor),
    );
    boton.addEventListener("click", () => enfocarEstacion(p.estacion_uuid));
    lista.append(el("li", {}, boton));

    selector.append(el("option", { value: p.estacion_uuid }, `${p.codigo} · ${p.nombre}`));
  }

  if (!geojson.features.length) {
    lista.append(el("li", { class: "estaciones__cargando" }, "No hay estaciones con mediciones."));
  }

  const total = geojson.features.length;
  const resumen = document.getElementById("resumen");
  resumen.replaceChildren();
  if (total) {
    const partes = [];
    if (conteo["no cumple"]) partes.push(`${conteo["no cumple"]} no cumple${conteo["no cumple"] > 1 ? "n" : ""}`);
    if (conteo["sin dato"]) partes.push(`${conteo["sin dato"]} sin dato`);
    if (conteo["cumple"]) partes.push(`${conteo["cumple"]} cumple${conteo["cumple"] > 1 ? "n" : ""}`);
    resumen.append("En su monitoreo más reciente, de ", el("strong", {}, String(total)), " estaciones: ", partes.join(", "), ".");
  }

  if (estado.mapa && limites.length) {
    estado.mapa.invalidateSize();
    estado.mapa.fitBounds(limites, { padding: [48, 48], maxZoom: 14 });
  }
}

function marcarActual(uuid) {
  for (const b of document.querySelectorAll(".estacion")) {
    b.setAttribute("aria-current", b.dataset.uuid === uuid ? "true" : "false");
  }
}

function enfocarEstacion(uuid) {
  const m = estado.marcadores.get(uuid);
  if (!m) return;
  estado.mapa.setView(m.getLatLng(), Math.max(estado.mapa.getZoom(), 13));
  m.openPopup();
  marcarActual(uuid);
}

function verMedicionesDe(uuid) {
  document.getElementById("filtro-estacion").value = uuid;
  cargarMediciones();
  document.getElementById("titulo-mediciones").scrollIntoView({ behavior: "smooth", block: "start" });
}

/* ---------- tabla de mediciones ---------- */

function leerFiltros() {
  const f = new FormData(document.getElementById("filtros"));
  const q = new URLSearchParams();
  for (const [k, v] of f) if (String(v).trim()) q.set(k, String(v).trim());
  return q;
}

function mostrarEstado(texto, esError = false) {
  const nodo = document.getElementById("estado-tabla");
  nodo.textContent = texto;
  nodo.classList.toggle("estado--error", esError);
}

let pedidoActual = 0;

async function cargarMediciones() {
  const desde = document.getElementById("filtro-desde");
  const hasta = document.getElementById("filtro-hasta");
  const rangoMalo = desde.value && hasta.value && desde.value > hasta.value;
  desde.setAttribute("aria-invalid", rangoMalo ? "true" : "false");
  hasta.setAttribute("aria-invalid", rangoMalo ? "true" : "false");
  if (rangoMalo) {
    mostrarEstado("La fecha «Desde» no puede ser posterior a «Hasta».", true);
    return;
  }

  const q = leerFiltros();
  const tabla = document.getElementById("tabla");
  const cuerpo = document.getElementById("tabla-cuerpo");
  const boton = document.querySelector("#filtros [type=submit]");
  const id = ++pedidoActual;
  tabla.setAttribute("aria-busy", "true");
  boton.disabled = true;
  mostrarEstado("Cargando mediciones…");

  try {
    const datos = await pedir(`/api/mediciones?${q}`);
    if (id !== pedidoActual) return;   // llegó una respuesta más nueva
    const filas = document.createDocumentFragment();
    for (const m of datos.mediciones) {
      if (m.origen === "simulado") estado.haySimulado = true;
      filas.append(el("tr", {},
        el("td", {}, fechaLima(m.fecha_hora_lima)),
        el("td", {}, `${m.estacion_codigo || ""} · ${m.estacion || ""}`),
        el("td", {}, m.monitoreo_codigo || "—"),
        el("td", {}, m.parametro || "—"),
        el("td", { class: "num valor" }, numero(m.valor)),
        el("td", {}, m.unidad || ""),
        el("td", {}, textoLimite(m.limite_min, m.limite_max)),
        el("td", {}, pildora(m.semaforo)),
        el("td", {}, el("span", { class: `origen origen--${m.origen === "simulado" ? "simulado" : "campo"}` }, m.origen || "—")),
      ));
    }
    cuerpo.replaceChildren(filas);

    if (!datos.total) {
      mostrarEstado("Ninguna medición coincide con los filtros. Amplía el rango de fechas o quita algún filtro.");
    } else if (datos.devueltas < datos.total) {
      mostrarEstado(`Mostrando las ${datos.devueltas} más recientes de ${datos.total} mediciones. Acota el rango de fechas para ver el resto.`);
    } else {
      mostrarEstado(`${datos.total} ${datos.total === 1 ? "medición" : "mediciones"}, de la más reciente a la más antigua.`);
    }
    actualizarAviso();
  } catch (e) {
    if (id !== pedidoActual) return;
    cuerpo.replaceChildren();
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

function actualizarAviso() {
  // El aviso viene visible en el HTML; solo se oculta si ningún dato cargado es simulado.
  document.getElementById("aviso-simulado").hidden = !estado.haySimulado;
}

async function cargarParametros() {
  const selector = document.getElementById("filtro-parametro");
  try {
    for (const p of await pedir("/api/parametros")) {
      selector.append(el("option", { value: p.parametro }, p.unidad ? `${p.parametro} (${p.unidad})` : p.parametro));
    }
  } catch { /* el filtro queda solo con "Todos" */ }
}

/* ---------- arranque ---------- */

async function iniciar() {
  for (const n of document.querySelectorAll(".semaforo[data-icono]")) {
    n.prepend(icono(n.dataset.icono));
  }

  const form = document.getElementById("filtros");
  form.addEventListener("submit", (ev) => { ev.preventDefault(); cargarMediciones(); });
  form.addEventListener("reset", () => setTimeout(cargarMediciones, 0));

  let config = null;
  try { config = await pedir("/api/config"); } catch { /* mapa sin fondo */ }
  if (window.L) estado.mapa = crearMapa(config);

  const tareas = [cargarParametros(), cargarMediciones()];
  try {
    pintarEstaciones(await pedir("/api/estaciones"));
    actualizarAviso();
  } catch {
    const lista = document.getElementById("lista-estaciones");
    lista.replaceChildren(el("li", { class: "estaciones__error" }, "No se pudieron cargar las estaciones. Recarga la página en unos segundos."));
  }
  await Promise.allSettled(tareas);
}

document.addEventListener("DOMContentLoaded", iniciar);
