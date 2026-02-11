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
import ballerina/io;

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

@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithStringTypes() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
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
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypes]
}
isolated function testCallWithStringTypesInParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    string col_char = "test0";
    string col_nchar = "test1";
    string col_varchar2 = "test2";
    string col_varchar = "test3";
    string col_nvarchar2 = "test4";

    sql:ProcedureCallResult ret = check oracledbClient->call(`{call InsertStringData(3, ${col_char}, ${col_nchar},
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
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesInParams]
}
isolated function testCallWithStringTypesOutParams() returns sql:Error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:CharOutParameter col_char = new ();
    sql:NCharOutParameter col_nchar = new ();
    sql:VarcharOutParameter col_varchar2 = new ();
    sql:VarcharOutParameter col_varchar = new ();
    sql:NVarcharOutParameter col_nvarchar2 = new ();

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

    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesOutParams]
}
isolated function testCallWithStringTypesInOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    int id = 4;
    sql:InOutParameter col_varchar2 = new ("test7");
    sql:InOutParameter col_varchar = new ("test8");
    sql:InOutParameter col_nvarchar2 = new ("test9");

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
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesInOutParams]
}
isolated function testCallWithNumericTypesOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new (1);
    sql:NumericOutParameter paraNumber = new;
    sql:FloatOutParameter paraFloat = new;
    sql:FloatOutParameter paraBinFloat = new;
    sql:DoubleOutParameter paraBinDouble = new;

    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{call SelectNumericDataWithOutParams(${paraID}, ${paraNumber}, ${paraFloat}, ${paraBinFloat},
        ${paraBinDouble})}`);

    test:assertEquals(paraNumber.get(decimal), <decimal>2147483647, "1st out parameter of procedure did not match.");
    test:assertTrue((check paraFloat.get(float)) < 21474.83647, "2nd out parameter of procedure did not match.");
    test:assertTrue((check paraBinFloat.get(float)) < 21.47483647, 
        "3rd out parameter of procedure did not match.");
    test:assertEquals(paraBinDouble.get(float), 21474836.47, "4th out parameter of procedure did not match.");
    boolean|sql:Error status = ret.getNextQueryResult();
    test:assertTrue(status is boolean, "state is not a boolean");
    check ret.close();
    check oracledbClient.close();
}

type Xml xml;

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithNumericTypesOutParams]
}
isolated function testCallWithComplexTypesOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new (1);
    XmlOutParameter paraXml = new ();

    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{call SelectComplexDataWithOutParams(${paraID}, ${paraXml})}`);
    xml 'xml = xml `<key>value</key>`;
    test:assertEquals(check paraXml.get(Xml), 'xml, "1st out parameter of procedure did not match.");
    check ret.close();
    check oracledbClient.close();
}

distinct class RandomOutParameter {
    *sql:OutParameter;
    public isolated function get(typedesc<anydata> typeDesc) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor",
        name: "getOutParameterValue"
    } external;
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithComplexTypesOutParams]
}
isolated function testCallWithRandomOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:IntegerValue paraID = new (1);
    RandomOutParameter paraRandom = new ();

    sql:ProcedureCallResult|error ret = oracledbClient->call(
        `{call SelectComplexDataWithOutParams(${paraID}, ${paraRandom})}`);
    check oracledbClient.close();
    test:assertTrue(ret is error);
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithRandomOutParams]
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

    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{call SelectDateTimesWithOutParams(${paraID}, ${paraDate}, ${paraDateOnly}, ${paraTimestamp},
        ${paraTimestampTz}, ${paraIntervalMY}, ${paraIntervalDS})}`);

    time:Civil dateTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Date dateOnlyTypeRecord = {year: 2020, month: 1, day: 5};
    time:Civil timestampTypeRecord = {year: 2020, month: 1, day: 5, hour: 10, minute: 35, second: 10};
    time:Civil timestampTzTypeRecord = {
        utcOffset: {hours: 5, minutes: 30},
        timeAbbrev: "+05:30",
        year: 2020,
        month: 1,
        day: 5,
        hour: 10,
        minute: 35,
        second: 10
    };
    IntervalYearToMonth intervalYM = {years: 15, months: 11, sign: 1};
    IntervalDayToSecond intervalDS = {days: 20, hours: 11, minutes: 21, seconds: 24.45, sign: 1};

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
    check ret.close();
    check oracledbClient.close();
}

type CallStringTypes record {|
    decimal ID;
    string COL_CHAR;
    string COL_NCHAR;
    string COL_VARCHAR2;
    string COL_VARCHAR;
    string COL_NVARCHAR2;
|};

type StringCharType record {|
    string COL_CHAR;
|};

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesOutParams]
}
isolated function testCallWithStringTypesCursorOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    decimal id = 1;
    sql:CursorOutParameter cursor = new;
    sql:ProcedureCallResult ret = check oracledbClient->call(`{call SelectDataWithRefCursorAndNumber(${id}, ${cursor})}`);
    stream<CallStringTypes, sql:Error?> resultStream = cursor.get();

    CallStringTypes[] result = check from CallStringTypes row in resultStream select row;
    io:println("result: ", result);
    CallStringTypes expectedDataRow = {
        ID: 1,
        COL_CHAR: "test0",
        COL_NCHAR: "test1",
        COL_VARCHAR2: "test2",
        COL_VARCHAR: "test3",
        COL_NVARCHAR2: "test4"
    };
    test:assertEquals(result.length(), 1, "Result length did not match.");
    test:assertEquals(result[0], expectedDataRow, "Result did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: [testCallWithStringTypesOutParams]
}
isolated function testCallWithStringTypesCursorOutParamsWithoutInput() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:CursorOutParameter activeCursor = new;
    sql:CursorOutParameter upcomingCursor = new;
    sql:ProcedureCallResult ret = check oracledbClient->call(`{call SelectStringDataWithRefCursor(${activeCursor}, ${upcomingCursor})}`);

    // First cursor - activeCursor
    stream<record{}, sql:Error?> resultStream = activeCursor.get();
    record{}[] result = check from record{} row in resultStream select row;
    io:println("result: ", result);

    CallStringTypes expectedDataRow = {
        ID: 1,
        COL_CHAR: "test0",
        COL_NCHAR: "test1",
        COL_VARCHAR2: "test2",
        COL_VARCHAR: "test3",
        COL_NVARCHAR2: "test4"
    };
    test:assertEquals(result.length(), 4, "Result length did not match.");
    test:assertEquals(result[0], expectedDataRow, "Result did not match.");

    // Second cursor - upcomingCursor
    stream<record{}, sql:Error?> resultStream2 = upcomingCursor.get();
    record{}[] result2 = check from record{} row in resultStream2 select row;
    io:println("result: ", result2);
    StringCharType expectedDataRow2 = {
        COL_CHAR: "test0"
    };
    test:assertEquals(result2.length(), 4, "Result length did not match.");
    test:assertEquals(result2[0], expectedDataRow2, "Result did not match.");

    check ret.close();
    check oracledbClient.close();
}

// Call ClobOutProc procedure to test CLOB type as output parameter.
@test:Config {
    groups: ["procedures"]
}
isolated function testCallWithClobOutParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);

    sql:ClobOutParameter returnedDbData = new();
    sql:ParameterizedCallQuery query = `{CALL ClobOutProc(${returnedDbData})}`;
    sql:ProcedureCallResult ret = check oracledbClient->call(query);

    string clobData = check returnedDbData.get();
    io:println("CLOB data returned from the procedure, the length is: ", clobData.length());
    test:assertEquals(clobData.length(), 110904, "Result length did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallStringFunction() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:VarcharOutParameter returnValue = new;
    decimal id = 1;
    sql:ProcedureCallResult ret = check oracledbClient->call(`{${returnValue} = call GetStringById(${id})}`);
    test:assertEquals(check returnValue.get(string), "test2", "Function return value did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallNumericFunction() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:DecimalOutParameter returnValue = new;
    decimal id = 1;
    sql:ProcedureCallResult ret = check oracledbClient->call(`{${returnValue} = call GetNumericById(${id})}`);
    test:assertEquals(check returnValue.get(decimal), 2147483647d, "Function return value did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallDoubleFunction() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:DoubleOutParameter returnValue = new;
    decimal id = 1;
    sql:ProcedureCallResult ret = check oracledbClient->call(`{${returnValue} = call GetDoubleById(${id})}`);
    test:assertEquals(check returnValue.get(float), 21474836.47, "Function return value did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionWithMultipleParams() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:VarcharOutParameter returnValue = new;
    decimal id = 1;
    string paramType = "varchar2";
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call GetStringByIdAndType(${id}, ${paramType})}`);
    test:assertEquals(check returnValue.get(string), "test2", "Function return value did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionWithMultipleParamsCharType() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:VarcharOutParameter returnValue = new;
    decimal id = 1;
    string paramType = "char";
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call GetStringByIdAndType(${id}, ${paramType})}`);
    test:assertEquals(check returnValue.get(string), "test0", "Function return value did not match.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionReturningNull() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:VarcharOutParameter returnValue = new;
    decimal id = 999;
    sql:ProcedureCallResult ret = check oracledbClient->call(`{${returnValue} = call GetNullableStringById(${id})}`);
    json result = check returnValue.get(json);
    test:assertEquals(result, (), "Function return value should be nil.");
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallNonExistentFunction() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:VarcharOutParameter returnValue = new;
    decimal id = 1;
    sql:ProcedureCallResult|sql:Error ret = oracledbClient->call(
        `{${returnValue} = call NonExistentFunction(${id})}`);
    test:assertTrue(ret is sql:Error, "Expected an error for non-existent function.");
    check oracledbClient.close();
}

type ObjectResult record {|
    string STRING_ATTR;
    int INT_ATTR;
    float FLOAT_ATTR;
    decimal DECIMAL_ATTR;
|};

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionReturningObject() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    ObjectOutParameter returnValue = new ("CALLRESULTOBJECTTYPE");
    decimal id = 1;
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call GetObjectById(${id})}`);
    ObjectResult? result = check returnValue.get(ObjectResult);
    test:assertTrue(result is ObjectResult, "Function should return an object.");
    if result is ObjectResult {
        test:assertEquals(result.STRING_ATTR, "test2", "STRING_ATTR did not match.");
        test:assertEquals(result.INT_ATTR, 2147483647, "INT_ATTR did not match.");
    }
    check ret.close();
    check oracledbClient.close();
}

type NullableObjectResult record {|
    int? ID_ATTR;
    string? STRING_ATTR;
    string? STATUS;
|};

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionReturningObjectWithNullFields() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    ObjectOutParameter returnValue = new ("CALLNULLABLEOBJECTTYPE");
    decimal id = 1;
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call GetNullableObjectById(${id})}`);
    NullableObjectResult? result = check returnValue.get(NullableObjectResult);
    test:assertTrue(result is NullableObjectResult, "Function should return an object.");
    if result is NullableObjectResult {
        test:assertEquals(result.ID_ATTR, 1, "ID_ATTR did not match.");
        test:assertEquals(result.STRING_ATTR, "test2", "STRING_ATTR did not match.");
        test:assertEquals(result.STATUS, (), "STATUS should be null.");
    }
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionReturningNullObject() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    ObjectOutParameter returnValue = new ("CALLNULLABLEOBJECTTYPE");
    decimal id = 999;
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call GetNullableObjectById(${id})}`);
    json result = check returnValue.get(json);
    test:assertEquals(result, (), "Function should return null for non-existent id.");
    check ret.close();
    check oracledbClient.close();
}

type MobileResult record {|
    int? user_id;
    string? first_name;
    string? last_name;
    string? email;
    string? mobile_number;
    string? status;
    string? is_verified;
    string? message;
|};

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionReturningStructType() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:StructOutParameter returnValue = new;
    string mobileNumber = "0771234567";
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call verify_mobile(${mobileNumber})}`);
    MobileResult? result = check returnValue.get(MobileResult);
    test:assertTrue(result is MobileResult, "Function should return a struct.");
    if result is MobileResult {
        test:assertEquals(result.user_id, 1, "user_id did not match.");
        test:assertEquals(result.first_name, "John", "first_name did not match.");
        test:assertEquals(result.last_name, "Doe", "last_name did not match.");
        test:assertEquals(result.email, "john.doe@example.com", "email did not match.");
        test:assertEquals(result.mobile_number, "0771234567", "mobile_number did not match.");
        test:assertEquals(result.status, "ACTIVE", "status did not match.");
        test:assertEquals(result.is_verified, "Y", "is_verified did not match.");
        test:assertEquals(result.message, "Mobile number verified successfully", "message did not match.");
    }
    check ret.close();
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
isolated function testCallFunctionReturningStructTypeNotFound() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    sql:StructOutParameter returnValue = new;
    string mobileNumber = "0000000000";
    sql:ProcedureCallResult ret = check oracledbClient->call(
        `{${returnValue} = call verify_mobile(${mobileNumber})}`);
    MobileResult? result = check returnValue.get(MobileResult);
    test:assertTrue(result is MobileResult, "Function should return a struct.");
    if result is MobileResult {
        test:assertEquals(result.user_id, (), "user_id should be null.");
        test:assertEquals(result.mobile_number, "0000000000", "mobile_number did not match.");
        test:assertEquals(result.status, "NOT_FOUND", "status did not match.");
        test:assertEquals(result.message, "Mobile number not registered", "message did not match.");
    }
    check ret.close();
    check oracledbClient.close();
}

isolated function callQueryClient(Client oracledbClient, sql:ParameterizedQuery sqlQuery)
returns record {}|error {
    stream<record {}, error?> streamData = oracledbClient->query(sqlQuery);
    record {|record {} value;|}? data = check streamData.next();
    check streamData.close();
    record {}? value = data?.value;
    check oracledbClient.close();
    if value is () {
        return {};
    } else {
        return value;
    }
}
