@isTest
public with sharing class CountRecordsAndFieldsTest {
    @isTest
    static void testCount() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        List<CountRecordsAndFields.Requests> requestList = new List<CountRecordsAndFields.Requests>();
        CountRecordsAndFields.Requests request = new CountRecordsAndFields.Requests();
        List<SObject> sobjects = new List<SObject>{testAcc};
        request.inputCollection = sobjects;
        request.fieldName = 'Name';
        request.fieldValue = 'Test Account';
        requestList.add(request);
        List<CountRecordsAndFields.Results> results = CountRecordsAndFields.count(requestList);
        System.assertEquals(1, results[0].matchedNumber);
        System.assertEquals(1, results[0].totalNumber);
    }
}
