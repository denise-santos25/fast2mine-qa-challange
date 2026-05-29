*** Settings ***
Documentation    Variáveis específicas do ambiente QA1.
...              Credenciais (USERNAME/PASSWORD) são injetadas via secrets_loader.py.

*** Variables ***
${ENV}                  QA1
${BASE_URL}             https://qa1.sistema.fast2mine.com
${EQUIPMENT}            Caminhão_01
${EQUIPMENT_ID}         EQ-QA1-001
${API_URL}              https://api.qa1.sistema.fast2mine.com
${EXPECTED_STATUS}      Ativo

# Performance/timeouts específicos do ambiente
${HTTP_TIMEOUT}         30s
${PAGE_LOAD_TIMEOUT}    20s
${RETRY_ATTEMPTS}       3
${RETRY_INTERVAL}       2s

# Mobile
${APP_PACKAGE}          com.fast2mine.qa1
${APP_ACTIVITY}         .MainActivity
