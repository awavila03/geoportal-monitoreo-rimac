-- Datos de referencia (ECA 1-A2) y estaciones simuladas. Se ejecuta como aavila.
-- Las estaciones y la línea base de temperatura son SIMULADAS.

INSERT INTO campo.parametro (uuid, codigo, nombre, unidad) VALUES
  (gen_random_uuid()::text, 'ph',                        'pH',                        'unidad de pH'),
  (gen_random_uuid()::text, 'conductividad',             'Conductividad eléctrica',   'µS/cm'),
  (gen_random_uuid()::text, 'solidos_disueltos_totales', 'Sólidos disueltos totales', 'mg/L'),
  (gen_random_uuid()::text, 'temperatura',               'Temperatura',               '°C');

INSERT INTO referencia.eca_limite (parametro_uuid, categoria, tipo_limite, valor, vigente_desde, fuente)
SELECT p.uuid, v.categoria, v.tipo, v.valor, DATE '2017-06-08',
       'D.S. N.° 004-2017-MINAM, Anexo, Categoría 1-A2 (El Peruano, 07/06/2017)'
FROM (VALUES
  ('ph',                        '1-A2', 'minimo',    5.5),
  ('ph',                        '1-A2', 'maximo',    9.0),
  ('conductividad',             '1-A2', 'maximo',    1600.0),
  ('solidos_disueltos_totales', '1-A2', 'maximo',    1000.0),
  ('temperatura',               '1-A2', 'variacion', 3.0)
) AS v(codigo, categoria, tipo, valor)
JOIN campo.parametro p ON p.codigo = v.codigo;

-- Coordenadas APROXIMADAS (lon, lat): verificar sobre el satélite.
INSERT INTO campo.estacion (uuid, codigo, nombre, geom) VALUES
  (gen_random_uuid()::text, 'E01', 'Chosica',    ST_SetSRID(ST_MakePoint(-76.6990, -11.9380), 4326)),
  (gen_random_uuid()::text, 'E02', 'Huampaní',   ST_SetSRID(ST_MakePoint(-76.7520, -11.9690), 4326)),
  (gen_random_uuid()::text, 'E03', 'Chaclacayo', ST_SetSRID(ST_MakePoint(-76.7700, -11.9750), 4326)),
  (gen_random_uuid()::text, 'E04', 'Ñaña',       ST_SetSRID(ST_MakePoint(-76.8300, -11.9890), 4326)),
  (gen_random_uuid()::text, 'E05', 'Carapongo',  ST_SetSRID(ST_MakePoint(-76.8650, -12.0000), 4326));

INSERT INTO referencia.estacion_categoria (estacion_uuid, categoria, vigente_desde)
SELECT uuid, '1-A2', DATE '2018-02-22' FROM campo.estacion;

-- Línea base de temperatura simulada: curva anual (máximo en febrero) + 0,4 °C por estación aguas abajo
INSERT INTO referencia.linea_base_temperatura (estacion_uuid, mes, valor)
SELECT e.uuid, m,
       round((17.0 + 2.5 * cos(2 * pi() * (m - 2) / 12.0)
              + (right(e.codigo, 1)::int - 1) * 0.4)::numeric, 1)::double precision
FROM campo.estacion e CROSS JOIN generate_series(1, 12) AS m;
