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
import io.ballerina.stdlib.sql.exception.ApplicationError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultResultParameterProcessor;
import io.ballerina.stdlib.sql.utils.ColumnDefinition;
import io.ballerina.stdlib.sql.utils.ErrorGenerator;
import io.ballerina.stdlib.sql.utils.Utils;
import oracle.jdbc.OracleTypes;

import java.math.BigDecimal;
import java.math.MathContext;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLXML;
import java.sql.Struct;
import java.sql.Time;
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
            throws ApplicationError {
        if (structValue == null) {
            return null;
        }
        Field[] internalStructFields = structType.getFields().values().toArray(new Field[0]);
        BMap<BString, Object> struct = ValueCreator.createMapValue(structType);
        try {
            Object[] dataArray = structValue.getAttributes();
            if (dataArray != null) {
                if (dataArray.length != internalStructFields.length) {
                    throw new ApplicationError("specified record and the returned SQL Struct field counts " +
                            "are different, and hence not compatible");
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
        } catch (SQLException e) {
            throw new ApplicationError("Error while retrieving data to create " + structType.getName()
                    + " record. ", e);
        }
        return struct;
    }

    @Override
    public Object processCustomTypeFromResultSet(ResultSet resultSet, int columnIndex,
                                                 ColumnDefinition columnDefinition)
            throws ApplicationError, SQLException {
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
                throw new ApplicationError("Unsupported SQL type " + columnDefinition.getSqlName());
        }
    }

    @Override
    public Object processCustomOutParameters(
            CallableStatement statement, int paramIndex, int sqlType) throws ApplicationError {
        switch (sqlType) {
            case OracleTypes.INTERVALDS:
            case OracleTypes.INTERVALYM:
                return processInterval(statement, paramIndex);
            default:
                throw new ApplicationError("Unsupported SQL type '" + sqlType + "' when reading Procedure call " +
                        "Out parameter of index '" + paramIndex + "'.");
        }
    }

    @Override
    public Object convertCustomOutParameter(Object value, String outParamObjectName, int sqlType, Type ballerinaType) {
        try {
            switch (outParamObjectName) {
                case Constants.Types.OutParameterTypes.INTERVAL_DAY_TO_SECOND:
                    return convertInterval((String) value, sqlType, ballerinaType, "INTERVALDS");
                case Constants.Types.OutParameterTypes.INTERVAL_YEAR_TO_MONTH:
                    return convertInterval((String) value, sqlType, ballerinaType, "INTERVALYM");
                default:
                    return ErrorGenerator.getSQLApplicationError("Unsupported SQL type " + sqlType);
            }

        } catch (ApplicationError e) {
            return ErrorGenerator.getSQLApplicationError(e.getMessage());
        }
    }

    @Override
    public Object convertTimeStamp(java.util.Date timestamp, int sqlType, Type type) throws ApplicationError {
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
                        throw new ApplicationError("Unsupported Ballerina type:" +
                                type.getName() + " for SQL Timestamp data type.");
                    }
                case TypeTags.INT_TAG:
                    return timestamp.getTime();
                case TypeTags.INTERSECTION_TAG:
                    return Utils.createTimeStruct(timestamp.getTime());
            }
        }
        return null;
    }

    private Object processInterval(CallableStatement statement, int paramIndex) throws ApplicationError {
        try {
            return statement.getString(paramIndex);
        } catch (SQLException e) {
            throw new ApplicationError("Error when reading Procedure call " +
                    "Out parameter of index '" + paramIndex + "'.");
        }
    }

    private Object processIntervalResult(ResultSet resultSet, int columnIndex, int sqlType, Type ballerinaType,
                                         String sqlTypeName) throws ApplicationError, SQLException {
        String intervalString = resultSet.getString(columnIndex);
        return convertInterval(intervalString, sqlType, ballerinaType, sqlTypeName);
    }

    private Object convertInterval(String interval, int sqlType, Type ballerinaType, String sqlTypeName)
            throws ApplicationError {
        if (interval != null) {
            switch (ballerinaType.getTag()) {
                case TypeTags.STRING_TAG:
                    return fromString(interval);
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    try {
                        if (sqlType == OracleTypes.INTERVALDS) {
                            //format: DD HH:Min:SS.XXX
                            if (ballerinaType.getName().
                                    equalsIgnoreCase(io.ballerina.stdlib.time.util.Constants.TIME_OF_DAY_RECORD)) {
                                Time time = Time.valueOf(interval.split("\\s+")[1].split("\\.")[0]);
                                return Utils.createTimeRecord(time);
                            } else if (ballerinaType.getName().
                                    equalsIgnoreCase(Constants.Types.INTERVAL_DAY_TO_SECOND_RECORD)) {
                                String[] splitOnSpaces = interval.split("\\s+");
                                String days = splitOnSpaces[0];
                                String[] splitOnDots = splitOnSpaces[1].split("\\.");
                                String secondFractions = splitOnDots[1];
                                String[] splitOnColons = splitOnDots[0].split(":");
                                BMap<BString, Object> intervalMap = ValueCreator
                                        .createRecordValue(ModuleUtils.getModule(),
                                                Constants.Types.INTERVAL_DAY_TO_SECOND_RECORD);
                                intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.DAYS),
                                        Integer.parseInt(days));
                                intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.HOURS),
                                        Integer.parseInt(splitOnColons[0]));
                                intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.MINUTES),
                                        Integer.parseInt(splitOnColons[1]));
                                BigDecimal second = new BigDecimal(splitOnColons[2]);
                                second = second.add((new BigDecimal(Integer.parseInt(secondFractions)))
                                        .divide(io.ballerina.stdlib.time.util.Constants.ANALOG_KILO,
                                                MathContext.DECIMAL128));
                                intervalMap.put(StringUtils.fromString(Constants.Types.IntervalDayToSecond.SECONDS),
                                        ValueCreator.createDecimalValue(second));
                                return intervalMap;
                            }
                        } else {
                            //format: YY-MM
                            if (ballerinaType.getName().
                                    equalsIgnoreCase(Constants.Types.INTERVAL_YEAR_TO_MONTH_RECORD)) {
                                String[] splitOnDash = interval.split("-");
                                BMap<BString, Object> intervalMap = ValueCreator
                                        .createRecordValue(ModuleUtils.getModule(),
                                                Constants.Types.INTERVAL_YEAR_TO_MONTH_RECORD);
                                intervalMap.put(StringUtils.fromString(Constants.Types.IntervalYearToMonth.YEARS),
                                        Integer.parseInt(splitOnDash[0]));
                                intervalMap.put(StringUtils.fromString(Constants.Types.IntervalYearToMonth.MONTHS),
                                        Integer.parseInt(splitOnDash[1]));
                                return intervalMap;
                            }
                        }
                        throw new ApplicationError("Unsupported Ballerina type:" +
                                ballerinaType.getName() + " for " + sqlTypeName + " data type.");
                    } catch (IndexOutOfBoundsException e) {
                        throw new ApplicationError("Incompatible format found in : " + interval);
                    }
                default:
                    throw new ApplicationError(sqlTypeName + " field cannot be converted to ballerina type : " +
                            ballerinaType.getName());
            }
        } else {
            return null;
        }
    }

    @Override
    public Object processXmlResult(ResultSet resultSet, int columnIndex, int sqlType, Type ballerinaType)
            throws ApplicationError, SQLException {
        try {
            SQLXML sqlxml = resultSet.getSQLXML(columnIndex);
            return this.convertXml(sqlxml, sqlType, ballerinaType);
        } catch (NoClassDefFoundError e) {
            throw new ApplicationError("Error occurred while retrieving an xml data. Check whether both " +
                    "`xdb.jar` and `xmlparserv2.jar` are added as dependency in Ballerina.toml");
        }
    }

    @Override
    public Object convertXml(SQLXML value, int sqlType, Type type) throws ApplicationError, SQLException {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL XML");
        if (value != null) {
            return XmlUtils.parse(value.getBinaryStream());
        } else {
            return null;
        }
    }

    @Override
    public Object convertDecimal(BigDecimal value, int sqlType, Type type, boolean isNull) throws ApplicationError {
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
