*** Settings ***
Documentation    Keywords wrapping the /user endpoints of the Petstore API.
Resource         common.resource
Library          Collections


*** Keywords ***
Create User
    [Documentation]    Registers a new user and returns the response.
    [Arguments]    ${user}
    ${response}=    POST On Session    ${SESSION}    /user    json=${user}
    RETURN    ${response}

Get User By Name
    [Documentation]    Fetches a user by username. Non-2xx responses are returned, not raised.
    [Arguments]    ${username}
    ${response}=    GET On Session    ${SESSION}    /user/${username}    expected_status=any
    RETURN    ${response}

Update User
    [Documentation]    Updates an existing user and returns the response.
    [Arguments]    ${username}    ${user}
    ${response}=    PUT On Session    ${SESSION}    /user/${username}    json=${user}
    RETURN    ${response}

Delete User
    [Documentation]    Deletes a user by username. Non-2xx responses are returned, not raised.
    [Arguments]    ${username}
    ${response}=    DELETE On Session    ${SESSION}    /user/${username}    expected_status=any
    RETURN    ${response}

Login User
    [Documentation]    Logs a user in and returns the response.
    [Arguments]    ${username}    ${password}
    &{params}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    GET On Session    ${SESSION}    /user/login    params=&{params}
    RETURN    ${response}

New User Payload
    [Documentation]    Builds a valid User payload for the given username.
    [Arguments]    ${username}
    ${id}=    Evaluate    random.randint(100000, 999999)    modules=random
    &{user}=    Create Dictionary
    ...    id=${id}
    ...    username=${username}
    ...    firstName=Robot
    ...    lastName=Tester
    ...    email=${username}@example.com
    ...    password=P4ssw0rd!
    ...    phone=0102030405
    ...    userStatus=${1}
    RETURN    ${user}

Generate Random Username
    [Documentation]    Returns a unique username usable for user tests.
    ${suffix}=    Evaluate    random.randint(100000, 999999)    modules=random
    RETURN    robot_user_${suffix}
