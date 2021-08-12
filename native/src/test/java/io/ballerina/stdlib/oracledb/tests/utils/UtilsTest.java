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

package io.ballerina.stdlib.oracledb.tests.utils;

import io.ballerina.stdlib.oracledb.tests.TestUtils;
import io.ballerina.stdlib.oracledb.utils.Utils;
import io.ballerina.stdlib.sql.exception.ApplicationError;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Utils class test.
 *
 * @since 0.1.0-beta.3
 */
public class UtilsTest {

    @Test
    void throwInvalidParameterErrorBValueTest() {
        ApplicationError error = Utils.throwInvalidParameterError(TestUtils.getMockBValueJson(), "JSON");
        assertEquals(error.getMessage(), "Invalid parameter: json is passed as value for SQL type: JSON");
    }

    @Test
    void throwInvalidParameterErrorObjectTest() {
        ApplicationError error = Utils.throwInvalidParameterError(new Object(), "JSON");
        assertEquals(error.getMessage(), "Invalid parameter: java.lang.Object is passed as value for SQL type: JSON");
    }
}
