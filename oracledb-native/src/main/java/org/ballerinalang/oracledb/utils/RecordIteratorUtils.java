package org.ballerinalang.oracledb.utils;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.oracledb.parameterprocessor.OracleDBResultParameterProcessor;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

/**
 * This class provides functionality to call `sql:RecordIteratorUtils` with a custom `ResultParameterProcessor` object.
 *
 * @since 0.1.0
 */
public class RecordIteratorUtils {

    /**
     * Calls `sql:RecordIteratorUtils` with a custom `ResultParameterProcessor` object.
     * @param customResultIterator module specific resultIterator BObject
     * @param iterator the record that needs to be iterated
     * @return next result of the iterator
     */
    public static Object nextResult(BObject customResultIterator, BObject iterator) {
        DefaultResultParameterProcessor resultParameterProcessor = OracleDBResultParameterProcessor.getInstance();
        return org.ballerinalang.sql.utils.RecordIteratorUtils.nextResult(iterator, resultParameterProcessor);
    }
}
