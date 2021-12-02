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

@test:Config {
   groups:["datetime"]
}
isolated function insertDateTimeTypesAndIntervalsWithString() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string date = "05-JAN-2020 10:35:10 AM";
    string dateOnly = "05-JAN-2020";
    string timestamp = "05-JAN-2020 10:35:10 AM";
    string timestamptz = "05-JAN-2020 10:35:10 AM +05:30";
    string timestamptzl = "05-JAN-2020 10:35:10 AM";
    string intervalYtoM = "15-11";
    string intervalDtoS = "200 5:12:45.89";
    sql:ExecutionResult result = check oracledbClient->execute(
        `ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH:MI:SS AM'`);
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP,
            COL_TIMESTAMPTZ, COL_TIMESTAMPTZL, COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND)
         VALUES (${date}, ${dateOnly}, ${timestamp}, ${timestamptz}, ${timestamptzl}, ${intervalYtoM},
            ${intervalDtoS})`;
    result = check oracledbClient->execute(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    int|string? insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
    check oracledbClient.close();
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertDateTimeTypesAndIntervalsWithString]
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
    string intervalYtoM = "15-11";
    string intervalDtoS = "13 5:34:23.45";
    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(
        COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ, COL_INTERVAL_YEAR_TO_MONTH,
        COL_INTERVAL_DAY_TO_SECOND) VALUES (${dateTimeValue}, ${dateValue}, ${timestampValue}, ${dateTimeValueForTz}, ${intervalYtoM},
        ${intervalDtoS})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    int|string? insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalWithBalTypeString]
}
isolated function insertIntervalWithBalType() returns sql:Error? {
   IntervalYearToMonth intervalYtoM = {years:15, months: 11};
   IntervalDayToSecond intervalDtoS = {days:13, hours: 5, minutes: 34, seconds: 23.45};
   sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
       COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   int|string? insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
   groups:["datetime"],
   dependsOn: [insertIntervalWithBalType]
}
isolated function insertIntervalNull() returns sql:Error? {
   sql:DateValue date = new ();
   sql:TimestampValue timestamp = new ();
   sql:TimestampValue timestamptz = new ();
   sql:TimestampValue timestamptzl = new ();
   IntervalYearToMonth? intervalYtoM = ();
   IntervalDayToSecond? intervalDtoS = ();
   sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(
       COL_DATE, COL_TIMESTAMP, COL_TIMESTAMPTZ, COL_TIMESTAMPTZL,
       COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND) VALUES (
       ${date}, ${timestamp}, ${timestamptz}, ${timestamptzl}, ${intervalYtoM}, ${intervalDtoS})`;
   sql:ExecutionResult result = check executeQuery(insertQuery);
   test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
   int|string? insertId = result.lastInsertId;
   test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertDateTimeTypesAndIntervalsWithString]
}
isolated function selectAllDateTimeDatatypesWithoutReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ,
            COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND FROM TestDateTimeTable WHERE pk = ${id}`;
    record{}? data = check queryClient(sqlQuery);
    var expectedData = {
        COL_DATE:"2020-01-05 10:35:10.0",
        COL_DATE_ONLY: "2020-01-05 00:00:00.0",
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
    time:Civil col_timestamp;
    time:Civil col_timestamptz;
    IntervalYearToMonth col_interval_year_to_month;
    IntervalDayToSecond col_interval_day_to_second;
};

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertDateTimeTypesAndIntervalsWithString]
}
isolated function selectAllDateTimeDatatypesWithReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE, COL_DATE_ONLY, COL_DATE_ONLY as COL_DATE_ONLY_AS_INT,
        COL_DATE_ONLY as COL_DATE_ONLY_AS_UTC, COL_TIMESTAMP, COL_TIMESTAMPTZ,
        COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND FROM TestDateTimeTable WHERE pk = ${id}`;
    record{}? data = check queryClient(sqlQuery, DateTimeReturnTypes);
    time:Civil dateTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Date dateOnlyTypeRecord = {year: 2020, month: 1, day: 5};
    time:Civil timestampTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Civil timestampTzTypeRecord = {utcOffset: {hours: 5, minutes: 30}, timeAbbrev: "+05:30", year: 2020,
                                        month: 1, day: 5, hour: 10, minute: 35, second: 10};
    IntervalYearToMonth intervalYtoMTypeRecord = {years:15, months: 11, sign: 1};
    IntervalDayToSecond intervalDtoSTypeRecord = {days:200, hours: 5, minutes: 12, seconds: 45.89, sign: 1};

    test:assertEquals(dateTypeRecord, data["col_date"], "col_date Expected and actual mismatch");
    test:assertEquals(dateOnlyTypeRecord, data["col_date_only"], "col_date_only Expected and actual mismatch");
    test:assertEquals(timestampTypeRecord, data["col_timestamp"], "col_timestamp Expected and actual mismatch");
    test:assertEquals(timestampTzTypeRecord, data["col_timestamptz"], "col_timestamptz Expected and actual mismatch");
    test:assertEquals(intervalYtoMTypeRecord, data["col_interval_year_to_month"], "col_interval_year_to_month Expected and actual mismatch");
    test:assertEquals(intervalDtoSTypeRecord, data["col_interval_day_to_second"], "col_interval_day_to_second Expected and actual mismatch");
}

type DateTimeReturnTypes2 record {
    string col_date;
    string col_date_only;
    string col_timestamp;
    string col_timestamptz;
    string col_interval_year_to_month;
    string col_interval_day_to_second;
};

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertDateTimeTypesAndIntervalsWithString]
}
isolated function selectAllDateTimeDatatypesWithStringReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ,
     COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND FROM TestDateTimeTable WHERE pk = ${id}`;
    record{}? data = check queryClient(sqlQuery, DateTimeReturnTypes2);

    string dateTypeString = "2020-01-05 10:35:10.0";
    string dateOnlyTypeString = "2020-01-05 00:00:00.0";
    string timestampTypeString = "2020-01-05 10:35:10.0";
    string timestampTzTypeString = "2020-01-05 10:35:10.0 +5:30";
    string intervalYtoMTypeString = "15-11";
    string intervalDtoSTypeString = "200 5:12:45.89";

    DateTimeReturnTypes2 expectedData = {
        col_date: dateTypeString,
        col_date_only: dateOnlyTypeString,
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
isolated function selectIntervalYMWithoutReturnType() returns error? {
    int id = 1;
    IntervalYearToMonth interval = {years:120, months:3};
    IntervalYearToMonth interval2 = {years:105};
    IntervalYearToMonth interval3 = {months:500};
    sql:ParameterizedQuery sqlQuery = `SELECT COL_YEAR3_TO_MONTH, COL_YEAR3, COL_MONTH3 FROM TestIntervalTable
                WHERE COL_YEAR3_TO_MONTH = ${interval} AND COL_YEAR3 = ${interval2} AND COL_MONTH3 = ${interval3} AND ID = ${id}`;
    record{}? data = check queryClient(sqlQuery);
    var expectedData = {
        COL_YEAR3_TO_MONTH: "120-3",
        COL_YEAR3: "105-0",
        COL_MONTH3: "41-8"
    };
    test:assertEquals(expectedData, data, "Expected and actual mismatch");
}

@test:Config {
    groups: ["datetime"]
}
isolated function selectAllIntervalDSWithoutReturnType() returns error? {
    int id = 1;
    IntervalDayToSecond intervalVal = {days:11, hours:10, minutes:9, seconds:8.555};
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DAY_TO_SECOND3,
                COL_DAY_TO_MINUTE, COL_DAY_TO_HOUR, COL_DAY3, COL_HOUR_TO_SECOND7, COL_HOUR_TO_MINUTE,
                COL_HOUR, COL_MINUTE_TO_SECOND, COL_MINUTE, COL_HOUR3, COL_SECOND2_3 FROM TestIntervalTable
                WHERE COL_DAY_TO_SECOND3 = ${intervalVal} AND ID = ${id}`;
    record{}? data = check queryClient(sqlQuery);
    var expectedData = {
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

@test:Config {
   groups:["datetime"]
}
isolated function insertNegativeIntervalsWithDifferentBalTypes() returns sql:Error? {
    IntervalYearToMonth intY3M = {years: 120, months: 11, sign: -1};
    IntervalYearToMonth intY3 = {years: 145, sign: -1};
    IntervalYearToMonth intM3 = {months: 311, sign: -1};

    IntervalDayToSecond intDS3 = {days: 11, hours: 10, minutes: 9, seconds: 8.555, sign: -1};
    IntervalDayToSecond intDM = {days: 11, hours: 10, minutes: 9, sign: -1};
    IntervalDayToSecond intD3H = {days: 200, hours: 110, sign: -1};
    IntervalDayToSecond intD3 = {days:167, sign: -1};
    IntervalDayToSecond intHS7 = {hours:10, minutes:9, seconds:8.555666, sign: -1};
    IntervalDayToSecond intHM = {hours:10, minutes:9, sign: -1};
    IntervalDayToSecond intH = {hours:12, sign: -1};
    IntervalDayToSecond intMS = {minutes:9, seconds:30, sign: -1};
    IntervalDayToSecond intM = {minutes:9, sign: -1};
    IntervalDayToSecond intH3 = {hours:810, sign: -1};
    IntervalDayToSecond intS = {seconds:15.679, sign: -1};

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestIntervalTable(ID, COL_YEAR3_TO_MONTH, COL_YEAR3, COL_MONTH3,
        COL_DAY_TO_SECOND3, COL_DAY_TO_MINUTE, COL_DAY_TO_HOUR, COL_DAY3, COL_HOUR_TO_SECOND7, COL_HOUR_TO_MINUTE,
        COL_HOUR, COL_MINUTE_TO_SECOND, COL_MINUTE, COL_HOUR3, COL_SECOND2_3)
        VALUES (2, ${intY3M}, ${intY3}, ${intM3}, ${intDS3}, ${intDM}, ${intD3H}, ${intD3}, ${intHS7}, ${intHM},
         ${intH}, ${intMS}, ${intM}, ${intH3}, ${intS})`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    int|string? insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertNegativeIntervalsWithDifferentBalTypes]
}
isolated function selectAllNegativeIntervalsWithoutReturnType() returns error? {
    int id = 2;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_YEAR3_TO_MONTH, COL_YEAR3, COL_MONTH3, COL_DAY_TO_SECOND3,
                COL_DAY_TO_MINUTE, COL_DAY_TO_HOUR, COL_DAY3, COL_HOUR_TO_SECOND7, COL_HOUR_TO_MINUTE,
                COL_HOUR, COL_MINUTE_TO_SECOND, COL_MINUTE, COL_HOUR3, COL_SECOND2_3 FROM TestIntervalTable
                WHERE ID = ${id}`;
    record{}? data = check queryClient(sqlQuery);

    var expectedData = {
        COL_YEAR3_TO_MONTH: "-120-11",
        COL_YEAR3: "-145-0",
        COL_MONTH3: "-25-11",
        COL_DAY_TO_SECOND3: "-11 10:9:8.555",
        COL_DAY_TO_MINUTE: "-11 10:9:0.0",
        COL_DAY_TO_HOUR: "-204 14:0:0.0",
        COL_DAY3: "-167 0:0:0.0",
        COL_HOUR_TO_SECOND7: "-0 10:9:8.555666",
        COL_HOUR_TO_MINUTE: "-0 10:9:0.0",
        COL_HOUR: "-0 12:0:0.0",
        COL_MINUTE_TO_SECOND: "-0 0:9:30.0",
        COL_MINUTE: "-0 0:9:0.0",
        COL_HOUR3: "-33 18:0:0.0",
        COL_SECOND2_3: "-0 0:0:15.679"
    };
    test:assertEquals(expectedData, data, "Expected and actual mismatch");
}

type IntervalReturnTypes record {
    IntervalYearToMonth COL_YEAR3_TO_MONTH;
    IntervalYearToMonth COL_YEAR3;
    IntervalYearToMonth COL_MONTH3;
    IntervalDayToSecond COL_DAY_TO_SECOND3;
    IntervalDayToSecond COL_DAY_TO_MINUTE;
    IntervalDayToSecond COL_DAY_TO_HOUR;
    IntervalDayToSecond COL_DAY3;
    IntervalDayToSecond COL_HOUR_TO_SECOND7;
    IntervalDayToSecond COL_HOUR_TO_MINUTE;
    IntervalDayToSecond COL_HOUR;
    IntervalDayToSecond COL_MINUTE_TO_SECOND;
    IntervalDayToSecond COL_MINUTE;
    IntervalDayToSecond COL_HOUR3;
    IntervalDayToSecond COL_SECOND2_3;
};

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertNegativeIntervalsWithDifferentBalTypes]
}
isolated function selectAllNegativeIntervalsWithReturnType() returns error? {
    int id = 2;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_YEAR3_TO_MONTH, COL_YEAR3, COL_MONTH3, COL_DAY_TO_SECOND3,
        COL_DAY_TO_MINUTE, COL_DAY_TO_HOUR, COL_DAY3, COL_HOUR_TO_SECOND7, COL_HOUR_TO_MINUTE,
        COL_HOUR, COL_MINUTE_TO_SECOND, COL_MINUTE, COL_HOUR3, COL_SECOND2_3 FROM TestIntervalTable
        WHERE ID = ${id}`;
    record{}? data = check queryClient(sqlQuery, IntervalReturnTypes);

    IntervalYearToMonth intY3M = {years: 120, months: 11, sign: -1};
    IntervalYearToMonth intY3 = {years: 145, months: 0, sign: -1};
    IntervalYearToMonth intM3 = {years: 25, months: 11, sign: -1};

    IntervalDayToSecond intDS3 = {days: 11, hours: 10, minutes: 9, seconds: 8.555, sign: -1};
    IntervalDayToSecond intDM = {days: 11, hours: 10, minutes: 9, seconds: 0.0, sign: -1};
    IntervalDayToSecond intD3H = {days:204, hours:14, minutes: 0, seconds: 0.0, sign: -1};
    IntervalDayToSecond intD3 = {days: 167, hours:0, minutes: 0, seconds: 0.0, sign: -1};
    IntervalDayToSecond intHS7 = {days: 0, hours: 10, minutes: 9, seconds: 8.555666, sign: -1};
    IntervalDayToSecond intHM = {days:0, hours: 10, minutes: 9, seconds: 0.0, sign: -1};
    IntervalDayToSecond intH = {days:0, hours: 12, minutes: 0, seconds: 0.0, sign: -1};
    IntervalDayToSecond intMS = {days:0, hours: 0, minutes: 9, seconds: 30.0, sign: -1};
    IntervalDayToSecond intM = {days: 0, hours: 0, minutes: 9, seconds: 0.0, sign: -1};
    IntervalDayToSecond intH3 = {days: 33, hours: 18, minutes: 0, seconds: 0.0, sign: -1};
    IntervalDayToSecond intS = {days: 0, hours: 0, minutes: 0, seconds: 15.679, sign: -1};

    IntervalReturnTypes expectedData = {
        COL_YEAR3_TO_MONTH: intY3M,
        COL_YEAR3: intY3,
        COL_MONTH3: intM3,
        COL_DAY_TO_SECOND3: intDS3,
        COL_DAY_TO_MINUTE: intDM,
        COL_DAY_TO_HOUR: intD3H,
        COL_DAY3: intD3,
        COL_HOUR_TO_SECOND7: intHS7,
        COL_HOUR_TO_MINUTE: intHM,
        COL_HOUR: intH,
        COL_MINUTE_TO_SECOND: intMS,
        COL_MINUTE: intM,
        COL_HOUR3: intH3,
        COL_SECOND2_3: intS
    };
    test:assertEquals(expectedData, data, "Expected data and actual are mismatched");
}

type InvalidTimestampRecord record {
    int id;
};

type InvalidTimestampReturnType record {
    InvalidTimestampRecord col_date;
};

@test:Config {
    groups: ["datetime"],
    dependsOn: [insertDateTimeTypesAndIntervalsWithString]
}
isolated function selectTimestampWithInvalidReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT COL_DATE FROM TestDateTimeTable WHERE pk = ${id}`;
    record {}|error? data = queryClient(sqlQuery, InvalidTimestampReturnType);
    test:assertTrue(data is error);
    if data is sql:ApplicationError {
        test:assertEquals(data.message(),
                    "Error when iterating the SQL result. The ballerina type expected for 'SQL Timestamp' type " +
                    "are 'time:Civil', and 'time:Date' but found type 'InvalidTimestampRecord'.");
    } else {
        test:assertFail("ApplicationError Error expected.");
    }
}
