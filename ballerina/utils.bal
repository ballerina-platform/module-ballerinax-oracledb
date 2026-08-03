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
import ballerinax/cdc;

// ============================================================================
// Oracle-specific Debezium property keys
// ============================================================================

// Database connection
const string ORACLE_DATABASE_NAME = "database.dbname";
const string ORACLE_DATABASE_URL = "database.url";
const string ORACLE_PDB_NAME = "database.pdb.name";
const string ORACLE_CONNECTION_ADAPTER = "database.connection.adapter";
const string ORACLE_RAC_NODES = "rac.nodes";
const string SCHEMA_INCLUDE_LIST = "schema.include.list";
const string SCHEMA_EXCLUDE_LIST = "schema.exclude.list";

// LogMiner
const string LOG_MINING_STRATEGY = "log.mining.strategy";
const string LOG_MINING_INCLUDE_REDO_SQL = "log.mining.include.redo.sql";
const string LOG_MINING_QUERY_FILTER_MODE = "log.mining.query.filter.mode";
const string LOG_MINING_READONLY_HOSTNAME = "log.mining.readonly.hostname";
const string LOG_MINING_FLUSH_TABLE_NAME = "log.mining.flush.table.name";
const string LOG_MINING_SESSION_MAX_MS = "log.mining.session.max.ms";
const string LOG_MINING_RESTART_CONNECTION = "log.mining.restart.connection";
const string LOG_MINING_ARCHIVE_LOG_HOURS = "archive.log.hours";
const string LOG_MINING_ARCHIVE_DESTINATION_NAME = "archive.destination.name";
const string LOG_MINING_ARCHIVE_LOG_ONLY_MODE = "log.mining.archive.log.only.mode";
const string LOG_MINING_ARCHIVE_LOG_ONLY_SCN_POLL_INTERVAL_MS = "log.mining.archive.log.only.scn.poll.interval.ms";
const string LOG_MINING_TRANSACTION_RETENTION_MS = "log.mining.transaction.retention.ms";
const string LOG_MINING_WINDOW_MAX_MS = "log.mining.window.max.ms";
const string LOG_MINING_USERNAME_INCLUDE_LIST = "log.mining.username.include.list";
const string LOG_MINING_USERNAME_EXCLUDE_LIST = "log.mining.username.exclude.list";
const string LOG_MINING_CLIENTID_INCLUDE_LIST = "log.mining.clientid.include.list";
const string LOG_MINING_CLIENTID_EXCLUDE_LIST = "log.mining.clientid.exclude.list";
const string LOG_MINING_SCN_GAP_DETECTION_GAP_SIZE_MIN = "log.mining.scn.gap.detection.gap.size.min";
const string LOG_MINING_SCN_GAP_DETECTION_TIME_INTERVAL_MAX_MS = "log.mining.scn.gap.detection.time.interval.max.ms";

// LogMiner buffer
const string LOG_MINING_BUFFER_TYPE = "log.mining.buffer.type";
const string LOG_MINING_BUFFER_TYPE_MEMORY = "memory";
const string LOG_MINING_BUFFER_TRACK_RS_ID = "log.mining.buffer.track.rs_id";
const string LOG_MINING_BUFFER_TRANSACTION_EVENTS_THRESHOLD = "log.mining.buffer.transaction.events.threshold";
const string LOG_MINING_BUFFER_DROP_ON_STOP = "log.mining.buffer.drop.on.stop";

// LogMiner batch / sleep
const string LOG_MINING_BATCH_SIZE_MIN = "log.mining.batch.size.min";
const string LOG_MINING_BATCH_SIZE_MAX = "log.mining.batch.size.max";
const string LOG_MINING_BATCH_SIZE_INCREMENT = "log.mining.batch.size.increment";
const string LOG_MINING_BATCH_SIZE_DEFAULT = "log.mining.batch.size.default";
const string LOG_MINING_SLEEP_TIME_MIN_MS = "log.mining.sleep.time.min.ms";
const string LOG_MINING_SLEEP_TIME_MAX_MS = "log.mining.sleep.time.max.ms";
const string LOG_MINING_SLEEP_TIME_DEFAULT_MS = "log.mining.sleep.time.default.ms";
const string LOG_MINING_SLEEP_TIME_INCREMENT_MS = "log.mining.sleep.time.increment.ms";

// Driver pass-through
const string DRIVER_SSL_KEYSTORE = "driver.javax.net.ssl.keyStore";
const string DRIVER_SSL_KEYSTORE_PASSWORD = "driver.javax.net.ssl.keyStorePassword";
const string DRIVER_SSL_KEYSTORE_TYPE = "driver.javax.net.ssl.keyStoreType";
const string DRIVER_SSL_TRUSTSTORE = "driver.javax.net.ssl.trustStore";
const string DRIVER_SSL_TRUSTSTORE_PASSWORD = "driver.javax.net.ssl.trustStorePassword";
const string DRIVER_SSL_TRUSTSTORE_TYPE = "driver.javax.net.ssl.trustStoreType";
const string DRIVER_ORACLE_WALLET_LOCATION = "driver.oracle.net.wallet_location";
const string DRIVER_ORACLE_TIMEZONE_AS_REGION = "driver.oracle.jdbc.timezoneAsRegion";

// OracleOptions extras
const string STREAMING_DELAY_MS = "streaming.delay.ms";
const string QUERY_FETCH_SIZE = "query.fetch.size";
const string LOB_ENABLED = "lob.enabled";
const string UNAVAILABLE_VALUE_PLACEHOLDER = "unavailable.value.placeholder";
const string SNAPSHOT_DATABASE_ERRORS_MAX_RETRIES = "snapshot.database.errors.max.retries";

// Configuration-based snapshot sub-flags
const string SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_DATA = "snapshot.mode.configuration.based.snapshot.data";
const string SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_SCHEMA = "snapshot.mode.configuration.based.snapshot.schema";
const string SNAPSHOT_MODE_CONFIGURATION_BASED_START_STREAM = "snapshot.mode.configuration.based.start.stream";
const string SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_ON_SCHEMA_ERROR = "snapshot.mode.configuration.based.snapshot.on.schema.error";
const string SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_ON_DATA_ERROR = "snapshot.mode.configuration.based.snapshot.on.data.error";

// Data type
const string INTERVAL_HANDLING_MODE = "interval.handling.mode";

// ============================================================================
// Orchestrator
// ============================================================================

isolated function populateDebeziumProperties(OracleListenerConfiguration config, map<string> debeziumConfigs) {
    cdc:populateDebeziumProperties({
        engineName: config.engineName,
        offsetStorage: config.offsetStorage,
        internalSchemaStorage: config.internalSchemaStorage,
        database: config.database,
        options: config.options
    }, debeziumConfigs);
    populateDatabaseConfigurations(config.database, debeziumConfigs);
    populateOptions(config.options, debeziumConfigs);
}

// ============================================================================
// Database connection
// ============================================================================

isolated function populateDatabaseConfigurations(OracleDatabaseConnection database, map<string> debeziumConfigs) {
    string? url = database?.url;

    debeziumConfigs[ORACLE_DATABASE_NAME] = database.databaseName;

    string|string[]? racNodes = database?.racNodes;
    if racNodes is string {
        debeziumConfigs[ORACLE_RAC_NODES] = racNodes;
    } else if racNodes is string[] {
        debeziumConfigs[ORACLE_RAC_NODES] = string:'join(",", ...racNodes);
    }

    if url is string {
        debeziumConfigs[ORACLE_DATABASE_URL] = url;
        // hostname / port are silently ignored when url is set
        _ = debeziumConfigs.removeIfHasKey("database.hostname");
        _ = debeziumConfigs.removeIfHasKey("database.port");
    }

    string? pdbName = database?.pdbName;
    if pdbName is string {
        debeziumConfigs[ORACLE_PDB_NAME] = pdbName;
    }

    debeziumConfigs[ORACLE_CONNECTION_ADAPTER] = database.adapterMode;

    populateSchemaConfigurations(database, debeziumConfigs);

    cdc:populateTableAndColumnConfigurations(
        database?.includedTables,
        database?.excludedTables,
        database?.includedColumns,
        database?.excludedColumns,
        debeziumConfigs
    );

    LogMinerConfiguration? logMinerConfig = database?.logMinerConfig;
    if logMinerConfig is LogMinerConfiguration {
        populateLogMinerProperties(logMinerConfig, debeziumConfigs);
    }

    DriverConfiguration? driverConfig = database?.driverConfig;
    if driverConfig is DriverConfiguration {
        populateDriverProperties(driverConfig, debeziumConfigs);
    }
}

isolated function populateSchemaConfigurations(OracleDatabaseConnection connection, map<string> debeziumConfigs) {
    string|string[]? includedSchemas = connection?.includedSchemas;
    if includedSchemas is string {
        debeziumConfigs[SCHEMA_INCLUDE_LIST] = includedSchemas;
    } else if includedSchemas is string[] {
        debeziumConfigs[SCHEMA_INCLUDE_LIST] = string:'join(",", ...includedSchemas);
    }

    string|string[]? excludedSchemas = connection?.excludedSchemas;
    if excludedSchemas is string {
        debeziumConfigs[SCHEMA_EXCLUDE_LIST] = excludedSchemas;
    } else if excludedSchemas is string[] {
        debeziumConfigs[SCHEMA_EXCLUDE_LIST] = string:'join(",", ...excludedSchemas);
    }
}

// ============================================================================
// LogMiner
// ============================================================================

isolated function populateLogMinerProperties(LogMinerConfiguration config, map<string> debeziumConfigs) {
    debeziumConfigs[LOG_MINING_STRATEGY] = config.strategy;
    debeziumConfigs[LOG_MINING_INCLUDE_REDO_SQL] = (config.strategy == REDO_LOG_CATALOG).toString();
    debeziumConfigs[LOG_MINING_QUERY_FILTER_MODE] = config.queryFilterMode;
    string? readOnlyHostname = config?.readOnlyHostname;
    if readOnlyHostname is string {
        debeziumConfigs[LOG_MINING_READONLY_HOSTNAME] = readOnlyHostname;
    }
    debeziumConfigs[LOG_MINING_FLUSH_TABLE_NAME] = config.flushTableName;

    LogMinerMemoryBufferConfiguration? buffer = config?.buffer;
    if buffer is LogMinerMemoryBufferConfiguration {
        populateLogMinerBufferProperties(buffer, debeziumConfigs);
    }

    decimal? sessionMaxDuration = config.sessionMaxDuration;
    if sessionMaxDuration is decimal {
        debeziumConfigs[LOG_MINING_SESSION_MAX_MS] = getMillisecondValueOf(sessionMaxDuration);
    }

    debeziumConfigs[LOG_MINING_RESTART_CONNECTION] = config.restartConnection.toString();

    LogMinerBatchConfiguration? batch = config?.batch;
    if batch is LogMinerBatchConfiguration {
        populateLogMinerBatchProperties(batch, debeziumConfigs);
    }

    LogMinerSleepConfiguration? sleep = config?.sleep;
    if sleep is LogMinerSleepConfiguration {
        populateLogMinerSleepProperties(sleep, debeziumConfigs);
    }

    LogMinerArchiveLogConfiguration? archive = config?.archive;
    if archive is LogMinerArchiveLogConfiguration {
        populateLogMinerArchiveLogProperties(archive, debeziumConfigs);
    }

    decimal? transactionRetentionTime = config.transactionRetentionTime;
    if transactionRetentionTime is decimal {
        debeziumConfigs[LOG_MINING_TRANSACTION_RETENTION_MS] = getMillisecondValueOf(transactionRetentionTime);
    }

    decimal? windowMax = config.maxWindowTime;
    if windowMax is decimal {
        debeziumConfigs[LOG_MINING_WINDOW_MAX_MS] = getMillisecondValueOf(windowMax);
    }

    string|string[]? includedUsernames = config?.includedUsernames;
    if includedUsernames is string {
        debeziumConfigs[LOG_MINING_USERNAME_INCLUDE_LIST] = includedUsernames;
    } else if includedUsernames is string[] {
        debeziumConfigs[LOG_MINING_USERNAME_INCLUDE_LIST] = string:'join(",", ...includedUsernames);
    }
    string|string[]? excludedUsernames = config?.excludedUsernames;
    if excludedUsernames is string {
        debeziumConfigs[LOG_MINING_USERNAME_EXCLUDE_LIST] = excludedUsernames;
    } else if excludedUsernames is string[] {
        debeziumConfigs[LOG_MINING_USERNAME_EXCLUDE_LIST] = string:'join(",", ...excludedUsernames);
    }

    string|string[]? includedClientIds = config?.includedClientIds;
    if includedClientIds is string {
        debeziumConfigs[LOG_MINING_CLIENTID_INCLUDE_LIST] = includedClientIds;
    } else if includedClientIds is string[] {
        debeziumConfigs[LOG_MINING_CLIENTID_INCLUDE_LIST] = string:'join(",", ...includedClientIds);
    }
    string|string[]? excludedClientIds = config?.excludedClientIds;
    if excludedClientIds is string {
        debeziumConfigs[LOG_MINING_CLIENTID_EXCLUDE_LIST] = excludedClientIds;
    } else if excludedClientIds is string[] {
        debeziumConfigs[LOG_MINING_CLIENTID_EXCLUDE_LIST] = string:'join(",", ...excludedClientIds);
    }

    debeziumConfigs[LOG_MINING_SCN_GAP_DETECTION_GAP_SIZE_MIN] = config.scnGapDetectionMinSize.toString();
    debeziumConfigs[LOG_MINING_SCN_GAP_DETECTION_TIME_INTERVAL_MAX_MS] = getMillisecondValueOf(config.scnGapDetectionMaxInterval);
}

isolated function populateLogMinerBufferProperties(LogMinerMemoryBufferConfiguration buffer, map<string> debeziumConfigs) {
    debeziumConfigs[LOG_MINING_BUFFER_TYPE] = LOG_MINING_BUFFER_TYPE_MEMORY;
    debeziumConfigs[LOG_MINING_BUFFER_TRACK_RS_ID] = buffer.trackRsId.toString();
    int? transactionEventsThreshold = buffer.transactionEventsThreshold;
    if transactionEventsThreshold is int {
        debeziumConfigs[LOG_MINING_BUFFER_TRANSACTION_EVENTS_THRESHOLD] = transactionEventsThreshold.toString();
    }
}

isolated function populateLogMinerBatchProperties(LogMinerBatchConfiguration batch, map<string> debeziumConfigs) {
    debeziumConfigs[LOG_MINING_BATCH_SIZE_MIN] = batch.minSize.toString();
    debeziumConfigs[LOG_MINING_BATCH_SIZE_MAX] = batch.maxSize.toString();
    debeziumConfigs[LOG_MINING_BATCH_SIZE_INCREMENT] = batch.incrementSize.toString();
    debeziumConfigs[LOG_MINING_BATCH_SIZE_DEFAULT] = batch.defaultSize.toString();
}

isolated function populateLogMinerSleepProperties(LogMinerSleepConfiguration sleep, map<string> debeziumConfigs) {
    debeziumConfigs[LOG_MINING_SLEEP_TIME_MIN_MS] = getMillisecondValueOf(sleep.minTime);
    debeziumConfigs[LOG_MINING_SLEEP_TIME_MAX_MS] = getMillisecondValueOf(sleep.maxTime);
    debeziumConfigs[LOG_MINING_SLEEP_TIME_DEFAULT_MS] = getMillisecondValueOf(sleep.defaultTime);
    debeziumConfigs[LOG_MINING_SLEEP_TIME_INCREMENT_MS] = getMillisecondValueOf(sleep.incrementTime);
}

isolated function populateLogMinerArchiveLogProperties(LogMinerArchiveLogConfiguration archive, map<string> debeziumConfigs) {
    int? logHours = archive.logHours;
    if logHours is int {
        debeziumConfigs[LOG_MINING_ARCHIVE_LOG_HOURS] = logHours.toString();
    }

    string|string[]? destinationName = archive?.destinationName;
    if destinationName is string {
        debeziumConfigs[LOG_MINING_ARCHIVE_DESTINATION_NAME] = destinationName;
    } else if destinationName is string[] {
        debeziumConfigs[LOG_MINING_ARCHIVE_DESTINATION_NAME] = string:'join(",", ...destinationName);
    }

    debeziumConfigs[LOG_MINING_ARCHIVE_LOG_ONLY_MODE] = archive.logOnlyMode.toString();
    debeziumConfigs[LOG_MINING_ARCHIVE_LOG_ONLY_SCN_POLL_INTERVAL_MS] = getMillisecondValueOf(archive.logOnlyScnPollInterval);
}

// ============================================================================
// JDBC driver pass-through
// ============================================================================

isolated function populateDriverProperties(DriverConfiguration config, map<string> debeziumConfigs) {
    DriverSslConfiguration|string? mtls = config?.mtls;
    if mtls is DriverSslConfiguration {
        DriverKeyStore? keyStore = mtls?.keyStore;
        if keyStore is DriverKeyStore {
            debeziumConfigs[DRIVER_SSL_KEYSTORE] = keyStore.path;
            debeziumConfigs[DRIVER_SSL_KEYSTORE_PASSWORD] = keyStore.password;
            debeziumConfigs[DRIVER_SSL_KEYSTORE_TYPE] = keyStore.storeType;
        }
        DriverTrustStore? trustStore = mtls?.trustStore;
        if trustStore is DriverTrustStore {
            debeziumConfigs[DRIVER_SSL_TRUSTSTORE] = trustStore.path;
            debeziumConfigs[DRIVER_SSL_TRUSTSTORE_PASSWORD] = trustStore.password;
            debeziumConfigs[DRIVER_SSL_TRUSTSTORE_TYPE] = trustStore.storeType;
        }
    } else if mtls is string {
        debeziumConfigs[DRIVER_ORACLE_WALLET_LOCATION] = mtls;
    }

    boolean? timezoneAsRegion = config?.timezoneAsRegion;
    if timezoneAsRegion is boolean {
        debeziumConfigs[DRIVER_ORACLE_TIMEZONE_AS_REGION] = timezoneAsRegion.toString();
    }
}

// ============================================================================
// Options
// ============================================================================

isolated function populateOptions(OracleOptions options, map<string> debeziumConfigs) {
    decimal? streamingDelay = options?.streamingDelay;
    if streamingDelay is decimal {
        debeziumConfigs[STREAMING_DELAY_MS] = getMillisecondValueOf(streamingDelay);
    }
    debeziumConfigs[QUERY_FETCH_SIZE] = options.queryFetchSize.toString();
    debeziumConfigs[LOB_ENABLED] = options.lobEnabled.toString();
    debeziumConfigs[UNAVAILABLE_VALUE_PLACEHOLDER] = options.unavailableValuePlaceholder;
    debeziumConfigs[SNAPSHOT_DATABASE_ERRORS_MAX_RETRIES] = options.snapshotDatabaseErrorsMaxRetries.toString();

    OracleExtendedSnapshotConfiguration? extendedSnapshot = options?.extendedSnapshot;
    if extendedSnapshot is OracleExtendedSnapshotConfiguration {
        populateExtendedSnapshotConfiguration(extendedSnapshot, debeziumConfigs);
    }

    OracleDataTypeConfiguration? dataTypeConfig = options?.dataTypeConfig;
    if dataTypeConfig is OracleDataTypeConfiguration {
        populateOracleDataTypeConfiguration(dataTypeConfig, debeziumConfigs);
    }

    cdc:RelationalHeartbeatConfiguration? heartbeatConfig = options?.heartbeatConfig;
    if heartbeatConfig is cdc:RelationalHeartbeatConfiguration {
        cdc:populateRelationalHeartbeatConfiguration(heartbeatConfig, debeziumConfigs);
    }

    cdc:populateAdditionalConfigurations(options, debeziumConfigs, typeof options);
}

isolated function populateExtendedSnapshotConfiguration(OracleExtendedSnapshotConfiguration config, map<string> debeziumConfigs) {
    cdc:populateRelationalExtendedSnapshotConfiguration(config, debeziumConfigs);

    ConfigurationBasedSnapshot? configurationBased = config?.configurationBased;
    if configurationBased is ConfigurationBasedSnapshot {
        debeziumConfigs[SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_DATA] = configurationBased.includeData.toString();
        debeziumConfigs[SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_SCHEMA] = configurationBased.includeSchema.toString();
        debeziumConfigs[SNAPSHOT_MODE_CONFIGURATION_BASED_START_STREAM] = configurationBased.startStream.toString();
        debeziumConfigs[SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_ON_SCHEMA_ERROR] = configurationBased.snapshotOnSchemaError.toString();
        debeziumConfigs[SNAPSHOT_MODE_CONFIGURATION_BASED_SNAPSHOT_ON_DATA_ERROR] = configurationBased.snapshotOnDataError.toString();
    }
}

isolated function populateOracleDataTypeConfiguration(OracleDataTypeConfiguration config, map<string> debeziumConfigs) {
    cdc:populateDataTypeConfiguration(config, debeziumConfigs);
    debeziumConfigs[INTERVAL_HANDLING_MODE] = config.intervalHandlingMode;
}

// ============================================================================
// Helpers
// ============================================================================

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}

isolated function logUnbufferedAdapterBufferWarning() {
    log:printWarn("`logMinerConfig.buffer` is ignored when `adapterMode == LOGMINER_UNBUFFERED`; "
        + "the database performs transaction buffering in unbuffered mode.");
}
