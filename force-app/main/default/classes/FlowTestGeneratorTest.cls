@IsTest
class FlowTestGeneratorTest {
    @IsTest
    static void flowTestMethod() {
        Flow_Test__c flowTest = new Flow_Test__c(Name = 'Test FLow', Flow_API_Name__c = 'TestFlow_SimpleAutolaunched');
        insert flowTest;

        Flow_Test_Method_Assertion__c flowTestMethodAssertion = new Flow_Test_Method_Assertion__c(
            Name = 'TestFlowTestMethodAssertion', 
            Flow_Test__c = flowTest.Id,
            Assertion_Formula__c = '##inputOutputDate == DATETIME("2021-07-13")',
            Error_Message__c = 'error'
            );
        insert flowTestMethodAssertion;

        Flow_Test_Method_Input_Variable__c flowTestMethodInputVariable = new Flow_Test_Method_Input_Variable__c(
            Name = 'inputOutputDate', 
            Flow_Test__c = flowTest.Id,
            Value__c = '2021-07-13',
            Type__c = 'date'
            );
        insert flowTestMethodInputVariable;


        FlowTestGenerator.Request request = new FlowTestGenerator.Request();
        request.flowTestId = flowTest.Id;

        FlowTestGenerator.Result result = FlowTestGenerator.generateTestClass(new List<FlowTestGenerator.Request> {request})[0];
        System.assert(String.isNotEmpty(result.testClassText));

        System.assert(result.testClassName == 'TestFlow_SimpleAutolaunched_Test');
    }

    @isTest
    static void getTypedInputVariablesMapTest() {
        String nameSpace = '';
        String flowName = 'TestFlow_SimpleAutolaunched';
        Map<String, String> outputVariablesToTypeMap = new Map<String, String>{
					'inputOutputDate'=>'Date',
					'inputOutputDateTime'=>'DateTime',
					'inputOutputNumber'=>'Number',
					'inputOutputString'=>'String',
					'inputString'=>'String',
					'outputString'=>'String'
				};//set of all output variables that are used in the assertions
        Map<String, String> inputVariables = new Map<String, String>{
					'inputOutputDate'=>'2021-08-03',
					'inputOutputDateTime'=>'2021-08-03T14:07:00.000Z',
					'inputOutputNumber'=>'2'
				}; //values for input variables
        Map<String, Object> typedInputVariablesMap = FlowTestGenerator.getTypedInputVariablesMap(outputVariablesToTypeMap, inputVariables);
        Map<String, String> assertionsToErrorMap = new Map<String, String>{
					'AND(##inputOutputDate == DATETIME("2021-08-03"), ##inputOutputDateTime == DATETIME("2021-08-03T14:07:00.000Z"), ##inputOutputNumber == DECIMAL("2"))'=>'error'
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

            System.assertEquals(true, Boolean.valueOf(usf.FormulaEvaluator.parseFormula(curAssertion, null)), errorMessage+ '\nActual output values: \n' + outputVariables);
        }

        System.assert(typedInputVariablesMap.get('inputOutputDate') != null);
        System.assert(typedInputVariablesMap.get('inputOutputDate') instanceof Datetime);
    }
}