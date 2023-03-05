*** Settings ***
Documentation
Library           RequestsLibrary

*** Variables ***
${BASE_URL}    https://moc-noc-api.deta.dev


*** Keywords ***
Get Moc-Noc API Endpoint
    [Documentation]     Fetch the controller endpoint
    ${resp}=    GET    ${BASE_URL}
    Status Should Be    OK    ${resp}
    Log To Console      ${resp}
    [return]    ${resp}
