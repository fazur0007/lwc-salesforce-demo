@isTest(SeeAllData=false)
public with sharing class NewOrderHelperTest 
{
    static testMethod void testMethodNewOrderCtrl1(){            
        
		//Create Account
        Account accountRecord = new Account();TestDataFactory.createAccountRecord(' ', false);
        accountRecord.Name = 'NikhilAccount Palekar99';
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
        accountRecord.Phone = '1234567890';
        accountRecord.Business_Email__c = 'NikhilAccount_Palekar99@test.com';
        insert accountRecord;
        
        //Insert Contact
        Contact con = new Contact();
        con.LastName = 'Last';  
        con.AccountId = accountRecord.Id;
        insert con;
        
        //Create portal user
        User user1 = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = con.Id,
            ProfileId = [Select id from Profile where Name = 'Service Repairer Community'].Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            CurrencyISOCode__c = 'USD'
        );
        UserTriggerHandler.beforeTriggerRun = false;
        UserTriggerHandler.afterTriggerRun = false;
        insert user1 ;

		//Create Case
		Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
		
        //Insert Product
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
               
        Id standardPBId = Test.getStandardPricebookId();        
        
        //Create PricebookEntry
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.pricebook2Id = standardPBId;
        standardPrice.product2id = productRecord.id;
        standardPrice.unitprice = 1249.0;
        standardPrice.isactive = true;
        insert standardPrice;
        
        
        //Create Order
        list<Order> orderList = new list<Order>();
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, standardPBId, recordTypeRecord.Id, 'Sale',
                                                               '411111111111111', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
        orderList.add(orderRecord1);
        
        Test.startTest();
        
        System.runAs(user1){
            insert orderList;
            
            //Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
            PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:standardPBId and Product2.SKU__c='PN1' limit 1];
            OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);

            PageReference pageRef = Page.NewOrder;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('Id', orderRecord1.id);
            ApexPages.CurrentPage().getparameters().put('recordId', caseRecord.id);
            ApexPages.CurrentPage().getparameters().put('idParam', orderRecord1.id );
            ApexPages.CurrentPage().getparameters().put('retURL', orderRecord1.id );
            // pageRef.getParameters().put('recordId', caseRecord.id);
            // pageRef.getParameters().put('retURL', caseRecord.id );
            
            ApexPages.StandardController sc = new ApexPages.standardController(orderRecord1);   
            NewOrderHelper newOrderHelperRecord1 = new NewOrderHelper(sc);
            newOrderHelperRecord1.getRedirect();
        }
        Test.stopTest();
        
    }   
}