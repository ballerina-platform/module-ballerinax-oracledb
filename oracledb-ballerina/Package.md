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
oracledb:Client|sql:Error dbClient2 = new ("localhost", "rootUser", "rooPass", "information_schema", 1521);
                              
oracledb:Options oracledbOptions = {
  autoCommit: true,
  connectTimeout: 10
};
oracldb:Client|sql:Error dbClient3 = new (user = "rootUser", password = "rootPass", options = oracledbOptions);
oracldb:Client|sql:Error dbClient4 = new (user = "rootUser", password = "rootPass", connectionPool = {maxOpenConnections: 5});
```
You can find more details about each property in the
[oracledb:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) constructor.

The [oracle:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) references [sql:Client](https://ballerina.io/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and all the operations defined by the `sql:Client` will be supported by the `oracledb:Client` as well.

# For more information on all the operations supported by the `oracledb``````:Client`, which include the below, see the [SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

1.Connection Pooling

``` ballerina
oracledb:Client|sql:Error oracledbClient = new (user = "rootUser", password = "rootPass", database = "School", connectionPool = {maxOpenConnections: 5});
```

2.Creating tables

``` ballerina
sql:ExecutionResult result = check oracledbClient->execute("CREATE TABLE Students(id NUMBER, name  VARCHAR2(200), PRIMARY KEY(id))");
```

3.Inserting data

``` ballerina
sql:ExecutionResult result = check oracledbClient->execute("INSERT INTO Students(id, name) VALUES (1, 'John')");

int id = 2;
string name = "Mike";
sql:ParameterizedQuery insertQuery = `insert into Students(id, name)values(${id}, ${name})`;
result = check oracledbClient->execute(insertQuery);

```

3.Querying data

``` ballerina
int id = 1;
sql:ParameterizedQuery selectQuery = `SELECT * from Students WHERE id = ${id}`;
stream<record{}, error> resultStream = oracledbClient->query("Select count(*) as Total from Customers");

record {|record {} value;|}? result = check resultStream.next();
check resultStream.close();
record {}|sql:Error? value = result?.value;

if (value is record {}) {
    io:println("Name of the student with id 1 : ", value["name"]);
} else if (value is error) {
    io:println("Next operation on the stream failed!", result);
} else {
    io:println("Students table is empty");
}
```

4.Updating data

``` ballerina
int id = 1;
sql:ParameterizedQuery updateQuery = `Update Students set name = "Max" where id = ${id}`;
sql:ExecutionResult result = check oracledbClient->execute(updateQuery);
```

5.Deleting data

``` ballerina
int id = 1;
sql:ParameterizedQuery deleteQuery = `Delete from Students where id = ${id}`;
sql:ExecutionResult result = check oracledbClient->execute(deleteQuery);
```

6.Batch insert and update data

``` ballerina
var insertRecords = [
    {id: 3, name: "Peter"},
    {id: 4, name: "Stephanie"},
    {id: 5, name: "Edward"}
];

sql:ParameterizedQuery[] insertQueries =
        from var data in insertRecords
            select  `INSERT INTO Students (id, name)
                VALUES (${data.id}, ${data.name})`;

sql:ExecutionResult[] result = check oracledbClient->batchExecute(insertQueries);
```

7.Execute stored procedures

``` ballerina
int id = 6;
string name = "Anne";
sql:ParameterizedCallQuery sqlQuery = `CALL InsertStudent(${id}, ${name})`;

sql:ProcedureCallResult callResult = check oracledbClient->call(sqlQuery);
```

8.Closing client

``` ballerina
check oracledbClient.close();
```
