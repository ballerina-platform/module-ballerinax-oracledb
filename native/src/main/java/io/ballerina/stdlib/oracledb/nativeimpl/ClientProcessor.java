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

 package io.ballerina.stdlib.oracledb.nativeimpl;

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.oracledb.utils.Utils;
import io.ballerina.stdlib.sql.datasource.SQLDatasource;

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
        BString userVal = clientConfig.getStringValue(Constants.ClientConfiguration.USER);
        String user = userVal == null ? null : userVal.getValue();
        BString passwordVal = clientConfig.getStringValue(Constants.ClientConfiguration.PASSWORD);
        String password = passwordVal == null ? null : passwordVal.getValue();
        BMap options = clientConfig.getMapValue(Constants.ClientConfiguration.OPTIONS);
        BMap<BString, Object> datasourceOptions = null;
        Properties poolProperties = null;
        String protocol = Constants.PROTOCOL_TCP;

        if (options != null) {
            datasourceOptions = Utils.generateOptionsMap(options);
            poolProperties = Utils.generatePoolProperties(options);
            if (options.getMapValue(Constants.Options.SSL) != null) {
                protocol = Constants.PROTOCOL_TCPS;
            }
        }
        StringBuilder url = new StringBuilder(Constants.DRIVER);
        url.append("(DESCRIPTION=(ADDRESS=");
        url.append("(PROTOCOL=").append(protocol).append(")");
        url.append("(PORT=").append(port).append(")");
        url.append("(HOST=").append(host).append(")");
        url.append(")");
        url.append("(CONNECT_DATA=(SERVICE_NAME=").append(database).append("))");
        url.append(")");
        BMap connectionPool = clientConfig.getMapValue(Constants.ClientConfiguration.CONNECTION_POOL_OPTIONS);
        String dataSourceName = Constants.ORACLE_DATASOURCE_NAME;
        SQLDatasource.SQLDatasourceParams sqlDatasourceParams = new SQLDatasource.SQLDatasourceParams()
                .setUrl(url.toString())
                .setUser(user)
                .setPassword(password)
                .setDatasourceName(dataSourceName)
                .setOptions(datasourceOptions)
                .setConnectionPool(connectionPool, globalConnPool)
                .setPoolProperties(poolProperties);
        return io.ballerina.stdlib.sql.nativeimpl.ClientProcessor.createClient(client, sqlDatasourceParams);
    }

    public static Object close(BObject client) {
        return io.ballerina.stdlib.sql.nativeimpl.ClientProcessor.close(client);
    }

}
