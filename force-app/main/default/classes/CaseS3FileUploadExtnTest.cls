@isTest
public with sharing class CaseS3FileUploadExtnTest 
{
	 static testMethod void testMethodCaseS3FileUploadExtn(){
		
		//Case caseObj = TestDataFactory.createCase('Open','USD', true );	
		//Case caseObj = TestDataFactory.createCase('Closed','USD',new QCAlert__c().id, true );	
		Case caseObj = TestDataFactory.createCase('Closed','USD',new QCAlert__c().id,new Account().Id, true );	
         //String status,String currencyIsoCode, String qcAlertId ,String accId,  Boolean insertRecord 
         
		Test.starttest();
	
         PageReference pageRef = Page.CaseS3FileUpload;
         Test.setCurrentPage(pageRef);
         
 		 Case caseObject = [SELECT CurrencyIsoCode FROM Case WHERE id = :caseObj.id];
 		 
	     ApexPages.StandardController sc = new ApexPages.StandardController(caseObject);
	     CaseS3FileUploadExtn caseS3FileUploadExtnObj = new CaseS3FileUploadExtn(sc);
	     
		Test.stoptest();
	
	}
	
        }