*** Settings ***
Documentation       Suite Mobile (Appium) — Equipamentos
...
...                 Pré-requisitos:
...                 - Appium Server rodando em ${APPIUM_URL}
...                 - Emulador/dispositivo Android ativo (adb devices)
...                 - APK do ambiente correspondente instalado
...
...                 Execução:
...                 robot -V environments/qa1.robot -d results/mobile_qa1 tests/mobile

Library             AppiumLibrary
Library             String
Resource            ../../resources/pages/equipamento_mobile_page.robot
Library             ../../resources/variables/data_factory.py

Suite Setup         Iniciar Sessão Appium
Suite Teardown      Close All Applications
Test Setup          Logar No App
Test Teardown       Run Keyword If Test Failed    Capture Page Screenshot

Force Tags          mobile    equipamentos


*** Keywords ***
Iniciar Sessão Appium
    Log To Console      \nMobile - Ambiente: ${ENV} | App: ${APP_PACKAGE}
    Open Application    ${APPIUM_URL}
    ...                 platformName=Android
    ...                 automationName=UiAutomator2
    ...                 deviceName=Android
    ...                 appPackage=${APP_PACKAGE}
    ...                 appActivity=${APP_ACTIVITY}
    ...                 noReset=${TRUE}
    ...                 newCommandTimeout=120


*** Test Cases ***
TC-MOB-001 - Buscar Equipamento Válido No App
    [Tags]    positivo    smoke

    Abrir Aba Equipamentos
    Buscar Equipamento Mobile         ${EQUIPMENT}
    Validar Equipamento Listado Mobile    ${EQUIPMENT}

TC-MOB-002 - Validar Status Do Equipamento No App
    [Tags]    positivo    status

    Abrir Aba Equipamentos
    Buscar Equipamento Mobile         ${EQUIPMENT}
    Validar Status Equipamento Mobile    ${EQUIPMENT}    ${EXPECTED_STATUS}

TC-MOB-003 - Buscar Equipamento Inexistente Mostra Estado Vazio
    [Tags]    negativo    busca

    Abrir Aba Equipamentos
    ${termo}=    Gerar Busca Invalida
    Buscar Equipamento Mobile    ${termo}
    Validar Estado Vazio Mobile
