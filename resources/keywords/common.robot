*** Settings ***
Documentation    Setup e teardown comuns para a suíte web.
Library          Browser
Library          OperatingSystem

*** Variables ***
${BROWSER}              chromium
${HEADLESS}             ${TRUE}
${VIEWPORT_WIDTH}       1366
${VIEWPORT_HEIGHT}      768
${DEFAULT_TIMEOUT}      15s

*** Keywords ***
Abrir Browser Para Ambiente
    [Documentation]    Abre o browser com config baseada no ambiente atual.
    ...                ${ENV} e ${BASE_URL} já estão resolvidos via -V do CLI.
    Log To Console     \nAmbiente: ${ENV} | URL: ${BASE_URL} | Equip: ${EQUIPMENT}
    New Browser        browser=${BROWSER}    headless=${HEADLESS}
    New Context        viewport={"width": ${VIEWPORT_WIDTH}, "height": ${VIEWPORT_HEIGHT}}
    ...                acceptDownloads=True
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

Fechar Browser E Anexar Evidências
    [Documentation]    Em caso de falha, captura screenshot final antes de fechar.
    Run Keyword If Test Failed    Take Screenshot    fullPage=True
    Close Browser    ALL
