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

import ballerina/io;
import ballerina/lang.'transaction as transactions;
import ballerina/sql;
import ballerina/test;

type TransactionResultCount record {
    int COUNTVAL;
};

public class SQLDefaultRetryManager {
    private int count;
    public isolated function init(int count = 2) {
        self.count = count;
    }
    public isolated function shouldRetry(error? e) returns boolean {
        if e is error && self.count >  0 {
            self.count -= 1;
            return true;
        } else {
            return false;
        }
    }
}

@test:Config {
    groups: ["transaction", "local-transaction"]
}
isolated function testLocalTransaction() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int retryVal = -1;
    boolean committedBlockExecuted = false;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        var res = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName, lastName,
            registrationID, creditLimit, country) values ('James', 'Clerk', 200, 5000.75, 'USA')`);
        res = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName, lastName, registrationID,
            creditLimit, country) values ('James', 'Clerk', 200, 5000.75, 'USA')`);
        transInfo = transactions:info();
        var commitResult = commit;
        if(commitResult is ()){
            committedBlockExecuted = true;
        }
    }
    retryVal = transInfo.retryNumber;
    //check whether update action is performed
    int count = check getCount(oracledbClient, "200");
    check oracledbClient.close();

    test:assertEquals(retryVal, 0);
    test:assertEquals(count, 2);
    test:assertEquals(committedBlockExecuted, true);
}

boolean stmtAfterFailureExecutedRWC = false;
int retryValRWC = -1;
@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testLocalTransaction]
}
function testTransactionRollbackWithCheck() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    error? result = testTransactionRollbackWithCheckHelper(oracledbClient);
    int count = check getCount(oracledbClient, "210");
    check oracledbClient.close();

    test:assertEquals(retryValRWC, 1);
    test:assertEquals(count, 0);
    test:assertEquals(stmtAfterFailureExecutedRWC, false);
}

function testTransactionRollbackWithCheckHelper(Client oracledbClient) returns error? {
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        retryValRWC = transInfo.retryNumber;
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                    creditLimit,country) values ('James', 'Clerk', 210, 5000.75, 'USA')`);
        var e2 = check oracledbClient->execute(`Insert into LocalTranCustomers2 (firstName,lastName,registrationID,
                    creditLimit,country) values ('James', 'Clerk', 210, 5000.75, 'USA')`);
        stmtAfterFailureExecutedRWC  = true;
        check commit;
    }
}


@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionRollbackWithCheck]
}
isolated function testTransactionRollbackWithRollback() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int retryVal = -1;
    boolean stmtAfterFailureExecuted = false;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        var e1 = oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                creditLimit,country) values ('James', 'Clerk', 211, 5000.75, 'USA')`);
        if (e1 is error){
            rollback;
        } else {
            var e2 = oracledbClient->execute(`Insert into LocalTranCustomers2 (firstName,lastName,registrationID,
                        creditLimit,country) values ('James', 'Clerk', 211, 5000.75, 'USA')`);
            if (e2 is error) {
                rollback;
                stmtAfterFailureExecuted  = true;
            } else {
                check commit;
            }
        }
    }
    retryVal = transInfo.retryNumber;
    int count = check getCount(oracledbClient, "211");
    check oracledbClient.close();

    test:assertEquals(retryVal, 0);
    test:assertEquals(count, 0);
    test:assertEquals(stmtAfterFailureExecuted, true);

}

@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionRollbackWithRollback]
}
isolated function testLocalTransactionUpdateWithGeneratedKeys() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int returnVal = 0;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers
            (firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')`);
        var e2 =  check oracledbClient->execute(`Insert into LocalTranCustomers
            (firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')`);
        check commit;
    }
    returnVal = transInfo.retryNumber;
    //Check whether the update action is performed.
    int count = check getCount(oracledbClient, "615");
    check oracledbClient.close();

    test:assertEquals(returnVal, 0);
    test:assertEquals(count, 2);
}

int returnValRGK = 0;
@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testLocalTransactionUpdateWithGeneratedKeys]
}
function testLocalTransactionRollbackWithGeneratedKeys() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    error? result = testLocalTransactionRollbackWithGeneratedKeysHelper(oracledbClient);
    //check whether update action is performed
    int count = check getCount(oracledbClient, "615");
    check oracledbClient.close();
    test:assertEquals(returnValRGK, 1);
    test:assertEquals(count, 2);
}

function testLocalTransactionRollbackWithGeneratedKeysHelper(Client oracledbClient) returns error? {
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        returnValRGK = transInfo.retryNumber;
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers
            (firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')`);
        var e2 = check oracledbClient->execute(`Insert into LocalTranCustomers2
            (firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')`);
        check commit;
    }
}

isolated int abortVal = 0;

@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testLocalTransactionRollbackWithGeneratedKeys]
}
isolated function testTransactionAbort() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    transactions:Info transInfo;

    var abortFunc = isolated function(transactions:Info? info, error? cause, boolean willTry) {
        lock {
            abortVal = -1;
        }
    };

    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        transactions:onRollback(abortFunc);
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers
            (firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 220, 5000.75, 'USA')`);
        var e2 =  check oracledbClient->execute(`Insert into LocalTranCustomers
            (firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 220, 5000.75, 'USA')`);
        int i = 0;
        if (i == 0) {
            rollback;
        } else {
            check commit;
        }
    }
    int returnVal = transInfo.retryNumber;
    //Check whether the update action is performed.
    int count = check getCount(oracledbClient, "220");
    check oracledbClient.close();

    test:assertEquals(returnVal, 0);
    lock {
        test:assertEquals(abortVal, -1);
    }
    test:assertEquals(count, 0);
}


int testTransactionErrorPanicRetVal = 0;
@test:Config {
    enable: false,
    groups: ["transaction", "local-transaction"]
}
function testTransactionErrorPanic() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int returnVal = 0;
    int catchValue = 0;
    var ret = trap testTransactionErrorPanicHelper(oracledbClient);
    io:println(ret);
    if (ret is error) {
        catchValue = -1;
    }
    //Check whether the update action is performed.
    int count = check getCount(oracledbClient, "260");
    check oracledbClient.close();
    test:assertEquals(testTransactionErrorPanicRetVal, 1);
    test:assertEquals(catchValue, -1);
    test:assertEquals(count, 0);
}

function testTransactionErrorPanicHelper(Client oracledbClient) returns error? {
    int returnVal = 0;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,
                              registrationID,creditLimit,country) values ('James', 'Clerk', 260, 5000.75, 'USA')`);
        int i = 0;
        if (i == 0) {
            error e = error("error");
            panic e;
        } else {
            var r = check commit;
        }
    }
    io:println("exec");
    testTransactionErrorPanicRetVal = transInfo.retryNumber;
}

@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionAbort]
}
isolated function testTransactionErrorPanicAndTrap() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int catchValue = 0;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                 creditLimit,country) values ('James', 'Clerk', 250, 5000.75, 'USA')`);
        var ret = trap testTransactionErrorPanicAndTrapHelper(0);
        if (ret is error) {
            catchValue = -1;
        }
        check commit;
    }
    int returnVal = transInfo.retryNumber;
    //Check whether the update action is performed.
    int count = check getCount(oracledbClient, "250");
    check oracledbClient.close();
    test:assertEquals(returnVal, 0);
    test:assertEquals(catchValue, -1);
    test:assertEquals(count, 1);
}

isolated function testTransactionErrorPanicAndTrapHelper(int i) {
    if (i == 0) {
        error err = error("error");
        panic err;
    }
}


@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionErrorPanicAndTrap]
}
isolated function testTwoTransactions() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    transactions:Info transInfo1;
    transactions:Info transInfo2;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo1 = transactions:info();
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                                    creditLimit,country) values ('James', 'Clerk', 400, 5000.75, 'USA')`);
        var e2 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                                    creditLimit,country) values ('James', 'Clerk', 400, 5000.75, 'USA')`);
        check commit;
    }
    int returnVal1 = transInfo1.retryNumber;

    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo2 = transactions:info();
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                        creditLimit,country) values ('James', 'Clerk', 400, 5000.75, 'USA')`);
        var e2 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                        creditLimit,country) values ('James', 'Clerk', 400, 5000.75, 'USA')`);
        check commit;
    }
    int returnVal2 = transInfo2.retryNumber;

    //Check whether the update action is performed.
    int count = check getCount(oracledbClient, "400");
    check oracledbClient.close();
    test:assertEquals(returnVal1, 0);
    test:assertEquals(returnVal2, 0);
    test:assertEquals(count, 4);
}

@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTwoTransactions]
}
isolated function testTransactionWithoutHandlers() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    transaction {
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
        creditLimit,country) values ('James', 'Clerk', 350, 5000.75, 'USA')`);
        var e2 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
        creditLimit,country) values ('James', 'Clerk', 350, 5000.75, 'USA')`);
        check commit;
    }
    //Check whether the update action is performed.
    int count = check getCount(oracledbClient, "350");
    check oracledbClient.close();
    test:assertEquals(count, 2);
}

isolated string rollbackOut = "";

@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionWithoutHandlers]
}
function testLocalTransactionFailed() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    string a = "beforetx";

    var ret = trap testLocalTransactionFailedHelper(oracledbClient);
    if (ret is string) {
        a += ret;
    } else {
        a += ret.message() + " trapped";
    }
    a = a + " afterTrx";
    int count = check getCount(oracledbClient, "111");
    check oracledbClient.close();
    test:assertEquals(a, "beforetx inTrx trxAborted inTrx trxAborted inTrx trapped afterTrx");
    test:assertEquals(count, 0);
}

isolated function testLocalTransactionFailedHelper(Client oracledbClient) returns string|error {
    transactions:Info transInfo;
    int i = 0;

    var onRollbackFunc = isolated function(transactions:Info? info, error? cause, boolean willTry) {
        lock {
           rollbackOut += " trxAborted";
        }
    };

    retry<SQLDefaultRetryManager>(2) transaction {
        lock {
           rollbackOut += " inTrx";
        }
        transInfo = transactions:info();
        transactions:onRollback(onRollbackFunc);
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers (firstName,lastName,registrationID,
                        creditLimit,country) values ('James', 'Clerk', 111, 5000.75, 'USA')`);
        var e2 = oracledbClient->execute(`Insert into LocalTranCustomers2 (firstName,lastName,registrationID,
                        creditLimit,country) values ('Anne', 'Clerk', 111, 5000.75, 'USA')`);
        if(e2 is error) {
           check getError();
        }
        check commit;
    }
    lock {
       return rollbackOut;
    }
}

isolated function getError() returns error? {
    lock {
       return error(rollbackOut);
    }
}

@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionWithoutHandlers]
}
isolated function testLocalTransactionSuccessWithFailed() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);

    string a = "beforetx";
    string | error ret = trap testLocalTransactionSuccessWithFailedHelper(a, oracledbClient);
    if (ret is string) {
        a = ret;
    } else {
        a = a + "trapped";
    }
    a = a + " afterTrx";
    int count = check getCount(oracledbClient, "222");
    check oracledbClient.close();
     test:assertEquals(a, "beforetx inTrx inTrx inTrx committed afterTrx");
    test:assertEquals(count, 2);
}

isolated function testLocalTransactionSuccessWithFailedHelper(string status,Client oracledbClient)
returns string|error {
    int i = 0;
    string a = status;
    retry<SQLDefaultRetryManager>(3) transaction {
        i = i + 1;
        a = a + " inTrx";
        var e1 = check oracledbClient->execute(`Insert into LocalTranCustomers(firstName,lastName,registrationID,
                        creditLimit,country) values ('James', 'Clerk', 222, 5000.75, 'USA')`);
        if (i == 3) {
            var e2 = check oracledbClient->execute(`Insert into LocalTranCustomers(firstName,lastName,registrationID,
                        creditLimit,country) values ('Anne', 'Clerk', 222, 5000.75, 'USA')`);
        } else {
            var e3 = check oracledbClient->execute(`Insert into LocalTranCustomers2(firstName,lastName,
                        registrationID,creditLimit,country) values ('Anne', 'Clerk', 222, 5000.75, 'USA')`);
        }
        check commit;
        a = a + " committed";
    }
    return a;
}

isolated function getCount(Client oracledbClient, string id) returns @tainted int|error {
    stream<TransactionResultCount, sql:Error?> streamData = oracledbClient->query(`Select COUNT(*) as
        countval from LocalTranCustomers where registrationID = ${id}`);
        record {|TransactionResultCount value;|}? data = check streamData.next();
        check streamData.close();
        TransactionResultCount? value = data?.value;
        if(value is TransactionResultCount){
           return value["COUNTVAL"];
        }
        return 0;
}
