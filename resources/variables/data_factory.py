"""
data_factory.py
----------------
Gerador de massa dinâmica para os testes.

Combina o equipamento BASE do ambiente (vindo do .robot do env) com
sufixos únicos baseados em timestamp + uuid curto, para evitar colisões
entre execuções paralelas/concorrentes.

Exemplo de uso no Robot:

    *** Settings ***
    Library    resources/variables/data_factory.py

    *** Test Cases ***
    Meu Teste
        ${dados}=    Gerar Dados Equipamento    Caminhão_01
        Log    ${dados.nome}    # Ex: Caminhão_01_EDIT_20260527T142301_a1b2
"""
from dataclasses import dataclass, asdict
from datetime import datetime
import uuid
import random


@dataclass
class EquipmentData:
    nome: str
    nome_editado: str
    codigo: str
    operador: str
    horimetro: int
    status: str

    def as_dict(self):
        return asdict(self)


def _stamp() -> str:
    ts = datetime.utcnow().strftime("%Y%m%dT%H%M%S")
    suffix = uuid.uuid4().hex[:4]
    return f"{ts}_{suffix}"


def gerar_dados_equipamento(equipamento_base: str) -> EquipmentData:
    """Gera um conjunto de dados dinâmicos para o equipamento atual."""
    stamp = _stamp()
    return EquipmentData(
        nome=equipamento_base,
        nome_editado=f"{equipamento_base}_EDIT_{stamp}",
        codigo=f"COD-{stamp.upper()}",
        operador=f"Operador_{random.randint(1000, 9999)}",
        horimetro=random.randint(100, 9999),
        status="Ativo",
    )


def gerar_busca_invalida() -> str:
    """String que garantidamente não retorna resultados."""
    return f"INEXISTENTE_{uuid.uuid4().hex[:8].upper()}"


def gerar_email_unico(prefix: str = "user") -> str:
    return f"{prefix}.{_stamp()}@fast2mine.com"
