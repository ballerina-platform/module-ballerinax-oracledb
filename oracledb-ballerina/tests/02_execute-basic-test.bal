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
    enable: true,
    groups:["execute","execute-basic"]
}
function testCreateTable() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);

    sql:ExecutionResult result = check dropTableIfExists("TestExecuteTable");
    result = check oracledbClient->execute("CREATE TABLE TestExecuteTable(field NUMBER, field2 VARCHAR2(255))");
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");

    result = check dropTableIfExists("TestCharacterTable");
    result = check oracledbClient->execute("CREATE TABLE TestCharacterTable("+
        "id NUMBER, "+
        "col_char CHAR(4), "+
        "col_nchar NCHAR(4), "+
        "col_varchar2  VARCHAR2(4000), " +
        "col_varchar  VARCHAR2(4000), " +
        "col_nvarchar2 NVARCHAR2(2000), "+
        "PRIMARY KEY(id) "+
        ")"
    );
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");

    result = check dropTableIfExists("TestNumericTable");
    result = check oracledbClient->execute("CREATE TABLE TestNumericTable("+
        "id NUMBER GENERATED ALWAYS AS IDENTITY, "+
        "col_number  NUMBER, " +
        "col_float  FLOAT, " +
        "col_binary_float BINARY_FLOAT, "+
        "col_binary_double BINARY_DOUBLE, "+
        "PRIMARY KEY(id) "+
        ")"
    );
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn: [testCreateTable]
}
isolated function testAlterTable() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("ALTER TABLE TestExecuteTable RENAME COLUMN field TO field1");
    check oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

@test:Config {
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn: [testAlterTable]
}
isolated function testInsertTable() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("INSERT INTO TestExecuteTable(field1, field2) VALUES (1, 'Hello, world')");
    check oracledbClient.close();

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;

    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn: [testInsertTable]
}
isolated function testUpdateTable() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("UPDATE TestExecuteTable SET field2 = 'Hello, ballerina' WHERE field1 = 1");
    check oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTable]
}
isolated function testInsertTableWithoutGeneratedKeys() returns sql:Error? {
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("Insert into TestCharacterTable (id, col_varchar2)"
        + " values (20, 'test')");
    check oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithoutGeneratedKeys]
}
isolated function testInsertTableWithGeneratedKeys() returns sql:Error? {
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("insert into TestNumericTable (col_number) values (21)");
    check oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
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
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("insert into TestNumericTable (col_number) values (31)");

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertedId = result.lastInsertId;
    if (insertedId is string|int) {
        string query = "SELECT * from TestNumericTable where col_number = 31";
        stream<record{} , error> queryResult = oracledbClient->query(query, NumericRecord);

        stream<NumericRecord, sql:Error> streamData = <stream<NumericRecord, sql:Error>>queryResult;
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
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("insert into TestNumericTable (col_number, col_float, "+
        "col_binary_float, col_binary_double) values (null, null, null, null)");

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertedId = result.lastInsertId;
    if (insertedId is string|int) {
        string query = "SELECT * from TestNumericTable where id =2 ";
        stream<record{} , error> queryResult = oracledbClient->query(query, NumericRecord);

        stream<NumericRecord, sql:Error> streamData = <stream<NumericRecord, sql:Error>>queryResult;
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
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult|sql:Error result = oracledbClient->execute("Insert into NumericTypesNonExistTable (int_type) values (20)");

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 942, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "42000", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    check oracledbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithDatabaseError]
}
isolated function testInsertTableWithDataTypeError() returns sql:Error? {
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult|sql:Error result = oracledbClient->execute("Insert into TestNumericTable (col_number) values"
        + " ('This is wrong type')");

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1722, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "42000", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    check oracledbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithDataTypeError]
}
isolated function testUpdateData() returns sql:Error? {
    Client oracledbClient = check new (user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("Update TestNumericTable set col_number = 11 where col_number = 31");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","execute-basic"],
    dependsOn:[testUpdateData]
}
isolated function testDropTable() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute("DROP TABLE TestNumericTable");
    check oracledbClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
}

