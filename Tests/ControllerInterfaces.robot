*** Settings ***
Documentation    Welcome to Meter's QA Engineer Take-Home Challenge!
...              Example keywords for Python's "ipaddress" module are
...              included to get you started. Feel free to modify these
...              starter files as needed!
Resource         /home/nagera/qa-engineer-takehome-challenge/Resources/MocNocAPI.resource
Library          String

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=         3x
${GLOBAL_RETRY_INTERVAL}=       1s

*** Test Cases ***

Get API response from controller
    [Documentation]     Validate if we get response from controller
    Log                 Fetching API response
    # Re-try if API is reachable 3 times at 1 seconds interval
    ${resp}             Wait Until Keyword Succeeds
    ...                 ${GLOBAL_RETRY_AMOUNT}
    ...                 ${GLOBAL_RETRY_INTERVAL}
    ...                 Get Moc-Noc API Endpoint
    Run Keyword If      "200" != """${resp.status_code}"""  Fatal Error
    # Save response value since we dont want to make multiple API requests to controller
    set suite variable  ${resp}

Gateway IP Addresses Are Private
    [Documentation]     Validate if the provided gateway IP addresses are private
    Log                 The Api response is ${resp}
    FOR    ${item}    IN    @{resp.json()}
        # Filter out only Data Structures with network in keys
        IF   "network" in """${item}"""
            Log    Validating gateway IP ${resp.json()}[${item}][dhcp][gateway] for network ${item}
            # Verify if the gateway is an IP address
            TRY
                ${ip_addr}    Evaluate Ipaddress Module Expression
                ...                  ${resp.json()}[${item}][dhcp][gateway]
                Log     ${resp.json()}[${item}][dhcp][gateway] is private : ${ip_addr.is_private}
            EXCEPT   AS  ${message}
                Log     Validating Gateway IP ${resp.json()}[${item}][dhcp][gateway]
                ...               for network ${item} failed with message: ${message}
            END
            Should Be True   ${ip_addr.is_private}

        END
    END

IP Addresses With VLSM Match DHCP Netmask
    [Documentation]     Validate if the provided DHCP netmask match the ip-address netmask
    Log                 The Api response is ${resp}
    FOR    ${item}    IN    @{resp.json()}
        IF   "network" in """${item}"""
            Log      Validating VLSM match for ${resp.json()}[${item}][dhcp][gateway] for ${item}
            TRY
                ${ip_addr}    Evaluate Ipaddress Module Expression
                ...  ${resp.json()}[${item}][ip-address]
            EXCEPT   AS  ${msg}
                Log    Validating ${resp.json()}[${item}][ip-address] failed with message: ${msg}
            END
            Log     The subnet of ip-address is ${ip_addr.netmask}
            Log     The subnet of dhcp config is ${resp.json()}[${item}][dhcp][netmask]
            Should Be True   '''${ip_addr.netmask}'''=='''${resp.json()}[${item}][dhcp][netmask]'''
        END
    END

DHCP Range Is Valid For Interface IP Addresses
    [Documentation]     Verify if the provided ip range is valid and falls under the netmask
    Log                 The Api response is ${resp}
    FOR    ${item}    IN    @{resp.json()}
        IF   "network" in """${item}"""
            Log      Validating gateway IP ${resp.json()}[${item}][dhcp][gateway] for ${item}
            # split the subnet to lower and upper IP range
            ${split_resp}=  Split String	 ${resp.json()}[${item}][dhcp][ip-range]  -
            TRY
                # verify if the ip-address is valid
                ${ip_address_nw_obj}  Compute Network IP Address From Interface
                ...  ${resp.json()}[${item}][ip-address]
            EXCEPT   AS  ${message}
                Log    Validating IP-address failed with message: ${message}
            END

            FOR    ${ip}    IN    @{split_resp}
                Log  IP address to verify ${ip}
                TRY
                    # verify if the ip is valid
                    ${ip_address_obj}  Evaluate Ipaddress Module Expression   ${ip}
                EXCEPT   AS  ${message}
                    Log    Validating IP-address ${ip} failed with message: ${message}
                END
                # verify if the ip belongs in the subnet
                ${ip_address_in_subnet}
                ...  Evaluate Ipaddress ipNetwork Expression
                ...  ${ip_address_nw_obj}  ${ip_address_obj}

                Log   ${ip} belongs to subnet ${ip_address_nw_obj} is ${ip_address_in_subnet}
                Should Be True   ${ip_address_in_subnet}
            END
        END
    END

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
    [Arguments]        ${api_data}
    # Add Get Moc-Noc API Endpoint keyword call here
    ${ipaddress}       Evaluate Ipaddress Module Expression    ${api_data}
    RETURN             ${ipaddress.network}

Evaluate Ipaddress ipNetwork Expression
    [Documentation]    Returns an true if the IP address belongs to subnet.
    [Arguments]        @{args}
    ${expression}      Set Variable    ipaddress.ip_interface('''${args[1]}''').ip in ipaddress.ip_interface('''${args[0]}''').network
    ${ip_is_in_range}     Evaluate    ${expression}    modules=ipaddress
    RETURN             ${ip_is_in_range}