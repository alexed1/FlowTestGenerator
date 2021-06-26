@IsTest
class FlowTestGeneratorTest {
    @IsTest
    static void flowTestMethod() {
        String nameSpace = '';
        String flowName = 'Test_Autolaunched_Flow';
        Set<String> outputVariablesNames = new Set<String>{
                'outputTextVar'
        };//set of all output variables that are used in the assertions
        Map<String, String> inputVariables = new Map<String, String>{
                'inputTextVar' => 'test input value'
        }
        ; //values for input variables
        Map<String, String> assertionsToErrorMap = new Map<String, String>{
                '"$outputTextVar" == TEXT("Changed:test input value")' => 'error'
        };// map of assertion to its error message

        Map<String, Object> outputVariables = new Map<String, Object>(); //stores output variables and its values

        Flow.Interview curInterview = Flow.Interview.createInterview(namespace, flowName, inputVariables);
        curInterview.start();

        for (String curOutputVariable : outputVariablesNames) {
            outputVariables.put(curOutputVariable, curInterview.getVariableValue(curOutputVariable));
        }

        for (String curAssertion : assertionsToErrorMap.keySet()) {
            for (String curOutputVarName : outputVariablesNames) {
                curAssertion = curAssertion.replaceAll('\\$' + curOutputVarName, (String) outputVariables.get(curOutputVarName));
            }

            System.assertEquals(true, Boolean.valueOf(usf.FormulaEvaluator.parseFormula(curAssertion, null)), assertionsToErrorMap.get(curAssertion));
        }
    }

    @IsTest
    static void Test_Autolaunched_Flow() {
        String nameSpace = '';
        String flowName = 'Test_Autolaunched_Flow';
        Map<String, String> outputVariablesToTypeMap = new Map<String, String>{
                'outputTextVar'=>'String'
        };//set of all output variables that are used in the assertions
        Map<String, String> inputVariables = new Map<String, String>{
                'inputTextVar'=>'ddd'
        }; //values for input variables
        Map<String, String> assertionsToErrorMap = new Map<String, String>{
                'CONTAINS(##outputTextVar, TEXT("ddd"))'=>'ddd tttt'
        };// map of assertion to its error message

        Map<String, Object> outputVariables = new Map<String, Object>(); //stores output variables and its values

        Flow.Interview curInterview = Flow.Interview.createInterview(namespace, flowName, inputVariables);
        curInterview.start();

        for (String curOutputVariable : outputVariablesToTypeMap.keySet()) {
            outputVariables.put(curOutputVariable, curInterview.getVariableValue(curOutputVariable));
        }

        for (String curAssertion : assertionsToErrorMap.keySet()) {
            String errorMessage = assertionsToErrorMap.get(curAssertion);
            for (String curOutputVarName : outputVariablesToTypeMap.keySet()) {
                curAssertion = curAssertion.replaceAll('##' + curOutputVarName, '"'+(String)outputVariables.get(curOutputVarName)+'"');
            }

            System.assertEquals(true, Boolean.valueOf(usf.FormulaEvaluator.parseFormula(curAssertion, null)), errorMessage);
        }
    }
}