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

package io.ballerina.stdlib.oracledb.utils;

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.constants.TypeConstants;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.StructureType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.sql.exception.ConversionError;
import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.exception.UnsupportedTypeError;

import java.math.BigDecimal;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Struct;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;


import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * This class converts ballerina custom types to driver specific objects.
 *
 * @since 0.1.0
 */
public class ConverterUtils {

    private ConverterUtils() {}

    /**
     * Convert IntervalYearToMonthValue value to String.
     * @param value Custom IntervalYearToMonthValue value
     * @return String of INTERVAL_YEAR_TO_MONTH
     * @throws DataError error thrown if invalid types are passed
     */
    public static String convertIntervalYearToMonth(Object value)
            throws DataError {
        Map<String, Object> fields = getRecordData(value, Constants.Types.OracleDbTypes.INTERVAL_YEAR_TO_MONTH);

        long years = fields.get(Constants.Types.IntervalYearToMonth.YEARS) == null ? 0L :
                (Long) fields.get(Constants.Types.IntervalYearToMonth.YEARS);
        long months = fields.get(Constants.Types.IntervalYearToMonth.MONTHS) == null ? 0L :
                (Long) fields.get(Constants.Types.IntervalYearToMonth.MONTHS);
        long sign = (Long) fields.get(Constants.Types.IntervalYearToMonth.SIGN);
        long effectiveMonths = (years * 12L) + months;
        years = effectiveMonths / 12L;
        months = effectiveMonths % 12L;
        return sign == -1L ? "-" + years + "-" + months : years + "-" + months;
    }

    /**
     * Convert IntervalDayToSecondValue value to String.
     * @param value Custom IntervalDayToSecond value
     * @return String of INTERVAL_DAY_TO_SECOND
     * @throws DataError error thrown if invalid types are passed
     */
    public static String convertIntervalDayToSecond(Object value)
            throws DataError {
        Map<String, Object> fields = getRecordData(value, Constants.Types.OracleDbTypes.INTERVAL_DAY_TO_SECOND);
        long days = fields.get(Constants.Types.IntervalDayToSecond.DAYS) == null ? 0L :
                (Long) fields.get(Constants.Types.IntervalDayToSecond.DAYS);
        long hours = fields.get(Constants.Types.IntervalDayToSecond.HOURS) == null ? 0L :
                (Long) fields.get(Constants.Types.IntervalDayToSecond.HOURS);
        long minutes = fields.get(Constants.Types.IntervalDayToSecond.MINUTES) == null ? 0L :
                (Long) fields.get(Constants.Types.IntervalDayToSecond.MINUTES);
        double seconds = fields.get(Constants.Types.IntervalDayToSecond.SECONDS) == null ? 0.0d :
                ((BDecimal) fields.get(Constants.Types.IntervalDayToSecond.SECONDS)).floatValue();
        long sign = (Long) fields.get(Constants.Types.IntervalDayToSecond.SIGN);
        BigDecimal effectivePeriod = new BigDecimal(String.valueOf((((((days * 24L) + hours) * 60L) + minutes) * 60L) +
                seconds));
        long onlyLongPeriod = effectivePeriod.longValue();
        days = onlyLongPeriod / (86400L);
        long leftover = onlyLongPeriod % (86400L);
        hours = leftover / (3600L);
        leftover = leftover % (3600L);
        minutes = leftover / 60L;
        leftover = leftover % 60L;
        seconds = leftover + effectivePeriod.subtract(new BigDecimal(onlyLongPeriod)).doubleValue();
        return sign == -1L ? "-" + days + " " + hours + ":" + minutes + ":" + seconds :
                days + " " + hours + ":" + minutes + ":" + seconds;
    }

    /**
     * Convert OracleObjectValue value to oracle.sql.STRUCT.
     * @param value Custom Bfile value
     * @return String of BFILE
     */
    public static Struct convertOracleObject(Connection connection, Object value)
            throws DataError, SQLException {
        Map<String, Object> fields = getRecordData(value, Constants.Types.OracleDbTypes.OBJECT_TYPE);
        String objectTypeName = ((BString) fields.get(Constants.Types.OracleObject.TYPE_NAME))
                .getValue().toUpperCase(Locale.ENGLISH);
        Object[] attributes = (Object[]) fields.get(Constants.Types.OracleObject.ATTRIBUTES);
        try {
            return connection.createStruct(objectTypeName, attributes);
        } catch (SQLException e) {
            throw(e);
        } catch (Exception e) {
            // This is to catch NumberFormatException that can be thrown
            throw new ConversionError("The array contains elements of unmappable types.", e);
        }
    }

    /**
     * Convert VArray value to oracle.sql.Array.
     * @param value Custom VArray Value
     * @return sql Array
     * @throws DataError throws error if the parameter types are incorrect
     */
    public static Array convertVarray(Connection connection, Object value)
            throws DataError, SQLException {
        Map<String, Object> fields = getRecordData(value, Constants.Types.OracleDbTypes.VARRAY);
        String name = ((BString) fields.get(Constants.Types.Varray.NAME)).getValue().toUpperCase(Locale.ENGLISH);
        Object varray = fields.get(Constants.Types.Varray.ELEMENTS);
        return Utils.getOracleConnection(connection).createARRAY(name, varray);
    }

    private static Map<String, Object> getRecordData(Object value, String sqlType)
            throws DataError {
        Type type = TypeUtils.getType(value);
        Map<String, Field> structFields = ((StructureType) type).getFields();
        int fieldCount = structFields.size();
        Iterator<Field> fieldIterator = structFields.values().iterator();
        HashMap<String, Object> structData = new HashMap<>();
        for (int i = 0; i < fieldCount; i++) {
            Field field = fieldIterator.next();
            Object bValue = ((BMap) value).get(fromString(field.getFieldName()));
            int typeTag = TypeUtils.getReferredType(field.getFieldType()).getTag();
            switch (typeTag) {
                case TypeTags.INT_TAG:
                case TypeTags.FLOAT_TAG:
                case TypeTags.STRING_TAG:
                case TypeTags.BOOLEAN_TAG:
                case TypeTags.DECIMAL_TAG:
                case TypeTags.FINITE_TYPE_TAG:
                case TypeTags.UNSIGNED32_INT_TAG:
                    structData.put(field.getFieldName(), bValue);
                    break;
                case TypeTags.ARRAY_TAG:
                    Object arrayData = getArrayData(bValue);
                    structData.put(field.getFieldName(), arrayData);
                    break;
                case TypeTags.RECORD_TYPE_TAG:
                    structData.put(field.getFieldName(), getRecordData(bValue, sqlType));
                    break;
                case TypeTags.UNION_TAG:
                    if (bValue == null) {
                        structData.put(field.getFieldName(), null);
                    } else if (bValue instanceof BArray) {
                        structData.put(field.getFieldName(), getArrayData(bValue));
                    } else if (bValue instanceof BString) {
                        structData.put(field.getFieldName(), bValue);
                    } else {
                        throw Utils.throwInvalidParameterError(value, sqlType);
                    }
                    break;
                default:
                    throw Utils.throwInvalidParameterError(value, sqlType);
            }
        }
        return structData;
    }

    private static Object[] getArrayData(Object bValue) throws DataError {
        String elementType = ((BArray) bValue).getElementType().toString();
        switch (elementType) {
            case TypeConstants.BYTE_TNAME:
                return getByteOnlyArrayData(bValue);
            case io.ballerina.stdlib.sql.Constants.SqlTypes.OPTIONAL_BYTE:
            case io.ballerina.stdlib.sql.Constants.SqlTypes.BYTE_ARRAY_TYPE:
                return getByteArrayData(bValue);
            case io.ballerina.stdlib.sql.Constants.SqlTypes.OPTIONAL_INT:
            case io.ballerina.stdlib.sql.Constants.SqlTypes.INT:
                return getIntArrayData(bValue);
            case io.ballerina.stdlib.sql.Constants.SqlTypes.OPTIONAL_BOOLEAN:
            case io.ballerina.stdlib.sql.Constants.SqlTypes.BOOLEAN_TYPE:
                return getBooleanArrayData(bValue);
            case io.ballerina.stdlib.sql.Constants.SqlTypes.OPTIONAL_FLOAT:
            case io.ballerina.stdlib.sql.Constants.SqlTypes.FLOAT_TYPE:
                return getFloatArrayData(bValue);
            case io.ballerina.stdlib.sql.Constants.SqlTypes.OPTIONAL_DECIMAL:
            case io.ballerina.stdlib.sql.Constants.SqlTypes.DECIMAL_TYPE:
                return getDecimalArrayData(bValue);
            case io.ballerina.stdlib.sql.Constants.SqlTypes.OPTIONAL_STRING:
            case io.ballerina.stdlib.sql.Constants.SqlTypes.STRING:
                return getStringArrayData(bValue);
            case TypeConstants.ANYDATA_TNAME:
            case Constants.Types.BallerinaArrayTypes.OPTIONAL_ANYDATA_TYPE:
                return getAnydataArrayData(bValue);
            default:
                throw new UnsupportedTypeError("Unsupported data type for array specified for struct parameter");
        }
    }

    private static Object[] getByteOnlyArrayData(Object value) {
        return new byte[][]{((BArray) value).getBytes()};
    }

    private static Object[] getByteArrayData(Object value) {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new Object[arrayLength];
        BArray array = (BArray) value;
        for (int i = 0; i < arrayLength; i++) {
            Object innerValue = array.get(i);
            if (innerValue == null) {
                arrayData[i] = null;
            } else if (innerValue instanceof BArray) {
                arrayData[i] = ((BArray) innerValue).getBytes();
            }
        }
        return arrayData;
    }

    private static Object[] getIntArrayData(Object value) {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new Long[arrayLength];
        BArray array = (BArray) value;
        for (int i = 0; i < arrayLength; i++) {
            Object arrayValue = array.get(i);
            if (arrayValue == null) {
                arrayData[i] = null;
            } else {
                arrayData[i] = array.getInt(i);
            }
        }
        return arrayData;
    }

    private static Object[] getFloatArrayData(Object value) {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new Double[arrayLength];
        BArray array = (BArray) value;
        for (int i = 0; i < arrayLength; i++) {
            Object arrayValue = array.get(i);
            if (arrayValue == null) {
                arrayData[i] = null;
            } else {
                arrayData[i] = array.getFloat(i);
            }
        }
        return arrayData;
    }

    private static Object[] getStringArrayData(Object value) {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new String[arrayLength];
        BArray array = (BArray) value;
        for (int i = 0; i < arrayLength; i++) {
            Object arrayValue = array.get(i);
            if (arrayValue == null) {
                arrayData[i] = null;
            } else {
                arrayData[i] = array.getBString(i).getValue();
            }
        }
        return arrayData;
    }

    private static Object[] getBooleanArrayData(Object value) {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new Boolean[arrayLength];
        BArray array = (BArray) value;
        for (int i = 0; i < arrayLength; i++) {
            Object arrayValue = array.get(i);
            if (arrayValue == null) {
                arrayData[i] = null;
            } else {
                arrayData[i] = array.getBoolean(i);
            }
        }
        return arrayData;
    }

    private static Object[] getDecimalArrayData(Object value) {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new BigDecimal[arrayLength];
        BArray array = (BArray) value;
        for (int i = 0; i < arrayLength; i++) {
            Object arrayValue = array.get(i);
            if (arrayValue == null) {
                arrayData[i] = null;
            } else {
                arrayData[i] = ((BDecimal) array.getRefValue(i)).value();
            }
        }
        return arrayData;
    }

    private static Object[] getAnydataArrayData(Object value) throws DataError {
        int arrayLength = ((BArray) value).size();
        Object[] arrayData = new Object[arrayLength];
        for (int i = 0; i < arrayLength; i++) {
            Object element = ((BArray) value).getRefValue(i);
            if (element instanceof Double || element instanceof Long || element == null) {
                arrayData[i] = element;
            } else if (element instanceof BString) {
                arrayData[i] = ((BString) element).getValue();
            } else if (element instanceof BDecimal) {
                arrayData[i] = ((BDecimal) element).decimalValue();
            } else if (element instanceof BArray) {
                arrayData[i] = getAnydataArrayData(element);
            } else {
                throw new UnsupportedTypeError("The array contains elements of unmappable types.");
            }
        }
        return arrayData;
    }
}
