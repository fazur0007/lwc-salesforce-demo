@isTest
public class Ltng_AssetExtendWarrantyCtrl_Test {

    @testSetup
    static void testSetup(){
    	
        //Insert Account
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        Account objAcc = new Account(Firstname = 'Test', Lastname='Test', CurrencyIsoCode= 'USD', RecordTypeId = accountRecordTypeId);
		insert objAcc;
        
        //Insert Product
        Product2 objProd = new Product2();
        objProd.Name='Test';
        objProd.AX_Item_Number__c = 'Test_123'; 
        objProd.Finished_Good__c= True;
        objProd.Spare_Part__c = False;
        objProd.Accessory__c = False;
        objProd.Warranty_In_Months__c= 12;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Product_Type__c = 'FG';
        objProd.MAP__c = 200; 
        insert objProd;

        List<Product2> prodRec = [Select id, Warranty_In_Months__c,Available_To_Sell__c from Product2 where Product_Type__c = 'FG' limit 1];
        System.assertEquals(prodRec[0].Available_To_Sell__c, False);
        
        //Insert Warranty SKU
        Product2 objWarrProd = new Product2();
        objWarrProd.Name='Test Warranty';
        objWarrProd.AX_Item_Number__c = 'Test_Warranty_123'; 
        objWarrProd.Warranty_In_Months__c= 12;
        objWarrProd.CurrencyIsoCode = 'USD';
        objWarrProd.Product_Type__c = 'EXTWTY';
        objWarrProd.serviceContractUseType__c = 'Existing';
        objWarrProd.MAP__c = 50.33; 
        insert objWarrProd;
        
        List<Product2> warrProdRec = [Select id, Warranty_In_Months__c,Available_To_Sell__c from Product2 where Product_Type__c = 'EXTWTY' limit 1];
        System.assertEquals(warrProdRec[0].Available_To_Sell__c, True);
        
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Test';
        assetObj.Batch_Code__c = '1920';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 12;
        assetObj.AccountId = objAcc.Id;
        insert assetObj;
        
        //Insert Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 objPricebook = new Pricebook2(Id=pricebookId,Region__c ='USA',Brand__c ='Breville',Type__c ='Sale',IsActive = true);
        update objPricebook;
        
		//Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry();
        pricebookEntryObj.Pricebook2Id=objPricebook.Id;
        pricebookEntryObj.Product2Id=objWarrProd.Id;
        pricebookEntryObj.UnitPrice=99;
        pricebookEntryObj.isActive=true;
        pricebookEntryObj.CurrencyIsoCode = 'USD';
        insert pricebookEntryObj;
        
        //Insert Related Product
        RelatedProducts__c objRelProd = new RelatedProducts__c();
        objRelProd.MasterProduct__c=objProd.Id;
        objRelProd.Product__c = objWarrProd.Id;
        objRelProd.Type__c = 'Extended Warranty';
        insert objRelProd;

    }
    
    @isTest
    static void testvalidateAssetProduct(){
        List<Asset> assetRec = [Select id from Asset limit 1];
               
        Test.startTest();        
        Ltng_AssetExtendWarrantyCtrl.validateAssetProduct(assetRec[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testvalidateAssetProduct_AlreadyHasOrder(){
        List<Asset> assetRec = [Select id, AccountId from Asset limit 1];
        
        //Insert Order
        Order objOrd = new Order();
        objOrd.AccountId = assetRec[0].AccountId;
        objOrd.CurrencyIsoCode = 'USD';
        objOrd.Status = 'Open';
        objOrd.Type = 'Sale';
        objOrd.Source__c = 'Breville';
        objOrd.Channel__c = 'CCC'; 
        objOrd.EffectiveDate = Date.today();
        objOrd.Asset__c = assetRec[0].Id;
        insert objOrd; 
       
        Test.startTest();        
        Ltng_AssetExtendWarrantyCtrl.validateAssetProduct(assetRec[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testvalidateAssetProduct_USARegion(){
        List<Asset> assetRec = [Select id from Asset limit 1];
       	List<Account> accRec = [Select id,CurrencyIsoCode from Account limit 1];
       	accRec[0].CurrencyIsoCode = 'GBP';
        update accRec;
        
        Test.startTest();
        Ltng_AssetExtendWarrantyCtrl.validateAssetProduct(assetRec[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testvalidateAssetProduct_EWPresent(){
        List<Asset> assetRec = [Select id,EW_Present__c from Asset limit 1];
       	assetRec[0].EW_Present__c = True;
        update assetRec;
        
        Test.startTest();
        Ltng_AssetExtendWarrantyCtrl.validateAssetProduct(assetRec[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testvalidateAssetProduct_BrevilleWarrBlank(){
        List<Asset> assetRec = [Select id from Asset limit 1];
       	List<Product2> prodRec = [Select id, Warranty_In_Months__c from Product2 where Finished_Good__c = True limit 1];
       	prodRec[0].Warranty_In_Months__c = null;
        update prodRec;
        
        Test.startTest();
        Ltng_AssetExtendWarrantyCtrl.validateAssetProduct(assetRec[0].Id);
        Test.stopTest();
    }
    
   @isTest
    static void testgetExtendedWarrantyList(){
		List<Asset> assetRec = [Select id from Asset limit 1];
        
        Test.startTest();
        Ltng_AssetExtendWarrantyCtrl.getExtendedWarrantyList(assetRec[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testgetExtendedWarrantyList_NotFGProduct(){
		List<Asset> assetRec = [Select id from Asset limit 1];
        List<Product2> prodRec = [Select id, Product_Type__c from Product2 where Finished_Good__c = True limit 1];
        prodRec[0].Spare_Part__c = True; 
        prodRec[0].Finished_Good__c = False;
        update prodRec;
           
        Test.startTest();
        Ltng_AssetExtendWarrantyCtrl.getExtendedWarrantyList(assetRec[0].Id);
        
        List<OrderItem> OrderProdRec = [Select Id, OrderId from OrderItem where Order.Asset__c =: assetRec[0].Id];
        System.assert(OrderProdRec.size() == 0);
        
        Test.stopTest();
    }
    
    @isTest
    static void testcreateOrder(){
		List<Asset> assetRec = [Select id from Asset limit 1];
        List<Product2> prodRec = [Select id from Product2 where Product_Type__c = 'EXTWTY' limit 1];
        
        Test.startTest();
        Ltng_AssetExtendWarrantyCtrl.createOrder(prodRec[0].Id, assetRec[0].Id);
        
        List<OrderItem> OrderProdRec = [Select Id, OrderId from OrderItem where Order.Asset__c =: assetRec[0].Id];
        System.assert(OrderProdRec.size() > 0);
        
        Test.stopTest();
    }
}