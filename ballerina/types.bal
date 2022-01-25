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

# Represents the Oracle (+/-) sign.
public type Sign +1|-1;

# Represents a period of time in years and months.
#
# + sign - Sign of the interval value
# + years - Number of years
# + months - Number of months
public type IntervalYearToMonth record {|
    Sign sign = +1;
    int:Unsigned32 years?;
    int:Unsigned32 months?;
|};

# Represents a period of time in days, hours, minutes, and seconds.
#
# + sign - Sign of the interval value
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

# Represents the Oracle UDT type, which is an abstraction of the real-world entities such as purchase orders that application programs deal with.
#
# + typename - Name of the object type
# + attributes - Attributes of the object
public type ObjectType record {|
    string typename;
    anydata[]? attributes;
|};

# Represents a Ballerina typed array.
type ArrayValueType string?[]|int?[]|boolean?[]|float?[]|decimal?[]|byte[]?[];

# Represents an ordered set of data elements with a variable size but with a maximum size defined. All elements of a given array are# of the same data type with null value support.
#
# + name - Name of the varray
# + elements - Elements of the Varray
public type Varray record {|
    string name;
    ArrayValueType? elements;
|};

# Represents an ordered set of data elements with a variable size.
#
# + name - Name of the varray
# + elements - Elements of the Varray
public type NestedTableType record {|
    string name;
    ArrayValueType? elements;
|};

# Represents the `OBJECT TYPE`` parameter in `sql:ParameterizedQuery`.
#
# + value - Value of the parameter passed into the SQL statement
public distinct class ObjectTypeValue {
    *sql:TypedValue;
    public ObjectType? value;

    public isolated function init(ObjectType? value = ()) {
        self.value = value;
    }
}

# Represents the `VARRAY` type parameter in `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
public distinct class VarrayValue {
    *sql:TypedValue;
    public Varray? value;

    public isolated function init(Varray? value = ()) {
        self.value = value;
    }
}

# Represents the `Nested Table` type parameter in `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
public distinct class NestedTableValue {
    *sql:TypedValue;
    public NestedTableType? value;

    public isolated function init(NestedTableType? value = ()) {
        self.value = value;
    }
}

# Represents the `XML range` `OutParameter` in `sql:ParameterizedCallQuery`.
public distinct class XmlOutParameter {
    *sql:OutParameter;

    # Parses the returned `Xml` SQL value to a Ballerina value.
    #
    # + typeDesc - The `typedesc` of the type to which the result needs to be returned
    # + return - The result in the `typeDesc` type, or an `sql:Error`
    public isolated function get(typedesc<anydata> typeDesc = <>) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor",
        name: "getOutParameterValue"
    } external;
}

# Represents the `IntervalYearToMonth` `OutParameter` in `sql:ParameterizedCallQuery`.
public distinct class IntervalYearToMonthOutParameter {
    *sql:OutParameter;

    # Parses the returned `IntervalYearToMonthOutParameter` SQL value to a Ballerina value.
    #
    # + typeDesc - The `typedesc` of the type to which the result needs to be returned
    # + return - The result in the `typeDesc` type, or an `sql:Error`
    public isolated function get(typedesc<anydata> typeDesc = <>) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor",
        "name": "getOutParameterValue"
    } external;
}

# Represents the `IntervalDayToSecond` `OutParameter` in `sql:ParameterizedCallQuery`.
public distinct class IntervalDayToSecondOutParameter {
    *sql:OutParameter;

    # Parses the returned `IntervalDayToSecondOutParameter` SQL value to a Ballerina value.
    #
    # + typeDesc - The `typedesc` of the type to which the result needs to be returned
    # + return - The result in the `typeDesc` type, or an `sql:Error`
    public isolated function get(typedesc<anydata> typeDesc = <>) returns typeDesc|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.oracledb.nativeimpl.OutParameterProcessor",
        "name": "getOutParameterValue"
    } external;
}

# The iterator for the stream returned from the `query` function to be used to override the default behaviour of `sql:ResultIterator`.
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
