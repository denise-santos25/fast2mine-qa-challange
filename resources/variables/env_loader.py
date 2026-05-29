"""
env_loader.py
---------------
Resolver de ambiente para Robot Framework.

Uso:
    robot --variable ENV:QA1 --variablefile resources/variables/env_loader.py tests/web

A variável ENV pode vir de 3 lugares (ordem de prioridade):
    1. --variable ENV:QAx (CLI)
    2. Variável de ambiente do SO (export ENV=QAx)
    3. Default = QA1

Esse arquivo NÃO carrega o .robot do ambiente (o Robot faz isso via -V no comando).
Aqui apenas exportamos metadados auxiliares e validamos o valor.
"""
import os


SUPPORTED_ENVS = {"QA1", "QA2", "QA3"}


def get_variables(env: str = None):
    # Prioridade: argumento posicional > variável de ambiente SO > default
    env = (env or os.environ.get("ENV") or "QA1").upper().strip()

    if env not in SUPPORTED_ENVS:
        raise ValueError(
            f"Ambiente '{env}' não suportado. "
            f"Valores válidos: {sorted(SUPPORTED_ENVS)}"
        )

    return {
        "ENV":              env,
        "ENV_CONFIG_FILE":  f"environments/{env.lower()}.robot",
        "SUPPORTED_ENVS":   sorted(SUPPORTED_ENVS),
    }
