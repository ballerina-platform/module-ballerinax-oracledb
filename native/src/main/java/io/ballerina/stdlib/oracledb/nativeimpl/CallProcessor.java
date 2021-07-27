/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.oracledb.nativeimpl;

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.oracledb.parameterprocessor.OracleDBResultParameterProcessor;
import io.ballerina.stdlib.oracledb.parameterprocessor.OracleDBStatementParameterProcessor;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultResultParameterProcessor;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultStatementParameterProcessor;

/**
 * This class holds the methods required to execute call statements.
 *
 * @since 0.1.0
 */
public class CallProcessor {

    private CallProcessor() {}

    /**
     * Execute a call query and return the results.
     * @param client Client BObject
     * @param paramSQLString SQL string for the call statement
     * @param recordTypes type description of the result record
     * @return procedure call result or error
     */
    public static Object nativeCall(BObject client, Object paramSQLString, BArray recordTypes) {
        DefaultStatementParameterProcessor statementParametersProcessor = OracleDBStatementParameterProcessor
                .getInstance();
        DefaultResultParameterProcessor resultParametersProcessor = OracleDBResultParameterProcessor
                .getInstance();
        return io.ballerina.stdlib.sql.nativeimpl.CallProcessor.nativeCall(client, paramSQLString,
            recordTypes, statementParametersProcessor, resultParametersProcessor);
    }
}
