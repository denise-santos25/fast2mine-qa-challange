<!-- omit in toc -->
# 🚛 Fast2Mine — QA Automation Framework

[![CI](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](.github/workflows/tests.yml)
[![Robot Framework](https://img.shields.io/badge/Robot_Framework-7.1-00B5A0?logo=robotframework&logoColor=white)](https://robotframework.org/)
[![Playwright](https://img.shields.io/badge/Playwright-1.49-2EAD33?logo=playwright&logoColor=white)](https://playwright.dev/)
[![Appium](https://img.shields.io/badge/Appium-2.x-AA00FF?logo=appium&logoColor=white)](https://appium.io/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)

> **Framework de automação E2E** para a feature de Equipamentos da Fast2Mine — Web, Mobile e API, com pipeline CI/CD, paralelização, observabilidade e quality gates integrados.

---

## 📑 Sumário

- [🎯 O que está aqui](#-o-que-está-aqui)
- [🏛️ Arquitetura](#️-arquitetura)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [🌍 Multi-ambiente](#-multi-ambiente)
- [🚀 Quick Start](#-quick-start)
- [🐳 Docker](#-docker)
- [🤖 CI/CD](#-cicd)
- [📊 Reporting & Observabilidade](#-reporting--observabilidade)
- [🧪 Camadas de Teste](#-camadas-de-teste)
- [🔐 Secrets Management](#-secrets-management)
- [✨ Qualidade de Código](#-qualidade-de-código)
- [📚 Documentação Adicional](#-documentação-adicional)

---

## 🎯 O que está aqui

Framework completo de automação cobrindo **3 camadas** (UI Web, UI Mobile e API), com práticas de engenharia que escalam para times distribuídos:

| Categoria | Implementação |
|---|---|
| **Automação Web** | Robot Framework + Browser Library (Playwright) |
| **Automação Mobile** | Robot Framework + AppiumLibrary (Android/UiAutomator2) |
| **Automação API** | RequestsLibrary + JSON Schema validation |
| **Multi-ambiente** | QA1/QA2/QA3 sem alteração de código |
| **Secrets** | GitHub Secrets em CI, `.env` em dev local (nunca em código) |
| **CI/CD** | GitHub Actions com matriz, lint, paralelização, Allure |
| **Observabilidade** | Listener customizado + métricas JSON + Slack alerts |
| **Paralelização** | Pabot com `--testlevelsplit` |
| **Containerização** | Docker + Docker Compose |
| **Qualidade** | Robocop (linter) + Robotidy (formatter) + pre-commit hooks |
| **Resiliência** | Retry pattern, polling estável, schema validation |

---

## 🏛️ Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│                         TESTS LAYER                          │
│   tests/web/         tests/mobile/         tests/api/        │
└──────┬───────────────────┬─────────────────────┬─────────────┘
       │                   │                     │
┌──────▼───────────────────▼─────────────────────▼─────────────┐
│                     KEYWORDS LAYER                           │
│   business_keywords.robot  •  common.robot  •  resilience.robot │
└──────┬───────────────────────────────────────────────────────┘
       │
┌──────▼───────────────────────────────────────────────────────┐
│                      PAGES / CLIENTS LAYER                   │
│   pages/*.robot (POM)  •  libraries/api_client.py            │
└──────┬───────────────────────────────────────────────────────┘
       │
┌──────▼───────────────────────────────────────────────────────┐
│                   CONFIG / DATA LAYER                        │
│   environments/qa*.robot  •  env_loader.py  •  secrets_loader.py │
│   data_factory.py (massa dinâmica)  •  schemas.py            │
└──────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
        Listener         Reports        Notifications
     (auto-screenshot)  (Allure + RF)     (Slack)
```

---

## 📁 Estrutura do Projeto

```
fast2mine-qa-challenge/
├── .github/workflows/
│   └── tests.yml                    # Pipeline CI/CD com matriz multi-ambiente
├── docs/
│   ├── 00_Test_Strategy.docx        # 📋 Estratégia de testes (entregável senior)
│   ├── 01_Casos_de_Teste.docx       # 10 casos manuais
│   ├── 02_Bug_Report.docx           # Reporte de bug
│   └── evidencias/                  # Reports de execução
├── environments/                    # 1 arquivo por ambiente
│   ├── qa1.robot
│   ├── qa2.robot
│   └── qa3.robot
├── resources/
│   ├── keywords/
│   │   ├── common.robot             # Setup/teardown
│   │   ├── business_keywords.robot  # Fluxos compostos
│   │   └── resilience.robot         # 🆕 Retry/polling/flaky handling
│   ├── libraries/                   # 🆕 Bibliotecas Python customizadas
│   │   ├── api_client.py            # Cliente HTTP encapsulado
│   │   └── schemas.py               # JSON Schemas
│   ├── listeners/                   # 🆕 Robot Listeners customizados
│   │   └── test_listener.py         # Screenshot/metrics/Slack
│   ├── pages/                       # Page Objects
│   │   ├── login_page.robot
│   │   ├── equipamento_page.robot
│   │   └── equipamento_mobile_page.robot
│   └── variables/
│       ├── env_loader.py            # Resolver de ambiente
│       ├── secrets_loader.py        # 🆕 Credenciais via env vars
│       └── data_factory.py          # Massa dinâmica
├── tests/
│   ├── web/                         # 6 testes UI Web
│   ├── mobile/                      # 3 testes UI Mobile
│   └── api/                         # 🆕 5 testes API + schema validation
├── .env.example                     # 🆕 Template de secrets
├── .pre-commit-config.yaml          # 🆕 Git hooks de qualidade
├── .robocop                         # 🆕 Linter config
├── .robotidy                        # 🆕 Formatter config
├── Dockerfile                       # 🆕 Container reproducível
├── docker-compose.yml               # 🆕 Orquestração local
├── run.sh / run.bat                 # Runners por ambiente
├── run-parallel.sh                  # 🆕 Pabot wrapper
└── README.md
```

---

## 🌍 Multi-ambiente

Cada ambiente é descrito em **um único arquivo** (`environments/qaX.robot`). Os testes **nunca** referenciam URL ou nome de equipamento hardcoded.

| Variável | QA1 | QA2 | QA3 |
|---|---|---|---|
| `${BASE_URL}` | `https://qa1.sistema.fast2mine.com` | `https://qa2...` | `https://qa3...` |
| `${EQUIPMENT}` | `Caminhão_01` | `Caminhão_02` | `Caminhão_03` |
| `${API_URL}` | `https://api.qa1...` | `https://api.qa2...` | `https://api.qa3...` |
| `${APP_PACKAGE}` | `com.fast2mine.qa1` | `com.fast2mine.qa2` | `com.fast2mine.qa3` |

**Credenciais NUNCA aparecem aqui** — vêm de `secrets_loader.py` que lê de:
1. GitHub Secrets (CI)
2. Arquivo `.env` (dev local — gitignored)
3. Falha explícita se ausentes

---

## 🚀 Quick Start

### 1. Setup local

```bash
git clone https://github.com/<user>/fast2mine-qa-challenge.git
cd fast2mine-qa-challenge

python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
rfbrowser init

cp .env.example .env  # preencher com credenciais reais
```

### 2. Rodar

```bash
# Web em QA1
./run.sh QA1 web

# Mobile em QA3
./run.sh QA3 mobile

# API em QA2
./run.sh QA2 api

# Execução paralela (Pabot)
./run-parallel.sh QA1 4
```

### 3. Ver resultados

```bash
open results/<env>_<type>_<timestamp>/report.html
open results/<env>_<type>_<timestamp>/metrics.json   # 🆕 métricas estruturadas
```

---

## 🐳 Docker

Zero dependência local — rode tudo containerizado:

```bash
# Build
docker compose build

# Executar
ENV=QA2 docker compose run tests-web
ENV=QA1 docker compose run tests-api

# Allure Server (visualização contínua)
docker compose up allure
# Abra http://localhost:5050
```

---

## 🤖 CI/CD

Pipeline em `.github/workflows/tests.yml` executa em **3 estágios**:

```
STAGE 1: LINT
  - Robocop (regras Robot)
  - Robotidy --check (formatação)
       ↓ blocked if fails
STAGE 2: TESTS (Matriz paralela 3×2 = 6 jobs)
  - QA1 web / QA1 api
  - QA2 web / QA2 api
  - QA3 web / QA3 api
       ↓
STAGE 3: AGGREGATE
  - Allure report consolidado
  - Upload de artifacts (30 dias retention)
  - Comentário no PR com resultados
```

**Triggers:**
- Push em `main`/`develop`
- Pull Request para `main`
- Smoke noturno agendado (06:00 UTC)
- Manual via `workflow_dispatch` (escolhendo ambiente e tipo)

---

## 📊 Reporting & Observabilidade

Quatro níveis de observabilidade:

### 1. Reports nativos do Robot
- `report.html` — sumário executivo
- `log.html` — log detalhado por keyword

### 2. Métricas estruturadas (`metrics.json`)
Geradas pelo `test_listener.py`:
```json
{
  "environment": "QA1",
  "summary": { "total": 6, "passed": 5, "failed": 1 },
  "tests": [
    { "name": "TC-WEB-001", "status": "PASS", "elapsed_seconds": 2.34, "tags": ["smoke"] }
  ]
}
```
Consumível por Datadog, Grafana, ELK ou qualquer ferramenta de observability.

### 3. Allure Report
Histórico, trends, flakiness detection — disponível em `http://localhost:5050` via Docker.

### 4. Notificações
- **Slack**: alertas automáticos em falhas críticas (via webhook)
- **PR comments**: dorny/test-reporter publica resultados como check no PR

---

## 🧪 Camadas de Teste

### 🔵 API (`tests/api/equipamentos_api.robot`) — 5 testes
Test Pyramid moderna: maioria da cobertura aqui (rápido + estável).

| ID | Cenário | Tags |
|---|---|---|
| TC-API-001 | GET /equipments/:id retorna 200 + schema válido | smoke, contrato |
| TC-API-002 | GET /equipments lista somente do ambiente (multi-tenancy) | seguranca |
| TC-API-003 | Response time < 500ms (SLA) | performance, sla |
| TC-API-004 | PATCH inexistente → 404 + schema de erro | negativo |
| TC-API-005 | PATCH com nome vazio → 400 + schema de erro | negativo |

### 🟢 Web (`tests/web/equipamentos.robot`) — 6 testes
Cobre fluxos críticos end-to-end. Não duplica o que API já valida.

### 🟣 Mobile (`tests/mobile/equipamentos_mobile.robot`) — 3 testes
Smoke do app Android.

---

## 🔐 Secrets Management

**Nunca** commite credenciais. Estratégia em camadas:

```bash
# Dev local
cp .env.example .env
# editar .env com credenciais reais (gitignored)

# CI
# GitHub Settings > Secrets > Actions:
#   QA1_USERNAME, QA1_PASSWORD
#   QA2_USERNAME, QA2_PASSWORD
#   QA3_USERNAME, QA3_PASSWORD
#   SLACK_WEBHOOK_URL (opcional)
```

`secrets_loader.py` valida que credenciais não são `changeme` antes de executar — falha cedo, em vez de tentar logar com placeholder.

---

## ✨ Qualidade de Código

Quality gates em **3 momentos**:

| Momento | Ferramenta | O que valida |
|---|---|---|
| **Antes do commit** | `pre-commit` hooks | trailing whitespace, secrets em código, branch protection |
| **No editor** | Robocop + Robotidy | regras de estilo Robot + formatação |
| **No CI** | Mesma stack | bloqueia merge se regras violadas |

Instalar pre-commit (uma vez):
```bash
pip install pre-commit
pre-commit install
```

---

## 📚 Documentação Adicional

- **[Test Strategy](docs/00_Test_Strategy.docx)** — visão estratégica completa: pyramid, riscos, métricas, roadmap
- **[Casos de Teste](docs/01_Casos_de_Teste.docx)** — 10 cenários manuais (positivos + negativos)
- **[Bug Report](docs/02_Bug_Report.docx)** — exemplo de bug documentado
- **[Evidências](docs/evidencias/README.md)** — execuções dry-run dos 3 ambientes

---

## 🛠️ Stack Detalhada

| Categoria | Ferramenta | Versão | Por quê |
|---|---|---|---|
| Test Runner | Robot Framework | 7.1.1 | Padrão BDD-like em Python, ótima para QA não-dev |
| Web Driver | Browser Library | 18.9.1 | Mais estável que Selenium, auto-wait nativo |
| Mobile | AppiumLibrary | 2.0.0 | Padrão da indústria para automação mobile |
| API | RequestsLibrary | 0.9.7 | Wrapper Robot do `requests` (mais idiomático) |
| Schema | jsonschema | 4.23 | Validação contratual JSON |
| Paralelização | Pabot | 4.1.0 | Diminui tempo de execução 3-4x |
| Reporting | Allure | 2.13.5 | Histórico, trends, flakiness detection |
| Linter | Robocop | 5.6.0 | Padrão da comunidade Robot |
| Formatter | Robotidy | 4.16.0 | Estilo consistente |
| CI | GitHub Actions | — | Nativo do GitHub, generoso no free tier |
| Container | Playwright + Python image | v1.49 | Browsers pré-instalados, build rápido |

---

## 📈 Próximas iterações

- [ ] Visual regression (Percy ou Chromatic)
- [ ] Acessibilidade automatizada (axe-core)
- [ ] Performance contínua (k6 integrado)
- [ ] iOS via AppiumLibrary (quando produto suportar)
- [ ] Synthetic monitoring em produção
