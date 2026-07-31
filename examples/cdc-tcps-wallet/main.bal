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

import ballerina/log;
import ballerina/os;
import ballerinax/cdc;
import ballerinax/oracledb;
import ballerinax/oracledb.cdc.driver as _;

configurable string username = os:getEnv("DB_USERNAME");
configurable string password = os:getEnv("DB_PASSWORD");
configurable string walletLocation = "./wallet";

// Full TNS connect string pointing at a TCPS (mTLS) listener. Must target the root container's
// service (not the PDB's service) — LogMiner (DBMS_LOGMNR) can only be driven from the CDB root;
// `pdbName` below tells the connector which pluggable database to capture from.
configurable string tcpsUrl =
    "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)(HOST=localhost)(PORT=2484))"
    + "(CONNECT_DATA=(SERVICE_NAME=FREE)))";

listener oracledb:CdcListener secureListener = new (
    database = {
        username,
        password,
        databaseName: "FREE",
        pdbName: "FREEPDB1",
        url: tcpsUrl,
        driverConfig: {
            mtls: walletLocation,
            // Set to false when the Oracle JDBC driver complains with ORA-01882
            // ("timezone region not found") because the client OS timezone is
            // not registered in v$timezone_names.
            timezoneAsRegion: false
        }
    },
    options = {
        snapshotMode: cdc:NO_DATA,
        // Use STRING for ISO-8601 interval representation; easier to consume downstream.
        dataTypeConfig: {intervalHandlingMode: oracledb:STRING}
    }
);

service cdc:Service on secureListener {
    isolated remote function onCreate(record {} after, string tableName) returns error? {
        log:printInfo(`Create on ${tableName}: ${after.toString()}`);
    }

    isolated remote function onUpdate(record {} before, record {} after, string tableName) returns error? {
        log:printInfo(`Update on ${tableName}: ${after.toString()}`);
    }

    isolated remote function onDelete(record {} before, string tableName) returns error? {
        log:printInfo(`Delete on ${tableName}: ${before.toString()}`);
    }

    isolated remote function onError(cdc:Error e) {
        log:printError(`CDC error: ${e.message()}`);
    }
}
