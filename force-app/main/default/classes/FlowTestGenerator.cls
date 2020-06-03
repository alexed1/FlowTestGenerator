public with sharing class FlowTestGenerator {
    @AuraEnabled
    public static void generateTestClass(String nameSpace, String flowName, String testClassDataListJSON) {
        List<TestClassData> testClassData = (List<TestClassData>) JSON.deserialize(testClassDataListJSON, List<TestClassData>.class);
        System.debug('testClassData:::' + testClassData);
        String finalTestClassText = TEST_CLASS_STRING.replaceAll(PLACEHOLDER_TEST_CLASS_NAME, escapeSingleQuotes(flowName) + '_Test');
        for (TestClassData curTCD : testClassData) {
            String testMethodText = TEST_METHOD_STRING;
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_TEST_METHOD_NAME, escapeSingleQuotes(curTCD.testMethodName));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_NAME, escapeSingleQuotes(flowName));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_NAMESPACE, escapeSingleQuotes(nameSpace));

            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_INPUT_VARIABLES, mapToApexString(curTCD.inputVariablesMap));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_OUTPUT_VARIABLES, mapToApexString(curTCD.outputVariablesToTypeMap));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_ASSERTION_ERROR_MAP, mapToApexString(curTCD.assertionsMap));
            finalTestClassText += testMethodText;

        }
        finalTestClassText += '\n}';
        DeployApexClass.deploy(finalTestClassText, flowName + '_Test', null);
        System.debug('finalTestClassText:::\n' + finalTestClassText);
    }

    private static String mapToApexString(Map<String, String> sourceMap) {
        String result = '{\n';
        Integer i = 0;
        for (String curKey : sourceMap.keySet()) {
            i++;
            result += '\t\t\t\t\t\'' + escapeSingleQuotes(curKey) + '\'=>\'' + escapeSingleQuotes(sourceMap.get(curKey)) + '\'' + (i == sourceMap.size() ? '' : ',') + '\n';
        }
        result += '\t\t\t\t}';
        return result;
    }

    private static String escapeSingleQuotes(String val) {
        return String.escapeSingleQuotes(String.escapeSingleQuotes(val));
    }

    public class TestClassData {
        String testMethodName;
        Map<String, String> inputVariablesMap;
        Map<String, String> outputVariablesToTypeMap;
        Map<String, String> assertionsMap;
    }

    private static final String PLACEHOLDER_TEST_CLASS_NAME = '\\{\\{\\{TestClassName\\}\\}\\}';
    private static final String PLACEHOLDER_TEST_METHOD_NAME = '\\{\\{\\{TestClassMethod\\}\\}\\}';
    private static final String PLACEHOLDER_FLOW_NAME = '\\{\\{\\{FlowName\\}\\}\\}';
    private static final String PLACEHOLDER_FLOW_NAMESPACE = '\\{\\{\\{NameSpace\\}\\}\\}';
    private static final String PLACEHOLDER_FLOW_INPUT_VARIABLES = '\\{\\{\\{inputVariables\\}\\}\\}';
    private static final String PLACEHOLDER_FLOW_OUTPUT_VARIABLES = '\\{\\{\\{outputVariablesToTypeMap\\}\\}\\}';
    private static final String PLACEHOLDER_FLOW_ASSERTION_ERROR_MAP = '\\{\\{\\{assertionsToErrorMap\\}\\}\\}';
    private static final String TEST_CLASS_STRING = '@IsTest\n' +
            'class {{{TestClassName}}} {\n';
    private static final String TEST_METHOD_STRING =
            '    @IsTest\n' +
                    '    static void {{{TestClassMethod}}}() {\n' +
                    '        String nameSpace = \'{{{NameSpace}}}\';\n' +
                    '        String flowName = \'{{{FlowName}}}\';\n' +
                    '        Map<String, String> outputVariablesToTypeMap = new Map<String, String>' +
                    '{{{outputVariablesToTypeMap}}};//set of all output variables that are used in the assertions\n' +
                    '        Map<String, String> inputVariables = new Map<String, String>' +
                    '{{{inputVariables}}}; //values for input variables\n' +
                    '        Map<String, String> assertionsToErrorMap = new Map<String, String>' +
                    '{{{assertionsToErrorMap}}};// map of assertion to its error message\n' +
                    '\n' +
                    '        Map<String, Object> outputVariables = new Map<String, Object>(); //stores output variables and its values\n' +
                    '\n' +
                    '        Flow.Interview curInterview = Flow.Interview.createInterview(namespace, flowName, inputVariables);\n' +
                    '        curInterview.start();\n' +
                    '\n' +
                    '        for (String curOutputVariable : outputVariablesToTypeMap.keySet()) {\n' +
                    '            outputVariables.put(curOutputVariable, curInterview.getVariableValue(curOutputVariable));\n' +
                    '        }\n' +
                    '\n' +
                    '        for (String curAssertion : assertionsToErrorMap.keySet()) {\n' +
                    '            String errorMessage = assertionsToErrorMap.get(curAssertion);\n' +
                    '            for (String curOutputVarName : outputVariablesToTypeMap.keySet()) {\n' +
                    '                curAssertion = curAssertion.replaceAll(\'##\' + curOutputVarName, \'"\'+(String)outputVariables.get(curOutputVarName)+\'"\');\n' +
                    '            }\n' +
                    '\n' +
                    '            System.assertEquals(true, Boolean.valueOf(FormulaEvaluator.parseFormula(curAssertion, null)), errorMessage);\n' +
                    '        }\n' +
                    '\t}' ;
}