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

 package org.ballerinalang.oracledb.nativeimpl;

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.oracledb.Constants;
import org.ballerinalang.oracledb.utils.Utils;
import org.ballerinalang.sql.datasource.SQLDatasource;

import java.util.Properties;

/**
 * This class contains the methods required for the oracledb clients.
 *
 * @since 0.1.0
 */
public class ClientProcessor {

    private ClientProcessor() {}

    /**
     * Create the database client.
     * @param client ballerina client instance
     * @param clientConfig connection configurations from client
     * @param globalConnPool global connection pool
     * @return connection errors if there is any
     */
    public static Object createClient(
            BObject client, BMap<BString, Object> clientConfig, BMap<BString, Object> globalConnPool) {

        String host = clientConfig.getStringValue(Constants.ClientConfiguration.HOST).getValue();
        int port = clientConfig.getIntValue(Constants.ClientConfiguration.PORT).intValue();
        BString databaseVal = clientConfig.getStringValue(Constants.ClientConfiguration.DATABASE);
        String database = databaseVal == null ? null : databaseVal.getValue();
        String url = Constants.DRIVER + host + ":" + Integer.toString(port) + "/" + database;
        BString userVal = clientConfig.getStringValue(Constants.ClientConfiguration.USER);
        String user = userVal == null ? null : userVal.getValue();
        BString passwordVal = clientConfig.getStringValue(Constants.ClientConfiguration.PASSWORD);
        String password = passwordVal == null ? null : passwordVal.getValue();
        BMap options = clientConfig.getMapValue(Constants.ClientConfiguration.OPTIONS);
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
        return org.ballerinalang.sql.nativeimpl.ClientProcessor.createClient(client, sqlDatasourceParams);
    }

    public static Object close(BObject client) {
        return org.ballerinalang.sql.nativeimpl.ClientProcessor.close(client);
    }

}
