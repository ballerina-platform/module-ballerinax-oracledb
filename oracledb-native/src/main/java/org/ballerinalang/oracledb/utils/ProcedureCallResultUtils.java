package org.ballerinalang.oracledb.utils;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.oracledb.parameterprocessor.OracleDBResultParameterProcessor;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

public class ProcedureCallResultUtils {

    public static Object getNextQueryResult(BObject CustomResultIterator, BObject callResult) {
        DefaultResultParameterProcessor resultParameterProcessor = OracleDBResultParameterProcessor.getInstance();
        return org.ballerinalang.sql.utils.ProcedureCallResultUtils.getNextQueryResult(callResult, resultParameterProcessor);
    }
}
