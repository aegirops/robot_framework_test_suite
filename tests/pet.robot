*** Settings ***
Documentation    Tests covering the /pet endpoints: create, read, update, delete and search.
Resource         ../resources/pet_keywords.resource
Test Tags        pet


*** Test Cases ***
Add A New Pet To The Store
    [Documentation]    A new pet can be added and is returned as created.
    ${pet}=    New Pet Payload
    ${response}=    Create Pet    ${pet}
    Status Should Be    200    ${response}
    Should Be Equal As Strings    ${response.json()}[name]    ${pet}[name]
    Should Be Equal As Strings    ${response.json()}[status]    ${pet}[status]

Get Pet By Id Returns The Created Pet
    [Documentation]    A previously created pet can be fetched by its id.
    [Tags]    smoke
    ${pet}=    New Pet Payload    name=Milou
    Create Pet    ${pet}
    ${response}=    Get Pet By Id    ${pet}[id]
    Status Should Be    200    ${response}
    Should Be Equal As Strings    ${response.json()}[id]    ${pet}[id]
    Should Be Equal As Strings    ${response.json()}[name]    Milou

Update An Existing Pet Changes Its Status
    [Documentation]    Updating a pet persists the new field values.
    ${pet}=    New Pet Payload    status=available
    Create Pet    ${pet}
    Set To Dictionary    ${pet}    status=sold
    ${response}=    Update Pet    ${pet}
    Status Should Be    200    ${response}
    ${get_response}=    Get Pet By Id    ${pet}[id]
    Should Be Equal As Strings    ${get_response.json()}[status]    sold

Find Pets By Status Returns Only Matching Pets
    [Documentation]    Searching by status only returns pets with that status.
    ${pet}=    New Pet Payload    status=pending
    Create Pet    ${pet}
    ${response}=    Find Pets By Status    pending
    Status Should Be    200    ${response}
    ${pets}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${pets}
    FOR    ${found_pet}    IN    @{pets}
        Should Be Equal As Strings    ${found_pet}[status]    pending
    END

Delete A Pet Removes It From The Store
    [Documentation]    A deleted pet can no longer be fetched.
    ${pet}=    New Pet Payload
    Create Pet    ${pet}
    ${delete_response}=    Delete Pet    ${pet}[id]
    Status Should Be    200    ${delete_response}
    ${get_response}=    Get Pet By Id    ${pet}[id]
    Status Should Be    404    ${get_response}

Get Pet By Id With Unknown Id Returns Not Found
    [Documentation]    Fetching a pet that was never created returns a 404.
    ${response}=    Get Pet By Id    999999999
    Status Should Be    404    ${response}
