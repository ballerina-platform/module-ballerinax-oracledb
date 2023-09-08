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

### Initial schema, table creation, and data insertion

* Start and run the Oracle database Docker container or standalone database.
  
* Run the `schema_with_data.sql` script against the Oracle database.
    * Navigate to the `setup` folder of the `examples/onlineshop` directory, and open the `schema_with_data.sql` file.
    * Run the content of the file in the Oracle database. 
    
## Run the Example
To start the service, navigate to the `examples/onlineshop` folder, and execute the command below.
It will build the posts of the Ballerina project and then run it.

```shell
bal run
```
