// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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


# IntervalYearToMonth stores a period of time in years and months.
#
# + years - Number of years
# + months - Number of months
type IntervalYearToMonth record {|
    int years;
    int months;
|};


# IntervalDayToSecond stores a period of time in days, hours, minutes, and seconds.
#
# + days - Number of days
# + hours - Number of hours
# + minutes - Number of minutes
# + seconds - Number of seconds
type IntervalDayToSecond record {|
    int days;
    int hours;
    int minutes;
    decimal seconds;
|};


# ObjectType is an abstraction of the real-world entities, such as purchase orders, that application programs deal with.
#
# + typename - Name of the object type
# + attributes - Attributes of the object
type ObjectType record {|
    string typename;
    anydata[]? attributes;
|};


# Varray is an ordered set of data elements with a variable size. All elements of a given array are of the same data
# type.
#
# + name - Name of the varray
# + elements - Elements of the Varray
type Varray record {|
    string name;
    byte[]|int[]|boolean[]|float[]|decimal[]|string[]? elements;
|};


# Represents INTERVAL YEAR TO MONTH Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public distinct class IntervalYearToMonthValue {
    *sql:TypedValue;
    public string|IntervalYearToMonth? value;

    public isolated function init(string|IntervalYearToMonth? value = ()) {
        self.value = value;
    }
}


# Represents INTERVAL DAY TO SECOND Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public distinct class IntervalDayToSecondValue {
    *sql:TypedValue;
    public string|IntervalDayToSecond? value;

    public isolated function init(string|IntervalDayToSecond? value = ()) {
        self.value = value;
    }
}


# Represents OBJECT TYPE Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public distinct class ObjectTypeValue {
    *sql:TypedValue;
    public ObjectType? value;

    public isolated function init(ObjectType? value = ()) {
        self.value = value;
    }
}


# Represents VARRAY Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public distinct class VarrayValue {
    *sql:TypedValue;
    public Varray? value;

    public isolated function init(Varray? value = ()) {
        self.value = value;
    }
}


# Represents NESTED TABLE Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public distinct class XmlValue {
    *sql:TypedValue;
    public string|xml? value;

    public isolated function init(string|xml? value = ()) {
        self.value = value;
    }
}


# The class with custom implementations for nextResult and getNextQueryResult in the connector modules.
#
public class CustomResultIterator {
    public isolated function nextResult(sql:ResultIterator iterator) returns record {}|sql:Error? = @java:Method {
        'class: "org.ballerinalang.oracledb.utils.RecordIteratorUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;

    public isolated function getNextQueryResult(sql:ProcedureCallResult callResult)
    returns boolean|sql:Error = @java:Method {
        'class: "org.ballerinalang.oracledb.utils.ProcedureCallResultUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;
}
