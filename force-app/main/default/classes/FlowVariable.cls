public with sharing class FlowVariable {
    
    @AuraEnabled
    public string ApiName;

    @AuraEnabled
    public string DataType;

    @AuraEnabled
    public string Description;

    @AuraEnabled
    public string DurableId;

    @AuraEnabled
    public string FlowVersionViewId;

    @AuraEnabled
    public Boolean IsCollection;

    @AuraEnabled
    public Boolean IsOutput;

    @AuraEnabled
    public Boolean IsInput;

    @AuraEnabled
    public string ObjectType;

    //used to temporarily store serialized values to be used as test inputs
    @AuraEnabled
    public string TestValue;
}
