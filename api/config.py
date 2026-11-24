"""Configuración leída de variables de entorno.

La conexión a la base usa las variables estándar de libpq (PGHOST, PGPORT,
PGDATABASE, PGUSER, PGPASSWORD), que psycopg lee por sí solo.
Aquí solo se valida la configuración del mapa base.
"""

import os
import re
from dataclasses import dataclass
from urllib.parse import quote, urlsplit

# CARTO Positron: teselas ráster públicas, no requieren API key.
POSITRON = "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"

ATRIBUCION = (
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors '
    '&copy; <a href="https://carto.com/attributions">CARTO</a>'
)

_HOST_VALIDO = re.compile(r"^(\*\.)?[a-z0-9-]+(\.[a-z0-9-]+)+$")


class ErrorConfig(ValueError):
    """Configuración inválida: la app no debe arrancar."""


@dataclass(frozen=True)
class MapaBase:
    url: str
    subdominios: str
    max_zoom: int
    atribucion: str
    origen_csp: str  # origen de las teselas para img-src de la CSP

    def publico(self) -> dict:
        """Solo lo que el mapa necesita en el navegador."""
        return {
            "url": self.url,
            "subdominios": self.subdominios,
            "max_zoom": self.max_zoom,
            "atribucion": self.atribucion,
        }


def leer_mapa_base(env=None) -> MapaBase:
    env = os.environ if env is None else env
    url = (env.get("MAPA_BASE_URL") or "").strip() or POSITRON
    clave = (env.get("CARTO_API_KEY") or "").strip()

    if not url.startswith("https://"):
        raise ErrorConfig("MAPA_BASE_URL debe empezar por https://")
    for marcador in ("{z}", "{x}", "{y}"):
        if marcador not in url:
            raise ErrorConfig(f"MAPA_BASE_URL debe contener {marcador}")
    if "{api_key}" in url:
        if not clave:
            raise ErrorConfig("MAPA_BASE_URL usa {api_key} pero CARTO_API_KEY está vacía")
        url = url.replace("{api_key}", quote(clave, safe=""))

    host = (urlsplit(url).hostname or "").replace("{s}", "*")
    if not _HOST_VALIDO.match(host):
        raise ErrorConfig("MAPA_BASE_URL tiene un host no válido")

    return MapaBase(
        url=url,
        subdominios="abcd" if "{s}" in url else "",
        max_zoom=20,
        atribucion=ATRIBUCION,
        origen_csp=f"https://{host}",
    )
