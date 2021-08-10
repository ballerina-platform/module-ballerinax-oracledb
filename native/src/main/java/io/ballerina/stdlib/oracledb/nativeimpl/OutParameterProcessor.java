/*
 *  Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.stdlib.oracledb.nativeimpl;

import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.oracledb.parameterprocessor.OracleDBResultParameterProcessor;


/**
 * This class provides the implementation of processing InOut/Out parameters of procedure calls.
 *
 * @since 0.1.0
 */
public class OutParameterProcessor {

    private OutParameterProcessor() {}

    public static Object get(BObject result, BTypedesc typeDesc) {
        return io.ballerina.stdlib.sql.nativeimpl.OutParameterProcessor
                .get(result, typeDesc, OracleDBResultParameterProcessor.getInstance());
    }
}
