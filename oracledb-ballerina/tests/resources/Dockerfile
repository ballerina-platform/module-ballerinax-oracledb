# Copyright (c) 2021, WSO2 Inc. (http://wso2.com) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dockerfile using dockerhub repository image

# ARG REPO_LOCATION=gayaldassanayake/database
# ARG BASE_VERSION=19.3.0-ee
ARG REPO_LOCATION=store/oracle/database-enterprise
ARG BASE_VERSION=12.2.0.1
FROM ${REPO_LOCATION}:${BASE_VERSION}

# CMD ["bash","-jar","springbootify.jar"]
# RUN /bin/bash -c "source /home/oracle/.bashrc; sqlplus /nolog <<< connect sys/password@//localhost:1521/ORCLCDB as sysdba; alter session set '_ORACLE_SCRIPT'=true; create user admin identified by password; grant connect, resource,dba to admin;"
#                         "docker exec ballerina-oracledb  /bin/bash -c 'source /home/oracle/.bashrc; sqlplus /nolog' <<< \"connect sys/password@//localhost:1521/ORCLCDB as sysdba; alter session set '_ORACLE_SCRIPT'=true; create user admin identified by password; grant connect, resource,dba to admin;\""

COPY sql-scripts/schema/create-schema.sql /home/oracle
# Connection test case
COPY sql-scripts/connection/connections-test-data.sql /docker-entrypoint-initdb.d/

# Pool test case
# COPY sql-scripts/pool/connection-pool-test-data.sql /docker-entrypoint-initdb.d/

# Execute test case
COPY sql-scripts/execute/execute-test-data.sql /docker-entrypoint-initdb.d/
# COPY sql-scripts/execute/execute-params-test-data.sql /docker-entrypoint-initdb.d/

# Batch Execute test case
COPY sql-scripts/batchexecute/batch-execute-test-data.sql /docker-entrypoint-initdb.d/

# Query test case
# COPY sql-scripts/query/simple-params-test-data.sql /docker-entrypoint-initdb.d/
# COPY sql-scripts/query/numerical-test-data.sql /docker-entrypoint-initdb.d/
# COPY sql-scripts/query/complex-test-data.sql /docker-entrypoint-initdb.d/

# Procedures test case
# COPY sql-scripts/procedures/stored-procedure-test-data.sql /docker-entrypoint-initdb.d/

# Transactions test case
# COPY sql-scripts/transaction/local-transaction-test-data.sql /docker-entrypoint-initdb.d/
# COPY sql-scripts/transaction/xa-transaction-test-data-1.sql /docker-entrypoint-initdb.d/
# COPY sql-scripts/transaction/xa-transaction-test-data-2.sql /docker-entrypoint-initdb.d/

# # RUN mkdir -p /etc/ssl
# # COPY keystore/server/ /etc/ssl/
# # RUN chown -R mysql /etc/ssl
#
# COPY my.cnf /etc/
#
# # ENV MYSQL_ROOT_PASSWORD Test123#
#
#
