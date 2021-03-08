package org.ballerinalang.oracledb.utils;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.oracledb.parameterprocessor.OracleDBResultParameterProcessor;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

public class RecordIteratorUtils {

    public static Object nextResult(BObject CustomResultIterator, BObject iterator) {
        DefaultResultParameterProcessor resultParameterProcessor = OracleDBResultParameterProcessor.getInstance();
        return org.ballerinalang.sql.utils.RecordIteratorUtils.nextResult(iterator, resultParameterProcessor);
    }
}
