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
import ballerina/sql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final oracledb:Client dbClient = check new(host = HOST, user = USER, password = PASSWORD, port = PORT,
    database = DATABASE, connectionPool = {maxOpenConnections: 3, minIdleConnections: 1});

service /onlineshop on new http:Listener(9090) {
    resource function get employees() returns Employee[]|error? {
        Employee[] employees = [];
         stream<Employee, error?> resultStream = dbClient->query(`SELECT * FROM EMPLOYEES`);
         _ = check resultStream.forEach(function(Employee employee) {
            employees.push(employee);
         });
         check resultStream.close();
         return employees;
    }

    resource function get employees/[int id]() returns Employee|error? {
        Employee employee = check dbClient->queryRow(`SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = ${id}`);
        return employee;
    }

    resource function get employees/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM EMPLOYEES`);
        return count;
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

    resource function get products/[int id]() returns Product|error? {
        Product product = check dbClient->queryRow(`SELECT * FROM PRODUCTS WHERE PRODUCT_ID = ${id}`);
        return product;
    }

    resource function get products/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM PRODUCTS`);
        return count;
    }

    resource function put products/[int id](@http:Payload Product product) returns string|error? {
        oracledb:VarrayValue reviewArray = new ({name: "ReviewArrayType", elements: product.reviews});
        sql:ParameterizedQuery query = `UPDATE PRODUCTS SET PRODUCT_NAME = ${product.product_name},
        DESCRIPTION = ${product.description}, STANDARD_COST = ${product.standard_cost},
        LIST_PRICE = ${product.list_price}, REVIEWS = ${reviewArray} where PRODUCT_ID = ${id}`;
        sql:ExecutionResult result = check dbClient->execute(query);
        return result.lastInsertId.toString();
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

    resource function get customers/[int id]() returns Customer|error? {
        Customer customer = check dbClient->queryRow(`SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = ${id}`);
        return customer;
    }

    resource function get customers/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM CUSTOMERS`);
        return count;
    }

    resource function post customers(@http:Payload CustomerInput customer) returns string|error? {
        sql:ParameterizedQuery query = `INSERT INTO CUSTOMERS (NAME,ADDRESS,CREDIT_LIMIT,WEBSITE) VALUES
        (${customer.name}, ${customer.address}, ${customer.credit_limit}, ${customer.website})`;
        sql:ExecutionResult result = check dbClient->execute(query);
        return result.lastInsertId.toString();
    }

    resource function delete customers/[int id]() returns string|error? {
        sql:ExecutionResult result = check dbClient->execute(`DELETE FROM CUSTOMERS WHERE CUSTOMER_ID = ${id}`);
        return result.affectedRowCount.toString();
    }

    resource function put customers/[int id](@http:Payload Customer customer) returns string|error? {
        sql:ParameterizedQuery query = `UPDATE CUSTOMERS SET NAME = ${customer.name}, ADDRESS = ${customer.address},
        CREDIT_LIMIT = ${customer.credit_limit},WEBSITE = ${customer.website} where CUSTOMER_ID = ${id}`;
        sql:ExecutionResult result = check dbClient->execute(query);
        return result.lastInsertId.toString();
    }

    resource function get purchases() returns Purchase[]|error? {
        Purchase[] purchases = [];
        stream<Purchase, error?> resultStream = dbClient->query(`SELECT * FROM PURCHASES`);
        _ = check resultStream.forEach(function(Purchase purchase) {
           purchases.push(purchase);
        });
        check resultStream.close();
        return purchases;
    }

    resource function get purchases/[int id]() returns Purchase|error? {
        Purchase purchase = check dbClient->queryRow(`SELECT * FROM PURCHASES WHERE PURCHASE_ID = ${id}`);
        return purchase;
    }

    resource function get purchases/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM PURCHASES`);
        return count;
    }

    resource function get purchaseitems() returns PurchaseItem[]|error? {
        PurchaseItem[] purchaseItems = [];
        stream<PurchaseItem, error?> resultStream = dbClient->query(`SELECT * FROM PURCHASE_ITEMS`);
        _ = check resultStream.forEach(function(PurchaseItem purchaseItem) {
           purchaseItems.push(purchaseItem);
        });
        check resultStream.close();
        return purchaseItems;
    }

    resource function get purchaseitems/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM PURCHASE_ITEMS`);
        return count;
    }

    resource function get purchases/[int id]/items() returns PurchaseItem[]|error? {
        PurchaseItem[] purchaseItems = [];
        stream<PurchaseItem, error?> resultStream = dbClient->query(`SELECT * FROM PURCHASE_ITEMS WHERE PURCHASE_ID = ${id}`);
        _ = check resultStream.forEach(function(PurchaseItem purchaseItem) {
           purchaseItems.push(purchaseItem);
        });
        check resultStream.close();
        return purchaseItems;
    }

    resource function get purchases/[int id]/items/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM PURCHASE_ITEMS WHERE PURCHASE_ID = ${id}`);
        return count;
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

    resource function get customers/[int id]/contacts() returns Contact[]|error? {
        Contact[] contacts = [];
        stream<Contact, error?> resultStream = dbClient->query(`SELECT * FROM CONTACTS WHERE CUSTOMER_ID = ${id}`);
        _ = check resultStream.forEach(function(Contact contact) {
           contacts.push(contact);
        });
        check resultStream.close();
        return contacts;
    }

    resource function get contacts/[int id]() returns Contact|error? {
        Contact contact = check dbClient->queryRow(`SELECT * FROM CONTACTS WHERE CONTACT_ID = ${id}`);
        return contact;
    }

    resource function get contacts/count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM CONTACTS`);
        return count;
    }
}
