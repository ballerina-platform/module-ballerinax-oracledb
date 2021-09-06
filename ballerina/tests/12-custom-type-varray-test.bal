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

// insert to varray
@test:Config {
   groups:["custom-varray"]
}
isolated function insertVarray() returns sql:Error? {
    string[] charArray = ["Hello", "World"];
    byte[] byteArray = [4, 23, 12];
    int[] intArray = [3, 4, 5];
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
   groups:["custom-varray"],
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
    if result is sql:ApplicationError {
       test:assertTrue(result.message().includes("Invalid parameter: null is passed as value for SQL type: varray"));
    } else {
       test:assertFail("Database Error expected.");
    }
}

// insert with null array
@test:Config {
   groups:["custom-varray"],
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
    groups:["custom-varray"],
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

// insert with null elements
@test:Config {
   groups:["custom-varray"],
   dependsOn: [insertVarrayWithEmptyArray]
}
isolated function insertVarrayWithNullElements() returns sql:Error? {
    string?[] charArray = [null, null];
    byte[]?[] byteArray = [null, null];
    int?[] intArray = [null, null];
    boolean?[] boolArray = [null, null];
    float?[] floatArray = [null, null];
    decimal?[] decimalArray = [null, null];

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
    groups:["custom-varray"],
    dependsOn: [insertVarray]
}
isolated function selectVarrayWithoutRecordType() returns error? {
    string[] charArray = ["Hello", "World"];
    byte[][] byteArray = [[4, 23, 12]];
    decimal[] intArray = [3, 4, 5];
    decimal[] boolArray = [1, 0, 0];
    decimal[] floatArray = [34, -98.23, 0.981];
    decimal[] decimalArray = [34, -98.23, 0.981];
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<record{}, error?> streamResult = oracledbClient->query(
        `SELECT pk, COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR FROM TestVarrayTable WHERE pk = 1`);
    record {}? data = check streamResult.next();
    check streamResult.close();
    check oracledbClient.close();
    record {}? value = <record {}> data["value"];
    string[] charArrayOut = <string[]> value["COL_CHARARR"];
    byte[][] byteArrayOut = <byte[][]> value["COL_BYTEARR"];
    decimal[] intArrayOut = <decimal[]> value["COL_INTARR"];
    decimal[] boolArrayOut = <decimal[]> value["COL_BOOLARR"];
    decimal[] floatArrayOut = <decimal[]> value["COL_FLOATARR"];
    decimal[] decimalArrayOut = <decimal[]> value["COL_DECIMALARR"];
    test:assertEquals(charArrayOut, charArray);
    test:assertEquals(byteArrayOut, byteArray);
    test:assertEquals(intArrayOut, intArray);
    test:assertEquals(boolArrayOut, boolArray);
    test:assertEquals(floatArrayOut, floatArray);
    test:assertEquals(decimalArrayOut, decimalArray);
}

type ArrayRecordType record {
    int pk;
    string[] col_chararr;
    byte[][] col_bytearr;
    int[] col_intarr;
    boolean[] col_boolarr;
    float[] col_floatarr;
    decimal[] col_decimalarr;
};

@test:Config {
    groups:["custom-varray"],
    dependsOn: [insertVarray]
}
isolated function selectVarrayWithRecordType() returns error? {
    ArrayRecordType arrayRecordInstance = {
        pk : 1,
        col_chararr : ["Hello", "World"],
        col_bytearr : [[4, 23, 12]],
        col_intarr : [3,4,5],
        col_boolarr : [true, false, false],
        col_floatarr : [34, -98.23, 0.981],
        col_decimalarr : [34, -98.23, 0.981]
    };
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<ArrayRecordType, error?> streamData = oracledbClient->query(
        `SELECT pk, COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR
         FROM TestVarrayTable WHERE pk = 1`);
    record {|ArrayRecordType value;|}? data = check streamData.next();
    check streamData.close();
    check oracledbClient.close();
    ArrayRecordType? value = data?.value;
    if value is () {
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
}

@test:Config {
    groups:["custom-varray"],
    dependsOn: [insertVarrayNull]
}
isolated function selectVarrayNull() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<ArrayRecordType, sql:Error?> streamData = oracledbClient->query(
        "SELECT pk, COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR " +
        "FROM TestVarrayTable WHERE pk = 2");
    record {|ArrayRecordType value;|}? data = check streamData.next();
    check streamData.close();
    check oracledbClient.close();
    ArrayRecordType? value = data?.value;
    if value is () {
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
}

type InvalidIntTypeArray record {
    int pk;
    int[] col_chararr;
};

@test:Config {
    groups:["custom-varray"],
    dependsOn: [insertVarray]
}
isolated function selectVarrayWithInvalidIntType() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    stream<InvalidIntTypeArray, sql:Error?> streamData = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1");
    record {}|error? returnData =  streamData.next();
    check streamData.close();
    check oracledbClient.close();
    if returnData is sql:ApplicationError {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: int[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }
}

type InvalidStringTypeArray record {
    int pk;
    string[] col_bytearr;
};

@test:Config {
    groups:["custom-varray"],
    dependsOn: [insertVarray]
}
isolated function selectVarrayWithInvalidStringType() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<InvalidStringTypeArray, sql:Error?> streamData = oracledbClient->query(
        "SELECT pk, COL_BYTEARR FROM TestVarrayTable WHERE pk = 1");
    record {}|error? returnData =  streamData.next();
    check streamData.close();
    check oracledbClient.close();
    if returnData is sql:ApplicationError {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: string[]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }
}

type InvalidByteTypeArray record {
    int pk;
    byte[][] col_chararr;
};

@test:Config {
    groups:["custom-varray"],
    dependsOn: [insertVarray]
}
isolated function selectVarrayWithInvalidByteType() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    stream<InvalidByteTypeArray, sql:Error?> streamData = oracledbClient->query(
        "SELECT pk, COL_CHARARR FROM TestVarrayTable WHERE pk = 1");
    record {}|error? returnData =  streamData.next();
    check streamData.close();
    check oracledbClient.close();
    if returnData is sql:ApplicationError {
        test:assertTrue(returnData.message().includes("Cannot cast varray to type: byte[][]"),
            "Incorrect error message");
    } else {
        test:assertFail("Querying varray with invalid array type should fail with " +
                            "sql:ApplicationError");
    }
}
