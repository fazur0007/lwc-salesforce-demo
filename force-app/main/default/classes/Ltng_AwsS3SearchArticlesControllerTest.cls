@isTest
public class Ltng_AwsS3SearchArticlesControllerTest {
    @isTest
    public static void testinitProductsLoadSearch()
    {
        system.debug('Test');
        List<Product2> lstProducts = TestDataFactory.createProductList('TestKnowledgeSearch',3,'BUSBES900XXL',true);
        for(Product2 ObjProduct:lstProducts)
        {
            ObjProduct.IsActive = true;
            ObjProduct.Finished_Good__c = true;
            ObjProduct.Exclude_from_Sync__c = false;
        }
        insert lstProducts;
        
        Map < String, String > result = new Map < String, String >();
        result = Ltng_AwsS3SearchArticlesController.initProductsLoadSearch('');
        system.assertEquals(3, result.size());
        
        Map < String, String > result_WithSearchString = new Map < String, String >();
        result_WithSearchString = Ltng_AwsS3SearchArticlesController.initProductsLoadSearch('TestKnowledge');
        system.assertEquals(3, result.size());
    }
    
    @isTest
    public static void TestgetBusinessUnits()
    {
        system.debug('Inside TestgetBusinessUnits');
        Map < String, String > result = new Map < String, String >();
        result = Ltng_AwsS3SearchArticlesController.getBusinessUnits('');
        system.assertEquals(true, result.size()>0);
    }
    
    @isTest
    public static void TestgetDocTypes()
    {
        system.debug('Inside TestgetDocTypes');
        Map < String, String > result = new Map < String, String >();
        result = Ltng_AwsS3SearchArticlesController.getDocTypes('');
        system.assertEquals(true, result.size()>0);
    }
    
    @isTest
    public static void TestsearchKnowledgeBase_WithoutDocBU()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Select','');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Select','');
    }
    
    @isTest
    public static void TestsearchKnowledgeBase_WithoutDocWithBU()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'BUS','Select','');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'BUS','Select','');
    }
    
    @isTest
    public static void TestsearchKnowledgeBase_WithDocWithoutBU()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Service Manual','');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Service Manual','');
    }
    
     @isTest
    public static void TestsearchKnowledgeBase_WithDocWithBU()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'BUS','Service Manual','');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'BUS','Service Manual','');
    }
    
       @isTest
    public static void TestsearchKnowledgeBase_WithoutDocBU_WithSearchString()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Select','Test');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Select','Test');
    }
    
    @isTest
    public static void TestsearchKnowledgeBase_WithoutDocWithBU_WithSearchString()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'BUS','Select','Test');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'BUS','Select','Test');
    }
    
    @isTest
    public static void TestsearchKnowledgeBase_WithDocWithoutBU_WithSearchString()
    {
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Service Manual','Test');
        productList.add('Test1');
        productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'Select','Service Manual','Test');
    }
    
     @isTest
    public static void TestsearchKnowledgeBase_WithDocWithBU_WithSearchString()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProduct',1,true);
        for(Product2 ObjProduct:lstProducts)
        {
            ObjProduct.IsActive = true;
            ObjProduct.Finished_Good__c = true;
            ObjProduct.Exclude_from_Sync__c = false;
        }
        insert lstProducts;
        TestDataFactory.createknowledgeBase('TestTitle','TestDesc','USA',lstProducts[0].Id,'Service Manual','USA','abc123','abcxyz',true);
        List < String > productList = new List < String >();
        List<Knowledge_Base__c> result = new List<Knowledge_Base__c>();
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'USA','Service Manual','Test');
        productList.add(lstProducts[0].Id);
        //productList.add('Test2');
        result = Ltng_AwsS3SearchArticlesController.searchKnowledgeBase(productList,'USA','Service Manual','Test');
    }
}