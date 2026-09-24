*** Settings ***
Documentation    Shared HTTP session handling for every Petstore API test suite.
Library          RequestsLibrary


*** Variables ***
${SESSION}          petstore


*** Keywords ***
Create Petstore Session
    [Documentation]    Creates the HTTP session reused by every test in the run.
    Create Session    ${SESSION}    ${BASE_URL}    verify=${True}

Delete Petstore Session
    [Documentation]    Tears down the HTTP session once the run is finished.
    Delete All Sessions
