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
import ballerina/io;

@test:BeforeGroups { value:["execute-params"] }
function beforeExecuteWithParamsFunc() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check dropTableIfExists("NumericTypesTable");
    result = check oracledbClient->execute("CREATE TABLE NumericTypesTable("+
        "id NUMBER, "+
        "col_number NUMBER, " +
        "col_float FLOAT, " +
        "col_binary_float BINARY_FLOAT, " +
        "col_binary_double BINARY_DOUBLE, " +
        "PRIMARY KEY (id) " +
        ")"
    );
    result = check oracledbClient->execute("INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double)"+
        "VALUES(1, 1, 922.337, 123.34, 123.34)");

    result = check oracledbClient->execute("INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double)"+
        "VALUES(2, 2, 922.337, 123.34, 123.34)");

    result = check oracledbClient->execute("CREATE TABLE CharTypesTable(" +
        "id NUMBER, "+
        "col_varchar2  VARCHAR2(4000), " +
        "col_varchar  VARCHAR2(4000), " +
        "col_nvarchar2 NVARCHAR2(2000), "+
        "col_char CHAR(2000), "+
        "col_nchar NCHAR(1000), "+
        "PRIMARY KEY(id) "+
        ")"
        );

    result = check oracledbClient->execute("CREATE TABLE AnsiTypesTable(" +
        "id NUMBER, "+
        "col_character  CHARACTER(256), " +
        "col_character_var  CHARACTER VARYING(256), " +

        "col_national_character NATIONAL CHARACTER(256), " +
        "col_national_char NATIONAL CHAR(256), " +

        "col_national_character_var NATIONAL CHARACTER VARYING(256), " +
        "col_national_char_var NATIONAL CHAR VARYING(256), " +
        "col_nchar_var NCHAR VARYING(256), " +

        "col_numeric NUMERIC, " +
        "col_decimal DECIMAL, " +

        "col_integer INTEGER, " +
        "col_int INT, " +
        "col_smallint SMALLINT, " +

        "col_float FLOAT, " +
        "col_double_precision DOUBLE PRECISION, " +
        "col_real REAL, " +
        
        "PRIMARY KEY(id) "+
        ")"
    );

    result = check oracledbClient->execute("CREATE TABLE SqlDsTypesTable(" +
        "id NUMBER, "+
        "col_character  CHARACTER(255), " +
        "col_long_varchar  LONG VARCHAR, " +
        "PRIMARY KEY(id) "+
        ")"
    );

    result = check oracledbClient->execute("CREATE TABLE LobTypesTable(" +
        "id NUMBER, "+
        "col_clob  CLOB, " +
        "col_nclob  NCLOB, " +
        "col_blob BLOB, " +
        "PRIMARY KEY(id) "+
        ")"
    );

    check oracledbClient.close();
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoNumericTable1() returns sql:Error? {
    int id = 3;
    int col_number = 3;
    float col_float =  922.337;
    decimal col_binary_float = 123.34;
    decimal col_binary_double = 123.34;

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double) 
        VALUES (${id}, ${col_number}, ${col_float}, ${col_binary_float}, ${col_binary_double})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable1]
}
function insertIntoNumericTable2() returns sql:Error? {
    int id = 4;
    int col_number = 4;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO NumericTypesTable (id) VALUES(${id})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}


@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable2]
}
function insertIntoNumericTable3() returns sql:Error? {
    int id = 5;
    int col_number = 5;
    float col_float =  -922.337;
    decimal col_binary_float = -123.34;
    decimal col_binary_double = 0.34;

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double) 
        VALUES (${id}, ${col_number}, ${col_float}, ${col_binary_float}, ${col_binary_double})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable3]
}
function insertIntoNumericTable4() returns sql:Error? {
    int id = 6;
    sql:IntegerValue col_number = new (6);
    sql:FloatValue col_float = new (124.34);
    sql:DoubleValue col_binary_float = new (29095039);
    sql:DoubleValue col_binary_double = new (29095039);

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double) 
        VALUES (${id}, ${col_number}, ${col_float}, ${col_binary_float}, ${col_binary_double})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable4]
}
function deleteNumericTable1() returns sql:Error? {
    int id = 1;
    int col_number = 1;
    float col_float =  922.337;
    decimal col_binary_float = 123.34;
    decimal col_binary_double = 123.34;

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM NumericTypesTable where id=${id} AND col_number=${col_number} 
                AND col_float=${col_float} AND col_binary_float=${col_binary_float}
                AND col_binary_float=${col_binary_float} AND col_binary_double=${col_binary_double}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteNumericTable1]
}
function deleteNumericTable2() returns sql:Error? {
    int id = 2;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM NumericTypesTable where id = ${id}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteNumericTable2]
}
function deleteNumericTable3() returns sql:Error? {
    int id = 3;
    sql:IntegerValue col_number = new (3);
    sql:FloatValue col_float = new (922.337);
    sql:DoubleValue col_binary_float = new (123.34);
    sql:DoubleValue col_binary_double = new (123.34);

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM NumericTypesTable where id=${id} AND col_number=${col_number} AND col_float=${col_float} AND col_binary_float=${col_binary_float}
              AND col_binary_float=${col_binary_float} AND col_binary_double=${col_binary_double}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteNumericTable3]
}
function insertIntoCharacterTable1() returns error? {
    int id = 1;
    string col_varchar2 = "very long text";
    string col_varchar = "very long text";
    string col_nvarchar2 = "very long text";
    string col_char = "very long text";
    string col_nchar = "very long text";

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO CharTypesTable (id, col_varchar2, col_varchar, col_nvarchar2, col_char, col_nchar) VALUES (
        ${id}, ${col_varchar2}, ${col_varchar}, ${col_nvarchar2}, ${col_char}, ${col_nchar})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoCharacterTable1]
}
function insertIntoCharacterTable2() returns error? {
    int id = 2;
    string? col_varchar2 = ();
    string? col_varchar = ();
    string? col_nvarchar2 = ();
    string? col_char = ();
    string? col_nchar = ();

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO CharTypesTable (id, col_varchar2, col_varchar, col_nvarchar2, col_char, col_nchar) VALUES (
        ${id}, ${col_varchar2}, ${col_varchar}, ${col_nvarchar2}, ${col_char}, ${col_nchar})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoCharacterTable2]
}
function insertIntoCharacterTable3() returns error? {
    int id = 3;
    sql:VarcharValue col_varchar2 = new();
    sql:VarcharValue col_varchar = new();
    sql:NVarcharValue col_nvarchar2 = new();
    sql:CharValue col_char = new();
    sql:NCharValue col_nchar = new();

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO CharTypesTable (id, col_varchar2, col_varchar, col_nvarchar2, col_char, col_nchar) VALUES (
        ${id}, ${col_varchar2}, ${col_varchar}, ${col_nvarchar2}, ${col_char}, ${col_nchar})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoCharacterTable3]
}
function insertIntoCharacterTable4() returns error? {
    int id = 4;
    sql:VarcharValue col_varchar2 = new("very long text");
    sql:VarcharValue col_varchar = new("very long text");
    sql:NVarcharValue col_nvarchar2 = new("very long text");
    sql:CharValue col_char = new("very long text");
    sql:NCharValue col_nchar = new("very long text");

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO CharTypesTable (id, col_varchar2, col_varchar, col_nvarchar2, col_char, col_nchar) VALUES (
        ${id}, ${col_varchar2}, ${col_varchar}, ${col_nvarchar2}, ${col_char}, ${col_nchar})`;
    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoCharacterTable4]
}
function deleteCharacterTable() returns sql:Error? {
    int id = 2;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM CharTypesTable where id = ${id}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteCharacterTable]
}
function insertIntoAnsiTable1() returns error? {
    int id = 1;
    string col_character = "Hello, world!";
    string col_character_var = "Hello, world!";
    string col_national_character = "Hello, world!";
    string col_national_char = "Hello, world!";
    string col_national_character_var = "Hello, world!";
    string col_national_char_var = "Hello, world!";
    string col_nchar_var = "Hello, world!";

    decimal col_numeric = 1234.134;
    decimal col_decimal = 123.4134;
    int col_integer = 1234134;
    int col_int = 1234134;
    int col_smallint = 1234134;
    float col_float = 1234.134;
    decimal col_double_precision = 1.234134;
    decimal col_real = 1.234134;

    sql:ParameterizedQuery sqlQuery = 
        `INSERT INTO AnsiTypesTable(id, col_character, col_character_var, col_national_character, col_national_char, col_national_character_var, 
        col_national_char_var, col_nchar_var, col_numeric, col_decimal, col_integer, col_int, col_smallint, col_float, col_double_precision, 
        col_real) VALUES (${id}, ${col_character}, ${col_character_var}, ${col_national_character}, ${col_national_char}, ${col_national_character_var}, 
        ${col_national_char_var}, ${col_nchar_var}, ${col_numeric}, ${col_decimal}, ${col_integer}, ${col_int}, ${col_smallint}, ${col_float}, 
        ${col_double_precision}, ${col_real})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoAnsiTable1]
}
function insertIntoAnsiTable2() returns error? {
    int id = 2;
    string? col_character = ();
    string? col_character_var = ();
    string? col_national_character = ();
    string? col_national_char = ();
    string? col_national_character_var = ();
    string? col_national_char_var = ();
    string? col_nchar_var = ();

    decimal? col_numeric = ();
    decimal? col_decimal = ();
    int? col_integer = ();
    int? col_int = ();
    int? col_smallint = ();
    float? col_float = ();
    decimal? col_double_precision = ();
    decimal? col_real = ();

    sql:ParameterizedQuery sqlQuery = 
        `INSERT INTO AnsiTypesTable(id, col_character, col_character_var, col_national_character, col_national_char, col_national_character_var, 
        col_national_char_var, col_nchar_var, col_numeric, col_decimal, col_integer, col_int, col_smallint, col_float, col_double_precision, 
        col_real) VALUES (${id}, ${col_character}, ${col_character_var}, ${col_national_character}, ${col_national_char}, ${col_national_character_var}, 
        ${col_national_char_var}, ${col_nchar_var}, ${col_numeric}, ${col_decimal}, ${col_integer}, ${col_int}, ${col_smallint}, ${col_float}, 
        ${col_double_precision}, ${col_real})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoAnsiTable2]
}
function insertIntoAnsiTable3() returns error? {
    int id = 3;
    sql:CharValue col_character = new("Hello, world!");
    sql:VarcharValue col_character_var = new("Hello, world!");
    sql:NCharValue col_national_character = new("Hello, world!");
    sql:NCharValue col_national_char =new("Hello, world!");
    sql:NVarcharValue col_national_character_var = new("Hello, world!");
    sql:NVarcharValue col_national_char_var = new("Hello, world!");
    sql:NCharValue col_nchar_var = new("Hello, world!");

    sql:NumericValue col_numeric = new(1234.134);
    sql:DecimalValue col_decimal = new(123.4134);
    sql:IntegerValue col_integer = new(1234134);
    sql:IntegerValue col_int = new(1234134);
    sql:SmallIntValue col_smallint = new(1234134);
    sql:FloatValue col_float = new(1234.134);
    sql:DoubleValue col_double_precision = new(1.234134);
    sql:RealValue col_real = new(1.234134);

    sql:ParameterizedQuery sqlQuery = 
        `INSERT INTO AnsiTypesTable(id, col_character, col_character_var, col_national_character, col_national_char, col_national_character_var, 
        col_national_char_var, col_nchar_var, col_numeric, col_decimal, col_integer, col_int, col_smallint, col_float, col_double_precision, 
        col_real) VALUES (${id}, ${col_character}, ${col_character_var}, ${col_national_character}, ${col_national_char}, ${col_national_character_var}, 
        ${col_national_char_var}, ${col_nchar_var}, ${col_numeric}, ${col_decimal}, ${col_integer}, ${col_int}, ${col_smallint}, ${col_float}, 
        ${col_double_precision}, ${col_real})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoAnsiTable3]
}
function insertIntoAnsiTable4() returns error? {
    int id = 4;
    sql:CharValue col_character = new();
    sql:VarcharValue col_character_var = new();
    sql:NCharValue col_national_character = new();
    sql:NCharValue col_national_char =new();
    sql:NVarcharValue col_national_character_var = new();
    sql:NVarcharValue col_national_char_var = new();
    sql:NCharValue col_nchar_var = new();

    sql:NumericValue col_numeric = new();
    sql:DecimalValue col_decimal = new();
    sql:IntegerValue col_integer = new();
    sql:IntegerValue col_int = new();
    sql:SmallIntValue col_smallint = new();
    sql:FloatValue col_float = new();
    sql:DoubleValue col_double_precision = new();
    sql:RealValue col_real = new();

    sql:ParameterizedQuery sqlQuery = 
        `INSERT INTO AnsiTypesTable(id, col_character, col_character_var, col_national_character, col_national_char, col_national_character_var, 
        col_national_char_var, col_nchar_var, col_numeric, col_decimal, col_integer, col_int, col_smallint, col_float, col_double_precision, 
        col_real) VALUES (${id}, ${col_character}, ${col_character_var}, ${col_national_character}, ${col_national_char}, ${col_national_character_var}, 
        ${col_national_char_var}, ${col_nchar_var}, ${col_numeric}, ${col_decimal}, ${col_integer}, ${col_int}, ${col_smallint}, ${col_float}, 
        ${col_double_precision}, ${col_real})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoAnsiTable4]
}
function deleteAnsiTable() returns sql:Error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM AnsiTypesTable where id = ${id}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteAnsiTable]
}
function insertIntoSqlDsTable1() returns error? {
    int id = 1;
    string col_character = "Hello, world!";
    string col_long_varchar = "Hello, world!";

    sql:ParameterizedQuery sqlQuery = 
             `INSERT INTO SqlDsTypesTable(id, col_character, col_long_varchar) VALUES (${id}, ${col_character}, ${col_long_varchar})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoSqlDsTable1]
}
function insertIntoSqlDsTable2() returns error? {
    int id = 2;
    string? col_character = ();
    string? col_long_varchar = ();

    sql:ParameterizedQuery sqlQuery = 
             `INSERT INTO SqlDsTypesTable(id, col_character, col_long_varchar) VALUES (${id}, ${col_character}, ${col_long_varchar})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoSqlDsTable2]
}
function deleteSqlDsTable() returns sql:Error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM SqlDsTypesTable where id = ${id}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteSqlDsTable]
}
function insertIntoLobTable1() returns error? {
    int id = 1;
    io:ReadableByteChannel blobChannel = check getBlobColumnChannel();
    io:ReadableCharacterChannel clobChannel = check getClobColumnChannel();

    sql:ClobValue col_clob = new (clobChannel);
    sql:ClobValue col_nclob = new (clobChannel);
    sql:BlobValue col_blob = new (blobChannel);

    sql:ParameterizedQuery sqlQuery = 
             `INSERT INTO LobTypesTable(id, col_clob, col_nclob, col_blob) VALUES (${id}, ${col_clob},  ${col_nclob}, ${col_blob})`;

    validateResult(check executeQuery(sqlQuery), 1, 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoLobTable1]
}
function deleteLobTable() returns sql:Error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM LobTypesTable where id = ${id}`;
    validateResult(check executeQuery(sqlQuery), 1);
}

function executeQuery(sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult|sql:Error {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check oracledbClient->execute(sqlQuery);
    check oracledbClient.close();
    return result;
}

isolated function validateResult(sql:ExecutionResult result, int rowCount, int? lastId = ()) {
    test:assertExactEquals(result.affectedRowCount, rowCount, "Affected row count is different.");

    if (lastId is ()) {
        test:assertEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    } else {
        int|string? lastInsertIdVal = result.lastInsertId;
        test:assertTrue(lastInsertIdVal is string , "Last Insert Id should be string.");
    }
}

