*** Settings ***
Documentation       Suite de testes Web — Equipamentos
...                 Cobre busca, edição e validação de status do equipamento
...                 válido do ambiente atual (QA1/QA2/QA3).
...
...                 Execução:
...                 robot -V environments/qa1.robot -d results/qa1 tests/web

Resource            ../../resources/keywords/common.robot
Resource            ../../resources/keywords/business_keywords.robot
Resource            ../../resources/pages/equipamento_page.robot
Library             ../../resources/variables/data_factory.py

Suite Setup         Abrir Browser Para Ambiente
Suite Teardown      Close Browser    ALL
Test Setup          Logar No Sistema
Test Teardown       Fechar Browser E Anexar Evidências

Force Tags          web    equipamentos


*** Test Cases ***
TC-WEB-001 - Buscar Equipamento Válido Do Ambiente
    [Documentation]    Valida que o equipamento esperado para o ambiente atual
    ...                aparece na listagem ao ser buscado pelo nome.
    [Tags]    positivo    smoke    busca

    Abrir Tela De Equipamentos
    Buscar Equipamento    ${EQUIPMENT}
    Validar Equipamento Listado    ${EQUIPMENT}

TC-WEB-002 - Validar Status Do Equipamento
    [Documentation]    Confirma que o equipamento válido do ambiente está com
    ...                status ${EXPECTED_STATUS}.
    [Tags]    positivo    smoke    status

    Garantir Equipamento Do Ambiente Listado
    Validar Status Do Equipamento    ${EQUIPMENT}    ${EXPECTED_STATUS}

TC-WEB-003 - Editar Equipamento Com Massa Dinâmica E Persistir
    [Documentation]    Edita o nome do equipamento com sufixo único e valida
    ...                persistência após reload da página.
    [Tags]    positivo    regressao    edicao

    Garantir Equipamento Do Ambiente Listado
    ${dados}=    Gerar Dados Equipamento    ${EQUIPMENT}
    Editar Equipamento E Salvar    ${dados.nome_editado}
    Reload
    Abrir Tela De Equipamentos
    Buscar Equipamento    ${dados.nome_editado}
    Validar Equipamento Listado    ${dados.nome_editado}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Editar Equipamento E Salvar    ${EQUIPMENT}
    ...    AND    Fechar Browser E Anexar Evidências

TC-WEB-004 - Cancelar Edição Não Persiste Alterações
    [Documentation]    Garante que cancelar a edição preserva o nome original.
    [Tags]    positivo    edicao

    Garantir Equipamento Do Ambiente Listado
    Abrir Edição Do Equipamento    ${EQUIPMENT}
    Editar Nome Do Equipamento     CANCELADO_NAO_PERSISTE
    Cancelar Edição
    Reload
    Abrir Tela De Equipamentos
    Buscar Equipamento    ${EQUIPMENT}
    Validar Equipamento Listado    ${EQUIPMENT}

TC-WEB-005 - Buscar Equipamento Inexistente Exibe Estado Vazio
    [Documentation]    Validação negativa: busca por termo aleatório retorna estado vazio.
    [Tags]    negativo    busca

    Abrir Tela De Equipamentos
    ${termo_invalido}=    Gerar Busca Invalida
    Buscar Equipamento    ${termo_invalido}
    Validar Nenhum Equipamento Listado

TC-WEB-006 - Salvar Edição Com Campo Obrigatório Vazio Falha
    [Documentation]    Validação negativa: nome em branco bloqueia o save.
    [Tags]    negativo    edicao    validacao

    Garantir Equipamento Do Ambiente Listado
    Abrir Edição Do Equipamento    ${EQUIPMENT}
    Editar Nome Do Equipamento     ${EMPTY}
    Salvar Edição
    Validar Erro De Campo Obrigatório
