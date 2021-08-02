// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.

// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime as runtime;
import ballerina/lang.'string as stringutils;
import ballerina/sql;
import ballerina/test;

const string POOLDB = DATABASE;

public type Result record {
  int val;
};

Options options = {
    loginTimeout: 1,
    autoCommit: true,
    connectTimeout: 30,
    socketTimeout: 30
};

@test:BeforeGroups { value:["pool"] }
isolated function beforePoolTestFunc() returns sql:Error? {
    Client oracledbClient = check new(HOST, USER, PASSWORD, POOLDB, POOLPORT);

    sql:ExecutionResult result = check dropPoolTableIfExists("PoolCustomers");
    result = check oracledbClient->execute(`CREATE TABLE PoolCustomers (
        customerId NUMBER GENERATED ALWAYS AS IDENTITY,
        firstName  VARCHAR2(300),
        lastName  VARCHAR2(300),
        registrationID NUMBER,
        creditLimit FLOAT,
        country  VARCHAR2(300),
        PRIMARY KEY (customerId))`
    );
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    result = check oracledbClient->execute(
        `INSERT INTO PoolCustomers (firstName,lastName,registrationID,creditLimit,country)
        VALUES ('Peter', 'Stuart', 1, 5000.75, 'USA')`);

    result = check oracledbClient->execute(
        `INSERT INTO PoolCustomers (firstName,lastName,registrationID,creditLimit,country)
        VALUES ('Dan', 'Brown', 2, 10000, 'UK')`);

    check oracledbClient.close();
}

@test:Config {
  groups: ["pool"]
}
function testLocalSharedConnectionPoolConfigSingleDestination() returns sql:Error? {
  sql:ConnectionPool pool = {maxOpenConnections: 5, minIdleConnections: 5};
  Client oracleDbClient1 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient2 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient3 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient4 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient5 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);

  (stream<record{}, error?>)[] resultArray = [];
  resultArray[0] = oracleDbClient1->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  resultArray[1] = oracleDbClient2->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  resultArray[2] = oracleDbClient3->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  resultArray[3] = oracleDbClient4->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  resultArray[4] = oracleDbClient5->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  resultArray[5] = oracleDbClient5->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);

  (int|error)[] returnArray = [];
  int i = 0;
  // Connections will be released here as we fully consume the data in the following conversion function calls
  foreach var x in resultArray {
      returnArray[i] = getReturnValue(x);
      i += 1;
  }

  check oracleDbClient1.close();
  check oracleDbClient2.close();
  check oracleDbClient3.close();
  check oracleDbClient4.close();
  check oracleDbClient5.close();

  // All 5 clients are supposed to use the same pool created with the configurations given by the
  // custom pool options. Since each select operation holds up one connection each, the last select
  // operation should return an error
  i = 0;
  while(i < 5) {
      test:assertEquals(returnArray[i], 1);
      i = i + 1;
  }
  validateConnectionTimeoutError(returnArray[5]);
}

@test:Config {
  groups: ["pool"]
}
isolated function testLocalSharedConnectionPoolConfigDifferentDbOptions() returns sql:Error? {
  sql:ConnectionPool pool = {maxOpenConnections: 3, minIdleConnections: 3};
  Client oracleDbClient1 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT,
      {connectTimeout: 2, socketTimeout: 10}, pool);
  Client oracleDbClient2 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT,
      {socketTimeout: 10, connectTimeout: 2}, pool);
  Client oracleDbClient3 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT,
      {connectTimeout: 2, socketTimeout: 10}, pool);
  Client oracleDbClient4 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT,
      {connectTimeout: 1}, pool);
  Client oracleDbClient5 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT,
      {connectTimeout: 1}, pool);
    Client oracleDbClient6 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT,
        {connectTimeout: 1}, pool);

    stream<record {} , error?>[] resultArray = [];
    resultArray[0] = oracleDbClient1->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[1] = oracleDbClient2->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[2] = oracleDbClient3->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);
    resultArray[3] = oracleDbClient3->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);

    resultArray[4] = oracleDbClient4->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[5] = oracleDbClient5->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);
    resultArray[6] = oracleDbClient6->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);
    resultArray[7] = oracleDbClient6->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);

  (int|error)[] returnArray = [];
  int i = 0;
  // Connections will be released here as we fully consume the data in the following conversion function calls
  foreach var x in resultArray {
      returnArray[i] = getReturnValue(x);
      i += 1;
  }

  check oracleDbClient1.close();
  check oracleDbClient2.close();
  check oracleDbClient3.close();
  check oracleDbClient4.close();
  check oracleDbClient5.close();
  check oracleDbClient6.close();

  // Since max pool size is 3, the last select function call going through each pool should fail.
  i = 0;
  while(i < 3) {
      test:assertEquals(returnArray[i], 1);
      test:assertEquals(returnArray[i + 4], 1);
      i = i + 1;
  }
  validateConnectionTimeoutError(returnArray[3]);
  validateConnectionTimeoutError(returnArray[7]);

}

@test:Config {
  groups: ["pool"],
  enable: false
}
function testLocalSharedConnectionPoolConfigMultipleDestinations() returns sql:Error? {
    sql:ConnectionPool pool1 = {maxOpenConnections: 3, minIdleConnections: 3};
    sql:ConnectionPool pool2 = {maxOpenConnections: 4, minIdleConnections: 4};
    Client oracleDbClient1 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool1);
    Client oracleDbClient2 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool1);
    Client oracleDbClient3 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool1);
    Client oracleDbClient4 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool2);
    Client oracleDbClient5 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool2);
    Client oracleDbClient6 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool2);
    Client oracleDbClient7 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool2);

    stream<record {} , error?>[] resultArray = [];
    resultArray[0] = oracleDbClient1->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[1] = oracleDbClient2->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[2] = oracleDbClient3->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);
    resultArray[3] = oracleDbClient3->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);

    resultArray[4] = oracleDbClient4->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[5] = oracleDbClient5->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);
    resultArray[6] = oracleDbClient6->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);
    resultArray[7] = oracleDbClient7->query(
        `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
    resultArray[8] = oracleDbClient7->query(
        `select count(*) as val from PoolCustomers where registrationID = 2`, Result);

    (int|error)[] returnArray = [];
    int i = 0;
    // Connections will be released here as we fully consume the data in the following conversion function calls
    foreach var x in resultArray {
        returnArray[i] = getReturnValue(x);
        i += 1;
    }

    check oracleDbClient1.close();
    check oracleDbClient2.close();
    check oracleDbClient3.close();
    check oracleDbClient4.close();
    check oracleDbClient5.close();
    check oracleDbClient6.close();
    check oracleDbClient7.close();

    // Since max pool size is 3, the last select function call going through each pool should fail.
    i = 0;
    while(i < 8) {
        if (i != 3) {
            test:assertEquals(returnArray[i], 1);
        }
        i = i + 1;
    }
    validateConnectionTimeoutError(returnArray[3]);
    validateConnectionTimeoutError(returnArray[8]);
}

@test:Config {
  groups: ["pool"]
}
function testLocalSharedConnectionPoolCreateClientAfterShutdown() returns sql:Error? {
  sql:ConnectionPool pool = {maxOpenConnections: 2, minIdleConnections: 2};
  Client oracleDbClient1 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient2 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);

  var dt1 = oracleDbClient1->query(`SELECT count(*) as val from PoolCustomers where registrationID = 1`, Result);
  var dt2 = oracleDbClient2->query(`SELECT count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error result1 = getReturnValue(dt1);
  int|error result2 = getReturnValue(dt2);

  // Since both clients are stopped the pool is supposed to shutdown.
  check oracleDbClient1.close();
  check oracleDbClient2.close();

  // This call should return an error as pool is shutdown
  var dt3 = oracleDbClient1->query(`SELECT count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error result3 = getReturnValue(dt3);

  // Now a new pool should be created
  Client oracleDbClient3 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);

  // This call should be successful
  var dt4 = oracleDbClient3->query(`SELECT count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error result4 = getReturnValue(dt4);

  check oracleDbClient3.close();

  test:assertEquals(result1, 1);
  test:assertEquals(result2, 1);
  validateApplicationError(result3);
  test:assertEquals(result4, 1);
}

@test:Config {
  groups: ["pool"]
}
function testLocalSharedConnectionPoolStopInitInterleave() returns error? {
  sql:ConnectionPool pool = {maxOpenConnections: 2, minIdleConnections: 2};

  worker w1 returns error? {
      check testLocalSharedConnectionPoolStopInitInterleaveHelper1(pool);
  }
  worker w2 returns int|error {
      return testLocalSharedConnectionPoolStopInitInterleaveHelper2(pool);
  }

  check wait w1;
  int|error result = wait w2;
  test:assertEquals(result, 1);
}

function testLocalSharedConnectionPoolStopInitInterleaveHelper1(sql:ConnectionPool pool)
returns error? {
  Client oracleDbClient = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  runtime:sleep(10);
  check oracleDbClient.close();
}

function testLocalSharedConnectionPoolStopInitInterleaveHelper2(sql:ConnectionPool pool)
returns @tainted int|error {
  runtime:sleep(10);
  Client oracleDbClient = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  var dt = oracleDbClient->query(`SELECT COUNT(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error count = getReturnValue(dt);
  check oracleDbClient.close();
  return count;
}

@test:Config {
  groups: ["pool"]
}
function testShutDownUnsharedLocalConnectionPool() returns sql:Error? {
  sql:ConnectionPool pool = {maxOpenConnections: 2, minIdleConnections: 2};
  Client oracleDbClient = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);

  var result = oracleDbClient->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error retVal1 = getReturnValue(result);
  // Pool should be shutdown as the only client using it is stopped.
  check oracleDbClient.close();
  // This should result in an error return.
  var resultAfterPoolShutDown = oracleDbClient->query(
    `select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error retVal2 = getReturnValue(resultAfterPoolShutDown);

  test:assertEquals(retVal1, 1);
  validateApplicationError(retVal2);
}

@test:Config {
  groups: ["pool"]
}
function testShutDownSharedConnectionPool() returns sql:Error? {
  sql:ConnectionPool pool = {maxOpenConnections: 1, minIdleConnections: 1};
  Client oracleDbClient1 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient2 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);

  var result1 = oracleDbClient1->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error retVal1 = getReturnValue(result1);

  var result2 = oracleDbClient2->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal2 = getReturnValue(result2);

  // Only one client is closed so pool should not shutdown.
  check oracleDbClient1.close();

  // This should be successful as pool is still up.
  var result3 = oracleDbClient2->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal3 = getReturnValue(result3);

  // This should fail because, even though the pool is up, this client was stopped
  var result4 = oracleDbClient1->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal4 = getReturnValue(result4);

  // Now pool should be shutdown as the only remaining client is stopped.
  check oracleDbClient2.close();

  // This should fail because this client is stopped.
  var result5 = oracleDbClient2->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal5 = getReturnValue(result4);

  test:assertEquals(retVal1, 1);
  test:assertEquals(retVal2, 1);
  test:assertEquals(retVal3, 1);
  validateApplicationError(retVal4);
  validateApplicationError(retVal5);
}

@test:Config {
  groups: ["pool"]
}
function testShutDownPoolCorrespondingToASharedPoolConfig() returns sql:Error? {
  sql:ConnectionPool pool = {maxOpenConnections: 1, minIdleConnections: 1};
  Client oracleDbClient1 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);
  Client oracleDbClient2 = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options, pool);

  var result1 = oracleDbClient1->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error retVal1 = getReturnValue(result1);

  var result2 = oracleDbClient2->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal2 = getReturnValue(result2);

  // This should result in stopping the pool used by this client as it was the only client using that pool.
  check oracleDbClient1.close();

  // This should be successful as the pool belonging to this client is up.
  var result3 = oracleDbClient2->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal3 = getReturnValue(result3);

  // This should fail because this client was stopped.
  var result4 = oracleDbClient1->query(`select count(*) as val from PoolCustomers where registrationID = 2`, Result);
  int|error retVal4 = getReturnValue(result4);

  check oracleDbClient2.close();

  test:assertEquals(retVal1, 1);
  test:assertEquals(retVal2, 1);
  test:assertEquals(retVal3, 1);
  validateApplicationError(retVal4);
}

@test:Config {
  groups: ["pool"]
}
function testStopClientUsingGlobalPool() returns sql:Error? {
  // This client doesn't have pool config specified therefore, global pool will be used.
  Client oracleDbClient = check new (HOST, USER, PASSWORD, POOLDB, POOLPORT, options);

  var result1 = oracleDbClient->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error retVal1 = getReturnValue(result1);

  // This will merely stop this client and will not have any effect on the pool because it is the global pool.
  check oracleDbClient.close();

  // This should fail because this client was stopped, even though the pool is up.
  var result2 = oracleDbClient->query(`select count(*) as val from PoolCustomers where registrationID = 1`, Result);
  int|error retVal2 = getReturnValue(result2);

  test:assertEquals(retVal1, 1);
  validateApplicationError(retVal2);
}

isolated function getReturnValue(stream<record{}, error?> queryResult) returns int|error {
  int count = -1;
  record {|record {} value;|}? data = check queryResult.next();
  if (data is record {|record {} value;|}) {
      record {} value = data.value;
      if (value is Result) {
          count = value.val;
      }
  }
  check queryResult.close();
  return count;
}

isolated function validateApplicationError(int|error dbError) {
  test:assertTrue(dbError is error);
  sql:ApplicationError sqlError = <sql:ApplicationError> dbError;
  test:assertTrue(stringutils:includes(sqlError.message(), "SQL Client is already closed, hence further " +
  "operations are not allowed"), sqlError.message());
}

isolated function validateConnectionTimeoutError(int|error dbError) {
  test:assertTrue(dbError is error);
  sql:DatabaseError sqlError = <sql:DatabaseError> dbError;
  test:assertTrue(stringutils:includes(sqlError.message(), "request timed out after"), sqlError.message());
}

isolated function dropPoolTableIfExists(string tablename) returns sql:ExecutionResult|sql:Error {
    Client oracledbClient = check new(HOST, USER, PASSWORD, POOLDB, POOLPORT);
    sql:ExecutionResult result = check oracledbClient->execute("BEGIN "+
        "EXECUTE IMMEDIATE 'DROP TABLE ' || '" + tablename + "'; " +
        "EXCEPTION " +
        "WHEN OTHERS THEN " +
            "IF SQLCODE != -942 THEN " +
                "RAISE; " +
            "END IF; " +
        "END;");
    check oracledbClient.close();
    return result;
}
