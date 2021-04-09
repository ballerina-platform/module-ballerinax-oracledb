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

package org.ballerinalang.oracledb.parameterprocessor;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.oracledb.Constants;
import org.ballerinalang.oracledb.utils.ModuleUtils;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

/**
 * This class overrides DefaultResultParameterProcessor to implement methods required convert SQL types into
 * ballerina types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class OracleDBResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final OracleDBResultParameterProcessor instance = new OracleDBResultParameterProcessor();
    private static final BObject iterator = ValueCreator.createObjectValue(
            ModuleUtils.getModule(), Constants.CUSTOM_RESULT_ITERATOR_OBJECT, new Object[0]);

    /**
     * Singleton static method that returns an instance of `OracleDBResultParameterProcessor`.
     * @return OracleDBResultParameterProcessor
     */
    public static OracleDBResultParameterProcessor getInstance() {
        return instance;
    }

    @Override
    protected BObject getIteratorObject() {
        return iterator;
    }
}
