*** Settings ***
Documentation    Keywords de negócio (fluxos compostos) — orquestram pages.
Resource         ../pages/login_page.robot
Resource         ../pages/equipamento_page.robot
Library          String
Library          Browser
Library          ../variables/data_factory.py

*** Keywords ***
Logar No Sistema
    [Documentation]    Fluxo completo de login usando credenciais do ambiente atual.
    Abrir Tela De Login
    Preencher Credenciais    ${USERNAME}    ${PASSWORD}
    Submeter Login
    Validar Login Com Sucesso

Garantir Equipamento Do Ambiente Listado
    [Documentation]    Pré-condição: confirma que o equipamento do ambiente atual aparece.
    Abrir Tela De Equipamentos
    Buscar Equipamento    ${EQUIPMENT}
    Validar Equipamento Listado    ${EQUIPMENT}

Editar Equipamento E Salvar
    [Arguments]    ${novo_nome}
    Abrir Edição Do Equipamento    ${EQUIPMENT}
    Editar Nome Do Equipamento     ${novo_nome}
    Salvar Edição
    Validar Toast De Sucesso

Restaurar Nome Original Do Equipamento
    [Documentation]    Hook de cleanup. Reverte alteração para deixar o ambiente limpo.
    Run Keyword And Ignore Error
    ...    Editar Equipamento E Salvar    ${EQUIPMENT}
