# Proposal: BFILE Type Support
_Owners_:  @daneshk @niveathika @lahirusamith   
_Reviewers_: @daneshk @niveathika   
_Created_: 2021/10/04   
_Updated_: 2021/10/07   
_Issue_: [#1944](https://github.com/ballerina-platform/ballerina-standard-library/issues/1944)   

## Summary
Add BFILE data type support to `oracledb` module.

## Goals
Implement support for BFILE datatype in `oracledb` module.

## Motivation
BFILE is an Oracle proprietary data type that provides read-only access to data located outside the database tablespaces on tertiary storage devices, such as hard disks, network mounted files systems, CD-ROMs, PhotoCDs, and DVDs. BFILE data is not under transaction control and is not stored by database backups. As it is a proprietary data type in the oracle database, it would allow users to query and update BFILE datatype with this support.

## Description

The BFILE data type enables access to files that are stored in file systems outside Oracle Database. A BFILE column or attribute stores a BFILE locator, which serves as a pointer to a binary file on the server file system. The locator maintains the directory name and the filename.

The database administrator must ensure that the external file exists and that Oracle processes have the operating system read permissions on the file.
The BFILE data type enables read-only support of large binary files. You cannot modify or replicate such a file. Oracle provides APIs to access file data.

The purpose of this proposal is to implement the BFILE support in `oracledb` module. Functionalities provided through this support are

- Ballerina type to indicate BFILE datatype in queries
- Perform file operations on the external files stored as BFILE in Oracle  DB such as reading, etc.

Proposed ballerina record for the oracle specific BFILE data type,

```ballerina
type BFile record {
  string name;
  int length;
};
```

Proposed three function signatures that would access the `oracledb:BFile` record and read content, etc. 

```ballerina
isolated function bfileExists(BFile bfile) returns boolean {
  //implement logic here
}

isolated function bfileReadBytes(BFile bfile) returns byte[]|sql:Error? {
  //implement logic here
}

isolated function bfileReadBlockAsStream(BFile bfile, int bufferSize) returns stream<byte[], error?>  {
  //implement logic here
}
```
