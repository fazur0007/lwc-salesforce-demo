@isTest
public with sharing class AwsS3SearchArticlesControllerTest {

	 static testMethod void testMethodAwsS3SearchArticlesController(){
		
		//Insert Product2
        Product2 objProd1 = new Product2(Name= 'Test Product1');
        objProd1.BusinessUnit__c = 'BUS'; 
        
        //Insert Product2
        Product2 objProd2 = new Product2(Name= 'Test Product2');
        objProd2.BusinessUnit__c = 'BUS'; 
        
        List<Product2> product2List = new List<Product2>();
        product2List.add(objProd1);
        product2List.add(objProd2);
        insert product2List;
        
        //Insert Case
   		Case caseRecord = new Case();
        caseRecord.status='Open';
        caseRecord.Product__c=objProd1.Id;
        insert caseRecord;
        
		Test.starttest();
		
		 PageReference pageRef = Page.AwsS3SearchArticles;
	     Test.setCurrentPage(pageRef);
	     pageRef.getParameters().put('products', objProd1.Id+','+objProd2.Id);
	     
	     AwsS3SearchArticlesController awsS3SearchArticlesControllerObj = new AwsS3SearchArticlesController();
        
        //With Search term
	     awsS3SearchArticlesControllerObj.searchStr='Product1';
	     awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
        awsS3SearchArticlesControllerObj.searchStr='Product1';
	     awsS3SearchArticlesControllerObj.businessUnit = 'Select';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
        awsS3SearchArticlesControllerObj.searchStr='Product1';
	     awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Select';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
        awsS3SearchArticlesControllerObj.searchStr='Product1';
	     awsS3SearchArticlesControllerObj.businessUnit = 'Select';
         awsS3SearchArticlesControllerObj.docType = 'Select';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
	     //Without Search term
	     awsS3SearchArticlesControllerObj.searchStr='';
         awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
	     System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
         awsS3SearchArticlesControllerObj.searchStr='';
         awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Select';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
	     System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
	     awsS3SearchArticlesControllerObj.searchStr='';
	     awsS3SearchArticlesControllerObj.businessUnit = 'Select';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(caseRecord.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
         System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
	     
	     awsS3SearchArticlesControllerObj.searchStr='';
	     awsS3SearchArticlesControllerObj.businessUnit = 'Select';
         awsS3SearchArticlesControllerObj.docType = 'Select';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     AwsS3SearchArticlesController.getCaseDetails(objProd2.Id);
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
        
         System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
		Test.stoptest();
	}
		
	static testMethod void noProductsTest(){
		
		Test.starttest();
		
		 PageReference pageRef = Page.AwsS3SearchArticles;
	     Test.setCurrentPage(pageRef);
	     
	     AwsS3SearchArticlesController awsS3SearchArticlesControllerObj = new AwsS3SearchArticlesController();
	     awsS3SearchArticlesControllerObj.searchStr='Product3';
	     awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
	     awsS3SearchArticlesControllerObj.getBusinessUnits();
	     awsS3SearchArticlesControllerObj.getDocTypes();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
         awsS3SearchArticlesControllerObj.searchStr='Product3';
	     awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Select';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
	     awsS3SearchArticlesControllerObj.getBusinessUnits();
	     awsS3SearchArticlesControllerObj.getDocTypes();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
         awsS3SearchArticlesControllerObj.searchStr='Product3';
	     awsS3SearchArticlesControllerObj.businessUnit = 'Select';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
	     awsS3SearchArticlesControllerObj.getBusinessUnits();
	     awsS3SearchArticlesControllerObj.getDocTypes();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
        awsS3SearchArticlesControllerObj.searchStr='Product3';
	     awsS3SearchArticlesControllerObj.businessUnit = 'Select';
         awsS3SearchArticlesControllerObj.docType = 'Select';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     awsS3SearchArticlesControllerObj.refreshPageSize();
	     awsS3SearchArticlesControllerObj.getBusinessUnits();
	     awsS3SearchArticlesControllerObj.getDocTypes();
        
        System.assertEquals(true, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
        
        
	     awsS3SearchArticlesControllerObj.searchStr='';
	     awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType = 'Service Manual';
	     awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     awsS3SearchArticlesControllerObj.getKnowledgeBaseList();
	     
        System.assertEquals(false, awsS3SearchArticlesControllerObj.showSearcResultsBlock);
	    System.assertEquals(0, awsS3SearchArticlesControllerObj.getKnowledgeBaseList().size());
	    
		Test.stoptest();
	}
    
    
    static testMethod void testsearchKnowledgeBase(){
		
	     Test.startTest();
         
         AwsS3SearchArticlesController awsS3SearchArticlesControllerObj = new AwsS3SearchArticlesController();
         awsS3SearchArticlesControllerObj.searchStr='Product3';
	     awsS3SearchArticlesControllerObj.businessUnit = 'BUS';
         awsS3SearchArticlesControllerObj.docType =null;
         awsS3SearchArticlesControllerObj.searchKnowledgeBase();
	     Test.stopTest();
    }
}