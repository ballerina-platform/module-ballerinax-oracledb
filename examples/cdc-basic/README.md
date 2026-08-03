# Oracle CDC: Basic Example

A minimal example showing how to use `oracledb:CdcListener` to react to row-level
INSERT / UPDATE / DELETE events from a multi-tenant Oracle database (CDB + PDB)
using LogMiner.

## Prerequisites

1. An Oracle database with archive logging enabled and `LOG_MINING_FLUSH` table
   plus the LogMiner grants required by Debezium. See the
   [Debezium Oracle setup guide](https://debezium.io/documentation/reference/3.0/connectors/oracle.html#setting-up-oracle).
2. The `ballerinax/oracledb.cdc.driver` Ballerina package on your project
   dependencies (this ships the Debezium Oracle connector and Oracle JDBC
   driver JARs).

## Run

Set the DB credentials and start the listener:

```bash
export DB_USERNAME="<cdc user>"
export DB_PASSWORD="<cdc password>"
bal run
```

Then INSERT / UPDATE / DELETE rows in `SCOTT.ORDERS` from any Oracle client —
the corresponding `onCreate` / `onUpdate` / `onDelete` events are printed
through `ballerina/log`.

## Notes

- `snapshotMode: cdc:NO_DATA` skips the initial table snapshot and starts streaming
  from the current SCN. Use `cdc:INITIAL` (default) to first emit a synthetic
  CREATE event for every existing row.
- `pdbName` is required only on multi-tenant installations. Remove it for
  legacy non-CDB databases.
- The `Orders` record fields are camelCase (`orderId`, `customerId`, ...) while
  the underlying `SCOTT.ORDERS` columns are the Oracle-conventional
  `ORDER_ID`, `CUSTOMER_ID`, etc. Each field is annotated with
  `@jsondata:Name` (from `ballerina/data.jsondata`) to map it to the actual
  column name — the same mapping mechanism `sql:ColumnConfig` provides for
  `ballerinax/oracledb` queries, since CDC payload binding goes through
  `data.jsondata` rather than `sql`.
