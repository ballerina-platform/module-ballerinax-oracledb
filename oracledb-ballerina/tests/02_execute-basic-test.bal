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
 import ballerina/io;

 @test:Config{
     enable: true,
     groups:["execute","execute-basic"]
 }
 function testCreateTable() {
     Client oracledbClient = checkpanic new(user, password, host, port, database);

     sql:ExecutionResult result = checkpanic dropTableIfExists("TestExecuteTable");
     result = checkpanic oracledbClient->execute("CREATE TABLE TestExecuteTable(field NUMBER, field2 VARCHAR2(255))");
     test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
     test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");

     result = checkpanic dropTableIfExists("TestCharacterTable");
     result = checkpanic oracledbClient->execute("CREATE TABLE TestCharacterTable("+
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

     result = checkpanic dropTableIfExists("TestNumericTable");
     result = checkpanic oracledbClient->execute("CREATE TABLE TestNumericTable("+
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

     checkpanic oracledbClient.close();
 }

 @test:Config{
     enable: true,
     groups:["execute","execute-basic"],
     dependsOn: [testCreateTable]
 }
 isolated function testAlterTable() {
     Client oracledbClient = checkpanic new(user, password, host, port, database);
     sql:ExecutionResult result = checkpanic oracledbClient->execute("ALTER TABLE TestExecuteTable RENAME COLUMN field TO field1");
     checkpanic oracledbClient.close();
     test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
     test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
 }

 @test:Config{
     enable: true,
     groups:["execute","execute-basic"],
     dependsOn: [testAlterTable]
 }
 isolated function testInsertTable() {
     Client oracledbClient = checkpanic new(user, password, host, port, database);
     sql:ExecutionResult result = checkpanic oracledbClient->execute("INSERT INTO TestExecuteTable(field1, field2) VALUES (1, 'Hello, world')");
     checkpanic oracledbClient.close();

     test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
     var insertId = result.lastInsertId;

     test:assertTrue(insertId is string, "Last Insert id should be string");
 }

 @test:Config{
     enable: true,
     groups:["execute","execute-basic"],
     dependsOn: [testInsertTable]
 }
 isolated function testUpdateTable() {
     Client oracledbClient = checkpanic new(user, password, host, port, database);
     sql:ExecutionResult result = checkpanic oracledbClient->execute("UPDATE TestExecuteTable SET field2 = 'Hello, ballerina' WHERE field1 = 1");
     checkpanic oracledbClient.close();
     test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
     test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
 }

 @test:Config {
     groups: ["execute", "execute-basic"],
     dependsOn: [testInsertTable]
 }
 isolated function testInsertTableWithoutGeneratedKeys() {
     Client oracledbClient = checkpanic new (user, password, host, port, database);
     sql:ExecutionResult result = checkpanic oracledbClient->execute("Insert into TestCharacterTable (id, col_varchar2)"
         + " values (20, 'test')");
     checkpanic oracledbClient.close();
     test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
     var insertId = result.lastInsertId;
     test:assertTrue(insertId is string, "Last Insert id should be string");
 }

 @test:Config {
     groups: ["execute", "execute-basic"],
     dependsOn: [testInsertTableWithoutGeneratedKeys]
 }
 isolated function testInsertTableWithGeneratedKeys() {
     Client oracledbClient = checkpanic new (user, password, host, port, database);
     sql:ExecutionResult result = checkpanic oracledbClient->execute("insert into TestNumericTable (col_number) values (21)");
     checkpanic oracledbClient.close();
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
 isolated function testInsertAndSelectTableWithGeneratedKeys() {
    Client oracledbClient = checkpanic new (user, password, host, port, database);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("insert into TestNumericTable (col_number) values (31)");

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertedId = result.lastInsertId;
    if (insertedId is string|int) {
         string query = "SELECT * from TestNumericTable where col_number = 31";
         stream<record{} , error> queryResult = oracledbClient->query(query, NumericRecord);

         stream<NumericRecord, sql:Error> streamData = <stream<NumericRecord, sql:Error>>queryResult;
         record {|NumericRecord value;|}? data = checkpanic streamData.next();

         checkpanic streamData.close();
        
         test:assertNotExactEquals(data?.value, (), "Incorrect InsertId returned.");

    } else {
        test:assertFail("Last Insert id should be string.");
    }
    checkpanic oracledbClient.close();
 }

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertAndSelectTableWithGeneratedKeys]
 }
 isolated function testInsertWithAllNilAndSelectTableWithGeneratedKeys() {
       Client oracledbClient = checkpanic new (user, password, host, port, database);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("insert into TestNumericTable (col_number, col_float, "+
         "col_binary_float, col_binary_double) values (null, null, null, null)");

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertedId = result.lastInsertId;
    if (insertedId is string|int) {
         string query = "SELECT * from TestNumericTable where id =2 ";
         stream<record{} , error> queryResult = oracledbClient->query(query, NumericRecord);

         stream<NumericRecord, sql:Error> streamData = <stream<NumericRecord, sql:Error>>queryResult;
         record {|NumericRecord value;|}? data = checkpanic streamData.next();

         checkpanic streamData.close();
        
         test:assertNotExactEquals(data?.value, (), "Incorrect InsertId returned.");

    } else {
        test:assertFail("Last Insert id should be string");
    }
    checkpanic oracledbClient.close();
 }

 type StringData record {
    int id;
    string col_char;
    string col_nchar;
    string col_varchar2;
    string col_varchar;
    string col_nvarchar2;
 };

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
 }
 isolated function testInsertWithStringAndSelectTable() {
       Client oracledbClient = checkpanic new (user, password, host, port, database);
    int intIDVal = 25;
    string insertQuery = string `Insert into TestCharacterTable (
        id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2) values (
        ${intIDVal} ,'str1','str2','str3','str4','str5')`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string query = string `SELECT * from TestCharacterTable where id = ${intIDVal}`;
    stream<record{}, error> queryResult = oracledbClient->query(query, StringData);
    stream<StringData, sql:Error> streamData = <stream<StringData, sql:Error>>queryResult;
    record {|StringData value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();

    StringData expectedInsertRow = {
        id: 25,
        col_char:"str1",
        col_nchar:"str2",
        col_varchar2:"str3",
        col_varchar:"str4",
        col_nvarchar2:"str5"
    };
     test:assertEquals(data?.value, expectedInsertRow, "Incorrect record returned.");
    //io:println(("Length DB:"+data?.value.col_char).length());
    //io:println(("Length Record:"+expectedInsertRow.col_char).length());

    checkpanic oracledbClient.close();
 }

type StringNilData record {
    int id;
    string? col_char;
    string? col_nchar;
    string? col_varchar2;
    string? col_varchar;
    string? col_nvarchar2;
 };

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
    //dependsOn: [testInsertWithStringAndSelectTable]
 }
 isolated function testInsertWithEmptyStringAndSelectTable() {
       Client oracledbClient = checkpanic new (user, password, host, port, database);
    int intIDVal = 35;
    string insertQuery = string `Insert into TestCharacterTable (
        id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2) values (
        ${intIDVal} ,'','','','','')`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string query = string `SELECT * from TestCharacterTable where id = ${intIDVal}`;
    stream<record{}, error> queryResult = oracledbClient->query(query, StringNilData);
    stream<StringNilData, sql:Error> streamData = <stream<StringNilData, sql:Error>>queryResult;
    record {|StringNilData value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();

    StringNilData expectedInsertRow = {
        id: 35,
        col_char:(),
        col_nchar:(),
        col_varchar2:(),
        col_varchar:(),
        col_nvarchar2:()
    };
    test:assertEquals(data?.value, expectedInsertRow, "Incorrect record returned.");

    checkpanic oracledbClient.close();
 }

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
    //dependsOn: [testInsertWithEmptyStringAndSelectTable]
 }
 isolated function testInsertWithNilStringAndSelectTable() {
       Client oracledbClient = checkpanic new (user, password, host, port, database);
    int intIDVal = 45;
    string insertQuery = string `Insert into TestCharacterTable (id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2) values (
        ${intIDVal} ,null,null,null,null,null)`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string query = string `SELECT * from TestCharacterTable where id = ${intIDVal}`;
    stream<record{}, error> queryResult = oracledbClient->query(query, StringNilData);
    stream<StringNilData, sql:Error> streamData = <stream<StringNilData, sql:Error>>queryResult;
    record {|StringNilData value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();

    StringNilData expectedInsertRow = {
        id: 45,
        col_char:(),
        col_nchar:(),
        col_varchar2:(), 
        col_varchar:(),
        col_nvarchar2:()
    };
    test:assertEquals(data?.value, expectedInsertRow, "Incorrect record returned.");
    checkpanic oracledbClient.close();
 }

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
    //dependsOn: [testInsertWithNilStringAndSelectTable]
 }
 isolated function testInsertTableWithDatabaseError() {
       Client oracledbClient = checkpanic new (user, password, host, port, database);
    sql:ExecutionResult|sql:Error result = oracledbClient->execute("Insert into NumericTypesNonExistTable (int_type) values (20)");

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 942, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "42000", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    checkpanic oracledbClient.close();
 }

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
    //dependsOn: [testInsertTableWithDatabaseError]
 }
 isolated function testInsertTableWithDataTypeError() {
       Client oracledbClient = checkpanic new (user, password, host, port, database);
    sql:ExecutionResult|sql:Error result = oracledbClient->execute("Insert into TestNumericTable (col_number) values"
        + " ('This is wrong type')");

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1722, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "42000", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    checkpanic oracledbClient.close();
 }

 type ResultCount record {
    int countVal;
 };

 @test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithAllNilAndSelectTableWithGeneratedKeys]
    //dependsOn: [testInsertTableWithDataTypeError]
 }
 isolated function testUpdateData() {
    Client oracledbClient = checkpanic new (user, password, host, port, database);
    sql:ExecutionResult result = checkpanic oracledbClient->execute("Update TestNumericTable set col_number = 11 where col_number = 31");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    stream<record{}, error> queryResult = oracledbClient->query("SELECT count(*) as countval from TestNumericTable"
        + " where int_type = 11", ResultCount);
    io:println("Count:");
    io:println(queryResult);
    stream<ResultCount, sql:Error> streamData = <stream<ResultCount, sql:Error>>queryResult;
    record {|ResultCount value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    test:assertEquals(data?.value?.countVal, 1, "Update command was not successful.");

    checkpanic oracledbClient.close();
 }

 @test:Config{
     enable: true,
     groups:["execute","execute-basic"],
     dependsOn:[testUpdateData]
 }
 isolated function testDropTable() {
     Client oracledbClient = checkpanic new(user, password, host, port, database);
     sql:ExecutionResult result = checkpanic oracledbClient->execute("DROP TABLE TestNumericTable");
     checkpanic oracledbClient.close();
     test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
     test:assertExactEquals(result.lastInsertId, (), "Last Insert Id should be null.");
 }

