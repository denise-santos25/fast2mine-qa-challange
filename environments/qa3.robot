*** Settings ***
Documentation    Variáveis específicas do ambiente QA3.
...              Credenciais (USERNAME/PASSWORD) são injetadas via secrets_loader.py.

*** Variables ***
${ENV}                  QA3
${BASE_URL}             https://qa3.sistema.fast2mine.com
${EQUIPMENT}            Caminhão_03
${EQUIPMENT_ID}         EQ-QA3-003
${API_URL}              https://api.qa3.sistema.fast2mine.com
${EXPECTED_STATUS}      Ativo

${HTTP_TIMEOUT}         30s
${PAGE_LOAD_TIMEOUT}    20s
${RETRY_ATTEMPTS}       3
${RETRY_INTERVAL}       2s

${APP_PACKAGE}          com.fast2mine.qa3
${APP_ACTIVITY}         .MainActivity
