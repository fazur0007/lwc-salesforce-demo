@isTest
public with sharing class BatchRMAReceiptPriceCalculationTest {
    
    static testMethod void testMethodBatchRMAReceiptPriceCalculation(){
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='RMA'];
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMA_Status__c = 'Credit Complete' ;
        caseObj.Account = objAcc;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.CurrencyIsoCode = 'USD';
        caseObj.Country__c = 'USA';
        upsert caseObj;
        
        System.debug('===caseObj==='+[Select RMA_Status__c, CurrencyIsoCode, Country__c from Case limit 2]);
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        insert objProd;   
        
        //Insert RMA
        RMA__c rmaObj = new RMA__c(Case__c=caseObj.Id);
        insert rmaObj;
        
        //Insert rma product
        RMA_Product__c rmaProduct = new RMA_Product__c();
        rmaProduct.Case__c = caseObj.Id;
        rmaProduct.CalculatedUnitPrice__c = 100;
        rmaProduct.Quantity__c = 1;
        insert rmaProduct;
        
        Receiving__c recObj = new Receiving__c(
                                                Received_Product__c=objProd.Id,
                                                Case__c=caseObj.id,
                                                Received_Qty__c=1,
                                                RMACalculatedUnitPrice__c=100,
                                                IsPriceCalculated__c=false,
                                                ErrorOccurredWhileCalculatingPrice__c=false,
                                                CurrencyIsoCode='USD',
                                                RMACalculatedTotalPrice__c=200,
                                                RMAProduct__c = rmaProduct.Id,
        										Received_Date__c = Date.today()
        										
                                              );
        
        recObj.Return_Location__c = 'USA PRC';
        recObj.Received_PDC__c = '1903';
        Test.startTest();
        insert recObj;
        //BatchRMAReceiptPriceCalculation.schduleBatch();
        
        
        // Set mock callout class
         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
         
         
         //Check success of response
         //Test.setMock(HttpCalloutMock.class, new RMAPriceMockImpl(200));
         Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(400,recObj.id));
         String batchExecute = Database.executeBatch(new BatchRMAReceiptPriceCalculation('USD'), 10);
         
        Test.stopTest();
    }
    
    static testMethod void testMethodBatchRMAReceiptPriceCalculation1(){
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='RMA'];
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMA_Status__c = 'Credit Complete' ;
        caseObj.Account = objAcc;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.CurrencyIsoCode = 'USD';
        caseObj.Country__c = 'USA';
        upsert caseObj;
        
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        insert objProd;   
        
        //Insert RMA
        RMA__c rmaObj = new RMA__c(Case__c=caseObj.Id);
        insert rmaObj;
        
        //Insert rma product
        RMA_Product__c rmaProduct = new RMA_Product__c();
        rmaProduct.Case__c = caseObj.Id;
        rmaProduct.CalculatedUnitPrice__c = 100;
        rmaProduct.Quantity__c = 1;
        insert rmaProduct;
        
        Receiving__c recObj = new Receiving__c(
                                                Received_Product__c=objProd.Id,
                                                Case__c=caseObj.id,
                                                Received_Qty__c=1,
                                                RMACalculatedUnitPrice__c=100,
                                                IsPriceCalculated__c=false,
                                                ErrorOccurredWhileCalculatingPrice__c=false,
                                                CurrencyIsoCode='USD',
                                                RMACalculatedTotalPrice__c=200,
                                                RMAProduct__c = rmaProduct.Id,
        										Received_Date__c = Date.today()
        										
                                              );
        
        recObj.Return_Location__c = 'USA PRC';
        recObj.Received_PDC__c = '1903';
        Test.startTest();
        insert recObj;
        //BatchRMAReceiptPriceCalculation.schduleBatch();
        
        
        // Set mock callout class
         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
         
         
         //Check success of response
         Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(200,recObj.id));
         //Test.setMock(HttpCalloutMock.class, new RMAPriceMockImpl(400));
         String batchExecute = Database.executeBatch(new BatchRMAReceiptPriceCalculation('USD'), 10);
         
        Test.stopTest();
    }
    
    static testMethod void testMethodBatchRMAReceiptPriceCalculationD365(){
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.AX_Item_Number__c  = 'SNE500BKS4EEU1';
        insert productRecord;
        
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
        
        Receiving__c recObj = new Receiving__c(
                                                Received_Product__c=productRecord.Id,
                                                Case__c=caseRecord.id,
                                                Received_Qty__c=1,
                                                RMACalculatedUnitPrice__c=100,
                                                IsPriceCalculated__c=false,
                                                ErrorOccurredWhileCalculatingPrice__c=false,
                                                CurrencyIsoCode='USD',
                                                RMACalculatedTotalPrice__c=200,
                                                RMAProduct__c = rm.Id,
        										Received_Date__c = Date.today()
        										
                                              );
        
        recObj.Return_Location__c = 'USA PRC';
        recObj.Received_PDC__c = '1903';
        Test.startTest();
        insert recObj;
        
         //Check success of response
         Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.TradeAgreementMock());
         //Test.setMock(HttpCalloutMock.class, new RMAPriceMockImpl(400));
         String batchExecute = Database.executeBatch(new BatchRMAReceiptPriceCalculation('USD'), 10);
         
        Test.stopTest();
    }
    
    static testMethod void testMethodBatchRMAReceiptPriceCalculationPersonAccountD365(){
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        Account accountRecord = new Account(Firstname = 'Test', Lastname='Test', CurrencyIsoCode= 'USD', RecordTypeId = accountRecordTypeId);
		insert accountRecord;        
        
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.AX_Item_Number__c  = 'SNE500BKS4EEU1';
        insert productRecord;
        
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
        
        Receiving__c recObj = new Receiving__c(
                                                Received_Product__c=productRecord.Id,
                                                Case__c=caseRecord.id,
                                                Received_Qty__c=1,
                                                RMACalculatedUnitPrice__c=100,
                                                IsPriceCalculated__c=false,
                                                ErrorOccurredWhileCalculatingPrice__c=false,
                                                CurrencyIsoCode='USD',
                                                RMACalculatedTotalPrice__c=200,
        										Received_Date__c = Date.today()
        										
                                              );
        
        recObj.Return_Location__c = 'USA PRC';
        recObj.Received_PDC__c = '1903';
        Test.startTest();
        insert recObj;
        
         //Check success of response
         Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.TradeAgreementMock());
         //Test.setMock(HttpCalloutMock.class, new RMAPriceMockImpl(400));
         String batchExecute = Database.executeBatch(new BatchRMAReceiptPriceCalculation('USD'), 10);
         
        Test.stopTest();
    }
    
    static testmethod void schedulerTest() {
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        BatchRMAReceiptPriceCalculation priceBatchForUSA = new BatchRMAReceiptPriceCalculation('USD');
               
        Test.startTest();

        //BatchRMAReceiptPriceCalculation.schduleBatch();
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, priceBatchForUSA);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertNotEquals(Null, jobId);

        Test.stopTest();
    }
    
    
    static testmethod void schedulerTestAll() {
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        Test.startTest();

        BatchRMAReceiptPriceCalculation.schduleBatch();

        Test.stopTest();
    }
}