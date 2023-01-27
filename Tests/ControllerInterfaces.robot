*** Settings ***
Documentation    Welcome to Meter's QA Engineer Take-Home Challenge!
...              Example keywords for Python's "ipaddress" module are
...              included to get you started. Feel free to modify these
...              starter files as needed!


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

Compute Network IP Address From Interface
    [Documentation]    Returns a network IP address (e.g. 172.16.0.0/24) from
    ...                a VLSM interface IP address (e.g. 172.16.0.1/24).
    [Arguments]        ${api_endpoint}
    # Add Get Moc-Noc API Endpoint keyword call here
    ${ipaddress}       Evaluate Ipaddress Module Expression    ${api_data['ip-address']}
    RETURN             ${ipaddress.network}
