"""Consultas a geoportal.vista_semaforo (única relación legible por geoportal_ro).

Todo el SQL es fijo; los valores del usuario viajan solo como parámetros.
El semáforo por medición viene de la vista; aquí solo se elige el peor de
un monitoreo con el orden: no cumple > sin dato > cumple.
"""

from datetime import date

from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool

SQL_PING = "SELECT 1 FROM geoportal.vista_semaforo LIMIT 1"

SQL_ESTACIONES = """
WITH ultimo AS (
    SELECT DISTINCT ON (estacion_uuid)
           estacion_uuid, monitoreo_codigo, fecha_hora_lima
    FROM geoportal.vista_semaforo
    ORDER BY estacion_uuid, fecha_hora_lima DESC, monitoreo_codigo DESC
)
SELECT u.estacion_uuid,
       min(v.estacion_codigo)                               AS codigo,
       min(v.estacion)                                      AS nombre,
       u.monitoreo_codigo,
       to_char(u.fecha_hora_lima, 'YYYY-MM-DD HH24:MI')     AS fecha_hora_lima,
       min(v.origen)                                        AS origen,
       CASE max(CASE v.semaforo WHEN 'no cumple' THEN 3
                                WHEN 'sin dato'  THEN 2
                                WHEN 'cumple'    THEN 1 END)
            WHEN 3 THEN 'no cumple' WHEN 2 THEN 'sin dato' WHEN 1 THEN 'cumple'
       END                                                  AS semaforo_peor,
       json_agg(json_build_object(
           'parametro',  v.parametro,
           'unidad',     v.unidad,
           'valor',      v.valor,
           'limite_min', v.limite_min,
           'limite_max', v.limite_max,
           'semaforo',   v.semaforo) ORDER BY v.parametro)  AS mediciones,
       ST_AsGeoJSON((array_agg(v.geom))[1], 6)::json        AS geometria
FROM ultimo u
JOIN geoportal.vista_semaforo v
  ON v.estacion_uuid = u.estacion_uuid
 AND v.monitoreo_codigo IS NOT DISTINCT FROM u.monitoreo_codigo
 AND v.fecha_hora_lima IS NOT DISTINCT FROM u.fecha_hora_lima
GROUP BY u.estacion_uuid, u.monitoreo_codigo, u.fecha_hora_lima
ORDER BY codigo
"""

SQL_MEDICIONES = """
SELECT estacion_uuid,
       estacion_codigo,
       estacion,
       monitoreo_codigo,
       to_char(fecha_hora_lima, 'YYYY-MM-DD HH24:MI') AS fecha_hora_lima,
       parametro, unidad, valor, limite_min, limite_max, semaforo, origen,
       count(*) OVER ()                               AS total
FROM geoportal.vista_semaforo
WHERE (%(estacion)s::text  IS NULL OR estacion_uuid = %(estacion)s::text)
  AND (%(parametro)s::text IS NULL OR parametro     = %(parametro)s::text)
  AND (%(desde)s::date     IS NULL OR fecha_hora_lima >= %(desde)s::date)
  AND (%(hasta)s::date     IS NULL OR fecha_hora_lima <  %(hasta)s::date + 1)
ORDER BY fecha_hora_lima DESC, estacion_codigo, parametro
LIMIT %(limite)s
"""

SQL_PARAMETROS = """
SELECT DISTINCT parametro, unidad
FROM geoportal.vista_semaforo
WHERE parametro IS NOT NULL
ORDER BY parametro
"""


class Repositorio:
    def __init__(self, pool: ConnectionPool):
        self.pool = pool

    def _filas(self, sql: str, params=None) -> list[dict]:
        with self.pool.connection() as con:
            with con.cursor(row_factory=dict_row) as cur:
                cur.execute(sql, params)
                return cur.fetchall()

    def ping(self) -> None:
        self._filas(SQL_PING)

    def estaciones(self) -> list[dict]:
        return self._filas(SQL_ESTACIONES)

    def mediciones(self, estacion: str | None, parametro: str | None,
                   desde: date | None, hasta: date | None, limite: int) -> list[dict]:
        return self._filas(SQL_MEDICIONES, {
            "estacion": estacion, "parametro": parametro,
            "desde": desde, "hasta": hasta, "limite": limite,
        })

    def parametros(self) -> list[dict]:
        return self._filas(SQL_PARAMETROS)
