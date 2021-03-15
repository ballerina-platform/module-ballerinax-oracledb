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

import java.sql.Struct;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

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
        public static final BString LOGIN_TIMEOUT_SECONDS = StringUtils.fromString("loginTimeout");
        public static final BString CONNECT_TIMEOUT_SECONDS = StringUtils.fromString("connectTimeout");
        public static final BString SOCKET_TIMEOUT_SECONDS = StringUtils.fromString("socketTimeout");
    }

    /**
     * Constants for configuring database SSL options.
     */
    public static final class SSLConfig {
        public static final BString KEYSTORE = StringUtils.fromString("keyStore");
        public static final BString TRUSTSTORE = StringUtils.fromString("trustStore");
        public static final BString KEYSTORE_TYPE = StringUtils.fromString("keyStoreType");
        public static final BString TRUSTSTORE_TYPE = StringUtils.fromString("trustStoreType");

        /**
         * Constants for setting crypto keystore.
         */
        public static final class CryptoKeyStoreRecord {
            public static final BString PATH_FIELD = StringUtils.fromString("path");
            public static final BString PASSWORD_FIELD = StringUtils.fromString("password");
        }

        /**
         * Constants for setting crypto truststore.
         */
        public static final class CryptoTrustStoreRecord {
            public static final BString PATH_FIELD = StringUtils.fromString("path");
            public static final BString PASSWORD_FIELD = StringUtils.fromString("password");
        }
    }

    /**
     * Constants for database properties.
     */
    public static final class DatabaseProps {
        public static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");
        // public static final BString SET_CONN_PROPERTIES = StringUtils.fromString("setConnectionProperties");
        public static final BString CONN_PROPERTIES = StringUtils.fromString("connectionProperties");

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

    /**
     * Constants related to TypedValue fields.
     */
    public static final class TypedValueFields {
        public static final BString VALUE = fromString("value");
    }

    /**
     * Constants related to Oracle DB types supported.
     */
    public static final class Types {

        /**
         * Constants related to Oracle Database type names.
         */
        public static final class OracleDbTypes {
            public static final String INTERVAL_YEAR_TO_MONTH = "INTERVAL_YEAR_TO_MONTH";
            public static final String INTERVAL_DAY_TO_SECOND = "INTERVAL_DAY_TO_SECOND";
            public static final String BFILE = "BFILE";
        }

        /**
         * Constants related to custom ballerina type names.
         */
        public static final class CustomTypes {
            public static final String INTERVAL_YEAR_TO_MONTH = "IntervalYearToMonthValue";
            public static final String INTERVAL_DAY_TO_SECOND = "IntervalDayToSecondValue";
            public static final String BFILE = "BfileValue";
            public static final String OBJECT = "ObjectValue";
            public static final String VARRAY = "VarrayValue";
            public static final String NESTED_TABLE = "CustomTableValue";
        }

        /**
         * Constants related to ballerina type names.
         */
        public static final class BallerinaTypes {
            public static final String STRING = "string";
        }

        /**
         * Constants related to the attributes of INTERVAL_YEAR_TO_MONTH Oracle DB type.
         */
        public static final class IntervalYearToMonth {
            public static final String YEAR = "year";
            public static final String MONTH = "month";

        }

        /**
         * Constants related to the attributes of INTERVAL_DAY_TO_SECOND Oracle DB type.
         */
        public static final class IntervalDayToSecond {
            public static final String DAY = "day";
            public static final String HOUR = "hour";
            public static final String MINUTE = "minute";
            public static final String SECOND = "second";
        }

        /**
         * Constants related to the attributes of BFILE Oracle DB type.
         */
        public static final class Bfile {
            public static final String DIRECTORY = "directory";
            public static final String FILE = "file";
        }

        /**
         * Constants related to the attributes of OBJECT Oracle DB type.
         */
        public static final class OracleObject {
            public static final String TYPE_NAME = "typeName";
            public static final String ATTRIBUTES = "attributes";
        }

        /**
         * Constants related to the attributes of OBJECT Oracle DB type.
         */
        public static final class OracleObject {
            public static final String TYPE_NAME = "typeName";
            public static final String ATTRIBUTES = "attributes";
        }

        /**
         *
         */
        public static final class Varray {
            public static final String NAME = "name";
            public static final String ELEMENTS = "elements";
        }


    }

    public static final String DRIVER = "jdbc:oracle:thin:@//";
    public static final String ORACLE_DATASOURCE_NAME = "oracle.jdbc.pool.OracleDataSource";
}

