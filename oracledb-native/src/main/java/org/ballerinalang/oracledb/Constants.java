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
package org.ballerinalang.oracledb;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants for oracle database client.
 */
public final class Constants {

    /**
     * Constants for database client properties.
     */
    public static final class ClientConfiguration {
        public static final BString HOST = StringUtils.fromString("host");
        public static final BString PORT = StringUtils.fromString("port");
        public static final BString USER = StringUtils.fromString("user");
        public static final BString PASSWORD = StringUtils.fromString("password");
        public static final BString DATABASE = StringUtils.fromString("database");
        public static final BString OPTIONS = StringUtils.fromString("options");
        public static final BString CONNECTION_POOL_OPTIONS = StringUtils.fromString("connectionPool"); 
    }

    /**
     * Constants for database client options.
     */
    public static final class Options {
        public static final BString SSL = StringUtils.fromString("ssl");
        public static final BString AUTOCOMMIT = StringUtils.fromString("autoCommit");
        public static final BString LOGIN_TIMEOUT_SECONDS = StringUtils.fromString("loginTimeoutInSeconds");
        public static final BString CONNECT_TIMEOUT_SECONDS = StringUtils.fromString("connectTimeoutInSeconds");
        public static final BString SOCKET_TIMEOUT_SECONDS = StringUtils.fromString("socketTimeoutInSeconds");
    }

    static final class SSLConfig {
        static final BString KEYSTORE = StringUtils.fromString("keyStore");
        static final BString TRUSTSTORE = StringUtils.fromString("trustStore");
        static final BString KEYSTORE_TYPE = StringUtils.fromString("keyStoreType");
        static final BString TRUSTSTORE_TYPE = StringUtils.fromString("trustStoreType");

        static final class CryptoKeyStoreRecord {
            static final BString PATH_FIELD = StringUtils.fromString("path");
            static final BString PASSWORD_FIELD = StringUtils.fromString("password");
        }

        static final class CryptoTrustStoreRecord {
            static final BString PATH_FIELD = StringUtils.fromString("path");
            static final BString PASSWORD_FIELD = StringUtils.fromString("password");
        }
    }

    /**
     * Constants for database properties.
     */
    public static final class DatabaseProps {
        public static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");
        // public static final BString SET_CONN_PROPERTIES = StringUtils.fromString("setConnectionProperties");
        static final BString CONN_PROPERTIES = StringUtils.fromString("connectionProperties");

        /**
         * Constants for oracle driver properties.
         */
        public static final class ConnProperties {
            public static final BString CONNECT_TIMEOUT = StringUtils.fromString("oracle.net.CONNECT_TIMEOUT");
            public static final BString SOCKET_TIMEOUT = StringUtils.fromString("oracle.jdbc.ReadTimeout");
            public static final BString AUTO_COMMIT = StringUtils.fromString("autoCommit");
            public static final BString KEYSTORE = StringUtils.fromString("javax.net.ssl.keyStore");
            public static final BString KEYSTORE_PASSWORD = StringUtils.fromString("javax.net.ssl.keyStorePassword");
            public static final BString KEYSTORE_TYPE = StringUtils.fromString("javax.net.ssl.keyStoreType");
            public static final BString TRUSTSTORE = StringUtils.fromString("javax.net.ssl.trustStore");
            public static final BString TRUSTSTORE_PASSWORD =
                    StringUtils.fromString("javax.net.ssl.trustStorePassword");
            public static final BString TRUSTSTORE_TYPE = StringUtils.fromString("javax.net.ssl.trustStoreType");
        }

    }

    /**
     * Constants for pool properties.
     */
    public static final class Pool {
        public static final BString CONNECT_TIMEOUT = StringUtils.fromString("connectionTimeout");
        public static final BString AUTO_COMMIT = StringUtils.fromString("autoCommit");

    }

    public static final String DRIVER = "jdbc:oracle:thin:@//";
    public static final String ORACLE_DATASOURCE_NAME = "oracle.jdbc.pool.OracleDataSource";
}

