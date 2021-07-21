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

@test:BeforeGroups { value:["query-simple-params"] }
isolated function beforeQueryWithSimpleParamsFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    sql:ExecutionResult result = check dropTableIfExists("GeneralQueryTable");
    result = check oracledbClient->execute("CREATE TABLE GeneralQueryTable(" +
        "id NUMBER, " +
        "col_number NUMBER, " +
        "col_varchar2 VARCHAR2(4000), " +
        "PRIMARY KEY (id) " +
        ")"
    );
    result = check oracledbClient->execute(
        "INSERT INTO GeneralQueryTable (id, col_number, col_varchar2) VALUES(1, -23.4, 'Hello world')");

    result = check dropTableIfExists("NumericSimpleQueryTable");
    result = check oracledbClient->execute("CREATE TABLE NumericSimpleQueryTable("+
        "id NUMBER, " +
        "col_number NUMBER, " +
        "col_float FLOAT, " +
        "col_binary_float BINARY_FLOAT, " +
        "col_binary_double BINARY_DOUBLE, " +
        "PRIMARY KEY (id) " +
        ")"
    );
    result = check oracledbClient->execute(
        "INSERT INTO NumericSimpleQueryTable (id, col_number, col_float, col_binary_float, col_binary_double)" +
        "VALUES(1, 1, 922.337, 123.34, 123.34)");

    result = check dropTableIfExists("CharSimpleQueryTable");
    result = check oracledbClient->execute("CREATE TABLE CharSimpleQueryTable(" +
        "id NUMBER, " +
        "col_varchar2  VARCHAR2(4000), " +
        "col_varchar  VARCHAR(4000), " +
        "col_nvarchar2 NVARCHAR2(2000), " +
        "col_char CHAR(2000), " +
        "col_nchar NCHAR(1000), " +
        "PRIMARY KEY(id) " +
        ")"
    );
    result = check oracledbClient->execute(
        "INSERT INTO CharSimpleQueryTable (id, col_varchar2, col_varchar, col_nvarchar2, col_char, col_nchar) " +
        "VALUES(1, 'Hello world', 'Hello world', 'Hello world', 'Hello world', 'Hello world')");
    

    result = check dropTableIfExists("AnsiSimpleQueryTable");
    result = check oracledbClient->execute("CREATE TABLE AnsiSimpleQueryTable(" +
        "id NUMBER, " +
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
        
        "PRIMARY KEY(id) " +
        ")"
    );
    result = check oracledbClient->execute(
        "INSERT INTO AnsiSimpleQueryTable(id, col_character, col_character_var, col_national_character, " +
        "col_national_char, col_national_character_var, col_national_char_var, col_nchar_var, col_numeric, " +
        "col_decimal, col_integer, col_int, col_smallint, col_float, col_double_precision, col_real) VALUES " +
        "(1, 'Hello world', 'Hello world', 'Hello world', 'Hello world', 'Hello world', 'Hello world', " +
        "'Hello world', 1234134, 1234134, 1234134, 1234134, 1234134, 1234.134, 1234.134, 1234.134)");

    result = check dropTableIfExists("SqlDsSimpleQueryTable");
    result = check oracledbClient->execute("CREATE TABLE SqlDsSimpleQueryTable(" +
        "id NUMBER, " +
        "col_character  CHARACTER(255), " +
        "col_long_varchar  LONG VARCHAR, " +
        "PRIMARY KEY(id) " +
        ")"
    );
    result = check oracledbClient->execute("INSERT INTO SqlDsSimpleQueryTable(id, col_character, col_long_varchar)" +
        " VALUES (1, 'Hello world', 'Hello world')");

    result = check dropTableIfExists("LobSimpleQueryTable");
    result = check oracledbClient->execute("CREATE TABLE LobSimpleQueryTable(" +
        "id NUMBER, "+
        "col_clob  CLOB, " +
        "col_nclob  NCLOB, " +
        "col_blob BLOB, " +
        "PRIMARY KEY(id) "+
        ")"
    );
    result = check oracledbClient->execute("INSERT INTO LobSimpleQueryTable(id, col_clob, col_nclob, col_blob) " +
        "VALUES (1, 'Hello world', 'Hello world', 'AB34EFC234')");

    check oracledbClient.close();
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function querySingleNumber() returns error? {
    float col_number = -23.4;
    sql:ParameterizedQuery sqlQuery = `SELECT * from GeneralQueryTable WHERE col_number = ${col_number}`;
    validateGeneralQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function querySingleString() returns error? {
    string col_varchar2 = "Hello world";
    sql:ParameterizedQuery sqlQuery = `SELECT * from GeneralQueryTable WHERE col_varchar2 = ${col_varchar2}`;
    validateGeneralQueryTableResult(check queryClient(sqlQuery));
}

isolated function validateGeneralQueryTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(<int> returnData["ID"], 1);
        test:assertEquals(<float> returnData["COL_NUMBER"], -23.4);
        test:assertEquals(returnData["COL_VARCHAR2"], "Hello world");
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function querySingleNumberParam() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericSimpleQueryTable WHERE id = ${id}`;
    validateNumericSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryDoubleNumberParam() returns error? {
    int id = 1;
    sql:DecimalValue col_number = new(1);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericSimpleQueryTable WHERE id = ${id}`;
    validateNumericSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryFloatParam() returns error? {
    int id = 1;
    sql:FloatValue col_float = new(922.337);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericSimpleQueryTable WHERE id = ${id}
        AND col_float =  ${col_float}`;
    validateNumericSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryBinaryFloatParam() returns error? {
    int id = 1;
    sql:FloatValue col_binary_float = new(123.34);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericSimpleQueryTable WHERE id = ${id}
        AND col_binary_float =  ${col_binary_float}`;
    validateNumericSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryBinaryDoubleParam() returns error? {
    int id = 1;
    sql:FloatValue col_binary_double = new(123.34);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericSimpleQueryTable WHERE id = ${id}
        AND col_binary_double =  ${col_binary_double}`;
    validateNumericSimpleQueryTableResult(check queryClient(sqlQuery));
}

isolated function validateNumericSimpleQueryTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {

        test:assertEquals(<int> returnData["ID"], 1);
        test:assertEquals(returnData["COL_NUMBER"], <decimal> 1);
        test:assertEquals(<float> returnData["COL_FLOAT"], 922.337);
        test:assertEquals(returnData["COL_BINARY_FLOAT"], "123.34");
        test:assertEquals(returnData["COL_BINARY_DOUBLE"], "123.34");
    } 
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryVarchar2Param() returns error? {
    int id = 1;
    sql:VarcharValue col_varchar2 = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from CharSimpleQueryTable WHERE id = ${id}
        AND col_varchar2 =  ${col_varchar2}`;
    validateCharacterSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryVarcharParam() returns error? {
    int id = 1;
    sql:VarcharValue col_varchar = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from CharSimpleQueryTable WHERE id = ${id}
        AND col_varchar =  ${col_varchar}`;
    validateCharacterSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryNVarchar2Param() returns error? {
    int id = 1;
    sql:NVarcharValue col_nvarchar2 = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from CharSimpleQueryTable WHERE id = ${id}
        AND col_nvarchar2 =  ${col_nvarchar2}`;
    validateCharacterSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiCharacterVarParam() returns error? {
    int id = 1;
    sql:VarcharValue col_character_var = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_character_var =  ${col_character_var}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiNationalCharacterVarParam() returns error? {
    int id = 1;
    sql:NVarcharValue col_national_character_var = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_national_character_var =  ${col_national_character_var}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiNationalCharVarParam() returns error? {
    int id = 1;
    sql:NVarcharValue col_national_char_var = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_national_char_var =  ${col_national_char_var}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiNCharVarParam() returns error? {
    int id = 1;
    sql:NVarcharValue col_nchar_var = new("Hello world");
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_nchar_var =  ${col_nchar_var}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiNumericParam() returns error? {
    int id = 1;
    sql:NumericValue col_numeric = new(1234134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_numeric =  ${col_numeric}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiDecimalParam() returns error? {
    int id = 1;
    sql:DecimalValue col_decimal = new(1234134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_decimal =  ${col_decimal}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiIntegerParam() returns error? {
    int id = 1;
    sql:IntegerValue col_integer = new(1234134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_integer =  ${col_integer}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiIntParam() returns error? {
    int id = 1;
    sql:IntegerValue col_int = new(1234134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id} AND col_int =  ${col_int}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiSmallIntParam() returns error? {
    int id = 1;
    sql:IntegerValue col_smallint = new(1234134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_smallint =  ${col_smallint}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiFloatParam() returns error? {
    int id = 1;
    sql:FloatValue col_float = new(1234.134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_float =  ${col_float}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiDoublePrecisionParam() returns error? {
    int id = 1;
    sql:DoubleValue col_double_precision = new(1234.134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id}
        AND col_double_precision =  ${col_double_precision}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryAnsiRealParam() returns error? {
    int id = 1;
    sql:RealValue col_real = new(1234.134);
    sql:ParameterizedQuery sqlQuery = `SELECT * from AnsiSimpleQueryTable WHERE id = ${id} AND col_real =  ${col_real}`;
    validateAnsiSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function queryClobParam() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from LobSimpleQueryTable WHERE id = ${id}`;
    validateLobSimpleQueryTableResult(check queryClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
isolated function querySqlDsVarcharParam() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from SqlDsSimpleQueryTable WHERE id = ${id}`;
    validateSqlDsSimpleQueryTableResult(check queryClient(sqlQuery));
}

isolated function validateLobSimpleQueryTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(<int> returnData["ID"], 1);
        test:assertEquals(returnData["COL_CLOB"], "Hello world");
        test:assertEquals(returnData["COL_NCLOB"], "Hello world");
        test:assertEquals(returnData["COL_BLOB"], [171,52,239,194,52]);
    }
}

isolated function validateAnsiSimpleQueryTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(<int> returnData["ID"], 1);
        test:assertEquals((<string>returnData["COL_CHARACTER"]).trim(), "Hello world");
        test:assertEquals(returnData["COL_CHARACTER_VAR"], "Hello world");
        test:assertEquals((<string>returnData["COL_NATIONAL_CHARACTER"]).trim(), "Hello world");
        test:assertEquals((<string>returnData["COL_NATIONAL_CHAR"]).trim(), "Hello world");
        test:assertEquals(returnData["COL_NATIONAL_CHARACTER_VAR"], "Hello world");
        test:assertEquals(returnData["COL_NATIONAL_CHAR_VAR"], "Hello world");
        test:assertEquals(returnData["COL_NCHAR_VAR"], "Hello world");
        test:assertEquals(returnData["COL_NUMERIC"], <decimal>1234134);
        test:assertEquals(returnData["COL_DECIMAL"], <decimal>1234134);
        test:assertEquals(returnData["COL_INTEGER"], <decimal>1234134);
        test:assertEquals(returnData["COL_INT"], <decimal>1234134);
        test:assertEquals(returnData["COL_SMALLINT"], <decimal>1234134);
        test:assertEquals(<float>returnData["COL_FLOAT"], 1234.134);
        test:assertEquals(<float>returnData["COL_DOUBLE_PRECISION"], 1234.134);
        test:assertEquals(<float>returnData["COL_REAL"], 1234.134);
    }
}

isolated function validateCharacterSimpleQueryTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {

        test:assertEquals(<int> returnData["ID"], 1);
        test:assertEquals(returnData["COL_VARCHAR2"], "Hello world");
        test:assertEquals(returnData["COL_VARCHAR"], "Hello world");
        test:assertEquals(returnData["COL_NVARCHAR2"], "Hello world");
        test:assertEquals((<string>returnData["COL_CHAR"]).trim(), "Hello world");
        test:assertEquals((<string>returnData["COL_NCHAR"]).trim(), "Hello world");
    }
}

isolated function validateSqlDsSimpleQueryTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(<int> returnData["ID"], 1);
        test:assertEquals((<string>returnData["COL_CHARACTER"]).trim(), "Hello world");
        test:assertEquals(returnData["COL_LONG_VARCHAR"], "Hello world");
    } 
}
