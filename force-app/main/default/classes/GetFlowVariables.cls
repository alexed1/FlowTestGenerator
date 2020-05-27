public with sharing class GetFlowVariables {
  
    @InvocableMethod
    public static List <Result> get(List<Request> requestList) {
        Result response = new Result();
        List<Result> responseWrapper = new List<Result>();
        
        for (Request req : requestList) {
            String flowName = req.flowName;
            FlowDefinitionView curFlow = [SELECT DurableId, ApiName, Label FROM FlowDefinitionView WHERE ApiName = :flowName];
            System.debug('curFlow:  ' + curFlow);
            FlowVersionView[] curFlowVersion = [SELECT DurableId, VersionNumber, Label FROM FlowVersionView WHERE FlowDefinitionViewId = :curFlow.DurableId];
            System.debug('curFlowVersion:  ' + curFlowVersion);    
            String versionId = curFlowVersion[0].DurableId;
            List<FlowVariableView> curFlowVariables = [SELECT ApiName, DataType, Description,DurableId, IsCollection,IsInput,IsOutput,ObjectType FROM FlowVariableView WHERE FlowVersionViewId = :versionId];
            System.debug('curFlowVariables:  ' + curFlowVariables);


            response.flowVariables = new List<FlowVariable>();
            for (FlowVariableView curVariableView : curFlowVariables) {
                FlowVariable curVar = new FlowVariable();
                curVar.ApiName = curVariableView.ApiName;
                curVar.DataType = curVariableView.DataType;
                curVar.Description =   curVariableView.Description;
                curVar.DurableId = curVariableView.DurableId;
                curVar.IsCollection = curVariableView.IsCollection;
                curVar.IsInput = curVariableView.IsInput;
                curVar.IsOutput =  curVariableView.IsOutput;
                curVar.ObjectType = curVariableView.ObjectType;
                response.flowVariables.add(curVar);
            }
            
            responseWrapper.add(response);
        }
        return responseWrapper;


    }


    public class Request {

        @InvocableVariable 
        public String flowName;

    }

    public class Result {


        @InvocableVariable
        public List<FlowVariable> flowVariables;

    }
}