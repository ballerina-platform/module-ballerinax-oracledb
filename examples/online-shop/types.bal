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

import ballerina/time;
import ballerinax/oracledb;

public type Customer record {
    decimal customer_id;
    string name;
    string? address;
    string? credit_limit;
    string? website;
};

public type CustomerInput record {
    string name;
    string? address;
    string? credit_limit;
    string? website;
};

public type Order record {
    decimal order_id;
    decimal customer_id;
    string status;
    decimal? salesman_id;
    time:Civil order_date;
};

public type Employee record {
    decimal employee_id;
    string first_name;
    string last_name;
    string email;
    string phone;
    time:Civil hire_date;
    decimal? manager_id;
    string job_title;
};

public type Product record {
    decimal product_id;
    string product_name;
    string? description;
    decimal? standard_cost;
    decimal? list_price;
};

public type OrderItem record {
    decimal order_id;
    decimal item_id;
    decimal product_id;
    decimal quantity;
    decimal unit_price;
    oracledb:IntervalYearToMonth? warranty_period;
};

public type Contact record {
    decimal contact_id;
    string first_name;
    string last_name;
    string email;
    string? phone;
    decimal? customer_id;
};
