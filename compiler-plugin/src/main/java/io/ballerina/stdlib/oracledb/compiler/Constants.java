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
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.stdlib.oracledb.compiler;

/**
 * Constants for OracleDB compiler plugin.
 */
public class Constants {
    public static final String BALLERINAX = "ballerinax";
    public static final String ORACLEDB = "oracledb";
    public static final String CONNECTION_POOL_PARAM_NAME = "connectionPool";
    public static final String OPTIONS_PARAM_NAME = "options";
    public static final String OUT_PARAMETER_POSTFIX = "OutParameter";

    private Constants() {
    }

    /**
     * Constants related to Client object.
     */
    public static class Client {
        public static final String NAME = "Client";

        private Client() {
        }
    }

    /**
     * Constants for fields in sql:ConnectionPool.
     */
    public static class ConnectionPool {
        public static final String MAX_OPEN_CONNECTIONS = "maxOpenConnections";
        public static final String MAX_CONNECTION_LIFE_TIME = "maxConnectionLifeTime";
        public static final String MIN_IDLE_CONNECTIONS = "minIdleConnections";

        private ConnectionPool() {
        }
    }

    /**
     * Constants for fields in oracledb:Options.
     */
    public static class Options {
        public static final String NAME = "Options";
        public static final String CONNECT_TIMEOUT = "connectTimeout";
        public static final String SOCKET_TIMEOUT = "socketTimeout";
        public static final String LOGIN_TIMEOUT = "loginTimeout";

        private Options() {
        }
    }

    /**
     * Constants for fields in OutParameter objects.
     */
    public static class OutParameter {
        public static final String METHOD_NAME = "get";
        public static final String XML = "XmlOutParameter";
        public static final String INTERVAL_YEAR_TO_MONTH = "IntervalYearToMonthOutParameter";
        public static final String INTERVAL_DAY_TO_SECOND = "IntervalDayToSecondOutParameter";

        private OutParameter() {
        }
    }


    public static final String UNNECESSARY_CHARS_REGEX = "\"|\\n";

}
