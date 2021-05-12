@isTest(SeeAllData = false)
public with sharing class OrderItemTriggerHandlerTest {
    
    static testMethod void testMethodOrderItemTriggerHandler(){
        
                // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS00000';
        lstAcc[0].DataAreaID__c='BDE';
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
        
        //Insert Case
        List<case> listCase = new List<case>();
        Case lstCase = TestDataFactory.createCase(lstAcc[0].Id, 'Phone', 'Open', 'Test RMA EUR', 'EUR', false);
        listCase.add(lstCase);
        insert listCase;
        List<Case> cID = [select id from Case];
        
        
        //Insert RMA Product
        List<RMA_Product__c> lstRMA = new List<RMA_Product__c>(); 
        RMA_Product__c rm = new RMA_Product__c(Case__c = cID[0].id , Order__c =OID[0].id ,Quantity__c=200,CurrencyIsoCode='EUR');
        system.debug('rma product'+rm.getSObject('Case__r'));
        insert rm;
        lstRMA.add(rm);
        
        //Insert Receiving
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(cID[0].id);
        Rcv.CurrencyIsoCode ='EUR';
        //Rcv.Account__c = lstAcc[0].Id;
        Rcv.Return_Location__c = 'USA PRC';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c =lstProd[0].id;
        Rcv.AX_Warehouse__c ='236';
        insert Rcv;
        lstRc.add(Rcv);
        
        
    }
    
    static testMethod void testMethodupdateParentOrder(){
        insert new InventorySetting__c(AXAccounts__c='CUS30006');
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS00000';
        lstAcc[0].DataAreaID__c='BDE';
        lstAcc[0].Type='Retailer';
        insert lstAcc;
        
        List<Account> newLstAcc=TestDataFactory.createAccount('Test', 200);
        newLstAcc[0].VendAccount__c='CUS00000';
        newLstAcc[0].DataAreaID__c='BDE';
        newLstAcc[0].Type='Retailer';
        insert newLstAcc;
        
        // Insert Contract
        List<Contract> lstContract= TestDataFactory.createContract(
            lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        lstContract[0].CurrencyIsoCode='EUR';
        insert lstContract;
        
        //Insert Contract
        list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;
        
        List<Contract> newLstContract= TestDataFactory.createContract(
            newLstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        newLstContract[0].CurrencyIsoCode='USD';
        insert newLstContract;
        
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'BOV845BSSUSC', false);
        lstProd[0].CurrencyIsoCode = 'EUR';
        lstProd[0].Landed_Cost__c=200;
        insert lstProd;
        
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Accommodation';
        date dt = date.today().addDays(10);
        lstOrder[0].RequestedShipDate__c = dt;
        lstOrder[0].CurrencyIsoCode = 'EUR';
        insert lstOrder;
        List<Order> OID = [select id from Order];
        
        List<Order> newLstOrder = TestDataFactory.createOrder(newLstAcc[0].Id, 'Open', date.today().addDays(2), newLstContract[0].id, 1);
        newLstOrder[0].Pricebook2Id=standardPriceBookId;
        newLstOrder[0].Type = 'Sale';
        date dtNew = date.today().addDays(40);
        newLstOrder[0].RequestedShipDate__c = dtNew;
        newLstOrder[0].CurrencyIsoCode = 'USD';
        newLstOrder[0].AX_Order_Account__c = 'CUS30006';
        insert newLstOrder;
        
        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'EUR');
        insert pbe;
        
        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, OID[0].id, 400, 20, 1);
        lstOI[0].ExternalInvoiceID__c=newLstOrder[0].Id;
        lstOI[0].Picking_Ticket__c=newLstOrder[0].Id;
        lstOI[0].TrackingNumbers__c = 'Axh634443';
        lstOI[0].Carrier__c = 'erwe3434' ;
        lstOI[0].External_Order_ID__c=newLstOrder[0].Id;
        insert lstOI;
        
        OrderItem orderItemObj1 =  [select id,Quantity,UnitPrice,ExternalInvoiceID__c,Picking_Ticket__c,TrackingNumbers__c,Carrier__c,External_Order_ID__c,OrderId,CurrencyIsoCode
                                    from OrderItem where id =: lstOI[0].Id LIMIT 1];
        orderItemObj1.Quantity = 450;
        orderItemObj1.UnitPrice=3;
        orderItemObj1.External_Order_ID__c=lstOrder[0].Id;
        orderItemObj1.Picking_Ticket__c=lstOrder[0].Id;
        orderItemObj1.ExternalInvoiceID__c=lstOrder[0].Id;
        orderItemObj1.TrackingNumbers__c = 'Avb34443';
        orderItemObj1.Carrier__c = 'emrer3434' ;
        update orderItemObj1;
        List<OrderItem> NewlstOI=new List<OrderItem>();
        //   lstOI.add(orderItemObj1);
        NewlstOI.add(orderItemObj1);
        
        
        
        //Insert Case
        List<case> listCase = new List<case>();
        Case lstCase = TestDataFactory.createCase(lstAcc[0].Id, 'Phone', 'Open', 'Test RMA EUR', 'EUR', false);
        listCase.add(lstCase);
        insert listCase;
        List<Case> cID = [select id from Case];
        
        
        //Insert RMA Product
        List<RMA_Product__c> lstRMA = new List<RMA_Product__c>(); 
        RMA_Product__c rm = new RMA_Product__c(Case__c = cID[0].id , Order__c =OID[0].id ,Quantity__c=200,CurrencyIsoCode='EUR');
        system.debug('rma product'+rm.getSObject('Case__r'));
        rm.Product__c = lstProd[0].id;
        insert rm;
        lstRMA.add(rm);
        
        //Insert Receiving
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(cID[0].id);
        Rcv.CurrencyIsoCode ='EUR';
        //Rcv.Account__c = lstAcc[0].Id;
        Rcv.Return_Location__c = 'USA PRC';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c =lstProd[0].id;
        Rcv.AX_Warehouse__c ='236';
        insert Rcv;
        lstRc.add(Rcv);
        map<Id,OrderItem> oldMap=new map<Id,OrderItem>();
        oldMap.put(lstOI[0].Id,lstOI[0]);
        
        Test.startTest();
        System.debug('NewlstOI = '+NewlstOI+' oldMap = '+oldMap);
        OrderItemTriggerHandler.populateSplitShipmentDetails(NewlstOI,oldMap);
        test.stopTest();
        
        
    }

    static testMethod void testMethodautoRegistrationforFinishedGoods(){
                //Insert Account
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
        
        Test.startTest();
        OrderItemTriggerHandler.afterTriggerRun = true;
        //List<OrderItem> orderItemRecord = [Select Id, LineStatus__c from OrderItem limit 1];
        orderItemRecord.LineStatus__c = 'Shipped';
        update orderItemRecord;

        test.stopTest();
        List<Asset> assetObj = [Select Id, EW_Present__c, EW_Start__c, EW_End__c, EW_Paid__c From Asset where ParentOrder__c =: objOrd.Id];
        System.assertEquals(3, assetObj.size());
        System.assertEquals(True, assetObj[0].EW_Present__c);
        System.assertEquals(True, assetObj[1].EW_Present__c);
        System.assertEquals(False, assetObj[2].EW_Present__c);
        
        System.assertNotEquals(Null, assetObj[0].EW_Start__c);
        System.assertNotEquals(Null, assetObj[0].EW_End__c);
        System.assertEquals(50.33, assetObj[0].EW_Paid__c);
        
        System.assertEquals(Null, assetObj[2].EW_Start__c);
        System.assertEquals(Null, assetObj[2].EW_End__c);
        System.assertEquals(Null, assetObj[2].EW_Paid__c);
        
    }
    
    static testMethod void testMethodupdateAssetExistingRegProduct(){
        //Insert Account
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
        
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Test';
        assetObj.Batch_Code__c = '1920';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 12;
        assetObj.AccountId = objAcc.Id;
        insert assetObj;
        
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
        objOrd.Asset__c = assetObj.Id;
        insert objOrd;  
                
        //Insert Order Product for Warranty SKU
        OrderItem orderItemRecord1 = new OrderItem();
        orderItemRecord1.orderId = objOrd.Id;
        orderItemRecord1.PricebookEntryId = pricebookEntryObj1.Id;
        orderItemRecord1.UnitPrice = pricebookEntryObj1.UnitPrice;
        orderItemRecord1.Quantity = 1;
        orderItemRecord1.Available_to_Sell__c = pricebookEntryObj1.Product2.Available_to_Sell__c;
        insert orderItemRecord1;

        
        Test.startTest();
        OrderItemTriggerHandler.afterTriggerRun = true;
        orderItemRecord1.LineStatus__c = 'Shipped';
        update orderItemRecord1;
        test.stopTest();
        
		Asset assetObjUpdated = [Select Id, EW_Present__c, EW_Start__c, EW_End__c, EW_Paid__c From Asset where Id =: assetObj.Id];
        
        System.assertEquals(True, assetObjUpdated.EW_Present__c);
        System.assertNotEquals(Null, assetObjUpdated.EW_Start__c);
        System.assertNotEquals(Null, assetObjUpdated.EW_End__c);
        System.assertEquals(50.33, assetObjUpdated.EW_Paid__c);
    }
}