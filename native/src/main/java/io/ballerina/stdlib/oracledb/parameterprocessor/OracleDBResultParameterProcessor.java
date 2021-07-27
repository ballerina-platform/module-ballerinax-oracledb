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
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.oracledb.utils.ConverterUtils;
import io.ballerina.stdlib.oracledb.utils.ModuleUtils;
import io.ballerina.stdlib.oracledb.utils.Utils;
import io.ballerina.stdlib.sql.exception.ApplicationError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultResultParameterProcessor;

import java.math.BigDecimal;
import java.sql.Array;
import java.sql.SQLException;
import java.sql.Struct;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * This class overrides DefaultResultParameterProcessor to implement methods required convert SQL types into
 * ballerina types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class OracleDBResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final OracleDBResultParameterProcessor instance = new OracleDBResultParameterProcessor();
    private static final BObject iterator = ValueCreator.createObjectValue(
            ModuleUtils.getModule(), Constants.CUSTOM_RESULT_ITERATOR_OBJECT, new Object[0]);

    /**
     * Singleton static method that returns an instance of `OracleDBResultParameterProcessor`.
     *
     * @return OracleDBResultParameterProcessor
     */
    public static OracleDBResultParameterProcessor getInstance() {
        return instance;
    }

    @Override
    protected BObject getIteratorObject() {
        return iterator;
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

    /**
     * Overrides org.ballerinalang.sql.parameterprocessor.convertArray to implement oracledb specific array conversion
     * logic.
     * @param array Retrieved SQL array
     * @param sqlType SQL data type of the array
     * @param type Ballerina type that the array needs to be converted to
     * @return BArray generated from the SQL array
     * @throws SQLException if an error occurs while attempting to access the array
     * @throws ApplicationError if ballerina types do not match the data
     */
    public BArray convertArray(Array array, int sqlType, Type type) throws SQLException, ApplicationError {
        if (array != null) {
            org.ballerinalang.sql.utils.Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL Array");
            Object[] dataArray = (Object[]) array.getArray();
            if (dataArray == null || dataArray.length == 0) {
                return null;
            }
            if (type.getTag() == TypeTags.ARRAY_TAG) {
                String typeName = type.toString();
                if (!typeName.equals(Constants.Types.BallerinaArrayTypes.ANYDATA)) {
                    return createAndPopulateTypedArray(dataArray, typeName);
                }
            }
            Object firstNonNullElement = firstNonNullObject(dataArray);
            boolean containsNull = containsNullObject(dataArray);
            if (containsNull) {
                // If there are some null elements, return a union-type element array
                return createAndPopulateBBRefValueArray(firstNonNullElement, dataArray, type);
            } else {
                // If there are no null elements, return a ballerina primitive-type array
                return createAndPopulatePrimitiveValueArray(firstNonNullElement, dataArray);
            }
        } else {
            return null;
        }
    }

    private BArray createAndPopulateTypedArray(Object[] dataArray, String typeName)
            throws ApplicationError {
        BArray typedArray;
        switch (typeName) {
            case Constants.Types.BallerinaArrayTypes.STRING:
                typedArray = ConverterUtils.convertToStringArrayFromVarray(dataArray);
                break;
            case Constants.Types.BallerinaArrayTypes.INT:
                typedArray = ConverterUtils.convertToIntArrayFromVarray(dataArray);
                break;
            case Constants.Types.BallerinaArrayTypes.FLOAT:
                typedArray = ConverterUtils.convertToFloatArrayFromVarray(dataArray);
                break;
            case Constants.Types.BallerinaArrayTypes.DECIMAL:
                typedArray = ConverterUtils.convertToDecimalArrayFromVarray(dataArray);
                break;
            case Constants.Types.BallerinaArrayTypes.BOOLEAN:
                typedArray = ConverterUtils.convertToBooleanArrayFromVarray(dataArray);
                break;
            case Constants.Types.BallerinaArrayTypes.BYTE:
                typedArray = ConverterUtils.convertToByteArrayFromVarray(dataArray);
                break;
            default:
                throw Utils.throwArrayTypeCastError(typeName);
        }
        return typedArray;
    }
}
