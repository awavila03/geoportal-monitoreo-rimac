/* Mapa Leaflet: fondo CARTO, marcadores de estación, selección y leyenda flotante. */

import { el, icono, infoSemaforo, SEMAFORO } from "./dom.js";

// Atribución compacta visible siempre en el mapa (la completa está en "Información").
const ATRIBUCION_COMPACTA =
  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> ' +
  '&copy; <a href="https://carto.com/attributions">CARTO</a>';

const marcadores = new Map();   // estacion_uuid -> { marcador, nodo }
let mapa = null;

export function crearMapa(contenedor, config) {
  mapa = L.map(contenedor, { zoomControl: true, attributionControl: false });
  mapa.setView([-11.97, -76.78], 12);

  const mb = config && config.mapa_base;
  const maxZoom = (mb && mb.max_zoom) || 17;
  mapa.setMaxZoom(maxZoom);   // CARTO no sirve ráster por encima de z18
  if (mb) {
    L.tileLayer(mb.url, { subdomains: mb.subdominios || "abc", maxZoom }).addTo(mapa);
  }
  L.control.attribution({ prefix: false }).addAttribution(ATRIBUCION_COMPACTA).addTo(mapa);
  L.control.scale({ imperial: false, position: "bottomright" }).addTo(mapa);
  crearLeyenda().addTo(mapa);

  // El contenedor cambia de tamaño (panel, hoja inferior): Leaflet debe saberlo.
  new ResizeObserver(() => mapa.invalidateSize()).observe(contenedor);
  return mapa;
}

function crearLeyenda() {
  const Leyenda = L.Control.extend({
    options: { position: "bottomleft" },
    onAdd() {
      const abierta = !window.matchMedia("(max-width: 48rem)").matches;
      const lista = el("ul", { class: "leyenda__lista", id: "leyenda-lista" });
      for (const [valor, s] of Object.entries(SEMAFORO)) {
        const pildora = el("span", { class: `semaforo semaforo--${s.clase}` }, icono(valor), s.texto);
        lista.append(el("li", {}, pildora));
      }
      lista.append(el("li", { class: "leyenda__nota" }, "Color de cada estación: peor resultado de su monitoreo más reciente."));
      lista.hidden = !abierta;

      const boton = el("button", {
        type: "button", class: "leyenda__boton",
        "aria-expanded": String(abierta), "aria-controls": "leyenda-lista",
      }, "Leyenda");
      boton.addEventListener("click", () => {
        const abrir = boton.getAttribute("aria-expanded") !== "true";
        boton.setAttribute("aria-expanded", String(abrir));
        lista.hidden = !abrir;
      });

      const caja = el("div", { class: "leaflet-control leyenda" }, boton, lista);
      L.DomEvent.disableClickPropagation(caja);
      L.DomEvent.disableScrollPropagation(caja);
      return caja;
    },
  });
  return new Leyenda();
}

/* Dibuja un marcador por estación: icono + código + color del peor semáforo. */
export function pintarMarcadores(features, alSeleccionar) {
  const limites = [];
  for (const f of features) {
    if (!f.geometry) continue;
    const p = f.properties;
    const s = infoSemaforo(p.semaforo_peor);
    const [lon, lat] = f.geometry.coordinates;
    const nodo = el("span", { class: `marca marca--${s.clase}` }, icono(p.semaforo_peor), p.codigo || "");
    const marcador = L.marker([lat, lon], {
      icon: L.divIcon({ className: "marca-icono", html: nodo, iconSize: null }),
      title: `${p.codigo} · ${p.nombre}: ${s.texto}`,
      alt: `${p.codigo} · ${p.nombre}: ${s.texto}`,
      riseOnHover: true,
      keyboard: true,
    }).addTo(mapa);
    marcador.on("click", () => alSeleccionar(p.estacion_uuid));   // Leaflet también lo dispara con Enter
    marcadores.set(p.estacion_uuid, { marcador, nodo });
    limites.push([lat, lon]);
  }
  encuadrar(limites);
}

function encuadrar(limites) {
  if (!limites.length) return;
  mapa.invalidateSize();
  mapa.fitBounds(limites, { padding: [56, 56], maxZoom: 14 });
}

/* Resalta la estación elegida y la centra sin cambiar el zoom del usuario.
 * tapado: píxeles del mapa cubiertos por abajo (hoja inferior en celular);
 * la estación se centra en la parte que queda visible. */
export function seleccionarEnMapa(uuid, tapado = 0) {
  for (const [id, { marcador, nodo }] of marcadores) {
    const activa = id === uuid;
    nodo.classList.toggle("marca--activa", activa);
    marcador.setZIndexOffset(activa ? 1000 : 0);
    if (activa) {
      const centro = mapa.project(marcador.getLatLng()).add([0, tapado / 2]);
      mapa.panTo(mapa.unproject(centro));
    }
  }
}
