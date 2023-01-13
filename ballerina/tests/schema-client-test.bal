// Copyright (c) 2022 WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/test;
import ballerina/sql;

@test:BeforeGroups {
    value: ["metadata"]
}
function initSchemaClientTests() returns error? {
    _ = check executeQueryOracleClient(`CREATE SCHEMA metadataEmptyDB;`);
    _ = check executeQueryOracleClient(`CREATE SCHEMA metadataDB;`);
    _ = check executeQueryOracleClient(`ALTER SESSION SET CURRENT_SCHEMA = metadataDB;`);

    sql:ParameterizedQuery query = `
        CREATE TABLE metadataDB.OFFICES (
            OFFICECODE varchar(10) NOT NULL,
            PRIMARY KEY (OFFICECODE)
        );

        CREATE TABLE metadataDB.EMPLOYEES (
            EMPLOYEENUMBER int NOT NULL,
            LASTNAME varchar(50) NOT NULL,
            FIRSTNAME varchar(50) NOT NULL,
            EXTENSION varchar(10) NOT NULL,
            EMAIL varchar(100) NOT NULL,
            OFFICECODE varchar(10) NOT NULL,
            REPORTSTO int DEFAULT NULL,
            JOBTITLE varchar(50) NOT NULL,
            PRIMARY KEY (EMPLOYEENUMBER),
            CONSTRAINT CHK_EmpNums CHECK (EMPLOYEENUMBER>0 AND REPORTSTO>0),
            CONSTRAINT FK_EmployeesManager FOREIGN KEY (REPORTSTO) REFERENCES EMPLOYEES(EMPLOYEENUMBER),
            CONSTRAINT FK_EmployeesOffice FOREIGN KEY (OFFICECODE) REFERENCES OFFICES(OFFICECODE)
        );

        CREATE INDEX REPORTSTO ON EMPLOYEES (REPORTSTO);
        CREATE INDEX OFFICECODE ON EMPLOYEES (OFFICECODE);
    `;

    sql:ParameterizedQuery query1 = `
        CREATE OR REPLACE PROCEDURE getEmpsName( EMPNUMBER IN NUMBER, FNAME OUT VARCHAR2)
        IS
        BEGIN
            SELECT FIRSTNAME INTO FNAME
            FROM EMPLOYEES
            WHERE EMPLOYEENUMBER = EMPNUMBER;
        END;
    `;

    sql:ParameterizedQuery query2 = `
        CREATE OR REPLACE PROCEDURE getEmpsEmail( EMPNUMBER IN NUMBER, EMPEMAIL OUT VARCHAR2)
        IS
        BEGIN
            SELECT EMAIL INTO EMPEMAIL
            FROM EMPLOYEES
            WHERE EMPLOYEENUMBER = EMPNUMBER;
        END;
    `;

    _ = check executeQueryOracleClient(query, "metadataDB");
    _ = check executeQueryOracleClient(query1, "metadataDB");
    _ = check executeQueryOracleClient(query2, "metadataDB");
}

@test:Config {
    groups: ["metadata"]
}
function testListTables() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    string[] tableList = check client1->listTables();
    check client1.close();
    test:assertEquals(tableList, ["OFFICES", "EMPLOYEES"]);
}

@test:Config {
    groups: ["metadata"]
}
function testListTablesNegative() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataEmptyDB", port);
    string[] tableList = check client1->listTables();
    check client1.close();
    test:assertEquals(tableList, []);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoNoColumns() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    sql:TableDefinition 'table = check client1->getTableInfo("EMPLOYEES", include = sql:NO_COLUMNS);
    check client1.close();
    test:assertEquals('table, {"name": "EMPLOYEES", "type": "BASE TABLE"});
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoColumnsOnly() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    sql:TableDefinition 'table = check client1->getTableInfo("EMPLOYEES", include = sql:COLUMNS_ONLY);
    check client1.close();
    test:assertEquals('table.name, "EMPLOYEES");
    test:assertEquals('table.'type, "BASE TABLE");

    string tableCol = (<sql:ColumnDefinition[]>'table.columns).toString();
    boolean colCheck = tableCol.includes("EMPLOYEENUMBER") && tableCol.includes("LASTNAME") && 
                         tableCol.includes("FIRSTNAME") && tableCol.includes("EXTENSION") && 
                         tableCol.includes("EMAIL") && tableCol.includes("OFFICECODE") && 
                         tableCol.includes("REPORTSTO") && tableCol.includes("JOBTITLE");

    test:assertEquals(colCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoColumnsWithConstraints() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    sql:TableDefinition 'table = check client1->getTableInfo("EMPLOYEES", include = sql:COLUMNS_WITH_CONSTRAINTS);
    check client1.close();

    test:assertEquals('table.name, "EMPLOYEES");
    test:assertEquals('table.'type, "BASE TABLE");

    string tableCheckConst = (<sql:CheckConstraint[]>'table.checkConstraints).toString();
    boolean checkConstCheck = tableCheckConst.includes("CHK_EmpNums");

    test:assertEquals(checkConstCheck, true);

    string tableCol = (<sql:ColumnDefinition[]>'table.columns).toString();
    boolean colCheck = tableCol.includes("EMPLOYEENUMBER") && tableCol.includes("LASTNAME") && 
                         tableCol.includes("FIRSTNAME") && tableCol.includes("EXTENSION") && 
                         tableCol.includes("EMAIL") && tableCol.includes("OFFICECODE") && 
                         tableCol.includes("REPORTSTO") && tableCol.includes("JOBTITLE") && 
                         tableCol.includes("FK_EmployeesOffice") && tableCol.includes("FK_EmployeesManager");

    test:assertEquals(colCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoNegative() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    sql:TableDefinition|sql:Error 'table = client1->getTableInfo("EMPLOYEE", include = sql:NO_COLUMNS);
    check client1.close();
    if 'table is sql:Error {
        test:assertEquals('table.message(), "The selected table does not exist or the user does not have the required privilege level to view the table.");
    } else {
        test:assertFail("Expected result not received");
    }
}

@test:Config {
    groups: ["metadata"]
}
function testListRoutines() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    string[] routineList = check client1->listRoutines();
    check client1.close();
    test:assertEquals(routineList, ["getEmpsName", "getEmpsEmail"]);
}

@test:Config {
    groups: ["metadata"]
}
function testListRoutinesNegative() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataEmptyDB", port);
    string[] routineList = check client1->listRoutines();
    check client1.close();
    test:assertEquals(routineList, []);
}

@test:Config {
    groups: ["metadata"]
}
function testGetRoutineInfo() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    sql:RoutineDefinition routine = check client1->getRoutineInfo("getEmpsName");
    check client1.close();
    test:assertEquals(routine.name, "getEmpsName");
    test:assertEquals(routine.'type, "PROCEDURE");

    string routineParams = (<sql:ParameterDefinition[]>routine.parameters).toString();
    boolean paramCheck = routineParams.includes("@EMPNUMBER") && routineParams.includes("@FNAME");
    test:assertEquals(paramCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetRoutineInfoNegative() returns error? {
    SchemaClient client1 = check new(host, user, password, "metadataDB", port);
    sql:RoutineDefinition|sql:Error routine = client1->getRoutineInfo("getEmpsNames");
    check client1.close();
    if routine is sql:Error {
        test:assertEquals(routine.message(), "Selected routine does not exist in the database, or the user does not have required privilege level to view it.");
    } else {
        test:assertFail("Expected result not recieved");
    }
}
