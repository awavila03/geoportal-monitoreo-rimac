-- Rol de solo lectura para la API del geoportal.
-- La contraseña NO va aquí: se asigna aparte con \password.
CREATE ROLE geoportal_ro LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
ALTER ROLE geoportal_ro SET default_transaction_read_only = on;

GRANT CONNECT ON DATABASE monitoreo_rimac TO geoportal_ro;
GRANT USAGE ON SCHEMA geoportal TO geoportal_ro;
GRANT SELECT ON geoportal.vista_semaforo TO geoportal_ro;
