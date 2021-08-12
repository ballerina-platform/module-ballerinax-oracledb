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


package io.ballerina.stdlib.oracledb.tests.parameterprocessor;

import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.oracledb.parameterprocessor.OracleDBStatementParameterProcessor;
import io.ballerina.stdlib.oracledb.tests.TestUtils;
import io.ballerina.stdlib.sql.Constants;
import io.ballerina.stdlib.sql.exception.ApplicationError;
import org.junit.jupiter.api.Test;

import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * OracleDBStatementParameterProcessor class test.
 *
 * @since 0.1.0-beta.3
 */
public class OracleDBStatementParameterProcessorTest {

    static class NullAndErrorCheckClass extends OracleDBStatementParameterProcessor {
        protected void testSetCustomSqlTypedParam(BObject object) throws SQLException, ApplicationError {
            setCustomSqlTypedParam(null, null, 0, object);
        }
    }

    @Test
    void createUserDefinedTypeTestNull() {
        NullAndErrorCheckClass testClass = new NullAndErrorCheckClass();
        BObject object = TestUtils.getMockObject("INTEGER");
        object.addNativeData(Constants.ParameterObject.SQL_TYPE_NATIVE_DATA, 4);
        try {
            testClass.testSetCustomSqlTypedParam(object);
        } catch (ApplicationError | SQLException e) {
            assertEquals(e.getMessage(), "Invalid parameter: null is passed as value for SQL type: INTEGER");
        }

    }

}
