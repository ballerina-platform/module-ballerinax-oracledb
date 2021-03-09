// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
// import ballerina/io;

@test:BeforeGroups { value:["insert-time"] }
function beforeGroupsFunc() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    sql:ExecutionResult result = checkpanic dropTableIfExists("DATETIME_TEST");
    result = checkpanic oracledbClient->execute("ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-RR HH:MI:SS AM'");
    result = checkpanic oracledbClient->execute("ALTER session set NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-RR HH:MI:SS AM TZR'");
    result = checkpanic oracledbClient->execute("CREATE TABLE DATETIME_TEST(" +
        "PK NUMBER GENERATED ALWAYS AS IDENTITY, "+
        "COL_DATE  DATE, " +
        "COL_TIMESTAMP_1  TIMESTAMP (9), " +
        "COL_TIMESTAMP_2  TIMESTAMP (9) WITH TIME ZONE, " +
        "COL_TIMESTAMP_3  TIMESTAMP (9) WITH LOCAL TIME ZONE, " +
        "COL_INTERVAL_YEAR_TO_MONTH INTERVAL YEAR TO MONTH, "+
        "COL_INTERVAL_DAY_TO_SECOND INTERVAL DAY(9) TO SECOND(9), "+
        "PRIMARY KEY(PK) "+
        ")"
    );
    _ = checkpanic oracledbClient.close();
}

@test:Config{
    enable: true,
    groups:["insert","insert-time"]
}
function insertIntervalYearToMonthWithString() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    string interval = "15-11";

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    _ = checkpanic oracledbClient.close();
}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithString]
}
function insertIntervalYearToMonthWithBalTypeString() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new("15-11");

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    _ = checkpanic oracledbClient.close();

}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithBalTypeString]
}
function insertIntervalYearToMonthWithBalType1() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new({year:15, month: 11});

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    _ = checkpanic oracledbClient.close();

}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithBalType1]
}
function insertIntervalYearToMonthWithBalType2() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new({year:15, month: 11});

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    _ = checkpanic oracledbClient.close();

}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithBalType2]
}
function insertIntervalYearToMonthWithBalType3() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new({year:15, month: "11"});

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    _ = checkpanic oracledbClient.close();

}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithBalType3]
}
function insertIntervalYearToMonthWithNullBalType() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new ();

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult result = checkpanic oracledbClient->execute(insertQuery);

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");

    _ = checkpanic oracledbClient.close();
}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithNullBalType]
}
function insertIntervalYearToMonthWithEmptyBalType() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new({year:"", month: ""});

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:DatabaseError) {
        test:assertTrue(result.message().startsWith("Error while executing SQL query: INSERT INTO DATETIME_TEST" + 
                        "(COL_INTERVAL_YEAR_TO_MONTH) VALUES ( ? ). ORA-01867: the interval is invalid"), 
                        "Error message does not match, actual :'" + result.message() + "'");
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1867, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    _ = checkpanic oracledbClient.close();
}

@test:Config{
    enable: true,
    groups:["insert","insert-time"],
    dependsOn: [insertIntervalYearToMonthWithEmptyBalType]
}
function insertIntervalYearToMonthWithInvalidBalType() {
    Client oracledbClient = checkpanic new(user, password, host, port, database, options);
    IntervalYearToMonthValue interval = new({year:"A", month: "1"});

    sql:ParameterizedQuery insertQuery = `INSERT INTO DATETIME_TEST(COL_INTERVAL_YEAR_TO_MONTH) VALUES (${interval})`;
    sql:ExecutionResult|sql:Error result = oracledbClient->execute(insertQuery);

    if (result is sql:DatabaseError) {
        test:assertTrue(result.message().startsWith("Error while executing SQL query: INSERT INTO DATETIME_TEST" + 
                        "(COL_INTERVAL_YEAR_TO_MONTH) VALUES ( ? ). ORA-01867: the interval is invalid"), 
                        "Error message does not match, actual :'" + result.message() + "'");
        sql:DatabaseErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.errorCode, 1867, "SQL Error code does not match");
        test:assertEquals(errorDetails.sqlState, "22008", "SQL Error state does not match");
    } else {
        test:assertFail("Database Error expected.");
    }

    _ = checkpanic oracledbClient.close();
}