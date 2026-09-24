*** Settings ***
Documentation    Keywords wrapping the /store endpoints of the Petstore API.
Resource         common.resource
Resource         pet_keywords.resource


*** Keywords ***
Place Order
    [Documentation]    Places an order for a pet and returns the response.
    [Arguments]    ${order}
    ${response}=    POST On Session    ${SESSION}    /store/order    json=${order}
    RETURN    ${response}

Get Order By Id
    [Documentation]    Fetches an order by id. Non-2xx responses are returned, not raised.
    [Arguments]    ${order_id}
    ${response}=    GET On Session    ${SESSION}    /store/order/${order_id}    expected_status=any
    RETURN    ${response}

Delete Order
    [Documentation]    Deletes an order by id. Non-2xx responses are returned, not raised.
    [Arguments]    ${order_id}
    ${response}=    DELETE On Session    ${SESSION}    /store/order/${order_id}    expected_status=any
    RETURN    ${response}

Get Inventory
    [Documentation]    Returns the map of pet status to quantity in the store.
    ${response}=    GET On Session    ${SESSION}    /store/inventory
    RETURN    ${response}

New Order Payload
    [Documentation]    Builds a valid Order payload for the given pet id.
    [Arguments]    ${pet_id}    ${status}=placed
    ${order_id}=    Evaluate    random.randint(1, 10)    modules=random
    &{order}=    Create Dictionary
    ...    id=${order_id}
    ...    petId=${pet_id}
    ...    quantity=${1}
    ...    status=${status}
    ...    complete=${False}
    RETURN    ${order}
