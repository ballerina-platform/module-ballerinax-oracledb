/*
 *  Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package io.ballerina.stdlib.oracledb.parameterprocessor;

import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BXml;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.oracledb.utils.ConverterUtils;
import io.ballerina.stdlib.oracledb.utils.Utils;
import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultStatementParameterProcessor;
import oracle.jdbc.OracleTypes;

import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLXML;
import java.sql.Struct;
import java.sql.Types;

/**
 * This class overrides DefaultStatementParameterProcessor to implement methods required to convert ballerina types
 * into SQL types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class OracleDBStatementParameterProcessor extends DefaultStatementParameterProcessor {
    private static final OracleDBStatementParameterProcessor instance = new OracleDBStatementParameterProcessor();

    /**
     * Singleton static method that returns an instance of `OracleDBStatementParameterProcessor`.
     * @return OracleDBStatementParameterProcessor
     */
    public static OracleDBStatementParameterProcessor getInstance() {
        return instance;
    }

    @Override
    protected void setCustomSqlTypedParam(Connection connection, PreparedStatement preparedStatement, int index,
        BObject typedValue) throws SQLException, DataError {
        String sqlType = typedValue.getType().getName();
        Object value = typedValue.get(Constants.TypedValueFields.VALUE);
        switch (sqlType) {
            case Constants.Types.CustomTypes.OBJECT:
                setOracleObject(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.VARRAY:
                setVarray(connection, preparedStatement, index, value);
                break;
            default:
                throw Utils.throwInvalidParameterError(value, sqlType);
        }
    }

    @Override
    public int getCustomOutParameterType(BObject typedValue) throws DataError {
        String sqlType = typedValue.getType().getName();
        int sqlTypeValue;
        switch (sqlType) {
            case Constants.Types.OutParameterTypes.XML:
                sqlTypeValue = Types.SQLXML;
                break;
            case Constants.Types.OutParameterTypes.INTERVAL_DAY_TO_SECOND:
                sqlTypeValue = OracleTypes.INTERVALDS;
                break;
            case Constants.Types.OutParameterTypes.INTERVAL_YEAR_TO_MONTH:
                sqlTypeValue = OracleTypes.INTERVALYM;
                break;
            default:
                throw new DataError(String.format("Unsupported OutParameter type: %s", sqlType));
        }
        return sqlTypeValue;
    }

    @Override
    protected void setXml(Connection connection, PreparedStatement preparedStatement,
                          int index, BXml value) throws SQLException, DataError {
        try {
            SQLXML sqlXml = connection.createSQLXML();
            sqlXml.setString(value.toString());
            preparedStatement.setObject(index, sqlXml, Types.SQLXML);
        } catch (NoClassDefFoundError e) {
            throw new DataError("Error occurred while setting an xml data. Check whether both " +
                    "`xdb.jar` and `xmlparserv2.jar` are added as dependency in Ballerina.toml");
        }
    }

    @Override
    protected int setCustomBOpenRecord(Connection connection, PreparedStatement preparedStatement, int index,
                                      Object value, boolean returnType) throws DataError, SQLException {
        Type type = ((BMap<?, ?>) value).getType();
        String recordName = type.getName();
        switch (recordName) {
            case Constants.Types.INTERVAL_YEAR_TO_MONTH_RECORD:
                setIntervalYearToMonth(preparedStatement, index, value);
                return returnType ? OracleTypes.INTERVALYM : 0;
            case Constants.Types.INTERVAL_DAY_TO_SECOND_RECORD:
                setIntervalDayToSecond(preparedStatement, index, value);
                return returnType ? OracleTypes.INTERVALDS : 0;
            default:
                throw new DataError(String.format("Unsupported type passed in column index: %d", index));
        }
    }

    private void setIntervalYearToMonth(PreparedStatement preparedStatement,
                                        int index, Object value) throws SQLException, DataError {
        String intervalYToM = ConverterUtils.convertIntervalYearToMonth(value);
        preparedStatement.setString(index, intervalYToM);
    }

    private void setIntervalDayToSecond(PreparedStatement preparedStatement,
                                        int index, Object value) throws SQLException, DataError {
        String intervalYToM = ConverterUtils.convertIntervalDayToSecond(value);
        preparedStatement.setString(index, intervalYToM);

    }

    private void setOracleObject(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, DataError {
        if (value == null) {
            throw Utils.throwInvalidParameterError(null, "object");
        }
        Struct oracleObject = ConverterUtils.convertOracleObject(connection, value);
        preparedStatement.setObject(index, oracleObject);
    }

    private void setVarray(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, DataError {
        if (value == null) {
            throw Utils.throwInvalidParameterError(null, "varray");
        }
        Array oracleArray = ConverterUtils.convertVarray(connection, value);
        preparedStatement.setArray(index, oracleArray);
    }
}
