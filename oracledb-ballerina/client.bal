// // Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
// //
// // WSO2 Inc. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied.  See the License for the
// // specific language governing permissions and limitations
// // under the License.

import ballerina/crypto;
import ballerina/java;
import ballerina/sql;

public client class Client{

    # Initialize Oracle Client.
    #
    # + user - Name of a user of the database
    # + password - Password for the user
    # + database - System Identifier or the Service Name of the database
    # + host - Hostname of the oracle server to be connected
    # + port - Port number of the oracle server to be connected
    # + options - Oracle database specific JDBC options
    # + connectionPool - The `sql:ConnectionPool` object to be used within 
    #         the jdbc client. If there is no connectionPool provided, 
    #         the global connection pool will be used
    public function init(
        string user,
        string password,
        string host = "localhost",
        int port = 1521,
        string database = "ORCL",
        Options? options = (),
        sql:ConnectionPool?  connectionPool = ()
    ) returns sql:Error? {
        ClientConfiguration clientConfig = {
            user: user,
            password: password,
            host: host,
            port: port,
            database: database,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConfig, sql:getGlobalConnectionPool());
    }

}

# SSL Configuration to be used when connecting to oracle server.
#
# + keyStore - Keystore configuration of the client certificates
# + trustStore - Truststore configuration of the trust certificates
# + keyStoreType - The type of the keystore - "JKS" / "PKCS12" / "SSO"
# + trustStoreType - The type of the keystore - "JKS" / "PKCS12" / "SSO"
public type SSLConfig record {|
  crypto:KeyStore keyStore?;
  crypto:TrustStore trustStore?;
  string keyStoreType?;
  string trustStoreType?;
|};

# Oracle database specific JDBC options
#
# + ssl - SSL Configuration to be used.
# + loginTimeoutInSeconds - Specify how long to wait for establishment 
# of a database connection in seconds.
# + autoCommit - If true commits automatically when statement is 
# complete.
# + connectTimeoutInSeconds - Time duration for a connection.
# + socketTimeoutInSeconds - Timeout duration for reading from a socket.
public type Options record {|
   SSLConfig ssl?;
   decimal loginTimeoutInSeconds?;
   boolean autoCommit?;
   decimal connectTimeoutInSeconds?;
   decimal socketTimeoutInSeconds?;
|};

# Client Configuration record for connection initialization
#
# + host - Hostname of the oracle server to be connected
# + port - Port number of the oracle server to be connected
# + database - System Identifier or the Service Name of the database
# + user - Name of a user of the database
# + password - Password for the user
# + options - Oracle database specific JDBC options
# + connectionPool - The `sql:ConnectionPool` object to be used within 
#         the jdbc client. If there is no connectionPool provided, 
#         the global connection pool will be used
type ClientConfiguration record {|
    string user;
    string password;
    string host;
    int port;
    string database;
    Options? options;
    sql:ConnectionPool?  connectionPool;
|};


function createClient(Client 'client, ClientConfiguration clientConfig, sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method{
    'class: "org.ballerinalang.oracledb.NativeImpl"
} external;


function nativeQuery(Client sqlClient, string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType)
returns stream <record {}, sql:Error> = @java:Method {
    'class: "org.ballerinalang.sql.nativeimpl.QueryProcessor"
} external;

function nativeExecute(Client sqlClient, string|sql:ParameterizedQuery sqlQuery)
returns sql:ExecutionResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.sql.nativeimpl.ExecuteProcessor"
} external;

function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "org.ballerinalang.sql.nativeimpl.ExecuteProcessor"
} external;

function nativeCall(Client sqlClient, string|sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes)
returns sql:ProcedureCallResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.sql.nativeimpl.CallProcessor"
} external;

function close(Client mysqlClient) returns sql:Error? = @java:Method {
    'class: "org.ballerinalang.oracledb.NativeImpl"
} external;
