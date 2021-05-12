@isTest(SeeAllData=true)
public with sharing class ChargentPaymentTerminalExtnTest {
	static testMethod void testMethodChargentPaymentTerminalExtn(){

		list<Order> orderList = new list<Order>();
		
		ShippingAmount__c shippingAmmountRecord1 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND', 75, true, 'Employee Sale', true);
		ShippingAmount__c shippingAmmountRecord2 = TestDataFactory.createShippingAmount('USD', 50, 'UPS GRD', 75, true, 'Sale', true);
		ShippingAmount__c shippingAmmountRecord3 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND', 75, true, 'Sale', true);
		
		Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
		//Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
		Contact contactRecord = TestDataFactory.createContact(accountRecord.Id, 'NikhilContact99', true);
		//Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
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
		update accountRecord;
        
		Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
		Pricebook2 pricebookRecord = new Pricebook2();
		pricebookRecord =  [select id from Pricebook2 where Region__c='USA' and Type__c='Wholesale' limit 1];
		
		Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
		
		
		Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        if (!standard.isActive) {
            standard.isActive = true;
            update standard;
        }

       
        PricebookEntry standardPrice = new PricebookEntry();
	    standardPrice.pricebook2Id = standard.id;
	    standardPrice.product2id = productRecord.id;
	    standardPrice.unitprice = 1249.0;
	    standardPrice.isactive = true;
	    insert standardPrice;
	    
	    PricebookEntry standardPriceNew = new PricebookEntry();
	    standardPriceNew.pricebook2Id = pricebookRecord.id;
	    standardPriceNew.product2id = productRecord.id;
	    standardPriceNew.unitprice = 1250.0;
	    standardPriceNew.isactive = true;
	    insert standardPriceNew;
		
		RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
		Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
																	'411111111111111', 'Breville','USD');
		orderRecord1.OrderSubcategory__c = 'Employee Sale';
		//orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
		orderList.add(orderRecord1);
		insert orderList;
        
        
		//Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
		PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
		OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
	 		
	 		//Insert WorkOrder    		
			//WorkOrder workOrderObj = new WorkOrder(CaseId=caseObj.Id, AccountId=objAcc.Id,CurrencyIsoCode='USD',Pricebook2Id = objPricebook2.Id,ServiceCentre__c=objAcc.Id); 
			//insert workOrderObj;   
		
			//ChargentPaymentTerminalExtn chargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(orderObj.Id);
            // ChargentOrders__ChargentOrder__c newChargentOrder = chargentPaymentTerminalExtnInstance.chargentOrder;
            //ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c(Order__c=orderObj.Id,ChargentOrders__Account__c=objAcc.Id,
					            		// CurrencyIsoCode='USD',ChargentOrders__Invoice_Number__c='00205531', ChargentOrders__Tax__c=5, ChargentOrders__Shipping__c=7,
					            		// ChargentOrders__Charge_Amount__c=-100,ChargentOrders__Subtotal__c=50);
            //insert newChargentOrder;
        ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
		
		Test.startTest();
		
		PageReference pageRef = Page.ChargentPaymentTerminal;
	    Test.setCurrentPage(pageRef);
	    pageRef.getParameters().put('order_id', orderRecord1.Id);
	    ApexPages.StandardController sc = new ApexPages.StandardController(newChargentOrder);
	    ChargentPaymentTerminalExtn chargentPaymentTerminalExtnObj = new ChargentPaymentTerminalExtn(sc);
	    //ChargentPaymentTerminalExtn chargentPaymentTerminalExtnObj1 = new ChargentPaymentTerminalExtn(workOrderObj.Id);
		
		ChargentPaymentTerminalExtn chargentPaymentTerminalExtnObj2 = new ChargentPaymentTerminalExtn(orderRecord1.Id);
		
		chargentPaymentTerminalExtnObj.getOrderFieldMappingForOrder();
		chargentPaymentTerminalExtnObj.getWorkOrderFieldMappingForOrder();
		chargentPaymentTerminalExtnObj.getDefaultGetWayId();
		/*
		chargentPaymentTerminalExtnObj.getOrderFieldMappingForOrder();
		chargentPaymentTerminalExtnObj.getWorkOrderFieldMappingForOrder();
		chargentPaymentTerminalExtnObj.getDefaultGetWayId();
		*/
		
		//Insert WorkOrder    		
		WorkOrder workOrderObj = new WorkOrder(CaseId=caseRecord.Id, AccountId=accountRecord.Id,CurrencyIsoCode='USD',Pricebook2Id = pricebookRecord.Id,ServiceCentre__c=accountRecord.Id);
        workOrderObj.SalesTaxRate__c = 20;
        workOrderObj.PartsTotal__c =220;
        workOrderObj.UsedServiceTaxRate__c =2;
		insert workOrderObj;   
		pageRef.getParameters().put('order_id', workOrderObj.Id);
	    ApexPages.StandardController sc1 = new ApexPages.StandardController(newChargentOrder);
	    ChargentPaymentTerminalExtn chargentPaymentTerminalExtnObj3 = new ChargentPaymentTerminalExtn(sc1);
		ChargentPaymentTerminalExtn chargentPaymentTerminalExtnObj4 = new ChargentPaymentTerminalExtn(workOrderObj.Id);
		chargentPaymentTerminalExtnObj3.getOrderFieldMappingForOrder();
		chargentPaymentTerminalExtnObj3.getWorkOrderFieldMappingForOrder();
		chargentPaymentTerminalExtnObj3.getDefaultGetWayId();
		test.stopTest();
	}
}