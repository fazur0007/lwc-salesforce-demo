@isTest public class Ltng_NewOrderCtrl_Test{
    /*@isTest static void testRestServices(){
        System.runAs(createTestUser()){
            Test.startTest();
                testMethodNewOrderCtrl();
                testOrganizationUtilMethods();
                testConstructors();
            Test.stopTest();
        }
    }*/

    @isTest static void testOrganizationUtilMethods(){
        Test.startTest();
        Ltng_OrganizationUtil_Cls.getWorkOrderFieldMappingForCase();
        Ltng_OrganizationUtil_Cls.getOrderFieldMappingForAccount();
        Ltng_OrganizationUtil_Cls.getOrderFieldMappingForCase();
        Test.stopTest();
    }

    @isTest static void testMethodNewOrderCtrl(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        accountRecord.phone = '1234567890';
        accountRecord.PersonEmail = 'NikhilAccount@test.com';
        insert accountRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        
       /* Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', 
            isActive=true, Region__c='USA', 
            Type__c='Wholesale',Brand__c='Breville'
            
        );*/
        Pricebook2 pricebookRecord = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Sale'
        );
        
        update pricebookRecord;
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        insert productRecord;
        
        //promotion creation
        Datetime currentTime = Datetime.now();
        Promotion__c objPromotion = new Promotion__c(isActive__c=true,PromoDispName__c='TestPromoTestClass',Promotion_Name__c='TestPromoTestClass',Start_Date_Time__c=currentTime,End_Date_Time__c=currentTime.AddDays(2));
        insert objPromotion;
        
        Offer_Product__c ObjOfferProduct = new Offer_Product__c(isActive__c=true,Product__c=productRecord.Id,Promotion__c=objPromotion.Id,Promotional_Pricing__c=12);
        insert ObjOfferProduct;
        
        Id pricebookId = pricebookRecord.Id;
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        system.debug('standardPrice:'+standardPrice);
       // PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = productRecord.id, UnitPrice = 1250.0, IsActive = true);
       // insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        //System.debug('Record Id : '+pricebookRecord.Id);
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
       // orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderRecord1.Country__c='USA';
        orderRecord1.Shipping_Method__c=null;
        //orderRecord1.OrderCustomerType__c = 'B2C';
        orderRecord1.Type = 'Sale';
       // orderRecord1.Shipping_Method__c='UPS 2ND';
        orderList.add(orderRecord1);
        insert orderList;
        system.debug('orderList:'+orderList);
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        
        Ltng_NewOrderCtrl.loadInit(accountRecord.Id);
        Ltng_NewOrderCtrl.loadInit(caseRecord.Id);
        Ltng_NewOrderCtrl.getBrands(True,'USA');
        Ltng_NewOrderCtrl.getBrands(false,'Test');
        Ltng_NewOrderCtrl.getOrderTypes(True,'USA','Service Repairer Community','Account',True,True);
        Ltng_NewOrderCtrl.getOrderTypes(True,'USA','Service Repairer Community','Case',True,True);
        
        Ltng_NewOrderCtrl.getOrderTypes(False,'USA','Service Repairer Community','Account',True,True);
        Ltng_NewOrderCtrl.getOrderTypes(False,'USA','Service Repairer Community','Case',True,True);        
        Ltng_NewOrderCtrl.getPriceBooks(orderItemRecord.OrderId);
        sObject accountObj = new Order();
        Ltng_NewOrderCtrl.getDependentMap(accountObj ,'Country__c','Shipping_Method__c');        
        Ltng_NewOrderCtrl.doGetOrderItem(orderList[0].Id);
        Ltng_NewOrderCtrl.doSearch(orderList[0].Id,'PN1','Name');
        
        String jsonString = '[]';
        Ltng_NewOrderCtrl.doSave(orderList[0].Id,jsonString);
        Ltng_NewOrderCtrl.save(accountRecord.Id,'Breville','Sale','USD','Account',false,'USA',false,'','');
        Ltng_NewOrderCtrl.save(caseRecord.Id,'Breville','Sale','USD','Case',false,'USA',false,'',''); 
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        Case caseRecord1 = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        caseRecord1.Service_Center__c = ServiceCentreAccount.Id;
        update caseRecord1;
        Test.startTest();
        Ltng_NewOrderCtrl.save(caseRecord1.Id,'Breville','Work Order','USD','Case',false,'USA',false,'','');
        
        Ltng_NewOrderCtrl.calcPPriceforB2COrder(orderList[0]);
        Ltng_NewOrderCtrl.copyBrevilleOfficeAddressAsShipping(orderList[0],accountRecord);
        Ltng_NewOrderCtrl.checkPriceBookForOrder(orderList[0],true,'Sample','','');
        Ltng_NewOrderCtrl.checkPriceBookForOrder(orderList[0],true,'Employee Sale','','');
        Ltng_NewOrderCtrl.checkPriceBookForOrder(orderList[0],true,'Specialty Roaster','','');
        Ltng_NewOrderCtrl.checkPriceBookForOrder(orderList[0],true,'Wholesale','','');
        Test.stopTest();
    }

    @isTest static void testConstructors(){
        Ltng_NewOrderCtrl newOrderCtrl = new Ltng_NewOrderCtrl ();
        Ltng_NewOrderCtrl.loadInit(null);
        Ltng_NewOrderCtrl.orderTypeChange(null,null);
        Ltng_NewOrderCtrl.copyBrevilleOfficeAddressAsShipping(null,null);        
    }
    
    @isTest static void testMethodNewOrderCtrl_B2BAccount(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('TestB2Baccount', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Business Account'].Id;
        insert accountRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        
       /* Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', 
            isActive=true, Region__c='USA', 
            Type__c='Wholesale',Brand__c='Breville'
            
        );*/
        Pricebook2 pricebookRecord = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Wholesale'
        );
        
        update pricebookRecord;
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Isactive = true;
        insert productRecord;
        
        Id pricebookId = pricebookRecord.Id;
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        system.debug('standardPrice:'+standardPrice);
       // PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = productRecord.id, UnitPrice = 1250.0, IsActive = true);
       // insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        //System.debug('Record Id : '+pricebookRecord.Id);
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
       // orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderRecord1.Country__c='USA';
        orderRecord1.Shipping_Method__c=null;
        //orderRecord1.OrderCustomerType__c = 'B2C';
        orderRecord1.Type = 'Sale';
       // orderRecord1.Shipping_Method__c='UPS 2ND';
        orderList.add(orderRecord1);
        insert orderList;
        system.debug('orderList:'+orderList);
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        
        Ltng_NewOrderCtrl.loadInit(accountRecord.Id);
        Ltng_NewOrderCtrl.loadInit(caseRecord.Id);
        Ltng_NewOrderCtrl.getBrands(True,'USA');
        Ltng_NewOrderCtrl.getBrands(false,'Test');
        Ltng_NewOrderCtrl.getOrderTypes(True,'USA','Service Repairer Community','Account',True,True);
        Ltng_NewOrderCtrl.getOrderTypes(True,'USA','Service Repairer Community','Case',True,True);
        
        Ltng_NewOrderCtrl.getOrderTypes(False,'USA','Service Repairer Community','Account',True,True);
        Ltng_NewOrderCtrl.getOrderTypes(False,'USA','Service Repairer Community','Case',True,True);        
        Ltng_NewOrderCtrl.getPriceBooks(orderItemRecord.OrderId);
        sObject accountObj = new Order();
        Ltng_NewOrderCtrl.getDependentMap(accountObj ,'Country__c','Shipping_Method__c');        
        Ltng_NewOrderCtrl.doGetOrderItem(orderList[0].Id);
        Ltng_NewOrderCtrl.doSearch(orderList[0].Id,'PN1','Name');
        
        String jsonString = '[]';
        Ltng_NewOrderCtrl.doSave(orderList[0].Id,jsonString);
        Ltng_NewOrderCtrl.save(accountRecord.Id,'Breville','Sale','USD','Account',false,'USA',false,'','');
        Ltng_NewOrderCtrl.save(caseRecord.Id,'Breville','Sale','USD','Case',false,'USA',false,'',''); 
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        Case caseRecord1 = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        caseRecord1.Service_Center__c = ServiceCentreAccount.Id;
        update caseRecord1;
        Test.startTest();
        Ltng_NewOrderCtrl.save(caseRecord1.Id,'Breville','Work Order','USD','Case',false,'USA',false,'','');
        
        Ltng_NewOrderCtrl.calcPPriceforB2COrder(orderList[0]);
        List<String> listOfProductsIds = new List<String> {productRecord.Id};
        Ltng_NewOrderCtrl.doGetProductsandRelatedProducts(listOfProductsIds,orderList[0].Id);
        String selectedOrderProducts = '[{"Available_To_Sell":false,"PricebookEntryId":"'+pricebookEntryRecord1.Id+'","Product2Id":"'+productRecord.Id+'","productRecName":"800BLXL","quantity":"2","relatedProductQuantity":10,"selectedRelatedProduct":"","unitPrice":299.99,"qtyErrorMessage":""}]';
        Ltng_NewOrderCtrl.doSaveRelatedProducts(orderList[0].Id,selectedOrderProducts);
        Test.stopTest();
        
    }
    
    private static User createTestUser(){
        Profile profile =[Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Admin';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        return testUser;
    }
}