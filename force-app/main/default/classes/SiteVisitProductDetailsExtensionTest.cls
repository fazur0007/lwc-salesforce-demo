@isTest
public class SiteVisitProductDetailsExtensionTest {
	@testSetup
	static void setupSampleData(){
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Name';
        insert accountRecord;
        
        Product2 productRecord = new Product2();
        productRecord.AX_Item_Number__c = '800BLXL';
        productRecord.Name = '800BLXL';
        productRecord.CurrencyIsoCode = 'USD';
        productRecord.IsActive = true;
        productRecord.Finished_Good__c = true;
        productRecord.Exclude_from_Sync__c = false;
        insert productRecord;
        
    	Site_Visit__c siteVisitRecord = new Site_Visit__c();
        siteVisitRecord.Account__c = accountRecord.Id;
      	siteVisitRecord.Out_of_Stock_Models__c = '800BLXL';
      	siteVisitRecord.OutOfStockProducts__c = productRecord.Id;
		siteVisitRecord.Knowledge_Products__c = '800BLXL';
        siteVisitRecord.CurrencyIsoCode = 'USD';
        insert siteVisitRecord;
        
        
        
    }
    static testMethod void saveResponseTest(){
      	Site_Visit__c siteVisitRecord = [select id,Out_of_Stock_Models__c,OutOfStockProducts__c,Knowledge_Products__c from Site_Visit__c LIMIT 1 ];
        ApexPages.StandardController sc = new ApexPages.StandardController(siteVisitRecord);
    	SiteVisitProductDetailsExtension testController = new SiteVisitProductDetailsExtension(sc);
        testController.addOutOfStockModel();
        testController.addKnowledgeProduct();
    }    
}