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

import ballerina/lang.'string as strings;
import ballerina/test;
import ballerina/sql;

string errorDB = "ERROR_DB";

@test:Config {
    groups: ["error"]
}
function TestAuthenticationError() {
    Client|error dbClient = new (HOST, USER, "PASSWORD", DATABASE, PORT);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "invalid username/password"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestLinkFailure() {
    Client|error dbClient = new ("HOST", USER, PASSWORD, DATABASE, PORT);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), " IO Error: The Network Adapter could not establish " +
                "the connection "), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidDB() {
    Client|error dbClient = new (HOST, USER, PASSWORD, "errorD", PORT);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "TNS:listener does not currently know of service requested " +
                "in connect descriptor"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestConnectionClose() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    check dbClient.close();
    string|error stringVal = dbClient->queryRow(sqlQuery);
    test:assertTrue(stringVal is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>stringVal;
    test:assertEquals(sqlerror.message(), "SQL Client is already closed, hence further operations are not allowed",
                sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidTableName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from Data WHERE row_id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    error sqlerror = <error>stringVal;
    test:assertTrue(strings:includes(sqlerror.message(), "table or view does not exist"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidFieldName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>stringVal;
    test:assertTrue(strings:includes(sqlerror.message(), "\"ID\": invalid identifier"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidColumnType() returns error? {
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult|error result = dbClient->execute(
                                                    `CREATE TABLE TestCreateTable(studentID Point,LastName string)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlerror.message(), "invalid datatype"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestNullValue() returns error? {
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    _ = check dbClient->execute(`CREATE TABLE TestCreateTable(studentID NUMBER not null, LastName VARCHAR(50))`);
    sql:ParameterizedQuery insertQuery = `Insert into TestCreateTable (studentID, LastName) values (null,'asha')`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "cannot insert NULL " +
            "into (\"ADMIN\".\"TESTCREATETABLE\".\"STUDENTID\")"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestNoDataRead() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = 5`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    record {}|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:NoRowsError);
    sql:NoRowsError sqlerror = <sql:NoRowsError>queryResult;
    test:assertEquals(sqlerror.message(), "Query did not retrieve any rows.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestUnsupportedTypeValue() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    json|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlerror = <sql:ConversionError>stringVal;
    test:assertEquals(sqlerror.message(), "Retrieved column 1 result 'Hello' could not be converted to 'JSON', " +
                "unrecognized token 'Hello' at line: 1 column: 7.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestConversionError() returns error? {
    sql:DateValue value = new ("hi");
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = ${value}`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError>stringVal;
    test:assertEquals(sqlError.message(), "Unsupported value: hi for Date Value", sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestConversionError1() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    json|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError>queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "Retrieved column 1 result 'Hello' could not be " +
            "converted to 'JSON', unrecognized token 'Hello'"), sqlError.message());
}

type data record {|
    int row_id;
    int string_type;
|};

@test:Config {
    groups: ["error"]
}
function TestTypeMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    data|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:TypeMismatchError);
    sql:TypeMismatchError sqlError = <sql:TypeMismatchError>queryResult;
    test:assertEquals(sqlError.message(), "The field 'string_type' of type int cannot be mapped to " +
                "the column 'STRING_TYPE' of SQL type 'VARCHAR2'", sqlError.message());
}

type stringValue record {|
    int row_id1;
    string string_type1;
|};

@test:Config {
    groups: ["error"]
}
function TestFieldMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from ErrorTable WHERE row_id = 1`;
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stringValue|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:FieldMismatchError);
    sql:FieldMismatchError sqlError = <sql:FieldMismatchError>queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "No mapping field found for SQL table column " +
                "'STRING_TYPE' in the record type 'stringValue'"), sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestIntegrityConstraintViolation() returns error? {
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    _ = check dbClient->execute(`CREATE TABLE employees( employee_id NUMBER not null,
                                                        employee_name varchar (75) not null,supervisor_name varchar(75),
                                                        CONSTRAINT employee_pk PRIMARY KEY (employee_id))`);
    _ = check dbClient->execute(`CREATE TABLE departments( department_id NUMBER not null,employee_id int not
                                  null,CONSTRAINT fk_employee FOREIGN KEY (employee_id)
                                  REFERENCES employees (employee_id))`);
    sql:ExecutionResult|error result = dbClient->execute(
                                    `INSERT INTO departments(department_id, employee_id) VALUES (250, 600)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlerror.message(), "parent key not found"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function testCreateProceduresWithMissingParams() returns error? {
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ParameterizedQuery query = `CREATE OR replace PROCEDURE InsertData (
                                            pId IN NUMBER,
                                            pData IN NUMBER
                                        AS
                                        BEGIN
                                            INSERT INTO call_procedure (id, data) VALUES (pId, pData);
                                        END;
                                        /`;
    _ = check dbClient->execute(`CREATE TABLE call_procedure(id INT , data INT)`);
    _ = check dbClient->execute(query);
    sql:ProcedureCallResult|error result = dbClient->call(`{call InsertData(1)}`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlError.message(), "ADMIN.INSERTDATA is invalid"), sqlError.message());
}

@test:Config {
    groups: ["error"],
    dependsOn: [testCreateProceduresWithMissingParams]
}
function testCreateProceduresWithParameterTypeMismatch() returns error? {
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ProcedureCallResult|error result = dbClient->call(`{call InsertData(1, 2)}`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlError.message(), "ADMIN.INSERTDATA is invalid"), sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestDuplicateKey() returns error? {
    Client dbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    _ = check dbClient->execute(`CREATE TABLE Details(id NUMBER, age INT, PRIMARY KEY (id))`);
    sql:ParameterizedQuery insertQuery = `Insert into Details (id, age) values (1,10)`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "violated"),
                sqlerror.message());
}
