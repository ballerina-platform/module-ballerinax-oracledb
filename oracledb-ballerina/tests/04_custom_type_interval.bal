//  // Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//  //
//  // WSO2 Inc. licenses this file to you under the Apache License,
//  // Version 2.0 (the "License"); you may not use this file except
//  // in compliance with the License.
//  // You may obtain a copy of the License at
//  // http://www.apache.org/licenses/LICENSE-2.0
//  //
//  // Unless required by applicable law or agreed to in writing,
//  // software distributed under the License is distributed on an
//  // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  // KIND, either express or implied. See the License for the
//  // specific language governing permissions and limitations
//  // under the License.

//  import ballerina/sql;
//  import ballerina/test;

//  @test:BeforeGroups { value:["insert-time"] }
//  function beforeInsertTimeFunc() {
//      Client oracledbClient = checkpanic new(user, password, host, port, database);
//      sql:ExecutionResult result = checkpanic dropTableIfExists("TestDateTimeTable");
//      result = checkpanic oracledbClient->execute("ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-RR HH:MI:SS AM'");
//      result = checkpanic oracledbClient->execute("ALTER session set NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-RR HH:MI:SS AM TZR'");
//      result = checkpanic oracledbClient->execute("CREATE TABLE TestDateTimeTable(" +
//          "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
//          // "COL_DATE  DATE, " +
//          // "COL_TIMESTAMP_1  TIMESTAMP (9), " +
//          // "COL_TIMESTAMP_2  TIMESTAMP (9) WITH TIME ZONE, " +
//          // "COL_TIMESTAMP_3  TIMESTAMP (9) WITH LOCAL TIME ZONE, " +
//          "COL_INTERVAL_YEAR_TO_MONTH INTERVAL YEAR TO MONTH, "+
//          "COL_INTERVAL_DAY_TO_SECOND INTERVAL DAY(9) TO SECOND(9), "+
//          "PRIMARY KEY(PK) "+
//          ")"
//      );

//      //result = checkpanic dropTableIfExists("TestBFileTable");
//      //result = checkpanic oracledbClient->execute("CREATE TABLE TestBFileTable(" +
//      //    "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
//      //    "COL_BFILE  BFILE, " +
//      //    "PRIMARY KEY(PK) "+
//      //    ")"
//      //);

//      checkpanic oracledbClient.close();
//  }



//  @test:Config{
//      enable: true,
//      groups:["insert","insert-time"]
//  }
//  isolated function insertIntervalWithString() {
//      Client oracledbClient = checkpanic new(user, password, host, port, database);
//      string intervalYtoM = "15-11";
//      string intervalDtoS = "200 5:12:45.89";

//      sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
//          COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
//      sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

//      test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//      var insertId = result.lastInsertId;
//      test:assertTrue(insertId is string, "Last Insert id should be string");

//      checkpanic oracledbClient.close();
//  }

//  @test:Config{
//      enable: true,
//      groups:["insert","insert-time"],
//      dependsOn: [insertIntervalWithString]
//  }
//  isolated function insertIntervalWithBalTypeString() {
//      Client oracledbClient = checkpanic new(user, password, host, port, database);
//      IntervalYearToMonthValue intervalYtoM = new("15-11");
//      IntervalDayToSecondValue intervalDtoS = new("13 5:34:23.45");

//      sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
//              COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
//      sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

//      test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//      var insertId = result.lastInsertId;
//      test:assertTrue(insertId is string, "Last Insert id should be string");

//      checkpanic oracledbClient.close();

//  }

//  @test:Config{
//      enable: true,
//      groups:["insert","insert-time"],
//      dependsOn: [insertIntervalWithBalTypeString]
//  }
//  isolated function insertIntervalWithBalType() {
//      Client oracledbClient = checkpanic new(user, password, host, port, database);
//      IntervalYearToMonthValue intervalYtoM = new({ year:15, month: 11 });
//      IntervalDayToSecondValue intervalDtoS = new({ day:13, hour: 5, minute: 34, second: 23.45 });

//      sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
//          COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
//      sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

//      test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//      var insertId = result.lastInsertId;
//      test:assertTrue(insertId is string, "Last Insert id should be string");

//      checkpanic oracledbClient.close();

//  }

//  @test:Config{
//      enable: true,
//      groups:["insert","insert-time"],
//      dependsOn: [insertIntervalWithBalType]
//  }
//  isolated function insertIntervalNull() {
//      Client oracledbClient = checkpanic new(user, password, host, port, database);
//      IntervalYearToMonthValue intervalYtoM = new ();
//      IntervalDayToSecondValue intervalDtoS = new();


//      sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
//              COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
//      sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

//      test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//      var insertId = result.lastInsertId;
//      test:assertTrue(insertId is string, "Last Insert id should be string");

//      checkpanic oracledbClient.close();
//  }

//  @test:Config{
//      enable: true,
//      groups:["insert","insert-time"],
//      dependsOn: [insertIntervalNull]
//  }
//  isolated function insertIntervalWithInvalidBalType1() {
//     Client oracledbClient = checkpanic new(user, password, host, port, database);
//      IntervalYearToMonthValue intervalYtoM = new({year:12, month: 340});
//      IntervalDayToSecondValue intervalDtoS = new({ day:1, hour: 555, minute: 34, second: 23.45 });

//      sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
//              COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
//      sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

//      if (result is sql:DatabaseError) {
//          sql:DatabaseErrorDetail errorDetails = result.detail();
//          test:assertEquals(errorDetails.errorCode, 1843, "SQL Error code does not match");
//          test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
//      } else {
//          test:assertFail("Database Error expected.");
//      }

//      checkpanic oracledbClient.close();
//  }

//  @test:Config{
//      enable: true,
//      groups:["insert","insert-time"],
//      dependsOn: [insertIntervalWithInvalidBalType1]
//  }
//  isolated function insertIntervalWithInvalidBalType2() {
//      Client oracledbClient = checkpanic new(user, password, host, port, database);
//      IntervalYearToMonthValue intervalYtoM = new({year:12, month: 34});
//      IntervalDayToSecondValue intervalDtoS = new({ day:1, hour: -55, minute: 34, second: 23.45 });

//      sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
//              COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
//      sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

//      if (result is sql:DatabaseError) {
//          sql:DatabaseErrorDetail errorDetails = result.detail();
//          test:assertEquals(errorDetails.errorCode, 1843, "SQL Error code does not match");
//          test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
//      } else {
//          test:assertFail("Database Error expected.");
//      }

//      checkpanic oracledbClient.close();
//  }

//  // @test:BeforeGroups { value:["insert-bfle"] }
//  // function beforeGroupsFunc() {
//  //     Client oracledbClient = checkpanic new(user, password, host, port, database);
//  //     sql:ExecutionResult result = checkpanic dropTableIfExists("TestBFileTable");
//  //     result = checkpanic oracledbClient->execute("CREATE TABLE TestBFileTable(" +
//  //         "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
//  //         "COL_BFILE  BFILE, " +
//  //         "PRIMARY KEY(PK) "+
//  //         ")"
//  //     );

//  //     checkpanic oracledbClient.close();
//  // }

//  //@test:Config{
//  //    enable: true,
//  //    groups:["insert","insert-bfile"],
//  //    dependsOn: [insertIntervalWithInvalidBalType2]
//  //}
//  //isolated function insertBFile() {
//  //    Client oracledbClient = checkpanic new(user, password, host, port, database);
//  //    BfileValue  bfile = new({ directory: "usr/java/home", file: "test.txt"});
//  //
//  //    sql:ParameterizedQuery insertQuery = `INSERT INTO TestBFileTable(COL_BFILE) VALUES (${bfile})`;
//  //    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);
//  //
//  //    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//  //    var insertId = result.lastInsertId;
//  //    test:assertTrue(insertId is string, "Last Insert id should be string");
//  //
//  //    checkpanic oracledbClient.close();
//  //}
//  //
//  //@test:Config{
//  //    enable: true,
//  //    groups:["insert","insert-bfile"],
//  //    dependsOn: [insertBFile]
//  //}
//  //isolated function insertBFileNull() {
//  //    Client oracledbClient = checkpanic new(user, password, host, port, database);
//  //    BfileValue  bfile = new();
//  //
//  //    sql:ParameterizedQuery insertQuery = `INSERT INTO TestBFileTable(COL_BFILE) VALUES (${bfile})`;
//  //    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);
//  //
//  //    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
//  //    var insertId = result.lastInsertId;
//  //    test:assertTrue(insertId is string, "Last Insert id should be string");
//  //
//  //    checkpanic oracledbClient.close();
//  //}


