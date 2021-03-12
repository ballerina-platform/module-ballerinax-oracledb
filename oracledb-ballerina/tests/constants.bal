import ballerina/file;
import ballerina/sql;

// const string user="admin";
// const string password="password";
// const string host = "localhost";
// const int port = 1521;
// const string database = "ORCLCDB.localdomain";
const string user="admin";
const string password="password";
const string host = "localhost";
const int port = 1521;
const string database = "ORCLCDB.localdomain";

string resourcePath = check file:getAbsolutePath("tests/resources");

final Options options = {
    loginTimeoutInSeconds: 1,
    autoCommit: true,
    connectTimeoutInSeconds: 1,
    socketTimeoutInSeconds: 3
};

final sql:ConnectionPool connectionPool = {
   maxOpenConnections: 5,
   maxConnectionLifeTime: 2000.0,
   minIdleConnections: 5
};
