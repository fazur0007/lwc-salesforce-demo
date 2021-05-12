@isTest public class RecordTypeSelectorController_Test {
    @isTest static void testRestServices() {
        System.runAs(createTestUser()) {
            Test.startTest();
                createWorkOrder();
                testConstructors();
            Test.stopTest();
        }
    }
    private static User createTestUser() {
        Profile profile = [Select Id From Profile Where Name = 'System Administrator'];
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
    @isTest static void testConstructors() {
        RecordTypeSelectorController recordTypeSelection = new RecordTypeSelectorController ();
    }
    @isTest static void createWorkOrder(){
        Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Description = 'testing';
        insert objProd;
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        insert caseObj;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId = caseObj.Id;
        wo.AutoReturnLabelStatus__c = 'Scheduled';
        wo.CC_Authorization_ID__c = 'CB12345';
        wo.CreateBoxOrder__c = true;
        insert wo;
        RecordTypeSelectorController.getConfigData(wo.Id);
        RecordTypeSelectorController.createClaim(wo.Id);
    }
}