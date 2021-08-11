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
import ballerina/time;

@test:BeforeGroups { value:["datetime"] }
isolated function beforeInsertTimeFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check dropTableIfExists("TestDateTimeTable", oracledbClient);
    result = check oracledbClient->execute(`ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH:MI:SS AM'`);
    result = check oracledbClient->execute(`ALTER session set NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-YYYY HH:MI:SS AM TZR'`);
    result = check oracledbClient->execute(`CREATE TABLE TestDateTimeTable(
        PK NUMBER GENERATED ALWAYS AS IDENTITY,
        COL_DATE  DATE,
        COL_DATE_ONLY  DATE,
        COL_TIME_ONLY  INTERVAL DAY(0) TO SECOND,
        COL_TIMESTAMP  TIMESTAMP (9),
        COL_TIMESTAMPTZ  TIMESTAMP (9) WITH TIME ZONE,
        COL_TIMESTAMPTZL  TIMESTAMP (9) WITH LOCAL TIME ZONE,
        COL_INTERVAL_YEAR_TO_MONTH INTERVAL YEAR TO MONTH,
        COL_INTERVAL_DAY_TO_SECOND INTERVAL DAY(9) TO SECOND(9),
        PRIMARY KEY(PK)
        )`
    );
    check oracledbClient.close();
}

@test:Config {
   groups:["datetime"]
}
isolated function insertIntervalWithString() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string date = "05-JAN-2020 10:35:10 AM";
    string dateOnly = "05-JAN-2020";
    string timeOnly = "0 11:00:00";
    string timestamp = "05-JAN-2020 10:35:10 AM";
    string timestamptz = "05-JAN-2020 10:35:10 AM +05:30";
    string timestamptzl = "05-JAN-2020 10:35:10 AM";
    string intervalYtoM = "15-11";
    string intervalDtoS = "200 5:12:45.89";
    sql:ExecutionResult result = check oracledbClient->execute(
        `ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH:MI:SS AM'`);
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_DATE, COL_DATE_ONLY, COL_TIME_ONLY,
         COL_TIMESTAMP, COL_TIMESTAMPTZ, COL_TIMESTAMPTZL, COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND)
         VALUES (${date}, ${dateOnly}, ${timeOnly}, ${timestamp}, ${timestamptz}, ${timestamptzl}, ${intervalYtoM},
         ${intervalDtoS})`;
    result = check oracledbClient->execute(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
    check oracledbClient.close();
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalWithString]
}
isolated function insertIntervalWithBalTypeString() returns sql:Error? {
    time:Civil date = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    sql:DateTimeValue dateTimeValue = new (date);
    time:Date dateOnly = {year: 2017, month: 12, day: 18};
    sql:DateValue dateValue = new (dateOnly);
    time:Utc utc = [1400000000, 0.5];
    sql:TimestampValue timestampValue = new(utc);
    time:Civil timestampWTz = {utcOffset: {hours: 5, minutes: 30}, timeAbbrev: "+05:30", year: 2020,
                                 month: 1, day: 5, hour: 10, minute: 35, second: 10};
    sql:DateTimeValue dateTimeValueForTz = new (timestampWTz);
    IntervalYearToMonthValue intervalYtoM = new("15-11");
    IntervalDayToSecondValue intervalDtoS = new("13 5:34:23.45");
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(
        COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ, COL_INTERVAL_YEAR_TO_MONTH,
        COL_INTERVAL_DAY_TO_SECOND) VALUES (${dateTimeValue}, ${dateValue}, ${timestampValue}, ${dateTimeValueForTz}, ${intervalYtoM},
        ${intervalDtoS})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalWithBalTypeString]
}
isolated function insertIntervalWithBalType() returns sql:Error? {
   IntervalYearToMonthValue intervalYtoM = new({ years:15, months: 11 });
   IntervalDayToSecondValue intervalDtoS = new({ days:13, hours: 5, minutes: 34, seconds: 23.45 });
   sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
       COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalWithBalType]
}
isolated function insertIntervalNull() returns sql:Error? {
   sql:DateValue date = new();
   sql:TimestampValue timestamp = new();
   sql:TimestampValue timestamptz = new();
   sql:TimestampValue timestamptzl = new();
   IntervalYearToMonthValue intervalYtoM = new ();
   IntervalDayToSecondValue intervalDtoS = new();
   sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(
       COL_DATE, COL_TIMESTAMP, COL_TIMESTAMPTZ, COL_TIMESTAMPTZL,
       COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND) VALUES (
       ${date}, ${timestamp}, ${timestamptz}, ${timestamptzl}, ${intervalYtoM}, ${intervalDtoS})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   var insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalNull]
}
isolated function insertIntervalWithInvalidBalType1() returns sql:Error? {
   IntervalYearToMonthValue intervalYtoM = new({years:12, months: 340});
   IntervalDayToSecondValue intervalDtoS = new({ days:1, hours: 555, minutes: 34, seconds: 23.45 });

   sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
           COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
   sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
   if (result is sql:DatabaseError) {
       sql:DatabaseErrorDetail errorDetails = result.detail();
       test:assertEquals(errorDetails.errorCode, 1843, "SQL Error code does not match");
       test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
   } else {
       test:assertFail("Database Error expected.");
   }
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalWithInvalidBalType1]
}
isolated function insertIntervalWithInvalidBalType2() returns sql:Error? {
   IntervalYearToMonthValue intervalYtoM = new({years:12, months: 34});
   IntervalDayToSecondValue intervalDtoS = new({ days:1, hours: -55, minutes: 34, seconds: 23.45 });
   sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
           COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
   sql:ExecutionResult|sql:Error result = executeQuery(insertQuery);
   if (result is sql:DatabaseError) {
       sql:DatabaseErrorDetail errorDetails = result.detail();
       test:assertEquals(errorDetails.errorCode, 1843, "SQL Error code does not match");
       test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
   } else {
       test:assertFail("Database Error expected.");
   }
}
