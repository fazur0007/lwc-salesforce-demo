@isTest
public with sharing class S3FileDownloaderHelperExtnTest 
{
	 static testMethod void testMethodS3FileDownloaderHelperExtn(){
		
		
		Product2 product = TestDataFactory.createProduct('Prod', false, true);
        Knowledge_Base__c knowledgeBase = TestDataFactory.createknowledgeBase('Manual for Coffee', 'Manual for Coffee', 'USA',product.Id,'Training Manual','USA','da9b6a65c04f5dcbb4478c9b62a667f4','KnowledgeBase/'+product.Id+'/Training Manual/Cash payment voucher.xls',true);
        
         
		Test.starttest();
	
         PageReference pageRef = Page.S3FileDownloadHelper;
         Test.setCurrentPage(pageRef);
         
         Knowledge_Base__c knowledgeBaseobj = [SELECT Bucket__c , FileKey__c FROM Knowledge_Base__c WHERE id = :knowledgeBase.id];
         
		 ApexPages.StandardController sc = new ApexPages.StandardController(knowledgeBaseobj);
	     S3FileDownloaderHelperExtn s3FileDownloaderHelperExtnObj = new S3FileDownloaderHelperExtn(sc);
	     s3FileDownloaderHelperExtnObj.generateDownloadLink();
	     
		Test.stoptest();
	
	}
	
}