// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

@test:Config {
    groups:["execute", "execute-basic"]
}
isolated function testCreateTable() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check dropTableIfExists("TestExecuteTable", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE TestExecuteTable(field NUMBER, field2 VARCHAR2(255))`);
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    result = check dropTableIfExists("TestCharacterTable", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE TestCharacterTable(
        id NUMBER,
        col_char CHAR(4),
        col_nchar NCHAR(4),
        col_varchar2  VARCHAR2(4000),
        col_varchar  VARCHAR2(4000),
        col_nvarchar2 NVARCHAR2(2000),
        PRIMARY KEY(id)
        )`
    );
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    result = check dropTableIfExists("TestNumericTable", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE TestNumericTable(
        id NUMBER GENERATED ALWAYS AS IDENTITY,
        col_number  NUMBER,
        col_float  FLOAT,
        col_binary_float BINARY_FLOAT,
        col_binary_double BINARY_DOUBLE,
        PRIMARY KEY(id)
        )`
    );
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    check oracledbClient.close();
}

@test:Config {
    groups:["execute", "execute-basic"],
    dependsOn: [testCreateTable]
}
isolated function testAlterTable() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(
        `ALTER TABLE TestExecuteTable RENAME COLUMN field TO field1`);
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

@test:Config {
    groups:["execute", "execute-basic"],
    dependsOn: [testAlterTable]
}
isolated function testInsertTable() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(
        `INSERT INTO TestExecuteTable(field1, field2) VALUES (1, 'Hello, world')`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    int|string? insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups:["execute", "execute-basic"],
    dependsOn: [testInsertTable]
}
isolated function testUpdateTable() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(
        `UPDATE TestExecuteTable SET field2 = 'Hello, ballerina' WHERE field1 = 1`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTable]
}
isolated function testInsertTableWithoutGeneratedKeys() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(`Insert into TestCharacterTable (id, col_varchar2)
         values (20, 'test')`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    int|string? insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithoutGeneratedKeys]
}
isolated function testInsertTableWithGeneratedKeys() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(`insert into TestNumericTable (col_number) values (21)`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    int|string? insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string.");
}

type NumericRecord record {|
    int id;
    decimal col_number;
    decimal col_float;
    decimal col_binary_float;
    decimal col_binary_double;
|};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithGeneratedKeys]
}
isolated function testInsertAndSelectTableWithGeneratedKeys() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check oracledbClient->execute(`insert into TestNumericTable (col_number) values (31)`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    string|int? insertedId = result.lastInsertId;
    if (insertedId is string|int) {
        sql:ParameterizedQuery query = `SELECT * from TestNumericTable where col_number = 31`;
        stream<NumericRecord , sql:Error?> streamData = oracledbClient->query(query);
        record {|NumericRecord value;|}? data = check streamData.next();
        check streamData.close();
        test:assertNotExactEquals(data?.value, (), "Incorrect InsertId returned.");
    } else {
        test:assertFail("Last Insert id should be string.");
    }
    check oracledbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertAndSelectTableWithGeneratedKeys]
}
isolated function testInsertWithAllNilAndSelectTableWithGeneratedKeys() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check oracledbClient->execute(`insert into TestNumericTable (col_number, col_float,
        col_binary_float, col_binary_double) values (null, null, null, null)`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    string|int? insertedId = result.lastInsertId;
    if (insertedId is string|int) {
        sql:ParameterizedQuery query = `SELECT * from TestNumericTable where id = 2`;
        stream<NumericRecord , sql:Error?> streamData = oracledbClient->query(query);
        record {|NumericRecord value;|}? data = check streamData.next();
        check streamData.close();
        test:assertNotExactEquals(data?.value, (), "Incorrect InsertId returned.");
    } else {
        test:assertFail("Last Insert id should be string");
    }
    check oracledbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
}
isolated function testInsertTableWithDatabaseError() returns sql:Error? {
    sql:ExecutionResult|sql:Error result = executeQuery(
        `Insert into NumericTypesNonExistTable (int_type) values (20)`);
    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 942, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "42000", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithDatabaseError]
}
isolated function testInsertTableWithDataTypeError() returns sql:Error? {
    sql:ExecutionResult|sql:Error result = executeQuery(`Insert into TestNumericTable (col_number) values
         ('This is wrong type')`);
    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1722, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "42000", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithDataTypeError]
}
isolated function testUpdateData() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(
        `Update TestNumericTable set col_number = 11 where col_number = 31`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
}

@test:Config {
    groups:["execute", "execute-basic"],
    dependsOn:[testUpdateData]
}
isolated function testDropTable() returns sql:Error? {
    sql:ExecutionResult result = check executeQuery(`DROP TABLE TestNumericTable`);
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}
