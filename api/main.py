"""Geoportal de la red de monitoreo del río Rímac (tramo Chosica).

Un solo proceso: el API en /api/... (solo GET) y los estáticos del mapa en /.
"""

import logging
import os
from contextlib import asynccontextmanager
from datetime import date
from pathlib import Path
from typing import Annotated

import psycopg
from fastapi import Depends, FastAPI, HTTPException, Query, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from psycopg_pool import ConnectionPool, PoolTimeout

from .config import MapaBase, leer_mapa_base
from .consultas import Repositorio

log = logging.getLogger("geoportal")

WEB_DIR = Path(os.environ.get("WEB_DIR", Path(__file__).resolve().parent.parent / "web"))

PATRON_UUID = r"^[A-Za-z0-9{}-]{1,64}$"


def crear_pool() -> ConnectionPool:
    # conninfo vacío: psycopg toma PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD.
    return ConnectionPool(
        conninfo="",
        min_size=1,
        max_size=int(os.environ.get("POOL_MAX", "5")),
        timeout=5,
        open=False,
        kwargs={
            "application_name": "geoportal-rimac",
            "connect_timeout": 5,
            "options": "-c statement_timeout=5000 -c default_transaction_read_only=on",
        },
    )


def politica_csp(mapa: MapaBase) -> str:
    return "; ".join([
        "default-src 'self'",
        "script-src 'self'",
        "style-src 'self'",
        f"img-src 'self' data: {mapa.origen_csp}",
        "font-src 'self'",
        "connect-src 'self'",
        "object-src 'none'",
        "base-uri 'self'",
        "form-action 'self'",
        "frame-ancestors 'none'",
    ])


def crear_app(repositorio: Repositorio | None = None, env=None) -> FastAPI:
    """repositorio=None crea el pool real; las pruebas pasan uno falso."""
    mapa = leer_mapa_base(env)  # falla al arrancar si la configuración es inválida
    csp = politica_csp(mapa)

    @asynccontextmanager
    async def ciclo_vida(app: FastAPI):
        pool = None
        if repositorio is None:
            pool = crear_pool()
            pool.open(wait=False)  # arranca aunque la base no responda; /api/salud lo dirá
            app.state.repo = Repositorio(pool)
        yield
        if pool is not None:
            pool.close()

    app = FastAPI(title="Geoportal Rímac", docs_url=None, redoc_url=None,
                  openapi_url=None, lifespan=ciclo_vida)
    if repositorio is not None:
        app.state.repo = repositorio

    def obtener_repo(request: Request) -> Repositorio:
        return request.app.state.repo

    Repo = Annotated[Repositorio, Depends(obtener_repo)]

    @app.middleware("http")
    async def cabeceras_seguridad(request: Request, call_next):
        resp = await call_next(request)
        resp.headers["Content-Security-Policy"] = csp
        resp.headers["X-Content-Type-Options"] = "nosniff"
        resp.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        if request.url.path.startswith("/api/"):
            resp.headers["Cache-Control"] = "no-cache"
        return resp

    @app.exception_handler(psycopg.Error)
    @app.exception_handler(PoolTimeout)
    async def base_no_disponible(request: Request, exc: Exception):
        log.error("Error de base de datos en %s: %s", request.url.path, exc.__class__.__name__)
        return JSONResponse(status_code=503, content={"detalle": "base de datos no disponible"})

    @app.get("/api/salud")
    def salud(repo: Repo):
        repo.ping()  # si falla, el manejador devuelve 503
        return {"estado": "ok", "base": "ok"}

    @app.get("/api/config")
    def config():
        return {"mapa_base": mapa.publico()}

    @app.get("/api/estaciones")
    def estaciones(repo: Repo):
        features = []
        for f in repo.estaciones():
            geometria = f.pop("geometria")
            features.append({"type": "Feature", "geometry": geometria, "properties": f})
        return {"type": "FeatureCollection", "features": features}

    @app.get("/api/mediciones")
    def mediciones(
        repo: Repo,
        estacion: Annotated[str | None, Query(pattern=PATRON_UUID, description="estacion_uuid")] = None,
        parametro: Annotated[str | None, Query(min_length=1, max_length=64)] = None,
        desde: Annotated[date | None, Query(description="YYYY-MM-DD, hora Lima")] = None,
        hasta: Annotated[date | None, Query(description="YYYY-MM-DD, hora Lima, inclusive")] = None,
        limite: Annotated[int, Query(ge=1, le=5000)] = 1000,
    ):
        if desde and hasta and desde > hasta:
            raise HTTPException(status_code=422, detail="'desde' no puede ser posterior a 'hasta'")
        filas = repo.mediciones(estacion, parametro, desde, hasta, limite)
        total = filas[0]["total"] if filas else 0
        for f in filas:
            del f["total"]
        return {"total": total, "devueltas": len(filas), "mediciones": filas}

    @app.get("/api/parametros")
    def parametros(repo: Repo):
        return repo.parametros()

    @app.get("/api/{resto:path}", include_in_schema=False)
    def api_no_encontrada(resto: str):
        raise HTTPException(status_code=404, detail="no encontrado")

    if WEB_DIR.is_dir():
        app.mount("/", StaticFiles(directory=WEB_DIR, html=True), name="web")
    else:
        log.warning("No existe %s: solo se sirve el API", WEB_DIR)
    return app


app = crear_app()
