/* Geoportal Rímac: arranque y coordinación entre mapa, pestañas y paneles.
 * El semáforo llega calculado desde la base (vista geoportal.vista_semaforo);
 * el front solo lo muestra. Las fechas llegan ya en hora de Lima como texto.
 */

import { obtenerConfig, obtenerEstaciones } from "./api.js";
import { el, icono } from "./dom.js";
import { mostrarEstacion } from "./estacion.js";
import { crearHoja } from "./hoja.js";
import { crearMapa, pintarMarcadores, seleccionarEnMapa } from "./mapa.js";
import { asegurarCargada, filtrarPorEstacion, iniciarMediciones } from "./mediciones.js";
import { crearPestanas } from "./pestanas.js";
import { marcarEnLista, pintarResumen } from "./resumen.js";

const $ = (id) => document.getElementById(id);
const estaciones = new Map();   // estacion_uuid -> feature

async function iniciar() {
  // Iconos de las tarjetas de resumen (definidos en el HTML con data-icono)
  for (const n of document.querySelectorAll("[data-icono]")) n.prepend(icono(n.dataset.icono));

  const hoja = crearHoja($("panel"), $("asa"));
  const pestanas = crearPestanas($("pestanas"), (id) => {
    if (id === "tab-mediciones") asegurarCargada();
    hoja.mostrar();   // en celular, elegir una pestaña sube la hoja si estaba plegada
  });

  function seleccionar(uuid) {
    const f = estaciones.get(uuid);
    if (!f) return;
    hoja.mostrar();
    seleccionarEnMapa(uuid, hoja.alturaTapada());
    marcarEnLista(uuid);
    mostrarEstacion(f, {
      alVerTabla(id) {
        filtrarPorEstacion(id);
        pestanas.activar("tab-mediciones");
      },
    });
    pestanas.activar("tab-estacion");
  }

  let config = null;
  try { config = await obtenerConfig(); } catch { /* mapa sin fondo */ }
  if (window.L) crearMapa($("mapa"), config);

  try {
    const geojson = await obtenerEstaciones();
    for (const f of geojson.features) estaciones.set(f.properties.estacion_uuid, f);
    pintarResumen(geojson.features, seleccionar);
    if (window.L) pintarMarcadores(geojson.features, seleccionar);
    iniciarMediciones(geojson.features);
    // El aviso viene visible en el HTML; solo se oculta si ninguna estación tiene datos simulados.
    $("aviso-simulado").hidden = !geojson.features.some((f) => f.properties.origen === "simulado");
  } catch {
    $("lista-estaciones").replaceChildren(
      el("li", { class: "lista-vacia lista-vacia--error" }, "No se pudieron cargar las estaciones. Recarga la página en unos segundos."));
    iniciarMediciones([]);
  }
}

document.addEventListener("DOMContentLoaded", iniciar);
