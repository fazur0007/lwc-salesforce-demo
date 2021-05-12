@isTest
private class TroubleShootFlowMappingTriggerTest {

    static testMethod void populateProductIdTest() {
        //Unique_Field__c
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        Trouble_Shoot_Flow_Mapping__c mapRecord = TestDataFactory.createTroubleshootFlowMappingRecord(productRecord.Id, 'abc,','def','ghi','jkl');
        
        Test.startTest();
        
        insert mapRecord;
        
        Test.stopTest();
    }
}