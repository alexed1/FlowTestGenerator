@isTest
public with sharing class GetFlowVariablesTest {

    @isTest
    public static void CanGetVariables() {
        List<GetFlowVariables.Request> requestList = new List<GetFlowVariables.Request>();
        GetFlowVariables.Request request = new GetFlowVariables.Request();
    
        request.flowName = 'TestFlow_SimpleAutolaunched';
        requestList.add(request);
        List<GetFlowVariables.Result> resultList = GetFlowVariables.get(requestList);
        System.assertNotEquals(null, resultList);
    
    }
    
}
