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

type StringDataForCall record {
    string varchar_type;
    string charmax_type;
    string char_type;
    string charactermax_type;
    string character_type;
    string nvarcharmax_type;
};

type StringDataSingle record {
    string varchar_type;
};

@test:BeforeGroups { value:["insert-time"] }
isolated function beforeProcCallFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check dropTableIfExists("CallStringTypes");
    result = check oracledbClient->execute("CREATE TABLE CallStringTypes ("+
        "id NUMBER,"+
        "col_char CHAR(255),"+
        "col_nchar NCHAR(255),"+
        "col_varchar2  VARCHAR2(255),"+
        "col_varchar  VARCHAR(255),"+
        "col_nvarchar2 NVARCHAR2(255),"+
        "PRIMARY KEY (id)"+
        ");"
    );
    reuslt = check oracledbClient->execute("INSERT INTO CallStringTypes("+
        "id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)"+
        "VALUES (1, 'test0', 'test1', 'test2', 'test3', 'test4');"
    );

    result = check dropTableIfExists("CallNumericTypes");
    result = check oracledbClient->execute("CREATE TABLE CallNumericTypes ("+
        "id NUMBER,"+
        "col_number  NUMBER,"+
        "col_float  FLOAT,"+
        "col_binary_float BINARY_FLOAT,"+
        "col_binary_double BINARY_DOUBLE,"+
        "PRIMARY KEY (id)"+
        ");"
    );
    reuslt = check oracledbClient->execute("INSERT INTO CallNemericTypes("+
        "id, col_number, col_float, col_binary_float, col_binary_double)"+
        "VALUES (1, 2147483647, 21474.83647, 21.47483647, 21474836.47);"
    );
    result = check oracledbClient->execute(
        "CREATE OR REPLACE PROCEDURE InsertStringData(IN p_id NUMBER,"+
        "IN p_col_char CHAR(255), IN pcol_nchar NCHAR(255),"+
        "IN p_col_varchar2  VARCHAR2(255), IN col_varchar VARCHAR(255), "+
        "col_nvarchar2 NVARCHAR2(255))"
        "Begin"
        "INSERT INTO StringTypes(id, varchar_type, charmax_type, char_type, charactermax_type, character_type, nvarcharmax_type)
        VALUES (p_id, p_varchar_type, p_charmax_type, p_char_type, p_charactermax_type, p_character_type, p_nvarcharmax_type);
        End;
/
    )
    check oracledbClient.close();
}

@test:Config {
    groups: ["procedures"]
}
function testCallWithStringTypes() returns @tainted record {}|error? {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);
    sql:ProcedureCallResult ret = checkpanic dbClient->call("{call InsertStringData(2,'test1', 'test2', 'c', 'test3', 'd', 'test4')};");

    string sqlQuery = "SELECT varchar_type, charmax_type, char_type, charactermax_type, character_type," +
                   "nvarcharmax_type from StringTypes where id = 2";

    StringDataForCall expectedDataRow = {
        varchar_type: "test1",
        charmax_type: "test2",
        char_type: "c",
        charactermax_type: "test3",
        character_type: "d",
        nvarcharmax_type: "test4"
    };
    test:assertEquals(queryMySQLClient(dbClient, sqlQuery), expectedDataRow, "Call procedure insert and query did not match.");
}