-- Esquema campo: se sincroniza con Mergin Maps mediante db-sync.
-- Se ejecuta como aavila, pero los objetos quedan a nombre de dbsync.
SET ROLE dbsync;
SET search_path = campo, public;

CREATE TABLE campo.estacion (
    fid    serial PRIMARY KEY,
    uuid   text NOT NULL UNIQUE,
    codigo text NOT NULL UNIQUE,
    nombre text NOT NULL,
    geom   geometry(Point, 4326)
);

CREATE TABLE campo.parametro (
    fid    serial PRIMARY KEY,
    uuid   text NOT NULL UNIQUE,
    codigo text UNIQUE,
    nombre text,
    unidad text
);

CREATE TABLE campo.monitoreo (
    fid                 serial PRIMARY KEY,
    uuid                text NOT NULL UNIQUE,
    codigo              text UNIQUE,  -- lo asigna el trigger al insertar
    estacion_uuid       text REFERENCES campo.estacion (uuid) DEFERRABLE INITIALLY DEFERRED,
    fecha_hora_utc      timestamp without time zone,
    estado              text CHECK (estado IN ('borrador','enviado','observado','corregido','validado')),
    origen              text CHECK (origen IN ('campo','simulado')),
    equipo_modelo       text,
    calibracion_fecha   date,
    calibracion_detalle text,
    certificado         text,
    clima               text,
    color               text,
    olor                text,
    caudal_estimado     text CHECK (caudal_estimado IN ('bajo','medio','alto')),
    observaciones       text
);

CREATE TABLE campo.medicion (
    fid            serial PRIMARY KEY,
    uuid           text NOT NULL UNIQUE,
    monitoreo_uuid text REFERENCES campo.monitoreo (uuid) DEFERRABLE INITIALLY DEFERRED,
    parametro_uuid text REFERENCES campo.parametro (uuid) DEFERRABLE INITIALLY DEFERRED,
    valor          double precision
);

CREATE TABLE campo.foto_monitoreo (
    fid            serial PRIMARY KEY,
    uuid           text NOT NULL UNIQUE,
    monitoreo_uuid text REFERENCES campo.monitoreo (uuid) DEFERRABLE INITIALLY DEFERRED,
    foto           text,
    descripcion    text
);

-- Código del monitoreo: MON-0001, MON-0002, ...
CREATE SEQUENCE campo.monitoreo_codigo_seq;

CREATE FUNCTION campo.asignar_codigo_monitoreo() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.codigo IS NULL THEN
        NEW.codigo := 'MON-' || lpad(nextval('campo.monitoreo_codigo_seq')::text, 4, '0');
    END IF;
    RETURN NEW;
END
$$;

CREATE TRIGGER trg_monitoreo_codigo
    BEFORE INSERT ON campo.monitoreo
    FOR EACH ROW EXECUTE FUNCTION campo.asignar_codigo_monitoreo();

RESET ROLE;
