*** Settings ***
Documentation    Page Object: tela de Login.
Library          Browser

*** Variables ***
${LOGIN_INPUT_USER}        id=input-username
${LOGIN_INPUT_PASS}        id=input-password
${LOGIN_BTN_SUBMIT}        id=btn-login
${LOGIN_MSG_ERROR}         css=[data-test="login-error"]
${LOGIN_LOGGED_AVATAR}     css=[data-test="user-avatar"]

*** Keywords ***
Abrir Tela De Login
    [Documentation]    Abre a URL base e garante que o form de login está visível.
    New Page           ${BASE_URL}/login
    Get Element        ${LOGIN_INPUT_USER}

Preencher Credenciais
    [Arguments]        ${user}    ${pwd}
    Fill Text          ${LOGIN_INPUT_USER}    ${user}
    Fill Secret        ${LOGIN_INPUT_PASS}    $pwd

Submeter Login
    Click              ${LOGIN_BTN_SUBMIT}

Validar Login Com Sucesso
    Wait For Elements State    ${LOGIN_LOGGED_AVATAR}    visible    timeout=10s

Validar Erro De Login
    [Arguments]        ${mensagem_esperada}
    Wait For Elements State    ${LOGIN_MSG_ERROR}    visible    timeout=5s
    Get Text           ${LOGIN_MSG_ERROR}    ==    ${mensagem_esperada}
