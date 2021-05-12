@isTest
public with sharing class RMAProcessBatchTest {
    
    @isTest
    private static void testProcessReceiving() {
        Receiving__c rcv = [SELECT Id FROM Receiving__c LIMIT 1];
        rcv.Received_Date__c = Date.today();
        rcv.IsPriceCalculated__c = true;
        rcv.Sent_to_AX__c = null;
        rcv.RMACalculatedUnitPrice__c = 100.00;
        update rcv;
        
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        Database.executeBatch(new RMAProcessBatch(RMAProcessBatch.Action.ProcessReceiving));
        Test.stopTest();
    }
    
    @isTest
    private static void testCompleteRMA() {
        Case cs = [SELECT Id FROM Case LIMIT 1];
        cs.Receiving_Completed_Date__c = Date.today();
        cs.ReceivingComplete__c = true;
        cs.D365RMANumber__c = 'RMA000023';
        update cs;
        
        Receiving__c rcv = [SELECT Id FROM Receiving__c LIMIT 1];
        rcv.Received_Date__c = Date.today();
        rcv.IsPriceCalculated__c = true;
        rcv.Sent_to_AX__c = Date.today();
        rcv.RMACalculatedUnitPrice__c = 100.00;
        update rcv;
        
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        Database.executeBatch(new RMAProcessBatch(RMAProcessBatch.Action.CompleteRMA));
        Test.stopTest();
    }
    
    @isTest
    private static void testScheduleBatch() {
        Case cs = [SELECT Id FROM Case LIMIT 1];
        cs.Receiving_Completed_Date__c = Date.today();
        cs.ReceivingComplete__c = true;
        update cs;
        
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        RMAProcessBatch.scheduleBatch();
        Test.stopTest();
    }
    
    @TestSetup
    static void makeData(){
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        Account objAcc = new Account(Firstname = 'Test', Lastname='Test', CurrencyIsoCode= 'USD', RecordTypeId = accountRecordTypeId);
        objAcc.PersonEmail = 'x@y.com';
        insert objAcc;
        
        Id contactID = [SELECT PersonContactId FROM Account WHERE ID = :objAcc.Id LIMIT 1].PersonContactId;
        
        //Insert Product
        Product2 objProd = new Product2();
        objProd.Name='Test';
        objProd.AX_Item_Number__c = 'Test_123'; 
        objProd.Finished_Good__c= True;
        objProd.Warranty_In_Months__c= 12;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Product_Type__c = 'FG';
        objProd.Finished_Good__c = True;
        objProd.Spare_Part__c = False; 
        objProd.Accessory__c = False;
        objProd.MAP__c = 200; 
        insert objProd;
        
        //Insert Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 objPricebook = new Pricebook2(Id=pricebookId,Region__c ='USA',Brand__c ='Breville',Type__c ='Sale',IsActive = true);
        update objPricebook;
        
		//Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry();
        pricebookEntryObj.Pricebook2Id=objPricebook.Id;
        pricebookEntryObj.Product2Id=objProd.Id;
        pricebookEntryObj.UnitPrice=objProd.MAp__c;
        pricebookEntryObj.isActive=true;
        pricebookEntryObj.CurrencyIsoCode = 'USD';
        insert pricebookEntryObj;
        
        //Insert Order
        Order objOrd = new Order();
        objOrd.AccountId = objAcc.Id;
        objOrd.CurrencyIsoCode = 'USD';
        objOrd.Status = 'Open';
        objOrd.Pricebook2Id=objPricebook.Id;
        objOrd.Type = 'Sale';
        objOrd.Source__c = 'Breville';
        objOrd.Channel__c = 'CCC'; 
        objOrd.EffectiveDate = Date.today();
        objOrd.Sales_Tax_Rate__c = 7;
        objOrd.BillToContactId = contactID;
        objOrd.BillingCity = 'Alpharetta';
        objOrd.BillingCountry = 'USA';
        objOrd.BillingStreet = '5750 Windward Parkway';
        objOrd.BillingState = 'GA';
        objOrd.BillingPostalCode = '30005';
        objOrd.ShipToContactId = contactID;
        objOrd.ShippingCity = 'Alpharetta';
        objOrd.ShippingCountry = 'USA';
        objOrd.ShippingStreet = '5750 Windward Parkway';
        objOrd.ShippingState = 'GA';
        objOrd.ShippingPostalCode = '30005';
        insert objOrd;  
        
        //Insert Order Product
        OrderItem orderItemRecord = new OrderItem();
        orderItemRecord.orderId = objOrd.Id;
        orderItemRecord.PricebookEntryId = pricebookEntryObj.Id;
        orderItemRecord.UnitPrice = pricebookEntryObj.UnitPrice;
        orderItemRecord.Quantity = 3;
        orderItemRecord.Available_to_Sell__c = pricebookEntryObj.Product2.Available_to_Sell__c;
        insert orderItemRecord; 
        
        OrderItemTriggerHandler.afterTriggerRun = true;
        
        orderItemRecord.LineStatus__c = 'Shipped';
        update orderItemRecord;
        
        Asset asst = [SELECT Id FROM Asset LIMIT 1];
        
        Case cse = TestDataFactory.createCase(objAcc.Id, 'Phone', 'Open', 'Test USD', 'USD', false);
        cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        cse.AccountId=objAcc.Id;
        cse.Purchase_Invoice_No__c='12345';
        cse.Product__c = objProd.Id;
        cse.Order__c = objOrd.Id;
        cse.AssetId = asst.Id;
        insert cse;
        
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(cse.id);
        Rcv.CurrencyIsoCode ='USD';
        Rcv.Case__c=cse.Id;
        Rcv.Return_Location__c = 'CAN DRP';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c = objProd.Id;
        Rcv.Received_Qty__c = 1;
        Rcv.AX_Warehouse__c = '621';
        insert Rcv;
    }
}