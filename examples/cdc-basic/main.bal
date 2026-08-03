// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/data.jsondata;
import ballerina/log;
import ballerina/os;
import ballerinax/cdc;
import ballerinax/oracledb;
import ballerinax/oracledb.cdc.driver as _;

configurable string username = os:getEnv("DB_USERNAME");
configurable string password = os:getEnv("DB_PASSWORD");

listener oracledb:CdcListener orderDBListener = new (
    database = {
        username,
        password,
        databaseName: "FREE",
        pdbName: "FREEPDB1",
        includedTables: "SCOTT\\.ORDERS"
    },
    options = {
        snapshotMode: cdc:NO_DATA
    }
);

@cdc:ServiceConfig {
    tables: "FREEPDB1.SCOTT.ORDERS"
}
service cdc:Service on orderDBListener {
    isolated remote function onCreate(Orders newOrder) returns error? {
        log:printInfo(`Order created: ${newOrder.toString()}`);
    }

    isolated remote function onUpdate(Orders before, Orders after) returns error? {
        log:printInfo(`Order ${after.orderId} updated: status ${before.status} -> ${after.status}`);
    }

    isolated remote function onDelete(Orders before) returns error? {
        log:printInfo(`Order deleted: ${before.toString()}`);
    }

    isolated remote function onError(cdc:Error e) {
        log:printError(`CDC error: ${e.message()}`);
    }
}

type Orders record {|
    @jsondata:Name {value: "ORDER_ID"}
    decimal orderId;
    @jsondata:Name {value: "CUSTOMER_ID"}
    decimal customerId;
    @jsondata:Name {value: "AMOUNT"}
    decimal amount;
    @jsondata:Name {value: "STATUS"}
    string status;
|};
