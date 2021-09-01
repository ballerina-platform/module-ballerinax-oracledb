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

# Represents the type that can be either minus one or plus one.
public type Sign +1|-1;

# Stores a period of time in years and months.
#
# + sign - sign of the interval value
# + years - Number of years
# + months - Number of months
public type IntervalYearToMonth record {|
    Sign sign = +1;
    int:Unsigned32 years?;
    int:Unsigned32 months?;
|};

# Stores a period of time in days, hours, minutes, and seconds.
#
# + sign - sign of the interval value
# + days - Number of days
# + hours - Number of hours
# + minutes - Number of minutes
# + seconds - Number of seconds
public type IntervalDayToSecond record {|
    Sign sign = +1;
    int:Unsigned32 days?;
    int:Unsigned32 hours?;
    int:Unsigned32 minutes?;
    decimal seconds?;
|};

# An abstraction of the real-world entities, such as purchase orders, that application programs deal with.
#
# + typename - Name of the object type
# + attributes - Attributes of the object
public type ObjectType record {|
    string typename;
    anydata[]? attributes;
|};

# An ordered set of data elements with a variable size. All elements of a given array are of the same data
# type.
#
# + name - Name of the varray
# + elements - Elements of the Varray
public type Varray record {|
    string name;
    byte[]|int[]|boolean[]|float[]|decimal[]|string[]? elements;
|};

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

# Represents Xml range OutParameter used in procedure calls
public distinct class XmlOutParameter {
    *sql:OutParameter;

    # Parses returned SQL value to ballerina value.
    #
    # + typeDesc - Type description of the data that need to be converted
    # + return - The converted ballerina value or Error
    public isolated function get(typedesc<anydata> typeDesc = <>) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor"
    } external;
}

# Represents IntervalYearToMonth OutParameter used in procedure calls
public distinct class IntervalYearToMonthOutParameter {
    *sql:OutParameter;

    # Parses returned SQL value to ballerina value.
    #
    # + typeDesc - Type description of the data that need to be converted
    # + return - The converted ballerina value or Error
    public isolated function get(typedesc<anydata> typeDesc = <>) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor"
    } external;
}

# Represents IntervalDayToSecond OutParameter used in procedure calls
public distinct class IntervalDayToSecondOutParameter {
    *sql:OutParameter;

    # Parses returned SQL value to ballerina value.
    #
    # + typeDesc - Type description of the data that need to be converted
    # + return - The converted ballerina value or Error
    public isolated function get(typedesc<anydata> typeDesc = <>) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor"
    } external;
}

# The class with custom implementations for nextResult and getNextQueryResult in the connector modules.
#
public class CustomResultIterator {
    public isolated function nextResult(sql:ResultIterator iterator) returns record {}|sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.utils.RecordIteratorUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;

    public isolated function getNextQueryResult(sql:ProcedureCallResult callResult)
    returns boolean|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.utils.ProcedureCallResultUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;
}
