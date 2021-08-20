cd /home/oracle/sql-scripts
sleep 10s
sqlplus /nolog <<< @schema/create-schema.sql
sleep 5s
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @connection/connection-pool-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @custom-types/custom-type-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @execute/batch-execute-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @execute/execute-with-params-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @procedures/stored-procedure-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @query/complex-params-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @query/simple-params-test-data.sql
sqlplus -S admin/password@localhost/ORCLCDB.localdomain <<< @transaction/local-transaction-test-data.sql
