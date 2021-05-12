@isTest(SeeAllData=true)
public class BackOrderNotificationBatchTest{
	static Order orderRecord;
	static Order orderRecord2;			 
	
	static void testData(){
		Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.CurrencyIsoCode = 'USD';
		productRecord.Quantity_Available__c = 0;
		productRecord.AX_Item_Number__c='ZBBL800BSS1BCA1';
    	insert productRecord;
    	
    	Pricebook2 objPricebook2 = new Pricebook2();
        objPricebook2 = [select id from Pricebook2 where IsStandard=true];
        
        orderRecord = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today()); 
		orderRecord.Type = 'Sale';
		orderRecord.CustomerBackOrderResponse__c = false;
		orderRecord.NextNotificationDate__c = Date.today();
		orderRecord.Pricebook2Id = objPricebook2.Id;
		insert orderRecord;
		
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2.Id, Product2Id=productRecord.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
     	OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderRecord.Id, 400,20,true);
     	
     	orderRecord.CC_Authorization_ID__c = '11234';
     	orderRecord.Shipping_Method__c = 'FX-2NDD';
     	
		orderRecord.ActivatedByPartner__c = true;
		update orderRecord;
		
		
	}
	
	static testMethod void saveResponseTest(){
		Test.startTest();
		
		testData();
		If(!Test.isRunningTest()){
			Id batchId = Database.executeBatch(new BackOrderNotificationBatch(), 200);
		}
		Test.stopTest();
	}
}