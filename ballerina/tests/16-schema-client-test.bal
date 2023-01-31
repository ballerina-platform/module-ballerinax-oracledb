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
import ballerina/io;

@test:Config {
    groups: ["metadata"]
}
function testListTables() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string[] tableList = check client1->listTables("ADMIN");
    check client1.close();

    boolean tableCheck = tableList.indexOf("OFFICES") != null && tableList.indexOf("MYEMPLOYEES") != null;
    test:assertEquals(tableCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testListTablesNegative() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string[] tableList = check client1->listTables("SYS");
    check client1.close();

    boolean tableCheck = tableList.indexOf("OFFICES") != null && tableList.indexOf("MYEMPLOYEES") != null;
    test:assertEquals(tableCheck, false);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoNoColumns() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:TableDefinition 'table = check client1->getTableInfo("MYEMPLOYEES", "ADMIN", include = sql:NO_COLUMNS);
    check client1.close();
    test:assertEquals('table, {"name": "MYEMPLOYEES", "type": "BASE TABLE"});
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoColumnsOnly() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:TableDefinition 'table = check client1->getTableInfo("MYEMPLOYEES", "ADMIN", include = sql:COLUMNS_ONLY);
    check client1.close();
    test:assertEquals('table.name, "MYEMPLOYEES");
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
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:TableDefinition 'table = check client1->getTableInfo("MYEMPLOYEES", "ADMIN", include = sql:COLUMNS_WITH_CONSTRAINTS);
    check client1.close();

    test:assertEquals('table.name, "MYEMPLOYEES");
    test:assertEquals('table.'type, "BASE TABLE");

    string tableCheckConst = (<sql:CheckConstraint[]>'table.checkConstraints).toString();
    io:println(tableCheckConst);
    boolean checkConstCheck = tableCheckConst.includes("CHK_EMPNUMS");

    test:assertEquals(checkConstCheck, true);

    string tableCol = (<sql:ColumnDefinition[]>'table.columns).toString();
    boolean colCheck = tableCol.includes("EMPLOYEENUMBER") && tableCol.includes("LASTNAME") && 
                         tableCol.includes("FIRSTNAME") && tableCol.includes("EXTENSION") && 
                         tableCol.includes("EMAIL") && tableCol.includes("OFFICECODE") && 
                         tableCol.includes("REPORTSTO") && tableCol.includes("JOBTITLE") && 
                         tableCol.includes("FK_MYEMPLOYEES_OFFICE") && tableCol.includes("FK_MYEMPLOYEES_MANAGER");

    test:assertEquals(colCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoNegative() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:TableDefinition|sql:Error 'table = client1->getTableInfo("EMPLOYEE", "ADMIN", include = sql:NO_COLUMNS);
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
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string[] routineList = check client1->listRoutines("ADMIN");
    check client1.close();
    
    boolean routineCheck = routineList.indexOf("GETEMPSNAME") != null && routineList.indexOf("GETEMPSEMAIL") != null;
    test:assertEquals(routineCheck, true);    
}

@test:Config {
    groups: ["metadata"]
}
function testListRoutinesNegative() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    string[] routineList = check client1->listRoutines("ADMIN");
    check client1.close();

    boolean routineCheck = routineList.indexOf("GETEMPSNAMES") != null && routineList.indexOf("GETEMPSEMAILS") != null;
    test:assertEquals(routineCheck, false);
}

@test:Config {
    groups: ["metadata"]
}
function testGetRoutineInfo() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:RoutineDefinition routine = check client1->getRoutineInfo("GETEMPSNAME");
    check client1.close();
    test:assertEquals(routine.name, "GETEMPSNAME");
    test:assertEquals(routine.'type, "PROCEDURE");

    string routineParams = (<sql:ParameterDefinition[]>routine.parameters).toString();
    boolean paramCheck = routineParams.includes("EMPNUMBER") && routineParams.includes("FNAME");
    test:assertEquals(paramCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetRoutineInfoNegative() returns error? {
    SchemaClient client1 = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:RoutineDefinition|sql:Error routine = client1->getRoutineInfo("GETEMPSNAMES");
    check client1.close();
    if routine is sql:Error {
        test:assertEquals(routine.message(), "Selected routine does not exist in the database, or the user does not have required privilege level to view it.");
    } else {
        test:assertFail("Expected result not recieved");
    }
}
