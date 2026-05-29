"""
schemas.py
-----------
JSON Schemas para validação contratual de respostas da API.

Quando o backend muda a estrutura de resposta sem avisar (campo removido,
tipo alterado), esses schemas falham o teste e expõem o contract drift.
"""

EQUIPMENT_SCHEMA = {
    "type": "object",
    "required": ["id", "name", "status", "environment"],
    "properties": {
        "id":          {"type": "string", "pattern": "^EQ-QA[0-9]+-[0-9]+$"},
        "name":        {"type": "string", "minLength": 1, "maxLength": 100},
        "status":      {"type": "string", "enum": ["Ativo", "Inativo", "Manutenção", "Offline"]},
        "environment": {"type": "string", "enum": ["QA1", "QA2", "QA3"]},
        "operator":    {"type": ["string", "null"]},
        "hour_meter":  {"type": "integer", "minimum": 0},
        "updated_at":  {"type": "string", "format": "date-time"},
    },
    "additionalProperties": True,
}

EQUIPMENT_LIST_SCHEMA = {
    "type": "object",
    "required": ["items", "total"],
    "properties": {
        "items": {"type": "array", "items": EQUIPMENT_SCHEMA},
        "total": {"type": "integer", "minimum": 0},
        "page":  {"type": "integer"},
    },
}

ERROR_SCHEMA = {
    "type": "object",
    "required": ["error", "message"],
    "properties": {
        "error":   {"type": "string"},
        "message": {"type": "string"},
        "code":    {"type": ["integer", "string"]},
    },
}
