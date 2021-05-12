@isTest
public class AddOrderProductControllerTest {
    
    @testSetup
    public static void setupData() {
        list<Order> orderList = new list<Order>();
    
        Account accountRecord = new Account();
        accountRecord.FirstName='Test';
        accountRecord.LastName='Account';
        accountRecord.BillingCity = 'Madrid';
        accountRecord.BillingCountryCode = 'ES';
        accountRecord.BillingPostalCode = '28001';
        accountRecord.BillingStreet = 'Calle de Claudio Coello, 65';
        accountRecord.ShippingCountryCode = 'ES';
        accountRecord.ShippingCity = 'Madrid';
        accountRecord.ShippingPostalCode = '28001';
        accountRecord.ShippingStreet = 'Calle de Claudio Coello, 65';
        insert accountRecord;
       
        Pricebook2 pricebookRecord = new Pricebook2(Name='Sage DE Pricebook', isActive=true, Region__c='DE', Type__c='Sale',Brand__c='Sage');
        insert pricebookRecord;
        
		Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        productRecord.IsActive= true;
        productRecord.Quantity_Available__c = 5;
        productRecord.CurrencyIsoCode = 'EUR';
        update productRecord;
        
        Id stdpricebookrec = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdpricebookrec, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        standardPrice.CurrencyIsoCode = 'EUR';
        Insert standardPrice;
   
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = productRecord.id, UnitPrice = 1250.0, IsActive = true);
        standardPriceNew.CurrencyIsoCode = 'EUR';
        insert standardPriceNew;
               
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Sage','EUR');
        
        orderRecord1.Country__c='DE';
        orderRecord1.BillingCity = 'Madrid';
        orderRecord1.BillingCountryCode = 'ES';
        orderRecord1.BillingPostalCode = '28001';
        orderRecord1.BillingStreet = 'Calle de Claudio Coello, 65';
        orderRecord1.ShippingCountryCode = 'ES';
        orderRecord1.ShippingCity = 'Madrid';
        orderRecord1.ShippingPostalCode = '28001';
        orderRecord1.ShippingStreet = 'Calle de Claudio Coello, 65';
        orderRecord1.Shipping_Method__c=null;
        orderRecord1.Pricebook2Id = pricebookRecord.id;
        insert orderRecord1;
        orderList.add(orderRecord1); 
        
        Datetime dt = Datetime.now();
        String currentdt = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        Promotion__c promotion =new Promotion__c();
        promotion.isActive__c=true;
        promotion.Promotion_Name__c = 'Friday_Sale';
        promotion.End_Date_Time__c = dt + 1;
        promotion.Start_Date_Time__c = dt - 1;
        promotion.CurrencyIsoCode = 'EUR';
        insert promotion;
        
        Product2 prod=[Select Id From Product2];
        Offer_Product__c offerProduct=new Offer_Product__c();
        offerProduct.Promotional_Pricing__c=22.90;
        offerProduct.isActive__c=true;
        offerProduct.Promotion__c=promotion.Id;
        offerProduct.Product__c=prod.Id;
        offerProduct.CurrencyIsoCode = 'EUR';
        insert offerProduct;
         Order OrderRecord11  = [Select Id,OrderCustomerType__c from Order ];
       		
    }
    
    static testMethod void testMethodAddOrderProductController1(){
		Test.startTest();
        Order ord=[Select Id From Order];
        List<PricebookEntry> pbeList=[Select Pricebook2Id,Product2Id,UnitPrice,IsActive from PricebookEntry];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrlRecord1 = new AddOrderProductController(sc); 
        PricebookEntry pberecord = [Select Id,Product2Id,UnitPrice,Product2.Quantity_Available__c,Product2.Available_To_Sell__c from PricebookEntry where UnitPrice = 1250.0 ]; 
        AddOrderProductController.Pricebookentrywrapper wp = new AddOrderProductController.Pricebookentrywrapper(pberecord);
        wp.selected=true;
        wp.quantity = 2;
        
        addOrderProductCtrlRecord1.list_size = 10;
        addOrderProductCtrlRecord1.counter = 0;
        addOrderProductCtrlRecord1.filters='AX_Item_Number__c';
        addOrderProductCtrlRecord1.searchText='9999';
        addOrderProductCtrlRecord1.getFilterItems();
        AddOrderProductController.showPromotionalPriceforB2COrder=true;
        addOrderProductCtrlRecord1.selectedOrderProducts.add(wp);
        addOrderProductCtrlRecord1.ordersSelected();
        addOrderProductCtrlRecord1.save();
        addOrderProductCtrlRecord1.resetTheCounterOnNewSearch();
        addOrderProductCtrlRecord1.getTotalPages();
        addOrderProductCtrlRecord1.getPageNumber();
        addOrderProductCtrlRecord1.Next();
        addOrderProductCtrlRecord1.Previous();
        addOrderProductCtrlRecord1.Beginning();
        addOrderProductCtrlRecord1.End();
        addOrderProductCtrlRecord1.getDisabledPrevious();
        Boolean status = addOrderProductCtrlRecord1.getDisabledNext();
        System.assertEquals(true, status, 'Success'); 
        Test.stopTest();
        
    }
    
    static testMethod void testMethodSaveAndMore(){
		Test.startTest();
        Order ord=[Select Id From Order];
        List<PricebookEntry> pbeList=[Select Pricebook2Id,Product2Id,UnitPrice,IsActive from PricebookEntry];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrlRecord1 = new AddOrderProductController(sc); 
        PricebookEntry pberecord = [Select Id,Product2Id,UnitPrice,Product2.Quantity_Available__c,Product2.Available_To_Sell__c from PricebookEntry where UnitPrice = 1250.0 ]; 
        AddOrderProductController.Pricebookentrywrapper wp = new AddOrderProductController.Pricebookentrywrapper(pberecord);
        wp.selected=true;
        wp.quantity = 2;
        
        addOrderProductCtrlRecord1.list_size = 10;
        addOrderProductCtrlRecord1.counter = 0;
        addOrderProductCtrlRecord1.filters='AX_Item_Number__c';
        addOrderProductCtrlRecord1.searchText='9999';
        addOrderProductCtrlRecord1.getFilterItems();
        AddOrderProductController.showPromotionalPriceforB2COrder=true;
        addOrderProductCtrlRecord1.selectedOrderProducts.add(wp);
        addOrderProductCtrlRecord1.ordersSelected();
        PageReference pg=addOrderProductCtrlRecord1.saveMore();
        System.debug('pg===>'+pg);
        Boolean status = addOrderProductCtrlRecord1.getDisabledNext();
        System.assertNotEquals(null, pg, 'Success');
        Test.stopTest();
        
    }
    
    @isTest
    static void testMethodgetDisabledNext(){
        
        Order ord=[Select Id From Order];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrl = new AddOrderProductController(sc); 
        addOrderProductCtrl.counter=1; 
        addOrderProductCtrl.list_size=1;
        addOrderProductCtrl.total_size=10; 
        Test.startTest();
        Boolean status=addOrderProductCtrl.getDisabledNext();
        System.assertEquals(false, status, 'Success'); 
        Test.stopTest();
    }
    
    @isTest
    static void testMethodgetDisabledPrevious(){
        
        Order ord=[Select Id From Order];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrl = new AddOrderProductController(sc); 
        addOrderProductCtrl.counter=1; 
        Test.startTest(); 
        Boolean status=addOrderProductCtrl.getDisabledPrevious();
        System.assertEquals(false, status, 'Success'); 
        Test.stopTest();
    }
    
    @isTest
    static void testMethodPrevious(){
        
        Order ord=[Select Id From Order];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrl = new AddOrderProductController(sc); 
        addOrderProductCtrl.count=2; 
        addOrderProductCtrl.list_size=1;
        addOrderProductCtrl.total_size=10; 
        addOrderProductCtrl.counter=10;
        Test.startTest();
        PageReference pageRef=addOrderProductCtrl.Previous(); 
        System.assertEquals(null, pageRef, 'Success'); 
        Test.stopTest();
    }
    
    @isTest
    static void testMethodNext(){
        
        Order ord=[Select Id From Order];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrl = new AddOrderProductController(sc); 
        addOrderProductCtrl.list_size=1;
        Test.startTest();
        PageReference pageRef=addOrderProductCtrl.Next(); 
        System.assertEquals(null, pageRef, 'Success'); 
        Test.stopTest();
    }
    
    
    @isTest
    static void testMethodgetTotalPages(){
        
        Order ord=[Select Id From Order];
        ApexPages.CurrentPage().getparameters().put('Id', ord.id); 
        ApexPages.StandardController sc = new ApexPages.standardController(ord);   
        AddOrderProductController addOrderProductCtrl = new AddOrderProductController(sc); 
        addOrderProductCtrl.counter=1; 
        addOrderProductCtrl.list_size=2;
        addOrderProductCtrl.total_size=10; 
        Test.startTest(); 
        Integer value= addOrderProductCtrl.getTotalPages();
        System.assertEquals(6,value,'Success');
        Test.stopTest();
    }
    
}