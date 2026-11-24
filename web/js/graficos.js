/* Mini gráfico de barras en SVG para un parámetro de una estación.
 * - Una barra por monitoreo, en orden cronológico, con el color e icono del
 *   semáforo que entrega la vista (no se recalcula nada).
 * - Límite ECA: línea (solo máximo) o banda (mín–máx). Si el límite cambia
 *   entre monitoreos (temperatura: línea base mensual ±3 °C) se dibuja una
 *   banda por barra: queda una banda escalonada.
 * - "Sin dato" con valor nulo: marca gris sin altura y el texto "Sin dato".
 * - Cada barra es enfocable, con <title> y aria-label (valor, fecha, semáforo).
 * Se dibuja al ancho real del contenedor para que el texto no se encoja.
 */

import { fechaCorta, fechaLima, infoSemaforo, numero, svg, textoLimite, trazosIcono } from "./dom.js";

// Una gráfica por fila, a todo el ancho del panel; algo más bajas en celular.
const ALTO_ESCRITORIO = 240;
const ALTO_CELULAR = 210;
const M = { izq: 38, der: 16, sup: 40, inf: 24 };   // márgenes del área de trazado

/* Escala "bonita" de 0 a un máximo redondeado, con 4-6 marcas. */
function escalaY(maximo) {
  const bruto = maximo / 5 || 1;
  const potencia = 10 ** Math.floor(Math.log10(bruto));
  const paso = [1, 2, 2.5, 5, 10].map((f) => f * potencia).find((p) => p >= bruto);
  const tope = Math.ceil(maximo / paso) * paso;
  const marcas = [];
  for (let v = 0; v <= tope + paso / 2; v += paso) marcas.push(Number(v.toFixed(6)));
  return { tope, marcas };
}

function limitesIguales(filas) {
  const claves = new Set(filas.map((f) => `${f.limite_min}|${f.limite_max}`));
  return claves.size === 1;
}

function textoBarra(f) {
  const s = infoSemaforo(f.semaforo);
  const valor = f.valor === null || f.valor === undefined ? "sin valor" : `${numero(f.valor)} ${f.unidad || ""}`.trim();
  return `${fechaLima(f.fecha_hora_lima)} (hora Lima): ${valor}. ${s.texto}. Límite ECA ${textoLimite(f.limite_min, f.limite_max)}${f.unidad ? " " + f.unidad : ""}.`;
}

/* Rótulo del límite en la cabecera del gráfico (arriba a la derecha), con una
 * muestra del trazo (línea discontinua, banda o banda escalonada). Así nunca
 * choca con las barras que superan el límite. */
function rotular(capa, W, texto, tipo) {
  const xFin = W - M.der;
  const t = svg("text", { x: xFin, y: 13, class: "grafico__rotulo", "text-anchor": "end" }, texto);
  capa.append(t);
  // ancho aproximado del texto (12 px, Source Sans, negrita): ~6.2 px por carácter
  const xMuestra = xFin - texto.length * 6.2 - 20;
  if (tipo === "linea") {
    capa.append(svg("line", { x1: xMuestra, x2: xMuestra + 14, y1: 9, y2: 9, class: "grafico__linea-limite" }));
  } else {
    capa.append(svg("rect", { x: xMuestra, y: 4, width: 14, height: 10, class: `grafico__banda${tipo === "escalon" ? " grafico__banda--escalon" : ""}` }));
    if (tipo === "banda") {
      capa.append(svg("line", { x1: xMuestra, x2: xMuestra + 14, y1: 4, y2: 4, class: "grafico__linea-limite" }));
      capa.append(svg("line", { x1: xMuestra, x2: xMuestra + 14, y1: 14, y2: 14, class: "grafico__linea-limite" }));
    }
  }
}

/* Devuelve un <svg> para las filas (ya ordenadas por fecha) de un parámetro. */
export function graficoBarras({ parametro, unidad, filas, ancho }) {
  const ALTO = window.matchMedia("(max-width: 48rem)").matches ? ALTO_CELULAR : ALTO_ESCRITORIO;
  const W = Math.max(200, Math.round(ancho));
  const pw = W - M.izq - M.der;
  const ph = ALTO - M.sup - M.inf;
  const n = filas.length;
  const ranura = pw / Math.max(n, 1);
  const anchoBarra = Math.min(26, ranura * 0.56);

  const valores = filas.flatMap((f) => [f.valor, f.limite_min, f.limite_max]).filter((v) => v !== null && v !== undefined);
  const { tope, marcas } = escalaY(Math.max(...valores, 0) * 1.08);
  const y = (v) => M.sup + ph - (v / tope) * ph;
  const xc = (i) => M.izq + ranura * (i + 0.5);

  const raiz = svg("svg", {
    width: W, height: ALTO, viewBox: `0 0 ${W} ${ALTO}`,
    class: "grafico", role: "group",
    "aria-label": `${parametro}: barras por monitoreo, en orden cronológico, con el límite ECA`,
  });

  // Unidad del eje Y
  raiz.append(svg("text", { x: 4, y: M.sup - 11, class: "grafico__unidad" }, unidad || ""));

  // Rejilla y marcas del eje Y
  for (const v of marcas) {
    raiz.append(svg("line", { x1: M.izq, x2: W - M.der, y1: y(v), y2: y(v), class: v === 0 ? "grafico__base" : "grafico__rejilla" }));
    raiz.append(svg("text", { x: M.izq - 5, y: y(v) + 4, class: "grafico__eje", "text-anchor": "end" }, numero(v)));
  }

  // Límite ECA
  const conLimite = filas.filter((f) => f.limite_min !== null || f.limite_max !== null);
  if (conLimite.length) {
    const capa = svg("g", { class: "grafico__limite", "aria-hidden": "true" });
    if (limitesIguales(conLimite)) {
      const { limite_min: lmin, limite_max: lmax } = conLimite[0];
      if (lmin !== null && lmax !== null) {
        capa.append(svg("rect", { x: M.izq, width: pw, y: y(lmax), height: y(lmin) - y(lmax), class: "grafico__banda" }));
      }
      for (const v of [lmin, lmax]) {
        if (v !== null) capa.append(svg("line", { x1: M.izq, x2: W - M.der, y1: y(v), y2: y(v), class: "grafico__linea-limite" }));
      }
      const texto = lmin !== null && lmax !== null ? `ECA ${numero(lmin)}–${numero(lmax)}`
        : lmax !== null ? `ECA ≤ ${numero(lmax)}` : `ECA ≥ ${numero(lmin)}`;
      rotular(capa, W, texto, lmin !== null && lmax !== null ? "banda" : "linea");
    } else {
      // Límite variable (temperatura): banda por barra -> banda escalonada
      filas.forEach((f, i) => {
        if (f.limite_min === null || f.limite_max === null) return;
        capa.append(svg("rect", {
          x: xc(i) - ranura * 0.45, width: ranura * 0.9,
          y: y(f.limite_max), height: y(f.limite_min) - y(f.limite_max), class: "grafico__banda grafico__banda--escalon",
        }));
      });
      rotular(capa, W, "ECA: línea base ±3 °C", "escalon");
    }
    raiz.append(capa);
  }

  // Barras
  filas.forEach((f, i) => {
    const s = infoSemaforo(f.semaforo);
    const etiqueta = textoBarra(f);
    const g = svg("g", { class: `barra barra--${s.clase}`, tabindex: "0", role: "img", "aria-label": etiqueta });
    g.append(svg("title", {}, etiqueta));
    // Zona de foco/hover de toda la ranura
    g.append(svg("rect", { x: xc(i) - ranura / 2 + 1, width: ranura - 2, y: M.sup - 6, height: ph + 6, class: "barra__marco" }));

    if (f.valor === null || f.valor === undefined) {
      g.append(svg("line", { x1: xc(i) - anchoBarra / 2, x2: xc(i) + anchoBarra / 2, y1: y(0) - 1.5, y2: y(0) - 1.5, class: "barra__sin-dato" }));
      g.append(svg("text", {
        x: xc(i) + 4, y: y(0) - 7, class: "barra__texto-sin-dato",
        transform: `rotate(-90 ${xc(i) + 4} ${y(0) - 7})`,
      }, "Sin dato"));
    } else {
      const alto = Math.max(1, y(0) - y(f.valor));
      g.append(svg("rect", { x: xc(i) - anchoBarra / 2, width: anchoBarra, y: y(0) - alto, height: alto, rx: 2, class: "barra__rect" }));
      const icono = svg("g", { class: "barra__icono", transform: `translate(${xc(i) - 6} ${y(f.valor) - 15}) scale(0.5)` });
      for (const d of trazosIcono(f.semaforo)) icono.append(svg("path", { d }));
      g.append(icono);
    }
    raiz.append(g);

    // Fecha bajo cada barra; si no caben, una sí y una no (siempre la última)
    if (ranura >= 32 || (n - 1 - i) % 2 === 0) {
      raiz.append(svg("text", { x: xc(i), y: ALTO - 7, class: "grafico__eje", "text-anchor": "middle" }, fechaCorta(f.fecha_hora_lima)));
    }
  });

  return raiz;
}
