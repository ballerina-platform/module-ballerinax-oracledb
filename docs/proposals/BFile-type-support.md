# Proposal: BFILE Type Support
_Ownes_:  @daneshk @niveathika @lahirusamith
_Reviewers_:
_Created_: 2021/10/04
_Updated_: 2021/10/04
_Issue_: [#1944](https://github.com/ballerina-platform/ballerina-standard-library/issues/1944)

## Summary
Add BFILE data type support to `oracledb` module.

## Goals
implement support for BFILE datatype in `oracledb` module.

## Motivation
BFILE is an Oracle proprietary data type that provides read-only access to data located outside the database tablespaces on tertiary storage devices, such as hard disks, network mounted files systems, CD-ROMs, PhotoCDs, and DVDs. BFILE data is not under transaction control and is not stored by database backups. As it is a proprietary data type in oracle database, it is good to provide a support for BFILE data type in `oracledb` module.

## Description

The BFILE data type enables access to files that are stored in file systems outside Oracle Database. A BFILE column or attribute stores a BFILE locator, which serves as a pointer to a binary file on the server file system. The locator maintains the directory name and the filename.

The database administrator must ensure that the external file exists and that Oracle processes have operating system read permissions on the file.
The BFILE data type enables read-only support of large binary files. You cannot modify or replicate such a file. Oracle provides APIs to access file data.

the purpose of this proposal is to implement the BFILE support in `oracledb` module.  Therefor the key functionalities expected when implementing BFILE data type is as follows,

- a proper ballerina type to pass the BFILE locator to a `sql:ParameterizedQuery`
- retrieve a proper ballerina type as `oracledb:BFile` from the oracle database
- `bfileExists`, `bfileReadBytes`, and `bfileReadBlockAsStream` functions for interacting with proposed `oracledb:BFile`

Following is the proposed ballerina type as for a BFILE locator which consists of two fields namely, directory and fileName:

```ballerina
public type BFileLocator record {|
   string directory;
   string fileName;
|};
```

Following is an example for `oracledb:BFileLocator` which is used to pass the BFILE locator to `sql:ParameterizedQuery`:

```ballerina
oracledb:BFileLocator bFileLocator = {directory: "Test_Dir", fileName: "test.pdf"};
sql:ParameterizedQuery = `INSERT INTO bfile_table(col_bfile) VALUES (${bFileLocator}))`;
```
Following is the proposed ballerina type to map with the oracle specific BFILE data type:

```ballerina
type BFile record {
  string name;
  int length;
};
```

Following are the function signatures would interact with `oracledb:BFile` :

```ballerina
function bfileExists(BFile bfile) returns boolean {
  //implement logic here
}

function bfileReadBytes(BFile bfile) returns byte[] {
  //implement logic here
}

function bfileReadBlockAsStream(BFile bfile, int length) returns stream<> {
  //implement logic here
}
```
