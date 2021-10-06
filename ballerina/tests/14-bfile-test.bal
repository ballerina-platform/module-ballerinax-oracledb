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

@test:Config {
    groups:["bfile"]
}
isolated function insertValidBFileLocator() returns sql:Error? {
    string directory = "BFILE_TEST_DIR";
    string fileName = "bfile.txt";
    sql:ParameterizedQuery insertQuery = `INSERT INTO bfile_test_table VALUES (1, BFILENAME(${directory}, ${fileName}))`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
}

type BFileRequestType record {
    decimal pk;
    BFile col_bfile;
};

@test:Config {
    groups:["bfile"],
    dependsOn:[insertValidBFileLocator]
}
isolated function getValidBFileWithRequestType() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM bfile_test_table where pk = 1`;
    record {}? value = check queryClient(sqlQuery, BFileRequestType);
    BFile bfile = {name:"bfile.txt", length:83};
    if value is record {} {
        test:assertEquals(<decimal> 1, value["pk"], "Expected pk did not match.");
        test:assertEquals(bfile, value["col_bfile"], "Expected Bfile did not match.");
    } else {
        test:assertFail("Value is Error");
    }
}

@test:Config {
    groups:["bfile"],
    dependsOn:[getValidBFileWithRequestType]
}
isolated function insertNullBFileLocator() returns error? {
    sql:ParameterizedQuery insertQuery = `INSERT INTO bfile_test_table VALUES (2, NULL)`;
    sql:ExecutionResult result = check executeQuery(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    test:assertTrue(insertId is string, "Last Insert id should be string");
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM bfile_test_table where pk = 2`;
    record {}? value = check queryClient(sqlQuery, BFileRequestType);
    if value is record {} {
        test:assertEquals(<decimal> 2, value["pk"], "Expected pk did not match.");
        test:assertEquals((), value["col_bfile"], "Expected Bfile did not match.");
    } else {
        test:assertFail("Value is Error");
    }
}

type InvalidBFile record {
    string name;
    int length;
};

type BFileRequestType2 record {
    decimal pk;
    InvalidBFile col_bfile;
};

@test:Config {
    groups:["bfile"],
    dependsOn:[insertNullBFileLocator]
}
isolated function getValidBFileWithInvalidRequestType() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM bfile_test_table where pk = 1`;
    record {}|error? value = queryClient(sqlQuery, BFileRequestType2);
    test:assertTrue(value is sql:ApplicationError);
    if value is sql:ApplicationError {
        test:assertTrue(value.message().includes("The ballerina type expected for 'BFILE' type is 'oracledb:BFile' " +
        "but found type 'InvalidBFile'."));
    } else {
        test:assertFail("ApplicationError Error expected");
    }
}

@test:Config {
    groups:["bfile"],
    dependsOn:[getValidBFileWithInvalidRequestType]
}
isolated function checkIsFileExistsMethod() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 1, minIdleConnections: 1};
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT, connectionPool = pool);
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM bfile_test_table where pk = 1`;
    stream<BFileRequestType, error?> streamData = oracledbClient->query(sqlQuery);
    record {|BFileRequestType value;|}? data = check streamData.next();
    BFileRequestType? value = data?.value;
    if value is BFileRequestType {
        BFile bfile = <BFile> value["col_bfile"];
        test:assertTrue(isBFileExists(bfile), "BFile does not exists.");
    } else {
        test:assertFail("Value is Error");
    }
    check streamData.close();
    check oracledbClient.close();
}

@test:Config {
    groups:["bfile"],
    dependsOn:[checkIsFileExistsMethod]
}
isolated function checkBfileReadBytesMethod() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 1, minIdleConnections: 1};
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT, connectionPool = pool);
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM bfile_test_table where pk = 1`;
    stream<BFileRequestType, error?> streamData = oracledbClient->query(sqlQuery);
    record {|BFileRequestType value;|}? data = check streamData.next();
    BFileRequestType? value = data?.value;
    if value is BFileRequestType {
        BFile bfile = <BFile> value["col_bfile"];
        byte[] expected = <byte[]> [84,104,105,115,32,105,115,32,97,32,115,97,109,112,108,101,32,116,101,120,116,32,
        102,105,108,101,32,102,111,114,32,116,101,115,116,105,110,103,32,98,102,105,108,101,32,115,117,112,112,111,
        114,116,32,105,110,32,98,97,108,108,101,114,105,110,97,32,111,114,97,99,108,101,100,98,32,109,111,100,117,
        108,101,46,10];
        byte[]? actual = check bfileReadBytes(bfile);
        test:assertEquals(actual, expected, "Expected and actuals are mismatched");
    } else {
        test:assertFail("Value is Error");
    }
    check streamData.close();
    check oracledbClient.close();
}

@test:Config {
    groups:["bfile"],
    dependsOn:[checkBfileReadBytesMethod]
}
isolated function checkBfileReadBlockAsStreamMethod() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 1, minIdleConnections: 1};
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT, connectionPool = pool);
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM bfile_test_table where pk = 1`;
    stream<BFileRequestType, error?> streamData = oracledbClient->query(sqlQuery);
    record {|BFileRequestType value;|}? data = check streamData.next();
    BFileRequestType? value = data?.value;
    if value is BFileRequestType {
        BFile bfile = <BFile> value["col_bfile"];
        stream<byte[], error?> streamArray = bfileReadBlockAsStream(bfile, 20);
        record {|byte[] value;|}? data1 = check streamArray.next();
        byte[]? actual1 = data1?.value;
        byte[] expected1 = <byte[]> [84,104,105,115,32,105,115,32,97,32,115,97,109,112,108,101,32,116,101,120];
        test:assertEquals(actual1, expected1, "Expected and actuals are mismatched");
        record {|byte[] value;|}? data2 = check streamArray.next();
        byte[]? actual2 = data2?.value;
        byte[] expected2 = <byte[]> [116,32,102,105,108,101,32,102,111,114,32,116,101,115,116,105,110,103,32,98];
        test:assertEquals(actual2, expected2, "Expected and actuals are mismatched");
        record {|byte[] value;|}? data3 = check streamArray.next();
        byte[]? actual3 = data3?.value;
        byte[] expected3 = <byte[]> [102,105,108,101,32,115,117,112,112,111,114,116,32,105,110,32,98,97,108,108];
        test:assertEquals(actual3, expected3, "Expected and actuals are mismatched");
        record {|byte[] value;|}? data4 = check streamArray.next();
        byte[]? actual4 = data4?.value;
        byte[] expected4 = <byte[]> [101,114,105,110,97,32,111,114,97,99,108,101,100,98,32,109,111,100,117,108];
        test:assertEquals(actual4, expected4, "Expected and actuals are mismatched");
        record {|byte[] value;|}? data5 = check streamArray.next();
        byte[]? actual5 = data5?.value;
        byte[] expected5 = <byte[]> [101,46,10];
        test:assertEquals(actual5, expected5, "Expected and actuals are mismatched");
        record {|byte[] value;|}|error? data6 = streamArray.next();
        test:assertEquals(data6, (), "Expected and actuals are mismatched");
        record {|byte[] value;|}|error? data7 = streamArray.next();
        test:assertTrue(data7 is sql:ApplicationError);
        if data7 is sql:ApplicationError {
            test:assertTrue(data7.message().includes("Stream is closed. Therefore, no operations are allowed further on the stream."));
        } else {
            test:assertFail("ApplicationError Error expected");
        }
    } else {
        test:assertFail("Value is Error");
    }
    check streamData.close();
    check oracledbClient.close();
}

@test:Config {
    groups:["bfile"],
    dependsOn:[checkBfileReadBlockAsStreamMethod]
}
isolated function checkIsFileExistsMethodForInvalidBFile() returns error? {
    BFile bfile = {name:"bfile.txt", length:83};
    test:assertEquals(isBFileExists(bfile), false, "BFile does not exists.");
}


@test:Config {
    groups:["bfile"],
    dependsOn:[checkIsFileExistsMethodForInvalidBFile]
}
isolated function checkBfileReadBytesMethodForInvalidBFile() returns error? {
    BFile bfile = {name:"bfile.txt", length:83};
    byte[]|sql:Error? value = bfileReadBytes(bfile);
    if value is sql:ApplicationError {
        test:assertTrue(value.message().includes("Invalid BFile received. Hence can not read."));
    } else {
        test:assertFail("ApplicationError Error expected");
    }
}


@test:Config {
    groups:["bfile"],
    dependsOn:[checkBfileReadBytesMethodForInvalidBFile]
}
isolated function checkBfileReadBlockAsStreamMethodForInvalidBFile() returns error? {
    BFile bfile = {name:"bfile.txt", length:83};
    stream<byte[], error?> streamArray = bfileReadBlockAsStream(bfile, 20);
    record {|byte[] value;|}|error? value = streamArray.next();
    if value is sql:Error {
        test:assertTrue(value.message().includes("Error while creating the stream. Invalid BFile received. Hence can " +
        "not create a stream from it."));
    } else {
        test:assertFail("ApplicationError Error expected");
    }
}
