*** Settings ***
Documentation    Tests covering the /user endpoints: registration, lookup and login.
Resource         ../resources/user_keywords.resource
Test Tags        user


*** Test Cases ***
Create A New User
    [Documentation]    A new user can be registered and then looked up by name.
    [Tags]    smoke
    ${username}=    Generate Random Username
    ${user}=    New User Payload    ${username}
    ${response}=    Create User    ${user}
    Status Should Be    200    ${response}
    ${get_response}=    Get User By Name    ${username}
    Status Should Be    200    ${get_response}
    Should Be Equal As Strings    ${get_response.json()}[username]    ${username}
    Should Be Equal As Strings    ${get_response.json()}[email]    ${user}[email]

Update User Changes Its Profile
    [Documentation]    Updating a user persists the new field values.
    ${username}=    Generate Random Username
    ${user}=    New User Payload    ${username}
    Create User    ${user}
    Set To Dictionary    ${user}    firstName=Updated
    ${response}=    Update User    ${username}    ${user}
    Status Should Be    200    ${response}
    ${get_response}=    Get User By Name    ${username}
    Should Be Equal As Strings    ${get_response.json()}[firstName]    Updated

Delete User Removes It From The Store
    [Documentation]    A deleted user can no longer be fetched.
    ${username}=    Generate Random Username
    ${user}=    New User Payload    ${username}
    Create User    ${user}
    ${delete_response}=    Delete User    ${username}
    Status Should Be    200    ${delete_response}
    ${get_response}=    Get User By Name    ${username}
    Status Should Be    404    ${get_response}

Login With Valid Credentials Succeeds
    [Documentation]    A registered user can log in and receives a session message.
    ${username}=    Generate Random Username
    ${user}=    New User Payload    ${username}
    Create User    ${user}
    ${response}=    Login User    ${username}    ${user}[password]
    Status Should Be    200    ${response}
    Should Contain    ${response.json()}[message]    logged in user

Get User By Name With Unknown User Returns Not Found
    [Documentation]    Fetching a user that was never created returns a 404.
    ${response}=    Get User By Name    unknown_user_does_not_exist
    Status Should Be    404    ${response}
