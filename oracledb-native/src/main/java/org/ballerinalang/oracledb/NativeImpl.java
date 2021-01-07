/*
 *  Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package org.ballerinalang.oracledb;

import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.sql.datasource.SQLDatasource;
import org.ballerinalang.sql.utils.ClientUtils;

import java.io.Console;
import java.util.Properties;

/**
 * Native Implementation of Client Initialization.
 */
public class NativeImpl {

    public static Object createClient(
            BObject client, BMap<BString, Object> clientConfig, BMap<BString, Object> globalConnPool
    ) {

        String host = clientConfig.getStringValue(Constants.ClientConfiguration.HOST).getValue();
        int port = clientConfig.getIntValue(Constants.ClientConfiguration.PORT).intValue();
        String database = clientConfig.getStringValue(Constants.ClientConfiguration.DATABASE).getValue();

        String url = Constants.DRIVER + host + ":" + Integer.toString(port) + "/" + database;

        String user = clientConfig.getStringValue(Constants.ClientConfiguration.USER).getValue();
        String password = clientConfig.getStringValue(Constants.ClientConfiguration.PASSWORD).getValue();

        BMap options = clientConfig.getMapValue(
            Constants.ClientConfiguration.OPTIONS);
        BMap<BString, Object> datasourceOptions = null;
        Properties poolProperties = null;

        if (options != null) {
            datasourceOptions = Utils.generateOptionsMap(options);
            poolProperties = Utils.generatePoolProperties(options);
        }

        BMap connectionPool = clientConfig.getMapValue(Constants.ClientConfiguration.CONNECTION_POOL_OPTIONS);

        String dataSourceName = Constants.ORACLE_DATASOURCE_NAME;

        SQLDatasource.SQLDatasourceParams sqlDatasourceParams = new SQLDatasource.SQLDatasourceParams()
                .setUrl(url)
                .setUser(user)
                .setPassword(password)
                .setDatasourceName(dataSourceName)
                .setOptions(datasourceOptions)
                .setConnectionPool(connectionPool, globalConnPool)
                .setPoolProperties(poolProperties);

        return ClientUtils.createClient(client, sqlDatasourceParams);
    }

    public static Object close(BObject client) {
        return ClientUtils.close(client);
    }
}
