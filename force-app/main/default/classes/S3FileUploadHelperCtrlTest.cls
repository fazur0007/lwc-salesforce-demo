@isTest
public with sharing class S3FileUploadHelperCtrlTest 
{
	 static testMethod void testMethodS3FileUploadHelperCtrl(){
		
		
		Product2 product = TestDataFactory.createProduct('Prod', false, true);
        Knowledge_Base__c knowledgeBase = TestDataFactory.createknowledgeBase('Manual for Coffee', 'Manual for Coffee', 'USA',product.Id,'Training Manual','USA','da9b6a65c04f5dcbb4478c9b62a667f4','KnowledgeBase/'+product.Id+'/Training Manual/Cash payment voucher.xls',true);
         
		Test.starttest();
	
         PageReference pageRef = Page.S3FileUploadHelper;
         Test.setCurrentPage(pageRef);
         
         pageRef.getParameters().put('region', knowledgeBase.Bucket__c);
         pageRef.getParameters().put('key', knowledgeBase.FileKey__c );

	     S3FileUploadHelperCtrl s3FileUploadHelperCtrlObj = new S3FileUploadHelperCtrl();
	     s3FileUploadHelperCtrlObj.getPolicy();
	     s3FileUploadHelperCtrlObj.getSignedPolicy();
	     
		Test.stoptest();
	
	}
	
}