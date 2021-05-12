@isTest
public with sharing class CaseAlertPopupTest 
{
	 static testMethod void testMethodCaseAlertPopup(){
		
		Account accountObj = TestDataFactory.createAccountRecord('Universal Services Ltd.', true);
		QCAlert__c qcAlertObj = TestDataFactory.createQCAlert('please review water and heating details','Test QC', true );	
        Product2 productRecord = TestDataFactory.createProduct('Product #Product Name# one','BES920XL',true,false,false,15,true, true);
		//QCLocation__c qcLocationObj = TestDataFactory.createQCLocation(accountObj.Id,'USA',qcAlertObj.Id,true);
        QCLocation__c qcLocationObj = TestDataFactory.createQCLocation(accountObj.Id,'USA',productRecord.Id, qcAlertObj.Id,false);
        qcLocationObj.IsActive__c = true;
        qcLocationObj.Product__c = productRecord.Id;
        insert qcLocationObj;
        
		Case caseObj = TestDataFactory.createCase('Open','USD', qcAlertObj.Id,accountObj.id, false);	
		caseObj.Product__c = productRecord.Id;
		insert caseObj;
		
		Test.starttest();
		
         PageReference pageRef = Page.QCAlertPopup;
         Test.setCurrentPage(pageRef);
 		 Case caseObject = [SELECT CurrencyIsoCode, QC_Alert__c,Product__c FROM Case WHERE id = :caseObj.id];
	     ApexPages.StandardController sc = new ApexPages.StandardController(caseObject);
	     CaseAlertPopup caseAlertPopupObj = new CaseAlertPopup(sc);
	     List<QCLocation__c> returnList = caseAlertPopupObj.getQCLocations();
	    System.assertEquals(returnList.size(), 0);
	    
		 Test.stoptest();
		 
	}
	
}