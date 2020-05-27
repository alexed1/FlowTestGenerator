public with sharing class FlowVariableSet {

    public FlowVariableSet() {
        variables = new List<FlowVariable>();
    }
   
    @AuraEnabled
    public  List<FlowVariable> variables;
        
    
}
