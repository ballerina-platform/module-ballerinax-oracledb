# Specification: Ballerina OracleDB Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2022/01/14  
_Updated_: 2026/04/02  
_Edition_: Swan Lake  

## Introduction

This is the specification for the OracleDB standard library of [Ballerina language](https://ballerina.io/), which provides the functionality that is required to access and manipulate data stored in an Oracle database.  

The OracleDB library specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag. 

 If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in GitHub.

 The conforming implementation of the specification is released to Ballerina Central. Any deviation from the specification is considered a bug.

## Contents

1. [Overview](#1-overview)
2. [Client](#2-client)  
   2.1. [Handle connection pools](#21-handle-connection-pools)  
   2.2. [Close the client](#22-close-the-client)
3. [Queries and values](#3-queries-and-values)
4. [Database operations](#4-database-operations)
5. [Observability](#5-observability)
   - [5.1. Metric tags](#51-metric-tags)
6. [Change Data Capture (CDC) Listener](#6-change-data-capture-cdc-listener)

# 1. Overview

This specification elaborates on usage of OracleDB `Client` object to interface with an Oracle database.

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes an SQL query, which calls a stored procedure. This can either return results or nil.

All the above operations make use of `sql:ParameterizedQuery` object, backtick surrounded string template to pass
SQL statements to the database. `sql:ParameterizedQuery` supports passing of Ballerina basic types or Typed SQL Values
such as `sql:CharValue`, `sql:BigIntValue`, etc. to indicate parameter types in SQL statements.

# 2. Client

Each client represents a pool of connections to the database. The pool of connections is maintained throughout the
lifetime of the client.

**Initialization of the Client:**
```ballerina
# Initializes the Oracle database client.
#
# + host - Hostname of the Oracle database server
# + user - Name of a user of the Oracle database server
# + password - The password of the Oracle database server for the provided username
# + database - System identifier or the service name of the database
# + port - Port number of the Oracle database server
# + options - Oracle database connection properties
# + connectionPool - The `sql:ConnectionPool` object to be used within the client. If there is no
#                    `connectionPool` provided, the global connection pool will be used
# + return - An `sql:Error` if the client creation fails
public isolated function init(string host = "localhost", string? user = "sys", string? password = (), 
string? database = (), int port = 1521, Options? options = (), sql:ConnectionPool? connectionPool = ()) 
returns sql:Error?;
```

**Configurations available for initializing the OracleDB client:**
* Connection properties:
  ```ballerina
  # Provides a set of additional configurations related to the Oracle database connection.
  #
  # + ssl - SSL configurations to be used
  # + loginTimeout - Timeout (in seconds) to be used when connecting to the Oracle server and authentication (0 means no timeout)
  # + autoCommit - If true, commits automatically when the statement is complete
  # + connectTimeout - Timeout (in seconds) to be used when connecting to the Oracle server
  # + socketTimeout - Socket timeout (in seconds) to be used during the read/write operations with the Oracle database server
  #                   (0 means no socket timeout)
  public type Options record {|
      SecureSocket ssl?;
      decimal loginTimeout = 0;
      boolean autoCommit = true;
      decimal connectTimeout = 30;
      decimal socketTimeout?;
  |};
  ``` 
* SSL connection:
  ```
  # SSL configurations to be used when connecting to the Oracle database server.
  #
  # + key - Keystore configuration of the client certificates
  # + cert - Truststore configuration of the trust certificates
  public type SecureSocket record {|
      crypto:KeyStore key?;
      crypto:TrustStore cert?;
  |};
  ```

## 2.1. Handle connection pools

Connection pool handling is generic and implemented through `sql` module. For more information, see the
[SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#21-connection-pool-handling)

## 2.2. Close the client

Once all the database operations are performed, the client can be closed by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

   ```ballerina
   # Closes the OracleDB client and shuts down the connection pool.
   #
   # + return - Possible error when closing the client
   public isolated function close() returns Error?;
   ```

# 3. Queries and values

All the generic `sql` queries and values are supported. For more information, see the
[SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-queries-and-values)

In addition to `sql` values, the `oracledb` package supports the following typed values for Oracle SQL data types,
1. ObjectTypeValue
2. VarrayValue
3. NestedTableValue

# 4. Database operations

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes an SQL query, which calls a stored procedure. This can either return results or nil.

For more information on database operations, see the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-database-operations)

# 5. Observability

The OracleDB module supports observability through connection pool metrics, reported via the `ballerina/observe` module. The metric names and lifecycle are defined by the `ballerina/sql` module. For more information on connection pool metrics, see the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md).

## 6.1. Metric tags

The OracleDB module sets the following metric tags on every connection pool it creates. These tags are attached to all pool health and connection event metrics, enabling filtering and identification.

| Tag | Source | Always present | Description |
|---|---|---|---|
| `db_host` | `host` parameter | Yes | Hostname of the MySQL server (defaults to `"localhost"`) |
| `db_port` | `port` parameter | Yes | Port number of the MySQL server (defaults to `3306`) |
| `db_name` | `database` parameter | No | Database name; omitted when `database` is `nil` or empty |

# 6. Change Data Capture (CDC) Listener

The OracleDB module exposes a `CdcListener` that streams row-level INSERT / UPDATE / DELETE / TRUNCATE events from an Oracle database. It is built on top of the [`ballerinax/cdc`](https://central.ballerina.io/ballerinax/cdc/latest) module, which embeds the Debezium engine, and uses Oracle [LogMiner](https://debezium.io/documentation/reference/3.0/connectors/oracle.html) as the change-capture mechanism. Both connector-buffered (`LOGMINER`) and database-buffered (`LOGMINER_UNBUFFERED`) modes are supported. Other adapters (OpenLogReplicator, XStream) and non-memory transaction buffers (Infinispan, Ehcache) are out of scope in this version.

The listener and its native dependencies (Debezium Oracle connector, Oracle JDBC driver) are pulled in through the companion driver package `ballerinax/oracledb.cdc.driver`. Import it once anywhere in your project to wire the JARs onto the runtime classpath.

## 6.1. Listener configuration

Listener configuration is supplied via `oracledb:OracleListenerConfiguration`, which composes:

- `database: OracleDatabaseConnection` — connection settings (CDB / PDB names, hostname / port or full JDBC `url`, RAC nodes, adapter, schema / table / column filters, LogMiner tunables, and JDBC driver pass-through for TCPS / Oracle Wallet / mTLS).
- `options: OracleOptions` — Oracle CDC behavior (LOB capture, JDBC fetch size, streaming delay, interval handling, configuration-based snapshots) plus the common `cdc:Options` fields (snapshot mode, decimal handling, signaling, etc.).
- The base `cdc:ListenerConfiguration` fields — `engineName`, `internalSchemaStorage`, `offsetStorage`, `livenessInterval`.

When `url` is set on the database connection, `hostname` and `port` are silently ignored; `databaseName` and `racNodes` are still emitted. Use a TNS / SCAN / TCPS descriptor for advanced setups. When `databaseName` and `url` are both unset, listener initialization fails with a `cdc:Error`.

## 6.2. Example

```ballerina
import ballerinax/cdc;
import ballerinax/oracledb;
import ballerinax/oracledb.cdc.driver as _;

listener oracledb:CdcListener orderListener = new (
    database = {
        username: "scott",
        password: "tiger",
        databaseName: "ORCLCDB",
        pdbName: "ORCLPDB1",
        includedTables: "SCOTT\\.ORDERS"
    },
    options = {
        snapshotMode: cdc:NO_DATA
    }
);

service cdc:Service on orderListener {
    isolated remote function onCreate(record {} after, string tableName) returns error? { }
    isolated remote function onUpdate(record {} before, record {} after, string tableName) returns error? { }
    isolated remote function onDelete(record {} before, string tableName) returns error? { }
    isolated remote function onTruncate(string tableName) returns error? { }
    isolated remote function onError(cdc:Error e) { }
}
```

See the `examples/cdc-basic` and `examples/cdc-tcps-wallet` directories for runnable variants — one for plain hostname / port connections, the other for TCPS + Oracle Wallet with mTLS.

## 6.3. Validation

`CdcListener.init` rejects configurations that Debezium would otherwise reject at runtime:

- `database.databaseName` and `database.url` cannot both be unset.
- The include / exclude pairs (`schemas`, `tables`, `columns`, LogMiner `usernames` and `clientIds`) are mutually exclusive.
- `logMinerConfig.strategy = HYBRID` is incompatible with `options.lobEnabled = true`; LOB capture requires `ONLINE_CATALOG` or `REDO_LOG_CATALOG`.
- `snapshotMode = CUSTOM`, `extendedSnapshot.lockingMode = CUSTOM`, and `extendedSnapshot.queryMode = CUSTOM` are rejected because the Java SPI hooks they reference are not surfaced in this version.

For the full list of Debezium properties that are settable through Ballerina, refer to the Oracle-specific records under `oracledb:OracleListenerConfiguration` and the shared types in [`cdc:Options`](https://central.ballerina.io/ballerinax/cdc/latest), [`cdc:OffsetStorage`](https://central.ballerina.io/ballerinax/cdc/latest), and [`cdc:InternalSchemaStorage`](https://central.ballerina.io/ballerinax/cdc/latest).
