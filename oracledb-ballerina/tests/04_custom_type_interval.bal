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

@test:BeforeGroups { value:["insert-time"] }
function beforeInsertTimeFunc() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    sql:ExecutionResult result = check dropTableIfExists("TestDateTimeTable");
    result = check oracledbClient->execute("ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-RR HH:MI:SS AM'");
    result = check oracledbClient->execute("ALTER session set NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-RR HH:MI:SS AM TZR'");
    result = check oracledbClient->execute("CREATE TABLE TestDateTimeTable(" +
        "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
        "COL_INTERVAL_YEAR_TO_MONTH INTERVAL YEAR TO MONTH, "+
        "COL_INTERVAL_DAY_TO_SECOND INTERVAL DAY(9) TO SECOND(9), "+
        "PRIMARY KEY(PK) "+
        ")"
    );

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","insert-time"]
}
function insertIntervalWithString() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    string intervalYtoM = "15-11";
    string intervalDtoS = "200 5:12:45.89";

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
        COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","insert-time"],
    dependsOn: [insertIntervalWithString]
}
function insertIntervalWithBalTypeString() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    IntervalYearToMonthValue intervalYtoM = new("15-11");
    IntervalDayToSecondValue intervalDtoS = new("13 5:34:23.45");

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
            COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","insert-time"],
    dependsOn: [insertIntervalWithBalTypeString]
}
function insertIntervalWithBalType() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    IntervalYearToMonthValue intervalYtoM = new({ years:15, months: 11 });
    IntervalDayToSecondValue intervalDtoS = new({ days:13, hours: 5, minutes: 34, seconds: 23.45 });

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
        COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

 @test:Config {
    enable: true,
    groups:["execute","insert-time"],
    dependsOn: [insertIntervalWithBalType]
 }
 function insertIntervalNull() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    IntervalYearToMonthValue intervalYtoM = new ();
    IntervalDayToSecondValue intervalDtoS = new();


    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
            COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
    sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","insert-time"],
    dependsOn: [insertIntervalNull]
}
function insertIntervalWithInvalidBalType1() returns sql:Error? {
Client oracledbClient = check new(user, password, host, port, database);
    IntervalYearToMonthValue intervalYtoM = new({years:12, months: 340});
    IntervalDayToSecondValue intervalDtoS = new({ days:1, hours: 555, minutes: 34, seconds: 23.45 });

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
            COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1843, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    check oracledbClient.close();
}

@test:Config {
    enable: true,
    groups:["execute","insert-time"],
    dependsOn: [insertIntervalWithInvalidBalType1]
}
function insertIntervalWithInvalidBalType2() returns sql:Error? {
    Client oracledbClient = check new(user, password, host, port, database);
    IntervalYearToMonthValue intervalYtoM = new({years:12, months: 34});
    IntervalDayToSecondValue intervalDtoS = new({ days:1, hours: -55, minutes: 34, seconds: 23.45 });

    sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable(COL_INTERVAL_YEAR_TO_MONTH,
            COL_INTERVAL_DAY_TO_SECOND) VALUES (${intervalYtoM}, ${intervalDtoS})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:DatabaseError) {
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1843, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    check oracledbClient.close();
}

