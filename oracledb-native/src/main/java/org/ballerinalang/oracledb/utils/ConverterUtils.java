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

        String year = getIntervalString(yearObject, Constants.Types.OracleDbTypes.INTERVAL_YEAR_TO_MONTH);
        String month = getIntervalString(monthObject, Constants.Types.OracleDbTypes.INTERVAL_YEAR_TO_MONTH);

        return year + "-" + month;
    }

    /**
     * Converts IntervalDayToSecondValue value to String.
     * @param value Custom IntervalDayToSecond value
     * @return String of INTERVAL_DAY_TO_SECOND
     * @throws ApplicationError error thrown if invalid types are passed
     */
    public static String convertIntervalDayToSecond(Object value) throws ApplicationError {
        Type type = TypeUtils.getType(value);
        if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throwApplicationErrorForInvalidTypes(Constants.Types.OracleDbTypes.INTERVAL_DAY_TO_SECOND);
        }

        Map<String, Object> fields = getRecordData(value);
        Object dayObject = fields.get(Constants.Types.IntervalDayToSecond.DAY);
        Object hourObject = fields.get(Constants.Types.IntervalDayToSecond.HOUR);
        Object minuteObject = fields.get(Constants.Types.IntervalDayToSecond.MINUTE);
        Object secondObject = fields.get(Constants.Types.IntervalDayToSecond.SECOND);

        String day = getIntervalString(dayObject, Constants.Types.OracleDbTypes.INTERVAL_DAY_TO_SECOND);
        String hour = getIntervalString(hourObject, Constants.Types.OracleDbTypes.INTERVAL_DAY_TO_SECOND);
        String minute = getIntervalString(minuteObject, Constants.Types.OracleDbTypes.INTERVAL_DAY_TO_SECOND);
        String second = getIntervalString(secondObject, Constants.Types.OracleDbTypes.INTERVAL_DAY_TO_SECOND);

        return day + " " + hour + ":" + minute + ":" + second;
    }

    /**
     * Converts BfileValue value to String.
     * @param value Custom Bfile value
     * @return String of BFILE
     */
    public static String convertBfile(Object value) throws ApplicationError {
        Type type = TypeUtils.getType(value);
        if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throwApplicationErrorForInvalidTypes(Constants.Types.OracleDbTypes.BFILE);
        }
        Map<String, Object> fields = getRecordData(value);
        String directory = ((BString) fields.get(Constants.Types.Bfile.DIRECTORY)).getValue();
        String file = ((BString) fields.get(Constants.Types.Bfile.FILE)).getValue();

        return "bfilename('" + directory + "', '" + file + "')";
    }

//     /**
//      * Converts OracleObjectValue value to oracle.sql.STRUCT.
//      * @param value Custom Bfile value
//      * @return String of BFILE
//      */
//     public static STRUCT convertOracleObject(Connection connection, Object value) throws ApplicationError {
//         Type type = TypeUtils.getType(value);
//         if (type.getTag() != TypeTags.RECORD_TYPE_TAG) {
//             throwApplicationErrorForInvalidTypes(Constants.Types.OracleDbTypes.BFILE);
//         }
//
////         StructDescriptor structdesc = StructDescriptor.createDescriptor("OBJECT_TYPE", connection);
////         STRUCT mySTRUCT = new STRUCT(structdesc, connection, attributes);
// //        Map<String, Object> fields = getRecordData(value);
// //        String directory = ((BString) fields.get(Constants.Types.Bfile.DIRECTORY)).getValue();
// //        String file = ((BString) fields.get(Constants.Types.Bfile.FILE)).getValue();
// //
// //        return "bfilename('" + directory + "', '" + file + "')";
//     }

    private static String getIntervalString(Object param, String typeName) throws ApplicationError {
        String value = null;
        if (param instanceof BString) {
            value = ((BString) param).getValue();
        } else if (param instanceof Long || param instanceof Double) {
            value = param.toString();
        } else {
            throwApplicationErrorForInvalidTypes(typeName);
        }
        return value;
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
            // int typeTag = field.getFieldType().getTag();
            structData.put(field.getFieldName(), bValue);
        }
        return structData;
    }

    private static void throwApplicationErrorForInvalidTypes(String sqlTypeName) throws ApplicationError {
        throw new ApplicationError("Invalid data types for " + sqlTypeName);
    }
}
