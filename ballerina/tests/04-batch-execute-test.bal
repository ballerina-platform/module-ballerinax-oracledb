// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/test;

@test:Config {
    groups: ["batch-execute"]
}
isolated function batchExecuteWithEmptyArray() returns error? {
    sql:ParameterizedQuery[] sqlQueries = [];
    sql:ExecutionResult[]|sql:Error result = batchExecuteQuery(sqlQueries);
    test:assertTrue(result is sql:Error);
    if result is sql:ApplicationError {
        test:assertTrue(result.message().includes("Parameter 'sqlQueries' cannot be an empty array"));
      } else {
        test:assertFail("ApplicationError Error expected");
    }
}

@test:Config {
    groups: ["batch-execute"]
}
isolated function batchInsertIntoDataTable() returns error? {
    var data = [
        {col_number:3, col_float:922.337, col_binary_float:123.34, col_binary_double:123.34},
        {col_number:4, col_float:922.337, col_binary_float:123.34, col_binary_double:123.34},
        {col_number:5, col_float:922.337, col_binary_float:123.34, col_binary_double:123.34}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO DataTable (col_number, col_float, col_binary_float, col_binary_double)
        VALUES (${row.col_number}, ${row.col_float}, ${row.col_binary_float}, ${row.col_binary_double})`;

    check validateBatchExecutionResult(check batchExecuteQuery(sqlQueries), [1, 1, 1], [3,4,5]);
}

@test:Config {
    groups: ["batch-execute"],
    dependsOn: [batchInsertIntoDataTable]
}
isolated function batchInsertIntoDataTable2() returns error? {
    int col_number = 6;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO DataTable (col_number) VALUES(${col_number})`;
    sql:ParameterizedQuery[] sqlQueries = [sqlQuery];
    check validateBatchExecutionResult(check batchExecuteQuery(sqlQueries), [1], [6]);
}

@test:Config {
    groups: ["batch-execute"],
    dependsOn: [batchInsertIntoDataTable2]
}
isolated function batchInsertIntoDataTableFailure() {
    var data = [
        {col_number:7, col_float:922.337, col_binary_float:123.34, col_binary_double:123.34},
        {col_number:8, col_float:922.337, col_binary_float:123.34, col_binary_double:123.34},
        {col_number:1, col_float:922.337, col_binary_float:123.34, col_binary_double:123.34}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO DataTable (col_number, col_float, col_binary_float, col_binary_double) 
        VALUES (${row.col_number}, ${row.col_float}, ${row.col_binary_float}, ${row.col_binary_double})`;
    sql:ExecutionResult[]|error result = trap batchExecuteQuery(sqlQueries);
    test:assertTrue(result is error);

    if result is sql:BatchExecuteError {
        sql:BatchExecuteErrorDetail errorDetails = result.detail();

        test:assertEquals(errorDetails.executionResults.length(), 2);
        test:assertEquals(errorDetails.executionResults[0].affectedRowCount, 1);
        test:assertEquals(errorDetails.executionResults[1].affectedRowCount, 1);
    } else {
        test:assertFail("Database Error expected.");
    }
}

isolated function validateBatchExecutionResult(sql:ExecutionResult[] results, int[] rowCount, int[] lastId)
returns error? {
    test:assertEquals(results.length(), rowCount.length());

    int i =0;
    while i < results.length() {
        test:assertEquals(results[i].affectedRowCount, rowCount[i]);
        string|int? lastInsertIdVal = results[i].lastInsertId;
        if lastId[i] == -1 {
            test:assertNotEquals(lastInsertIdVal, ());
        } else {
            test:assertTrue(lastInsertIdVal is string , "Last Insert Id should be string.");
        }
        i = i + 1;
    }
}

isolated function batchExecuteQuery(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult[] result = check oracledbClient->batchExecute(sqlQueries);
    check oracledbClient.close();
    return result;
}
