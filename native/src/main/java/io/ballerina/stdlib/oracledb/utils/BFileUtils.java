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

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.sql.exception.ApplicationError;
import io.ballerina.stdlib.sql.utils.ErrorGenerator;
import oracle.jdbc.OracleBfile;

import java.sql.SQLException;

/**
 * Utility functions relevant to BFILE operations.
 *
 * @since 1.0.0
 */
public class BFileUtils {
    private BFileUtils() {}

    public static boolean isBFileExists(BMap<BString, Object> bFileMap) {
        try {
            OracleBfile bfile = (OracleBfile) bFileMap.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
            return bfile.fileExists();
        } catch (SQLException | NullPointerException ignore) {
            return false;
        }
    }

    public static Object bfileReadBytes(BMap<BString, Object> bFileMap) {
        try {
            Object bfileObj = bFileMap.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
            if (bfileObj instanceof OracleBfile) {
                OracleBfile bfile = (OracleBfile) bfileObj;
                bfile.openFile();
                byte[] bytes = bfile.getBytes(1L, (int) bfile.length());
                bfile.closeFile();
                return ValueCreator.createArrayValue(bytes);
            } else {
                return ErrorGenerator.getSQLApplicationError(String.format("Provided BFile: %s does not contain a " +
                                "pointer or contains an invalid pointer to a remote file. Hence can not perform any " +
                                "read operations on it",
                        bFileMap.getStringValue(StringUtils.fromString(Constants.Types.BFile.NAME))));
            }
        } catch (SQLException ex) {
            return ErrorGenerator.
                    getSQLApplicationError(new ApplicationError("Error occurred when reading the BFile.", ex));
        }
    }

    public static BStream bfileReadBlockAsStream(BMap<BString, Object> bFileMap, int bufferSize) {
        try {
            Object bfileObj = bFileMap.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
            if (bfileObj instanceof OracleBfile && ((OracleBfile) bfileObj).fileExists()) {
                BObject bFileIterator = ValueCreator.createObjectValue(ModuleUtils.getModule(),
                        Constants.BFILE_ITERATOR_OBJECT, bufferSize, ((OracleBfile) bfileObj).length(), null);
                bFileIterator.addNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD, bfileObj);
                return ValueCreator.createStreamValue(TypeCreator.createStreamType(
                        TypeCreator.createArrayType(PredefinedTypes.TYPE_BYTE),
                        TypeCreator.createUnionType(PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL)),
                        bFileIterator);
            } else {
                SQLException ex = new SQLException(String.format("Provided BFile: %s does not contain a pointer or " +
                                "contains an invalid pointer to a remote file. Hence can not create a stream from it.",
                        bFileMap.getStringValue(StringUtils.fromString(Constants.Types.BFile.NAME))));
                BError errorValue = ErrorGenerator.getSQLError(ex, "Error while creating the stream. ");
                return getErrorStream(errorValue);
            }
        } catch (SQLException ex) {
            BError errorValue = ErrorGenerator.getSQLError(ex, "Error while creating the stream. ");
            return getErrorStream(errorValue);
        }
    }

    public static Object getBytes(BObject bFileIterator) {
        OracleBfile bfile = (OracleBfile) bFileIterator.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
        long position = bFileIterator.getIntValue(StringUtils.fromString(Constants.Types.BFile.POSITION));
        long bufferSize = bFileIterator.getIntValue(StringUtils.fromString(Constants.Types.BFile.BUFFER_SIZE));
        long fileLength = bFileIterator.getIntValue(StringUtils.fromString(Constants.Types.BFile.FILE_LENGTH));
        byte[] buffer = new byte[(int) bufferSize];
        try {
            bfile.openFile();
            int length = bfile.getBytes(position, (int) bufferSize, buffer);
            bfile.closeFile();
            if (length < bufferSize) {
                position = fileLength + 1;
                byte[] array = new byte[length];
                System.arraycopy(buffer, 0, array, 0, length);
                buffer = array;
            } else {
                position += length;
            }
            bFileIterator.set(StringUtils.fromString(Constants.Types.BFile.POSITION), position);
            return ValueCreator.createArrayValue(buffer);
        } catch (SQLException ex) {
            return ErrorGenerator.
                    getSQLApplicationError(new ApplicationError("Error occurred when reading the BFile.", ex));
        }
    }

    private static BStream getErrorStream(BError errorValue) {
        return ValueCreator.createStreamValue(TypeCreator.createStreamType(TypeCreator.
                        createArrayType(PredefinedTypes.TYPE_BYTE), TypeCreator.createUnionType(
                                PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL)), ValueCreator.
                createObjectValue(ModuleUtils.getModule(), Constants.BFILE_ITERATOR_OBJECT,  0L, 0L, errorValue));
    }
}
