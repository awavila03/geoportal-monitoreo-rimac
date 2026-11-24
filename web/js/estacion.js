/* Pestaña "Estación": cabecera con el estado actual y detalle de la estación. */

import { el, fechaLima, numero, pildora, textoLimite } from "./dom.js";

const $ = (id) => document.getElementById(id);

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

  detalle.replaceChildren(cabecera, el("div", { id: "graficos", class: "graficos" }),
    el("div", { class: "mini-tabla-contenedor", role: "region", "aria-label": "Último monitoreo", tabindex: "0" }, ultimo));
}
