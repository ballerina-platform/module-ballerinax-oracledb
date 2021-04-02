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

package org.ballerinalang.oracledb.utils;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.oracledb.parameterprocessor.OracleDBResultParameterProcessor;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

/**
 * This class provides functionality to call `sql:RecordIteratorUtils` with a custom `ResultParameterProcessor` object.
 *
 * @since 0.1.0
 */
public class RecordIteratorUtils {

    /**
     * Calls `sql:RecordIteratorUtils` with a custom `ResultParameterProcessor` object.
     * @param customResultIterator module specific resultIterator BObject
     * @param iterator the record that needs to be iterated
     * @return next result of the iterator
     */
    public static Object nextResult(BObject customResultIterator, BObject iterator) {
        DefaultResultParameterProcessor resultParameterProcessor = OracleDBResultParameterProcessor.getInstance();
        return org.ballerinalang.sql.utils.RecordIteratorUtils.nextResult(iterator, resultParameterProcessor);
    }
}
