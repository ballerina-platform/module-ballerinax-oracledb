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

   result = check dropTableIfExists("TestIntervalTable", oracledbClient);
   result = check oracledbClient->execute(`CREATE TABLE TestIntervalTable(
       ID NUMBER,
       COL_YEAR3_TO_MONTH INTERVAL YEAR(3) TO MONTH,
       COL_YEAR3 INTERVAL YEAR(3) TO MONTH,
       COL_MONTH3 INTERVAL YEAR(3) TO MONTH,
       COL_DAY_TO_SECOND3 INTERVAL DAY TO SECOND(3),
       COL_DAY_TO_MINUTE INTERVAL DAY TO SECOND,
       COL_DAY_TO_HOUR INTERVAL DAY(3) TO SECOND,
       COL_DAY3 INTERVAL DAY(3) TO SECOND,
       COL_HOUR_TO_SECOND7 INTERVAL DAY TO SECOND(7),
       COL_HOUR_TO_MINUTE INTERVAL DAY TO SECOND,
       COL_HOUR INTERVAL DAY TO SECOND,
       COL_MINUTE_TO_SECOND INTERVAL DAY TO SECOND,
       COL_MINUTE INTERVAL DAY TO SECOND,
       COL_HOUR3 INTERVAL DAY TO SECOND,
       COL_SECOND2_3 INTERVAL DAY TO SECOND(3),
       PRIMARY KEY(ID)
       )`
   );

   result = check oracledbClient->execute(`INSERT INTO TestIntervalTable(ID, COL_YEAR3_TO_MONTH, COL_YEAR3, COL_MONTH3,
            COL_DAY_TO_SECOND3, COL_DAY_TO_MINUTE, COL_DAY_TO_HOUR, COL_DAY3, COL_HOUR_TO_SECOND7, COL_HOUR_TO_MINUTE,
            COL_HOUR, COL_MINUTE_TO_SECOND, COL_MINUTE, COL_HOUR3, COL_SECOND2_3)
            VALUES (1, INTERVAL '120-3' YEAR(3) TO MONTH, INTERVAL '105' YEAR(3), INTERVAL '500' MONTH(3),
            INTERVAL '11 10:09:08.555' DAY TO SECOND(3), INTERVAL '11 10:09' DAY TO MINUTE, INTERVAL '100 10' DAY(3) TO HOUR,
            INTERVAL '999' DAY(3), INTERVAL '09:08:07.6666666' HOUR TO SECOND(7), INTERVAL '09:30' HOUR TO MINUTE, INTERVAL '40' HOUR,
            INTERVAL '15:30' MINUTE TO SECOND, INTERVAL '30' MINUTE, INTERVAL '250' HOUR(3), INTERVAL '15.6789' SECOND(2,3))`);

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

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertIntervalWithString]
}
isolated function selectAllDateTimeDatatypesWithoutReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE, COL_DATE_ONLY, COL_TIME_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ,
            COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND FROM TestDateTimeTable WHERE pk = ${id}`;
    record{}? data = check queryClient(sqlQuery);
    var expectedData = {
        COL_DATE:"2020-01-05 10:35:10.0",
        COL_DATE_ONLY: "2020-01-05 00:00:00.0",
        COL_TIME_ONLY: "0 11:0:0.0",
        COL_TIMESTAMP:"2020-01-05 10:35:10.0",
        COL_TIMESTAMPTZ:"2020-01-05 10:35:10.0 +5:30",
        COL_INTERVAL_YEAR_TO_MONTH:"15-11",
        COL_INTERVAL_DAY_TO_SECOND:"200 5:12:45.89"
    };
    test:assertEquals(expectedData, data, "Expected and actual mismatch");
}

type DateTimeReturnTypes record {
    time:Civil col_date;
    time:Date col_date_only;
    int col_date_only_as_int;
    time:Utc col_date_only_as_utc;
    time:TimeOfDay col_time_only;
    time:Civil col_timestamp;
    time:Civil col_timestamptz;
    IntervalYearToMonth col_interval_year_to_month;
    IntervalDayToSecond col_interval_day_to_second;
};

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertIntervalWithString]
}
isolated function selectAllDateTimeDatatypesWithReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE, COL_DATE_ONLY, COL_DATE_ONLY as COL_DATE_ONLY_AS_INT,
        COL_DATE_ONLY as COL_DATE_ONLY_AS_UTC, COL_TIME_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ,
        COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND FROM TestDateTimeTable WHERE pk = ${id}`;
    record{}? data = check queryClient(sqlQuery, DateTimeReturnTypes);
    time:Civil dateTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Date dateOnlyTypeRecord = {year: 2020, month: 1, day: 5};
    int col_date_only_as_int = 1578162600000;
    time:Utc dateOnlyAsUtc = [1578162600, 0];
    time:TimeOfDay timeOnlyTypeRecord = {hour: 11, minute: 0, second:0};
    time:Civil timestampTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Civil timestampTzTypeRecord = {utcOffset: {hours: 5, minutes: 30}, timeAbbrev: "+05:30", year: 2020,
                                        month: 1, day: 5, hour: 10, minute: 35, second: 10};
    IntervalYearToMonth intervalYtoMTypeRecord = {years:15, months: 11};
    IntervalDayToSecond intervalDtoSTypeRecord = {days:200, hours: 5, minutes: 12, seconds: 45.089};

    test:assertEquals(dateTypeRecord, data["col_date"], "col_date Expected and actual mismatch");
    test:assertEquals(dateOnlyTypeRecord, data["col_date_only"], "col_date_only Expected and actual mismatch");
    test:assertEquals(timeOnlyTypeRecord, data["col_time_only"], "col_time_only Expected and actual mismatch");
    test:assertEquals(timestampTypeRecord, data["col_timestamp"], "col_timestamp Expected and actual mismatch");
    test:assertEquals(timestampTzTypeRecord, data["col_timestamptz"], "col_timestamptz Expected and actual mismatch");
    test:assertEquals(intervalYtoMTypeRecord, data["col_interval_year_to_month"], "col_interval_year_to_month Expected and actual mismatch");
    test:assertEquals(intervalDtoSTypeRecord, data["col_interval_day_to_second"], "col_interval_day_to_second Expected and actual mismatch");
}

type DateTimeReturnTypes2 record {
    string col_date;
    string col_date_only;
    string col_time_only;
    string col_timestamp;
    string col_timestamptz;
    string col_interval_year_to_month;
    string col_interval_day_to_second;
};

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertIntervalWithString]
}
isolated function selectAllDateTimeDatatypesWithStringReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE, COL_DATE_ONLY, COL_TIME_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ,
     COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND FROM TestDateTimeTable WHERE pk = ${id}`;
    record{}? data = check queryClient(sqlQuery, DateTimeReturnTypes2);

    string dateTypeString = "2020-01-05 10:35:10.0";
    string dateOnlyTypeString = "2020-01-05 00:00:00.0";
    string timeOnlyTypeString = "0 11:0:0.0";
    string timestampTypeString = "2020-01-05 10:35:10.0";
    string timestampTzTypeString = "2020-01-05 10:35:10.0 +5:30";
    string intervalYtoMTypeString = "15-11";
    string intervalDtoSTypeString = "200 5:12:45.89";

    DateTimeReturnTypes2 expectedData = {
        col_date: dateTypeString,
        col_date_only: dateOnlyTypeString,
        col_time_only: timeOnlyTypeString,
        col_timestamp: timestampTypeString,
        col_timestamptz: timestampTzTypeString,
        col_interval_year_to_month: intervalYtoMTypeString,
        col_interval_day_to_second: intervalDtoSTypeString
    };
    test:assertEquals(expectedData, data, "Expected and actual mismatch");
}

@test:Config {
    groups: ["datetime"]
}
isolated function selectAllIntervalsWithoutReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_YEAR3_TO_MONTH, COL_YEAR3, COL_MONTH3, COL_DAY_TO_SECOND3,
                COL_DAY_TO_MINUTE, COL_DAY_TO_HOUR, COL_DAY3, COL_HOUR_TO_SECOND7, COL_HOUR_TO_MINUTE,
                COL_HOUR, COL_MINUTE_TO_SECOND, COL_MINUTE, COL_HOUR3, COL_SECOND2_3 FROM TestIntervalTable
                WHERE ID = ${id}`;
    record{}? data = check queryClient(sqlQuery);
    var expectedData = {
        COL_YEAR3_TO_MONTH: "120-3",
        COL_YEAR3: "105-0",
        COL_MONTH3: "41-8",
        COL_DAY_TO_SECOND3: "11 10:9:8.555",
        COL_DAY_TO_MINUTE: "11 10:9:0.0",
        COL_DAY_TO_HOUR: "100 10:0:0.0",
        COL_DAY3: "999 0:0:0.0",
        COL_HOUR_TO_SECOND7: "0 9:8:7.6666666",
        COL_HOUR_TO_MINUTE: "0 9:30:0.0",
        COL_HOUR: "1 16:0:0.0",
        COL_MINUTE_TO_SECOND: "0 0:15:30.0",
        COL_MINUTE: "0 0:30:0.0",
        COL_HOUR3: "10 10:0:0.0",
        COL_SECOND2_3: "0 0:0:15.679"
    };
    test:assertEquals(expectedData, data, "Expected and actual mismatch");
}
