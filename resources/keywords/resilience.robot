*** Settings ***
Documentation    Keywords de resiliência: retry, wait com polling, soft assertions.
...              Padrão usado por suites maduras para reduzir flakiness sem mascarar bugs.
Library          Browser
Library          BuiltIn
Library          DateTime


*** Keywords ***
Retry Keyword
    [Documentation]    Executa uma keyword com retry/backoff. Falha real é preservada.
    ...                Use somente para operações sabidamente flaky (network, animações).
    [Arguments]    ${keyword}    @{args}    ${attempts}=${RETRY_ATTEMPTS}    ${interval}=${RETRY_INTERVAL}
    ${last_error}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE    1    ${attempts} + 1
        ${status}    ${error}=    Run Keyword And Ignore Error    ${keyword}    @{args}
        IF    '${status}' == 'PASS'    RETURN
        ${last_error}=    Set Variable    ${error}
        Log    Tentativa ${i}/${attempts} falhou: ${error}    level=WARN
        Sleep    ${interval}
    END
    Fail    Keyword '${keyword}' falhou após ${attempts} tentativas. Último erro: ${last_error}

Esperar Por Elemento Estável
    [Documentation]    Espera o elemento ficar visível E estável (sem reflow/animação).
    ...                Combate flakiness causada por animações CSS e re-renders React.
    [Arguments]    ${selector}    ${timeout}=10s    ${stable_for}=300ms
    Wait For Elements State    ${selector}    visible    timeout=${timeout}
    Wait For Function    e => {
    ...    const el = document.querySelector(arguments[0]);
    ...    if (!el) return false;
    ...    const r1 = el.getBoundingClientRect();
    ...    return new Promise(res => setTimeout(() => {
    ...      const r2 = el.getBoundingClientRect();
    ...      res(r1.x === r2.x && r1.y === r2.y);
    ...    }, ${stable_for.rstrip('ms')}));
    ...    }    ${selector}

Tentar Até Suceder
    [Documentation]    Polling com timeout: tenta a keyword a cada N segundos.
    ...                Diferente do Retry: não falha entre tentativas, só no final.
    [Arguments]    ${timeout}    ${interval}    ${keyword}    @{args}
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    ${keyword}    @{args}
