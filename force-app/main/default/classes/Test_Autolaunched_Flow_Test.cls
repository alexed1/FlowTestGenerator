@IsTest
class Test_Autolaunched_Flow_Test {
    @IsTest
    static void FlowTestGeneratorTest() {
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
                'inputOutputDateTime'=>'2020-06-23T11:00:00.000Z',
                'inputOutputNumber'=>'1',
                'inputOutputString'=>'asd',
                'inputOutputDate'=>'2020-06-23'
        }; //values for input variables
        Map<String, Object> typedInputVariablesMap = FlowTestGenerator.getTypedInputVariablesMap(outputVariablesToTypeMap, inputVariables);
        Map<String, String> assertionsToErrorMap = new Map<String, String>{
                'AND(##inputOutputNumber == DECIMAL("6"), ##inputOutputDate == DATETIME("2020-06-24"), ##inputOutputDateTime == DATETIME("2020-06-23T11:00:00.000Z"), CONTAINS(##inputOutputString , TEXT("asd")), CONTAINS(##inputOutputString , TEXT("1")))'=>'tests2',
                'AND(##inputOutputString != TEXT("asd2"), ##inputOutputString == TEXT("asd1"))'=>'assertion2 failed'
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

            System.assertEquals(true, Boolean.valueOf(FormulaEvaluator.parseFormula(curAssertion, null)), errorMessage+ '\nActual output values: \n' + outputVariables);
        }
    }
}