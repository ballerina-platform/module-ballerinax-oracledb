# Ballerina OracleDB module Example use case

## Overview 
This example demonstrates how to use the Ballerina `oracledb` module to execute, query, and call etc. in an Oracle database. 

Here, a sample database is used to demonstrate the functionalities. This sample database models an imaginary shop that sells
computer hardware, and the database has six tables namely, `CUSTOMERS`, `CONTACTS`, `EMPLOYEES`, `PRODUCTS`, `PURCHASES`, and `PURCHASEITEMS`.

The shop has customer information including the name, address, etc. with their respective contact details. It also maintains an employee list
of the shop. Once a customer places a purchase with different purchase items chosen from the products list, the shop can follow up and update 
the purchase status in several stages like `Pending`, `Shipped`, or `Cancelled`.

## Implementation

These are HTTP RESTful services used to insert, create, and retrieve data of a sample database.

## Prerequisite

* *Adding the oracledb JDBC thin driver and their dependencies*

    * Download and add the OracleDB thin driver `ojdbc8.jar` along with the `xdb.jar` and `xmlparserv2.jar` files as native 
      library dependencies in the example Ballerina project's `Ballerina.toml` file. It is recommended to use an Oracle 
      thin driver `ojdbc8.jar` version greater than 12.2.0.1. As per the existing `Ballerina.toml` file, it points to 
      those dependencies in the `ballerina` folder. You may have to download those dependencies and update the `Ballerina.toml`
      file.
      
      Follow one of the ways below to add the JAR in the file: 
      
      * Download the JAR files and update the path.
        ```
        [[platform.java17.dependency]]
        path = "PATH"
        ```
        or
        
      * Add the JAR with the Maven dependency params.
        ```
        [platform.java17.dependency]]
        groupId = "com.oracle.database.jdbc"
        artifactId = "ojdbc8"
        version = "12.2.0.1"
  
        [platform.java17.dependency]]
        groupId = "com.oracle.database.xml"
        artifactId = "xdb"
        version = "21.1.0.0"
  
        [platform.java17.dependency]]
        groupId = "com.oracle.database.xml"
        artifactId = "xmlparserv2"
        version = "12.2.0.1"
        ```

* *Initial schema, table creation, and data insertion*

    * Start and run the Oracle database Docker container or standalone database.
      
    * Run the `schema_with_data.sql` script against the Oracle database.
        * Navigate to the `setup` folder of the `examples/onlineshop` directory, and open the `schema_with_data.sql` file.
        * Run the content of the file in the Oracle database. 
    
## Run the Example
To start the service, navigate to the `examples/onlineshop` folder, and execute the command below.
It will build the posts of the Ballerina project and then run it.

```
$bal run
```
