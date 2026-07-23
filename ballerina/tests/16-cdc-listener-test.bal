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

// CDC property-mapping and validation tests. These tests exercise the listener
// configuration → Debezium property map translation without spinning up an Oracle
// instance and without depending on the `ballerinax/oracledb.cdc.driver` package.
// Live-Oracle integration tests are intentionally deferred to a follow-up.

import ballerina/test;
import ballerinax/cdc;

const string CDC_GROUP = "cdc";

function buildConfigsFor(OracleListenerConfiguration config) returns map<string> {
    map<string> debeziumConfigs = {};
    populateDebeziumProperties(config, debeziumConfigs);
    return debeziumConfigs;
}

function minimalConfig() returns OracleListenerConfiguration {
    return {
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB"
        }
    };
}

// ============================================================================
// Default values
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testDefaultDatabaseConfigurations() {
    map<string> configs = buildConfigsFor(minimalConfig());

    test:assertEquals(configs["connector.class"], "io.debezium.connector.oracle.OracleConnector");
    test:assertEquals(configs["database.dbname"], "ORCLCDB");
    test:assertEquals(configs["database.connection.adapter"], "logminer");
    test:assertEquals(configs["database.user"], "scott");
    test:assertEquals(configs["database.password"], "tiger");
    test:assertEquals(configs["tasks.max"], "1");
}

@test:Config {groups: [CDC_GROUP]}
function testDefaultOracleOptions() {
    map<string> configs = buildConfigsFor(minimalConfig());

    test:assertEquals(configs["query.fetch.size"], "10000");
    test:assertEquals(configs["lob.enabled"], "false");
    test:assertEquals(configs["unavailable.value.placeholder"], "__debezium_unavailable_value");
    test:assertEquals(configs["snapshot.database.errors.max.retries"], "0");
}

// ============================================================================
// Adapter and PDB
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testAdapterLogMinerUnbuffered() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.adapterMode = LOGMINER_UNBUFFERED;
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["database.connection.adapter"], "logminer_unbuffered");
}

@test:Config {groups: [CDC_GROUP]}
function testPdbName() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.pdbName = "ORCLPDB1";
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["database.pdb.name"], "ORCLPDB1");
}

// ============================================================================
// URL precedence
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testUrlOnlyOverridesHostnameAndPort() {
    OracleListenerConfiguration config = {
        database: {
            username: "scott",
            password: "tiger",
            url: "jdbc:oracle:thin:@//db.example.com:1521/ORCLPDB1",
            hostname: "ignored",
            port: 9999,
            databaseName: "ORCLCDB",
            racNodes: ["nodeA:1521", "nodeB:1521"]
        }
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["database.url"], "jdbc:oracle:thin:@//db.example.com:1521/ORCLPDB1");
    test:assertFalse(configs.hasKey("database.hostname"), "hostname must not be emitted when url is set");
    test:assertFalse(configs.hasKey("database.port"), "port must not be emitted when url is set");
    test:assertEquals(configs["database.dbname"], "ORCLCDB");
    test:assertEquals(configs["rac.nodes"], "nodeA:1521,nodeB:1521");
}

@test:Config {groups: [CDC_GROUP]}
function testRacNodesAsArrayJoinedCsv() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.racNodes = ["nodeA:1521", "nodeB:1521", "nodeC:1521"];
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["rac.nodes"], "nodeA:1521,nodeB:1521,nodeC:1521");
}

@test:Config {groups: [CDC_GROUP]}
function testRacNodesAsString() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.racNodes = "nodeA:1521,nodeB:1521";
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["rac.nodes"], "nodeA:1521,nodeB:1521");
}

// ============================================================================
// Schema / table / column filtering
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testIncludedSchemasAsArray() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.includedSchemas = ["HR", "SCOTT"];
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["schema.include.list"], "HR,SCOTT");
}

@test:Config {groups: [CDC_GROUP]}
function testExcludedSchemasAsString() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.excludedSchemas = "SYS|SYSTEM";
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["schema.exclude.list"], "SYS|SYSTEM");
}

// ============================================================================
// LogMiner
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testLogMinerCoreFields() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.logMinerConfig = {
        strategy: REDO_LOG_CATALOG,
        queryFilterMode: REGEX,
        readOnlyHostname: "standby.example.com",
        flushTableName: "MY_FLUSH_TABLE",
        sessionMaxDuration: 30,
        restartConnection: true,
        archive: {
            logHours: 24,
            logOnlyMode: true,
            logOnlyScnPollInterval: 5
        },
        transactionRetentionTime: 4,
        maxWindowTime: 120,
        scnGapDetectionMinSize: 500000,
        scnGapDetectionMaxInterval: 10
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["log.mining.strategy"], "redo_log_catalog");
    test:assertEquals(configs["log.mining.query.filter.mode"], "regex");
    test:assertEquals(configs["log.mining.readonly.hostname"], "standby.example.com");
    test:assertEquals(configs["log.mining.include.redo.sql"], "true");
    test:assertEquals(configs["log.mining.flush.table.name"], "MY_FLUSH_TABLE");
    test:assertEquals(configs["log.mining.session.max.ms"], "30000");
    test:assertEquals(configs["log.mining.restart.connection"], "true");
    test:assertEquals(configs["archive.log.hours"], "24");
    test:assertEquals(configs["log.mining.archive.log.only.mode"], "true");
    test:assertEquals(configs["log.mining.archive.log.only.scn.poll.interval.ms"], "5000");
    test:assertEquals(configs["log.mining.transaction.retention.ms"], "4000");
    test:assertEquals(configs["log.mining.window.max.ms"], "120000");
    test:assertEquals(configs["log.mining.scn.gap.detection.gap.size.min"], "500000");
    test:assertEquals(configs["log.mining.scn.gap.detection.time.interval.max.ms"], "10000");
}

@test:Config {groups: [CDC_GROUP]}
function testLogMinerBufferEmitsMemoryType() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.logMinerConfig = {
        buffer: {
            trackRsId: false,
            transactionEventsThreshold: 1000
        }
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["log.mining.buffer.type"], "memory");
    test:assertEquals(configs["log.mining.buffer.track.rs_id"], "false");
    test:assertEquals(configs["log.mining.buffer.transaction.events.threshold"], "1000");
    test:assertEquals(configs["log.mining.buffer.drop.on.stop"], "true");
}

@test:Config {groups: [CDC_GROUP]}
function testLogMinerBatchAndSleep() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.logMinerConfig = {
        batch: {minSize: 2000, maxSize: 50000, incrementSize: 5000, defaultSize: 10000},
        sleep: {minTime: 0.5, maxTime: 5, defaultTime: 2, incrementTime: 0.25}
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["log.mining.batch.size.min"], "2000");
    test:assertEquals(configs["log.mining.batch.size.max"], "50000");
    test:assertEquals(configs["log.mining.batch.size.increment"], "5000");
    test:assertEquals(configs["log.mining.batch.size.default"], "10000");
    test:assertEquals(configs["log.mining.sleep.time.min.ms"], "500");
    test:assertEquals(configs["log.mining.sleep.time.max.ms"], "5000");
    test:assertEquals(configs["log.mining.sleep.time.default.ms"], "2000");
    test:assertEquals(configs["log.mining.sleep.time.increment.ms"], "250");
}

@test:Config {groups: [CDC_GROUP]}
function testLogMinerUsernameAndClientIdFiltering() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.logMinerConfig = {
        includedUsernames: ["APP_USER", "BATCH_USER"],
        includedClientIds: "client-1,client-2"
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["log.mining.username.include.list"], "APP_USER,BATCH_USER");
    test:assertEquals(configs["log.mining.clientid.include.list"], "client-1,client-2");
}

// ============================================================================
// Driver pass-through
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testDriverSslPassthrough() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.driverConfig = {
        mtls: {
            keyStore: {path: "/etc/oracle/ks.p12", password: "secret", storeType: "PKCS12"},
            trustStore: {path: "/etc/oracle/ts.jks", password: "trust"}
        },
        timezoneAsRegion: false
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["driver.javax.net.ssl.keyStore"], "/etc/oracle/ks.p12");
    test:assertEquals(configs["driver.javax.net.ssl.keyStorePassword"], "secret");
    test:assertEquals(configs["driver.javax.net.ssl.keyStoreType"], "PKCS12");
    test:assertEquals(configs["driver.javax.net.ssl.trustStore"], "/etc/oracle/ts.jks");
    test:assertEquals(configs["driver.javax.net.ssl.trustStorePassword"], "trust");
    test:assertEquals(configs["driver.javax.net.ssl.trustStoreType"], "JKS");
    test:assertEquals(configs["driver.oracle.jdbc.timezoneAsRegion"], "false");
}

@test:Config {groups: [CDC_GROUP]}
function testDriverWalletPassthrough() {
    OracleListenerConfiguration config = minimalConfig();
    config.database.driverConfig = {
        mtls: "/etc/oracle/wallet",
        timezoneAsRegion: false
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["driver.oracle.net.wallet_location"], "/etc/oracle/wallet");
    test:assertEquals(configs["driver.oracle.jdbc.timezoneAsRegion"], "false");
}

// ============================================================================
// OracleOptions extras + extended snapshot + data type
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testOracleOptionsExtras() {
    OracleListenerConfiguration config = minimalConfig();
    config.options = {
        streamingDelay: 3,
        queryFetchSize: 5000,
        lobEnabled: true,
        unavailableValuePlaceholder: "__N/A__",
        snapshotDatabaseErrorsMaxRetries: 3
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["streaming.delay.ms"], "3000");
    test:assertEquals(configs["query.fetch.size"], "5000");
    test:assertEquals(configs["lob.enabled"], "true");
    test:assertEquals(configs["unavailable.value.placeholder"], "__N/A__");
    test:assertEquals(configs["snapshot.database.errors.max.retries"], "3");
}

@test:Config {groups: [CDC_GROUP]}
function testConfigurationBasedSnapshotSubFlags() {
    OracleListenerConfiguration config = minimalConfig();
    config.options.snapshotMode = cdc:CONFIGURATION_BASED;
    config.options.extendedSnapshot = {
        configurationBased: {
            includeData: true,
            includeSchema: true,
            startStream: true,
            snapshotOnSchemaError: true,
            snapshotOnDataError: false
        }
    };
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["snapshot.mode"], "configuration_based");
    test:assertEquals(configs["snapshot.mode.configuration.based.snapshot.data"], "true");
    test:assertEquals(configs["snapshot.mode.configuration.based.snapshot.schema"], "true");
    test:assertEquals(configs["snapshot.mode.configuration.based.start.stream"], "true");
    test:assertEquals(configs["snapshot.mode.configuration.based.snapshot.on.schema.error"], "true");
    test:assertEquals(configs["snapshot.mode.configuration.based.snapshot.on.data.error"], "false");
}

@test:Config {groups: [CDC_GROUP]}
function testIntervalHandlingMode() {
    OracleListenerConfiguration config = minimalConfig();
    config.options.dataTypeConfig = {intervalHandlingMode: STRING};
    map<string> configs = buildConfigsFor(config);

    test:assertEquals(configs["interval.handling.mode"], "string");
}

// ============================================================================
// Validation: unsupported inherited fields
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testDatabaseSecureIsRejected() {
    CdcListener|cdc:Error result = new ({
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB",
            secure: {}
        }
    });
    test:assertTrue(result is cdc:Error);
    if result is cdc:Error {
        test:assertTrue(result.message().includes("secure"));
    }
}

// ============================================================================
// Validation: mutually exclusive include/exclude
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testIncludedAndExcludedSchemasIsRejected() {
    CdcListener|cdc:Error result = new ({
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB",
            includedSchemas: "HR",
            excludedSchemas: "SYS"
        }
    });
    test:assertTrue(result is cdc:Error);
    if result is cdc:Error {
        test:assertTrue(result.message().includes("includedSchemas"));
        test:assertTrue(result.message().includes("excludedSchemas"));
    }
}

@test:Config {groups: [CDC_GROUP]}
function testIncludedAndExcludedTablesIsRejected() {
    CdcListener|cdc:Error result = new ({
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB",
            includedTables: "T1",
            excludedTables: "T2"
        }
    });
    test:assertTrue(result is cdc:Error);
}

@test:Config {groups: [CDC_GROUP]}
function testLogMinerIncludedAndExcludedUsernamesIsRejected() {
    CdcListener|cdc:Error result = new ({
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB",
            logMinerConfig: {
                includedUsernames: "U1",
                excludedUsernames: "U2"
            }
        }
    });
    test:assertTrue(result is cdc:Error);
    if result is cdc:Error {
        test:assertTrue(result.message().includes("Usernames"));
    }
}

@test:Config {groups: [CDC_GROUP]}
function testHybridStrategyWithLobEnabledIsRejected() {
    CdcListener|cdc:Error result = new ({
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB",
            logMinerConfig: {strategy: HYBRID}
        },
        options: {lobEnabled: true}
    });
    test:assertTrue(result is cdc:Error);
    if result is cdc:Error {
        test:assertTrue(result.message().includes("HYBRID"));
        test:assertTrue(result.message().includes("lobEnabled"));
    }
}

@test:Config {groups: [CDC_GROUP]}
function testCustomSnapshotModeIsRejected() {
    CdcListener|cdc:Error result = new ({
        database: {username: "scott", password: "tiger", databaseName: "ORCLCDB"},
        options: {snapshotMode: cdc:CUSTOM}
    });
    test:assertTrue(result is cdc:Error);
}

// ============================================================================
// Happy-path listener init
// ============================================================================

@test:Config {groups: [CDC_GROUP]}
function testListenerInitWithMinimalConfig() returns cdc:Error? {
    OracleListenerConfiguration config = minimalConfig();
    CdcListener cdcListener = check new (config);
    _ = cdcListener;

    map<string> configs = buildConfigsFor(config);
    test:assertEquals(configs["database.dbname"], "ORCLCDB", msg = "Database name does not match.");
}

@test:Config {groups: [CDC_GROUP]}
function testListenerInitWithUrlAndDriverConfig() returns cdc:Error? {
    OracleListenerConfiguration config = {
        database: {
            username: "scott",
            password: "tiger",
            databaseName: "ORCLCDB",
            url: "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)(HOST=db.example.com)(PORT=2484))(CONNECT_DATA=(SERVICE_NAME=ORCLPDB1)))",
            driverConfig: {
                mtls: {
                    keyStore: {path: "/etc/oracle/ks.jks", password: "secret"}
                }
            }
        }
    };
    CdcListener cdcListener = check new (config);
    _ = cdcListener;

    map<string> configs = buildConfigsFor(config);
    test:assertEquals(configs["database.url"], config.database.url, msg = "Database URL does not match.");
    test:assertEquals(configs["database.dbname"], "ORCLCDB",
        msg = "Database name does not match even though `url` is also set.");
}
