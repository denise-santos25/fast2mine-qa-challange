*** Settings ***
Documentation    Page Object: tela de Equipamentos (busca, listagem, edição, status).
Library          Browser

*** Variables ***
# Listagem / busca
${EQ_MENU_LINK}              css=[data-test="menu-equipamentos"]
${EQ_SEARCH_INPUT}           id=input-busca-equipamento
${EQ_SEARCH_BTN}             id=btn-buscar
${EQ_LIST_ROW}               css=[data-test="equipamento-row"]
${EQ_EMPTY_STATE}            css=[data-test="empty-state"]

# Linha do equipamento (templates dinâmicos)
${EQ_ROW_BY_NAME_TPL}        css=[data-test="equipamento-row"][data-name="{name}"]
${EQ_STATUS_BY_NAME_TPL}     css=[data-test="equipamento-row"][data-name="{name}"] [data-test="status"]
${EQ_EDIT_BTN_BY_NAME_TPL}   css=[data-test="equipamento-row"][data-name="{name}"] [data-test="btn-editar"]

# Modal de edição
${EQ_EDIT_INPUT_NAME}        id=input-edit-nome
${EQ_EDIT_BTN_SAVE}          id=btn-salvar
${EQ_EDIT_BTN_CANCEL}        id=btn-cancelar
${EQ_TOAST_SUCCESS}          css=[data-test="toast-success"]
${EQ_FIELD_ERROR_NAME}       css=[data-test="error-nome"]

*** Keywords ***
Abrir Tela De Equipamentos
    Click                       ${EQ_MENU_LINK}
    Wait For Elements State     ${EQ_SEARCH_INPUT}    visible    timeout=10s

Buscar Equipamento
    [Arguments]                 ${termo}
    Fill Text                   ${EQ_SEARCH_INPUT}    ${termo}
    Click                       ${EQ_SEARCH_BTN}

Validar Equipamento Listado
    [Arguments]                 ${nome}
    ${seletor}=                 Replace String    ${EQ_ROW_BY_NAME_TPL}    {name}    ${nome}
    Wait For Elements State     ${seletor}    visible    timeout=10s

Validar Nenhum Equipamento Listado
    Wait For Elements State     ${EQ_EMPTY_STATE}    visible    timeout=10s
    Get Element Count           ${EQ_LIST_ROW}    ==    0

Validar Status Do Equipamento
    [Arguments]                 ${nome}    ${status_esperado}
    ${seletor}=                 Replace String    ${EQ_STATUS_BY_NAME_TPL}    {name}    ${nome}
    Wait For Elements State     ${seletor}    visible    timeout=10s
    Get Text                    ${seletor}    ==    ${status_esperado}

Abrir Edição Do Equipamento
    [Arguments]                 ${nome}
    ${seletor}=                 Replace String    ${EQ_EDIT_BTN_BY_NAME_TPL}    {name}    ${nome}
    Click                       ${seletor}
    Wait For Elements State     ${EQ_EDIT_INPUT_NAME}    visible    timeout=10s

Editar Nome Do Equipamento
    [Arguments]                 ${novo_nome}
    Clear Text                  ${EQ_EDIT_INPUT_NAME}
    Fill Text                   ${EQ_EDIT_INPUT_NAME}    ${novo_nome}

Salvar Edição
    Click                       ${EQ_EDIT_BTN_SAVE}

Cancelar Edição
    Click                       ${EQ_EDIT_BTN_CANCEL}

Validar Toast De Sucesso
    Wait For Elements State     ${EQ_TOAST_SUCCESS}    visible    timeout=10s

Validar Erro De Campo Obrigatório
    Wait For Elements State     ${EQ_FIELD_ERROR_NAME}    visible    timeout=5s
    Get Text                    ${EQ_FIELD_ERROR_NAME}    ==    Campo obrigatório
