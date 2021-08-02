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
    sql:ExecutionResult result = check dropTableIfExists("ComplexQueryTable");
    result = check oracledbClient->execute(`CREATE TABLE ComplexQueryTable(
        id NUMBER,
        col_xml XMLType,
        PRIMARY KEY (id)
        )`
    );
    xml xmlValue = xml `<key>value</key>`;
    result = check oracledbClient->execute(
            `INSERT INTO ComplexQueryTable (id, col_xml) VALUES(1, ${xmlValue})`);
    check oracledbClient.close();
}

@test:Config {
    groups: ["query", "query-complex-params"]
}
isolated function queryXmlWithoutReturnType() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT a.* from ComplexQueryTable a`;
    record {}|sql:Error? value = check queryClient(sqlQuery);
    if value is record {} {
        test:assertEquals(<decimal> 1, value["ID"], "Returned are wrong");
        test:assertEquals(xml `<key>value</key>`, value["COL_XML"], "Returned are wrong");
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
    sql:ParameterizedQuery sqlQuery = `SELECT a.* from ComplexQueryTable a`;
    record {}? value = check queryClient(sqlQuery, XmlTypeRecord);
    XmlTypeRecord complexResult = {
            id: 1,
            col_xml: xml `<key>value</key>`
        };
    test:assertEquals(complexResult, value, "Returned are wrong");
}
