"""
api_client.py
--------------
Cliente de API para setup/teardown rápido e validação backend.

Vantagens vs. UI-only:
- Setup de pré-condições 10-100x mais rápido (criar equipamento via API vs. tela)
- Cleanup garantido (DELETE direto, sem depender de UI)
- Validação contratual (status code, schema JSON)
- Detecta bugs de backend que UI mascara
"""
from dataclasses import dataclass
from typing import Optional
import requests


@dataclass
class ApiResponse:
    status_code: int
    json_body: dict
    headers: dict
    elapsed_ms: int

    @property
    def is_success(self) -> bool:
        return 200 <= self.status_code < 300


class EquipmentApiClient:
    """Cliente para a API de Equipamentos.

    Em produção, herdaria de uma BaseClient com auth, retry, circuit breaker,
    etc. Aqui mantemos enxuto pra clareza.
    """

    def __init__(self, base_url: str, token: Optional[str] = None, timeout: int = 30):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.timeout = timeout
        if token:
            self.session.headers["Authorization"] = f"Bearer {token}"
        self.session.headers["Content-Type"] = "application/json"
        self.session.headers["Accept"] = "application/json"

    def _wrap(self, response: requests.Response) -> ApiResponse:
        try:
            body = response.json()
        except ValueError:
            body = {}
        return ApiResponse(
            status_code=response.status_code,
            json_body=body,
            headers=dict(response.headers),
            elapsed_ms=int(response.elapsed.total_seconds() * 1000),
        )

    def login(self, username: str, password: str) -> ApiResponse:
        r = self.session.post(
            f"{self.base_url}/auth/login",
            json={"username": username, "password": password},
            timeout=self.timeout,
        )
        if r.ok:
            token = r.json().get("access_token")
            if token:
                self.session.headers["Authorization"] = f"Bearer {token}"
        return self._wrap(r)

    def get_equipment(self, equipment_id: str) -> ApiResponse:
        r = self.session.get(f"{self.base_url}/equipments/{equipment_id}", timeout=self.timeout)
        return self._wrap(r)

    def list_equipments(self, search: Optional[str] = None) -> ApiResponse:
        params = {"q": search} if search else None
        r = self.session.get(f"{self.base_url}/equipments", params=params, timeout=self.timeout)
        return self._wrap(r)

    def update_equipment(self, equipment_id: str, payload: dict) -> ApiResponse:
        r = self.session.patch(
            f"{self.base_url}/equipments/{equipment_id}",
            json=payload,
            timeout=self.timeout,
        )
        return self._wrap(r)

    def reset_equipment_name(self, equipment_id: str, original_name: str) -> ApiResponse:
        """Cleanup helper - restaura nome original via API (não UI)."""
        return self.update_equipment(equipment_id, {"name": original_name})
