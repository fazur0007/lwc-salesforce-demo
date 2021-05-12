@istest
public with sharing class SendQuoteOnWorkOrderControllerTest {
	public static testMethod void sendQuotePositiveTest(){
   		TestObjects testDataClassObj = new TestObjects();
        Account accObject = new Account();
        accObject.FirstName = 'Test';
        accObject.LastName = 'Test';
        accObject.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        accObject.PersonEmail = 'test@abc.com';
        accObject.CurrencyIsoCode = 'USD';
        insert accObject;
        
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '98104';
        workOrder.currencyISOCode = 'USD';
        workOrder.AccountId = accObject.Id;
        
        Product2 prod2 = TestDataFactory.createProduct('Test Product2', true, false);
        insert prod2;
        
        Product2 prod = TestDataFactory.createProduct('Test Product', true, false);
        prod.Serviceable__c = true;
        prod.Service_Return_Box__c = prod2.Id;
        insert prod;
        
        workOrder.Product__c = prod.ID;
        workOrder.BatchCode__c = '1624';
        workOrder.FirstName__c = 'Test';
        workOrder.LastName__c = 'Test';
        
        Case crec = new Case();
        crec.AccountId = accObject.Id;
        insert crec;
        
        workOrder.caseId = crec.Id;
        insert workOrder;
        
        ApexPages.StandardController sc = new ApexPages.standardController(workOrder);
		SendQuoteOnWorkOrderController ctlr = new SendQuoteOnWorkOrderController(sc);
		
        ctlr.createReturnLabel = 'Yes';
        ctlr.submitResponse();
        System.assertEquals(true,ctlr.quoteSent);
   }
   
   public static testMethod void sendQuotePositiveTestWithNoEmail(){
   		TestObjects testDataClassObj = new TestObjects();
        Account accObject = new Account();
        accObject.FirstName = 'Test';
        accObject.LastName = 'Test';
        accObject.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        //accObject.PersonEmail = 'test@abc.com';
        accObject.CurrencyIsoCode = 'USD';
        insert accObject;
        
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '98104';
        workOrder.currencyISOCode = 'USD';
        workOrder.AccountId = accObject.Id;
        
        Product2 prod2 = TestDataFactory.createProduct('Test Product2', true, false);
        insert prod2;
        
        Product2 prod = TestDataFactory.createProduct('Test Product', true, false);
        prod.Serviceable__c = true;
        prod.Service_Return_Box__c = prod2.Id;
        insert prod;
        
        workOrder.Product__c = prod.ID;
        workOrder.BatchCode__c = '1624';
        workOrder.FirstName__c = 'Test';
        workOrder.LastName__c = 'Test';
        
        Case crec = new Case();
        crec.AccountId = accObject.Id;
        insert crec;
        
        workOrder.caseId = crec.Id;
        insert workOrder;
        
        ApexPages.StandardController sc = new ApexPages.standardController(workOrder);
		SendQuoteOnWorkOrderController ctlr = new SendQuoteOnWorkOrderController(sc);
		
        ctlr.createReturnLabel = 'Yes';
        ctlr.submitResponse();
        System.assertEquals(true,ctlr.quoteSent);
   }
}