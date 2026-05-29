#!/usr/bin/env bash
# run-parallel.sh
# Executa testes em paralelo usando Pabot.
#
# Uso:
#   ./run-parallel.sh QA1 4    # roda QA1 com 4 processos paralelos

set -euo pipefail

ENV="${1:-QA1}"
PROCESSES="${2:-4}"

ENV_LOWER=$(echo "${ENV}" | tr '[:upper:]' '[:lower:]')
OUTDIR="results/${ENV_LOWER}_parallel_$(date +%Y%m%d_%H%M%S)"

echo "▶ Pabot: ENV=${ENV} | processos=${PROCESSES}"

pabot \
  --processes "${PROCESSES}" \
  --testlevelsplit \
  --variablefile resources/variables/env_loader.py:"${ENV}" \
  --variablefile resources/variables/secrets_loader.py:"${ENV}" \
  --variable ENV:"${ENV}" \
  -V environments/"${ENV_LOWER}".robot \
  --listener resources/listeners/test_listener.py \
  -d "${OUTDIR}" \
  tests/web tests/api

echo "✓ Execução paralela concluída: ${OUTDIR}/report.html"
