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
    groups:["custom-object"]
}
isolated function insertObjectTypeWithString() returns sql:Error? {
    string string_attr = "Hello world";
    int int_attr = 34;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT)
        VALUES(OBJECT_TYPE(${string_attr}, ${int_attr}, ${float_attr}, ${decimal_attr}))`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithString]
}
isolated function insertObjectTypeWithCustomType() returns sql:Error? {
    string string_attr = "Hello world";
    int int_attr = 1;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;
    ObjectTypeValue objectType = new({typename: "object_type",
        attributes: [ string_attr, int_attr, float_attr, decimal_attr]});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithCustomType]
}
isolated function insertObjectTypeNull() returns sql:Error? {
    ObjectTypeValue objectType = new();
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType}))`;
    sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
    if (result is sql:ApplicationError) {
       test:assertTrue(result.message().includes("Invalid parameter: null is passed as value for SQL type: object"));
    } else {
       test:assertFail("Database Error expected.");
    }
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeNull]
}
isolated function insertObjectTypeWithNullArray() returns sql:Error? {
    ObjectTypeValue objectType = new({typename: "object_type", attributes: ()});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithNullArray]
}
isolated function insertObjectTypeWithEmptyArray() returns sql:Error? {
    ObjectTypeValue objectType = new({typename: "object_type", attributes: []});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 17049);
        test:assertEquals(errorDetails.sqlState, "99999");
    } else {
        test:assertFail("Database Error expected.");
    }
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithEmptyArray]
}
isolated function insertObjectTypeWithInvalidTypes1() returns sql:Error? {
    string string_attr = "Hello world";
    int int_attr = 34;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;
    ObjectTypeValue objectType = new({typename: "object_type",
        attributes: [ float_attr, int_attr, string_attr, decimal_attr]});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().includes("The array contains elements of unmappable types."));
    } else {
        test:assertFail("Application Error expected.");
    }
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithInvalidTypes1]
}
isolated function insertObjectTypeWithInvalidTypes2() returns sql:Error? {
    boolean invalid_attr = true;
    ObjectTypeValue objectType = new({typename: "object_type",
        attributes: [invalid_attr]});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().includes("The array contains elements of unmappable types."));
    } else {
        test:assertFail("Application Error expected.");
    }
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithInvalidTypes2]
}
isolated function insertObjectTypeWithInvalidTypes3() returns sql:Error? {
    map<string> invalid_attr = { key1: "value1", key2: "value2"};
    ObjectTypeValue objectType = new({typename: "object_type",
        attributes: [invalid_attr]});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().includes("The array contains elements of unmappable types."));
    } else {
        test:assertFail("Application Error expected.");
    }
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithInvalidTypes3]
}
isolated function insertObjectTypeWithStringArray() returns sql:Error? {
    string string_attr = "Hello world";
    string int_attr = "34";
    string float_attr = "34.23";
    string decimal_attr = "34.23";
    string[] attributes = [ string_attr, int_attr, float_attr, decimal_attr];
    ObjectTypeValue objectType = new({typename: "object_type", attributes: attributes});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups:["custom-object"],
    dependsOn: [insertObjectTypeWithStringArray]
}
isolated function insertObjectTypeWithNestedType() returns sql:Error? {
    string string_attr = "Hello world";
    int int_attr = 34;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;
    anydata[] attributes = [ string_attr,[string_attr, int_attr, float_attr, decimal_attr]];
    ObjectTypeValue objectType = new({typename: "nested_type", attributes: attributes});
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestNestedObjectTypeTable(COL_NESTED_OBJECT)
        VALUES(${objectType})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

type ObjectRecord record {
    string string_attr;
    int int_attr;
    float float_attr;
    decimal decimal_attr;
};

type ObjectRecordType record {
    int pk;
    ObjectRecord col_object;
};

@test:Config {
    groups: ["custom-object"],
    dependsOn: [insertObjectTypeWithNestedType]
}
isolated function selectObjectType() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<ObjectRecordType, error?> streamData = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1" );
    record {|ObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
    check oracledbClient.close();
    ObjectRecordType? value = data?.value;
    if (value is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(value.length(), 2);
        test:assertEquals(value["pk"], 1);

        ObjectRecord objRecord = value["col_object"];
        decimal delta = 0.01;

        test:assertEquals(objRecord["string_attr"], "Hello world");
        test:assertEquals(objRecord["int_attr"], 34);
        test:assertEquals(objRecord["float_attr"], 34.23);
        test:assertTrue(objRecord["decimal_attr"] - <decimal>34.23 < delta);
        test:assertTrue(objRecord["decimal_attr"] - <decimal>34.23 > -delta);
    }
}

@test:Config {
    groups: ["custom-object"],
    dependsOn: [selectObjectType]
}
isolated function selectObjectTypeNull() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<ObjectRecordType, error?> streamData = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 15");
    record {|ObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
    check oracledbClient.close();
    ObjectRecordType? value = data?.value;
    test:assertEquals(value, (), "Returned data should be nil");
}

type MismatchObjectRecord record {
    string string_attr;
    int int_attr;
    float float_attr;
};

type MismatchObjectRecordType record {
    int pk;
    MismatchObjectRecord col_object;
};

@test:Config {
    groups: ["custom-object"],
    dependsOn: [selectObjectTypeNull]
}
isolated function selectObjectTypeWithMisMatchingFieldCount() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<MismatchObjectRecordType, error?> streamData = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1");
    record {}|error? returnData = streamData.next();
    check streamData.close();
    check oracledbClient.close();
    if (returnData is sql:ApplicationError) {
        test:assertEquals(returnData.message(), "Error when iterating the SQL result. Record 'MismatchObjectRecord' " +
          "field count 3 and the returned SQL Struct field count 4 are different.");
    } else {
        test:assertFail("Querying custom type with rowType mismatching field count should fail with " +
                            "sql:ApplicationError");
    }
}

type BoolObjectRecord record {
    string string_attr;
    boolean int_attr;
    float float_attr;
    decimal decimal_attr;
};

type BoolObjectRecordType record {
    int pk;
    BoolObjectRecord col_object;
};

@test:Config {
    groups: ["custom-object"],
    dependsOn: [selectObjectTypeWithMisMatchingFieldCount]
}
isolated function selectObjectTypeWithBoolean() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<BoolObjectRecordType, error?> streamData = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 2");
    record {|BoolObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
    check oracledbClient.close();
    BoolObjectRecordType? value = data?.value;
    if (value is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(value.length(), 2);
        test:assertEquals(value["pk"], 2);

        BoolObjectRecord objRecord = value["col_object"];
        test:assertEquals(objRecord["int_attr"], true);
    }
}

type NestedObjectRecord record {
    string string_attr;
    ObjectRecord object_attr;
};

type NestedObjectRecordType record {
    int pk;
    NestedObjectRecord col_nested_object;
};

@test:Config {
    groups: ["custom-object"],
    dependsOn: [selectObjectTypeWithBoolean]
}
isolated function selectObjectTypeWithNestedType() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<NestedObjectRecordType, error?> streamData = oracledbClient->query(
        "SELECT pk, col_nested_object FROM TestNestedObjectTypeTable WHERE pk = 1");
    record {|NestedObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
    check oracledbClient.close();
    NestedObjectRecordType? value = data?.value;
    if (value is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(value.length(), 2);
        test:assertEquals(value["pk"], 1);

        NestedObjectRecord nestedRecord = value["col_nested_object"];
        decimal delta = 0.01;
        test:assertEquals(nestedRecord["string_attr"], "Hello world");

        ObjectRecord objRecord = nestedRecord["object_attr"];

        test:assertEquals(objRecord["int_attr"], 34);
        test:assertEquals(objRecord["float_attr"], 34.23);
        test:assertTrue(objRecord["decimal_attr"] - <decimal>34.23 < delta);
        test:assertTrue(objRecord["decimal_attr"] - <decimal>34.23 > -delta);
    }
}

type InvalidObjectRecord record {
    string string_attr;
    int int_attr;
    xml float_attr;
    decimal decimal_attr;
};

type InvalidObjectRecordType record {
    int pk;
    InvalidObjectRecord col_object;
};

@test:Config {
    groups: ["custom-object"],
    dependsOn: [selectObjectTypeWithNestedType]
}
isolated function selectObjectTypeWithInvalidTypedRecord() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<InvalidObjectRecordType, error?> streamData = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1");
    record {}|error? returnData = streamData.next();
    check streamData.close();
    check oracledbClient.close();
    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Error while retrieving data for unsupported type"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying custom type with invalid record field type should fail with " +
                            "sql:ApplicationError");
    }
}

@test:Config {
    groups: ["nested-table"]
}
isolated function insertToNestedTable() returns error? {
    string[] nameAtt = ["Smith", "John", "Arya", "Stark"];
    NestedTableValue students = new({name: "NestedNameTable", elements: nameAtt});
    int[] gradesAtt = [67, 45, 78, 86];
    NestedTableValue grades = new({name: "NestedGradeTable", elements: gradesAtt});
    int total = 4;
    int pk = 2;
    string teacher = "Kate Anderson";
    sql:ParameterizedQuery insertQuery = `INSERT INTO NestedClassTable(pk, col_teacher, col_students, col_grades, col_total)
            VALUES (${pk}, ${teacher}, ${students}, ${grades}, ${total})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

type ReturnZeroLevelNestedClassTable record {
    int pk;
    string col_teacher;
    string[] col_students;
    decimal[] col_grades;
    int col_total;
};

@test:Config {
    groups: ["nested-table"],
    dependsOn: [insertToNestedTable]
}
isolated function selectFromZeroLevelNestedTable() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<ReturnZeroLevelNestedClassTable, error?> streamData = oracledbClient->query(
        `SELECT * FROM NestedClassTable WHERE pk = 1`);
    record {|ReturnZeroLevelNestedClassTable value;|}? returnData = check streamData.next();
    ReturnZeroLevelNestedClassTable? value = returnData?.value;
    check streamData.close();
    check oracledbClient.close();
    ReturnZeroLevelNestedClassTable expectedData = {
         pk: 1,
         col_teacher: "Kate Johnson",
         col_students: ["John","Smith","Arya","Stark","Conan"],
         col_grades: [78, 56, 23, 68, 87],
         col_total: 5
    };
    test:assertEquals(value, expectedData, "Expected data mismatched.");
}

@test:Config {
   groups:["nested-table"],
   dependsOn: [insertToNestedTable]
}
isolated function insertNestedTableNull() returns error? {
    int pk = 3;
    NestedTableValue students = new();
    NestedTableValue grades = new();
    sql:ParameterizedQuery insertQuery = `INSERT INTO NestedClassTable(pk, col_students, col_grades)
            VALUES (${pk}, ${students}, ${grades})`;
    sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
    if result is sql:ApplicationError {
       test:assertTrue(result.message().includes("Invalid parameter: null is passed as value for SQL type: varray"));
    } else {
       test:assertFail("Database Error expected.");
    }
}

type InvalidIntTypeNestedTable record {
    int pk;
    int[] col_students;
};

@test:Config {
    groups:["nested-table"],
    dependsOn: [insertNestedTableNull]
}
isolated function selectNestedTableWithInvalidIntType() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<InvalidIntTypeNestedTable, sql:Error?> streamData = oracledbClient->query(
        `SELECT pk, col_students FROM NestedClassTable WHERE pk = 1`);
    record {}|error? returnData =  streamData.next();
    check streamData.close();
    check oracledbClient.close();
    if returnData is sql:ApplicationError {
        test:assertTrue(returnData.message().includes("Cannot cast array to type: int[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }
}
