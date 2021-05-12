@isTest public class Org_QuickActionHandler_Test {
    @isTest static void testRestServices() {
        System.runAs(createTestUser()) {
            Test.startTest();
                createWorkOrder();
                testConstructors();
                testCreateOrder();
            Test.stopTest();
        }
    }
    private static User createTestUser() {
        Profile profile = [Select Id From Profile Where Name = 'System Administrator'];
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
    @isTest static void testConstructors() {
        Org_QuickActionHandler quickActionHandler = new Org_QuickActionHandler ();
        Org_QuickActionHandler.calculatePriceUtility(null);
    }
    @isTest static void createWorkOrder(){
        Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Description = 'testing';
        insert objProd;
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        //caseObj.Return_Shipment_Type__c ='Multiple Parcels';
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        insert caseObj;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId = caseObj.Id;
        wo.AutoReturnLabelStatus__c = 'Scheduled';
        wo.CC_Authorization_ID__c = 'CB12345';
        wo.CreateBoxOrder__c = true;
        insert wo;
        Org_QuickActionHandler.getConfigData(wo.Id);
        Org_QuickActionHandler.createClaim(wo.Id);
        Org_QuickActionHandler.getCaseConfigData(caseObj.Id);
        Org_QuickActionHandler.updateCaseExtendWarranty(caseObj.Id);
        Org_QuickActionHandler.calculatePriceUtility(caseObj.Id);
        Org_QuickActionHandler.updateCaseRelease(caseObj.Id);
        Org_QuickActionHandler.createReturnLabel(caseObj.Id);
        Org_QuickActionHandler.getAccountData(objAcc.Id);
        
        try{
            Org_QuickActionHandler.createReturnLabel(null);
            Org_QuickActionHandler.updateCaseExtendWarranty(null);
            Org_QuickActionHandler.calculatePriceUtility(null);
            Ltng_OrderObjectUtil.getOrderDetails(null);
       }catch(Exception e){
           
       }
    }
    @isTest static void testCreateOrder(){
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
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
        orderRecord1.Country__c='USA';
        orderRecord1.Shipping_Method__c=null;
        orderRecord1.Type = 'Sale';
        orderList.add(orderRecord1);
        insert orderList;
        Ltng_OrderObjectUtil orderUtil = new Ltng_OrderObjectUtil();
        Ltng_OrderObjectUtil.getOrderDetails(orderList[0].Id);
        Ltng_OrderObjectUtil.getOrderDetail(orderList[0].Id);
        
        Task taskRec = new Task();
        taskRec.ActivityDate = Date.today();
        taskRec.Description = 'Shipment Label Sent';
        taskRec.Subject = 'Test record';
        //taskRec.WhatId = whatId;
        //taskRec.WhoId = whoId;
        taskRec.Status = 'New';
        taskRec.Brand__c = 'Breville';
        taskRec.CarrierName__c = 'Test';
        taskRec.Priority='Normal';
        taskRec.CallType='Outbound';
        insert taskRec;
        Ltng_OrderObjectUtil.closeTask(taskRec.Id);
    }
}