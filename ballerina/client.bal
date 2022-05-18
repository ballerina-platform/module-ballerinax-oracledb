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

public isolated client class Client {
    *sql:Client;

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

    # Executes the query, which may return multiple results.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name=${albumName}` ``
    # + rowType - The `typedesc` of the record to which the result needs to be returned
    # + return - Stream of records in the `rowType` type
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) 
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Executes the query, which is expected to return at most one row of the result.
    # If the query does not return any results, an `sql:NoRowsError` is returned.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name=${albumName}` ``
    # + returnType - The `typedesc` of the record to which the result needs to be returned.
    #                It can be a basic type if the query result contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>) 
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.QueryProcessor",
        name: "nativeQueryRow"
    } external;

    # Executes the SQL query. Only the metadata of the execution is returned (not the results from the query).
    #
    # + sqlQuery - The SQL query such as `` `DELETE FROM Album WHERE artist=${artistName}` ``
    # + return - Metadata of the query execution as an `sql:ExecutionResult` or an `sql:Error`
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.ExecuteProcessor",
        name: "nativeExecute"
    } external;

    # Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned (not results from the query).
    # If one of the commands in the batch fails, the `sql:BatchExecuteError` will be returned immediately.
    #
    # + sqlQueries - The SQL query with multiple sets of parameters
    # + return - Metadata of the query execution as an `sql:ExecutionResult[]` or an `sql:Error`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries)
    returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError("Parameter 'sqlQueries' cannot be an empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes a SQL query, which calls a stored procedure. This may or may not return results.
    #
    # + sqlQuery - The SQL query such as `` `CALL sp_GetAlbums();` ``
    # + rowTypes - `typedesc` array of the records to which the results need to be returned
    # + return - Summary of the execution and results are returned in an `sql:ProcedureCallResult`, or an `sql:Error`
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, 
    typedesc<record {}>[] rowTypes = []) returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Closes the SQL client and shuts down the connection pool.
    #
    # + return - `()` or an `sql:Error`
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

# SSL configurations to be used when connecting to the Oracle database server.
#
# + key - Keystore configuration of the client certificates
# + cert - Truststore configuration of the trust certificates
public type SecureSocket record {|
    crypto:KeyStore key?;
    crypto:TrustStore cert?;
|};

# Provides an additional set of configurations related to the Oracle database connection.
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

# Client configuration record for connection initialization.
#
# + host - Hostname of the Oracle database server
# + port - Port number of the Oracle database server
# + user - Name of a user of the Oracle database server
# + database - System identifier or the service name of the database
# + password - The password of the Oracle database server for the provided username
# + options - Oracle database connection properties
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
returns sql:Error? = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.nativeimpl.ClientProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries) 
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.nativeimpl.ExecuteProcessor"
} external;
