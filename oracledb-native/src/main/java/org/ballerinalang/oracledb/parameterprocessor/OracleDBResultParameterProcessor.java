package org.ballerinalang.oracledb.parameterprocessor;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

/**
 * This class overrides DefaultResultParameterProcessor to implement methods required convert SQL types into
 * ballerina types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class OracleDBResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final Object lock = new Object();
    private static volatile OracleDBResultParameterProcessor instance;

    public static OracleDBResultParameterProcessor getInstance() {
        if (instance == null) {
            synchronized (lock) {
                if (instance == null) {
                    instance = new OracleDBResultParameterProcessor();
                }
            }
        }
        return instance;
    }
}
