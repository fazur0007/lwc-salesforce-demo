@isTest
public with sharing class KnowledgeBaseS3FileUploadExtnTest 
{
	 static testMethod void testMethodKnowledgeBaseS3FileUploadExtn(){
		
		Product2 product = TestDataFactory.createProduct('Prod', false, true);
        Knowledge_Base__c knowledgeBase = TestDataFactory.createknowledgeBase('Manual for Coffee', 'Manual for Coffee', 'USA',product.Id,'Training Manual','USA','da9b6a65c04f5dcbb4478c9b62a667f4','KnowledgeBase/'+product.Id+'/Training Manual/Cash payment voucher.xls',true);
         
		Test.starttest();
	
         PageReference pageRef = Page.KnowledgeBaseS3FileUpload;
         Test.setCurrentPage(pageRef);

	     ApexPages.StandardController sc = new ApexPages.StandardController(knowledgeBase);
	     KnowledgeBaseS3FileUploadExtn knowledgeBaseS3FileUploadExtnObj = new KnowledgeBaseS3FileUploadExtn(sc);
	     
		Test.stoptest();
	
	}
	
        }