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

import ballerina/lang.'transaction as transactions;
// import ballerina/io;
import ballerina/sql;
import ballerina/test;

type TransactionResultCount record {
    int COUNTVAL;
};

public class SQLDefaultRetryManager {
    private int count;
    public function init(int count = 2) {
        self.count = count;
    }
    public function shouldRetry(error? e) returns boolean {
        if e is error && self.count >  0 {
            self.count -= 1;
            return true;
        } else {
            return false;
        }
    }
}

@test:BeforeGroups { value:["local-transaction"] }
isolated function beforeExecuteWithParamsFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    sql:ExecutionResult result = check dropTableIfExists("LocalTransCustomers");
    result = check oracledbClient->execute("CREATE TABLE LocalTransCustomers("+
        "id NUMBER GENERATED ALWAYS AS IDENTITY, "+
        "firstName VARCHAR2(100), " +
        "lastName VARCHAR2(100), " +
        "registrationID NUMBER, " +
        "creditLimit VARCHAR2(100), " +
        "country VARCHAR2(100), " +
        "PRIMARY KEY (id) " +
        ")"
    );
}

@test:Config {
    groups: ["transaction", "local-transaction"]
}
function testLocalTransaction() returns error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, DATABASE, PORT);
    int retryVal = -1;
    boolean committedBlockExecuted = false;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        var res = check oracledbClient->execute("Insert into LocalTransCustomers (firstName, lastName, " + 
            "registrationID, creditLimit, country) values ('James', 'Clerk', 200, 5000.75, 'USA')");
        res = check oracledbClient->execute("Insert into LocalTransCustomers (firstName, lastName, registrationID," + 
            "creditLimit, country) values ('James', 'Clerk', 200, 5000.75, 'USA')");
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
        var e1 = check oracledbClient->execute("Insert into LocalTransCustomers (firstName,lastName,registrationID," +
                "creditLimit,country) values ('James', 'Clerk', 210, 5000.75, 'USA')");
        var e2 = check oracledbClient->execute("Insert into LocalTransCustomers2 (firstName,lastName,registrationID," +
                    "creditLimit,country) values ('James', 'Clerk', 210, 5000.75, 'USA')");
        stmtAfterFailureExecutedRWC  = true;
        check commit;
    }
}


@test:Config {
    groups: ["transaction", "local-transaction"],
    dependsOn: [testTransactionRollbackWithCheck]
}
function testTransactionRollbackWithRollback() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    int retryVal = -1;
    boolean stmtAfterFailureExecuted = false;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        var e1 = oracledbClient->execute("Insert into LocalTransCustomers (firstName,lastName,registrationID," +
                "creditLimit,country) values ('James', 'Clerk', 211, 5000.75, 'USA')");
        if (e1 is error){
            rollback;
        } else {
            var e2 = oracledbClient->execute("Insert into LocalTransCustomers2 (firstName,lastName,registrationID," +
                        "creditLimit,country) values ('James', 'Clerk', 211, 5000.75, 'USA')");
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
function testLocalTransactionUpdateWithGeneratedKeys() returns error? {
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    int returnVal = 0;
    transactions:Info transInfo;
    retry<SQLDefaultRetryManager>(1) transaction {
        transInfo = transactions:info();
        var e1 = check oracledbClient->execute("Insert into LocalTransCustomers " +
         "(firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')");
        var e2 =  check oracledbClient->execute("Insert into LocalTransCustomers " +
        "(firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')");
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
    Client oracledbClient = check new (HOST, USER, PASSWORD, DATABASE, PORT);
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
        var e1 = check oracledbClient->execute("Insert into LocalTransCustomers " +
         "(firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')");
        var e2 = check oracledbClient->execute("Insert into LocalTransCustomers2 " +
        "(firstName,lastName,registrationID,creditLimit,country) values ('James', 'Clerk', 615, 5000.75, 'USA')");
        check commit;
    }
}

function getCount(Client oracledbClient, string id) returns @tainted int|error {
    stream<TransactionResultCount, sql:Error> streamData = 
        <stream<TransactionResultCount, sql:Error>> oracledbClient->query("Select COUNT(*) as " +
        "countval from LocalTransCustomers where registrationID = "+ id, TransactionResultCount);
        record {|TransactionResultCount value;|}? data = check streamData.next();
        check streamData.close();
        TransactionResultCount? value = data?.value;
        if(value is TransactionResultCount){
           return value["COUNTVAL"];
        }
        return 0;
}
