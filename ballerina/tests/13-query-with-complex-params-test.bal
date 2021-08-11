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

@test:BeforeGroups { value:["query-complex-params"] }
isolated function beforeQueryWithComplexParamsFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check dropTableIfExists("ComplexQueryTable", oracledbClient);
    result = check oracledbClient->execute(`CREATE TABLE ComplexQueryTable(
        id NUMBER,
        col_xml XMLType,
        PRIMARY KEY (id)
        )`
    );
    xml xmlValue = xml `<key>value</key>`;
    result = check oracledbClient->execute(
            `INSERT INTO ComplexQueryTable (id, col_xml) VALUES(1, ${xmlValue})`);
    result = check oracledbClient->execute(
            `INSERT INTO ComplexQueryTable (id, col_xml) VALUES(2, ${()})`);
    check oracledbClient.close();
}

@test:Config {
    groups: ["query", "query-complex-params"]
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
    groups: ["query", "query-complex-params"]
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
    groups: ["query", "query-complex-params"]
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
