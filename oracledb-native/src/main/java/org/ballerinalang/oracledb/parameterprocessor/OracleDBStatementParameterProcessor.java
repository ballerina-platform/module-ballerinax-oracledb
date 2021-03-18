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

package org.ballerinalang.oracledb.parameterprocessor;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.io.IOException;
import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Struct;

import oracle.xdb.XMLType;
import org.ballerinalang.oracledb.Constants;
import org.ballerinalang.oracledb.utils.ConverterUtils;
import org.ballerinalang.sql.exception.ApplicationError;
import org.ballerinalang.sql.parameterprocessor.DefaultStatementParameterProcessor;

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
                                          BObject typedValue) throws SQLException, ApplicationError, IOException {
        String sqlType = typedValue.getType().getName();
        Object value = typedValue.get(Constants.TypedValueFields.VALUE);
        if (value == null) {
            preparedStatement.setString(index, null);
            return;
        }

        switch (sqlType) {
            case Constants.Types.CustomTypes.INTERVAL_YEAR_TO_MONTH:
                setIntervalYearToMonth(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.INTERVAL_DAY_TO_SECOND:
                setIntervalDayToSecond(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.BFILE:
                setBfile(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.OBJECT:
                setOracleObject(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.VARRAY:
                setVarray(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.NESTED_TABLE:
                setNestedTable(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.XML:
                setXml(connection, preparedStatement, index, value);
                break;
            default:
                // TODO
                super.setCustomSqlTypedParam(connection, preparedStatement, index, typedValue);
        }
    }

    private void setIntervalYearToMonth(Connection connection, PreparedStatement preparedStatement,
                                         int index, Object value) throws SQLException, ApplicationError {
        if (value instanceof BString) {
            preparedStatement.setString(index, value.toString());
        } else {
            String intervalYToM = ConverterUtils.convertIntervalYearToMonth(value);
            preparedStatement.setString(index, intervalYToM);
        }
    }

    private void setIntervalDayToSecond(Connection connection, PreparedStatement preparedStatement,
                                        int index, Object value) throws SQLException, ApplicationError {
        if (value instanceof BString) {
            preparedStatement.setString(index, value.toString());
        } else {
            String intervalYToM = ConverterUtils.convertIntervalDayToSecond(value);
            preparedStatement.setString(index, intervalYToM);
        }
    }

    private void setBfile(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, ApplicationError {
        String bfile = ConverterUtils.convertBfile(value);
        preparedStatement.setString(index, bfile);
    }

    private void setOracleObject(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, ApplicationError {
        Struct oracleObject = ConverterUtils.convertOracleObject(connection, value);
        preparedStatement.setObject(index, oracleObject);
    }

    private void setVarray(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, ApplicationError {
        Array varray = ConverterUtils.convertVarray(value);
        preparedStatement.setArray(index, varray);
    }

    private void setNestedTable(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, ApplicationError {
        Array nestedTable = ConverterUtils.convertNestedTable(value);
        preparedStatement.setArray(index, nestedTable);
    }

    private void setXml(Connection connection, PreparedStatement preparedStatement, int index, Object value)
            throws SQLException, ApplicationError {
        XMLType xml = ConverterUtils.convertXml(connection, value);
        preparedStatement.setObject(index, xml);
    }
}

