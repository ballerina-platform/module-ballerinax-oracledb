/*
 * Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
final class Constants {
    static final class ClientConfiguration {
        static final BString HOST = StringUtils.fromString("host");
        static final BString PORT = StringUtils.fromString("port");
        static final BString USER = StringUtils.fromString("user");
        static final BString PASSWORD = StringUtils.fromString("password");
        static final BString OPTIONS = StringUtils.fromString("options");
        static final BString CONNECTION_POOL_OPTIONS = StringUtils.fromString("connectionPool");
    }

    static final class Options {
        static final BString SSL = StringUtils.fromString("ssl");
        static final BString AUTOCOMMIT = StringUtils.fromString("autoCommit");
        static final BString LOGIN_TIMEOUT_SECONDS = StringUtils.fromString("loginTimeoutInSeconds");
        static final BString CONNECT_TIMEOUT_SECONDS = StringUtils.fromString("connectTimeoutInSeconds");
        static final BString SOCKET_TIMEOUT_SECONDS = StringUtils.fromString("socketTimeoutInSeconds");
    }

    static final class DatabaseProps {
        static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");
        static final BString SET_CONN_PROPERTIES = StringUtils.fromString("setConnectionProperties");

        static final class ConnProperties {
            static final BString CONNECT_TIMEOUT = StringUtils.fromString("oracle.net.CONNECT_TIMEOUT");
            static final BString SOCKET_TIMEOUT = StringUtils.fromString("oracle.jdbc.ReadTimeout");
            static final BString AUTO_COMMIT = StringUtils.fromString("autoCommit");
            static final BString KEYSTORE = StringUtils.fromString("javax.net.ssl.keyStore");
            static final BString KEYSTORE_PASSWORD = StringUtils.fromString("javax.net.ssl.keyStorePassword");
            static final BString KEYSTORE_TYPE = StringUtils.fromString("javax.net.ssl.keyStoreType");
            static final BString TRUSTSTORE = StringUtils.fromString("javax.net.ssl.trustStore");
            static final BString TRUSTSTORE_PASSWORD = StringUtils.fromString("javax.net.ssl.trustStorePassword");
            static final BString TRUSTSTORE_TYPE = StringUtils.fromString("javax.net.ssl.trustStoreType");
        }

    }

    static final class Pool {
        static final BString CONNECT_TIMEOUT = StringUtils.fromString("connectionTimeout");
        static final BString AUTO_COMMIT = StringUtils.fromString("autoCommit");

    }

    static final String DRIVER = "jdbc:oracle:thin:@//";
    static final String ORACLE_DATASOURCE_NAME = "oracle.jdbc.pool.OracleDataSource";
}
