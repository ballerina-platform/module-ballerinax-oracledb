## Overview

This module provides the functionality required to access and manipulate data stored in an Oracle database.

### Prerequisite
Add the OracleDB thin driver `ojdbc8.jar` along with `xdb.jar` and `xmlparserv2.jar` as native library dependencies in your Ballerina project's `Ballerina.toml` file.
It is recommended to use an oracle thin driver `ojdbc8.jar` version greater than 12.2.0.1.

Follow one of the ways below to add the JAR in the file:

* Download the JAR and update the path.
    ```
    [[platform.java11.dependency]]
    path = "PATH"
    ```

* Add JAR with the Maven dependency params.
    ```
    [platform.java11.dependency]]
    groupId = "com.oracle.database.jdbc"
    artifactId = "ojdbc8"
    version = "12.2.0.1"
  
    [platform.java11.dependency]]
    groupId = "com.oracle.database.xml"
    artifactId = "xdb"
    version = "21.1.0.0"
  
    [platform.java11.dependency]]
    groupId = "com.oracle.database.xml"
    artifactId = "xmlparserv2"
    version = "12.2.0.1"
    ```

### Client
To access a database, you must first create an
[oracledb:Client](https://docs.central.ballerina.io/ballerinax/oracledb/latest/clients/Client) object.
The samples for creating an OracleDB client can be found below.

#### Creating a Client
This sample shows the different ways of creating the `oracledb:Client`.

The client can be created with an empty constructor, and thereby, the client will be initialized with the default properties.

```ballerina
oracledb:Client|sql:Error dbClient = new ();
```

The `dbClient` receives the host, username, and password. Since the properties are passed in the same order as they are defined
in the `oracledb:Client`, you can pass them without named params.

```ballerina
oracledb:Client|sql:Error dbClient = new ("localhost", "adminUser", "adminPassword", 
                              "ORCLCDB.localdomain", 1521);
```

The `dbClient` uses the named params to pass the attributes since it is skipping some params in the constructor.
Further, the [`oracledb:Options`](https://docs.central.ballerina.io/ballerinax/oracledb/latest/records/Options)
property is passed to configure the SSL and connection timeouts in the OracleDB client.

```ballerina
string clientStorePath = check file:getAbsolutePath("./client-keystore.p12");
string trustStorePath = check file:getAbsolutePath("./client-truststore.p12");

oracledb:Options options = {
    ssl: {
        key: {
            path: clientStorePath,
            password: "password"
        },
        cert: {
            path: trustStorePath,
            password: "password"
        }
    },
    loginTimeout: 1,
    autoCommit: true,
    connectTimeout: 30,
    socketTimeout: 30
};

oracledb:Client|sql:Error dbClient = new (user = "adminUser", password = "adminPassword",
                              options = options);
```

Similarly, the `dbClient` uses the named params, and it provides an unshared connection pool of the type of
[sql:ConnectionPool](https://docs.central.ballerina.io/ballerina/sql/latest/records/ConnectionPool)
to be used within the client.
For more details about connection pooling, see the [`sql` Module](https://docs.central.ballerina.io/ballerina/sql/latest).

```ballerina
oracledb:Client|sql:Error dbClient = new (user = "adminUser", password = "adminPassword",
                              connectionPool = {maxOpenConnections: 5});
```

#### Connection Pool Handling

All database modules share the same connection pooling concept and there are three possible scenarios for
connection pool handling. For its properties and possible values, see the [`sql:ConnectionPool`](https://docs.central.ballerina.io/ballerina/sql/latest/records/ConnectionPool).

1. Global, shareable, default connection pool

   If you do not provide the `poolOptions` field when creating the database client, a globally-shareable pool will be
   created for your database unless a connection pool matching with the properties you provided already exists.

    ```ballerina
    oracledb:Client|sql:Error dbClient = new (user = "adminUser", password = "adminPassword");
    ```

2. Client-owned, unsharable connection pool

   If you define the `connectionPool` field inline when creating the database client with the `sql:ConnectionPool` type,
   an unsharable connection pool will be created.

    ```ballerina
    oracledb:Client|sql:Error dbClient = new (user = "adminUser", password = "adminPassword",
                                           connectionPool = { maxOpenConnections: 5 });
    ```

3. Local, shareable connection pool

   If you create a record of the `sql:ConnectionPool` type and reuse that in the configuration of multiple clients,
   for each set of clients that connects to the same database instance with the same set of properties, a shared
   connection pool will be created.

    ```ballerina
    sql:ConnectionPool connPool = {maxOpenConnections: 5};
    
    oracledb:Client|sql:Error dbClient1 =       
                               new (user = "adminUser", password = "adminPassword",
                               connectionPool = connPool);
    oracledb:Client|sql:Error dbClient2 = 
                               new (user = "adminUser", password = "adminPassword",
                               connectionPool = connPool);
    oracledb:Client|sql:Error dbClient3 = 
                               new (user = "adminUser", password = "adminPassword",
                               connectionPool = connPool);
    ```

For more details about each property, see the [`oracledb:Client`](https://docs.central.ballerina.io/ballerinax/oracledb/latest/clients/Client) constructor.

The [oracledb:Client](https://docs.central.ballerina.io/ballerinax/oracledb/latest/clients/Client) references
[sql:Client](https://docs.central.ballerina.io/ballerina/sql/latest/clients/Client) and all the operations
defined by the `sql:Client` will be supported by the `oracledb:Client` as well.

#### Closing the Client

Once all the database operations are performed, you can close the database client you have created by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

```ballerina
error? e = dbClient.close();
```
Or
```ballerina
check dbClient.close();
```

### Database Operations

Once the client is created, database operations can be executed through that client. This module defines the interface
and common properties that are shared among multiple database clients.  It also supports querying, inserting, deleting,
updating, and batch updating data.

#### Parameterized Query

The `sql:ParameterizedQuery` is used to construct the SQL query to be executed by the client.
You can create a query with constant or dynamic input data as follows.

*Query with constant values*

```ballerina
sql:ParameterizedQuery query = `SELECT * FROM students 
                                WHERE id < 10 AND age > 12`;
```

*Query with dynamic values*

```ballerina
int[] ids = [10, 50];
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students 
                                WHERE id < ${ids[0]} AND age > ${age}`;
```

Moreover, the SQL package has `sql:queryConcat()` and `sql:arrayFlattenQuery()` util functions which make it easier
to create a dynamic/constant complex query.

The `sql:queryConcat()` is used to create a parameterized query by concatenating a set of parameterized queries.
The sample below shows how to concatenate queries.

```ballerina
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students`;
sql:ParameterizedQuery query1 = ` WHERE id < ${id} AND age > ${age}`;
sql:ParameterizedQuery sqlQuery = sql:queryConcat(query, query1);
```

The query with the `IN` operator can be created using the `sql:ParameterizedQuery` like below. Here you need to flatten the array and pass each element separated by a comma.

```ballerina
int[] ids = [1, 2, 3];
sql:ParameterizedQuery query = `SELECT count(*) as total FROM DataTable 
                                WHERE row_id in (${ids[0]}, ${ids[1]}, ${ids[2]})`;
```

The util function `sql:arrayFlattenQuery()` is introduced to make the array flatten easier. It makes the inclusion of varying array elements into the query easier by flattening the array to return a parameterized query. You can construct the complex dynamic query with the `IN` operator by using both functions like below.

```ballerina
int[] ids = [1, 2];
sql:ParameterizedQuery sqlQuery = 
                         sql:queryConcat(`SELECT * FROM DataTable WHERE id IN (`, 
                                          sql:arrayFlattenQuery(ids), `)`);
```

#### Creating Tables

This sample creates a table with two columns. One column is of type `int` and the other is of type `varchar`.
The `CREATE` statement is executed via the `execute` remote function of the client.

```ballerina
// Create the ‘Students’ table with the  ‘id’, 'name', and ‘age’ fields.
sql:ExecutionResult result = 
                check dbClient->execute(`CREATE TABLE student (
                                            id      NUMBER 
                                                    GENERATED BY DEFAULT AS IDENTITY START WITH 1 
                                                    PRIMARY KEY,
                                            age     NUMBER,
                                            name    VARCHAR(255)
                                        )`);
//A value of the sql:ExecutionResult type is returned for 'result'. 
```

#### Inserting Data

These samples show the data insertion by executing an `INSERT` statement using the `execute` remote function
of the client.

In this sample, the query parameter values are passed directly into the query statement of the `execute`
remote function.

```ballerina
sql:ExecutionResult result = check dbClient->execute(`INSERT INTO student(age, name)
                                                        VALUES (23, 'john')`);
```

In this sample, the parameter values, which are in local variables are used to parameterize the SQL query in
the `execute` remote function. This type of a parameterized SQL query can be used with any primitive Ballerina type
like `string`, `int`, `float`, or `boolean` and in that case, the corresponding SQL type of the parameter is derived
from the type of the Ballerina variable that is passed in.

```ballerina
string name = "Anne";
int age = 8;

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                  VALUES (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
```

In this sample, the parameter values are passed as a `sql:TypedValue` to the `execute` remote function. Use the
corresponding subtype of the `sql:TypedValue` such as `sql:VarcharValue`, `sql:CharValue`, `sql:IntegerValue`, etc., when you need to
provide more details such as the exact SQL type of the parameter.

```ballerina
sql:VarcharValue name = new ("James");
sql:IntegerValue age = new (10);

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                  VALUES (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Inserting Data With Auto-generated Keys

This sample demonstrates inserting data while returning the auto-generated keys. It achieves this by using the
`execute` remote function to execute the `INSERT` statement.

```ballerina
int age = 31;
string name = "Kate";

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                  VALUES (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
//Number of rows affected by the execution of the query.
int? count = result.affectedRowCount;
//The integer or string generated by the database in response to a query execution.
string|int? generatedKey = result.lastInsertId;
```

#### Querying Data

These samples show how to demonstrate the different usages of the `query` operation to query the
database table and obtain the results.

This sample demonstrates querying data from a table in a database.
First, a type is created to represent the returned result set. This record can be defined as an open or a closed record
according to the requirement. If an open record is defined, the returned stream type will include both defined fields
in the record and additional database columns fetched by the SQL query which are not defined in the record.
Note the mapping of the database column to the returned record's property is case-insensitive if it is defined in the
record(i.e., the `ID` column in the result can be mapped to the `id` property in the record). Additional Column names
added to the returned record as in the SQL query. If the record is defined as a close record, only defined fields in the
record are returned or gives an error when additional columns present in the SQL query. Next, the `SELECT` query is executed
via the `query` remote function of the client. Once the query is executed, each data record can be retrieved by looping
the result set. The `stream` returned by the select operation holds a pointer to the actual data in the database and it
loads data from the table only when it is accessed. This stream can be iterated only once.

```ballerina
// Define an open record type to represent the results.
type Student record {
    int id;
    int age;
    string name;
};

// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` samples, parameters can be passed as
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<Student, sql:Error?> resultStream = dbClient->query(query);

// Iterating the returned table.
error? e = resultStream.forEach(function(Student student) {
   //Can perform operations using the record 'student' of type `Student`.
});
```

Defining the return type is optional and you can query the database without providing the result type. Hence,
the above sample can be modified as follows with an open record type as the return type. The property name in the open record
type will be the same as how the column is defined in the database.

```ballerina
// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` samples, parameters can be passed as 
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<record{}, sql:Error?> resultStream = dbClient->query(query);

// Iterating the returned table.
error? e = resultStream.forEach(function(record{} student) {
    // Can perform operations using the record 'student'.
    io:println("Student name: ", student.value["name"]);
});
```

There are situations in which you may not want to iterate through the database and in that case, you may decide
to use the `sql:queryRow()` operation. If the provided return type is a record, this method returns only the first row
retrieved by the query as a record.

```ballerina
int id = 10;
sql:ParameterizedQuery query = `SELECT * FROM students WHERE id = ${id}`;
Student retrievedStudent = check dbClient->queryRow(query);
```

The `sql:queryRow()` operation can also be used to retrieve a single value from the database (e.g., when querying using
`COUNT()` and other SQL aggregation functions). If the provided return type is not a record (i.e., a primitive data type)
, this operation will return the value of the first column of the first row retrieved by the query.

```ballerina
int age = 12;
sql:ParameterizedQuery query = `SELECT COUNT(*) FROM students WHERE age < ${age}`;
int youngStudents = check dbClient->queryRow(query);
```

#### Updating Data

This sample demonstrates modifying data by executing an `UPDATE` statement via the `execute` remote function of
the client.

```ballerina
int age = 23;
sql:ParameterizedQuery query = `UPDATE students SET name = 'John' WHERE age = ${age}`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Deleting Data

This sample demonstrates deleting data by executing a `DELETE` statement via the `execute` remote function of
the client.

```ballerina
string name = "John";
sql:ParameterizedQuery query = `DELETE from students WHERE name = ${name}`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Batch Updating Data

This sample demonstrates how to insert multiple records with a single `INSERT` statement that is executed via the
`batchExecute` remote function of the client. This is done by creating a `table` with multiple records and
parameterized SQL query as same as the above `execute` operations.

```ballerina
// Create the table with the records that need to be inserted.
var data = [
  { name: "John", age: 25  },
  { name: "Peter", age: 24 },
  { name: "jane", age: 22 }
];

// Do the batch update by passing the batches.
sql:ParameterizedQuery[] batch = from var row in data
                                 select `INSERT INTO students ('name', 'age')
                                           VALUES (${row.name}, ${row.age})`;
sql:ExecutionResult[] result = check dbClient->batchExecute(batch);
```

#### Execute SQL Stored Procedures

This sample demonstrates how to execute a stored procedure with a single `INSERT` statement that is executed via the
`call` remote function of the client.

```ballerina
int uid = 10;
sql:IntegerOutParameter insertId = new;

sql:ProcedureCallResult result = 
                         check dbClient->call(`call InsertPerson(${uid}, ${insertId})`);
stream<record{}, sql:Error?>? resultStr = result.queryResult;
if resultStr is stream<record{}, sql:Error?> {
    sql:Error? e = resultStr.forEach(function(record{} result) {
      // Can perform operations using the record 'result'.
    });
}
check result.close();
```
Note that you have to invoke the close operation explicitly on the `sql:ProcedureCallResult` to release the connection resources and avoid a connection leak as shown above.

### OracleDB specific Custom data types
 
#### Interval Types

OracleDB has two `INTERVAL` data types `INTERVAL YEAR TO MONTH` and `INTERVAL DAY TO SECOND` to store the various `INTERVAL` periods. 

The equivalent types in Ballerina are as follows.

```ballerina
public type Sign +1|-1;

public type IntervalYearToMonth record {|
    Sign sign = +1;
    int:Unsigned32 years?;
    int:Unsigned32 months?;
|};

public type IntervalDayToSecond record {|
    Sign sign = +1;
    int:Unsigned32 days?;
    int:Unsigned32 hours?;
    int:Unsigned32 minutes?;
    decimal seconds?;
|};
```

Here, `oracledb:Sign` is used to mark the sign of the interval period and period values are always ZERO or positive integers. 

```ballerina
//INTERVAL '120-11' YEAR(3) TO MONTH
oracledb:IntervalYearToMonth intervalYM = {years: 120, months: 11};
//INTERVAL '120' YEAR(3)
oracledb:IntervalYearToMonth intervalYM2 = {years: 120};
//INTERVAL '-11' MONTH(3)
oracledb:IntervalYearToMonth intervalYM3 = {months: 11, sign: -1};
//INTERVAL '-120-11' YEAR(3) TO MONTH
oracledb:IntervalYearToMonth intervalYM4 = {years: 120, months: 11, sign: -1};

//INTERVAL '11 10:09:08.555' DAY TO SECOND(3)
oracledb:IntervalDayToSecond intervalDS = {days: 11, hours: 10, minutes: 9, seconds: 8.555};
//INTERVAL '-11 10:09:08.555' DAY TO SECOND(3)
oracledb:IntervalDayToSecond intervalDS2 = {days: 11, hours: 10, minutes: 9, seconds: 8.555, sign: -1};
//INTERVAL '-10:09:08.555' HOUR TO SECOND(3)
oracledb:IntervalDayToSecond intervalDS3 = {hours: 10, minutes: 9, seconds: 8.555, sign: -1};
//INTERVAL '11 00:09:08.55578' DAY TO SECOND(5)
oracledb:IntervalDayToSecond intervalDS4 = {days: 11, minutes: 9, seconds: 8.55578};
```
#### VARRAY Types

OracleDB has support for `VARRAY` data type and `VARRAY` consists a type name and elements attributes.

The `VARRAY` equivalent type in Ballerina are as follows.

```ballerina
type ArrayValueType string?[]|int?[]|boolean?[]|float?[]|decimal?[]|byte[]?[];

public type Varray record {|
    string name;
    ArrayValueType? elements;
|};
```

here, `oracledb:Varray` has two fields to set the type name and elements of the varray. In OracleDB, a `VARRAY` type can be created as follows.

```roomsql
CREATE OR REPLACE TYPE CharArrayType AS VARRAY(6) OF VARCHAR(100);

CREATE TABLE TestVarrayTable(
       PK               NUMBER GENERATED ALWAYS AS IDENTITY,
       COL_CHARARR      CharArrayType,
       PRIMARY KEY(PK)
);
```
In ballerina, `oracledb:Varray` can be used to pass values for `VARRAY` data type as follows.

```ballerina
string?[] charArray = [null, "Hello", "World"];
Varray charVarray = { name:"CharArrayType", elements: charArray };
```

#### BFILE Type

The `BFILE` data type is an Oracle proprietary data type that provides read-only access to binary file LOBs that are stored in file systems outside Oracle Database.
A `BFILE` column or attribute stores a `BFILE` locator, which serves as a pointer to a binary file on the server file system. The locator maintains the directory name and the filename.
Use the `CREATE DIRECTORY` statement to create a directory object in Oracle Database. A directory object specifies an alias for a directory on the server file system where external binary file LOBs (`BFILE`s) are located.

In Oracle Database, a `BFILE` type can be created and stored a value as follows, 

```roomsql
CREATE DIRECTORY BFILE_DIR as '/home/oracle/bfile-sample';

CREATE TABLE TestBFileTable(
    pk            NUMBER,
    col_bfile     BFILE,
    PRIMARY KEY(pk)
);

INSERT INTO TestBFileTable(pk, col_bfile) VALUES (1, BFILENAME('BFILE_DIR', 'bfile.txt'))
```

##### Passing BFILE Locator data

This ballerina sample demonstrates inserting and modifying `BFILE` data as follows,

```ballerina
string directory = "BFILE_DIR";
string fileName = "bfile.txt";
sql:ParameterizedQuery query = `INSERT INTO TestBFileTable(pk, col_bfile) VALUES (1, BFILENAME(${directory}, ${fileName}))`;
sql:ExecutionResult result = check dbClient->execute(query);

string newFileName = "newFile.txt";
sql:ParameterizedQuery updateQuery = `UPDATE TestBFileTable SET col_bfile = BFILENAME(${directory}, ${newFileName}) WHERE pk = 1`;
sql:ExecutionResult result = check dbClient->execute(updateQuery);
```

##### Reading BFILE data

`oracledb:BFile` type is used to get valid `BFILE` data from the Oracle Database and `oracledb` module provides three functions to perform file operations for `BFILE` data type. This sample demonstrates those three function usages as follows,

```ballerina
// define the request type for query method.
type BFileRequestType record {
    decimal pk;
    BFile col_bfile;
};
```

- `oracledb:isBFileExists(BFile bfile)` function to check the remote file existence in the file system. 

   ```ballerina
   sql:ParameterizedQuery sqlQuery = `SELECT * FROM TestBFileTable where pk = 1`;
   stream<BFileRequestType, error?> streamData = oracledbClient->query(sqlQuery);
   record {|BFileRequestType value;|}? data = check streamData.next();
   BFileRequestType? value = data?.value;
   if value is BFileRequestType {
       BFile bfile = <BFile> value["col_bfile"];
       boolean fileExists = isBFileExists(bfile);
   }
   ```

- `oracledb:bfileReadBytes(BFile bfile)` function to get all file data as a byte[]. 

   ```ballerina
   sql:ParameterizedQuery sqlQuery = `SELECT * FROM TestBFileTable where pk = 1`;
   stream<BFileRequestType, error?> streamData = oracledbClient->query(sqlQuery);
   record {|BFileRequestType value;|}? data = check streamData.next();
   BFileRequestType? value = data?.value;
   if value is BFileRequestType {
       BFile bfile = <BFile> value["col_bfile"];
       byte[] fileData = check bfileReadBytes(bfile);
   }
   ```
  
- `oracledb:bfileReadBlockAsStream(BFile bfile, int bufferSize)` function to read the file as a stream.

   ```ballerina
   sql:ParameterizedQuery sqlQuery = `SELECT * FROM TestBFileTable where pk = 1`;
   stream<BFileRequestType, error?> streamData = oracledbClient->query(sqlQuery);
   record {|BFileRequestType value;|}? data = check streamData.next();
   BFileRequestType? value = data?.value;
   if value is BFileRequestType {
       BFile bfile = <BFile> value["col_bfile"];
       stream<byte[], error?> streamArray = bfileReadBlockAsStream(bfile, 20);
       record {|byte[] value;|}? fileData = check streamArray.next();
       byte[]? dataBuffer = fileData?.value;
   }
   ```

>**Note:** The default thread pool size used in Ballerina is: `the number of processors available * 2`. You can configure the thread pool size by using the `BALLERINA_MAX_POOL_SIZE` environment variable.
