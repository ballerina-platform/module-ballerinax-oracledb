package org.ballerinalang.oracledb.parameterprocessor;

import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.sql.exception.ApplicationError;
import org.ballerinalang.sql.parameterprocessor.DefaultStatementParameterProcessor;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Locale;

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
    protected void setCustomSqlTypedParam(Connection connection, PreparedStatement preparedStatement,
                                          int index, BObject typedValue)
            throws SQLException, ApplicationError, IOException {
        String sqlType = typedValue.getType().getName();

        switch (sqlType) {
            // set values according to the execute, query type
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
}
