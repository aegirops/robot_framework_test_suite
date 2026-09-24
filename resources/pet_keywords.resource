*** Settings ***
Documentation    Keywords wrapping the /pet endpoints of the Petstore API.
Resource         common.resource
Library          Collections


*** Keywords ***
Create Pet
    [Documentation]    Adds a new pet to the store and returns the response.
    [Arguments]    ${pet}
    ${response}=    POST On Session    ${SESSION}    /pet    json=${pet}
    RETURN    ${response}

Get Pet By Id
    [Documentation]    Fetches a pet by id. Non-2xx responses are returned, not raised.
    [Arguments]    ${pet_id}
    ${response}=    GET On Session    ${SESSION}    /pet/${pet_id}    expected_status=any
    RETURN    ${response}

Update Pet
    [Documentation]    Updates an existing pet and returns the response.
    [Arguments]    ${pet}
    ${response}=    PUT On Session    ${SESSION}    /pet    json=${pet}
    RETURN    ${response}

Delete Pet
    [Documentation]    Deletes a pet by id. Non-2xx responses are returned, not raised.
    [Arguments]    ${pet_id}
    ${response}=    DELETE On Session    ${SESSION}    /pet/${pet_id}    expected_status=any
    RETURN    ${response}

Find Pets By Status
    [Documentation]    Searches pets filtered by a single status value.
    [Arguments]    ${status}
    &{params}=    Create Dictionary    status=${status}
    ${response}=    GET On Session    ${SESSION}    /pet/findByStatus    params=&{params}
    RETURN    ${response}

New Pet Payload
    [Documentation]    Builds a minimal valid Pet payload with a unique id.
    [Arguments]    ${status}=available    ${name}=Rex
    ${id}=    Generate Random Id
    &{category}=    Create Dictionary    id=${1}    name=Dogs
    &{pet}=    Create Dictionary
    ...    id=${id}
    ...    category=${category}
    ...    name=${name}
    ...    photoUrls=${{['https://example.com/photo.jpg']}}
    ...    status=${status}
    RETURN    ${pet}

Generate Random Id
    [Documentation]    Returns a random integer usable as a pet, order or user id.
    ${id}=    Evaluate    random.randint(100000, 999999)    modules=random
    RETURN    ${id}
