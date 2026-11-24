# Geoportal Rímac: un solo contenedor (API FastAPI + estáticos del mapa).
# Contexto de build = raíz del repo (ver deploy/compose.yaml).
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY api/requirements.txt api/requirements.txt
RUN pip install -r api/requirements.txt

COPY api/ api/
COPY web/ web/

# Usuario sin privilegios
RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app
USER 10001

EXPOSE 8000

# --proxy-headers: detrás de Caddy (el puerto no se publica fuera de la red docker).
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000", \
     "--proxy-headers", "--forwarded-allow-ips", "*", "--no-server-header"]
