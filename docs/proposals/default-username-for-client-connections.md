# Define default username for client connections

_Owners_: @kaneeldias  
_Reviewers_: @daneshk @niveathika  
_Created_: 2022/04/25  
_Updated_: 2022/04/25  
_Edition_: Swan Lake  
_Issues_: [#2397](https://github.com/ballerina-platform/ballerina-standard-library/issues/2397)

## Summary
Define default username to be used when connecting to an Oracle database on client initialization.

## History
The 1.3.x versions and below of the OracleDB package defaulted to connecting to the database without a username
attached (i.e. an empty string).

## Goals
- Define the default username to be used when connecting to an Oracle database on client initialization.

## Motivation
The ability to connect to common databases with default credentials (as opposed to manually defining) would make the
developer experience much more quick, simple and user-friendly, especially in testing scenarios.

## Description
For Oracle databases, the default username is `sys`[[1]](https://docs.oracle.com/database/121/ADMQS/GUID-CF1CD853-AF15-41EC-BC80-61918C73FDB5.htm#ADMQS12003)

Modify the [client initialization method](https://github.com/ballerina-platform/module-ballerinax-mssql/blob/dd331469cfed22073c66337278962cbad6dd565c/ballerina/Client.bal#L37-L38)
signature to use `sys` as the default value for the username instead of `()`.

```ballerina
    public isolated function init(string host = "localhost", string? user = "sys", string? password = (), 
        string? database = (), int port = 1521, Options? options = (), sql:ConnectionPool? connectionPool = ()) 
        returns sql:Error? {

```

## References
[1] https://docs.oracle.com/database/121/ADMQS/GUID-CF1CD853-AF15-41EC-BC80-61918C73FDB5.htm#ADMQS12003
