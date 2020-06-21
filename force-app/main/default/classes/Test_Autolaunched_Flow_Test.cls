@IsTest
class Test_Autolaunched_Flow_Test {
    @IsTest
    static void TestMyAutolaunchedFlow() {
        String nameSpace = '';
        String flowName = 'Test_Autolaunched_Flow';
        Map<String, String> outputVariablesToTypeMap = new Map<String, String>{
                'inputOutputDate'=>'Date',
                'inputOutputDateTime'=>'DateTime',
                'inputOutputNumber'=>'Number',
                'inputOutputString'=>'String',
                'inputString'=>'String',
                'outputString'=>'String'
        };//set of all output variables that are used in the assertions
        Map<String, String> inputVariables = new Map<String, String>{
                'inputOutputDate'=>'2020-06-07',
                'inputOutputDateTime'=>'2020-06-08T12:00:00.000Z',
                'inputOutputNumber'=>'1',
                'inputOutputString'=>'thisIsString with spaces'
        }; //values for input variables
        Map<String, Object> typedInputVariablesMap = FlowTestGenerator.getTypedInputVariablesMap(outputVariablesToTypeMap, inputVariables);
        Map<String, String> assertionsToErrorMap = new Map<String, String>{
                'AND(##inputOutputNumber == DECIMAL("1"), ##inputOutputString == TEXT("thisIsString with spaces"), ##inputOutputDate == DATETIME("2020-06-07T00:00:00"), ##inputOutputDateTime == DATETIME("2020-06-08T12:00:00"))'=>'Invalid output parameters'
        };// map of assertion to its error message

        Map<String, Object> outputVariables = new Map<String, Object>(); //stores output variables and its values

        Flow.Interview curInterview = Flow.Interview.createInterview(namespace, flowName, typedInputVariablesMap);
        curInterview.start();

        for (String curOutputVariable : outputVariablesToTypeMap.keySet()) {
            outputVariables.put(curOutputVariable, curInterview.getVariableValue(curOutputVariable));
        }

        for (String curAssertion : assertionsToErrorMap.keySet()) {
            String errorMessage = assertionsToErrorMap.get(curAssertion);
            for (String curOutputVarName : outputVariablesToTypeMap.keySet()) {
                if (curAssertion.contains('##' + curOutputVarName)) {
                    curAssertion = curAssertion.replaceAll('##' + curOutputVarName+' ', FlowTestGenerator.getFormattedValue(outputVariables.get(curOutputVarName), outputVariablesToTypeMap.get(curOutputVarName)));
                }
            }

            System.assertEquals(true, Boolean.valueOf(FormulaEvaluator.parseFormula(curAssertion, null)), errorMessage);
        }
    }
}