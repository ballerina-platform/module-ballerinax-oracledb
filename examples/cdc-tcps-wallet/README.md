# Oracle CDC: TCPS + Wallet Example

Connect to Oracle over TCPS (mTLS) using an Oracle Wallet and a JDBC-driver
keystore / truststore. The Ballerina-side wiring is identical to the basic
example — only the `url` plus `driverConfig` block differ.

## Prerequisites

1. Oracle configured to accept TCPS connections; clients trust the Oracle
   server certificate and Oracle trusts the client certificate.
2. An Oracle Wallet directory (containing `cwallet.sso` / `ewallet.p12`)
   readable by the user running this Ballerina program.
3. PKCS#12 / JKS client keystore + server-cert truststore for mTLS.
4. The `ballerinax/oracledb.cdc.driver` Ballerina package on your project
   dependencies (this ships the Debezium Oracle connector and Oracle JDBC
   driver JARs).

## Run

```bash
export DB_USERNAME="<cdc user>"
export DB_PASSWORD="<cdc password>"
bal run
```

## Notes

- `url` overrides `hostname`, `port`, `databaseName`, and `racNodes`. Use a
  full TNS descriptor for TCPS / SCAN / RAC configurations.
- `driverConfig.timezoneAsRegion = false` works around ORA-01882 when the
  client OS timezone is not present in the Oracle timezone registry.
- `intervalHandlingMode: STRING` emits Oracle `INTERVAL` columns as ISO-8601
  strings; the default `NUMERIC` representation is more compact but less
  readable.
