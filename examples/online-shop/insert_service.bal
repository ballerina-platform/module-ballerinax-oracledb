import ballerinax/oracledb;
import ballerina/http;
import ballerina/sql;

final oracledb:Client dbUpdateClient = check new(host = HOST, user = USER, password = PASSWORD, port = PORT,
    database = DATABASE, connectionPool = {maxOpenConnections: 3, minIdleConnections: 1});

service /onlineshop/insert on onlineShopListener {
    resource function post customers(@http:Payload CustomerInput customer) returns string|error? {
        sql:ParameterizedQuery query = `INSERT INTO CUSTOMERS (NAME,ADDRESS,CREDIT_LIMIT,WEBSITE) VALUES
        (${customer.name}, ${customer.address}, ${customer.credit_limit}, ${customer.website})`;
        sql:ExecutionResult result = check dbUpdateClient->execute(query);
        return result.lastInsertId.toString();
    }
}