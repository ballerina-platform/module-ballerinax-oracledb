// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/sql;

isolated function getUntaintedData(record {}|error? value, string fieldName) returns @untainted anydata|error? {
    if (value is record {}) {
        return value[fieldName];
    }
    return {};
}

isolated function getByteColumnChannel() returns @untainted io:ReadableByteChannel|error  {
    io:ReadableByteChannel byteChannel = check io:openReadableFile("./tests/resources/files/byteValue.txt");
    return byteChannel;
}

isolated function getBlobColumnChannel() returns @untainted io:ReadableByteChannel|error {
    io:ReadableByteChannel byteChannel = check io:openReadableFile("./tests/resources/files/blobValue.txt");
    return byteChannel;
}

isolated function getClobColumnChannel() returns @untainted io:ReadableCharacterChannel|error {
    io:ReadableByteChannel byteChannel = check io:openReadableFile("./tests/resources/files/clobValue.txt");
    io:ReadableCharacterChannel sourceChannel = new (byteChannel, "UTF-8");
    return sourceChannel;
}

isolated function getTextColumnChannel() returns @untainted io:ReadableCharacterChannel|error {
    io:ReadableByteChannel byteChannel = check io:openReadableFile("./tests/resources/files/clobValue.txt");
    io:ReadableCharacterChannel sourceChannel = new (byteChannel, "UTF-8");
    return sourceChannel;
}

isolated function dropTableIfExists(string tablename) returns sql:ExecutionResult|sql:Error {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check oracledbClient->execute("BEGIN "+
        "EXECUTE IMMEDIATE 'DROP TABLE ' || '" + tablename + "'; "+
        "EXCEPTION "+
        "WHEN OTHERS THEN "+
            "IF SQLCODE != -942 THEN "+
                "RAISE; "+
            "END IF; "+
        "END;");
    check oracledbClient.close();
    return result;
}

isolated function dropTypeIfExists(string tablename) returns sql:ExecutionResult|sql:Error {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check oracledbClient->execute("BEGIN "+
        "EXECUTE IMMEDIATE 'DROP TYPE ' || '" + tablename + " FORCE'; "+
        "EXCEPTION "+
        "WHEN OTHERS THEN "+
            "IF SQLCODE != -4043 THEN "+
                "RAISE; "+
            "END IF; "+
        "END;");
    check oracledbClient.close();
    return result;
}

isolated function executeParamQuery(sql:ParameterizedQuery|string query) returns sql:ExecutionResult|sql:Error {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check oracledbClient->execute(query);
    check oracledbClient.close();
    return result;
}

