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

final Options options = {
    loginTimeoutInSeconds: 1,
    autoCommit: true,
    connectTimeoutInSeconds: 1,
    socketTimeoutInSeconds: 3
};

final sql:ConnectionPool connectionPool = {
   maxOpenConnections: 5,
   maxConnectionLifeTimeInSeconds: 2000.0,
   minIdleConnections: 5
};
