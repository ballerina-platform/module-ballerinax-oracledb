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

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.StructureType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.XmlUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.oracledb.utils.ModuleUtils;
import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.exception.FieldMismatchError;
import io.ballerina.stdlib.sql.exception.TypeMismatchError;
import io.ballerina.stdlib.sql.exception.UnsupportedTypeError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultResultParameterProcessor;
import io.ballerina.stdlib.sql.utils.ColumnDefinition;
import io.ballerina.stdlib.sql.utils.Utils;
import oracle.jdbc.OracleTypes;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.JDBCType;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLXML;
import java.sql.Struct;
import java.sql.Timestamp;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * This class overrides DefaultResultParameterProcessor to implement methods required convert SQL types into
 * ballerina types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class OracleDBResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final OracleDBResultParameterProcessor instance = new OracleDBResultParameterProcessor();
    private static final BObject iteratorObject = ValueCreator.createObjectValue(
            ModuleUtils.getModule(), Constants.CUSTOM_RESULT_ITERATOR_OBJECT);

    /**
     * Singleton static method that returns an instance of `OracleDBResultParameterProcessor`.
     *
     * @return OracleDBResultParameterProcessor
     */
    public static OracleDBResultParameterProcessor getInstance() {
        return instance;
    }

    @Override
    public BObject getBalStreamResultIterator() {
        return iteratorObject;
    }

    @Override
    protected BMap<BString, Object> createUserDefinedType(Struct structValue, StructureType structType)
            throws DataError, SQLException {
        if (structValue == null) {
            return null;
        }
        Field[] internalStructFields = structType.getFields().values().toArray(new Field[0]);
        BMap<BString, Object> struct = ValueCreator.createMapValue(structType);
        Object[] dataArray = structValue.getAttributes();
        if (dataArray != null) {
            if (dataArray.length != internalStructFields.length) {
                throw new FieldMismatchError(structType.getName(), internalStructFields.length, dataArray.length);
            }
            int index = 0;
            for (Field internalField : internalStructFields) {
                int type = internalField.getFieldType().getTag();
                BString fieldName = fromString(internalField.getFieldName());
                Object value = dataArray[index];
                switch (type) {
                    case TypeTags.INT_TAG:
                        if (value instanceof BigDecimal) {
                            struct.put(fieldName, ((BigDecimal) value).intValue());
                        } else {
                            struct.put(fieldName, value);
                        }
                        break;
                    case TypeTags.FLOAT_TAG:
                        if (value instanceof BigDecimal) {
                            struct.put(fieldName, ((BigDecimal) value).doubleValue());
                        } else {
                            struct.put(fieldName, value);
                        }
                        break;
                    case TypeTags.DECIMAL_TAG:
                        if (value instanceof BigDecimal) {
                            struct.put(fieldName, ValueCreator.createDecimalValue((BigDecimal) value));
                        } else {
                            struct.put(fieldName, value);
                        }
                        break;
                    case TypeTags.STRING_TAG:
                        struct.put(fieldName, StringUtils.fromString((String) value));
                        break;
                    case TypeTags.BOOLEAN_TAG:
                        if (value instanceof BigDecimal) {
                            struct.put(fieldName, ((BigDecimal) value).intValue() == 1);
                        } else {
                            struct.put(fieldName, ((int) value) == 1);
                        }
                        break;
                    case TypeTags.OBJECT_TYPE_TAG:
                    case TypeTags.RECORD_TYPE_TAG:
                        struct.put(fieldName,
                                createUserDefinedType((Struct) value,
                                        (StructureType) internalField.getFieldType()));
                        break;
                    default:
                        createUserDefinedTypeSubtype(internalField, structType);
                }
                ++index;
            }
        }
        return struct;
    }

    @Override
    public Object processCustomTypeFromResultSet(ResultSet resultSet, int columnIndex,
                                                 ColumnDefinition columnDefinition)
            throws DataError, SQLException {
        int sqlType = columnDefinition.getSqlType();
        Type ballerinaType = columnDefinition.getBallerinaType();
        switch (sqlType) {
            case OracleTypes.INTERVALDS:
            case OracleTypes.INTERVALYM:
                return processIntervalResult(resultSet, columnIndex, sqlType, ballerinaType,
                        columnDefinition.getSqlName());
            case OracleTypes.TIMESTAMPTZ:
            case OracleTypes.TIMESTAMPLTZ:
                return processTimestampWithTimezoneResult(resultSet, columnIndex, sqlType, ballerinaType);
            default:
                throw new UnsupportedTypeError(JDBCType.valueOf(sqlType).getName(), columnIndex);
        }
    }

    @Override
    public Object processCustomOutParameters(
            CallableStatement statement, int paramIndex, int sqlType) throws DataError, SQLException {
        switch (sqlType) {
            case OracleTypes.INTERVALDS:
            case OracleTypes.INTERVALYM:
                return processInterval(statement, paramIndex);
            default:
                throw new UnsupportedTypeError(JDBCType.valueOf(sqlType).getName(), paramIndex);
        }
    }

    @Override
    public Object convertCustomOutParameter(Object value, String outParamObjectName, int sqlType, Type ballerinaType)
            throws DataError {
        switch (outParamObjectName) {
            case Constants.Types.OutParameterTypes.INTERVAL_DAY_TO_SECOND:
                return convertInterval((String) value, sqlType, ballerinaType, "INTERVALDS");
            case Constants.Types.OutParameterTypes.INTERVAL_YEAR_TO_MONTH:
                return convertInterval((String) value, sqlType, ballerinaType, "INTERVALYM");
            default:
                throw new UnsupportedTypeError(String.format(
                       "ParameterizedCallQuery consists of a parameter of unsupported type '%s'.", outParamObjectName));
        }
    }

    @Override
    public Object convertTimeStamp(java.util.Date timestamp, int sqlType, Type type) throws DataError {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL Date/Time");
        if (timestamp != null) {
            switch (type.getTag()) {
                case TypeTags.STRING_TAG:
                    return fromString(timestamp.toString());
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    if (type.getName().equalsIgnoreCase(io.ballerina.stdlib.time.util.Constants.CIVIL_RECORD)
                            && timestamp instanceof Timestamp) {
                        return Utils.createTimestampRecord((Timestamp) timestamp);
                    } else if (type.getName().equalsIgnoreCase(io.ballerina.stdlib.time.util.Constants.DATE_RECORD)
                            && timestamp instanceof Timestamp) {
                        return Utils.createDateRecord(new java.sql.Date(timestamp.getTime()));
                    } else {
                        throw new TypeMismatchError("SQL Timestamp", type.getName(),
                                new String[]{"time:Civil", "time:Date"});
                    }
                case TypeTags.INT_TAG:
                    return timestamp.getTime();
                case TypeTags.INTERSECTION_TAG:
                    return Utils.createTimeStruct(timestamp.getTime());
            }
        }
        return null;
    }

    private Object processInterval(CallableStatement statement, int paramIndex) throws SQLException {
        return statement.getString(paramIndex);
    }

    private Object processIntervalResult(ResultSet resultSet, int columnIndex, int sqlType, Type ballerinaType,
                                         String sqlTypeName) throws DataError, SQLException {
        String intervalString = resultSet.getString(columnIndex);
        return convertInterval(intervalString, sqlType, ballerinaType, sqlTypeName);
    }

    private Object convertInterval(String interval, int sqlType, Type ballerinaType, String sqlTypeName)
            throws DataError {
        if (interval != null) {
            switch (ballerinaType.getTag()) {
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    boolean isNegative = interval.startsWith("-");
                    if (isNegative) {
                        interval = interval.substring(1);
                    }
                    if (sqlType == OracleTypes.INTERVALDS) {
                        //format: [-]DD HH:Min:SS.XXX
                        if (ballerinaType.getName().
                                equalsIgnoreCase(Constants.Types.INTERVAL_DAY_TO_SECOND_RECORD)) {
                            String[] splitOnSpaces = interval.split("\\s+");
                            String days = splitOnSpaces[0];
                            String[] splitOnColons = splitOnSpaces[1].split(":");
                            int dayValue = Integer.parseInt(days);
                            int hourValue = Integer.parseInt(splitOnColons[0]);
                            int minuteValue = Integer.parseInt(splitOnColons[1]);
                            BigDecimal seconds = new BigDecimal(splitOnColons[2]);
                            BMap<BString, Object> intervalMap = ValueCreator
                                    .createRecordValue(ModuleUtils.getModule(),
                                            Constants.Types.INTERVAL_DAY_TO_SECOND_RECORD);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.DAYS),
                                    dayValue);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.HOURS),
                                    hourValue);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.MINUTES),
                                    minuteValue);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.SECONDS),
                                    ValueCreator.createDecimalValue(seconds));
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.SIGN),
                                    isNegative ? -1L  : 1L);
                            return intervalMap;
                        }
                    } else {
                        //format: [-]YY-MM
                        if (ballerinaType.getName().
                                equalsIgnoreCase(Constants.Types.INTERVAL_YEAR_TO_MONTH_RECORD)) {
                            String[] splitOnDash = interval.split("-");
                            int yearValue = Integer.parseInt(splitOnDash[0]);
                            int monthValue = Integer.parseInt(splitOnDash[1]);
                            BMap<BString, Object> intervalMap = ValueCreator
                                    .createRecordValue(ModuleUtils.getModule(),
                                            Constants.Types.INTERVAL_YEAR_TO_MONTH_RECORD);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalYearToMonth.YEARS),
                                    yearValue);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalYearToMonth.MONTHS),
                                    monthValue);
                            intervalMap.put(StringUtils.fromString(Constants.Types.IntervalYearToMonth.SIGN),
                                    isNegative ? -1L : 1L);
                            return intervalMap;
                        }
                    }
                    throw new TypeMismatchError(sqlTypeName, ballerinaType.getName(),
                            new String[]{"oracle:IntervalYearToMonth", "oracle:IntervalDayToSecond"});
                default:
                    throw new UnsupportedTypeError(String.format("%s field cannot be converted to ballerina type : %s",
                            sqlTypeName, ballerinaType.getName()));
            }
        } else {
            return null;
        }
    }

    @Override
    public Object processXmlResult(ResultSet resultSet, int columnIndex, int sqlType, Type ballerinaType)
            throws DataError, SQLException {
        try {
            SQLXML sqlxml = resultSet.getSQLXML(columnIndex);
            return this.convertXml(sqlxml, sqlType, ballerinaType);
        } catch (NoClassDefFoundError e) {
            throw new DataError("Error occurred while retrieving an xml data. Check whether both " +
                    "`xdb.jar` and `xmlparserv2.jar` are added as dependency in Ballerina.toml");
        }
    }

    @Override
    public Object convertXml(SQLXML value, int sqlType, Type type) throws DataError, SQLException {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL XML");
        if (value != null) {
            return XmlUtils.parse(value.getBinaryStream());
        } else {
            return null;
        }
    }

    @Override
    public Object convertDecimal(BigDecimal value, int sqlType, Type type, boolean isNull) throws DataError {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL decimal or real");
        if (isNull) {
            return null;
        } else {
            if (type.getTag() == TypeTags.STRING_TAG) {
                return fromString(String.valueOf(value));
            } else if (type.getTag() == TypeTags.INT_TAG) {
                return value.intValue();
            }
            return ValueCreator.createDecimalValue(value);
        }
    }
}
