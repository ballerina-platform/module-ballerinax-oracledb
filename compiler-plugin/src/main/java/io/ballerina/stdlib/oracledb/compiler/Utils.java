/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.stdlib.oracledb.compiler;

import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.BasicLiteralNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingConstructorExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingFieldNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SpecificFieldNode;
import io.ballerina.compiler.syntax.tree.UnaryExpressionNode;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.util.Optional;

import static io.ballerina.stdlib.oracledb.compiler.Constants.UNNECESSARY_CHARS_REGEX;
import static io.ballerina.stdlib.oracledb.compiler.OracleDBDiagnosticsCode.ORACLEDB_101;
import static io.ballerina.stdlib.oracledb.compiler.OracleDBDiagnosticsCode.ORACLEDB_201;
import static io.ballerina.stdlib.oracledb.compiler.OracleDBDiagnosticsCode.ORACLEDB_202;

/**
 * Utils class.
 */
public class Utils {

    private Utils() {
    }

    public static boolean hasCompilationErrors(SyntaxNodeAnalysisContext ctx) {
        for (Diagnostic diagnostic : ctx.compilation().diagnosticResult().diagnostics()) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                return true;
            }
        }
        return false;
    }

    public static boolean isOracleDBObject(SyntaxNodeAnalysisContext ctx, ExpressionNode node, String matchName) {
        Optional<TypeSymbol> objectType = ctx.semanticModel().typeOf(node);
        if (objectType.isEmpty()) {
            return false;
        }
        if (objectType.get().typeKind() == TypeDescKind.UNION) {
            return ((UnionTypeSymbol) objectType.get()).memberTypeDescriptors().stream()
                    .filter(typeDescriptor -> typeDescriptor instanceof TypeReferenceTypeSymbol)
                    .map(typeReferenceTypeSymbol -> (TypeReferenceTypeSymbol) typeReferenceTypeSymbol)
                    .anyMatch(typeRef -> Utils.isOracleDBObject(typeRef, matchName));
        }
        if (objectType.get() instanceof TypeReferenceTypeSymbol) {
            return isOracleDBObject(((TypeReferenceTypeSymbol) objectType.get()), matchName);
        }
        return false;
    }

    public static boolean isOracleDBObject(TypeReferenceTypeSymbol typeReference, String matchName) {
        Optional<ModuleSymbol> optionalModuleSymbol = typeReference.getModule();
        if (optionalModuleSymbol.isEmpty()) {
            return false;
        }
        ModuleSymbol module = optionalModuleSymbol.get();
        if (!(module.id().orgName().equals(Constants.BALLERINAX) &&
                module.id().moduleName().equals(Constants.ORACLEDB))) {
            return false;
        }
        String objectName = typeReference.definition().getName().get();
        switch (matchName) {
            case Constants.Client.NAME:
                return objectName.equals(Constants.Client.NAME);
            case Constants.OUT_PARAMETER_POSTFIX:
                return objectName.endsWith(Constants.OUT_PARAMETER_POSTFIX);
            default:
                return false;
        }
    }

    public static void validateOptions(SyntaxNodeAnalysisContext ctx, MappingConstructorExpressionNode options) {
        SeparatedNodeList<MappingFieldNode> fields = options.fields();
        for (MappingFieldNode field : fields) {
            String name = ((SpecificFieldNode) field).fieldName().toString()
                    .trim().replaceAll(UNNECESSARY_CHARS_REGEX, "");
            ExpressionNode valueNode = ((SpecificFieldNode) field).valueExpr().get();
            switch (name) {
                case Constants.Options.CONNECT_TIMEOUT:
                case Constants.Options.LOGIN_TIMEOUT:
                case Constants.Options.SOCKET_TIMEOUT:
                    float timeoutVal = Float.parseFloat(getTerminalNodeValue(valueNode, "0"));
                    if (timeoutVal < 0) {
                        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(ORACLEDB_101.getCode(),
                                ORACLEDB_101.getMessage(), ORACLEDB_101.getSeverity());
                        ctx.reportDiagnostic(
                                DiagnosticFactory.createDiagnostic(diagnosticInfo, valueNode.location()));
                    }
                    break;
                default:
                    // Can ignore all the other fields
                    continue;
            }
        }
    }

    public static String getTerminalNodeValue(Node valueNode, String defaultValue) {
        String value = defaultValue;
        if (valueNode instanceof BasicLiteralNode) {
            value = ((BasicLiteralNode) valueNode).literalToken().text();
        } else if (valueNode instanceof UnaryExpressionNode) {
            UnaryExpressionNode unaryExpressionNode = (UnaryExpressionNode) valueNode;
            value = unaryExpressionNode.unaryOperator() +
                    ((BasicLiteralNode) unaryExpressionNode.expression()).literalToken().text();
        }
        // Currently, we cannot process values from variables, this needs code flow analysis
        return value.replaceAll(UNNECESSARY_CHARS_REGEX, "");
    }

    public static DiagnosticInfo addDiagnosticsForInvalidTypes(String objectName, TypeDescKind requestedReturnType) {
        switch(objectName) {
            case Constants.OutParameter.INTERVAL_DAY_TO_SECOND:
            case Constants.OutParameter.INTERVAL_YEAR_TO_MONTH:
                // todo Verify needed specific record type
                if (requestedReturnType == TypeDescKind.RECORD ||
                        requestedReturnType == TypeDescKind.OBJECT) {
                    return null;
                }
                return new DiagnosticInfo(ORACLEDB_201.getCode(), ORACLEDB_201.getMessage(),
                        ORACLEDB_201.getSeverity());
            case Constants.OutParameter.XML:
                if (requestedReturnType == TypeDescKind.XML) {
                    return null;
                }
                return new DiagnosticInfo(ORACLEDB_202.getCode(), ORACLEDB_202.getMessage(),
                        ORACLEDB_202.getSeverity());
            default:
                return null;
        }
    }
}
