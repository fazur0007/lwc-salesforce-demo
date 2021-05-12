@isTest(seeAllData=false)
public class D365APIUtilityTest {
    @testSetup 
    public static  void testSetup() {
        insert new D365Setting__c(ValidCurrencies__c='CHF,EUR,GBP,USD');
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS00000';
        lstAcc[0].DataAreaID__c='BDE';
        lstAcc[0].CurrencyIsoCode = 'EUR';
        insert lstAcc;
        
        // Insert Contract
        List<Contract> lstContract= TestDataFactory.createContract(
        lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        lstContract[0].CurrencyIsoCode='EUR';
        insert lstContract;
        
        //Insert Contract
        list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;
        
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'BOV845BSSUSC', false);
        lstProd[0].CurrencyIsoCode = 'EUR';
        lstProd[0].AX_Item_Number__c='234567';
        insert lstProd;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Sale';
        date dt = date.today().addDays(10);
        lstOrder[0].RequestedShipDate__c = dt;
        lstOrder[0].CurrencyIsoCode = 'EUR';
        insert lstOrder;
        List<Order> OID = [select id from Order];
        System.debug('aID '+OID);
        
        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'EUR');
        insert pbe;
        
        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, OID[0].id, 400, 20, 1);
        insert lstOI;
        System.debug('lstOI#########'+lstOI);
        system.debug('rma product#####'+lstOI[0].getSObject('order'));
        
        //Insert Case
        List<case> listCase = new List<case>();
        Case lstCase = TestDataFactory.createCase(lstAcc[0].Id, 'Phone', 'Open', 'Test RMA EUR', 'EUR', false);
        lstCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        lstCase.AccountId=lstAcc[0].Id;
        lstCase.Country__c = 'DE';
        lstCase.Purchase_Invoice_No__c='12345';
        lstCase.RMA_Type__c = 'Destroy in Field';
        listCase.add(lstCase);
        insert listCase;
        List<Case> cID = [select id from Case];
        System.debug('aID '+cID);
        
        //Insert RMA Product
        List<RMA_Product__c> lstRMA = new List<RMA_Product__c>(); 
        RMA_Product__c rm = new RMA_Product__c(Case__c = lstCase.Id , Order__c =OID[0].id ,Quantity__c=200,CurrencyIsoCode='EUR');
        rm.Case__c=lstCase.Id;
        rm.Product__c=lstProd[0].Id;
 		insert rm;
        lstRMA.add(rm);
        
        system.debug('rma product detail'+rm.getSObject('Case__r'));
        Case caseRecord=lstCase;
        System.debug('Case Record'+caseRecord.get('AccountId'));
        
        
        //Insert Receiving
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(cID[0].id);
        Rcv.CurrencyIsoCode ='EUR';
        //Rcv.Account__c = lstAcc[0].Id;
        Rcv.Case__c=lstCase.Id;
       // Rcv.Return_Location__c = 'DHL GERMANY';
         Rcv.Return_Location__c = 'CAN DRP';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c =lstProd[0].id;
        Rcv.Received_Qty__c=1;
        Rcv.AX_Warehouse__c='621';
        insert Rcv;
        lstRc.add(Rcv);
        
    }
    
    @isTest
    public static void testGetTradeAgreementPrice()
    {
        
        List<Account> lstAcc = [Select Id,VendAccount__c,DataAreaID__c from Account Where DataAreaID__c='BDE'];
        List<OrderItem> lstOI= [Select Id,OrderId,Order.Id,Order.RequestedShipDate__c,Order.CurrencyIsoCode,AX_Item_Number__c,Quantity From OrderItem Where UnitPrice= 20];
        List<RMA_Product__c> lstRMA = [Select Id,Case__c, Product__c,Case__r.CurrencyIsoCode,Case__r.Id,Product__r.Id,Product__r.AX_Item_Number__c,Quantity__c,Case__r.AccountId From RMA_PRoduct__c Where Quantity__c=200];
        List<Receiving__c> lstRc = [select Id,Case__c,Received_Qty__c,AXAccountNumber__c,Case__r.Purchase_Invoice_No__c, Case__r.Id,Case__r.CurrencyIsoCode,Case__r.AccountId,Received_Product__c,Received_Product__r.Id,Received_Product__r.AX_Item_Number__c From Receiving__c];
        //select Id,Case__c,Received_Qty__c,Account__c,Account__r.Id,AXAccountNumber__c,Case__r.Purchase_Invoice_No__c,Account__r.DataAreaID__c, Case__r.Id,Case__r.CurrencyIsoCode,Case__r.AccountId,Received_Product__c,Received_Product__r.Id,Received_Product__r.AX_Item_Number__c From Receiving__c 
        
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.TradeAgreementMock());
        
        test.startTest();
        
        D365APIUtility.getTradeAgreementPrice(lstOI,lstAcc[0]);

        test.stopTest();
        
    }
    
    @isTest
    public static void testGetTradeAgreementPriceReceiving()
    {
        
        List<Account> lstAcc = [Select Id,VendAccount__c,DataAreaID__c from Account Where DataAreaID__c='BDE'];
        List<Receiving__c> lstRc = [select Id,Case__c,Received_Qty__c,AXAccountNumber__c,Case__r.Purchase_Invoice_No__c, Case__r.Id,Case__r.CurrencyIsoCode,Case__r.AccountId,Received_Product__c,Received_Product__r.Id,Received_Product__r.AX_Item_Number__c,Case__r.Account.DataAreaID__c From Receiving__c];

        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.TradeAgreementMock());
        
        test.startTest();
        
        D365APIUtility.getTradeAgreementPrice(lstRc,lstAcc[0]);

        test.stopTest();
        
    }
    
    @isTest
    public static void testGetTradeAgreementPriceRMAProduct()
    {
        
        List<Account> lstAcc = [Select Id,VendAccount__c,DataAreaID__c from Account Where DataAreaID__c='BDE'];

        List<RMA_Product__c> lstRMA = [Select Id,Case__c, Product__c,Case__r.CurrencyIsoCode,Case__r.Id,Product__r.Id,Product__r.AX_Item_Number__c,Quantity__c,Case__r.AccountId,Case__r.Account.VendAccount__c,Case__r.Account.DataAreaID__c From RMA_PRoduct__c Where Quantity__c=200];
        
        
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.TradeAgreementMock());
        
        test.startTest();
        
        D365APIUtility.getTradeAgreementPrice(lstRMA,lstAcc[0]);

        test.stopTest();
        
    }
    
    static testMethod void testCreateReceivingOnDIF(){
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Destroy in Field';
        insert caseRecord;
        
        RMA_Product__c rm = new RMA_Product__c(Case__c = caseRecord.Id , Quantity__c=2, CurrencyIsoCode='USD');
        rm.Product__c=productRecord.Id;
        insert rm;
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        CaseTriggerHandler.afterTriggerRun = true;
        CaseTriggerHandler.beforeTriggerRun = true;
        caseRecord.RMAStatus__c = 'RMA Approved';
        update caseRecord;
        Test.stopTest();
    }
    
    static testMethod void testReceivingComplete(){
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Goods to be return (First quality)';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        insert caseRecord;
        
        RMA_Product__c rm = new RMA_Product__c(Case__c = caseRecord.Id , Quantity__c=2, CurrencyIsoCode='USD');
        rm.Product__c=productRecord.Id;
        insert rm;
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        CaseTriggerHandler.afterTriggerRun = true;
        CaseTriggerHandler.beforeTriggerRun = true;
        caseRecord.ReceivingComplete__c = true;
        update caseRecord;
        Test.stopTest();
    }
    
    @isTest
    static void testProcessRMAB2C() {
        Account accountRecord = TestDataFactory.createAccountRecord('Abc', 'Ventures', false);
        accountRecord.ShippingPostalCode = 'Test111';
        accountRecord.BillingStreet = '1234 E Main st';
        accountRecord.BillingCity = 'ZA';
        accountRecord.BillingStateCode= 'CA';
        accountRecord.BillingCountryCode= 'US';
        accountRecord.ShippingStreet = '1234 E Main st';
        accountRecord.ShippingCity = 'ZA';
        accountRecord.ShippingStateCode= 'CA';
        accountRecord.ShippingCountryCode= 'US';
        accountRecord.PersonEmail = 'test@test.com';
        insert accountRecord;
        
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.Stock_Return_Type__c = 'Faulty Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Goods to be return (Defective return)';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        List<Order> OID = [select id from Order];
        caseRecord.Order__c = OID[0].Id;
        insert caseRecord;
        
        RMA_Product__c rm = new RMA_Product__c(Case__c = caseRecord.Id , Quantity__c=2, CurrencyIsoCode='USD');
        rm.Product__c=productRecord.Id;
        insert rm;
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        CaseTriggerHandler.afterTriggerRun = true;
        CaseTriggerHandler.beforeTriggerRun = true;
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(caseRecord.id);
        Rcv.CurrencyIsoCode ='USD';
        Rcv.Case__c=caseRecord.Id;
        Rcv.Return_Location__c = 'CAN DRP';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c = productRecord.id;
        Rcv.Received_Qty__c=1;
        Rcv.AX_Warehouse__c='621';
        Rcv.IsPriceCalculated__c = true;
        Rcv.RMACalculatedUnitPrice__c = 200.0;
        insert Rcv;
        Test.stopTest();
    }
    
}