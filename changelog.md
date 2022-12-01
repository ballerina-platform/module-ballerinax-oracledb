# Change Log

This file contains all the notable changes done to the Ballerina oracledb package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed
- [Remove SQL_901 diagnostic hint](https://github.com/ballerina-platform/ballerina-standard-library/issues/3609)

## [1.6.1] - 2022-12-01

### Changed
- [Updated API Docs on `oracledb.driver` usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/3710)

## [1.6.0] - 2022-11-29

### Added
- [Support for XA transaction](https://github.com/ballerina-platform/ballerina-standard-library/issues/3599)

### Changed
- [Updated API Docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3463)

## [1.5.1] - 2022-11-11

### Added
- [Support for XA transaction](https://github.com/ballerina-platform/ballerina-standard-library/issues/3599)

## [1.5.0] - 2022-09-08

### Changed
- [Change default username for client initialization to `sys`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2397)

## [1.4.2] - 2022-11-11

### Added
- [Support for XA transaction](https://github.com/ballerina-platform/ballerina-standard-library/issues/3599)

## [1.4.1] - 2022-06-27

### Changed
- [Fix NullPointerException when retrieving record with default value](https://github.com/ballerina-platform/ballerina-standard-library/issues/2985)

## [1.4.0] - 2022-05-30

### Added
- [Improve DB columns to Ballerina record Mapping through Annotation](https://github.com/ballerina-platform/ballerina-standard-library/issues/2652)

### Changed
- [Fixed compiler plugin validation for `time` module constructs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2893)
- [Fix incorrect code snippet in SQL api docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2931)

## [1.3.1] - 2022-03-01

### Changed
- [Improve API documentation to reflect query usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/2524)

## [1.3.0] - 2022-01-29

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool` and `oracledb:Options`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.1] - 2022-02-03

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool` and `oracledb:Options`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.0] - 2021-12-13

### Added
- [Tooling support for OracleDB module](https://github.com/ballerina-platform/ballerina-standard-library/issues/2283)

## [1.1.0] - 2021-11-20

### Changed
- [Change queryRow return type to anydata](https://github.com/ballerina-platform/ballerina-standard-library/issues/2390)
- [Make OutParameter get function parameter optional](https://github.com/ballerina-platform/ballerina-standard-library/issues/2388)

## [1.0.0] - 2021-10-09

### Added
- [Add Nested Table support](https://github.com/ballerina-platform/ballerina-standard-library/issues/1665)
- [Add mix array type support](https://github.com/ballerina-platform/ballerina-standard-library/issues/1816)
- [Add Interval support](https://github.com/ballerina-platform/ballerina-standard-library/issues/1763)
- [Add SSL support](https://github.com/ballerina-platform/ballerina-standard-library/issues/1672)
- [Add support for queryRow](https://github.com/ballerina-platform/ballerina-standard-library/issues/1750)
- [Add xml data type support in oracledb module](https://github.com/ballerina-platform/ballerina-standard-library/issues/1695)
- Basic CRUD functionalities with an Oracle database.
- Insert functionality for complex data types.
- Add code examples for oracle specific data types to Package.md.
- Select functionality for VArrays and Object Types.
- Upgrade ojdbc driver version from 12 to 19.

### Changed
- [Remove support for string parameter in SQL APIs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2010)
