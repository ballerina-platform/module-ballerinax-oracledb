// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/test;
// import ballerina/io;

@test:Config{
    enable: true,
    groups:["execute","execute-basic"]
}
function testCreateTable() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("CREATE TABLE TestExecuteTable(field NUMBER, field2 VARCHAR2(255))");
    checkpanic oracledbClient.close();

    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
}

@test:Config{
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn: ["testCreateTable"]
}
function testAlterTable() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("ALTER TABLE TestExecuteTable RENAME COLUMN field TO field1");
    checkpanic oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

@test:Config{
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn: ["testAlterTable"]
}
function testInsertTable() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("INSERT INTO TestExecuteTable(field1, field2) VALUES (1, 'Hello, world')");
    checkpanic oracledbClient.close();

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;

    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config{
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn: ["testInsertTable"]
}
function testUpdateTable() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("UPDATE TestExecuteTable SET field2 = 'Hello, ballerina' WHERE field1 = 1");
    checkpanic oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

@test:Config{
    enable: true,
    groups:["execute","execute-basic"],
    after: "testInsertTable"
}
function testDropTable() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("DROP TABLE TestExecuteTable");
    checkpanic oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

