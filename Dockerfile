# =============================================================
# Fast2Mine QA - Test Runner Container
# =============================================================
# Imagem base oficial do Playwright com Python 3.12 + browsers.
# Já vem com Chromium, Firefox e Webkit instalados.
# =============================================================

FROM mcr.microsoft.com/playwright/python:v1.49.0-noble

LABEL maintainer="QA Team <qa@fast2mine.com>"
LABEL description="Robot Framework + Browser Library + Appium client"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    ROBOT_OUTPUT_DIR=/app/results \
    PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Node.js já vem na imagem do Playwright
# Instalar Python deps
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Inicializar Browser Library (link com node_modules do Playwright)
RUN rfbrowser init --skip-browsers

# Copiar projeto
COPY . .

# Default: rodar suite web em QA1
# Override:  docker run ... fast2mine-qa ./run.sh QA2 web
ENTRYPOINT ["./run.sh"]
CMD ["QA1", "web"]
