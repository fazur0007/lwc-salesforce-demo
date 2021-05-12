@isTest global class MulberryAPIHelper_test
{

    global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global string apiRespone {get;set;}
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            //Asset Objasset = [select id from asset limit 1];
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string apires = '{\r\n    \"success\": true,\r\n    \"order_id\": \"2e49670acdf048159fc9b112f521f92e\",\r\n    \"data\": {\r\n        \"external_order_id\": \"1455353616\",\r\n        \"order_status_value\": \"Active\",\r\n        \"id\": \"2e49670acdf048159fc9b112f521f92e\",\r\n        \"warranties\": [\r\n            {\r\n                \"id\": \"a2488ce761af47718b8139112ac3ea77\",\r\n                \"created_date\": \"2020-05-07 23:20:24.815104+00:00\",\r\n                \"line_items\": [\r\n                    {\r\n                        \"id\": \"bcba87c456224bcd8ca3e84e3692bc44\",\r\n                        \"product\": {\r\n                            \"name\": \"the oracle touch\",\r\n                            \"price\": \"2799.95\",\r\n                            \"external_product_id\": \"Assetid\",\r\n                            \"product_meta\": [\r\n                                {\r\n                                    \"field_name\": \"SKU\",\r\n                                    \"field_value\": \"BES990BSS1BUS1\"\r\n                                }\r\n                            ]\r\n                        }\r\n                    }\r\n                ],\r\n                \"customer_cost\": \"45.50\",\r\n                \"service_type\": \"repair_replace\",\r\n                \"warranty_hash\": \"9a142dcef0679526d209f98fc78634b82c50eec4d82d9a40cc63f8e839006c26\",\r\n                \"duration_months\": \"24\"\r\n            }\r\n        ],\r\n        \"created_date\": \"2020-06-16 10:09:07.113698+00:00\",\r\n        \"customer\": {\r\n            \"show_review_prompt\": false,\r\n            \"billing_address_2\": \"\",\r\n            \"billing_address_1\": \"123 Mint St. Apt 3F\",\r\n            \"billing_country\": \"United States\",\r\n            \"phone\": \"11234567890\",\r\n            \"first_name\": \"Abishekh\",\r\n            \"billing_zip\": \"11231\",\r\n            \"billing_state\": \"NY\",\r\n            \"last_name\": \"Ns\",\r\n            \"email\": \"abhishek.namburi@breville.com.au\",\r\n            \"has_reviewed\": false,\r\n            \"billing_city\": \"Brooklyn\"\r\n        }\r\n    }\r\n}';         
            apires = apires.replace('Assetid','1234567890');
            system.debug('apires:'+apires);
            res.setBody(apires);
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        global string apiRespone {get;set;}
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            //Asset Objasset = [select id from asset limit 1];
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string apires = '{\r\n  \"success\": false\r\n}';         
            system.debug('apires:'+apires);
            res.setBody(apires);
            res.setStatusCode(200);
            return res;
        }
    }
     @isTest static void testCreateWarranty(){
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
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        insert productRecord;
        
        Product2 warrantyProductRecord = new Product2(Name='test warranty SKU', SKU__c='EW2YRNEW100', AX_Item_Number__c='EW2YRNEW100', Available_To_Sell__c=true,Product_Type__c='EXTWTY');
        warrantyProductRecord.Warranty_In_Months__c= 12;
        warrantyProductRecord.CurrencyIsoCode = 'USD';
    warrantyProductRecord.Product_Type__c = 'EXTWTY';
        warrantyProductRecord.serviceContractUseType__c = 'New';
        insert warrantyProductRecord;
        
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
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = warrantyProductRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice1;
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
        PricebookEntry pricebookEntryRecord2 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='EW2YRNEW100' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        OrderItem orderItemRecord_warranty = TestDataFactory.createOrderItemRecord(pricebookEntryRecord2.Id, orderRecord1.Id, 1, 100, true);
        
        
       ProductExtended_warranty__c newPBEW = new ProductExtended_warranty__c(Order__c=orderRecord1.Id,Parent_order_product__c=orderItemRecord.Id,Warranty_order_product__c=orderItemRecord_warranty.Id);
       insert newPBEW;
       orderItemRecord.Linestatus__c = 'Invoiced';
       orderItemRecord_warranty.Linestatus__c = 'Invoiced';
        OrderItemTriggerHandler.afterTriggerRun = true;
       update orderItemRecord;
       update orderItemRecord_warranty;
       orderRecord1.Shipping_Method__c = 'FX-GND';
       orderRecord1.status = 'Invoiced';       
       update orderRecord1;
       
        Asset Objasset = new Asset();
       ObjAsset.Product2Id = productRecord.Id;
       ObjAsset.Name = 'testabc123';
       ObjAsset.Product_Extended_warranty__c = newPBEW.Id;
       ObjAsset.AccountId = accountRecord.Id;
       ObjAsset.Batch_code__c = '2019';
       ObjAsset.ParentOrder__c = orderRecord1.Id;
       insert Objasset;
       
       Test.startTest();
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       ScheduleMulberryWarrantyBatch m = new ScheduleMulberryWarrantyBatch();
       String sch = '0 20 * * * ?';
       String jobID = system.schedule('Mulberry warranty registration', sch, m);
        
       BatchTriggerMulberryWarrantyRegistration objBatch = new BatchTriggerMulberryWarrantyRegistration();
       Database.executeBatch(objBatch,1);
       //MulberryAPIHelper.CreateWarranty(orderRecord1.Id);
       Test.stopTest();      
    }
    @isTest static void testCancelWarranty(){
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
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        insert productRecord;
        
        Product2 warrantyProductRecord = new Product2(Name='test warranty SKU', SKU__c='EW2YRNEW100', AX_Item_Number__c='EW2YRNEW100', Available_To_Sell__c=true,Product_Type__c='EXTWTY');
        warrantyProductRecord.Warranty_In_Months__c= 12;
        warrantyProductRecord.CurrencyIsoCode = 'USD';
    warrantyProductRecord.Product_Type__c = 'EXTWTY';
        warrantyProductRecord.serviceContractUseType__c = 'New';
        insert warrantyProductRecord;
        
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
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = warrantyProductRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice1;
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
        PricebookEntry pricebookEntryRecord2 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='EW2YRNEW100' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        OrderItem orderItemRecord_warranty = TestDataFactory.createOrderItemRecord(pricebookEntryRecord2.Id, orderRecord1.Id, 1, 100, true);
        
        
       ProductExtended_warranty__c newPBEW = new ProductExtended_warranty__c(Order__c=orderRecord1.Id,Parent_order_product__c=orderItemRecord.Id,Warranty_order_product__c=orderItemRecord_warranty.Id);
       insert newPBEW;
       orderItemRecord.Linestatus__c = 'Invoiced';
       orderItemRecord_warranty.Linestatus__c = 'Invoiced';
        OrderItemTriggerHandler.afterTriggerRun = true;
       update orderItemRecord;
       update orderItemRecord_warranty;
       orderRecord1.Shipping_Method__c = '  FX-GND';
       orderRecord1.status = 'Invoiced';    
        orderRecord1.warr_Order_ID__c ='abc21313231';
       update orderRecord1;
       
       //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());       
       Asset Objasset = new Asset();
       ObjAsset.Product2Id = productRecord.Id;
       ObjAsset.Name = 'testabc123';
       ObjAsset.Product_Extended_warranty__c = newPBEW.Id;
       ObjAsset.AccountId = accountRecord.Id;
       ObjAsset.Batch_code__c = '2019';
       insert Objasset;
       caseRecord.AssetId = Objasset.Id;
       caseRecord.RA_Delivered__c = true;
       update caseRecord;
       
       Objasset.Trigger_Mulberry_Cancellation__c = true;
        Objasset.Mulberry_Warranty_Line_Id__c = 'asdasd1231313';
        update Objasset;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
       ScheduleMulberryCancellationBatch m = new ScheduleMulberryCancellationBatch();
       String sch = '0 20 * * * ?';
       String jobID = system.schedule('Mulberry warranty registration', sch, m);
       
       BatchTriggerMulberryWarrantyCancellation objBatch1 = new BatchTriggerMulberryWarrantyCancellation();
       Database.executeBatch(objBatch1,1);       
       MulberryAPIHelper.CancelWarranty(caseRecord .Id);
       Test.stopTest();
    }
}