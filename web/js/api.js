/* Llamadas al API (mismo origen, solo GET). */

export async function pedir(ruta) {
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

export const obtenerConfig = () => pedir("/api/config");
export const obtenerEstaciones = () => pedir("/api/estaciones");
export const obtenerParametros = () => pedir("/api/parametros");
export const obtenerMediciones = (filtros) => pedir(`/api/mediciones?${new URLSearchParams(filtros)}`);
