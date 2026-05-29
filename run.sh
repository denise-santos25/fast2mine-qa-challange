#!/usr/bin/env bash
# run.sh - Runner por ambiente e tipo de teste
#
# Uso:
#   ./run.sh QA1          # web QA1 (default)
#   ./run.sh QA2 mobile   # mobile QA2
#   ./run.sh QA1 api      # api QA1
#   ./run.sh QA3 web smoke   # web QA3 só tag smoke

set -euo pipefail

ENV="${1:-QA1}"
TYPE="${2:-web}"
TAG="${3:-}"

VALID_ENVS=(QA1 QA2 QA3)
VALID_TYPES=(web mobile api)

if [[ ! " ${VALID_ENVS[*]} " =~ " ${ENV} " ]]; then
  echo "❌ Ambiente inválido: ${ENV}. Use: ${VALID_ENVS[*]}"; exit 1
fi
if [[ ! " ${VALID_TYPES[*]} " =~ " ${TYPE} " ]]; then
  echo "❌ Tipo inválido: ${TYPE}. Use: ${VALID_TYPES[*]}"; exit 1
fi

ENV_LOWER=$(echo "${ENV}" | tr '[:upper:]' '[:lower:]')
OUTDIR="results/${ENV_LOWER}_${TYPE}_$(date +%Y%m%d_%H%M%S)"

EXTRA_ARGS=()
[[ -n "${TAG}" ]] && EXTRA_ARGS+=(--include "${TAG}")

echo "▶ ENV=${ENV} | TYPE=${TYPE} | TAG=${TAG:-(all)}"
echo "▶ Output: ${OUTDIR}"

export ROBOT_OUTPUT_DIR="${OUTDIR}"

robot \
  --variablefile resources/variables/env_loader.py:"${ENV}" \
  --variablefile resources/variables/secrets_loader.py:"${ENV}" \
  --variable ENV:"${ENV}" \
  -V environments/"${ENV_LOWER}".robot \
  --listener resources/listeners/test_listener.py \
  -d "${OUTDIR}" \
  "${EXTRA_ARGS[@]}" \
  tests/"${TYPE}"

echo "✓ Done. Open: ${OUTDIR}/report.html"
