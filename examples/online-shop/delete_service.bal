import ballerina/sql;

service /onlineshop/delete on onlineShopListener {
    resource function delete customers/[string id]() returns string|error? {
        sql:ParameterizedQuery query = `DELETE FROM CUSTOMERS WHERE CUSTOMER_ID = ${id}`;
        sql:ExecutionResult result = check dbUpdateClient->execute(query);
        return result.affectedRowCount.toString();
    }
}