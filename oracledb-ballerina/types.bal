// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;
import ballerina/sql;

type IntervalYearToMonthRecord record {|
    int|string year;
    int|string month;
|};

# Represents INTERVAL YEAR TO MONTH Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class IntervalYearToMonthValue {
    public IntervalYearToMonthRecord|string? value;

    public isolated function init(IntervalYearToMonthRecord|string? value = ()) {
        self.value = value;
    }
}


# The class with custom implementations for nextResult and getNextQueryResult in the connector modules.
# 
public class CustomResultIterator {
    isolated function nextResult(sql:ResultIterator iterator) returns record {}|sql:Error? = @java:Method {
        'class: "org.ballerinalang.oracledb.utils.RecordIteratorUtils"
    } external;

    isolated function getNextQueryResult(sql:ProcedureCallResult callResult) returns boolean|sql:Error? = @java:Method {
        'class: "org.ballerinalang.oracledb.utils.ProcedureCallResultUtils"
    } external;
}

