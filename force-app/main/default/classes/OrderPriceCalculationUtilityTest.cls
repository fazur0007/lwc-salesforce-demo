@isTest(SeeAllData = false)
public with sharing class OrderPriceCalculationUtilityTest 
{
    	
	static testMethod void testMethodOrderPriceCalculationUtilityFailure(){
	 	
	 	 //Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
       // Pricebook2 objPricebook2 = new Pricebook2();
       // objPricebook2 = [select id from Pricebook2 where IsStandard=true];
        Id standardPriceBookId = Test.getStandardPricebookId();
        
         //Insert Order    		
		Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='EUR',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = standardPriceBookId); 
		orderObj.Type = 'Sale';
		insert orderObj;   
           
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA'); 
        insert objProd;   
        					
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        pricebookEntryObj.CurrencyIsoCode='EUR';
        insert pricebookEntryObj;   
        
        //Insert OrderItem
     	OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
		//insert orderItemObj;
        
		Test.starttest();
	
		 // Set mock callout class
         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
         
         //Check failure of response
         Test.setMock(HttpCalloutMock.class, new OrderPriceAPIMockImpl(400,orderItemObj.id));
	     OrderPriceCalculationUtility.calculatePriceUtility(orderObj.Id);
	     
		Test.stoptest();
	
	}
    
    
    static testMethod void testMethodOrderPriceCalculationUtility(){
	 	
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
	 	 //Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
       // Pricebook2 objPricebook2 = new Pricebook2();
       // objPricebook2 = [select id from Pricebook2 where IsStandard=true];
        Id standardPriceBookId = Test.getStandardPricebookId();
        
         //Insert Order    		
		Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='AUD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = standardPriceBookId); 
		orderObj.Type = 'Sale';
		insert orderObj;   
           
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA'); 
        insert objProd;   
        					
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        pricebookEntryObj.CurrencyIsoCode='AUD';
        insert pricebookEntryObj;   
        
        //Insert OrderItem
     	OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
		//insert orderItemObj;
        
		Test.starttest();
	
		 // Set mock callout class
         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
         
         //Check failure of response
         Test.setMock(HttpCalloutMock.class, new OrderPriceAPIMockImpl(400,orderItemObj.id));
	     OrderPriceCalculationUtility.calculatePriceUtility(orderObj.Id);
	     
		Test.stoptest();
	
	}

	static testMethod void testAXProductPriceConnector(){
       
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
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA'); 
        insert objProd;   
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=objProd.Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'EUR');
        insert pbe;
        
        //Insert RMA
        RMA__c rmaObj = new RMA__c(Case__c=caseObj.Id);
        insert rmaObj;
        
        //Insert rma product
        RMA_Product__c rmaProduct = new RMA_Product__c();
        rmaProduct.Case__c = caseObj.Id;
        rmaProduct.Product__c = objProd.Id;
        rmaProduct.CalculatedUnitPrice__c = 100;
        rmaProduct.Quantity__c = 1;
        insert rmaProduct;
        List<RMA_Product__c> rmaProductList=new List<RMA_Product__c>();
        rmaProductList.add(rmaProduct);
        
        List<Contract> lstContract= TestDataFactory.createContract(
        objAcc.id, 5, Date.Today(), 3, 'Draft');
        lstContract[0].CurrencyIsoCode='EUR';
        insert lstContract;
        
        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(objAcc.Id, 'Open', date.today(), lstContract[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Sale';
        date dt = date.today().addDays(10);
        lstOrder[0].RequestedShipDate__c = dt;
        lstOrder[0].CurrencyIsoCode = 'EUR';
        lstOrder[0].Tax_Exempt_Order__c=true;
        insert lstOrder;
        
        
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, lstOrder[0].id, 400, 20, 1);
        lstOI[0].OrderId = lstOrder[0].id;
        lstOI[0].Order = lstOrder[0];
        insert lstOI;
        
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
        
        recObj.Return_Location__c = 'CAN DRP';
        recObj.AX_Warehouse__c='621';
        recObj.Received_PDC__c = '1903';
        insert recObj;
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(200,recObj.id));
        Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(200,lstOI[0].id));
        AXProductPriceConnector.calculatePrice(lstOI,objAcc);
        Test.stopTest();
    }
    
    static testMethod void testAXProductcalculatePriceD365(){
       
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
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
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'SNE500BKS4EEU1', false);
        lstProd[0].CurrencyIsoCode = 'EUR';
        lstProd[0].AX_Item_Number__c='SNE500BKS4EEU1';
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
        
        
        //Insert RMA Product
        List<RMA_Product__c> lstRMA = new List<RMA_Product__c>(); 
        RMA_Product__c rm = new RMA_Product__c(Case__c = listCase[0].id , Order__c =OID[0].id ,Quantity__c=200,CurrencyIsoCode='EUR');
        rm.Product__c = lstProd[0].Id;
        insert rm;
        lstRMA.add(rm);
        
        //Insert Receiving
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(listCase[0].id);
        Rcv.CurrencyIsoCode ='EUR';
        //Rcv.Account__c = lstAcc[0].Id;
        Rcv.Return_Location__c = 'CAN DRP';
        Rcv.AX_Warehouse__c='621';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c =lstProd[0].id;
        insert Rcv;
        lstRc.add(Rcv);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock());
        AXProductPriceConnector.calculatePriceD365(lstOI,lstAcc[0]);
        Test.stopTest();
    }
    
    static testMethod void testAXProductcalculatePriceForRMACase(){
       
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
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA'); 
        insert objProd;   
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=objProd.Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'EUR');
        insert pbe;
        
        //Insert RMA
        RMA__c rmaObj = new RMA__c(Case__c=caseObj.Id);
        insert rmaObj;
        
        //Insert rma product
        RMA_Product__c rmaProduct = new RMA_Product__c();
        rmaProduct.Case__c = caseObj.Id;
        rmaProduct.CalculatedUnitPrice__c = 100;
        rmaProduct.Quantity__c = 1;
        rmaProduct.Product__c=objProd.Id;
        insert rmaProduct;
        List<RMA_Product__c> rmaProductList=new List<RMA_Product__c>();
        rmaProductList.add(rmaProduct);
        
        List<Contract> lstContract= TestDataFactory.createContract(
        objAcc.id, 5, Date.Today(), 3, 'Draft');
        lstContract[0].CurrencyIsoCode='EUR';
        insert lstContract;
        
        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(objAcc.Id, 'Open', date.today(), lstContract[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Sale';
        date dt = date.today().addDays(10);
        lstOrder[0].RequestedShipDate__c = dt;
        lstOrder[0].CurrencyIsoCode = 'EUR';
        lstOrder[0].Tax_Exempt_Order__c=true;
        insert lstOrder;
        
        
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, lstOrder[0].id, 400, 20, 1);
        lstOI[0].OrderId = lstOrder[0].id;
        lstOI[0].Order = lstOrder[0];
        insert lstOI;
        
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
        
        
        recObj.Received_PDC__c = '1903';
        recObj.Return_Location__c = 'CAN DRP';
        recObj.AX_Warehouse__c='621';
        insert recObj;
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(200,recObj.id));
        Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(200,rmaProductList[0].id));
        AXProductPriceConnector.calculatePriceForRMACase(rmaProductList);
        Test.stopTest();
    }
    
    static testMethod void testAXProductcalculatePriceForRMACaseD365(){
       
       // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS60012';
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
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'SNE500BKS4EEU1', false);
        lstProd[0].CurrencyIsoCode = 'EUR';
        lstProd[0].AX_Item_Number__c = 'SNE500BKS4EEU1';
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
        Case caseData = TestDataFactory.createCase(lstAcc[0].Id, 'Phone', 'Open', 'Test RMA EUR', 'EUR', false);
        caseData.Account=lstAcc[0];
        listCase.add(caseData);
        insert listCase;
        
        
        //Insert RMA Product
        List<RMA_Product__c> lstRMA = new List<RMA_Product__c>(); 
        RMA_Product__c rm = new RMA_Product__c(Case__c = listCase[0].id , Order__c =OID[0].id ,Quantity__c=200,CurrencyIsoCode='EUR');
        rm.Product__c=lstProd[0].Id;
        insert rm;
        lstRMA.add(rm);
        
        //Insert Receiving
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(listCase[0].id);
        Rcv.CurrencyIsoCode ='EUR';
        //Rcv.Account__c = lstAcc[0].Id;
        Rcv.Return_Location__c = 'CAN DRP';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c =lstProd[0].id;
        Rcv.AX_Warehouse__c='621';
        insert Rcv;
        lstRc.add(Rcv);
        
        Test.startTest();
       Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock());
       
       list<RMA_Product__c> rmalst = [select id, Quantity__c, Case_Currency__c, Case__c,Case__r.AccountId, Case__r.PriceCalculationRequired__c, 
        							Case__r.Purchase_Invoice_No__c, CalculatedUnitPrice__c,Product__c, Product__r.AX_Item_Number__c, 
        						    Case__r.Account.VendAccount__c, Case__r.Account.DataAreaID__c, Case__r.Account.BusinessUnitFormula__c, Price__c, Case__r.CurrencyIsoCode  
        						    from RMA_Product__c where Case__c=:listCase];
       AXProductPriceConnector.calculatePriceForRMACaseD365(rmalst, null);
       Test.stopTest();
    }
	
}