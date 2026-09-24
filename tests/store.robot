*** Settings ***
Documentation    Tests covering the /store endpoints: orders and inventory.
Resource         ../resources/store_keywords.resource
Test Tags        store


*** Test Cases ***
Place An Order For A Pet
    [Documentation]    A new order can be placed and is returned as created.
    [Tags]    smoke
    ${pet}=    New Pet Payload
    Create Pet    ${pet}
    ${order}=    New Order Payload    ${pet}[id]
    ${response}=    Place Order    ${order}
    Status Should Be    200    ${response}
    Should Be Equal As Strings    ${response.json()}[petId]    ${pet}[id]
    Should Be Equal As Strings    ${response.json()}[status]    placed

Get Order By Id Returns The Placed Order
    [Documentation]    A placed order can be fetched by its id.
    ${pet}=    New Pet Payload
    Create Pet    ${pet}
    ${order}=    New Order Payload    ${pet}[id]
    Place Order    ${order}
    ${response}=    Get Order By Id    ${order}[id]
    Status Should Be    200    ${response}
    Should Be Equal As Strings    ${response.json()}[id]    ${order}[id]

Delete Order Removes It From The Store
    [Documentation]    A deleted order can no longer be fetched.
    ${pet}=    New Pet Payload
    Create Pet    ${pet}
    ${order}=    New Order Payload    ${pet}[id]
    Place Order    ${order}
    ${delete_response}=    Delete Order    ${order}[id]
    Status Should Be    200    ${delete_response}
    ${get_response}=    Get Order By Id    ${order}[id]
    Status Should Be    404    ${get_response}

Get Order By Id With Unknown Id Returns Not Found
    [Documentation]    Fetching an order that was never placed returns a 404.
    ${response}=    Get Order By Id    999999999
    Status Should Be    404    ${response}

Store Inventory Returns Quantities Per Status
    [Documentation]    The inventory endpoint returns a map of status to quantity.
    ${response}=    Get Inventory
    Status Should Be    200    ${response}
    Dictionary Should Contain Key    ${response.json()}    available
