# Oracle CDC: TCPS + Wallet Example

Connect to Oracle over TCPS (mTLS) using an Oracle Wallet. The Ballerina-side
wiring is identical to the basic example — only the `url` plus `driverConfig`
block differ.

## Prerequisites

1. Oracle configured to accept TCPS connections; clients trust the Oracle
   server certificate and Oracle trusts the client certificate.
2. An Oracle Wallet directory (containing `cwallet.sso` / `ewallet.p12`)
   readable by the user running this Ballerina program.
3. The `ballerinax/oracledb.cdc.driver` Ballerina package on your project
   dependencies (this ships the Debezium Oracle connector and Oracle JDBC
   driver JARs).

## Run

```bash
export DB_USERNAME="<cdc user>"
export DB_PASSWORD="<cdc password>"
bal run
```

## Notes

- `url` overrides `hostname` and `port`; `databaseName` and `racNodes` remain
  available to the connector. Use a full TNS descriptor for TCPS / SCAN / RAC
  configurations.
- Set `walletLocation` to the directory containing your Oracle Wallet. The
  default `./wallet` is relative to the directory from which the example runs.
- `driverConfig.timezoneAsRegion = false` works around ORA-01882 when the
  client OS timezone is not present in the Oracle timezone registry.
- `intervalHandlingMode: STRING` emits Oracle `INTERVAL` columns as ISO-8601
  strings; the default `NUMERIC` representation is more compact but less
  readable.
