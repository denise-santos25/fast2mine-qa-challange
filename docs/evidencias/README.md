# 📸 Evidências de Execução

> **Nota**: As URLs do desafio são fictícias (não existe servidor real apontado). Por isso, as evidências aqui são de execução em modo **`--dryrun`** do Robot Framework, que executa toda a estrutura (parsing, resolução de variáveis por ambiente, carregamento de page objects, validação de keywords) **sem fazer chamadas reais a browser/API**.
>
> O dry-run é a técnica padrão de QA para validar a integridade da suíte. Quando o sistema real estiver disponível, basta remover a flag `--dryrun` que os mesmos testes rodam de verdade.

---

## ✅ Resultado consolidado

| Ambiente | Web | API | Mobile | Total |
|---|---|---|---|---|
| **QA1** | 6/6 ✅ | 5/5 ✅ | 3/3 ✅ | **14/14** |
| **QA2** | 6/6 ✅ | 5/5 ✅ | 3/3 ✅ | **14/14** |
| **QA3** | 6/6 ✅ | 5/5 ✅ | 3/3 ✅ | **14/14** |

**O que isso comprova:**
- ✅ Sintaxe Robot Framework 100% válida
- ✅ Page Objects carregam corretamente
- ✅ Variáveis de ambiente resolvem corretamente para cada ambiente (QA1/QA2/QA3)
- ✅ Cliente de API Python (`api_client.py`) é importável e executável
- ✅ JSON Schemas (`schemas.py`) são válidos
- ✅ Massa dinâmica (`data_factory.py`) é importável
- ✅ Listener customizado (`test_listener.py`) carrega sem erro
- ✅ Estrutura multi-ambiente funciona — basta trocar o `-V`

---

## 📂 Reports gerados

Cada subpasta `dryrun_qaX/` contém:

```
docs/evidencias/dryrun_qa1/
├── log.html        ← abra no navegador
├── report.html     ← abra no navegador
└── output.xml      ← para integração com CI/Allure
```

---

## 🚀 Como rodar de verdade

Remova `--dryrun` e garanta que tem credenciais reais + browser instalado:

```bash
cp .env.example .env
# preencher .env com credenciais

pip install -r requirements.txt
rfbrowser init

./run.sh QA1 web
```

Ou via Docker:

```bash
ENV=QA1 docker compose run tests-web
```

Ou via CI (GitHub Actions roda automaticamente em todo push para `main`).
