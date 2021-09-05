@isTest
public with sharing class AssembleInputParamsTest {
    @isTest
    static void testExecute() {
        List<AssembleInputParams.Requests> requestList = new List<AssembleInputParams.Requests>();
        AssembleInputParams.Requests request = new AssembleInputParams.Requests();
        request.param1Key = 'param1Key';
        request.param1Value = 'param1Value';
        request.param2Key = 'param2Key';
        request.param2Value = 'param2Value';
        request.param3Key = 'param3Key';
        request.param3Value = 'param3Value';
        request.param4Key = 'param4Key';
        request.param4Value = 'param4Value';
        requestList.add(request);
        List<AssembleInputParams.Results> results = AssembleInputParams.execute(requestList);
        String resultJSON = 
        '[' +
            '{' +
                '"value":"param1Value",' + 
                '"name":"param1Key"' +
            '},' +
            '{' +
                '"value":"param2Value",' + 
                '"name":"param2Key"' +
            '},' +
            '{' +
                '"value":"param3Value",' + 
                '"name":"param3Key"' +
            '},' +
            '{' +
                '"value":"param4Value",' + 
                '"name":"param4Key"' +
            '}' +
        ']';
        System.assertEquals(resultJSON, results[0].jsonParams);
    }
}
