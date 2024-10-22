import ballerina/http;
import ballerina/time;

type User record {|
    readonly int id;
    string name;
    time:Date dateOfBirth;
    string mobileNumber;
|};

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;

};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type NewUser record {
    string name;
    time:Date dateOfBirth;
    string mobileNumber;
};

table<User> key(id) users = table [
    {id: 1, name: "Ruju", dateOfBirth: {year: 2001, month: 1, day: 5}, mobileNumber: "0775785129"}
];

service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[]|error? {
        // User ruju = {id: 1,name: "Ruju",dateOfBirth: {year: 2001, month: 1, day: 5}, mobileNumber: "0775785129"};

        // return [ruju];
        return users.toArray();
    }

    resource function get users/[int id]() returns User|UserNotFound|error {
        User? user = users[id];

        if user is () { // user not found
            UserNotFound userNotFound = {
                body: {message: string `user with id ${id} not found`, details: string `users/${id}`, timeStamp: time:utcNow()}
            };
            return userNotFound;
        }
        return user;
    }

    resource function post users(NewUser newUser) returns http:Created|error {
        users.add({id: users.length() + 1, name: newUser.name, mobileNumber: newUser.mobileNumber, dateOfBirth: newUser.dateOfBirth});

        return http:CREATED;
    }
}
