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
import ballerina/jballerina.java;
import ballerina/time;

type StringDataForCall record {
    string COL_CHAR;
    string COL_NCHAR;
    string COL_VARCHAR2;
    string COL_VARCHAR;
    string COL_NVARCHAR2;
};

type StringVarDataForCall record {
    string COL_VARCHAR2;
    string COL_VARCHAR;
    string COL_NVARCHAR2;
};

type StringDataSingle record {
    string varchar_type;
};

@test:BeforeGroups { value:["procedures"] }
isolated function beforeProcCallFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check dropTableIfExists("CallStringTypes", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE CallStringTypes (
        id NUMBER,
        col_char CHAR(5),
        col_nchar NCHAR(5),
        col_varchar2  VARCHAR2(255),
        col_varchar  VARCHAR(255),
        col_nvarchar2 NVARCHAR2(255),
        PRIMARY KEY (id)
        )`
    );
    result = check oracledbClient->execute(`INSERT INTO CallStringTypes(
        id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)
        VALUES (1, 'test0', 'test1', 'test2', 'test3', 'test4')`
    );

    result = check dropTableIfExists("CallNumericTypes", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE CallNumericTypes (
        id NUMBER,
        col_number  NUMBER,
        col_float  FLOAT,
        col_binary_float BINARY_FLOAT,
        col_binary_double BINARY_DOUBLE,
        PRIMARY KEY (id)
        )`
    );
    result = check oracledbClient->execute(`INSERT INTO CallNumericTypes(
        id, col_number, col_float, col_binary_float, col_binary_double)
        VALUES (1, 2147483647, 21474.83647, 21.47483647, 21474836.47)`
    );

    result = check dropTableIfExists("CallComplexTypes", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE CallComplexTypes(
        id NUMBER,
        col_xml XMLType,
        PRIMARY KEY (id)
        )`
    );
    result = check oracledbClient->execute( `INSERT INTO CallComplexTypes (id, col_xml)
        VALUES(1, XMLType('<key>value</key>'))`);

    result = check dropTableIfExists("CallDateTimeTypes", oracledbClient);
    result = check oracledbClient->execute(`ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH:MI:SS AM'`);
    result = check oracledbClient->execute(`ALTER session set NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-YYYY HH:MI:SS AM TZR'`);
    result = check oracledbClient->execute(`CREATE TABLE CallDateTimeTypes(
        id NUMBER,
        col_date DATE,
        col_date_only DATE,
        col_timestamp TIMESTAMP,
        col_timestamptz TIMESTAMP WITH TIME ZONE,
        col_interval_year_to_month INTERVAL YEAR TO MONTH,
        col_interval_day_to_second INTERVAL DAY TO SECOND,
        PRIMARY KEY(id)
        )`
    );
    result = check oracledbClient->execute(`INSERT INTO CallDateTimeTypes(ID, COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP,
                    COL_TIMESTAMPTZ, COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND)
                    VALUES (1, '05-JAN-2020 10:35:10 AM','05-JAN-2020','05-JAN-2020 10:35:10 AM',
                    '05-JAN-2020 10:35:10 AM +05:30','15-11', '20 11:21:24.45')`);

    check oracledbClient.close();
    check createProcedures();
}

isolated function createProcedures() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check oracledbClient->execute(
            `CREATE OR REPLACE PROCEDURE InsertStringData(p_id IN NUMBER,
            p_col_char IN CHAR, p_col_nchar IN NCHAR,
            p_col_varchar2 IN VARCHAR2, p_col_varchar IN VARCHAR,
            p_col_nvarchar2 IN NVARCHAR2)
            AS BEGIN
            INSERT INTO CallStringTypes(id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)
            VALUES (p_id, p_col_char, p_col_nchar, p_col_varchar2, p_col_varchar, p_col_nvarchar2);
            END;`
        );

    result = check oracledbClient->execute(
        `CREATE OR REPLACE PROCEDURE SelectStringData(p_col_char OUT CHAR, p_col_nchar OUT NCHAR,
        p_col_varchar2 OUT VARCHAR2, p_col_varchar OUT VARCHAR, p_col_nvarchar2 OUT NVARCHAR2)
        AS BEGIN
        SELECT col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2 INTO
        p_col_char, p_col_nchar, p_col_varchar2, p_col_varchar, p_col_nvarchar2
        FROM CallStringTypes where id = 1;
        END;`
    );

    result = check oracledbClient->execute(
        `CREATE OR REPLACE PROCEDURE InOutStringData(p_id IN OUT NUMBER,
        p_col_varchar2 IN OUT VARCHAR2, p_col_varchar IN OUT VARCHAR,
        p_col_nvarchar2 IN OUT NVARCHAR2)
        AS BEGIN
        INSERT INTO CallStringTypes(id, col_varchar2, col_varchar, col_nvarchar2)
         VALUES (p_id, p_col_varchar2, p_col_varchar, p_col_nvarchar2);
        SELECT col_varchar2, col_varchar, col_nvarchar2 INTO
        p_col_varchar2, p_col_varchar, p_col_nvarchar2
        FROM CallStringTypes where id = 1;
        END;`
    );

    result = check oracledbClient->execute(
        `CREATE OR REPLACE PROCEDURE SelectNumericDataWithOutParams(
        p_id IN NUMBER, p_col_number OUT NUMBER, p_col_float OUT FLOAT, p_col_binary_float OUT BINARY_FLOAT,
        p_col_binary_double OUT BINARY_DOUBLE)
        AS BEGIN
        SELECT col_number, col_float, col_binary_float, col_binary_double INTO
        p_col_number, p_col_float, p_col_binary_float, p_col_binary_double
        FROM CallNumericTypes where id = p_id;
        END;`
    );

    result = check oracledbClient->execute(
        `CREATE OR REPLACE PROCEDURE SelectComplexDataWithOutParams(
        p_id IN NUMBER, p_col_xml OUT XMLType)
        AS BEGIN
        SELECT col_xml INTO p_col_xml FROM CallComplexTypes where id = p_id;
        END;`
    );

    result = check oracledbClient->execute(
        `CREATE OR REPLACE PROCEDURE SelectDateTimesWithOutParams(
        p_id IN NUMBER, p_col_date OUT DATE, p_col_date_only OUT DATE, p_col_timestamp OUT TIMESTAMP,
        p_col_timestamptz OUT TIMESTAMP WITH TIME ZONE, p_col_interval_year_to_month OUT INTERVAL YEAR TO MONTH,
        p_col_interval_day_to_second OUT INTERVAL DAY TO SECOND)
        AS BEGIN
        SELECT col_date INTO p_col_date FROM CallDateTimeTypes where id = p_id;
        SELECT col_date_only INTO p_col_date_only FROM CallDateTimeTypes where id = p_id;
        SELECT col_timestamp INTO p_col_timestamp FROM CallDateTimeTypes where id = p_id;
        SELECT col_timestamptz INTO p_col_timestamptz FROM CallDateTimeTypes where id = p_id;
        SELECT col_interval_year_to_month INTO p_col_interval_year_to_month FROM CallDateTimeTypes where id = p_id;
        SELECT col_interval_day_to_second INTO p_col_interval_day_to_second FROM CallDateTimeTypes where id = p_id;
        END;`
    );

    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithStringTypes() returns @tainted record {}|error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ProcedureCallResult ret = check oracledbClient->call(`{call InsertStringData(2,'test0', 'test1', 'test2',
        'test3', 'test4')}`);
    sql:ParameterizedQuery sqlQuery = `SELECT col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2 from CallStringTypes
    where id = 2`;

    StringDataForCall expectedDataRow = {
        COL_CHAR: "test0",
        COL_NCHAR: "test1",
        COL_VARCHAR2: "test2",
        COL_VARCHAR: "test3",
        COL_NVARCHAR2: "test4"
    };
    test:assertEquals(check callQueryClient(oracledbClient, sqlQuery), expectedDataRow,
        "Call procedure insert and query did not match.");
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypes]
}
isolated function testCallWithStringTypesInParams() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string col_char = "test0";
    string col_nchar = "test1";
    string col_varchar2 = "test2";
    string col_varchar = "test3";
    string col_nvarchar2 = "test4";

    var ret = check oracledbClient->call(`{call InsertStringData(3, ${col_char}, ${col_nchar},
        ${col_varchar2}, ${col_varchar}, ${col_nvarchar2})}`);

    sql:ParameterizedQuery sqlQuery = `SELECT col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2
                   from CallStringTypes where id = 3`;

    StringDataForCall expectedDataRow = {
        COL_CHAR: "test0",
        COL_NCHAR: "test1",
        COL_VARCHAR2: "test2",
        COL_VARCHAR: "test3",
        COL_NVARCHAR2: "test4"
    };
    test:assertEquals(check callQueryClient(oracledbClient, sqlQuery), expectedDataRow,
        "Call procedure insert and query did not match.");
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesInParams]
}
isolated function testCallWithStringTypesOutParams() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:CharOutParameter col_char = new();
    sql:NCharOutParameter col_nchar = new();
    sql:VarcharOutParameter col_varchar2 = new();
    sql:VarcharOutParameter col_varchar = new();
    sql:NVarcharOutParameter col_nvarchar2 = new();

    sql:ParameterizedCallQuery query = `{CALL SelectStringData(${col_char}, ${col_nchar}, ${col_varchar2},
        ${col_varchar}, ${col_nvarchar2})}`;
    sql:ProcedureCallResult ret = check oracledbClient->call(query);

    StringDataForCall expectedDataRow = {
        COL_CHAR: "test0",
        COL_NCHAR: "test1",
        COL_VARCHAR2: "test2",
        COL_VARCHAR: "test3",
        COL_NVARCHAR2: "test4"
    };
    test:assertEquals((check col_char.get(string)).trim(), expectedDataRow.COL_CHAR);
    test:assertEquals((check col_nchar.get(string)).trim(), expectedDataRow.COL_NCHAR);
    test:assertEquals((check col_varchar2.get(string)).trim(), expectedDataRow.COL_VARCHAR2);
    test:assertEquals((check col_varchar.get(string)).trim(), expectedDataRow.COL_VARCHAR);
    test:assertEquals((check col_nvarchar2.get(string)).trim(), expectedDataRow.COL_NVARCHAR2);

    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesOutParams]
}
isolated function testCallWithStringTypesInOutParams() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int id = 4;
    sql:InOutParameter col_varchar2 = new("test7");
    sql:InOutParameter col_varchar = new("test8");
    sql:InOutParameter col_nvarchar2 = new("test9");

    sql:ParameterizedCallQuery query = `{CALL InOutStringData(${id}, ${col_varchar2}, ${col_varchar},
        ${col_nvarchar2})}`;
    sql:ProcedureCallResult ret = check oracledbClient->call(query);

    string exp_col_varchar2 = "test2";
    string exp_col_varchar = "test3";
    string exp_col_nvarchar2 = "test4";

    test:assertEquals((check col_varchar2.get(string)).trim(), exp_col_varchar2);
    test:assertEquals((check col_varchar.get(string)).trim(), exp_col_varchar);
    test:assertEquals((check col_nvarchar2.get(string)).trim(), exp_col_nvarchar2);

    sql:ParameterizedQuery sqlQuery = `SELECT col_varchar2, col_varchar, col_nvarchar2 from CallStringTypes where id = 4`;

    StringVarDataForCall expectedDataRow = {
        COL_VARCHAR2: "test7",
        COL_VARCHAR: "test8",
        COL_NVARCHAR2: "test9"
    };
    test:assertEquals(check callQueryClient(oracledbClient, sqlQuery), expectedDataRow,
        "Call procedure insert and query did not match.");

    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithNumericTypesOutParams() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new(1);
    sql:NumericOutParameter paraNumber = new;
    sql:FloatOutParameter paraFloat = new;
    sql:FloatOutParameter paraBinFloat = new;
    sql:DoubleOutParameter paraBinDouble = new;

    var ret = check oracledbClient->call(
        `{call SelectNumericDataWithOutParams(${paraID}, ${paraNumber}, ${paraFloat}, ${paraBinFloat},
        ${paraBinDouble})}`);

    test:assertEquals(paraNumber.get(decimal), <decimal>2147483647, "1st out parameter of procedure did not match.");
    test:assertTrue((check paraFloat.get(float)) < 21474.83647, "2nd out parameter of procedure did not match.");
    test:assertTrue((check paraBinFloat.get(float)) < 21.47483647,
        "3rd out parameter of procedure did not match.");
    test:assertEquals(paraBinDouble.get(float), 21474836.47, "4th out parameter of procedure did not match.");
    boolean|sql:Error status = ret.getNextQueryResult();
    test:assertTrue(status is boolean, "state is not a boolean");
    check oracledbClient.close();
}

type Xml xml;

@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithComplexTypesOutParams() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new (1);
    XmlOutParameter paraXml = new ();

    var ret = check oracledbClient->call(
        `{call SelectComplexDataWithOutParams(${paraID}, ${paraXml})}`);
    check oracledbClient.close();
    xml 'xml = xml `<key>value</key>`;
    test:assertEquals(check paraXml.get(Xml), 'xml , "1st out parameter of procedure did not match.");
}

distinct class RandomOutParameter {
    *sql:OutParameter;
    public isolated function get(typedesc<anydata> typeDesc) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor"
    } external;
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithRandomOutParams() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new (1);
    RandomOutParameter paraRandom = new ();

    var ret = oracledbClient->call(
        `{call SelectComplexDataWithOutParams(${paraID}, ${paraRandom})}`);
    check oracledbClient.close();
    test:assertTrue(ret is error);
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithDateTimesOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new (1);
    sql:DateTimeOutParameter paraDate = new;
    sql:DateOutParameter paraDateOnly = new;
    sql:TimestampOutParameter paraTimestamp = new;
    sql:TimestampWithTimezoneOutParameter paraTimestampTz = new;
    IntervalYearToMonthOutParameter paraIntervalMY = new;
    IntervalDayToSecondOutParameter paraIntervalDS = new;

    var ret = check oracledbClient->call(
        `{call SelectDateTimesWithOutParams(${paraID}, ${paraDate}, ${paraDateOnly}, ${paraTimestamp},
        ${paraTimestampTz}, ${paraIntervalMY}, ${paraIntervalDS})}`);
    check oracledbClient.close();

    time:Civil dateTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Date dateOnlyTypeRecord = {year: 2020, month: 1, day: 5};
    time:Civil timestampTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Civil timestampTzTypeRecord = {utcOffset: {hours: 5, minutes: 30}, timeAbbrev: "+05:30", year: 2020,
                                        month: 1, day: 5, hour: 10, minute: 35, second: 10};
    IntervalYearToMonth intervalYM = {years:15, months: 11};
    IntervalDayToSecond intervalDS = {days:20, hours: 11, minutes: 21, seconds: 24.045};

    test:assertEquals(check paraDate.get(time:Civil), dateTypeRecord,
                        "paraDate out parameter of procedure did not match.");
    test:assertEquals(check paraDateOnly.get(time:Date), dateOnlyTypeRecord,
                        "paraDateOnly out parameter of procedure did not match.");
    test:assertEquals(check paraTimestamp.get(time:Civil), timestampTypeRecord,
                        "paraTimestamp out parameter of procedure did not match.");
    test:assertEquals(check paraTimestampTz.get(time:Civil), timestampTzTypeRecord,
                        "paraTimestampTz out parameter of procedure did not match.");
    test:assertEquals(check paraIntervalMY.get(IntervalYearToMonth), intervalYM,
                        "paraIntervalMY out parameter of procedure did not match.");
    test:assertEquals(check paraIntervalDS.get(IntervalDayToSecond), intervalDS,
                        "paraIntervalDS out parameter of procedure did not match.");
}

isolated function callQueryClient(Client oracledbClient, @untainted string|sql:ParameterizedQuery sqlQuery)
returns @tainted record {}|error {
    stream<record {}, error?> streamData = oracledbClient->query(sqlQuery);
    record {|record {} value;|}? data = check streamData.next();
    check streamData.close();
    record {}? value = data?.value;
    check oracledbClient.close();
    if (value is ()) {
        return {};
    } else {
        return value;
    }
}
