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

@test:BeforeGroups { value:["varray"] }
isolated function beforeInsertVArrayFunc() returns sql:Error? {
   string OID = "19A57209ECB73F91E03400400B40BB25";

   Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
   sql:ExecutionResult result = check dropTypeIfExists("CharArrayType");
   result = check dropTypeIfExists("ByteArrayType");
   result = check dropTypeIfExists("IntArrayType");
   result = check dropTypeIfExists("BoolArrayType");
   result = check dropTypeIfExists("FloatArrayType");
   result = check dropTypeIfExists("DecimalArrayType");

   result = check oracledbClient->execute(
      `CREATE OR REPLACE TYPE CharArrayType AS VARRAY(6) OF VARCHAR(100);`);
   result = check oracledbClient->execute(
      `CREATE OR REPLACE TYPE ByteArrayType AS VARRAY(6) OF RAW(100);`);
   result = check oracledbClient->execute(
      `CREATE OR REPLACE TYPE IntArrayType AS VARRAY(6) OF NUMBER;`);
   result = check oracledbClient->execute(
      `CREATE OR REPLACE TYPE BoolArrayType AS VARRAY(6) OF NUMBER;`);
   result = check oracledbClient->execute(
      `CREATE OR REPLACE TYPE FloatArrayType AS VARRAY(6) OF FLOAT;`);
   result = check oracledbClient->execute(
      `CREATE OR REPLACE TYPE DecimalArrayType AS VARRAY(6) OF NUMBER;`);

   result = check dropTableIfExists("TestVarrayTable");
   result = check oracledbClient->execute(`CREATE TABLE TestVarrayTable(
      PK NUMBER GENERATED ALWAYS AS IDENTITY,
      COL_CHARARR CharArrayType,
      COL_BYTEARR ByteArrayType,
      COL_INTARR IntArrayType,
      COL_BOOLARR BoolArrayType,
      COL_FLOATARR FloatArrayType,
      COL_DECIMALARR DecimalArrayType,
      PRIMARY KEY(PK)
      )`
   );
   check oracledbClient.close();
 }

// insert to varray
@test:Config {
   enable: true,
   groups:["execute","varray"]
}
isolated function insertVarray() returns sql:Error? {

   string[] charArray = ["Hello", "World"];
   byte[] byteArray = [4, 23, 12];
   int[] intArray = [3,4,5];
   boolean[] boolArray = [true, false, false];
   float[] floatArray = [34, -98.23, 0.981];
   decimal[] decimalArray = [34, -98.23, 0.981];

   VarrayValue charVarray = new({ name:"CharArrayType", elements: charArray });
   VarrayValue byteVarray = new({ name:"ByteArrayType", elements: byteArray });
   VarrayValue intVarray = new({ name:"IntArrayType", elements: intArray });
   VarrayValue boolVarray = new({ name:"BoolArrayType", elements: boolArray });
   VarrayValue floatVarray = new({ name:"FloatArrayType", elements: floatArray });
   VarrayValue decimalVarray = new({ name:"DecimalArrayType", elements: decimalArray });

   sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
         COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
         values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

// insert with null VarrayValue object
@test:Config {
   enable: true,
   groups:["execute","varray"],
   dependsOn: [insertVarray]
}
isolated function insertVarrayNull() returns sql:Error? {
   VarrayValue charVarray = new();
   VarrayValue byteVarray = new();
   VarrayValue intVarray = new();
   VarrayValue boolVarray = new();
   VarrayValue floatVarray = new();
   VarrayValue decimalVarray = new();

   sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
      COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
      values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
   sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);

   if (result is sql:ApplicationError) {
      test:assertTrue(result.message().includes("Invalid parameter: null is passed as value for SQL type: varray"));
   } else {
      test:assertFail("Database Error expected.");
   }
}

// insert with null array
@test:Config {
   enable: true,
   groups:["execute","varray"],
   dependsOn: [insertVarrayNull]
}
isolated function insertVarrayWithNullArray() returns sql:Error? {
   VarrayValue charVarray = new({ name:"CharArrayType", elements: () });
   VarrayValue byteVarray = new({ name:"ByteArrayType", elements: () });
   VarrayValue intVarray = new({ name:"IntArrayType", elements: () });
   VarrayValue boolVarray = new({ name:"BoolArrayType", elements: () });
   VarrayValue floatVarray = new({ name:"FloatArrayType", elements: () });
   VarrayValue decimalVarray = new({ name:"DecimalArrayType", elements: () });

   sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
         COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
         values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

// insert with empty array
@test:Config {
    enable: true,
    groups:["execute","varray"],
    dependsOn: [insertVarrayWithNullArray]
}
isolated function insertVarrayWithEmptyArray() returns sql:Error? {
   string[] charArray = [];
   byte[] byteArray = [];
   int[] intArray = [];
   boolean[] boolArray = [];
   float[] floatArray = [];
   decimal[] decimalArray = [];

   VarrayValue charVarray = new({ name:"CharArrayType", elements: charArray });
   VarrayValue byteVarray = new({ name:"ByteArrayType", elements: byteArray });
   VarrayValue intVarray = new({ name:"IntArrayType", elements: intArray });
   VarrayValue boolVarray = new({ name:"BoolArrayType", elements: boolArray });
   VarrayValue floatVarray = new({ name:"FloatArrayType", elements: floatArray });
   VarrayValue decimalVarray = new({ name:"DecimalArrayType", elements: decimalArray });

   sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
            COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
            values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [insertVarrayWithEmptyArray]
}
isolated function selectVarrayWithoutRecordType() returns error? {
    string[] charArray = ["Hello", "World"];
    decimal[] decimalArray = [34, -98.23, 0.981];

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR, COL_DECIMALARR FROM TestVarrayTable WHERE pk = 1");
    record {}? data = check streamResult.next();
    check streamResult.close();
    record {}? value = <record {}>data["value"];
    string[] charArrayOut = <string[]>value["COL_CHARARR"];
    decimal[] decimalArrayOut = <decimal[]>value["COL_DECIMALARR"];

    test:assertEquals(charArrayOut, charArray);
    test:assertEquals(decimalArrayOut, decimalArray);

    check oracledbClient.close();
}

type ArrayRecordType record {
    int pk;
    string[] col_chararr;
    byte[] col_bytearr;
    int[] col_intarr;
    boolean[] col_boolarr;
    float[] col_floatarr;
    decimal[] col_decimalarr;
};

@test:Config {
    groups:["query","varray"],
     enable: false,
    dependsOn: [selectVarrayWithoutRecordType]
}
isolated function selectVarrayWithRecordType() returns error? {

    ArrayRecordType arrayRecordInstance = {
        pk : 1,
        col_chararr : ["Hello", "World"],
        col_bytearr : [4, 23, 12],
        col_intarr : [3,4,5],
        col_boolarr : [true, false, false],
        col_floatarr : [34, -98.23, 0.981],
        col_decimalarr : [34, -98.23, 0.981]
    };

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR " +
        "FROM TestVarrayTable WHERE pk = 1", ArrayRecordType);
    stream<ArrayRecordType, sql:Error> streamData = <stream<ArrayRecordType, sql:Error>>streamResult;
    record {|ArrayRecordType value;|}? data = check streamData.next();
    check streamData.close();
    ArrayRecordType? value = data?.value;
    if (value is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(value.length(), 7);
        test:assertEquals(value.pk, arrayRecordInstance.pk);
        test:assertEquals(value.col_chararr, arrayRecordInstance.col_chararr);
        test:assertEquals(value.col_bytearr, arrayRecordInstance.col_bytearr);
        test:assertEquals(value.col_intarr, arrayRecordInstance.col_intarr);
        test:assertEquals(value.col_boolarr, arrayRecordInstance.col_boolarr);
        test:assertEquals(value.col_floatarr, arrayRecordInstance.col_floatarr);
        test:assertEquals(value.col_decimalarr, arrayRecordInstance.col_decimalarr);
    }
    check oracledbClient.close();
}

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayWithRecordType]
}
isolated function selectVarrayNull() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR " +
        "FROM TestVarrayTable WHERE pk = 2", ArrayRecordType);
    stream<ArrayRecordType, sql:Error> streamData = <stream<ArrayRecordType, sql:Error>>streamResult;
    record {|ArrayRecordType value;|}? data = check streamData.next();
    check streamData.close();
    ArrayRecordType? value = data?.value;
    if (value is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(value.length(), 7);
        test:assertEquals(value.pk, 2);
        test:assertEquals(value.col_chararr, ());
        test:assertEquals(value.col_bytearr, ());
        test:assertEquals(value.col_intarr, ());
        test:assertEquals(value.col_boolarr, ());
        test:assertEquals(value.col_floatarr, ());
        test:assertEquals(value.col_decimalarr, ());
    }
    check oracledbClient.close();
}

type InvalidIntTypeArray record {
    int pk;
    int[] col_chararr;
};

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayNull]
}
isolated function selectVarrayWithInvalidIntType() returns error? {

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1", InvalidIntTypeArray);
    stream<InvalidIntTypeArray, sql:Error> streamData = <stream<InvalidIntTypeArray, sql:Error>>streamResult;
    record {}|error? returnData =  streamData.next();

    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: int[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }

    check streamData.close();
    check oracledbClient.close();
}

type InvalidFloatTypeArray record {
    int pk;
    float[] col_chararr;
};

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayWithInvalidIntType]
}
isolated function selectVarrayWithInvalidFloatType() returns error? {

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1", InvalidFloatTypeArray);
    stream<InvalidFloatTypeArray, sql:Error> streamData = <stream<InvalidFloatTypeArray, sql:Error>>streamResult;
    record {}|error? returnData =  streamData.next();

    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: float[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }

    check streamData.close();
    check oracledbClient.close();
}

type InvalidDecimalTypeArray record {
    int pk;
    decimal[] col_chararr;
};

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayWithInvalidFloatType]
}
isolated function selectVarrayWithInvalidDecimalType() returns error? {

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1", InvalidDecimalTypeArray);
    stream<InvalidDecimalTypeArray, sql:Error> streamData = <stream<InvalidDecimalTypeArray, sql:Error>>streamResult;
    record {}|error? returnData =  streamData.next();

    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: decimal[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }

    check streamData.close();
    check oracledbClient.close();
}

type InvalidBoolTypeArray record {
    int pk;
    boolean[] col_chararr;
};

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayWithInvalidDecimalType]
}
isolated function selectVarrayWithInvalidBoolType() returns error? {

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1", InvalidBoolTypeArray);
    stream<InvalidBoolTypeArray, sql:Error> streamData = <stream<InvalidBoolTypeArray, sql:Error>>streamResult;
    record {}|error? returnData =  streamData.next();

    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: boolean[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }

    check streamData.close();
    check oracledbClient.close();
}

type InvalidByteTypeArray record {
    int pk;
    byte[] col_chararr;
};

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayWithInvalidDecimalType]
}
isolated function selectVarrayWithInvalidByteType() returns error? {

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1", InvalidByteTypeArray);
    stream<InvalidByteTypeArray, sql:Error> streamData = <stream<InvalidByteTypeArray, sql:Error>>streamResult;
    record {}|error? returnData =  streamData.next();

    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: byte[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }

    check streamData.close();
    check oracledbClient.close();
}

type InvalidStringTypeArray record {
    int pk;
    string[] col_bytearr;
};

@test:Config {
    groups:["query","varray"],
    enable: false,
    dependsOn: [selectVarrayWithInvalidByteType]
}
isolated function selectVarrayWithInvalidStringType() returns error? {

    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, COL_BYTEARR FROM TestVarrayTable WHERE pk = 1", InvalidStringTypeArray);
    stream<InvalidStringTypeArray, sql:Error> streamData = <stream<InvalidStringTypeArray, sql:Error>>streamResult;
    record {}|error? returnData =  streamData.next();

    if (returnData is sql:ApplicationError) {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: string[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }

    check streamData.close();
    check oracledbClient.close();
}