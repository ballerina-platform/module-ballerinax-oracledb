// // Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
// //
// // WSO2 Inc. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied. See the License for the
// // specific language governing permissions and limitations
// // under the License.

// import ballerina/sql;
// import ballerina/test;

// @test:BeforeGroups { value:["insert-varray"] }
// function beforeInsertVArrayFunc() {

//     Client oracledbClient = checkpanic new(user, password, host, port, database);
//     sql:ExecutionResult result = checkpanic oracledbClient->execute(
//         " CREATE OR REPLACE TYPE CharArrayType AS VARRAY(6) OF VARCHAR(100);"
//         );

//     result = checkpanic oracledbClient->execute(
//         " CREATE OR REPLACE TYPE NumArrayType AS VARRAY(6) OF NUMBER;"
//         );

//     result = checkpanic oracledbClient->execute(
//         "CREATE OR REPLACE TYPE VarrayType OID '"+ OID +"' AS OBJECT(" +
//         "ATTR1 VARCHAR(20), "+
//         "ATTR2 VARCHAR(20), "+
//         "ATTR3 VARCHAR(20), "+
//         "MAP MEMBER FUNCTION GET_ATTR1 RETURN NUMBER "+
//         ") "
//     );
    
//     result = checkpanic oracledbClient->execute(
//         "CREATE OR REPLACE TYPE BODY VarrayType AS "+
//             "MAP MEMBER FUNCTION GET_ATTR1 RETURN NUMBER IS "+
//             "BEGIN "+
//                 "RETURN ATTR1; "+
//             "END; "+
//         "END; "
//     );

//     result = checkpanic oracledbClient->execute("CREATE TABLE TestVarrayTable(" +
//         "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
//         "COL_CHARARR CharArrayType, " +
//         "COL_NUMARR NumArrayType, " +
//         "PRIMARY KEY(PK) "+
//         ")"
//         );
    
//     checkpanic oracledbClient.close();
// }



// @test:Config{
//     enable: true,
//     groups:["insert","insert-varray"]
// }
// isolated function insertVarray() {
//     Client oracledbClient = checkpanic new(user, password, host, port, database);
//     string[] charArray = ["Hello", "World"];
//     int[] numArray = [3,4,5];

//     VarrayValue charVarray = new({ name:"CharArrayType", elements: charArray });
//     VarrayValue numVarray = new({ name:"NumArrayType", elements: numArray });

//     sql:ParameterizedQuery insertQuery = `insert into varraytable(COL_CHARARR, COL_NUMARR) values(${charVarray}, ${numVarray})`;
//     sql:ExecutionResult| sql:Error result = checkpanic oracledbClient->execute(insertQuery);
   
//     test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//     var insertId = result.lastInsertId;
//     test:assertTrue(insertId is string, "Last Insert id should be string");

//     checkpanic oracledbClient.close();
// }

// @test:Config{
//     enable: true,
//     groups:["insert","insert-varray"],
//     dependsOn: [insertVarray]
// }
// isolated function insertVarrayNull() {
//     Client oracledbClient = checkpanic new(user, password, host, port, database);
    
//     VarrayValue charVarray = new();
//     VarrayValue numVarray = new();

//     sql:ParameterizedQuery insertQuery = `insert into varraytable(COL_CHARARR, COL_NUMARR) values(${charArray}, ${numArray})`;
//     sql:ExecutionResult| sql:Error result = checkpanic oracledbClient->execute(insertQuery);
   
//     test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//     var insertId = result.lastInsertId;
//     test:assertTrue(insertId is string, "Last Insert id should be string");

//     checkpanic oracledbClient.close();
// }

