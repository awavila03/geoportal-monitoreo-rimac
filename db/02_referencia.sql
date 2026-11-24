-- Esquema referencia (no sincroniza) y vista del semáforo (esquema geoportal).
-- Se ejecuta como aavila.

CREATE TABLE referencia.eca_limite (
    id             serial PRIMARY KEY,
    parametro_uuid text NOT NULL REFERENCES campo.parametro (uuid),
    categoria      text NOT NULL,
    tipo_limite    text NOT NULL CHECK (tipo_limite IN ('minimo','maximo','variacion')),
    valor          double precision NOT NULL,
    vigente_desde  date NOT NULL,
    vigente_hasta  date,          -- nulo = vigente
    fuente         text
);

CREATE TABLE referencia.estacion_categoria (
    id            serial PRIMARY KEY,
    estacion_uuid text NOT NULL REFERENCES campo.estacion (uuid),
    categoria     text NOT NULL,
    vigente_desde date NOT NULL,
    vigente_hasta date
);

CREATE TABLE referencia.linea_base_temperatura (
    id            serial PRIMARY KEY,
    estacion_uuid text NOT NULL REFERENCES campo.estacion (uuid),
    mes           integer NOT NULL CHECK (mes BETWEEN 1 AND 12),
    valor         double precision NOT NULL,  -- simulada
    UNIQUE (estacion_uuid, mes)
);

CREATE VIEW geoportal.vista_semaforo AS
WITH med AS (
    SELECT m.fid                                              AS medicion_fid,
           mo.codigo                                          AS monitoreo_codigo,
           e.uuid                                             AS estacion_uuid,
           e.nombre                                           AS estacion,
           e.geom                                             AS geom,
           ((mo.fecha_hora_utc AT TIME ZONE 'UTC') AT TIME ZONE 'America/Lima') AS fecha_hora_lima,
           p.uuid                                             AS parametro_uuid,
           p.nombre                                           AS parametro,
           p.unidad                                           AS unidad,
           m.valor                                            AS valor,
           mo.origen                                          AS origen
    FROM campo.medicion m
    JOIN campo.monitoreo mo ON mo.uuid = m.monitoreo_uuid
    JOIN campo.estacion  e  ON e.uuid  = mo.estacion_uuid
    JOIN campo.parametro p  ON p.uuid  = m.parametro_uuid
),
lim AS (
    SELECT med.*, b.limite_min, b.limite_max
    FROM med
    LEFT JOIN LATERAL (
        SELECT
            max(CASE l.tipo_limite
                    WHEN 'minimo'    THEN l.valor
                    WHEN 'variacion' THEN lb.valor - l.valor
                END) AS limite_min,
            min(CASE l.tipo_limite
                    WHEN 'maximo'    THEN l.valor
                    WHEN 'variacion' THEN lb.valor + l.valor
                END) AS limite_max
        FROM referencia.estacion_categoria ec
        JOIN referencia.eca_limite l
          ON l.categoria = ec.categoria
         AND l.parametro_uuid = med.parametro_uuid
        LEFT JOIN referencia.linea_base_temperatura lb
          ON lb.estacion_uuid = med.estacion_uuid
         AND lb.mes = extract(month FROM med.fecha_hora_lima)::int
        WHERE ec.estacion_uuid = med.estacion_uuid
          AND med.fecha_hora_lima::date BETWEEN ec.vigente_desde AND coalesce(ec.vigente_hasta, 'infinity'::date)
          AND med.fecha_hora_lima::date BETWEEN l.vigente_desde  AND coalesce(l.vigente_hasta,  'infinity'::date)
    ) b ON true
)
SELECT medicion_fid, estacion_uuid, estacion, monitoreo_codigo, fecha_hora_lima,
       parametro, unidad, valor, limite_min, limite_max, origen,
       CASE
           WHEN valor IS NULL OR (limite_min IS NULL AND limite_max IS NULL) THEN 'sin dato'
           WHEN (limite_min IS NOT NULL AND valor < limite_min)
             OR (limite_max IS NOT NULL AND valor > limite_max)             THEN 'no cumple'
           ELSE 'cumple'
       END AS semaforo,
       geom
FROM lim;
