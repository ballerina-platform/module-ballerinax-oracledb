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
package io.ballerina.stdlib.oracledb.utils;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BValue;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.sql.exception.ApplicationError;
import oracle.jdbc.OracleConnection;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * This class contains utility functions required by the nativeimpl package.
 */
public class Utils {

    /**
     * Generate the map of connection parameter options.
     * @param clientOptions BMap of user provided options
     * @return Structured connection parameter options
     */
    public static BMap<BString, Object> generateOptionsMap(BMap clientOptions) {
        BMap<BString, Object> options = ValueCreator.createMapValue();
        long loginTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.LOGIN_TIMEOUT_SECONDS));
        if (loginTimeout >= 0) {
            options.put(Constants.DatabaseProps.LOGIN_TIMEOUT, loginTimeout);
        }
        Properties connProperties = setConnectionProperties(clientOptions);
        if (connProperties.size() > 0) {
            options.put(Constants.DatabaseProps.CONN_PROPERTIES, connProperties);
        }
        return options;
    }

    private static long getTimeoutInMilliSeconds(Object secondsDecimal) {
        if (secondsDecimal instanceof BDecimal) {
            BDecimal timeoutSec = (BDecimal) secondsDecimal;
            if (timeoutSec.floatValue() >= 0) {
                return Double.valueOf(timeoutSec.floatValue() * 1000).longValue();
            }
        }
        return -1;
    }

    private static Properties setConnectionProperties(BMap clientOptions) {
        Properties connProperties = new Properties();
        long connectTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.CONNECT_TIMEOUT_SECONDS));
        if (connectTimeout >= 0) {
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_NET_CONNECT_TIMEOUT,
                    String.valueOf(connectTimeout));
        }
        long socketTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.SOCKET_TIMEOUT_SECONDS));
        if (socketTimeout >= 0) {
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_READ_TIMEOUT, String.valueOf(socketTimeout));
        }
        Boolean autocommit = clientOptions.getBooleanValue(Constants.Options.AUTOCOMMIT);
        if (autocommit != null) {
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_AUTOCOMMIT, String.valueOf(autocommit));
        }
        BMap secureSocket = clientOptions.getMapValue(Constants.Options.SSL);
        if (secureSocket != null) {
            setSSLConProperties(secureSocket, connProperties);
        }
        return connProperties;
    }

    /**
     * Generate a Properties object of pool properties.
     * @param clientOptions pool options provided by the user
     * @return Properties object of pool properties
     */
    public static Properties generatePoolProperties(BMap clientOptions) {
        Properties poolProperties = new Properties();
        long connectTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.CONNECT_TIMEOUT_SECONDS));
        if (connectTimeout > 0) {
            poolProperties.put(Constants.Pool.CONNECT_TIMEOUT, connectTimeout);
        }
        Boolean autocommit = clientOptions.getBooleanValue(Constants.Options.AUTOCOMMIT);
        if (autocommit != null) {
            poolProperties.put(Constants.Pool.AUTO_COMMIT, autocommit);
        }
        if (poolProperties.size() > 0) {
            return poolProperties;
        }
        return null;
    }

    private static void setSSLConProperties(BMap secureSocket, Properties connProperties) {
        BMap keyStore = secureSocket.getMapValue(Constants.SecureSocket.KEYSTORE);
        if (keyStore != null) {
            String keyStorePath = keyStore.getStringValue(
                    Constants.SecureSocket.CryptoKeyStoreRecord.PATH_FIELD).getValue();
            String keyStorePassword = keyStore.getStringValue(
                    Constants.SecureSocket.CryptoKeyStoreRecord.PASSWORD_FIELD).getValue();
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_JAVAX_NET_SSL_KEYSTORE, keyStorePath);
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_JAVAX_NET_SSL_KEYSTOREPASSWORD,
                    keyStorePassword);
            String keyStoreType = setSSLStoreType(keyStorePath);
            if (keyStoreType != null) {
                connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_JAVAX_NET_SSL_KEYSTORETYPE, keyStoreType);
            }
        }
        BMap trustStore = secureSocket.getMapValue(Constants.SecureSocket.TRUSTSTORE);
        if (trustStore != null) {
            String trustStorePath = trustStore.getStringValue(
                    Constants.SecureSocket.CryptoTrustStoreRecord.PATH_FIELD).getValue();
            String trustStorePassword = trustStore.getStringValue(
                    Constants.SecureSocket.CryptoTrustStoreRecord.PASSWORD_FIELD).getValue();
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_JAVAX_NET_SSL_TRUSTSTORE, trustStorePath);
            connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_JAVAX_NET_SSL_TRUSTSTOREPASSWORD,
                    trustStorePassword);
            String trustStoreType = setSSLStoreType(trustStorePath);
            if (trustStoreType != null) {
                connProperties.put(OracleConnection.CONNECTION_PROPERTY_THIN_JAVAX_NET_SSL_KEYSTORETYPE,
                        trustStoreType);
            }
        }
    }

    private static String setSSLStoreType(String storePath) {
        String storeType = null;
        if (storePath.endsWith(Constants.SecureSocket.StoreExtensions.P12) ||
                storePath.endsWith(Constants.SecureSocket.StoreExtensions.PFX)) {
            storeType = Constants.SecureSocket.StoreTypes.PKCS12;
        } else if (storePath.endsWith(Constants.SecureSocket.StoreExtensions.JKS)) {
            storeType = Constants.SecureSocket.StoreTypes.JKS;
        } else if (storePath.endsWith(Constants.SecureSocket.StoreExtensions.SSO)) {
            storeType = Constants.SecureSocket.StoreTypes.SSO;
        }
        return storeType;
    }

    /**
     * Throw an error if the sql type of the provided value is invalid.
     * @param value The parameter of invalid type
     * @param sqlType The SQL type of the parameter
     * @return sql:ApplicationError
     */
    public static ApplicationError throwInvalidParameterError(Object value, String sqlType) {
        String valueName;
        if (value == null) {
            valueName = "null";
        } else if (value instanceof BValue) {
            valueName = ((BValue) value).getType().getName();
        } else {
            valueName = value.getClass().getName();
        }
        return new ApplicationError("Invalid parameter: " + valueName + " is passed as value for SQL type: " + sqlType);
    }

    /**
     * Return an OracleConnection instance from Hikari connection.
     * @param connection Hikari connection
     * @return OracleConnection instance
     * @throws SQLException if hikari connection is not a wrapper of Oracle connection
     */
    public static OracleConnection getOracleConnection(Connection connection) throws SQLException {
        if (connection.isWrapperFor(OracleConnection.class)) {
            return connection.unwrap(OracleConnection.class);
        }
        throw new SQLException("Cannot cast connection to Oracle connection");
    }
}
