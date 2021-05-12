@isTest
private class DupliacteAccountsBatchTest {

    static testMethod void myUnitTest() {
    	
       Account accountRecord1 = TestDataFactory.createAccountRecord('FirstName1','LastName',false);
       accountRecord1.PersonEmail = 'firstname1@example.com';
       accountRecord1.Is_Duplicate_Checked__c = false;
       insert accountRecord1;
       
       Account accountRecord2 = TestDataFactory.createAccountRecord('FirstName2','LastName',false);
       accountRecord2.PersonEmail = 'firstname2@example.com';
       accountRecord2.Is_Duplicate_Checked__c = false;
       insert accountRecord2;
       
       Account accountRecord3 = TestDataFactory.createAccountRecord('FirstName3','LastName',false);
       accountRecord3.PersonEmail = 'firstname3@example.com';
       accountRecord3.Is_Duplicate_Checked__c = false;
       insert accountRecord3;
       
       Account accountRecord4 = TestDataFactory.createAccountRecord('FirstName4','LastName',false);
       accountRecord4.PersonEmail = 'firstname1@example.com';
       accountRecord4.Is_Duplicate_Checked__c = false;
       insert accountRecord4;
       
       Account accountRecord5 = TestDataFactory.createAccountRecord('FirstName5','LastName',false);
       accountRecord5.PersonEmail = 'firstname2@example.com';
       accountRecord5.Is_Duplicate_Checked__c = false;
       insert accountRecord5;
       
       Account accountRecord6 = TestDataFactory.createAccountRecord('FirstName6','LastName',false);
       accountRecord6.PersonEmail = 'firstname2@example.com';
       accountRecord6.Is_Duplicate_Checked__c = false;
       insert accountRecord6;
       
       Database.executeBatch(new DupliacteAccountsBatch(), 200);
       
       System.assertEquals(0, [SELECT Count() FROM Duplicate_Account__c]);
       
    }
}