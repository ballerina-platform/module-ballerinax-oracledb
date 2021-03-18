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
package org.ballerinalang.oracledb.utils;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.oracledb.Constants;

import java.util.Properties;

/**
 * This class contains utility functions required by the nativeimpl package.
 */
public class Utils {

    /**
     * Generates the map of connection parameter options.
     * @param clientOptions BMap of user provided options
     * @return Structured connection parameter options
     */
    public static BMap<BString, Object> generateOptionsMap(BMap clientOptions) {
        BMap<BString, Object> options = ValueCreator.createMapValue();

        long loginTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.LOGIN_TIMEOUT_SECONDS));
        if (loginTimeout > 0) {
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
            if (timeoutSec.floatValue() > 0) {
                return Double.valueOf(timeoutSec.floatValue() * 1000).longValue();
            }
        }
        return -1;
    }

    private static Properties setConnectionProperties(BMap clientOptions) {
        Properties connProperties = new Properties();

        long connectTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.CONNECT_TIMEOUT_SECONDS));
        if (connectTimeout > 0) {
            connProperties.put(Constants.DatabaseProps.ConnProperties.CONNECT_TIMEOUT, connectTimeout);
        }

        long socketTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.SOCKET_TIMEOUT_SECONDS));
        if (socketTimeout > 0) {
            connProperties.put(Constants.DatabaseProps.ConnProperties.SOCKET_TIMEOUT, socketTimeout);
        }

        Boolean autocommit = clientOptions.getBooleanValue(Constants.Options.AUTOCOMMIT);
        if (autocommit != null) {
            connProperties.put(Constants.DatabaseProps.ConnProperties.AUTO_COMMIT, autocommit);
        }

        setSSLConProperties(clientOptions, connProperties);
        return connProperties;
    }

    /**
     * Generates a Properties object of pool properties.
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
            return null;
        }
        return poolProperties;
    }

    private static void setSSLConProperties(BMap sslConfig, Properties connProperties) {
        if (sslConfig != null) {

            BMap keyStore = sslConfig.getMapValue(Constants.SSLConfig.KEYSTORE);
            if (keyStore != null) {
                connProperties.put(Constants.DatabaseProps.ConnProperties.KEYSTORE, keyStore
                        .getStringValue(Constants.SSLConfig.CryptoKeyStoreRecord.PATH_FIELD));
                connProperties.put(Constants.DatabaseProps.ConnProperties.KEYSTORE_PASSWORD, keyStore
                        .getStringValue(Constants.SSLConfig.CryptoKeyStoreRecord.PASSWORD_FIELD));
            }

            BString keyStoreType = sslConfig.getStringValue(Constants.SSLConfig.KEYSTORE_TYPE);
            if (keyStoreType != null) {
                connProperties.put(Constants.DatabaseProps.ConnProperties.KEYSTORE_TYPE, keyStoreType.getValue());
            }

            BMap trustStore = sslConfig.getMapValue(Constants.SSLConfig.TRUSTSTORE);
            if (trustStore != null) {
                connProperties.put(Constants.DatabaseProps.ConnProperties.TRUSTSTORE, trustStore
                        .getStringValue(Constants.SSLConfig.CryptoTrustStoreRecord.PATH_FIELD));
                connProperties.put(Constants.DatabaseProps.ConnProperties.TRUSTSTORE_PASSWORD, trustStore
                        .getStringValue(Constants.SSLConfig.CryptoTrustStoreRecord.PASSWORD_FIELD));
            }

            BString trustStoreType = sslConfig.getStringValue(Constants.SSLConfig.TRUSTSTORE_TYPE);
            if (trustStoreType != null) {
                connProperties.put(Constants.DatabaseProps.ConnProperties.TRUSTSTORE_TYPE, trustStoreType.getValue());
            }
        }
    }

}

