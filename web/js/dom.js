/* Utilidades de DOM y formato. Todo el contenido con datos se escribe con
 * textContent / createTextNode, nunca con innerHTML. */

export const SEMAFORO = {
  "cumple":    { clase: "cumple",    texto: "Cumple" },
  "no cumple": { clase: "no-cumple", texto: "No cumple" },
  "sin dato":  { clase: "sin-dato",  texto: "Sin dato" },
};

const ICONO_TRAZOS = {
  "cumple":    ["M5 12.5l4.5 4.5L19 7.5"],
  "no cumple": ["M7 7l10 10", "M17 7L7 17"],
  "sin dato":  ["M6 12h12"],
};

export const NS_SVG = "http://www.w3.org/2000/svg";

const fmtNumero = new Intl.NumberFormat("es-PE", { maximumFractionDigits: 2 });

export function el(tag, attrs = {}, ...hijos) {
  const nodo = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (v === null || v === undefined || v === false) continue;
    if (k === "class") nodo.className = v;
    else if (k === "text") nodo.textContent = v;
    else nodo.setAttribute(k, v === true ? "" : v);
  }
  for (const h of hijos) {
    if (h === null || h === undefined || h === false) continue;
    nodo.append(h instanceof Node ? h : document.createTextNode(String(h)));
  }
  return nodo;
}

export function svg(tag, attrs = {}, ...hijos) {
  const nodo = document.createElementNS(NS_SVG, tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (v === null || v === undefined || v === false) continue;
    nodo.setAttribute(k, String(v));
  }
  for (const h of hijos) {
    if (h === null || h === undefined || h === false) continue;
    nodo.append(h instanceof Node ? h : document.createTextNode(String(h)));
  }
  return nodo;
}

/* Trazos del icono del semáforo (para reutilizarlos dentro de otros SVG). */
export function trazosIcono(semaforo) {
  return ICONO_TRAZOS[semaforo] || ICONO_TRAZOS["sin dato"];
}

export function icono(semaforo) {
  const nodo = svg("svg", { viewBox: "0 0 24 24", "aria-hidden": "true", class: "icono" });
  for (const d of trazosIcono(semaforo)) nodo.append(svg("path", { d }));
  return nodo;
}

export function infoSemaforo(valor) {
  return SEMAFORO[valor] || { clase: "sin-dato", texto: valor || "Sin dato" };
}

export function pildora(valor) {
  const s = infoSemaforo(valor);
  return el("span", { class: `semaforo semaforo--${s.clase}` }, icono(valor), s.texto);
}

export function numero(v) {
  return v === null || v === undefined ? "—" : fmtNumero.format(v);
}

export function textoLimite(min, max) {
  if (min !== null && min !== undefined && max !== null && max !== undefined) return `${numero(min)} – ${numero(max)}`;
  if (max !== null && max !== undefined) return `≤ ${numero(max)}`;
  if (min !== null && min !== undefined) return `≥ ${numero(min)}`;
  return "—";
}

/* "2026-11-15 09:00" -> "15/11/2026 09:00" sin pasar por Date (la hora ya es de Lima). */
export function fechaLima(texto) {
  if (!texto) return "—";
  const [f, h = ""] = texto.split(" ");
  const [a, m, d] = f.split("-");
  return `${d}/${m}/${a} ${h}`.trim();
}

/* "2026-11-15 09:00" -> "15/11" */
export function fechaCorta(texto) {
  if (!texto) return "—";
  const [, m, d] = texto.split(" ")[0].split("-");
  return `${d}/${m}`;
}
