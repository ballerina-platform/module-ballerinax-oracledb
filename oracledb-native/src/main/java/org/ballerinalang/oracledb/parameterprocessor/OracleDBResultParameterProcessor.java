package org.ballerinalang.oracledb.parameterprocessor;

import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;

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
