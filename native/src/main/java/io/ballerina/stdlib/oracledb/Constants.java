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
package io.ballerina.stdlib.oracledb;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * Constants for Oracle database client.
 */
public final class Constants {

    private Constants() {}

    /**
     * Constants for database client properties.
     */
    public static final class ClientConfiguration {

        private ClientConfiguration() {}

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

        private Options () {}

        public static final BString SSL = StringUtils.fromString("ssl");
        public static final BString AUTOCOMMIT = StringUtils.fromString("autoCommit");
        public static final BString LOGIN_TIMEOUT_SECONDS = StringUtils.fromString("loginTimeout");
        public static final BString CONNECT_TIMEOUT_SECONDS = StringUtils.fromString("connectTimeout");
        public static final BString SOCKET_TIMEOUT_SECONDS = StringUtils.fromString("socketTimeout");
    }

    /**
     * Constants for configuring database SSL options.
     */
    public static final class SecureSocket {

        private SecureSocket() {}

        public static final BString KEYSTORE = StringUtils.fromString("key");
        public static final BString TRUSTSTORE = StringUtils.fromString("cert");

        /**
         * Constants for setting crypto keystore.
         */
        public static final class CryptoKeyStoreRecord {

            private CryptoKeyStoreRecord () {}

            public static final BString PATH_FIELD = StringUtils.fromString("path");
            public static final BString PASSWORD_FIELD = StringUtils.fromString("password");
        }

        /**
         * Constants for setting crypto truststore.
         */
        public static final class CryptoTrustStoreRecord {

            private CryptoTrustStoreRecord() {}

            public static final BString PATH_FIELD = StringUtils.fromString("path");
            public static final BString PASSWORD_FIELD = StringUtils.fromString("password");
        }

        /**
         * Constants for available Keystore/ Truststore file types.
         */
        public static final class StoreTypes {

            private StoreTypes() {}

            public static final String JKS = "JKS";
            public static final String PKCS12 = "PKCS12";
            public static final String SSO = "SSO";
        }

        /**
         * Constants for available Keystore/ Truststore extensions.
         */
        public static final class StoreExtensions {

            private StoreExtensions() {}

            public static final String P12 = ".p12";
            public static final String PFX = ".pfx";
            public static final String JKS = ".jks";
            public static final String SSO = ".sso";
        }
    }

    /**
     * Constants for database properties.
     */
    public static final class DatabaseProps {

        private DatabaseProps() {}

        public static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");
        public static final BString CONN_PROPERTIES = StringUtils.fromString("connectionProperties");
    }

    /**
     * Constants for pool properties.
     */
    public static final class Pool {

        private Pool() {}

        public static final BString CONNECT_TIMEOUT = StringUtils.fromString("connectionTimeout");
        public static final BString AUTO_COMMIT = StringUtils.fromString("autoCommit");
    }

    /**
     * Constants related to TypedValue fields.
     */
    public static final class TypedValueFields {

        private TypedValueFields() {}

        public static final BString VALUE = fromString("value");
    }

    /**
     * Constants related to Oracle DB types supported.
     */
    public static final class Types {

        private Types() {}

        public static final String INTERVAL_YEAR_TO_MONTH_RECORD = "IntervalYearToMonth";
        public static final String INTERVAL_DAY_TO_SECOND_RECORD = "IntervalDayToSecond";

        /**
         * Constants related to Oracle Database type names.
         */
        public static final class OracleDbTypes {

            private OracleDbTypes() {}

            public static final String INTERVAL_YEAR_TO_MONTH = "INTERVAL_YEAR_TO_MONTH";
            public static final String INTERVAL_DAY_TO_SECOND = "INTERVAL_DAY_TO_SECOND";
            public static final String OBJECT_TYPE = "OBJECT";
            public static final String VARRAY = "VARRAY";
        }

        /**
         * Constants related to custom ballerina type names.
         */
        public static final class CustomTypes {

            private CustomTypes() {}

            public static final String OBJECT = "ObjectTypeValue";
            public static final String VARRAY = "VarrayValue";
        }

        /**
         * Constants related to OutParameter supported.
         */
        public static final class OutParameterTypes {

            private OutParameterTypes() {}

            public static final String XML = "XmlOutParameter";
            public static final String INTERVAL_YEAR_TO_MONTH = "IntervalYearToMonthOutParameter";
            public static final String INTERVAL_DAY_TO_SECOND = "IntervalDayToSecondOutParameter";
        }

        /**
         * Constants related to the attributes of INTERVAL_YEAR_TO_MONTH Oracle DB type.
         */
        public static final class IntervalYearToMonth {

            private IntervalYearToMonth() {}

            public static final String YEARS = "years";
            public static final String MONTHS = "months";
            public static final String SIGN = "sign";
        }

        /**
         * Constants related to the attributes of INTERVAL_DAY_TO_SECOND Oracle DB type.
         */
        public static final class IntervalDayToSecond {

            private IntervalDayToSecond() {}

            public static final String DAYS = "days";
            public static final String HOURS = "hours";
            public static final String MINUTES = "minutes";
            public static final String SECONDS = "seconds";
            public static final String SIGN = "sign";
        }

        /**
         * Constants related to the attributes of OBJECT Oracle DB type.
         */
        public static final class OracleObject {

            private OracleObject() {}

            public static final String TYPE_NAME = "typename";
            public static final String ATTRIBUTES = "attributes";
        }

        /**
         * Constants related to the attributes of VARRAY Oracle DB type.
         */
        public static final class Varray {

            private Varray() {}

            public static final String NAME = "name";
            public static final String ELEMENTS = "elements";
        }

        /**
         * Constants related to the ballerina array types to which oracle varrays are converted.
         */
        public static final class BallerinaArrayTypes {

            private BallerinaArrayTypes() {}

            public static final String STRING = "string[]";
            public static final String INT = "int[]";
            public static final String FLOAT = "float[]";
            public static final String DECIMAL = "decimal[]";
            public static final String BOOLEAN = "boolean[]";
            public static final String BYTE = "byte[]";
            public static final String ANYDATA = "anydata[]";
        }
    }

    public static final String DRIVER = "jdbc:oracle:thin:@";
    public static final String PROTOCOL_TCP = "TCP";
    public static final String PROTOCOL_TCPS = "TCPS";
    public static final String ORACLE_DATASOURCE_NAME = "oracle.jdbc.pool.OracleDataSource";
    public static final String CUSTOM_RESULT_ITERATOR_OBJECT = "CustomResultIterator";
}
