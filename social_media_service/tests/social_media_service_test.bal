import ballerinax/postgresql;
import ballerina/test;
import ballerina/http;

@test:Mock {
    functionName: "initSocialMediaDb"
}

//creating the mock client
function initMockSocialMediaDb() returns postgresql:Client|error => test:mock(postgresql:Client);

@test:Config{}
function testUsersById() returns error? {
    User userExpected = {
        id: 999,
        name: "kalam",
        dateOfBirth: {year: 1978, month: 7, day: 15},
        mobileNumber: "0777123123"
    }
    //tell when mock is executing what is expected
    test:prepare(socialMediaDb).when("queryRow").thenReturn(userExpected);

    //using http client to trigger the test function
    configurable string socialMediaEndPointUrl = check ?;
    http:Client socialMediaEndPoint = check new(socialMediaEndPointUrl)
    User userActual = socialMediaEndPoint->/users/[userExpected.id.toString()];

    test:assertEquals(userActual,userExpected);
}