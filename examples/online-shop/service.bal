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
import ballerinax/oracledb;

const string USER = "balUser";
const string PASSWORD = "balpass";
const string HOST = "localhost";
const int PORT = 1521;
const string DATABASE = "ORCLCDB.localdomain";

final oracledb:Client dbClient = check new(host = HOST, user = USER, password = PASSWORD, port = PORT,
    database = DATABASE, connectionPool = {maxOpenConnections: 3, minIdleConnections: 1});
listener http:Listener onlineShopListener = new (9090);

service /onlineshop on onlineShopListener {
    resource function get employees() returns Employee[]|error? {
        Employee[] employees = [];
         stream<Employee, error?> resultStream = dbClient->query(`SELECT * FROM EMPLOYEES`);
         _ = check resultStream.forEach(function(Employee employee) {
            employees.push(employee);
         });
         check resultStream.close();
         return employees;
    }

    resource function get employees/[decimal id]() returns Employee|error? {
        stream<Employee, error?> resultStream = dbClient->query(`SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = ${id}`);
        record {|Employee value;|}? data = check resultStream.next();
        check resultStream.close();
        return data?.value;
    }

    resource function get totalemployeesCount() returns int|error? {
        return check dbClient->queryRow(`SELECT COUNT(*) FROM EMPLOYEES`, int);
    }

    resource function get products() returns Product[]|error? {
        Product[] products = [];
        stream<Product, error?> resultStream = dbClient->query(`SELECT * FROM PRODUCTS`);
        _ = check resultStream.forEach(function(Product product) {
           products.push(product);
        });
        check resultStream.close();
        return products;
    }

    resource function get products/[decimal id]() returns Product|error? {
        stream<Product, error?> resultStream = dbClient->query(`SELECT * FROM PRODUCTS WHERE PRODUCT_ID = ${id}`);
        record {|Product value;|}? data = check resultStream.next();
        check resultStream.close();
        return data?.value;
    }

    resource function get customers() returns Customer[]|error? {
        Customer[] customers = [];
        stream<Customer, error?> resultStream = dbClient->query(`SELECT * FROM CUSTOMERS`);
        _ = check resultStream.forEach(function(Customer customer) {
           customers.push(customer);
        });
        check resultStream.close();
        return customers;
    }

    resource function get customers/[decimal id]() returns Customer|error? {
        stream<Customer, error?> resultStream = dbClient->query(`SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = ${id}`);
        record {|Customer value;|}? data = check resultStream.next();
        check resultStream.close();
        return data?.value;
    }

    resource function get orders() returns Order[]|error? {
        Order[] orders = [];
        stream<Order, error?> resultStream = dbClient->query(`SELECT * FROM ORDERS`);
        _ = check resultStream.forEach(function(Order order) {
           orders.push(order);
        });
        check resultStream.close();
        return orders;
    }

    resource function get orders/[decimal id]() returns Order|error? {
        stream<Order, error?> resultStream = dbClient->query(`SELECT * FROM ORDERS WHERE ORDER_ID = ${id}`);
        record {|Order value;|}? data = check resultStream.next();
        check resultStream.close();
        return data?.value;
    }

    resource function get orderItems() returns OrderItem[]|error? {
        OrderItem[] orderItems = [];
        stream<OrderItem, error?> resultStream = dbClient->query(`SELECT * FROM ORDER_ITEMS`);
        _ = check resultStream.forEach(function(OrderItem orderItem) {
           orderItems.push(orderItem);
        });
        check resultStream.close();
        return orderItems;
    }

    resource function get orderItemsByOrderId/[decimal id]() returns OrderItem[]|error? {
        OrderItem[] orderItems = [];
        stream<OrderItem, error?> resultStream = dbClient->query(`SELECT * FROM ORDER_ITEMS WHERE ORDER_ID = ${id}`);
        _ = check resultStream.forEach(function(OrderItem orderItem) {
           orderItems.push(orderItem);
        });
        check resultStream.close();
        return orderItems;
    }

    resource function get contacts() returns Contact[]|error? {
        Contact[] contacts = [];
        stream<Contact, error?> resultStream = dbClient->query(`SELECT * FROM CONTACTS`);
        _ = check resultStream.forEach(function(Contact contact) {
           contacts.push(contact);
        });
        check resultStream.close();
        return contacts;
    }

    resource function get contactsByCustomerId/[decimal id]() returns Contact[]|error? {
        Contact[] contacts = [];
        stream<Contact, error?> resultStream = dbClient->query(`SELECT * FROM CONTACTS WHERE CUSTOMER_ID = ${id}`);
        _ = check resultStream.forEach(function(Contact contact) {
           contacts.push(contact);
        });
        check resultStream.close();
        return contacts;
    }

    resource function get contacts/[decimal id]() returns Contact|error? {
        stream<Contact, error?> resultStream = dbClient->query(`SELECT * FROM CONTACTS WHERE CONTACT_ID = ${id}`);
        record {|Contact value;|}? data = check resultStream.next();
        check resultStream.close();
        return data?.value;
    }
}
