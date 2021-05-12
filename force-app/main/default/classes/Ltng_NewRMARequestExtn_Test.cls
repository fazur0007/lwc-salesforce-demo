@isTest public class Ltng_NewRMARequestExtn_Test{
    @isTest static void testRestServices(){
        System.runAs(createTestUser()){
            Test.startTest();
                testRMACaseCreation();
                testConstructors();
            Test.stopTest();
        }
    }
    @isTest static void testConstructors(){
        Ltng_NewRMARequestExtn newRMARequest = new Ltng_NewRMARequestExtn();
        Ltng_NewRMARequestExtn.getCurentUser();
        Ltng_NewRMARequestExtn.getWorkOrderRecordTypeID('000kdfjhd84765');
        Ltng_NewRMARequestExtn.doGetConfigDetails('000kdfjhd84765');        
    }
    @isTest static void testRMACaseCreation(){
        Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        Case caseObj = TestDataFactory.createCase(objAcc.Id, 'Email', 'Open', '', 'USD',true);
        caseObj.ContactId = contactObj.Id;
        update caseObj;
        Ltng_NewRMARequestExtn.prePopulateRMABasicInfromation(caseObj,true);
        
        Account objAcc1 = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc1;
        Contact contactObj1 = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        Case caseObj1 = TestDataFactory.createCase(objAcc1.Id, 'Email', 'Open', '', 'USD',true);
        Ltng_NewRMARequestExtn.prePopulateRMABasicInfromation(caseObj1,true);
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