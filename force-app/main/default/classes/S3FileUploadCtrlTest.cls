@isTest
public with sharing class S3FileUploadCtrlTest {
	
	 static testMethod void testMethodS3FileUploadCtrl(){
		
		//Case caseObj = TestDataFactory.createCase('Open','USD', true );
		Case caseObj = TestDataFactory.createCase('Open','USD',new QCAlert__c().id,new Account().Id,true );
		Product2 product = TestDataFactory.createProduct('Prod', false, true);
        Knowledge_Base__c knowledgeBase = TestDataFactory.createknowledgeBase('Manual for Coffee', 'Manual for Coffee', 'USA',product.Id,'Training Manual','USA','da9b6a65c04f5dcbb4478c9b62a667f4','KnowledgeBase/'+product.Id+'/Training Manual/Cash payment voucher.xls',true);
        
         
		Test.starttest();
	
         PageReference pageRef = Page.KnowledgeBaseS3FileUpload;
         Test.setCurrentPage(pageRef);

	     S3FileUploadCtrl s3FileUploadCtrlObj = new S3FileUploadCtrl();
	     s3FileUploadCtrlObj.KB = knowledgeBase; 
	     s3FileUploadCtrlObj.ctrlRegion = knowledgeBase.Bucket__c; 
	     s3FileUploadCtrlObj.ctrlKey = knowledgeBase.FileKey__c ;
	     
	     Boolean sucesssPositiveCondition = S3FileUploadCtrl.createKnowledgeBase(knowledgeBase,knowledgeBase.Bucket__c,'KnowledgeBase/.SWF100/FAQ/Braville_Project','85008651e941b54c5e81366e31684094');
	     
	     Boolean sucesssNegativeCondition =S3FileUploadCtrl.createKnowledgeBase(new Knowledge_Base__c() ,knowledgeBase.Bucket__c,'KnowledgeBase/.SWF100/FAQ/Braville_Project','85008651e941b54c5e81366e31684094');
	     
		Test.stoptest();
		
		
		//Check if one record is created in Knowledge Base Object
        List<Knowledge_Base__c> knowledgeBaseList = [SELECT Id, Title__c FROM Knowledge_Base__c WHERE id =: knowledgeBase.id];
        system.assertEquals(1,knowledgeBaseList.size());
        
        //Check if one record is updated in Knowledge Base Object
        Knowledge_Base__c knowledgeBaseObject = [SELECT Id, Title__c,ETag__c,FileKey__c FROM Knowledge_Base__c WHERE id =: knowledgeBase.id];
        system.assertEquals('85008651e941b54c5e81366e31684094',knowledgeBaseObject.ETag__c);
        system.assertEquals('KnowledgeBase/.SWF100/FAQ/Braville_Project',knowledgeBaseObject.FileKey__c);
        
        //Check for positive condition
        system.assertEquals(true,sucesssPositiveCondition);
        
        //Check for negative condition
        system.assertEquals(true,sucesssNegativeCondition);
	
	}
	
        }