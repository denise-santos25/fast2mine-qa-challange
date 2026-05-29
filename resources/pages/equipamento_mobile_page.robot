*** Settings ***
Documentation    Page Object Mobile: tela de equipamentos no app.
Library          AppiumLibrary

*** Variables ***
# Login mobile
${MOB_INPUT_USER}            accessibility_id=input_username
${MOB_INPUT_PASS}            accessibility_id=input_password
${MOB_BTN_LOGIN}             accessibility_id=btn_login

# Navegação
${MOB_BOTTOM_NAV_EQUIP}      accessibility_id=tab_equipamentos
${MOB_SEARCH_INPUT}          accessibility_id=search_equipamento
${MOB_SEARCH_BTN}            accessibility_id=btn_search

# Resultado
${MOB_LIST_ITEM_TPL}         xpath=//*[@content-desc="equipamento_item" and @text="{name}"]
${MOB_STATUS_TPL}            xpath=//*[@content-desc="equipamento_item" and @text="{name}"]/following-sibling::*[@content-desc="status"]
${MOB_EMPTY_STATE}           accessibility_id=empty_state

# Edição
${MOB_BTN_EDITAR_TPL}        xpath=//*[@content-desc="equipamento_item" and @text="{name}"]/..//*[@content-desc="btn_editar"]
${MOB_EDIT_INPUT_NAME}       accessibility_id=edit_input_nome
${MOB_BTN_SALVAR}            accessibility_id=btn_salvar
${MOB_TOAST_SUCCESS}         accessibility_id=toast_success

*** Keywords ***
Logar No App
    Wait Until Page Contains Element    ${MOB_INPUT_USER}    timeout=15s
    Input Text                          ${MOB_INPUT_USER}    ${USERNAME}
    Input Password                      ${MOB_INPUT_PASS}    ${PASSWORD}
    Click Element                       ${MOB_BTN_LOGIN}

Abrir Aba Equipamentos
    Wait Until Page Contains Element    ${MOB_BOTTOM_NAV_EQUIP}    timeout=15s
    Click Element                       ${MOB_BOTTOM_NAV_EQUIP}
    Wait Until Page Contains Element    ${MOB_SEARCH_INPUT}    timeout=10s

Buscar Equipamento Mobile
    [Arguments]    ${termo}
    Input Text     ${MOB_SEARCH_INPUT}    ${termo}
    Click Element  ${MOB_SEARCH_BTN}

Validar Equipamento Listado Mobile
    [Arguments]    ${nome}
    ${seletor}=    Replace String    ${MOB_LIST_ITEM_TPL}    {name}    ${nome}
    Wait Until Page Contains Element    ${seletor}    timeout=10s

Validar Status Equipamento Mobile
    [Arguments]    ${nome}    ${status_esperado}
    ${seletor}=    Replace String    ${MOB_STATUS_TPL}    {name}    ${nome}
    Wait Until Page Contains Element    ${seletor}    timeout=10s
    ${texto}=      Get Text    ${seletor}
    Should Be Equal As Strings    ${texto}    ${status_esperado}

Validar Estado Vazio Mobile
    Wait Until Page Contains Element    ${MOB_EMPTY_STATE}    timeout=10s
