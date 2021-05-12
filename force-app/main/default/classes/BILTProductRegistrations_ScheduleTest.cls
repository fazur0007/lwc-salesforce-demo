@isTest
private class BILTProductRegistrations_ScheduleTest {
    @isTest
    private static void testFetchAndSaveProductRegistrations() {
        Test.setMock(HttpCalloutMock.class, new BILTUtilityTest.BILTApiMock(BILTUtilityTest.API.Registrations));
        Test.startTest();
        BILTProductRegistrations_Schedule.fetchAndSaveProductRegistrations();
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM Account].size());
        System.assertEquals(2, [SELECT Id FROM Asset].size());
    }
    
    @isTest
    private static void testScheduledJob() {
        Test.setMock(HttpCalloutMock.class, new BILTUtilityTest.BILTApiMock(BILTUtilityTest.API.Registrations));
        Test.startTest();
        String jobId = System.schedule('BILT scheduled job', '0 0 * * * ?', new BILTProductRegistrations_Schedule());
        Test.stopTest();
    }
    
    @TestSetup
    static void makeData(){
        TestObjects t = new TestObjects();
        Account acc = new Account();
        acc.ShippingPostalCode = 'Test111';
        acc.BillingStreet = '1234 E Main st';
        acc.FirstName = 'Test1';
        acc.LastName = 'LastName';
        acc.PersonEmail = 'test@test.com';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Product2 prod = t.getProduct(false);
        prod.Brand__c = 'Breville';
        prod.Name = 'BES450';
        prod.Finished_Good__c = true;
        prod.Spare_Part__c = false ;
        prod.Accessory__c = false;
        prod.IsActive = true;
        prod.Product_Type__c = 'FG';
        insert prod;
    }
}