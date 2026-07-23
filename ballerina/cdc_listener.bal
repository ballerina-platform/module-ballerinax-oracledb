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

import ballerinax/cdc;

# Represents the Ballerina Oracle CDC Listener.
public isolated class CdcListener {
    *cdc:Listener;

    private final map<string> & readonly debeziumConfigs;
    private final map<anydata> & readonly listenerConfigs;

    # Initializes the Oracle listener with the given configuration.
    #
    # + config - The configuration for the Oracle CDC connector
    # + return - A `cdc:Error` if the configuration is invalid, or `()` if initialization succeeds
    public isolated function init(*OracleListenerConfiguration config) returns cdc:Error? {
        check validateConfig(config);
        map<string> debeziumConfigs = {};
        map<anydata> listenerConfigs = {};
        populateDebeziumProperties(config, debeziumConfigs);
        cdc:populateListenerProperties(config, listenerConfigs);
        self.debeziumConfigs = debeziumConfigs.cloneReadOnly();
        self.listenerConfigs = listenerConfigs.cloneReadOnly();
    }

    # Attaches a CDC service to the Oracle listener.
    #
    # + s - The CDC service to attach
    # + name - Attachment points
    # + return - A `cdc:Error` if the service cannot be attached, or `()` if successful
    public isolated function attach(cdc:Service s, string[]|string? name = ()) returns cdc:Error? {
        check cdc:externAttach(self, s);
    }

    # Starts the Oracle listener.
    #
    # + return - A `cdc:Error` if the listener cannot be started, or `()` if successful
    public isolated function 'start() returns cdc:Error? {
        check cdc:externStartWithExtendedConfigs(self, self.debeziumConfigs, self.listenerConfigs);
    }

    # Detaches a CDC service from the Oracle listener.
    #
    # + s - The CDC service to detach
    # + return - A `cdc:Error` if the service cannot be detached, or `()` if successful
    public isolated function detach(cdc:Service s) returns cdc:Error? {
        check cdc:externDetach(self, s);
    }

    # Stops the Oracle listener gracefully.
    #
    # + return - A `cdc:Error` if the listener cannot be stopped, or `()` if successful
    public isolated function gracefulStop() returns cdc:Error? {
        check cdc:externGracefulStop(self);
    }

    # Stops the Oracle listener immediately.
    #
    # + return - A `cdc:Error` if the listener cannot be stopped, or `()` if successful
    public isolated function immediateStop() returns cdc:Error? {
        check cdc:externImmediateStop(self);
    }
}

isolated function validateConfig(OracleListenerConfiguration config) returns cdc:Error? {
    OracleDatabaseConnection database = config.database;

    if database?.secure !is () {
        return error cdc:Error(
            "`database.secure` is not supported; the Oracle connector does not read `database.ssl.*` " +
            "properties. Configure TLS via `database.driverConfig.mtls` (Java keystore/truststore, " +
            "or an Oracle Wallet location string) instead.");
    }

    // Mutually-exclusive include / exclude pairs
    if database?.includedSchemas !is () && database?.excludedSchemas !is () {
        return error cdc:Error("`database.includedSchemas` and `database.excludedSchemas` are mutually exclusive; set only one.");
    }
    if database?.includedTables !is () && database?.excludedTables !is () {
        return error cdc:Error("`database.includedTables` and `database.excludedTables` are mutually exclusive; set only one.");
    }
    if database?.includedColumns !is () && database?.excludedColumns !is () {
        return error cdc:Error("`database.includedColumns` and `database.excludedColumns` are mutually exclusive; set only one.");
    }

    LogMinerConfiguration? logMinerConfig = database?.logMinerConfig;
    if logMinerConfig is LogMinerConfiguration {
        if logMinerConfig?.includedUsernames !is () && logMinerConfig?.excludedUsernames !is () {
            return error cdc:Error("`logMinerConfig.includedUsernames` and `logMinerConfig.excludedUsernames` are mutually exclusive; set only one.");
        }
        if logMinerConfig?.includedClientIds !is () && logMinerConfig?.excludedClientIds !is () {
            return error cdc:Error("`logMinerConfig.includedClientIds` and `logMinerConfig.excludedClientIds` are mutually exclusive; set only one.");
        }

        // HYBRID mining strategy is incompatible with lobEnabled
        if logMinerConfig.strategy == HYBRID && config.options.lobEnabled {
            return error cdc:Error("`logMinerConfig.strategy = HYBRID` is incompatible with `options.lobEnabled = true`; LOB capture requires `ONLINE_CATALOG` or `REDO_LOG_CATALOG`.");
        }

        if database.adapterMode == LOGMINER_UNBUFFERED && logMinerConfig?.buffer !is () {
            logUnbufferedAdapterBufferWarning();
        }
    }

    // Custom Java SPI hooks are not supported in V1
    if config.options.snapshotMode == cdc:CUSTOM {
        return error cdc:Error("`options.snapshotMode = CUSTOM` is not supported; custom Java SPI hooks are unavailable.");
    }
    OracleExtendedSnapshotConfiguration? extendedSnapshot = config.options?.extendedSnapshot;
    if extendedSnapshot is OracleExtendedSnapshotConfiguration {
        cdc:SnapshotLockingMode? lockingMode = extendedSnapshot?.lockingMode;
        if lockingMode is cdc:SnapshotLockingMode && <string>lockingMode == cdc:CUSTOM {
            return error cdc:Error("`options.extendedSnapshot.lockingMode = CUSTOM` is not supported; custom Java SPI hooks are unavailable.");
        }
        cdc:SnapshotQueryMode? queryMode = extendedSnapshot?.queryMode;
        if queryMode is cdc:SnapshotQueryMode && <string>queryMode == cdc:CUSTOM {
            return error cdc:Error("`options.extendedSnapshot.queryMode = CUSTOM` is not supported; custom Java SPI hooks are unavailable.");
        }
    }
}
