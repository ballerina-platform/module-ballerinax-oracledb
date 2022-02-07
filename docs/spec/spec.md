# Specification: Ballerina OracleDB Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2022/01/14  
_Updated_: 2022/02/07  
_Edition_: Swan Lake  
_Issue_: [#2293](https://github.com/ballerina-platform/ballerina-standard-library/issues/2293)

# Introduction

This is the specification for the OracleDB standard library of [Ballerina language](https://ballerina.io/), which provides the functionality that is required to access and manipulate data stored in an Oracle database.  

The OracleDB library specification has evolved and may continue to evolve in the future. Released versions of the specification can be found under the relevant Github tag. 

If you have any feedback or suggestions about the library, start a discussion via a [Github issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Slack channel](https://ballerina.io/community/). Based on the outcome of the discussion, specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in Github.

Conforming implementation of the specification is released to Ballerina central. Any deviation from the specification is considered a bug.

# Contents

1. [Overview](#1-overview)
2. [Client](#2-client)  
   2.1. [Connection Pool Handling](#21-connection-pool-handling)  
   2.2. [Closing the Client](#22-closing-the-client)
3. [Queries and Values](#3-queries-and-values)
4. [Database Operations](#4-database-operations)

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

**Initialisation of the Client:**
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
public isolated function init(string host = "localhost", string? user = (), string? password = (), 
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
* SSL Connection:
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

## 2.1. Connection Pool Handling

Connection pool handling is generic and implemented through `sql` module. For more information, see the
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#21-connection-pool-handling)

## 2.2. Closing the Client

Once all the database operations are performed, the client can be closed by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

   ```ballerina
   # Closes the OracleDB client and shuts down the connection pool.
   #
   # + return - Possible error when closing the client
   public isolated function close() returns Error?;
   ```

# 3. Queries and Values

All the generic `sql` queries and values are supported. For more information, see the
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-queries-and-values)

In addition to `sql` values, the `oracledb` package supports the following typed values for Oracle SQL data types,
1. ObjectTypeValue
2. VarrayValue
3. NestedTableValue

# 4. Database Operations

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes an SQL query, which calls a stored procedure. This can either return results or nil.

For more information on database operations see the [SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-database-operations)
