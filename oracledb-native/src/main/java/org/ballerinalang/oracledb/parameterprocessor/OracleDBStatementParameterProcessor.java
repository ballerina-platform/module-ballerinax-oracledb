package org.ballerinalang.oracledb.parameterprocessor;

import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.oracledb.Constants;
import org.ballerinalang.oracledb.utils.ConverterUtils;
import org.ballerinalang.sql.exception.ApplicationError;
import org.ballerinalang.sql.parameterprocessor.DefaultStatementParameterProcessor;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Locale;

/**
 * This class overrides DefaultStatementParameterProcessor to implement methods required to convert ballerina types
 * into SQL types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class OracleDBStatementParameterProcessor extends DefaultStatementParameterProcessor {
    private static final Object lock = new Object();
    private static volatile OracleDBStatementParameterProcessor instance;

    public static OracleDBStatementParameterProcessor getInstance() {
        if (instance == null) {
            synchronized (lock) {
                if (instance == null) {
                    instance = new OracleDBStatementParameterProcessor();
                }
            }
        }
        return instance;
    }

    @Override
    protected void setCustomSqlTypedParam(Connection connection, PreparedStatement preparedStatement, int index,
                                          BObject typedValue) throws SQLException, ApplicationError, IOException {
        String sqlType = typedValue.getType().getName();
        Object value = typedValue.get(Constants.TypedValueFields.VALUE);

        switch (sqlType) {
            case Constants.Types.CustomTypes.INTERVAL_YEAR_TO_MONTH:
                setIntervalYearToMonth(connection, preparedStatement, index, value);
                break;
            case Constants.Types.CustomTypes.INTERVAL_DAY_TO_SECOND:
                setIntervalDayToSecond(connection, preparedStatement, index, value);
                break;
            default:
                super.setCustomSqlTypedParam(connection, preparedStatement, index, typedValue);
        }
    }

    @Override
    protected int getCustomSQLType(BObject typedValue) throws ApplicationError {
        String sqlType = typedValue.getType().getName();
        int sqlTypeValue;
        switch (sqlType) {
            // set values according to the call type
            default:
                sqlTypeValue = super.getCustomSQLType(typedValue);
        }
        return sqlTypeValue;
    }

    @Override
    protected Object[] getCustomArrayData(Object value) throws ApplicationError {
        // custom type array logic
        return super.getCustomArrayData(value);
    }

    @Override
    protected Object[] getCustomStructData(Connection conn, Object value)
            throws SQLException, ApplicationError {
        Type type = TypeUtils.getType(value);
        String structuredSQLType = type.getName().toUpperCase(Locale.getDefault());
        // custom type struct logic
        return super.getCustomStructData(conn, value);
    }

    private void setIntervalYearToMonth(Connection connection, PreparedStatement preparedStatement,
                                         int index, Object value) throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setString(index, null);
        } else if (value instanceof BString) {
            preparedStatement.setString(index, value.toString());
        } else {
            String intervalYToM = ConverterUtils.convertIntervalYearToMonth(value);
            preparedStatement.setString(index, intervalYToM);
        }
    }

    private void setIntervalDayToSecond(Connection connection, PreparedStatement preparedStatement,
                                        int index, Object value) throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setString(index, null);
        } else if (value instanceof BString) {
            preparedStatement.setString(index, value.toString());
        } else {
            String intervalYToM = ConverterUtils.convertIntervalDayToSecond(value);
            preparedStatement.setString(index, intervalYToM);
        }
    }
}
