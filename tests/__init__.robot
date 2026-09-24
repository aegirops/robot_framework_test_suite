*** Settings ***
Documentation      Petstore API test suite - https://petstore.swagger.io/v2
Resource           ../resources/common.resource
Suite Setup        Create Petstore Session
Suite Teardown     Delete Petstore Session
