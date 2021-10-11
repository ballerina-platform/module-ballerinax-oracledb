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
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.oracledb.Constants;
import io.ballerina.stdlib.sql.exception.ApplicationError;
import io.ballerina.stdlib.sql.utils.ErrorGenerator;
import oracle.jdbc.OracleBfile;

import java.io.InputStream;
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
            Object bfileObj = bFileMap.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
            if (bfileObj instanceof OracleBfile) {
                OracleBfile bfile = (OracleBfile) bfileObj;
                return bfile.fileExists();
            } else {
                return false;
            }
        } catch (SQLException ignore) {
            return false;
        }
    }

    public static Object bfileReadBytes(BMap<BString, Object> bFileMap) {
        if (isBFileExists(bFileMap)) {
            Object bfileObj = bFileMap.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
            OracleBfile bfile = (OracleBfile) bfileObj;
            byte[] bytes;
            try {
                bfile.openFile();
                bytes = bfile.getBytes(1L, (int) bfile.length());
            } catch (SQLException ex) {
                return ErrorGenerator.
                        getSQLApplicationError(new ApplicationError("Error occurred when reading the BFile.", ex));
            } finally {
                try {
                    bfile.closeFile();
                } catch (SQLException ex) {
                    return ErrorGenerator.
                            getSQLApplicationError(new ApplicationError("Error occurred when closing the BFile.", ex));
                }
            }
            return ValueCreator.createArrayValue(bytes);
        } else {
            return ErrorGenerator.getSQLApplicationError(String.format("Provided BFile: %s does not contain a " +
                                "pointer or contains an invalid pointer to a remote file. Hence can not perform any " +
                                "read operations on it",
                        bFileMap.getStringValue(StringUtils.fromString(Constants.Types.BFile.NAME))));
        }
    }

    public static Object bfileReadBlockAsStream(BMap<BString, Object> bFileMap, int bufferSize) {
        if (isBFileExists(bFileMap)) {
            try {
                Object bfileObj = bFileMap.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
                BObject bFileIterator = ValueCreator.createObjectValue(ModuleUtils.getModule(),
                        Constants.BFILE_ITERATOR_OBJECT, bufferSize, ((OracleBfile) bfileObj).length());
                bFileIterator.addNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD, bfileObj);
                OracleBfile bFile =  (OracleBfile) bfileObj;
                bFile.openFile();
                bFileIterator.addNativeData(Constants.ORACLEBFILE_STREAM_DATA_FIELD, bFile.getBinaryStream());
                return ValueCreator.createStreamValue(TypeCreator.createStreamType(
                        TypeCreator.createArrayType(PredefinedTypes.TYPE_BYTE),
                        TypeCreator.createUnionType(PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL)),
                        bFileIterator);
            } catch (SQLException ex) {
                return ErrorGenerator.getSQLError(ex, "Error while creating the stream. ");
            }
        } else {
            SQLException ex = new SQLException(String.format("Provided BFile: %s does not contain a pointer or " +
                            "contains an invalid pointer to a remote file. Hence can not create a stream from it.",
                    bFileMap.getStringValue(StringUtils.fromString(Constants.Types.BFile.NAME))));
            return ErrorGenerator.getSQLError(ex, "Error while creating the stream. ");
        }
    }

    public static Object getBytes(BObject bFileIterator) {
        long position = bFileIterator.getIntValue(StringUtils.fromString(Constants.Types.BFile.POSITION));
        long bufferSize = bFileIterator.getIntValue(StringUtils.fromString(Constants.Types.BFile.BUFFER_SIZE));
        long fileLength = bFileIterator.getIntValue(StringUtils.fromString(Constants.Types.BFile.FILE_LENGTH));
        InputStream inputStream = (InputStream) bFileIterator.getNativeData(Constants.ORACLEBFILE_STREAM_DATA_FIELD);
        byte[] buffer = new byte[(int) bufferSize];
        try {
            int length = inputStream.read(buffer);
            if (length == -1) {
                position = fileLength + 1;
                buffer = new byte[0];
            } else if (length < bufferSize) {
                position = fileLength + 1;
                byte[] array = new byte[length];
                System.arraycopy(buffer, 0, array, 0, length);
                buffer = array;
            } else {
                position += length;
            }
            bFileIterator.set(StringUtils.fromString(Constants.Types.BFile.POSITION), position);
            return ValueCreator.createArrayValue(buffer);
        } catch (Exception ex) {
            return ErrorGenerator.
                    getSQLApplicationError(new ApplicationError("Error occurred when reading the BFile.", ex));
        }
    }

    public static Object closeBFile(BObject bFileIterator) {
        OracleBfile bfile = (OracleBfile) bFileIterator.getNativeData(Constants.ORACLEBFILE_NATIVE_DATA_FIELD);
        InputStream inputStream = (InputStream) bFileIterator.getNativeData(Constants.ORACLEBFILE_STREAM_DATA_FIELD);
        try {
            inputStream.close();
            bfile.closeFile();
            return null;
        } catch (Exception ex) {
            return ErrorGenerator.
                    getSQLApplicationError(new ApplicationError("Error occurred when closing the BFile.", ex));
        }
    }

}
