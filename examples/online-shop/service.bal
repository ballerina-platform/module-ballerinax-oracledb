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

import ballerina/http;
import ballerina/sql;
import ballerinax/oracledb;
import ballerina/time;

const string USER = "balUser";
const string PASSWORD = "balpass";
const string HOST = "localhost";
const int PORT = 1521;
const string DATABASE = "ORCLCDB.localdomain";

oracledb:Client dbClient = check new(host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE);
listener http:Listener onlineShopListener = new (9090);

public type Customer record {
    decimal customer_id;
    string name;
    string address;
    string credit_limit;
    string website;
};

public type Order record {
    decimal order_id;
    decimal customer_id;
    string status;
    decimal salesman_id;
    time:Civil order_date;
};

service /online-shop on onlineShopListener {
    resource function get customers() returns Customer[]|error {
        Customer[] customers = [];
        stream<Customer, error?> resultStream = check dbClient->query(`SELECT * FROM CUSTOMERS`);
        check resultStream.forEach(function(Customer customer) {
           customers.push(customer);
        });
        check resultStream.close();
        return customers;
    }
}