"""Pruebas mínimas sin base de datos: un repositorio falso sustituye al real."""

from datetime import date

import psycopg
import pytest
from fastapi.testclient import TestClient

from api.config import POSITRON, ErrorConfig, leer_mapa_base
from api.main import crear_app

MEDICION = {
    "estacion_uuid": "u-1", "estacion_codigo": "E01", "estacion": "Chosica",
    "monitoreo_codigo": "MON-0030", "fecha_hora_lima": "2026-11-20 09:40",
    "parametro": "pH", "unidad": "unidad de pH", "valor": 9.1,
    "limite_min": 5.5, "limite_max": 9.0, "semaforo": "no cumple", "origen": "simulado",
}


class RepoFalso:
    def __init__(self, caido=False):
        self.caido = caido
        self.llamada = None

    def ping(self):
        if self.caido:
            raise psycopg.OperationalError("sin conexión")

    def estaciones(self):
        return [{
            "estacion_uuid": "u-1", "codigo": "E01", "nombre": "Chosica",
            "monitoreo_codigo": "MON-0030", "fecha_hora_lima": "2026-11-20 09:40",
            "origen": "simulado", "semaforo_peor": "no cumple",
            "mediciones": [{k: MEDICION[k] for k in
                            ("parametro", "unidad", "valor", "limite_min", "limite_max", "semaforo")}],
            "geometria": {"type": "Point", "coordinates": [-76.699, -11.938]},
        }]

    def mediciones(self, estacion, parametro, desde, hasta, limite):
        self.llamada = (estacion, parametro, desde, hasta, limite)
        return [dict(MEDICION, total=7)]

    def parametros(self):
        return [{"parametro": "pH", "unidad": "unidad de pH"}]


@pytest.fixture
def repo():
    return RepoFalso()


@pytest.fixture
def cliente(repo):
    return TestClient(crear_app(repositorio=repo, env={}))


def test_salud_ok(cliente):
    r = cliente.get("/api/salud")
    assert r.status_code == 200 and r.json() == {"estado": "ok", "base": "ok"}


def test_salud_sin_base_devuelve_503():
    c = TestClient(crear_app(repositorio=RepoFalso(caido=True), env={}))
    r = c.get("/api/salud")
    assert r.status_code == 503
    assert "sin conexión" not in r.text  # no filtra detalles internos


def test_estaciones_geojson(cliente):
    r = cliente.get("/api/estaciones")
    assert r.status_code == 200
    fc = r.json()
    assert fc["type"] == "FeatureCollection"
    f = fc["features"][0]
    assert f["geometry"]["type"] == "Point"
    assert f["properties"]["codigo"] == "E01"
    assert f["properties"]["semaforo_peor"] == "no cumple"
    assert "geometria" not in f["properties"]


def test_mediciones_filtros_pasan_como_parametros(cliente, repo):
    r = cliente.get("/api/mediciones", params={
        "estacion": "u-1", "parametro": "pH", "desde": "2026-06-01", "hasta": "2026-11-30", "limite": 50})
    assert r.status_code == 200
    cuerpo = r.json()
    assert cuerpo["total"] == 7 and cuerpo["devueltas"] == 1
    assert "total" not in cuerpo["mediciones"][0]
    assert repo.llamada == ("u-1", "pH", date(2026, 6, 1), date(2026, 11, 30), 50)


@pytest.mark.parametrize("params", [
    {"desde": "2026-13-01"},
    {"hasta": "ayer"},
    {"desde": "2026-11-30", "hasta": "2026-06-01"},
    {"limite": 0},
    {"limite": 5001},
    {"estacion": "x' OR '1'='1"},
    {"parametro": "p" * 65},
])
def test_mediciones_parametros_invalidos(cliente, params):
    assert cliente.get("/api/mediciones", params=params).status_code == 422


def test_parametros(cliente):
    assert cliente.get("/api/parametros").json()[0]["parametro"] == "pH"


def test_solo_get(cliente):
    assert cliente.post("/api/mediciones").status_code == 405


def test_api_inexistente_404(cliente):
    assert cliente.get("/api/nada").status_code == 404


def test_cabeceras_seguridad(cliente):
    h = cliente.get("/api/salud").headers
    assert "default-src 'self'" in h["content-security-policy"]
    assert "img-src 'self' data: https://basemaps.cartocdn.com" in h["content-security-policy"]
    assert h["x-content-type-options"] == "nosniff"


# --- /api/config y validación del mapa base ---

def test_config_por_defecto_positron_sin_key(cliente):
    mb = cliente.get("/api/config").json()["mapa_base"]
    assert mb["url"] == POSITRON
    assert "OpenStreetMap" in mb["atribucion"] and "CARTO" in mb["atribucion"]
    assert set(mb) == {"url", "subdominios", "max_zoom", "atribucion"}


def test_config_carto_con_key_agrega_parametro():
    mb = leer_mapa_base({"CARTO_API_KEY": "k/1"})
    assert mb.url == POSITRON + "?key=k%2F1"
    assert mb.origen_csp == "https://basemaps.cartocdn.com"


def test_config_con_marcador_api_key():
    mb = leer_mapa_base({
        "MAPA_BASE_URL": "https://tiles.ejemplo.org/{z}/{x}/{y}.png?api_key={api_key}",
        "CARTO_API_KEY": "abc 123",
    })
    assert mb.url.endswith("api_key=abc%20123")
    assert mb.origen_csp == "https://tiles.ejemplo.org"
    assert mb.subdominios == ""


@pytest.mark.parametrize("url", [
    "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",   # sin https
    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}.png",       # falta {y}
    "https://tiles.ejemplo.org/{z}/{x}/{y}.png?k={api_key}",         # {api_key} sin key
    "https://tiles ejemplo.org/{z}/{x}/{y}.png",                     # host inválido
])
def test_config_invalida(url):
    with pytest.raises(ErrorConfig):
        leer_mapa_base({"MAPA_BASE_URL": url})
