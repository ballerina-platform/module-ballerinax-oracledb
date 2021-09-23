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

import ballerina/sql;
import ballerina/test;

@test:Config {
    groups: ["query", "query-complex-params"]
}
isolated function insertXmlDataToTable() returns error? {
    xml xmlValue = xml `<key>value</key>`;
    sql:ExecutionResult result = check executeQuery(
            `INSERT INTO ComplexQueryTable (id, col_xml) VALUES(1, ${xmlValue})`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    result = check executeQuery(
            `INSERT INTO ComplexQueryTable (id, col_xml) VALUES(2, ${()})`);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
}

@test:Config {
    groups: ["query", "query-complex-params"],
    dependsOn: [insertXmlDataToTable]
}
isolated function queryXmlWithoutReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT a.* from ComplexQueryTable a where a.id = ${id}`;
    record {}|sql:Error? value = check queryClient(sqlQuery);
    if value is record {} {
        test:assertEquals(<decimal> 1, value["ID"], "Expected data did not match.");
        test:assertEquals(xml `<key>value</key>`, value["COL_XML"], "Returned are wrong");
    } else {
        test:assertFail("Value is Error");
    }
}

@test:Config {
    groups: ["query", "query-complex-params"],
    dependsOn: [insertXmlDataToTable]
}
isolated function queryNullXmlWithoutReturnType() returns error? {
    int id = 2;
    sql:ParameterizedQuery sqlQuery = `SELECT a.* from ComplexQueryTable a where a.id = ${id}`;
    record {}|sql:Error? value = check queryClient(sqlQuery);
    if value is record {} {
        test:assertEquals(<decimal> 2, value["ID"], "Expected data did not match.");
        test:assertEquals((), value["COL_XML"], "Expected data did not match.");
    } else {
        test:assertFail("Value is Error");
    }
}

type XmlTypeRecord record {
    int id;
    xml col_xml;
};

@test:Config {
    groups: ["query", "query-complex-params"],
    dependsOn: [insertXmlDataToTable]
}
isolated function queryXmlWithReturnType() returns error? {
    int id = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT a.* from ComplexQueryTable a where a.id = ${id}`;
    record {}? value = check queryClient(sqlQuery, XmlTypeRecord);
    XmlTypeRecord complexResult = {
            id: 1,
            col_xml: xml `<key>value</key>`
        };
    test:assertEquals(complexResult, value, "Expected data did not match.");
}

type SelectComplexData record {
    decimal INT_TYPE;
    string INT_AS_STR_TYPE;
    float DOUBLE_TYPE;
    string STRING_TYPE;
};

@test:Config {
    groups: ["query", "query-complex-params"]
}
isolated function testGetPrimitiveTypesRecord() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    SelectComplexData value = check oracledbClient->queryRow(
	`SELECT int_type, int_type as int_as_str_type, double_type, string_type from ComplexDataTable WHERE row_id = 1`);
    SelectComplexData expectedData = {
        INT_TYPE: 1,
        INT_AS_STR_TYPE: "1",
        DOUBLE_TYPE: 2.13909503923E9,
        STRING_TYPE: "Hello"
    };
    test:assertEquals(value, expectedData, "Expected data did not match.");
    sql:ParameterizedQuery sqlQuery = `SELECT COUNT(*) FROM ComplexDataTable`;
    int count = check oracledbClient->queryRow(sqlQuery);
    test:assertEquals(count, 1);
    sqlQuery = `SELECT * FROM ComplexDataTable WHERE row_id = 1`;
    int|error queryResult = oracledbClient->queryRow(sqlQuery);
    if queryResult is error {
        test:assertTrue(queryResult is sql:TypeMismatchError, "Incorrect error type");
        test:assertEquals(queryResult.message(), "Expected type to be 'int' but found 'record{}'.");
    } else {
        test:assertFail("Expected error when query result contains multiple columns.");
    }
    check oracledbClient.close();
}
