*** Settings ***
Documentation       Suite API — Equipamentos
...
...                 Cobre o backend da feature de equipamentos:
...                 - GET /equipments      (listagem + busca)
...                 - GET /equipments/:id  (detalhe)
...                 - PATCH /equipments/:id (edição)
...                 - Validação contratual via JSON Schema
...                 - Validação de SLA (response time)
...
...                 Execução:
...                 robot -V environments/qa1.robot tests/api

Library             ../../resources/libraries/api_client.py    WITH NAME    API
Library             RequestsLibrary
Library             Collections
Library             ../../resources/libraries/schemas.py
Library             jsonschema

Suite Setup         Autenticar Na API
Force Tags          api    equipamentos


*** Keywords ***
Autenticar Na API
    ${client}=      Evaluate    __import__('api_client', fromlist=['EquipmentApiClient']).EquipmentApiClient('${API_URL}')
    ...             modules=sys, resources.libraries.api_client
    Set Suite Variable    ${API_CLIENT}    ${client}
    ${response}=    Call Method    ${API_CLIENT}    login    ${USERNAME}    ${PASSWORD}
    Should Be True  ${response.is_success}    Login API falhou: ${response.status_code}

Validar Schema
    [Arguments]     ${data}    ${schema}
    ${result}=      Evaluate    __import__('jsonschema').validate(instance=$data, schema=$schema)


*** Test Cases ***
TC-API-001 - GET /equipments/:id Retorna 200 E Schema Válido
    [Documentation]    Valida contrato e payload do endpoint de detalhe.
    [Tags]    positivo    contrato    smoke

    ${response}=    Call Method    ${API_CLIENT}    get_equipment    ${EQUIPMENT_ID}
    Should Be Equal As Integers    ${response.status_code}    200
    Validar Schema    ${response.json_body}    ${EQUIPMENT_SCHEMA}
    Should Be Equal    ${response.json_body['environment']}    ${ENV}
    Should Be Equal    ${response.json_body['name']}    ${EQUIPMENT}

TC-API-002 - GET /equipments Lista Apenas Equipamentos Do Ambiente
    [Documentation]    Garante isolamento por ambiente (não vaza dados de outros tenants).
    [Tags]    positivo    seguranca    multitenancy

    ${response}=    Call Method    ${API_CLIENT}    list_equipments
    Should Be Equal As Integers    ${response.status_code}    200
    Validar Schema    ${response.json_body}    ${EQUIPMENT_LIST_SCHEMA}
    FOR    ${item}    IN    @{response.json_body['items']}
        Should Be Equal    ${item['environment']}    ${ENV}
    END

TC-API-003 - Response Time Dentro Do SLA
    [Documentation]    SLA acordado: P95 < 500ms para endpoints de leitura.
    [Tags]    positivo    performance    sla

    ${response}=    Call Method    ${API_CLIENT}    get_equipment    ${EQUIPMENT_ID}
    Should Be True    ${response.elapsed_ms} < 500
    ...               msg=Response time ${response.elapsed_ms}ms excedeu SLA de 500ms

TC-API-004 - PATCH Equipamento Inexistente Retorna 404
    [Tags]    negativo    contrato

    ${response}=    Call Method    ${API_CLIENT}    update_equipment    EQ-INEXISTENTE-999    {"name": "x"}
    Should Be Equal As Integers    ${response.status_code}    404
    Validar Schema    ${response.json_body}    ${ERROR_SCHEMA}

TC-API-005 - PATCH Com Nome Vazio Retorna 400
    [Tags]    negativo    contrato    validacao

    ${response}=    Call Method    ${API_CLIENT}    update_equipment    ${EQUIPMENT_ID}    {"name": ""}
    Should Be Equal As Integers    ${response.status_code}    400
    Validar Schema    ${response.json_body}    ${ERROR_SCHEMA}
