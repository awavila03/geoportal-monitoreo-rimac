/* Pestaña "Resumen": conteo de estaciones por semáforo y lista de estaciones. */

import { el, fechaLima, pildora } from "./dom.js";

export function pintarResumen(features, alSeleccionar) {
  const conteo = { "cumple": 0, "no cumple": 0, "sin dato": 0 };
  for (const f of features) {
    const s = f.properties.semaforo_peor;
    if (s in conteo) conteo[s] += 1;
  }
  for (const [valor, n] of Object.entries(conteo)) {
    const nodo = document.querySelector(`[data-conteo="${valor}"]`);
    if (nodo) nodo.textContent = String(n);
  }

  const lista = document.getElementById("lista-estaciones");
  lista.replaceChildren();
  if (!features.length) {
    lista.append(el("li", { class: "lista-vacia" }, "No hay estaciones con mediciones."));
    return;
  }
  for (const f of features) {
    const p = f.properties;
    const boton = el("button", { type: "button", class: "estacion", "data-uuid": p.estacion_uuid },
      el("span", { class: "estacion__codigo" }, p.codigo || ""),
      el("span", { class: "estacion__texto" },
        el("span", { class: "estacion__nombre" }, p.nombre || ""),
        el("span", { class: "estacion__fecha" }, `${fechaLima(p.fecha_hora_lima)} (hora Lima)`),
      ),
      pildora(p.semaforo_peor),
    );
    boton.addEventListener("click", () => alSeleccionar(p.estacion_uuid));
    lista.append(el("li", {}, boton));
  }
}

export function marcarEnLista(uuid) {
  for (const b of document.querySelectorAll("#lista-estaciones .estacion")) {
    b.setAttribute("aria-current", b.dataset.uuid === uuid ? "true" : "false");
  }
}
