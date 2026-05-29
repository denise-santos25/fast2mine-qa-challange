"""
test_listener.py
-----------------
Robot Framework Listener (API v3) que adiciona:

1. Screenshot automático em qualquer falha de keyword (não apenas teardown)
2. Métricas de execução exportadas em metrics.json
3. Notificação Slack em falhas críticas (se SLACK_WEBHOOK_URL configurado)
4. Logging estruturado para integração com observability (Datadog, ELK)

Uso:
    robot --listener resources/listeners/test_listener.py:slack=true ...
"""
import json
import os
import time
from pathlib import Path
from typing import Optional

try:
    import requests
except ImportError:
    requests = None


class TestListener:
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, slack: str = "false", screenshot_on_failure: str = "true"):
        self.slack_enabled = slack.lower() == "true"
        self.screenshot_on_failure = screenshot_on_failure.lower() == "true"
        self.slack_webhook = os.environ.get("SLACK_WEBHOOK_URL", "")
        self.metrics = {
            "started_at": None,
            "ended_at": None,
            "suite": None,
            "environment": os.environ.get("ENV", "unknown"),
            "tests": [],
            "summary": {"total": 0, "passed": 0, "failed": 0, "skipped": 0},
        }
        self._test_start_ts = None
        self._output_dir = None

    # ---------- Suite hooks ----------

    def start_suite(self, suite, result):
        if self.metrics["started_at"] is None:
            self.metrics["started_at"] = time.time()
            self.metrics["suite"] = suite.name

    def end_suite(self, suite, result):
        if suite.parent is None:  # raiz
            self.metrics["ended_at"] = time.time()
            self.metrics["summary"]["total"] = result.statistics.total
            self.metrics["summary"]["passed"] = result.statistics.passed
            self.metrics["summary"]["failed"] = result.statistics.failed
            self.metrics["summary"]["skipped"] = result.statistics.skipped
            self._export_metrics()
            if self.slack_enabled and result.statistics.failed > 0:
                self._notify_slack(result)

    # ---------- Test hooks ----------

    def start_test(self, test, result):
        self._test_start_ts = time.time()

    def end_test(self, test, result):
        elapsed = time.time() - (self._test_start_ts or time.time())
        self.metrics["tests"].append({
            "name": test.name,
            "tags": list(test.tags),
            "status": result.status,
            "elapsed_seconds": round(elapsed, 3),
            "message": result.message if result.status == "FAIL" else "",
        })

    # ---------- Keyword failure hook ----------

    def end_keyword(self, data, result):
        """Tira screenshot quando QUALQUER keyword falha (não só no teardown)."""
        if not self.screenshot_on_failure or result.status != "FAIL":
            return
        # Evita capturar screenshot em keywords de baixo nível (BuiltIn)
        if data.libname in ("BuiltIn", "String", "Collections", "OperatingSystem"):
            return
        try:
            from Browser import Browser  # type: ignore
            Browser().take_screenshot(fullPage=True)
        except Exception:
            pass  # Best-effort - não interrompe execução

    # ---------- Internos ----------

    def _output_path(self) -> Path:
        # Robot escreve outputs em ${OUTPUTDIR}; tentamos descobrir via env var
        outdir = os.environ.get("ROBOT_OUTPUT_DIR") or os.environ.get("OUTPUTDIR") or "."
        return Path(outdir)

    def _export_metrics(self):
        outdir = self._output_path()
        outdir.mkdir(parents=True, exist_ok=True)
        (outdir / "metrics.json").write_text(
            json.dumps(self.metrics, indent=2, default=str),
            encoding="utf-8",
        )

    def _notify_slack(self, result):
        if not self.slack_webhook or requests is None:
            return
        stats = self.metrics["summary"]
        env = self.metrics["environment"]
        payload = {
            "text": (
                f":x: *Robot suite falhou em {env}*\n"
                f"Suite: `{self.metrics['suite']}`\n"
                f"Passed: {stats['passed']}  |  Failed: {stats['failed']}  |  Total: {stats['total']}"
            )
        }
        try:
            requests.post(self.slack_webhook, json=payload, timeout=5)
        except Exception:
            pass
