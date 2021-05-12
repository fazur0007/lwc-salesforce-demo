@isTest(SeeAllData = true)
private class OrderBlockTest {
/*
    static testMethod void OrderItemTest() {
		list<Order> orderList = new list<Order>();
		list<OrderItem> orderItemList = new list<OrderItem>();
		Case[] caseArray = new List<Case>();
		Case[] caseArray2 = new List<Case>();
		
		Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
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
		Case caseRecord2 = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
		Pricebook2 pricebookRecord =  [select id from Pricebook2 where Region__c='USA' and Type__c='Sale' limit 1];
		
		RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
		Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sample',
																	'411111111111111', 'Breville','USD');
        System.debug('Created Order :: '+orderRecord1);
		//orderRecord1.OrderSubcategory__c = 'Sample';
		orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderList.add(orderRecord1); 
		
		Test.startTest();
		insert orderList;
		
		Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
		caseRecord.Product__c = productRecord.Id;
		caseRecord2.Product__c = productRecord.Id;
		update caseRecord;
		
		PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='.800BLXL' limit 1];
		OrderItem orderItemRecord1 = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
		OrderItem orderItemRecord2 = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
		OrderItem orderItemRecord3 = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
		OrderItem orderItemRecord4 = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
		OrderItem orderItemRecord5 = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
		
		orderItemList.add(orderItemRecord1);
		orderItemList.add(orderItemRecord2);
		orderItemList.add(orderItemRecord3);
		orderItemList.add(orderItemRecord4);
		orderItemList.add(orderItemRecord5);
		
		caseArray.add(caseRecord);
		caseArray2.add(caseRecord2); 
		
		OrderBlock testrecord = new OrderBlock();
		testrecord.onInsertAndUpdate(orderItemList);
		testrecord.onInsert(caseArray);
		testrecord.onUpdate(caseArray, caseArray2);
        //testrecord.updateOrderBlock(caseArray);
		
		Test.stopTest();
		
		
		
    }
 */
}