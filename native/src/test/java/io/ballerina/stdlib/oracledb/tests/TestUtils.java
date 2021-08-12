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

package io.ballerina.stdlib.oracledb.tests;

import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BFuture;
import io.ballerina.runtime.api.values.BLink;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BValue;
import io.ballerina.runtime.internal.scheduling.Strand;

import java.util.HashMap;
import java.util.Map;

/**
 * TestUtils class for testing ballerina native classes/methods.
 */
public class TestUtils {

    private static Module emptyModule = new Module(null, null, null);

    public static BObject getMockObject(String name) {
        return new BObject() {
            HashMap<String, Object> nativeData = new HashMap<>();

            @Override
            public Object call(Strand strand, String s, Object... objects) {
                return null;
            }

            @Override
            public BFuture start(Strand strand, String s, Object... objects) {
                return null;
            }

            @Override
            public ObjectType getType() {
                return TypeCreator.createObjectType(name, emptyModule, 0);
            }

            @Override
            public Object get(BString bString) {
                return null;
            }

            @Override
            public long getIntValue(BString bString) {
                return 0;
            }

            @Override
            public double getFloatValue(BString bString) {
                return 0;
            }

            @Override
            public BString getStringValue(BString bString) {
                return null;
            }

            @Override
            public boolean getBooleanValue(BString bString) {
                return false;
            }

            @Override
            public BMap getMapValue(BString bString) {
                return null;
            }

            @Override
            public BObject getObjectValue(BString bString) {
                return null;
            }

            @Override
            public BArray getArrayValue(BString bString) {
                return null;
            }

            @Override
            public void addNativeData(String s, Object o) {
                nativeData.put(s, o);
            }

            @Override
            public Object getNativeData(String s) {
                return nativeData.get(s);
            }

            @Override
            public HashMap<String, Object> getNativeData() {
                return null;
            }

            @Override
            public void set(BString bString, Object o) {

            }

            @Override
            public Object copy(Map<Object, Object> map) {
                return null;
            }

            @Override
            public Object frozenCopy(Map<Object, Object> map) {
                return null;
            }

            @Override
            public String stringValue(BLink bLink) {
                return null;
            }

            @Override
            public String expressionStringValue(BLink bLink) {
                return null;
            }
        };
    }

    public static BValue getMockBValueJson() {
        return new BValue() {
            @Override
            public Object copy(Map<Object, Object> map) {
                return null;
            }

            @Override
            public Object frozenCopy(Map<Object, Object> map) {
                return null;
            }

            @Override
            public String stringValue(BLink bLink) {
                return null;
            }

            @Override
            public String expressionStringValue(BLink bLink) {
                return null;
            }

            @Override
            public Type getType() {
                return PredefinedTypes.TYPE_JSON;
            }
        };
    }
}
