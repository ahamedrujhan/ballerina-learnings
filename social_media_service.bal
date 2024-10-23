import ballerina/http;
import ballerina/sql;
import ballerina/time;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

type User record {|
    readonly int id;
    string name;
    @sql:Column {
        name: "birth_date"
    }
    time:Date dateOfBirth;
    @sql:Column {
        name: "mobile_number"
    }
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

type DatabseConfig record {|
    string host;
    string username;
    string password;
    string database;
    int port;
|};

type PostWithMeta record {|
    readonly int id;
    string description;
    record {|
        string[] tags;
        string category;
        @sql:Column {name: "created_date"}
        time:Date created_date;
    |} meta;
|};

type Post record {|
    int id;
    string description;
    string tags;
    string category;
    @sql:Column {name: "created_date"}
    time:Date created_date;
|};

table<User> key(id) users = table [
    {id: 1, name: "Ruju", dateOfBirth: {year: 2001, month: 1, day: 5}, mobileNumber: "0775785129"}
];

//Postgres clinet

configurable DatabseConfig databseConfig = ?; //we can provide fallback values if we want
postgresql:Client socialMediaDb = check new (...databseConfig);

service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[]|error? {
        // User ruju = {id: 1,name: "Ruju",dateOfBirth: {year: 2001, month: 1, day: 5}, mobileNumber: "0775785129"};

        // return [ruju];
        // return users.toArray();

        stream<User, sql:Error?> userSteam = socialMediaDb->query(`select * from users`);
        // io:println(userSteam);
        return from var user in userSteam
            select user;
    }

    resource function get users/[int id]() returns User|UserNotFound|error {
        // User? user = users[id];

        // if user is () { // user not found
        //     UserNotFound userNotFound = {
        //         body: {message: string `user with id ${id} not found`, details: string `users/${id}`, timeStamp: time:utcNow()}
        //     };
        //     return userNotFound;
        // }
        // return user;

        User|sql:Error user = socialMediaDb->queryRow(`select * from users where id = ${id}`);

        if user is sql:NoRowsError {
            UserNotFound userNotFound = {
                body: {message: string `user with id ${id} not found`, details: string `user/${id}`, timeStamp: time:utcNow()}
            };
            return userNotFound;
        }
        return user;
    }

    resource function post users(NewUser newUser) returns http:Created|error {
        // users.add({id: users.length() + 1, name: newUser.name, mobileNumber: newUser.mobileNumber, dateOfBirth: newUser.dateOfBirth});

        // return http:CREATED;

        //tranaction block
        transaction {
            _ = check socialMediaDb->execute(`
        insert into users (birth_date,name,mobile_number)
         values (${newUser.dateOfBirth}, ${newUser.name},${newUser.mobileNumber});`);

            //   _=  check socialMediaDb->execute(`
            // insert into users (birth_date,name,mobile_number)
            //  values (${newUser.dateOfBirth}, ${newUser.name},${newUser.mobileNumber});`);

            check commit;
        }

        //   ReturnType returnType = {
        //     code: http:CREATED,
        //     value: value,
        //   }

        return http:CREATED;
    }

    resource function get users/[int id]/posts() returns Post[]|UserNotFound|error {

        User|error result = socialMediaDb->queryRow(`select * from users where id = ${id}`);

        if result is sql:NoRowsError {

            ErrorDetails errorDetails = {message: string `user with id ${id} not found`, details: string `users/${id}/posts` ,
            timeStamp: time:utcNow()};

            UserNotFound userNotFound = {
                body: errorDetails
            };
            return userNotFound;
        }

        stream<Post, sql:Error?> postStream = socialMediaDb->query(`SELECT id, description, category, created_date, tags FROM posts WHERE user_id = ${id}`);

        return from var post in postStream 
        select post;
    }
}
