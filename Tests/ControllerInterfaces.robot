*** Settings ***
Documentation    Welcome to Meter's QA Engineer Take-Home Challenge!
...              Feel free to modify these starter files as needed.


*** Variables ***


*** Test Cases ***
DHCP Range Is Valid For Interface IP Addresses
    [Documentation]

Gateway IP Addresses Are Private
    [Documentation]

IP Addresses With VLSM Match DHCP Netmask
    [Documentation]


*** Keywords ***
Evaluate Ipaddress Module Expression
    [Documentation]    Returns an ipaddress module object created
    ...                with data from the Moc-Noc API.
    [Arguments]        ${api_data}    ${function}=ip_interface
    ${expression}      Set Variable    ipaddress.${function}("${api_data}")
    ${ipaddress}       Evaluate    ${expression}    modules=ipaddress
    RETURN             ${ipaddress}
