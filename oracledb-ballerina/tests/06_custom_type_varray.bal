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
 
@test:BeforeGroups { value:["insert-varray"] }
function beforeInsertVArrayFunc() returns sql:Error? {
   string OID = "19A57209ECB73F91E03400400B40BB25";
 
   Client oracledbClient = check new(user, password, host, port, database);
   sql:ExecutionResult result = check oracledbClient->execute(
      "CREATE OR REPLACE TYPE CharArrayType AS VARRAY(6) OF VARCHAR(100);");
   result = check oracledbClient->execute(
      "CREATE OR REPLACE TYPE ByteArrayType AS VARRAY(6) OF RAW(100);");
   result = check oracledbClient->execute(
      "CREATE OR REPLACE TYPE IntArrayType AS VARRAY(6) OF NUMBER;");
   result = check oracledbClient->execute(
      "CREATE OR REPLACE TYPE BoolArrayType AS VARRAY(6) OF NUMBER;");
   result = check oracledbClient->execute(
      "CREATE OR REPLACE TYPE FloatArrayType AS VARRAY(6) OF FLOAT;");
   result = check oracledbClient->execute(
      "CREATE OR REPLACE TYPE DecimalArrayType AS VARRAY(6) OF NUMBER;");

   result = check oracledbClient->execute("CREATE TABLE TestVarrayTable(" +
      "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
      "COL_CHARARR CharArrayType, " +
      "COL_BYTEARR ByteArrayType, " +
      "COL_INTARR IntArrayType, " +
      "COL_BOOLARR BoolArrayType, " +
      "COL_FLOATARR FloatArrayType, " +
      "COL_DECIMALARR DecimalArrayType, " +
      "PRIMARY KEY(PK) "+
      ")"
   );
   check oracledbClient.close();
 }

// insert to varray
@test:Config {
   enable: true,
   groups:["execute","insert-varray"]
}
function insertVarray() returns sql:Error? {

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
   sql:ExecutionResult result = check executeParamQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

// insert with null VarrayValue object
@test:Config {
   enable: true,
   groups:["execute","insert-varray"],
   dependsOn: [insertVarray]
}
function insertVarrayNull() returns sql:Error? {
   VarrayValue charVarray = new();
   VarrayValue byteVarray = new();
   VarrayValue intVarray = new();
   VarrayValue boolVarray = new();
   VarrayValue floatVarray = new();
   VarrayValue decimalVarray = new();

   sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
      COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
      values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
   sql:ExecutionResult|sql:Error result = executeParamQuery(insertQuery);

   if (result is sql:ApplicationError) {
      test:assertTrue(result.message().includes("Invalid parameter: null is passed as value for SQL type: varray"));
   } else {
      test:assertFail("Database Error expected.");
   }
}

// insert with null array
@test:Config {
   enable: true,
   groups:["execute","insert-varray"],
   dependsOn: [insertVarrayNull]
}
function insertVarrayWithNullArray() returns sql:Error? {
   VarrayValue charVarray = new({ name:"CharArrayType", elements: () });
   VarrayValue byteVarray = new({ name:"ByteArrayType", elements: () });
   VarrayValue intVarray = new({ name:"IntArrayType", elements: () });
   VarrayValue boolVarray = new({ name:"BoolArrayType", elements: () });
   VarrayValue floatVarray = new({ name:"FloatArrayType", elements: () });
   VarrayValue decimalVarray = new({ name:"DecimalArrayType", elements: () });

   sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
         COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
         values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
   sql:ExecutionResult result = check executeParamQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

// insert with empty array
@test:Config {
    enable: true,
    groups:["execute","insert-varray"],
    dependsOn: [insertVarrayWithNullArray]
}
function insertVarrayWithEmptyArray() returns sql:Error? {
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
   sql:ExecutionResult result = check executeParamQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

