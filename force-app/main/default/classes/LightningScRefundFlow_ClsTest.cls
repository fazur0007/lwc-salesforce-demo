@isTest
private class LightningScRefundFlow_ClsTest {
    
    @isTest
    private static void testGetAssetDetails() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(acc.id,'Chat','Open',null,'USD', null, 'Support & Service',Label.FinalReturn,'1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        insert caseRecord;
        Test.startTest();
        LightningServiceContractRefundFlow_Cls.getAssetDetails(caseRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testDoUpdateDetails() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return;Faulty Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(acc.id,'Chat','Open',null,'USD', null, 'Support & Service',Label.FinalReturn,'1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        insert caseRecord;
        
        Asset ast = [SELECT Id FROM Asset LIMIT 1];
        LightningServiceContractRefundFlow_Cls.Assetwrapper assetInfo = new LightningServiceContractRefundFlow_Cls.Assetwrapper();
        assetInfo.Id = ast.Id;
        assetInfo.isReturnSC = false;
        Test.startTest();
        LightningServiceContractRefundFlow_Cls.doUpdateAssets(caseRecord.Id, JSON.serialize(assetInfo));
        Test.stopTest();
    }
    
    @isTest
    private static void testDoUpdateDetailsOnlyScReturn() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return;Faulty Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(acc.id,'Chat','Open',null,'USD', null, 'Support & Service',Label.FinalReturn,'1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        insert caseRecord;
        
        Asset ast = [SELECT Id FROM Asset LIMIT 1];
        LightningServiceContractRefundFlow_Cls.Assetwrapper assetInfo = new LightningServiceContractRefundFlow_Cls.Assetwrapper();
        assetInfo.Id = ast.Id;
        assetInfo.isReturnSC = true;
        Test.startTest();
        LightningServiceContractRefundFlow_Cls.doUpdateAssets(caseRecord.Id, JSON.serialize(assetInfo));
        Test.stopTest();
    }
    
    @TestSetup
    static void makeData(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        Account objAcc = new Account(Firstname = 'Test', Lastname='Test', CurrencyIsoCode= 'USD', RecordTypeId = accountRecordTypeId);
        insert objAcc;
        
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
        
        //Insert PricebookEntry for Warranty SKU
        PricebookEntry pricebookEntryObj1 = new PricebookEntry();
        pricebookEntryObj1.Pricebook2Id=objPricebook.Id;
        pricebookEntryObj1.Product2Id=objWarrProd.Id;
        pricebookEntryObj1.UnitPrice=objWarrProd.MAp__c;
        pricebookEntryObj1.isActive=true;
        pricebookEntryObj1.CurrencyIsoCode = 'USD';
        insert pricebookEntryObj1;
        
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
        insert objOrd;  
        
        //Insert Order Product
        OrderItem orderItemRecord = new OrderItem();
        orderItemRecord.orderId = objOrd.Id;
        orderItemRecord.PricebookEntryId = pricebookEntryObj.Id;
        orderItemRecord.UnitPrice = pricebookEntryObj.UnitPrice;
        orderItemRecord.Quantity = 3;
        orderItemRecord.Available_to_Sell__c = pricebookEntryObj.Product2.Available_to_Sell__c;
        insert orderItemRecord; 
        
        //Insert Order Product for Warranty SKU
        OrderItem orderItemRecord1 = new OrderItem();
        orderItemRecord1.orderId = objOrd.Id;
        orderItemRecord1.PricebookEntryId = pricebookEntryObj1.Id;
        orderItemRecord1.UnitPrice = pricebookEntryObj1.UnitPrice;
        orderItemRecord1.Quantity = 2;
        orderItemRecord1.Available_to_Sell__c = pricebookEntryObj1.Product2.Available_to_Sell__c;
        insert orderItemRecord1;
        
        ProductExtended_warranty__c prodExtObj = new ProductExtended_warranty__c();
        prodExtObj.Parent_order_product__c = orderItemRecord.Id;
        prodExtObj.Warranty_order_product__c = orderItemRecord1.Id;
        prodExtObj.Order__c = objOrd.Id;
        insert prodExtObj;
        
        OrderItemTriggerHandler.afterTriggerRun = true;
        //List<OrderItem> orderItemRecord = [Select Id, LineStatus__c from OrderItem limit 1];
        orderItemRecord.LineStatus__c = 'Shipped';
        update orderItemRecord;
    }
}