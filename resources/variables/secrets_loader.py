"""
secrets_loader.py
------------------
Carrega credenciais sensíveis de variáveis de ambiente ou .env file.

Estratégia de fallback (em ordem):
    1. Variáveis de ambiente do SO/CI
    2. Arquivo .env na raiz do projeto (dev local)
    3. Falha explícita se obrigatórias estiverem faltando

Uso no CLI:
    robot --variablefile resources/variables/secrets_loader.py:QA1 ...

Em CI (GitHub Actions), as secrets são injetadas via env block:
    env:
      QA1_USERNAME: ${{ secrets.QA1_USERNAME }}
      QA1_PASSWORD: ${{ secrets.QA1_PASSWORD }}
"""
import os
from pathlib import Path


def _load_dotenv():
    """Parse simples de .env sem dependência externa."""
    dotenv = Path(__file__).resolve().parents[2] / ".env"
    if not dotenv.exists():
        return
    for line in dotenv.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        # Não sobrescreve env vars já definidas (CI > .env)
        os.environ.setdefault(key, value)


def _require(name: str) -> str:
    value = os.environ.get(name)
    if not value or value == "changeme":
        raise RuntimeError(
            f"Variável de ambiente '{name}' não definida. "
            f"Configure no .env (dev local) ou nas GitHub Secrets (CI)."
        )
    return value


def get_variables(env: str = "QA1"):
    _load_dotenv()
    env = env.upper().strip()

    return {
        "USERNAME": _require(f"{env}_USERNAME"),
        "PASSWORD": _require(f"{env}_PASSWORD"),
        "APPIUM_URL": os.environ.get("APPIUM_URL", "http://127.0.0.1:4723"),
        "SLACK_WEBHOOK_URL": os.environ.get("SLACK_WEBHOOK_URL", ""),
    }
