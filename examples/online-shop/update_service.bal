import ballerina/http;
import ballerina/sql;

service /onlineshop/update on onlineShopListener {
    resource function post customers(@http:Payload Customer customer) returns string|error? {
        sql:ParameterizedQuery query = `UPDATE CUSTOMERS SET NAME = ${customer.name}, ADDRESS = ${customer.address},
        CREDIT_LIMIT = ${customer.credit_limit},WEBSITE = ${customer.website} where CUSTOMER_ID = ${customer.customer_id}`;
        sql:ExecutionResult result = check dbUpdateClient->execute(query);
        return result.lastInsertId.toString();
    }
}
