package org.ballerinalang.oracledb;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Properties;

class Utils {
    static BMap<BString, Object> generateOptionsMap(BMap clientOptions) {
        BMap<BString, Object> options = ValueCreator.createMapValue();

        long loginTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.LOGIN_TIMEOUT_SECONDS));
        if (loginTimeout > 0) {
            options.put(Constants.DatabaseProps.LOGIN_TIMEOUT, loginTimeout);
        }

        Properties connProperties = setConnectionProperties(clientOptions);
        if (connProperties.size() > 0) {
            options.put(Constants.DatabaseProps.SET_CONN_PROPERTIES, connProperties);
        }

        return options;
    }

    static long getTimeoutInMilliSeconds(Object secondsDecimal) {
        if (secondsDecimal instanceof BDecimal) {
            BDecimal timeoutSec = (BDecimal) secondsDecimal;
            if (timeoutSec.floatValue() > 0) {
                return Double.valueOf(timeoutSec.floatValue() * 1000).longValue();
            }
        }
        return -1;
    }

    static Properties setConnectionProperties(BMap clientOptions) {
        // TODO: add SSL properties
        Properties connProperties = new Properties();

        long connectTimeout = getTimeoutInMilliSeconds(clientOptions.get(Constants.Options.LOGIN_TIMEOUT_SECONDS));
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

        return connProperties;
    }

    static Properties generatePoolProperties(BMap clientOptions) {
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
}
