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

# Oracle CDC adapter modes for capturing changes from the Oracle database transaction logs. LogMiner is the only adapter supported by this module.
#
# + LOGMINER - Connector-side LogMiner buffer (default)
# + LOGMINER_UNBUFFERED - Database-side LogMiner buffer; the database performs transaction buffering
public enum AdapterMode {
    LOGMINER = "logminer",
    LOGMINER_UNBUFFERED = "logminer_unbuffered"
}

# LogMiner mining strategy used when reading redo / archive logs and extracting change events.
#
# + ONLINE_CATALOG - Always use the online data dictionary (lowest overhead, no schema-change support)
# + REDO_LOG_CATALOG - Use the data dictionary written to the redo logs (supports schema changes)
# + HYBRID - Hybrid approach combining online catalog with selective redo-log lookups (incompatible with `lobEnabled`)
public enum LogMiningStrategy {
    ONLINE_CATALOG = "online_catalog",
    REDO_LOG_CATALOG = "redo_log_catalog",
    HYBRID = "hybrid"
}

# How table-include filters are applied to the LogMiner query.
#
# + NONE - Apply filters in connector code only (no SQL-level filtering)
# + IN - Apply filters using SQL `IN` predicates against table names
# + REGEX - Apply filters using `REGEXP_LIKE` predicates
public enum LogMiningQueryFilterMode {
    NONE = "none",
    IN = "in",
    REGEX = "regex"
}

# How Oracle INTERVAL data types are represented in change events.
#
# + NUMERIC - Numeric representation (microseconds for day-second, months for year-month)
# + STRING - ISO-8601 string representation
public enum IntervalHandlingMode {
    NUMERIC = "numeric",
    STRING = "string"
}

public enum StoreType {
    JKS = "JKS",
    PKCS12 = "PKCS12"

}

# Client keystore for mTLS authentication against Oracle (driver pass-through).
#
# + path - Filesystem path to the keystore file
# + password - Keystore password
# + storeType - Keystore format (JKS, PKCS12); defaults to JKS
public type DriverKeyStore record {|
    string path;
    string password;
    StoreType storeType = JKS;
|};

# Server-certificate truststore for TLS verification (driver pass-through).
#
# + path - Filesystem path to the truststore file
# + password - Truststore password
# + storeType - Truststore format (JKS, PKCS12); defaults to JKS
public type DriverTrustStore record {|
    string path;
    string password;
    StoreType storeType = JKS;
|};

# JDBC driver SSL/TLS keystore and truststore configuration for mTLS connections to Oracle.
#
# + keyStore - Client keystore (`driver.javax.net.ssl.keyStore*`)
# + trustStore - Server certificate truststore (`driver.javax.net.ssl.trustStore*`)
public type DriverSslConfiguration record {|
    DriverKeyStore keyStore?;
    DriverTrustStore trustStore?;
|};

# Oracle JDBC driver pass-through configuration.
# All values are emitted with the `driver.` prefix as Debezium pass-through properties.
#
# + mtls - mTLS client authentication for Oracle — supply either a Java keystore/truststore
#          (`DriverSslConfiguration`, mapped to `driver.javax.net.ssl.*`) or an Oracle Wallet
#          location string (mapped to `driver.oracle.net.wallet_location`). These are two
#          alternative methods per Debezium's docs, not combinable.
# + timezoneAsRegion - Whether the JDBC driver should resolve timezone as a region
#                      (`driver.oracle.jdbc.timezoneAsRegion`). Set to `false` to work around
#                      ORA-01882 "timezone region not found".
public type DriverConfiguration record {|
    DriverSslConfiguration|string mtls?;
    boolean timezoneAsRegion?;
|};

# In-memory LogMiner transaction buffer tunables.
#
# + trackRsId - Track the row-id (RS_ID) of each event in the transaction buffer. 
#               Turning this off trims memory and the data pulled per LogMiner query, at the cost of losing that identifier
# + transactionEventsThreshold - Max events per transaction before abandoning the transaction. 
#                                The default is not having a transaction event threshold
public type LogMinerMemoryBufferConfiguration record {|
    boolean trackRsId = true;
    int transactionEventsThreshold?;
|};

# SCN-based LogMiner mining batch sizing. 
# SCN is a monotonically increasing integer that Oracle stamps onto every committed change in the database.
# Debezium uses the SCN as its streaming offset/position.
# 
# + minSize - Minimum SCN window size
# + maxSize - Maximum SCN window size
# + incrementSize - Amount to grow/shrink the window when adapting
# + defaultSize - Initial / fallback SCN window size
public type LogMinerBatchConfiguration record {|
    int minSize = 1000;
    int maxSize = 100000;
    int incrementSize = 20000;
    int defaultSize = 20000;
|};

# Sleep timing between LogMiner mining iterations (all values in seconds).
#
# + minTime - Minimum sleep duration
# + maxTime - Maximum sleep duration
# + defaultTime - Initial / fallback sleep duration
# + incrementTime - Amount to grow/shrink sleep when adapting
public type LogMinerSleepConfiguration record {|
    decimal minTime = 0;
    decimal maxTime = 3;
    decimal defaultTime = 1;
    decimal incrementTime = 0.2;
|};

# Archive-log mining configuration for LogMiner.
#
# + logHours - Number of hours of archive logs to scan for the start SCN.
#              If not set, the connector mines all archive logs
# + destinationName - Configured Oracle archive destination(s) to use when mining archive logs.
#                     When not set, the first valid, local configured destination is automatically selected
# + logOnlyMode - Mine only archive logs, and ignore the redo-logs.
#                 This allows reliable log mining at the cost of potentially increased latency
# + logOnlyScnPollInterval - Poll interval in seconds when waiting for a new SCN.
#                            Applicable only if `logOnlyMode` is `true`
public type LogMinerArchiveLogConfiguration record {|
    int logHours?;
    string|string[] destinationName?;
    boolean logOnlyMode = false;
    decimal logOnlyScnPollInterval = 10;
|};

# LogMiner adapter tunables. Applies to both `LOGMINER` and `LOGMINER_UNBUFFERED` adapter modes.
# When `adapterMode == LOGMINER_UNBUFFERED`, all `buffer.*` fields are accepted but ignored by the
# database-side buffer.
#
# + strategy - Mining strategy (`online_catalog` / `redo_log_catalog` / `hybrid`)
# + queryFilterMode - How table-include filters are applied to the mining query
# + readOnlyHostname - Hostname of a read-only standby to direct LogMiner queries at
# + flushTableName - Name of the internal flush table; useful for RAC deployments
# + buffer - In-memory transaction buffer tunables
# + sessionMaxDuration - Max time before closing and reopening the LogMiner session, in seconds; no limit if not set
# + restartConnection - Restart the JDBC connection when a mining session is rotated
# + batch - SCN-based batch sizing
# + sleep - Sleep timing between mining iterations
# + archive - Archive-log mining configuration
# + transactionRetentionTime - Time to retain transactions in the buffer before forced commit/rollback in seconds.
#                              If not set, transactions are retained until a commit or rollback is detected
# + maxWindowTime - Max mining window duration in seconds before forced advance of the offset. 
#                   If not set, the offset sits at the lower bound of the oldest open transaction start SCN 
#                   until it is committed or rolled back.
# + includedUsernames - Usernames whose changes to capture (mutually exclusive with `excludedUsernames`)
# + excludedUsernames - Usernames whose changes to skip (mutually exclusive with `includedUsernames`)
# + includedClientIds - JDBC client IDs whose changes to capture (mutually exclusive with `excludedClientIds`)
# + excludedClientIds - JDBC client IDs whose changes to skip (mutually exclusive with `includedClientIds`)
# + scnGapDetectionMinSize - Minimum SCN delta to consider for gap detection
# + scnGapDetectionMaxInterval - Max time window in seconds for the SCN gap detection heuristic
public type LogMinerConfiguration record {|
    LogMiningStrategy strategy = ONLINE_CATALOG;
    LogMiningQueryFilterMode queryFilterMode = NONE;
    string readOnlyHostname?;
    string flushTableName = "LOG_MINING_FLUSH";
    LogMinerMemoryBufferConfiguration buffer?;
    decimal sessionMaxDuration?;
    boolean restartConnection = false;
    LogMinerBatchConfiguration batch?;
    LogMinerSleepConfiguration sleep?;
    LogMinerArchiveLogConfiguration archive?;
    decimal transactionRetentionTime?;
    decimal maxWindowTime?;
    string|string[] includedUsernames?;
    string|string[] excludedUsernames?;
    string|string[] includedClientIds?;
    string|string[] excludedClientIds?;
    int scnGapDetectionMinSize = 1000000;
    decimal scnGapDetectionMaxInterval = 20;
|};

# Fine-grained switches used when `snapshotMode == CONFIGURATION_BASED`.
#
# + includeData - Include row data in the snapshot
# + includeSchema - Include schema (DDL) in the snapshot
# + startStream - Start streaming after the snapshot completes
# + snapshotOnSchemaError - Re-snapshot on schema error
# + snapshotOnDataError - Re-snapshot on data error
public type ConfigurationBasedSnapshot record {|
    boolean includeData = false;
    boolean includeSchema = false;
    boolean startStream = false;
    boolean snapshotOnSchemaError = false;
    boolean snapshotOnDataError = false;
|};

# Oracle-specific extended snapshot configuration.
# Extends the relational base with configuration-based snapshot sub-flags.
#
# + configurationBased - Sub-flags active only when `snapshotMode == CONFIGURATION_BASED`
public type OracleExtendedSnapshotConfiguration record {|
    *cdc:RelationalExtendedSnapshotConfiguration;
    ConfigurationBasedSnapshot configurationBased?;
|};

# Oracle-specific data type handling.
#
# + intervalHandlingMode - How Oracle `INTERVAL` types are represented (numeric vs ISO-8601 string)
public type OracleDataTypeConfiguration record {|
    *cdc:DataTypeConfiguration;
    IntervalHandlingMode intervalHandlingMode = NUMERIC;
|};

# Represents the configuration for the Oracle CDC database connection.
#
# + connectorClass - Fully-qualified Debezium connector class name (hardcoded)
# + hostname - Oracle server hostname; ignored when `url` is set
# + port - Oracle listener port; ignored when `url` is set
# + databaseName - Root container (CDB) or non-CDB database name. Required regardless of `url`
# + url - Raw JDBC URL for TNS / RAC / TCPS connections. Overrides `hostname` and `port` only
# + pdbName - Pluggable database name (multi-tenant installations only)
# + adapterMode - LogMiner mode: connector-side (`LOGMINER`) or database-side (`LOGMINER_UNBUFFERED`)
# + racNodes - RAC node list (`host:port` or `host:port/SID`); required for RAC even when `url` is set
# + includedSchemas - Regex patterns for schemas to capture (mutually exclusive with `excludedSchemas`)
# + excludedSchemas - Regex patterns for schemas to exclude (mutually exclusive with `includedSchemas`)
# + includedTables - Regex patterns for tables to capture (mutually exclusive with `excludedTables`)
# + excludedTables - Regex patterns for tables to exclude (mutually exclusive with `includedTables`)
# + includedColumns - Regex patterns for columns to capture (mutually exclusive with `excludedColumns`)
# + excludedColumns - Regex patterns for columns to exclude (mutually exclusive with `includedColumns`)
# + logMinerConfig - LogMiner adapter tunables (apply to both `LOGMINER` and `LOGMINER_UNBUFFERED`)
# + driverConfig - Oracle JDBC driver pass-through (mTLS, Oracle Wallet, timezone-as-region)
public type OracleDatabaseConnection record {|
    *cdc:DatabaseConnection;
    string connectorClass = "io.debezium.connector.oracle.OracleConnector";
    string hostname = "localhost";
    int port = 1521;
    string databaseName;
    string url?;
    string pdbName?;
    AdapterMode adapterMode = LOGMINER;
    string|string[] racNodes?;
    string|string[] includedSchemas?;
    string|string[] excludedSchemas?;
    string|string[] includedTables?;
    string|string[] excludedTables?;
    string|string[] includedColumns?;
    string|string[] excludedColumns?;
    LogMinerConfiguration logMinerConfig?;
    DriverConfiguration driverConfig?;
|};

# Oracle-specific CDC options for snapshot, LOB capture, streaming, and data type handling.
#
# + extendedSnapshot - Snapshot config with Oracle-specific configuration-based sub-flags
# + dataTypeConfig - Data type handling including Oracle `INTERVAL` handling
# + heartbeatConfig - Heartbeat configuration for keeping the connection alive
# + streamingDelay - Delay between snapshot completion and streaming start, in seconds
# + queryFetchSize - JDBC fetch size for streaming queries
# + lobEnabled - Enable CLOB / NCLOB / BLOB / XML capture (incompatible with `HYBRID` mining strategy)
# + unavailableValuePlaceholder - Placeholder string emitted for unchanged LOB columns
# + snapshotDatabaseErrorsMaxRetries - Per-table retry count for snapshot-time DB errors (e.g., ORA-01466)
public type OracleOptions record {|
    *cdc:Options;
    OracleExtendedSnapshotConfiguration extendedSnapshot?;
    OracleDataTypeConfiguration dataTypeConfig?;
    cdc:RelationalHeartbeatConfiguration heartbeatConfig?;
    decimal streamingDelay?;
    int queryFetchSize = 10000;
    boolean lobEnabled = false;
    string unavailableValuePlaceholder = "__debezium_unavailable_value";
    int snapshotDatabaseErrorsMaxRetries = 0;
|};

# Oracle CDC listener configuration including database connection, storage, and CDC options.
#
# + database - Oracle database connection, LogMiner, driver, and capture settings
# + options - Oracle-specific CDC options including snapshot, LOB, streaming, and data type handling
public type OracleListenerConfiguration record {|
    *cdc:ListenerConfiguration;
    OracleDatabaseConnection database;
    OracleOptions options = {};
|};
