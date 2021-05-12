@isTest public class Breville_GlobalButtonsHandler_Test{
    @isTest static void testRestServices() {
        System.runAs(createTestUser()) {
            Test.startTest();
                testCreateOrder();
                testConstructors();
                //testCreateOrder();
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
        Breville_GlobalButtonsHandler  globalHanlder = new Breville_GlobalButtonsHandler ();
        try{
            Breville_GlobalButtonsHandler.cancelOrder(null);
        }catch(Exception e){}
        
        try{
            Breville_GlobalButtonsHandler.getOrderRecord(null);
        }catch(Exception e){}
        
        try{
            Breville_GlobalButtonsHandler.sendQuote(null);
        }catch(Exception e){}
        
        try{
            Breville_GlobalButtonsHandler.handleCancelOrder(null);
        }catch(Exception e){}
        
        try{
            Breville_GlobalButtonsHandler.handleCalculateRecalculate(null);
        }catch(Exception e){}
        
    }
    @isTest static void testCreateOrder(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.PersonEmail = 'test@breville.com';
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
        orderRecord1.Shipping_Method__c='TMS';
        orderRecord1.Type = 'Sale';
        orderRecord1.SendQuoteEmail__c = 'test@breville.com';
        orderList.add(orderRecord1);
        insert orderList;
        Breville_GlobalButtonsHandler.getOrderRecord(orderList[0].Id);
        Breville_GlobalButtonsHandler.cancelOrder(orderList[0].Id);
        Breville_GlobalButtonsHandler.sendQuote(orderList[0].Id);
        Breville_GlobalButtonsHandler.handleCancelOrder(orderList[0].Id);
        Breville_GlobalButtonsHandler.handleCalculateRecalculate(orderList[0].Id);
    }
}