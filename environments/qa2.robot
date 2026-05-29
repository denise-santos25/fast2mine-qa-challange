*** Settings ***
Documentation    Variáveis específicas do ambiente QA2.
...              Credenciais (USERNAME/PASSWORD) são injetadas via secrets_loader.py.

*** Variables ***
${ENV}                  QA2
${BASE_URL}             https://qa2.sistema.fast2mine.com
${EQUIPMENT}            Caminhão_02
${EQUIPMENT_ID}         EQ-QA2-002
${API_URL}              https://api.qa2.sistema.fast2mine.com
${EXPECTED_STATUS}      Ativo

${HTTP_TIMEOUT}         30s
${PAGE_LOAD_TIMEOUT}    20s
${RETRY_ATTEMPTS}       3
${RETRY_INTERVAL}       2s

${APP_PACKAGE}          com.fast2mine.qa2
${APP_ACTIVITY}         .MainActivity
