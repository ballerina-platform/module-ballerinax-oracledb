// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/crypto;
import ballerina/jballerina.java;
import ballerina/sql;

public client class Client {
    *sql:Client;
    private boolean clientActive = true;

    # Initialize Oracle Client.
    #
    # + host - Hostname of the Oracle database server to be connected
    # + user - Name of a user of the database
    # + password - Password for the user
    # + database - System Identifier or the Service Name of the database
    # + port - Port number of the Oracle database server to be connected
    # + options - Oracle database connection parameters
    # + connectionPool - The `sql:ConnectionPool` object to be used within the database client. If there is no
    #                    connectionPool provided, the global connection pool will be used
    # + return - sql error if the client creation failed 
    public isolated function init(string host = "localhost", string? user = (), string? password = (),
    string? database = (), int port = 1521, Options? options = (), sql:ConnectionPool? connectionPool = ())
    returns sql:Error? {
        ClientConfiguration clientConfig = {
            host: host,
            port: port,
            user: user,
            password: password,
            database: database,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConfig, sql:getGlobalConnectionPool());
    }

    # Queries the database with the query provided by the user, and returns the result as stream.
    #
    # + sqlQuery - The query which needs to be executed as `string` or `ParameterizedQuery` when the SQL query has
    #              params to be passed in
    # + rowType - The `typedesc` of the record that should be returned as a result. If this is not provided the default
    #             column names of the query result set be used for the record attributes.
    # + return - Stream of records in the type of `rowType`
    remote isolated function query(@untainted string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType = ())
    returns @tainted stream <record {}, sql:Error> {
        if (self.clientActive) {
            return nativeQuery(self, sqlQuery, rowType);
        } else {
            return sql:generateApplicationErrorStream("OracleDB client is already closed,"
                + "hence further operations are not allowed");
        }
    }

    # Executes the DDL or DML sql queries provided by the user, and returns summary of the execution.
    #
    # + sqlQuery - The DDL or DML query such as INSERT, DELETE, UPDATE, etc as `string` or `ParameterizedQuery`
    #              when the query has params to be passed in
    # + return - Summary of the sql update query as `ExecutionResult` or returns `Error`
    #            if any error occurred when executing the query
    remote isolated function execute(@untainted string|sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error {
        if (self.clientActive) {
            return nativeExecute(self, sqlQuery);
        } else {
            return error sql:ApplicationError(
            "OracleDB client is already closed, hence further operations are not allowed");
        }
    }

    # Executes a batch of parameterized DDL or DML sql query provided by the user,
    # and returns the summary of the execution.
    #
    # + sqlQueries - The DDL or DML query such as INSERT, DELETE, UPDATE, etc as `ParameterizedQuery` with an array
    #                of values passed in
    # + return - Summary of the executed SQL queries as `ExecutionResult[]` which includes details such as
    #            `affectedRowCount` and `lastInsertId`. If one of the commands in the batch fails, this function
    #            will return `BatchExecuteError`, however the database driver may or may not continue to process the
    #            remaining commands in the batch after a failure. The summary of the executed queries in case of error
    #            can be accessed as `(<sql:BatchExecuteError> result).detail()?.executionResults`
    remote isolated function batchExecute(@untainted sql:ParameterizedQuery[] sqlQueries)
    returns sql:ExecutionResult[]|sql:Error {
        if (sqlQueries.length() == 0) {
            return error sql:ApplicationError("'sqlQueries' parameter cannot be an empty array");
        }
        if (self.clientActive) {
            return nativeBatchExecute(self, sqlQueries);
        } else {
            return error sql:ApplicationError(
                "OracleDB client is already closed, hence further operations are not allowed");
        }
    }

    # Executes a SQL stored procedure and returns the result as stream and execution summary.
    #
    # + sqlQuery - The query to execute the SQL stored procedure
    # + rowTypes - The array of `typedesc` of the records that should be returned as a result. If this is not provided
    #              the default column names of the query result set be used for the record attributes
    # + return - Summary of the execution is returned in `ProcedureCallResult` or `sql:Error`
    remote isolated function call(@untainted string|sql:ParameterizedCallQuery sqlQuery,
    typedesc<record {}>[] rowTypes = []) returns sql:ProcedureCallResult|sql:Error {
        if (self.clientActive) {
            return nativeCall(self, sqlQuery, rowTypes);
        } else {
            return error sql:ApplicationError(
                "OracleDB client is already closed, hence further operations are not allowed");
        }
    }

    # Close the SQL client.
    #
    # + return - Possible error during closing the client
    public isolated function close() returns sql:Error? {
        self.clientActive = false;
        return close(self);
    }

}

# SSL Configuration to be used when connecting to Oracle database server.
#
# + key - Keystore configuration of the client certificates
# + cert - Truststore configuration of the trust certificates
public type SecureSocket record {|
  crypto:KeyStore key?;
  crypto:TrustStore cert?;
|};

# Oracle database connection parameters.
#
# + ssl - SSL Configuration to be used
# + loginTimeout - Specify how long to wait for establishment of a database connection in seconds
# + autoCommit - If true commits automatically when statement is complete
# + connectTimeout - Time duration for a connection in seconds
# + socketTimeout - Timeout duration for reading from a socket in seconds
public type Options record {|
   SecureSocket ssl?;
   decimal loginTimeout = 0;
   boolean autoCommit = true;
   decimal connectTimeout = 0;
   decimal socketTimeout?;
|};

# Client Configuration record for connection initialization.
#
# + host - Hostname of the Oracle server to be connected
# + port - Port number of the Oracle server to be connected
# + user - Name of a user of the database
# + database - System Identifier or the Service Name of the database
# + password - Password for the user
# + options - Oracle database connection parameters
# + connectionPool - The `sql:ConnectionPool` record to be used within the database client. If there is no
#                    connectionPool provided, the global connection pool will be used
type ClientConfiguration record {|
    string host;
    int port;
    string? user;
    string? password;
    string? database;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

isolated function createClient(Client 'client, ClientConfiguration clientConfig, sql:ConnectionPool globalConnPool)
returns sql:Error? = @java:Method{
    'class: "org.ballerinalang.oracledb.nativeimpl.ClientProcessor"
} external;

isolated function nativeQuery(Client sqlClient, string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType)
returns stream <record {}, sql:Error> = @java:Method {
    'class: "org.ballerinalang.oracledb.nativeimpl.QueryProcessor"
} external;

isolated function nativeExecute(Client sqlClient, string|sql:ParameterizedQuery sqlQuery)
returns sql:ExecutionResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.oracledb.nativeimpl.ExecuteProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "org.ballerinalang.oracledb.nativeimpl.ExecuteProcessor"
} external;

isolated function nativeCall(Client sqlClient, string|sql:ParameterizedCallQuery sqlQuery,
typedesc<record {}>[] rowTypes) returns sql:ProcedureCallResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.oracledb.nativeimpl.CallProcessor"
} external;

isolated function close(Client oracledbClient) returns sql:Error? = @java:Method {
    'class: "org.ballerinalang.oracledb.nativeimpl.ClientProcessor"
} external;
