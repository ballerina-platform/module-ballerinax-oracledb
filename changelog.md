# Change Log

This file contains all the notable changes done to the Ballerina oracledb package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

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
