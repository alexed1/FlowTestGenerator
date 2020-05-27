public with sharing class FlowTestDefinition {
    
    @AuraEnabled
    public List<FlowVariable>  inputValues;

    @AuraEnabled
    public List<String>  assertionExpressions;
    
    @AuraEnabled
    public string testName;
        
}
