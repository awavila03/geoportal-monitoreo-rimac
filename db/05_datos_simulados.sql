-- ============================================================
-- DATOS SIMULADOS. No son mediciones reales de campo.
-- ============================================================
-- Generado por db/generar_datos_simulados.py (semilla 20261124). No editar a mano:
-- modificar el script y volver a generar.
-- 30 monitoreos (E01-E05, junio-noviembre de 2026) y 120 mediciones,
-- con origen = 'simulado'. Incluye casos deliberados para probar el semáforo.
-- Ejecutar como aavila, después de 04_datos_referencia.sql, en una sola
-- transacción:  psql -1 -v ON_ERROR_STOP=1 -f db/05_datos_simulados.sql
-- (sin BEGIN/COMMIT internos). Los uuid son deterministas (uuid5): una
-- segunda ejecución falla por UNIQUE y no inserta nada.
-- codigo queda NULL: lo asigna el trigger; los monitoreos van en orden cronológico.
-- fecha_hora_utc = hora de Lima + 5 h.

-- E02 | Lima 2026-06-01 09:40 | línea base 16.2 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('5a7fac4a-7271-5a2b-b7b4-3e23cfd1b34f', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E02'),
    TIMESTAMP '2026-06-01 14:40:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-06-01',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('5f56e6b3-7f38-515b-b60a-0c6ba21bd656', '5a7fac4a-7271-5a2b-b7b4-3e23cfd1b34f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.86),
  ('f10a3109-8129-52e3-8ad2-88ea3890d9ca', '5a7fac4a-7271-5a2b-b7b4-3e23cfd1b34f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 871),
  ('443aef5a-95da-58bf-9fbe-c2b643baba3b', '5a7fac4a-7271-5a2b-b7b4-3e23cfd1b34f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 530),
  ('1ac5e13c-a43c-55d7-a3e3-e0d67e82fd7f', '5a7fac4a-7271-5a2b-b7b4-3e23cfd1b34f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 16.2);

-- E04 | Lima 2026-06-02 11:15 | línea base 17.0 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('771f1b1a-957f-5132-8207-d324a0410119', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E04'),
    TIMESTAMP '2026-06-02 16:15:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-06-02',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('69781b1d-9375-5bac-a11a-6fc595359b01', '771f1b1a-957f-5132-8207-d324a0410119',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.76),
  ('54caf337-aa32-5a07-9c37-13461916ad2b', '771f1b1a-957f-5132-8207-d324a0410119',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 934),
  ('098d3714-d392-5db8-80b0-74fcafa5bb2a', '771f1b1a-957f-5132-8207-d324a0410119',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 565),
  ('d263a2f0-e82b-556f-9e03-6eefd8e6b56a', '771f1b1a-957f-5132-8207-d324a0410119',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 16.9);

-- E05 | Lima 2026-06-15 08:55 | línea base 17.4 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('7eb66d78-7495-572d-a043-886413a899c4', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E05'),
    TIMESTAMP '2026-06-15 13:55:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-06-15',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('94ae2a80-01f6-5449-8c8b-e266f61886d9', '7eb66d78-7495-572d-a043-886413a899c4',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 5.20),  -- caso: pH bajo
  ('c05a6aee-2c84-5373-b423-bce83603dc4e', '7eb66d78-7495-572d-a043-886413a899c4',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1186),
  ('26c17d6e-c5b0-5f52-a1a4-e8decc7d30f6', '7eb66d78-7495-572d-a043-886413a899c4',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 726),
  ('b2708a39-aeec-5c2e-befd-f12273be3cd6', '7eb66d78-7495-572d-a043-886413a899c4',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 18.4);

-- E03 | Lima 2026-06-17 09:45 | línea base 16.6 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('6fbbe0db-b119-546f-bb7a-c245af570b9b', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E03'),
    TIMESTAMP '2026-06-17 14:45:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-06-17',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('6f0e8e46-7be5-572e-927f-9c758e66f0ce', '6fbbe0db-b119-546f-bb7a-c245af570b9b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.87),
  ('bd72fc9b-bba2-55ff-84e4-4c615d57adb3', '6fbbe0db-b119-546f-bb7a-c245af570b9b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1018),
  ('df9645ed-da0b-5918-92ce-26dabe9460b6', '6fbbe0db-b119-546f-bb7a-c245af570b9b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 603),
  ('6e3d9fd1-fd6a-560f-88ba-e2c872c457ff', '6fbbe0db-b119-546f-bb7a-c245af570b9b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.2);

-- E01 | Lima 2026-06-27 08:50 | línea base 15.8 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('17a2dcf0-7481-5fb7-ba07-60ba5d42ba58', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E01'),
    TIMESTAMP '2026-06-27 13:50:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-06-27',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('b8f7a7de-c588-5f34-b416-f0fc42d87d0f', '17a2dcf0-7481-5fb7-ba07-60ba5d42ba58',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.86),
  ('a37d9d1f-ee16-5cd4-8ba0-c62ce0d0d5f0', '17a2dcf0-7481-5fb7-ba07-60ba5d42ba58',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 859),
  ('a0ba2374-66fa-5ddb-9267-90ac4ee2780d', '17a2dcf0-7481-5fb7-ba07-60ba5d42ba58',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 530),
  ('3e001115-bf66-566a-b92f-2929068f10a0', '17a2dcf0-7481-5fb7-ba07-60ba5d42ba58',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 16.9);

-- E02 | Lima 2026-07-14 08:25 | línea base 15.2 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('6c90b407-d920-5da0-a8fe-f43f5123d4a2', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E02'),
    TIMESTAMP '2026-07-14 13:25:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-07-14',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('90bed829-d01c-5851-ba58-3ba71d2b904c', '6c90b407-d920-5da0-a8fe-f43f5123d4a2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 9.35),  -- caso: pH alto
  ('d7d702de-87a8-5d09-a118-c99e01130c57', '6c90b407-d920-5da0-a8fe-f43f5123d4a2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 948),
  ('b82880c0-217f-51a1-bccb-68ecec01cb45', '6c90b407-d920-5da0-a8fe-f43f5123d4a2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 579),
  ('3798ab5d-09f2-50b7-bfbb-cf12e0652191', '6c90b407-d920-5da0-a8fe-f43f5123d4a2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 14.2);

-- E03 | Lima 2026-07-14 11:40 | línea base 15.6 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('b5c7a4aa-7668-5919-b763-edf734d56f8b', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E03'),
    TIMESTAMP '2026-07-14 16:40:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-07-14',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('fa101a34-0c0f-584c-928b-24adf08da810', 'b5c7a4aa-7668-5919-b763-edf734d56f8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.85),
  ('ef7d89bd-b604-5915-8700-4ac23e81ef01', 'b5c7a4aa-7668-5919-b763-edf734d56f8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1041),
  ('4974d869-34b8-5ae3-9048-7bb44b44fcb3', 'b5c7a4aa-7668-5919-b763-edf734d56f8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 614),
  ('911a1370-b5a1-5160-8f7d-a7dda93db478', 'b5c7a4aa-7668-5919-b763-edf734d56f8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 15.4);

-- E01 | Lima 2026-07-15 10:10 | línea base 14.8 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('16aefb51-08cc-536f-9896-e37a7bbdb784', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E01'),
    TIMESTAMP '2026-07-15 15:10:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-07-15',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('9acda61a-a5a2-59b4-b05b-c3756271b34e', '16aefb51-08cc-536f-9896-e37a7bbdb784',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.78),
  ('25abbf2e-c938-5dc4-a6cb-81492301b548', '16aefb51-08cc-536f-9896-e37a7bbdb784',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 852),
  ('d98da10b-c016-5edd-86af-6f20c016ce09', '16aefb51-08cc-536f-9896-e37a7bbdb784',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), NULL),  -- caso: sin dato
  ('31a0b95b-0133-5943-a763-ef892c55590d', '16aefb51-08cc-536f-9896-e37a7bbdb784',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 15.8);

-- E04 | Lima 2026-07-20 09:15 | línea base 16.0 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('0ea98eda-ee23-5cb9-9ed9-56b988db9c74', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E04'),
    TIMESTAMP '2026-07-20 14:15:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-07-20',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('023e7eb7-ddb0-52ae-b824-8cb21b018f1d', '0ea98eda-ee23-5cb9-9ed9-56b988db9c74',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.52),
  ('f15e827e-924d-5267-b086-0addc50eb436', '0ea98eda-ee23-5cb9-9ed9-56b988db9c74',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1083),
  ('4c1d36d9-287c-5663-898e-dfd2f13d138a', '0ea98eda-ee23-5cb9-9ed9-56b988db9c74',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 660),
  ('54084cc6-3613-56b7-a218-e7c3e3f818d9', '0ea98eda-ee23-5cb9-9ed9-56b988db9c74',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 15.4);

-- E05 | Lima 2026-07-22 08:20 | línea base 16.4 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('45548496-2bbf-5f8c-994e-df42e4057d6f', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E05'),
    TIMESTAMP '2026-07-22 13:20:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-07-22',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('8f2f0f1d-7b20-5f52-90ce-3a040cd81f40', '45548496-2bbf-5f8c-994e-df42e4057d6f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.96),
  ('a2228524-f3a8-5245-bc6e-1b5f7edd1c72', '45548496-2bbf-5f8c-994e-df42e4057d6f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1048),
  ('2a545937-da92-5d24-bd9d-3e88cdaf13bb', '45548496-2bbf-5f8c-994e-df42e4057d6f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 632),
  ('42837b72-2a75-59f6-ab1e-f9e9e6daf25f', '45548496-2bbf-5f8c-994e-df42e4057d6f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.4);

-- E03 | Lima 2026-08-02 07:25 | línea base 15.3 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('a11e0ff9-d3b1-59ef-9206-ccef9f8cd1ec', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E03'),
    TIMESTAMP '2026-08-02 12:25:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-08-02',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('c2df7574-1c2f-5024-b1e1-87c6f3bc2b67', 'a11e0ff9-d3b1-59ef-9206-ccef9f8cd1ec',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.51),
  ('0159fa8c-1f2b-599c-8329-8bcda69cf3f6', 'a11e0ff9-d3b1-59ef-9206-ccef9f8cd1ec',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 928),
  ('48815eff-9433-51b7-be79-58e310df2f44', 'a11e0ff9-d3b1-59ef-9206-ccef9f8cd1ec',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 567),
  ('d1a00b30-8be7-5253-baa5-497ee6bc0fe1', 'a11e0ff9-d3b1-59ef-9206-ccef9f8cd1ec',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 19.1);  -- caso: temperatura sobre la línea base

-- E02 | Lima 2026-08-07 10:50 | línea base 14.9 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('e2c7ee79-929f-5e73-8729-a7ec3ce3c969', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E02'),
    TIMESTAMP '2026-08-07 15:50:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-08-07',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('ab6995b4-9100-5a63-a80f-3d545ef7f075', 'e2c7ee79-929f-5e73-8729-a7ec3ce3c969',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.54),
  ('4dfe7354-a178-5a8c-84d0-cf5d58bcc726', 'e2c7ee79-929f-5e73-8729-a7ec3ce3c969',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 790),
  ('9e8acc8a-320c-53a7-836a-1ed38c9a7628', 'e2c7ee79-929f-5e73-8729-a7ec3ce3c969',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 465),
  ('323e3624-6efe-5c7b-ab72-e852bead9665', 'e2c7ee79-929f-5e73-8729-a7ec3ce3c969',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 15.2);

-- E01 | Lima 2026-08-08 07:55 | línea base 14.5 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('4254e8c2-9a66-5069-a38e-2e207459b4cd', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E01'),
    TIMESTAMP '2026-08-08 12:55:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-08-08',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('951b37fa-5fec-58b2-b261-c6bc022e76de', '4254e8c2-9a66-5069-a38e-2e207459b4cd',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 8.06),
  ('85997870-266d-550c-94d6-ccd7fb944610', '4254e8c2-9a66-5069-a38e-2e207459b4cd',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 712),
  ('ad5d43ab-1b0f-59fc-8b22-34bb4b01def8', '4254e8c2-9a66-5069-a38e-2e207459b4cd',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 418),
  ('94591b38-70a8-5a83-aa2a-31f034681ebe', '4254e8c2-9a66-5069-a38e-2e207459b4cd',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 14.4);

-- E04 | Lima 2026-08-19 09:15 | línea base 15.7 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('4a1c2535-953d-5039-8e4d-ba3a610c554f', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E04'),
    TIMESTAMP '2026-08-19 14:15:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-08-19',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('1c4e6150-73c5-5331-91c7-8235bc678b13', '4a1c2535-953d-5039-8e4d-ba3a610c554f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.75),
  ('1fef75bd-c9aa-52c0-a6e1-63fb1748c0e4', '4a1c2535-953d-5039-8e4d-ba3a610c554f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 955),
  ('852d5997-e38c-58ec-b635-eb81a3190172', '4a1c2535-953d-5039-8e4d-ba3a610c554f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 584),
  ('df009a4d-5d66-5669-810f-a2229b1230f6', '4a1c2535-953d-5039-8e4d-ba3a610c554f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.1);

-- E05 | Lima 2026-08-23 10:25 | línea base 16.1 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('27fe56f4-1afa-5a87-aabb-6f1e670642e2', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E05'),
    TIMESTAMP '2026-08-23 15:25:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-08-23',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('f1ddf2c4-96e7-5cdc-bc09-2c7ca5207c86', '27fe56f4-1afa-5a87-aabb-6f1e670642e2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.62),
  ('07335d63-2497-557c-8ce5-ece8ae9368ad', '27fe56f4-1afa-5a87-aabb-6f1e670642e2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1780),  -- caso: conductividad alta (TDS = 0,6 x cond.)
  ('33ba6b3a-ff30-503d-ae82-6420b1ff17f8', '27fe56f4-1afa-5a87-aabb-6f1e670642e2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 1068),
  ('086abca5-13f3-5176-9fd8-1ce842dec975', '27fe56f4-1afa-5a87-aabb-6f1e670642e2',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 16.6);

-- E04 | Lima 2026-09-01 10:55 | línea base 16.0 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('31b9f6bf-8b8f-5b9b-a0e8-c298e27a8390', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E04'),
    TIMESTAMP '2026-09-01 15:55:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-09-01',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('93a90c57-3e79-5257-978b-36649b2d541b', '31b9f6bf-8b8f-5b9b-a0e8-c298e27a8390',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 9.60),  -- caso: pH alto
  ('420ddc10-1707-5174-a325-7710933de519', '31b9f6bf-8b8f-5b9b-a0e8-c298e27a8390',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 969),
  ('419ffdae-6f35-5a4b-bdae-c186f0d6f1c5', '31b9f6bf-8b8f-5b9b-a0e8-c298e27a8390',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 566),
  ('d633aa0d-5d9c-5454-89d9-cd6e0cac2536', '31b9f6bf-8b8f-5b9b-a0e8-c298e27a8390',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 14.6);

-- E01 | Lima 2026-09-01 11:25 | línea base 14.8 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('de5bec0c-28fb-5e30-a897-522a7dcbb40b', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E01'),
    TIMESTAMP '2026-09-01 16:25:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-09-01',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('3fb0cb10-1190-56e4-b314-d6942f362684', 'de5bec0c-28fb-5e30-a897-522a7dcbb40b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.80),
  ('d1097439-52fc-551a-b949-b4d2e1cb3669', 'de5bec0c-28fb-5e30-a897-522a7dcbb40b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 818),
  ('76f2899b-4e47-5149-ba66-d931782bd214', 'de5bec0c-28fb-5e30-a897-522a7dcbb40b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 478),
  ('93ccb3dd-0b5e-552f-b5ed-3dbf87c6520e', 'de5bec0c-28fb-5e30-a897-522a7dcbb40b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 14.9);

-- E03 | Lima 2026-09-07 10:20 | línea base 15.6 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('aeb76dd0-d0eb-5232-a24a-1813ff8ff70b', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E03'),
    TIMESTAMP '2026-09-07 15:20:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-09-07',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('15562239-1bf3-5039-851d-0bdb02203173', 'aeb76dd0-d0eb-5232-a24a-1813ff8ff70b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.86),
  ('f8957e86-cd21-5fd6-8ea6-d3ce0a3ace76', 'aeb76dd0-d0eb-5232-a24a-1813ff8ff70b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 891),
  ('fa30b274-e359-58d1-8cf5-20c0978b642f', 'aeb76dd0-d0eb-5232-a24a-1813ff8ff70b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 547),
  ('a02c2574-df6e-5bc5-8f2d-7ac416be2fcf', 'aeb76dd0-d0eb-5232-a24a-1813ff8ff70b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 14.9);

-- E02 | Lima 2026-09-14 10:35 | línea base 15.2 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('f2c05f63-c0bb-571f-8cee-70b5103e8f2f', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E02'),
    TIMESTAMP '2026-09-14 15:35:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-09-14',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('5846669c-0883-5480-8e7e-6ec064539e39', 'f2c05f63-c0bb-571f-8cee-70b5103e8f2f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 8.00),
  ('9b176d5c-0dbf-53ab-800d-2b29cb859212', 'f2c05f63-c0bb-571f-8cee-70b5103e8f2f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 797),
  ('00ab6618-65fc-594e-9c45-9fae2d4db201', 'f2c05f63-c0bb-571f-8cee-70b5103e8f2f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 465),
  ('91335302-3b32-5151-a0c6-e6e49d7fc0db', 'f2c05f63-c0bb-571f-8cee-70b5103e8f2f',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 16.0);

-- E05 | Lima 2026-09-17 11:20 | línea base 16.4 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('d15146c2-d54a-5d06-bc1a-762de8268c81', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E05'),
    TIMESTAMP '2026-09-17 16:20:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-09-17',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('92f26c52-df90-5cc1-b181-7db98016ff8c', 'd15146c2-d54a-5d06-bc1a-762de8268c81',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 8.08),
  ('6490a484-b791-56aa-a0a0-0eac0d437b18', 'd15146c2-d54a-5d06-bc1a-762de8268c81',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1130),
  ('e0c8b084-1b36-50a7-afcb-6171af10cc09', 'd15146c2-d54a-5d06-bc1a-762de8268c81',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 687),
  ('b1a21b92-39f9-5748-9ec7-6347a7760e54', 'd15146c2-d54a-5d06-bc1a-762de8268c81',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), NULL);  -- caso: sin dato

-- E03 | Lima 2026-10-01 09:00 | línea base 16.6 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('883be476-e378-5cb9-afb2-1f0ee2a244ee', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E03'),
    TIMESTAMP '2026-10-01 14:00:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-10-01',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('f07d2d93-3e49-5ed3-87a2-dd1cf20048d4', '883be476-e378-5cb9-afb2-1f0ee2a244ee',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.73),
  ('a777cc82-a14f-52f6-b615-f826835165bc', '883be476-e378-5cb9-afb2-1f0ee2a244ee',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1615),  -- caso: conductividad apenas sobre 1 600
  ('fd48b1d6-03c7-5645-ab6e-6c41f4eafac7', '883be476-e378-5cb9-afb2-1f0ee2a244ee',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 985),  -- caso: TDS apenas bajo 1 000 (limitación)
  ('26b3d0c2-bf54-5946-88b2-1175676a0468', '883be476-e378-5cb9-afb2-1f0ee2a244ee',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.3);

-- E05 | Lima 2026-10-03 09:15 | línea base 17.4 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('72577437-90ab-5de5-a50e-083134d1dde5', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E05'),
    TIMESTAMP '2026-10-03 14:15:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-10-03',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('5075c79e-f8c8-595f-9f86-da2fa12fb075', '72577437-90ab-5de5-a50e-083134d1dde5',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.74),
  ('fd663d39-5068-5938-ac18-c4a88aec54bf', '72577437-90ab-5de5-a50e-083134d1dde5',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1120),
  ('23de884f-cdfc-5f2c-8b54-7947ba38ac95', '72577437-90ab-5de5-a50e-083134d1dde5',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 671),
  ('bdf886d7-a4a3-5d05-9b39-acb8aeee84ea', '72577437-90ab-5de5-a50e-083134d1dde5',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 16.9);

-- E04 | Lima 2026-10-10 11:10 | línea base 17.0 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('742d3ccc-2f96-5cca-8eb9-5690f07d1662', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E04'),
    TIMESTAMP '2026-10-10 16:10:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-10-10',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('7582fa6f-dc00-54a4-a947-7d8396cdb20f', '742d3ccc-2f96-5cca-8eb9-5690f07d1662',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.64),
  ('36533814-1ec5-56b5-9a6d-901f2c577042', '742d3ccc-2f96-5cca-8eb9-5690f07d1662',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1124),
  ('43ac4175-8037-57dc-8b2d-271aa2998b14', '742d3ccc-2f96-5cca-8eb9-5690f07d1662',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 686),
  ('3e58669d-bb86-5ec2-9d7e-1ca647a21d13', '742d3ccc-2f96-5cca-8eb9-5690f07d1662',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.1);

-- E02 | Lima 2026-10-14 11:05 | línea base 16.2 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('b71575ad-af17-5262-82bc-97ed43d888c0', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E02'),
    TIMESTAMP '2026-10-14 16:05:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-10-14',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('653a117c-fc53-584d-9619-95e3d5b44e62', 'b71575ad-af17-5262-82bc-97ed43d888c0',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 8.03),
  ('8665fa28-68da-5225-b3a8-56e8f0daa9ea', 'b71575ad-af17-5262-82bc-97ed43d888c0',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 886),
  ('0b6c888c-c241-54d4-8354-ee9389e9e36f', 'b71575ad-af17-5262-82bc-97ed43d888c0',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 531),
  ('b0ee2671-08e2-5a90-845d-da2c8bb12756', 'b71575ad-af17-5262-82bc-97ed43d888c0',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 12.6);  -- caso: temperatura bajo la línea base

-- E01 | Lima 2026-10-31 23:30 | línea base 15.8 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('bc8f2e61-4983-55e1-a6bb-2041eac8d175', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E01'),
    TIMESTAMP '2026-11-01 04:30:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-10-31',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('69bdc668-7b12-5002-858e-52d30ca88aec', 'bc8f2e61-4983-55e1-a6bb-2041eac8d175',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.63),
  ('058fe23e-b6af-5db9-a594-1649fdaca8db', 'bc8f2e61-4983-55e1-a6bb-2041eac8d175',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 858),
  ('1c19c6cb-d494-5b84-89f9-152f78665e0b', 'bc8f2e61-4983-55e1-a6bb-2041eac8d175',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 518),
  ('5cfcae1b-0f86-5a1b-9766-3ff73ead743e', 'bc8f2e61-4983-55e1-a6bb-2041eac8d175',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 13.4);  -- caso: visita 31/10 23:30 Lima: mes de línea base = octubre

-- E03 | Lima 2026-11-05 08:55 | línea base 17.8 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('88827854-7508-5116-9c76-ba4468784040', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E03'),
    TIMESTAMP '2026-11-05 13:55:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-11-05',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('bc93fac4-43f0-5f8e-a1db-18f6135bee2e', '88827854-7508-5116-9c76-ba4468784040',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.63),
  ('9ef9a4b5-80cb-58b4-8a4b-1ccc8125b220', '88827854-7508-5116-9c76-ba4468784040',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 897),
  ('7010fb23-3ba2-5e65-b214-d2b90e7b0cfe', '88827854-7508-5116-9c76-ba4468784040',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 547),
  ('172d37ba-cc30-5f6c-90a2-5c1273ed5c44', '88827854-7508-5116-9c76-ba4468784040',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.5);

-- E04 | Lima 2026-11-06 11:00 | línea base 18.2 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('e39fae4b-2913-536c-9570-f98492e8ae3e', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E04'),
    TIMESTAMP '2026-11-06 16:00:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-11-06',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('a7f67cef-1fe5-5646-ae21-190bc2cc7962', 'e39fae4b-2913-536c-9570-f98492e8ae3e',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.79),
  ('2f942104-2607-5b81-9145-5531b35e8954', 'e39fae4b-2913-536c-9570-f98492e8ae3e',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1690),  -- caso: conductividad alta (TDS = 0,6 x cond.)
  ('d934e454-1982-57d6-a426-3fc11a184117', 'e39fae4b-2913-536c-9570-f98492e8ae3e',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 1014),
  ('35b0f198-1f71-55f0-8810-8c57c4ee917a', 'e39fae4b-2913-536c-9570-f98492e8ae3e',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.2);

-- E01 | Lima 2026-11-12 11:10 | línea base 17.0 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('e2cd29d2-d01c-5104-9841-0a845d232c8b', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E01'),
    TIMESTAMP '2026-11-12 16:10:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-11-12',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('9bd27242-828e-5b76-8e15-124b7131fee4', 'e2cd29d2-d01c-5104-9841-0a845d232c8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.75),
  ('6a4b83b2-ef5c-5c49-a093-9dba2a1c8b9d', 'e2cd29d2-d01c-5104-9841-0a845d232c8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 801),
  ('01115221-00c2-5b77-bb1e-b624a9721f96', 'e2cd29d2-d01c-5104-9841-0a845d232c8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 467),
  ('d8053c4f-150a-5615-80dc-6bf2f726d96e', 'e2cd29d2-d01c-5104-9841-0a845d232c8b',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 15.6);

-- E05 | Lima 2026-11-13 09:40 | línea base 18.6 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('57c63f42-46c4-5dd1-8226-bdb9e02f3cd9', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E05'),
    TIMESTAMP '2026-11-13 14:40:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-11-13',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('4382bf06-8c38-5b22-8d42-0e235ed5bbdb', '57c63f42-46c4-5dd1-8226-bdb9e02f3cd9',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.63),
  ('ae6a7cb3-fcc0-5c6a-9d4a-c1e702be8f16', '57c63f42-46c4-5dd1-8226-bdb9e02f3cd9',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 1047),
  ('065e255b-4f1b-5f20-a2a1-0089794e8a7a', '57c63f42-46c4-5dd1-8226-bdb9e02f3cd9',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 628),
  ('c40e7481-7c28-50c6-954c-79fbb8441678', '57c63f42-46c4-5dd1-8226-bdb9e02f3cd9',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 19.2);

-- E02 | Lima 2026-11-15 09:00 | línea base 17.4 °C
INSERT INTO campo.monitoreo (uuid, codigo, estacion_uuid, fecha_hora_utc, estado, origen,
    equipo_modelo, calibracion_fecha, calibracion_detalle, certificado)
VALUES ('4c61a02d-6579-547d-8105-5501909009c1', NULL,
    (SELECT uuid FROM campo.estacion WHERE codigo = 'E02'),
    TIMESTAMP '2026-11-15 14:00:00', 'validado', 'simulado',
    'Multiparámetro portátil (simulado)', DATE '2026-11-15',
    'Calibración simulada con soluciones patrón', NULL);
INSERT INTO campo.medicion (uuid, monitoreo_uuid, parametro_uuid, valor) VALUES
  ('f6c1044a-218c-5214-bc7a-a3a7db28da8a', '4c61a02d-6579-547d-8105-5501909009c1',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'ph'), 7.85),
  ('8c55fe59-5afa-5a8d-b76b-7bae829994c2', '4c61a02d-6579-547d-8105-5501909009c1',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'conductividad'), 828),
  ('06dd4f2a-af9b-5443-ab8a-380865447fea', '4c61a02d-6579-547d-8105-5501909009c1',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'solidos_disueltos_totales'), 494),
  ('60fe95dd-73c0-53a1-8c83-b68f563977f2', '4c61a02d-6579-547d-8105-5501909009c1',
   (SELECT uuid FROM campo.parametro WHERE codigo = 'temperatura'), 17.0);
