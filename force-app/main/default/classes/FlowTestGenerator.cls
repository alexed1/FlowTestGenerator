public with sharing class FlowTestGenerator {
    @InvocableMethod
    public static List<Result> generateTestClass(List<Request> requestList) {
        List<Result> responseWrapper = new List<Result>();
        for (Request req : requestList) {
            String flowTestId = req.flowTestId;
            Flow_Test__c curFlowTest = [SELECT Id, Name, Apex_Class_Name__c, Flow_Api_Name__c, Namespace__c FROM Flow_Test__c WHERE Id = :flowTestId];
            List<Flow_Test_Method_Assertion__c> assertions = [SELECT Id, Error_Message__c, Assertion_Formula__c FROM Flow_Test_Method_Assertion__c WHERE Flow_Test__c = :flowTestId];
            List<Flow_Test_Method_Input_Variable__c> inputVariables = [SELECT Id, Type__c, Value__c, Name FROM Flow_Test_Method_Input_Variable__c WHERE Flow_Test__c = :flowTestId];
            List<GetFlowVariables.Result> flowVariablesResult = GetFlowVariables.get(new List<GetFlowVariables.Request>{
                    new GetFlowVariables.Request(curFlowTest.Flow_Api_Name__c)
            });
            if (flowVariablesResult == null || flowVariablesResult.isEmpty()) {
                throw new InvocableActionException('Flow does not have any variables');
            }
            Map<String, String> outputVariablesToTypeMap = new Map<String, String>();
            for (FlowVariable fv : flowVariablesResult[0].flowVariables) {
                outputVariablesToTypeMap.put(fv.ApiName, fv.DataType);
            }

            String finalTestClassText = TEST_CLASS_STRING.replaceAll(PLACEHOLDER_TEST_CLASS_NAME, escapeSingleQuotes(curFlowTest.Flow_Api_Name__c) + '_Test');

            String testMethodText = TEST_METHOD_STRING;
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_TEST_METHOD_NAME, escapeSingleQuotes(curFlowTest.Name));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_NAME, escapeSingleQuotes(curFlowTest.Flow_Api_Name__c));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_NAMESPACE, escapeSingleQuotes(curFlowTest.Namespace__c == null ? '' : curFlowTest.Namespace__c));

            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_INPUT_VARIABLES, mapToApexString(generateSObjectMapByKeysAndValues(inputVariables, 'Name', 'Value__c')));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_OUTPUT_VARIABLES, mapToApexString(outputVariablesToTypeMap));
            testMethodText = testMethodText.replaceAll(PLACEHOLDER_FLOW_ASSERTION_ERROR_MAP, mapToApexString(generateSObjectMapByKeysAndValues(assertions, 'Assertion_Formula__c', 'Error_Message__c')));
            finalTestClassText += testMethodText;


            finalTestClassText += '\n}';
            try {
                DeployApexClass.deploy(finalTestClassText, curFlowTest.Flow_Api_Name__c + '_Test', null);
                responseWrapper.add(new Result(finalTestClassText.escapeHtml4(), false, null));
                System.debug('finalTestClassText:::\n' + finalTestClassText);
            } catch (Exception ex) {
                responseWrapper.add(new Result(null, true, 'Error Deploying the test class: \n' + ex.getMessage() + '; ' + ex.getStackTraceString()));
            }

        }
        return responseWrapper;
    }


    public class Request {
        @InvocableVariable
        public String flowTestId;
    }

    public class Result {
        @InvocableVariable
        public String testClassText;
        @InvocableVariable
        public Boolean isError;
        @InvocableVariable
        public String errorMessage;
        public Result() {

        }
        public Result(String testClassText, Boolean isError, String errorMessage) {
            this.testClassText = testClassText;
            this.isError = isError;
            this.errorMessage = errorMessage;
        }
    }


    public static Map<String, String> generateSObjectMapByKeysAndValues(List<SObject> sourceObjects, String keyField, String valueField) {
        Map<String, String> results = new Map<String, String>();
        for (SObject so : sourceObjects) {
            if (!results.containsKey((String) so.get(keyField))) {
                results.put((String) so.get(keyField), (String) so.get(valueField));
            }
        }
        return results;
    }

    public class InvocableActionException extends Exception {
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
        if (val == null) {
            return val;
        }
        return String.escapeSingleQuotes(String.escapeSingleQuotes(val));
    }

    public class TestClassData {
        String testMethodName;
        Map<String, String> inputVariablesMap;
        Map<String, String> outputVariablesToTypeMap;
        Map<String, String> assertionsMap;
    }

    public static Map<String, Object> getTypedInputVariablesMap(Map<String, String> outputVariablesToTypeMap, Map<String, String> inputVariables) {
        Map<String, Object> result = new Map<String, Object>();
        for (String curVariableName : inputVariables.keySet()) {
            String curVariableType = outputVariablesToTypeMap.get(curVariableName);
            if (curVariableType == 'Date') {
                //DateTime is given in the following format: 2020-09-07, we need to convert it so it can be parsed with Date.valueOf
                String dateString = inputVariables.get(curVariableName) + ' 00:00:00';
                Datetime dt = Datetime.valueOf(dateString);
                result.put(curVariableName, dt);
            } else if (curVariableType == 'DateTime') {
                //DateTime is given in the following format: 2020-09-07T00:00:00Z, we need to convert it so it can be parsed with Datetime.valueOf
                String dateTimeString = inputVariables.get(curVariableName).replace('T', ' ');
                result.put(curVariableName, DateTime.valueOf(dateTimeString));
            } else if (curVariableType == 'Number') {
                result.put(curVariableName, Decimal.valueOf(inputVariables.get(curVariableName)));
            } else {
                result.put(curVariableName, String.valueOf(inputVariables.get(curVariableName)));
            }
        }

        return result;
    }

    public static String getFormattedValue(Object value, String dataType) {

        if (value == null) {
            return '';
        }
        String result;
        if (dataType == 'DateTime') {
            DateTime curDate = DateTime.valueOf(value);
            result = 'DATETIME("' + curDate.format('yyyy-MM-dd\'T\'HH:mm:ss') + '")';
        } else if (dataType == 'Date') {
            DateTime curDate = DateTime.valueOf(String.valueOf(value));
            result = 'DATE(' + curDate.year() + ',' + curDate.month() + ',' + curDate.day() + ')';
        } else if (dataType == 'Number') {
            result = 'DECIMAL("' + String.valueOf(value) + '")';
        } else {
            result = 'TEXT("' + String.valueOf(value) + '")';
        }

        return result;
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
                    '        Map<String, Object> typedInputVariablesMap = FlowTestGenerator.getTypedInputVariablesMap(outputVariablesToTypeMap, inputVariables);\n' +
                    '        Map<String, String> assertionsToErrorMap = new Map<String, String>' +
                    '{{{assertionsToErrorMap}}};// map of assertion to its error message\n' +
                    '\n' +
                    '        Map<String, Object> outputVariables = new Map<String, Object>(); //stores output variables and its values\n' +
                    '\n' +
                    '        Flow.Interview curInterview = Flow.Interview.createInterview(namespace, flowName, typedInputVariablesMap);\n' +
                    '        curInterview.start();\n' +
                    '\n' +
                    '        for (String curOutputVariable : outputVariablesToTypeMap.keySet()) {\n' +
                    '            outputVariables.put(curOutputVariable, curInterview.getVariableValue(curOutputVariable));\n' +
                    '        }\n' +
                    '\n' +
                    '        for (String curAssertion : assertionsToErrorMap.keySet()) {\n' +
                    '            String errorMessage = assertionsToErrorMap.get(curAssertion);\n' +
                    '            for (String curOutputVarName : outputVariablesToTypeMap.keySet()) {\n' +
                    '               if (curAssertion.contains(\'##\' + curOutputVarName)) {\n' +
                    '                   curAssertion = curAssertion.replaceAll(\'##\' + curOutputVarName+\' \', FlowTestGenerator.getFormattedValue(outputVariables.get(curOutputVarName), outputVariablesToTypeMap.get(curOutputVarName)));\n' +
                    '               }\n' +
                    '            }\n' +
                    '\n' +
                    '            System.assertEquals(true, Boolean.valueOf(FormulaEvaluator.parseFormula(curAssertion, null)), errorMessage);\n' +
                    '        }\n' +
                    '\t}' ;
}