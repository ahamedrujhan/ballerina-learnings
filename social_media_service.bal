import ballerina/http;
import ballerina/time;

type User record {|
int id;
string name;
time:Date dateOfBirth;
string mobileNumber;
|};

service /social\-media on new http:Listener(9090) {
    resource function get getUsers() returns User[]|error? {
        User ruju = {id: 1,name: "Ruju",dateOfBirth: {year: 2001, month: 1, day: 5}, mobileNumber: "0775785129"};

        return [ruju];
    }
}
