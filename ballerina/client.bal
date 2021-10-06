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

    # Initialize the Oracle Client.
    #
    # + host - Hostname of the Oracle database server to be connected
    # + user - Name of a user of the database
    # + password - Password of the user
    # + database - System identifier or the service name of the database
    # + port - Port number of the Oracle database server to be connected
    # + options - Oracle database connection parameters
    # + connectionPool - The `sql:ConnectionPool` object to be used within the database client. If there is no
    #                    `connectionPool` provided, the global connection pool will be used
    # + return - An SQL error if the client creation failed 
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
    # + sqlQuery - The query, which needs to be executed as an `sql:ParameterizedQuery`. Usage of `string` is depreciated
    # + rowType - The `typedesc` of the record that should be returned as a result. If this is not provided, the default
    #             column names of the query result set will be used for the record attributes
    # + return - Stream of records in the type of `rowType`
    remote isolated function query(string|sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream <rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Queries the database with the provided query and returns the first row as a record if the expected return type is
    # a record. If the expected return type is not a record, then a single value is returned.
    #
    # + sqlQuery - The query to be executed as a `sql:ParameterizedQuery` which returns only one row result
    # + returnType - The `typedesc` of the record/type that should be returned as a result. If this is not provided, the
    #                default column names/type of the query result set will be used
    # + return - Result in the type of `returnType`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<any> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.QueryProcessor",
        name: "nativeQueryRow"
    } external;


    # Executes the DDL or DML SQL queries provided by the user and returns a summary of the execution.
    #
    # + sqlQuery - The DDL or DML query such as INSERT, DELETE, UPDATE, etc. as an `sql:ParameterizedQuery`.
    #              Usage of `string` is depreciated
    # + return - Summary of the SQL update query as an `sql:ExecutionResult` or returns an `sql:Error`
    #            if any error occurred when executing the query
    remote isolated function execute(string|sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.ExecuteProcessor",
         name: "nativeExecute"
    } external;

    # Executes a provided batch of parameterized DDL or DML SQL queries
    # and returns the summary of the execution.
    #
    # + sqlQueries - The DDL or DML queries such as `INSERT`, `DELETE`, `UPDATE`, etc. as a `sql:ParameterizedQuery` with an array
    #                of values passed in
    # + return - Summary of the executed SQL queries as an `sql:ExecutionResult[]`, which includes details such as
    #            `affectedRowCount` and `lastInsertId`. If one of the commands in the batch fails, this function
    #            will return a `sql:BatchExecuteError`. However, the Oracle driver may or may not continue to process the
    #            remaining commands in the batch after a failure. The summary of the executed queries in case of an error
    #            can be accessed as `(<sql:BatchExecuteError> result).detail()?.executionResults`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries)
    returns sql:ExecutionResult[]|sql:Error {
        if (sqlQueries.length() == 0) {
            return error sql:ApplicationError("Parameter 'sqlQueries' cannot be an empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes a SQL stored procedure and returns the result as a stream and the execution summary.
    #
    # + sqlQuery - The query to execute the SQL stored procedure as an `sql:ParameterizedQuery`.Usage of `string` is depreciated
    # + rowTypes - The array of `typedesc` of the records that should be returned as a result. If this is not provided,
    #              the default column names of the query result set will be used for the record attributes
    # + return - Summary of the execution is returned in a `sql:ProcedureCallResult` or an `sql:Error`
    remote isolated function call(string|sql:ParameterizedCallQuery sqlQuery,
    typedesc<record {}>[] rowTypes = []) returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Close the SQL client.
    #
    # + return - Possible error during closing the client
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

# SSL Configuration to be used when connecting to the Oracle database server.
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
# + autoCommit - If true commits automatically when the statement is complete
# + connectTimeout - Time duration for a connection in seconds
# + socketTimeout - Timeout duration for reading from a socket in seconds
public type Options record {|
   SecureSocket ssl?;
   decimal loginTimeout = 0;
   boolean autoCommit = true;
   decimal connectTimeout = 30;
   decimal socketTimeout?;
|};

# Client configuration record for connection initialization.
#
# + host - Hostname of the Oracle server to be connected
# + port - Port number of the Oracle server to be connected
# + user - Name of a user of the database
# + database - System Identifier or the Service Name of the database
# + password - Password of the user
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

isolated function closedStreamInvocationError() returns sql:Error {
    return error sql:ApplicationError("Stream is closed. Therefore, no operations are allowed further on the stream.");
}

isolated function createClient(Client 'client, ClientConfiguration clientConfig, sql:ConnectionPool globalConnPool)
returns sql:Error? = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.nativeimpl.ClientProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.nativeimpl.ExecuteProcessor"
} external;

isolated function getBytes(BFileIterator bFileIterator) returns byte[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.utils.BFileUtils"
} external;

isolated function isBFileExists(BFile bfile) returns boolean = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.utils.BFileUtils"
} external;

isolated function bfileReadBytes(BFile bfile) returns byte[]|sql:Error? = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.utils.BFileUtils"
} external;

isolated function bfileReadBlockAsStream(BFile bfile, int bufferSize) returns stream<byte[], error?> = @java:Method {
    'class: "io.ballerina.stdlib.oracledb.utils.BFileUtils"
} external;