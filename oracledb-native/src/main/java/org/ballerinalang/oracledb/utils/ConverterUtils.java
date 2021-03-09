package org.ballerinalang.oracledb.utils;

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.StructureType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.oracledb.Constants;
import org.ballerinalang.sql.exception.ApplicationError;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * This class converts ballerina custom types to driver specific objects.
 *
 * @since 0.1.0
 */
public class ConverterUtils {

    /**
     * Converts IntervalYearToMonthValue value to String.
     * @param value Custom IntervalYearToMonthValue value
     * @return String of INTERVAL_YEAR_TO_MONTH
     * @throws ApplicationError error thrown if invalid types are passed
     */
    public static String convertIntervalYearToMonth(Object value) throws ApplicationError {
        Type type = TypeUtils.getType(value);
        if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throwApplicationErrorForInvalidTypes(Constants.Types.OracleDbTypes.INTERVAL_YEAR_TO_MONTH);
        }

        Map<String, Object> fields = getRecordData(value);
        Object yearObject = fields.get(Constants.Types.IntervalYearToMonth.YEAR);
        Object monthObject = fields.get(Constants.Types.IntervalYearToMonth.MONTH);
        String year = "";
        String month = "";

        if (yearObject instanceof BString) {
            year = ((BString) yearObject).getValue();
        } else if (yearObject instanceof Long) {
            year = yearObject.toString();
        } else {
            throwApplicationErrorForInvalidTypes(Constants.Types.OracleDbTypes.INTERVAL_YEAR_TO_MONTH);
        }

        if (monthObject instanceof BString) {
            month = ((BString) monthObject).getValue();
        } else if (monthObject instanceof Long) {
            month = monthObject.toString();
        } else {
            throwApplicationErrorForInvalidTypes(Constants.Types.OracleDbTypes.INTERVAL_YEAR_TO_MONTH);
        }

        return year + "-" + month;
    }

    private static Map<String, Object> getRecordData(Object value) {
        Type type = TypeUtils.getType(value);
        Map<String, Field> structFields = ((StructureType) type).getFields();
        int fieldCount = structFields.size();
        Iterator<Field> fieldIterator = structFields.values().iterator();
        HashMap<String, Object> structData = new HashMap<>();
        for (int i = 0; i < fieldCount; i++) {
            Field field = fieldIterator.next();
            Object bValue = ((BMap) value).get(fromString(field.getFieldName()));
            int typeTag = field.getFieldType().getTag();
            structData.put(field.getFieldName(), bValue);
        }
        return structData;
    }

    private static void throwApplicationErrorForInvalidTypes(String sqlTypeName) throws ApplicationError {
        throw new ApplicationError("Invalid data types for " + sqlTypeName);
    }
}
