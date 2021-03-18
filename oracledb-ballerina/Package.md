## Package overview

This Package provides the functionality required to access and manipulate data stored in an `Oracle Database`.  

**Prerequisite:** Add the Oracle Database JDBC thin driver JAR as a native library dependency in your Ballerina project. 
Once you build the project by executing the `ballerina build` command, you should be able to run the resultant by 
executing the `ballerina run` command.

E.g., The `Ballerina.toml` content.
Change the path to the JDBC driver appropriately.

```toml
[package]
org = "sample"
name = "oracledb"
version= "0.1.0"

[[platform.java11.dependency]]
path = "/path/to/oracledb-connector/ojdbc8-12.2.0.1.jar"
artifactId = "ojdbc8"
groupId = "com.oracle.database.jdbc"
version = "12.2.0.1"
``` 

### Client
To access a database, you must first create an oracledb:Client object. 
The examples for creating a OracleDB client can be found below.

#### Creating a client
This example shows different ways of creating the `oracledb:Client`. 

The client can be created with an empty constructor and hence, the client will be initialized with the default properties. 
The first example with the `dbClient1` demonstrates this.

The `dbClient2` receives the host, username, and password. Since the properties are passed in the same order as it is defined 
in the `jdbc:Client`, you can pass it without named params.

The `dbClient3` uses the named params to pass the attributes since it is skipping some params in the constructor. 
Further [oracledb:Options](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/records/Options) 
is passed to configure the SSL and connection timeout in the OracleDB client. 

Similarly, the `dbClient4` uses the named params and it provides an unshared connection pool in the type of 
[sql:ConnectionPool](https://ballerina.io/learn/api-docs/ballerina/#/sql/records/ConnectionPool) 
to be used within the client. 
For more details about connection pooling, see the [SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

```ballerina
oracledb:Client|sql:Error dbClient1 = new ();
oracledb:Client|sql:Error dbClient2 = new ("localhost", "rootUser", "rooPass", 
                              "information_schema", 3306);
                              
oracledb:Options oracledbOptions = {
  autoCommit: true,
  connectTimeout: 10
};
oracldb:Client|sql:Error dbClient3 = new (user = "rootUser", password = "rootPass",
                              options = oracledbOptions);
oracldb:Client|sql:Error dbClient4 = new (user = "rootUser", password = "rootPass",
                              connectionPool = {maxOpenConnections: 5});
```
You can find more details about each property in the
[oracledb:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) constructor. 

The [oracle:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) references 
[sql:Client](https://ballerina.io/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and all the operations 
defined by the `sql:Client` will be supported by the `oracledb:Client` as well. 

# For more information on all the operations supported by the `oracledb``````:Client`, which include the below, see the [SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

1. Connection Pooling
2. Querying data
3. Inserting data
4. Updating data
5. Deleting data
6. Batch insert and update data
7. Execute stored procedures
8. Closing client