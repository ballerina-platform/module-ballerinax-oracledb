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


# Structure of INTERVAL YEAR TO MONTH.
# + year - Number of years
# + month - Number of months
type IntervalYearToMonthRecord record {|
    int year;
    int month;
|};


# Structure of INTERVAL DAY TO SECOND.
# + day - Number of days
# + hour - Number of hours
# + minute - Number of minutes
# + second - Number of seconds
type IntervalDayToSecondRecord record {|
    int day;
    int hour;
    int minute;
    float second;
|};


# Structure of BFILE.
# + directory - Directory of the file
# + file - File name
type BfileRecord record {|
    string directory;
    string file;
|};


# Structure of OBJECT TYPE.
# + typeName - Name of the object type
# + attributes - Attributes of the object
type ObjectTypeRecord record {|
    string typeName;
    anydata[] attributes;
|};


# Structure of VARRAY.
# + name - Name of the varray
# + elements - Elements of the Varray
type VarrayRecord record {|
    string name;
    anydata[] elements;
|};


# Structure of NESTED TABLE.
# + name - Name of the varray
# + attributes - Attributes of the nested table
type NestedTableRecord record {|
    string name;
    anydata[] attributes;
|};


# Structure of NESTED TABLE.
# + xml - Xml string
type XmlRecord record {|
    string 'xml;
|};


# Represents INTERVAL YEAR TO MONTH Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class IntervalYearToMonthValue {
    public string|IntervalYearToMonthRecord? value;

    public isolated function init(string|IntervalYearToMonthRecord? value = ()) {
        self.value = value;
    }
}


# Represents INTERVAL DAY TO SECOND Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class IntervalDayToSecondValue {
    public string|IntervalDayToSecondRecord? value;

    public isolated function init(string|IntervalDayToSecondRecord? value = ()) {
        self.value = value;
    }
}


# Represents BFILE Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class BfileValue {
    public BfileRecord? value;

    public isolated function init(BfileRecord? value = ()) {
        self.value = value;
    }
}


# Represents OBJECT TYPE Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class ObjectTypeValue {
    public ObjectTypeRecord? value;

    public isolated function init(ObjectTypeRecord? value = ()) {
        self.value = value;
    }
}


# Represents VARRAY Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class VarrayValue {
    public VarrayRecord? value;

    public isolated function init(VarrayRecord? value = ()) {
        self.value = value;
    }
}


# Represents NESTED TABLE Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class NestedTableValue {
    public NestedTableRecord? value;

    public isolated function init(NestedTableRecord? value = ()) {
        self.value = value;
    }
}


# Represents NESTED TABLE Oracle DB field.
#
# + value - Value of parameter passed into the SQL statement
public class XmlValue {
    public XmlRecord? value;

    public isolated function init(XmlRecord? value = ()) {
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

