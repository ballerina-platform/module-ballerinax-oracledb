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

// with user and password only
@test:Config {
    enable: true,
    groups:["connection","connection-init"]
}
function testWithOnlyUserPasswordParams() {
    Client|sql:Error oracledbClient = new(user=user, password=password);
    test:assertTrue(oracledbClient is sql:Error, "Initializing only with username and password params should fail");
}

// with user, pwd, db
@test:Config {
    enable: true,
    groups:["connection","connection-init"]
}
function testWithUserPasswordDatabaseParams() {
    Client|sql:Error oracledbClient = new(user=user, password=password, database=database);
    test:assertTrue(oracledbClient is Client, "Initializing with username, password and database params fail");
}

// with all params except options
@test:Config {
    enable: true,
    groups:["connection","connection-init"]
}
function testWithAllParamsExceptOptions() {
    Client|sql:Error oracledbClient = new(
        user=user, 
        password=password,
        host=host,
        port=port,
        database=database
    );
    test:assertTrue(oracledbClient is Client, "Initializing with all params except options fail");
}

// with all params and options minus SSL
@test:Config {
    enable: true,
    groups:["connection","connection-init"]

}
function testWithOptionsExceptSSL() {
    Client|sql:Error oracledbClient = new(
        user=user,
        password=password,
        host=host,
        port=port,
        database=database,
        options=options);
    test:assertTrue(oracledbClient is Client, "Initializing with options fail");
}

// with all params, options and connection Pool
@test:Config {
   enable: true,
   groups:["connection","connection-init"]
}
function testWithConnectionPoolParam() {
    Client|sql:Error oracledbClient = new(
        user=user,
        password=password,
        host=host,
        port=port,
        database=database,
        connectionPool=connectionPool
    );
    test:assertTrue(oracledbClient is Client, "Initializing with connection pool param fail");
}

