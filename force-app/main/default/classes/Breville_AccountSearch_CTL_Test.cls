@isTest public class Breville_AccountSearch_CTL_Test{
    @isTest static void testRestServices(){
        System.runAs(createTestUser()){
            Test.startTest();
                //testMethodNewOrderCtrl();
                //testOrganizationUtilMethods();
                testConstructors();
            Test.stopTest();
        }
    }
    @isTest static void testConstructors(){
        Breville_AccountSearch_CTL accountSearch = new Breville_AccountSearch_CTL ();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.Email_External_ID__c = 'test@breville.com';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Breville_AccountSearch_CTL.searchAllAccounts('test@breville.com');
    }
    private static User createTestUser(){
        Profile profile =[Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Admin';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        return testUser;
    }
    
}