/* Hoja inferior en celular: el asa cambia entre plegada, media y completa. */

const ORDEN = ["plegada", "media", "completa"];
const ETIQUETA = { plegada: "Abrir panel", media: "Ampliar panel", completa: "Plegar panel" };

export function crearHoja(panel, asa) {
  function poner(estado) {
    panel.dataset.hoja = estado;
    asa.setAttribute("aria-expanded", String(estado !== "plegada"));
    asa.setAttribute("aria-label", ETIQUETA[estado]);
  }
  asa.addEventListener("click", () => {
    const i = ORDEN.indexOf(panel.dataset.hoja);
    poner(ORDEN[(i + 1) % ORDEN.length]);
  });
  poner(panel.dataset.hoja || "plegada");
  const esHoja = window.matchMedia("(max-width: 48rem)");
  return {
    /* Al elegir algo, que la hoja se vea al menos a media altura. */
    mostrar() { if (panel.dataset.hoja === "plegada") poner("media"); },
    /* Píxeles que la hoja tapa por abajo (0 en escritorio), según su estado final. */
    alturaTapada() {
      if (!esHoja.matches) return 0;
      const fraccion = { plegada: 0, media: 0.5, completa: 0.88 }[panel.dataset.hoja] ?? 0;
      return Math.round(window.innerHeight * fraccion);
    },
  };
}
