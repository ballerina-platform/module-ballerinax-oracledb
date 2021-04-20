## Package overview

This Package provides the functionality required to access and manipulate data stored in an `Oracle Database`.  

**Prerequisite:** Add the Oracle Database JDBC thin driver JAR as a native library dependency in your Ballerina project.
Once you build the project by executing the `ballerina build` command, you should be able to run the resultant by
executing the `ballerina run` command.

Change the path to the JDBC driver appropriately in the example `Balleirna.toml` content below.

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

To access a database, you must first create an 
[oracledb:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) object.
The examples for creating an OracleDB client can be found below.

#### Creating a client

This example shows different ways of creating the `oracledb:Client`.

The client can be created with an empty constructor and hence, the client will be initialized with the default 
properties. The first example with the `dbClient1` demonstrates this.

The `dbClient2` receives the host, username, and password. Since the properties are passed in the same order 
as it is defined in the `oracledb:Client`, you can pass it without named params.

The `dbClient3` uses the named params to pass the attributes since it is skipping some params in the constructor.
Further, the [oracledb:Options](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/records/Options)
property is passed to configure the SSL and connection timeout in the OracleDB client.

Similarly, the `dbClient4` uses the named params and it provides an unshared connection pool of the
[sql:ConnectionPool](https://ballerina.io/learn/api-docs/ballerina/#/sql/records/ConnectionPool) type
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
oracldb:Client|sql:Error dbClient4 = new (user = "rootUser", password = "rootPass", 
    connectionPool = {maxOpenConnections: 5});
```

You can find more details about each property in the
[oracledb:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) constructor.

The [oracledb:Client](https://ballerina.io/learn/api-docs/ballerina/#/oracledb/clients/Client) references 
[sql:Client](https://ballerina.io/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and all the operations 
defined by the `sql:Client` will be supported by the `oracledb:Client` as well.

For more information on all the operations supported by the `oracledb:Client`, which include the below, see the 
[SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

1. Connection pooling

``` ballerina
oracledb:Client|sql:Error oracledbClient = new (user = "rootUser", password = "rootPass", database = "School", 
    connectionPool = {maxOpenConnections: 5});
```

2. Creating tables

``` ballerina
sql:ExecutionResult result = check oracledbClient->execute(string `CREATE TABLE Students(id NUMBER, name  VARCHAR2(200), 
    PRIMARY KEY(id))`);
```

3. Inserting data

``` ballerina
sql:ExecutionResult result = check oracledbClient->execute("INSERT INTO Students(id, name) VALUES (1, 'John')");

int id = 2;
string name = "Mike";
sql:ParameterizedQuery insertQuery = `insert into Students(id, name)values(${id}, ${name})`;
result = check oracledbClient->execute(insertQuery);

```

4. Querying data

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

5. Updating data

``` ballerina
int id = 1;
sql:ParameterizedQuery updateQuery = `Update Students set name = "Max" where id = ${id}`;
sql:ExecutionResult result = check oracledbClient->execute(updateQuery);
```

6. Deleting data

``` ballerina
int id = 1;
sql:ParameterizedQuery deleteQuery = `Delete from Students where id = ${id}`;
sql:ExecutionResult result = check oracledbClient->execute(deleteQuery);
```

7. Inserting and updating data in batches

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

8. Executing stored procedures

``` ballerina
int id = 6;
string name = "Anne";
sql:ParameterizedCallQuery sqlQuery = `CALL InsertStudent(${id}, ${name})`;

sql:ProcedureCallResult callResult = check oracledbClient->call(sqlQuery);
```

9. Closing the client

``` ballerina
check oracledbClient.close();
```

10. Custom data types
    1. Interval Types
        - Creating a table with INTERVAL YEAR TO MONTH and INTERVAL DAY TO SECOND

        ``` ballerina
        sql:ExecutionResult result = check oracledbClient->execute("CREATE TABLE TestDateTimeTable(" +
            "PK NUMBER GENERATED ALWAYS AS IDENTITY, " +
            "COL_INTERVAL_YEAR_TO_MONTH INTERVAL YEAR TO MONTH, " +
            "COL_INTERVAL_DAY_TO_SECOND INTERVAL DAY(9) TO SECOND(9), " +
            "PRIMARY KEY(PK) " +
            ")"
        );
        ```

        - Inserting data

        ``` ballerina
        oracledb:IntervalYearToMonthValue intervalYtoM = new({ years:15, months: 11 });
        oracledb:IntervalDayToSecondValue intervalDtoS = new({ days:13, hours: 5, minutes: 34, seconds: 23.45 });

        sql:ParameterizedQuery insertQuery = `INSERT INTO TestDateTimeTable( 
            COL_INTERVAL_YEAR_TO_MONTH, COL_INTERVAL_DAY_TO_SECOND) VALUES   
            (${intervalYtoM}, ${intervalDtoS})`;
        sql:ExecutionResult result = check oracledbClient->execute(insertQuery);
        io:println("Rows affected: ", result.affectedRowCount);
        ```

    2. Object Types
        - Creating object types and Table with columns of created object types

        ``` ballerina
        sql:ExecutionResult result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE OBJECT_TYPE OID '19A57209ECB73F91E03400400B40BB25' AS OBJECT(" +
                "STRING_ATTR VARCHAR(20), " +
                "INT_ATTR NUMBER, " +
                "FLOAT_ATTR FLOAT, " +
                "DECIMAL_ATTR FLOAT " +
            ") "
        );
        result = check oracledbClient->execute("CREATE TABLE TestObjectTypeTable(" +
            "PK NUMBER GENERATED ALWAYS AS IDENTITY, " +
            "COL_OBJECT OBJECT_TYPE, " +
            "PRIMARY KEY(PK) " +
            ")"
        );

        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE NESTED_TYPE OID '19A57209ECB73F91E03400400B40BB23' AS OBJECT(" +
                "STRING_ATTR VARCHAR2(20), " +
                "OBJECT_ATTR OBJECT_TYPE, " +
                "MAP MEMBER FUNCTION GET_ATTR1 RETURN NUMBER " +
            ") "
        );
        result = check oracledbClient->execute("CREATE TABLE TestNestedObjectTypeTable(" +
            "PK NUMBER GENERATED ALWAYS AS IDENTITY, " +
            "COL_NESTED_OBJECT NESTED_TYPE, " +
            "PRIMARY KEY(PK) " +
            ")"
        );
        ```

        - Inserting data

        ``` ballerina
        string string_attr = "Hello world";
        int int_attr = 1;
        float float_attr = 34.23;
        decimal decimal_attr = 34.23;

        oracledb:ObjectTypeValue objectType = new({typename: "object_type", 
            attributes: [ string_attr, int_attr, float_attr, decimal_attr]});

        sql:ParameterizedQuery insertQuery = `INSERT INTO TestObjectTypeTable(COL_OBJECT) VALUES(${objectType})`;
        result = check oracledbClient->execute(insertQuery);
        io:println("Rows affected: ", result.affectedRowCount);
        ```

        - Selecting data

        ``` ballerina
        type ObjectRecord record {
            string string_attr;
            int int_attr;
            float float_attr;
            decimal decimal_attr;
        };

        type ObjectRecordType record {
            int pk;
            ObjectRecord col_object;
        };

        stream<record{}, error> streamResult = oracledbClient->query(
            "SELECT pk, col_object FROM TestObjectTypeTable WHERE pk = 1", ObjectRecordType);
        stream<ObjectRecordType, sql:Error> streamData = <stream<ObjectRecordType, sql:Error>>streamResult;
        record {|ObjectRecordType value;|}? data = check streamData.next();
        check streamData.close();
        ObjectRecordType? value = data?.value;
        if (value is ()) {
            io:println("Returned data is nil");
        } else {
            ObjectRecord objRecord = value["col_object"];

            io:println(objRecord["string_attr"]);
            io:println(objRecord["int_attr"]);
            io:println(objRecord["float_attr"]);
            io:println(objRecord["decimal_attr"]);
            io:println(objRecord["decimal_attr"]);
        }

        ```

        - Inserting a nested object

        ``` ballerina
        string string_attr = "Hello world";
        int int_attr = 34;
        float float_attr = 34.23;
        decimal decimal_attr = 34.23;

        anydata[] attributes = [ string_attr,[string_attr, int_attr, float_attr, decimal_attr]];
        oracledb:ObjectTypeValue objectType = new({typename: "nested_type", attributes: attributes});

        sql:ParameterizedQuery insertQuery = `INSERT INTO TestNestedObjectTypeTable(COL_NESTED_OBJECT)
            VALUES(${objectType})`;
        result = check oracledbClient->execute(insertQuery);

        io:println("Rows affected: ", result.affectedRowCount);
        ```

        - Selecting a nested object

        ``` ballerina
        type NestedObjectRecord record {
            string string_attr;
            ObjectRecord object_attr;
        };

        type NestedObjectRecordType record {
            int pk;
            NestedObjectRecord col_nested_object;
        };

        stream<record{}, error> streamResult = oracledbClient->query(
        "SELECT pk, col_nested_object FROM TestNestedObjectTypeTable WHERE pk = 1", NestedObjectRecordType);
        stream<NestedObjectRecordType, sql:Error> streamData = <stream<NestedObjectRecordType, sql:Error>>streamResult;
        record {|NestedObjectRecordType value;|}? data = check streamData.next();
        check streamData.close();
        NestedObjectRecordType? value = data?.value;
        if (value is ()) {
            io:println("Returned data is nil");
        } else {
            NestedObjectRecord nestedRecord = value["col_nested_object"];
            ObjectRecord objRecord = nestedRecord["object_attr"];

            io:println(nestedRecord["string_attr"]);

            io:println(objRecord["string_attr"]);
            io:println(objRecord["int_attr"]);
            io:println(objRecord["float_attr"]);
            io:println(objRecord["decimal_attr"]);
            io:println(objRecord["decimal_attr"]);
        }
        ```

    3. Varray Type

        - Creating Varray types and tables with columns of varray types

        ``` ballerina
        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE CharArrayType AS VARRAY(6) OF VARCHAR(100);");
        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE ByteArrayType AS VARRAY(6) OF RAW(100);");
        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE IntArrayType AS VARRAY(6) OF NUMBER;");
        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE BoolArrayType AS VARRAY(6) OF NUMBER;");
        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE FloatArrayType AS VARRAY(6) OF FLOAT;");
        result = check oracledbClient->execute(
            "CREATE OR REPLACE TYPE DecimalArrayType AS VARRAY(6) OF NUMBER;");
            
        result = check oracledbClient->execute("CREATE TABLE TestVarrayTable(" +
            "PK NUMBER GENERATED ALWAYS AS IDENTITY, " +
            "COL_CHARARR CharArrayType, " +
            "COL_BYTEARR ByteArrayType, " +
            "COL_INTARR IntArrayType, " +
            "COL_BOOLARR BoolArrayType, " +
            "COL_FLOATARR FloatArrayType, " +
            "COL_DECIMALARR DecimalArrayType, " +
            "PRIMARY KEY(PK) " +
            ")"
        );
        ```

        - Inserting data

        ``` ballerina
        string[] charArray = ["Hello", "World"];
        byte[] byteArray = [4, 23, 12];
        int[] intArray = [3,4,5];
        boolean[] boolArray = [true, false, false];
        float[] floatArray = [34, -98.23, 0.981];
        decimal[] decimalArray = [34, -98.23, 0.981];

        oracledb:VarrayValue charVarray = new({ name:"CharArrayType", elements: charArray });
        oracledb:VarrayValue byteVarray = new({ name:"ByteArrayType", elements: byteArray });
        oracledb:VarrayValue intVarray = new({ name:"IntArrayType", elements: intArray });
        oracledb:VarrayValue boolVarray = new({ name:"BoolArrayType", elements: boolArray });
        oracledb:VarrayValue floatVarray = new({ name:"FloatArrayType", elements: floatArray });
        oracledb:VarrayValue decimalVarray = new({ name:"DecimalArrayType", elements: decimalArray });

        sql:ParameterizedQuery insertQuery = `insert into TestVarrayTable(
                COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR)
                values(${charVarray}, ${byteVarray}, ${intVarray}, ${boolVarray}, ${floatVarray}, ${decimalVarray})`;
        sql:ExecutionResult result = check oracledbClient->execute(insertQuery);

        io:println("Rows affected: ", result.affectedRowCount);
        ```

        - Selecting data

        ``` ballerina
        stream<record{}, error> streamResult = oracledbClient->query(
            "SELECT pk, COL_CHARARR, COL_BYTEARR, COL_INTARR, COL_BOOLARR, COL_FLOATARR, COL_DECIMALARR " +
            "FROM TestVarrayTable WHERE pk = 1", ArrayRecordType);
        stream<ArrayRecordType, sql:Error> streamData = <stream<ArrayRecordType, sql:Error>>streamResult;
        record {|ArrayRecordType value;|}? data = check streamData.next();
        check streamData.close();
        ArrayRecordType? value = data?.value;
        if (value is ()) {
            io:println("Returned data is nil");
        } else {
            io:println(value.length());
            io:println(value.pk);
            io:println(value.col_chararr);
            io:println(value.col_bytearr);
            io:println(value.col_intarr);
            io:println(value.col_boolarr);
            io:println(value.col_floatarr);
            io:println(value.col_decimalarr);
        }
        check oracledbClient.close();
        ```
