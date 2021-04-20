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

@test:BeforeGroups { value:["insert-object"] }
isolated function beforeInsertObjectFunc() returns sql:Error? {
   string OID = "19A57209ECB73F91E03400400B40BB23";
   string OID2 = "19A57209ECB73F91E03400400B40BB25";

   Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
   sql:ExecutionResult result = check dropTableIfExists("TestObjectTypeTable");
   result = check dropTableIfExists("TestNestedObjectTypeTable");
   result = check dropTypeIfExists("OBJECT_TYPE");
   result = check dropTypeIfExists("NESTED_TYPE");
   result = check oracledbClient->execute(
       "CREATE OR REPLACE TYPE OBJECT_TYPE OID '" + OID + "' AS OBJECT(" +
        "STRING_ATTR VARCHAR(20), " +
        "INT_ATTR NUMBER, " +
        "FLOAT_ATTR FLOAT, " +
        "DECIMAL_ATTR FLOAT " +
       ") "
   );
   result = check oracledbClient->execute("CREATE TABLE TestObjectTypeTable(" +
       "PK NUMBER GENERATED ALWAYS AS IDENTITY, " +
       "COL_OBJECT OBJECT_TYPE, " +
       "PRIMARY KEY(PK) " +
       ")"
   );

   result = check oracledbClient->execute(
       "CREATE OR REPLACE TYPE NESTED_TYPE OID '" + OID2 + "' AS OBJECT(" +
        "STRING_ATTR VARCHAR2(20), " +
        "OBJECT_ATTR OBJECT_TYPE, " +
        "MAP MEMBER FUNCTION GET_ATTR1 RETURN NUMBER " +
       ") "
   );
   result = check oracledbClient->execute("CREATE TABLE TestNestedObjectTypeTable(" +
       "PK NUMBER GENERATED ALWAYS AS IDENTITY, " +
       "COL_NESTED_OBJECT NESTED_TYPE, " +
       "PRIMARY KEY(PK) " +
       ")"
   );

   check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"]
}
isolated function insertObjectTypeWithString() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    string string_attr = "Hello world";
    int int_attr = 34;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) 
        VALUES(OBJECT_TYPE(${string_attr}, ${int_attr}, ${float_attr}, ${decimal_attr}))`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithString]
}
isolated function insertObjectTypeWithCustomType() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    string string_attr = "Hello world";
    int int_attr = 1;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;

    ObjectTypeValue objectType = new({typename: "object_type", 
        attributes: [ string_attr, int_attr, float_attr, decimal_attr]});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithCustomType]
}
isolated function insertObjectTypeNull() returns sql:Error? {
   Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

   ObjectTypeValue objectType = new();

   sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType}))`;
   sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

   if (result is sql:ApplicationError) {
      test:assertTrue(result.message().includes("Invalid parameter: null is passed as value for SQL type: object"));
   } else {
      test:assertFail("Database Error expected.");
   }
   check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeNull]
}
isolated function insertObjectTypeWithNullArray() returns sql:Error? {
   Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
   ObjectTypeValue objectType = new({typename: "object_type", attributes: ()});

   sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
   sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");

   check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithNullArray]
}
isolated function insertObjectTypeWithEmptyArray() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    ObjectTypeValue objectType = new({typename: "object_type", attributes: []});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 17049);
        test:assertEquals(errorDetails.sqlState, "99999");
    } else {
        test:assertFail("Database Error expected.");
    }
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithEmptyArray]
}
isolated function insertObjectTypeWithInvalidTypes1() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string string_attr = "Hello world";
    int int_attr = 34;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;

    ObjectTypeValue objectType = new({typename: "object_type", 
        attributes: [ float_attr, int_attr, string_attr, decimal_attr]});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);
    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().includes("The array contains elements of unmappable types."));
    } else {
        test:assertFail("Application Error expected.");
    }
    check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithInvalidTypes1]
}
isolated function insertObjectTypeWithInvalidTypes2() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    boolean invalid_attr = true;

    ObjectTypeValue objectType = new({typename: "object_type", 
        attributes: [invalid_attr]});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().includes("The array contains elements of unmappable types."));
    } else {
        test:assertFail("Application Error expected.");
    }
    check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithInvalidTypes2]
}
isolated function insertObjectTypeWithInvalidTypes3() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    map<string> invalid_attr = { key1: "value1", key2: "value2"};

    ObjectTypeValue objectType = new({typename: "object_type", 
        attributes: [invalid_attr]});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().includes("The array contains elements of unmappable types."));
    } else {
        test:assertFail("Application Error expected.");
    }
    check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithInvalidTypes3]
}
isolated function insertObjectTypeWithStringArray() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    string string_attr = "Hello world";
    string int_attr = "34";
    string float_attr = "34.23";
    string decimal_attr = "34.23";

    string[] attributes = [ string_attr, int_attr, float_attr, decimal_attr];

    ObjectTypeValue objectType = new({typename: "object_type", attributes: attributes});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

@test:Config {
   enable: true,
   groups:["execute","insert-object"],
   dependsOn: [insertObjectTypeWithStringArray]
}
isolated function insertObjectTypeWithNestedType() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    string string_attr = "Hello world";
    int int_attr = 34;
    float float_attr = 34.23;
    decimal decimal_attr = 34.23;

    anydata[] attributes = [ string_attr,[string_attr, int_attr, float_attr, decimal_attr]];
    ObjectTypeValue objectType = new({typename: "nested_type", attributes: attributes});

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestNestedObjectTypeTable(COL_NESTED_OBJECT)
        VALUES(${objectType})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
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
    groups: ["execute", "execute-params"],
    dependsOn: [insertObjectTypeWithNestedType]
}
isolated function selectObjectType() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1", ObjectRecordType);
    stream<ObjectRecordType, sql:Error> streamData = <stream<ObjectRecordType, sql:Error>>streamResult;
    record {|ObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
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
    check oracledbClient.close();
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [selectObjectType]
}
isolated function selectObjectTypeNull() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 15", ObjectRecordType);
    stream<ObjectRecordType, sql:Error> streamData = <stream<ObjectRecordType, sql:Error>>streamResult;
    record {|ObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
    ObjectRecordType? value = data?.value;
    test:assertEquals(value, (), "Returned data should be nil");
    check oracledbClient.close();
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
    groups: ["execute", "execute-params"],
    dependsOn: [selectObjectTypeNull]
}
isolated function selectObjectTypeWithMisMatchingFieldCount() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1", MismatchObjectRecordType);
    stream<MismatchObjectRecordType, sql:Error> streamData = <stream<MismatchObjectRecordType, sql:Error>>streamResult;
    record {}|error returnData = streamData.next();
    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("specified record and the returned SQL Struct field counts " +
                            "are different, and hence not compatible"), "Incorrect error message");
    } else {
        test:assertFail("Querying custom type with rowType mismatching field count should fail with " +
                            "sql:ApplicationError");
    }
    check streamData.close();
    check oracledbClient.close();
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
    groups: ["execute", "execute-params"],
    dependsOn: [selectObjectTypeWithMisMatchingFieldCount]
}
isolated function selectObjectTypeWithBoolean() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 2", BoolObjectRecordType);
    stream<BoolObjectRecordType, sql:Error> streamData = <stream<BoolObjectRecordType, sql:Error>>streamResult;
    record {|BoolObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
    BoolObjectRecordType? value = data?.value;
    if (value is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(value.length(), 2);
        test:assertEquals(value["pk"], 2);

        BoolObjectRecord objRecord = value["col_object"];
        test:assertEquals(objRecord["int_attr"], true);
    }
    check oracledbClient.close();
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
    groups: ["execute", "execute-params"],
    dependsOn: [selectObjectTypeWithBoolean]
}
isolated function selectObjectTypeWithNestedType() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_nested_object FROM TestNestedObjectTypeTable WHERE pk = 1", NestedObjectRecordType);
    stream<NestedObjectRecordType, sql:Error> streamData = <stream<NestedObjectRecordType, sql:Error>>streamResult;
    record {|NestedObjectRecordType value;|}? data = check streamData.next();
    check streamData.close();
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
    check oracledbClient.close();
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
    groups: ["execute", "execute-params"],
    dependsOn: [selectObjectTypeWithNestedType]
}
isolated function selectObjectTypeWithInvalidTypedRecord() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1", InvalidObjectRecordType);
    stream<InvalidObjectRecordType, sql:Error> streamData = <stream<InvalidObjectRecordType, sql:Error>>streamResult;
    record {}|error returnData = streamData.next();
    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Error while retrieving data for unsupported type"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying custom type with invalid record field type should fail with " +
                            "sql:ApplicationError");
    }
    check streamData.close();
    check oracledbClient.close();
}
