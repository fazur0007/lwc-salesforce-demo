@isTest
public with sharing class NewRMARequestExtnTest {
  
  static testMethod void testMethodNewRMARequestExtn(){
  	
  	 //Insert Account    		
	 Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
     insert objAcc;
        
     //Insert Contact
     Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
     //Insert case
     Case caseObj = TestDataFactory.createCase(objAcc.Id, 'Email', 'Open', '', 'USD',true);
    // caseObj.ContactId=contactObj.Id;
     //upsert caseObj;
    
  	 ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
     NewRMARequestExtn ctrl = new NewRMARequestExtn(sc);
     
     PageReference actualPf = ctrl.cancel();
     PageReference idealPf = new PageReference('/500/');
     
     System.assertEquals(idealPf.getUrl(),actualPf.getUrl());
  	
  }
    
}