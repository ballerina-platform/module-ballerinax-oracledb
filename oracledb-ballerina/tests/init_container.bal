// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.


import ballerina/os;
import ballerina/test;
import ballerina/file;
import ballerina/lang.runtime as runtime;

string resourcePath = check file:getAbsolutePath("tests/resources");

// string host = "localhost";
// string user = "sysdba";
// string password = "Oradoc_db1";
// int port = 1521;

@test:BeforeSuite
function beforeSuite() {

    // login to registory
    os:Process process = checkpanic os:exec("docker", {}, resourcePath, "login", "container-registry.oracle.com");
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker login failed!");
    
    // run the dockerfile to create custom docker image
    process = checkpanic os:exec("docker", {}, resourcePath, "build", "-t", "ballerina-oracledb", ".");
    exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker image 'ballerina-oracledb' creation failed!");
    
    // build the docker container
    // docker run  -d -it --name oracle -p1521:1521 -v oracledata:/ORCL store/oracle/database-enterprise:12.2.0.1
    process = checkpanic os:exec("docker", {}, resourcePath, 
                    "run", "--rm", "-d", "--name", "ballerina-oracledb", "-p", "1522:1521", "-t", "ballerina-oracledb");
    exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker container 'ballerina-oracledb' creation failed!");
    runtime:sleep(50000);

    // mount the database
    string command = "'source /home/oracle/.bashrc; sqlplus /nolog' && 'connect sys as sysdba;' && 'alter session set \"_ORACLE_SCRIPT\"=true;' && 'create user admin identified by password;' && 'GRANT CONNECT, RESOURCE, DBA TO admin/password;'";
    process = checkpanic os:exec("docker", {}, resourcePath, "exec", "-it", "ballerina-oracledb", "bash", "-c", command);
    exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Oracle database mounting to the container 'ballerina-oracledb' failed!");
    runtime:sleep(50000);

    

    // check status of the docker container
    // int healthCheck = 1;
    // int counter = 0;
    // while(healthCheck > 0 && counter < 12) {
    //     runtime:sleep(10000);
    //     process = checkpanic os:exec("docker", {}, resourcePath, 
    //                 "exec", "ballerina-oracledb", "mysqladmin", "ping", "-hlocalhost", "-uroot", "-pTest123#", "--silent");
    //     healthCheck = checkpanic process.waitForExit();
    //     counter = counter + 1;
    // }
    // test:assertExactEquals(healthCheck, 0, "Docker container 'ballerina-oracledb' health test exceeded timeout!");    
    // io:println("Docker container started.");
}

@test:AfterSuite {}
function afterSuite() {
    os:Process process = checkpanic os:exec("docker", {}, resourcePath, "stop", "ballerina-oracledb");
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker container 'ballerina-oracledb' stop failed!");
}
