@isTest
public class BackOrderKeepOrCancelControllerTest{
	static Order orderRecord;
	static Order orderRecord2;			 
	
	static void testData(){
		Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.CurrencyIsoCode = 'USD';
    	insert productRecord;
        
        orderRecord = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today()); 
		orderRecord.Type = 'Sale';
		orderRecord.CustomerBackOrderResponse__c = false;
		insert orderRecord;
		
		orderRecord2 = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Cancelled',EffectiveDate=system.today()); 
		orderRecord2.Type = 'Accommodation';
		orderRecord2.CustomerBackOrderResponse__c = false;
		insert orderRecord2;
        
	}
	
	static testMethod void saveResponseTest(){
		Test.startTest();
		
		testData();
		ApexPages.currentPage().getParameters().put('oid','fakeId');
		BackOrderKeepOrCancelController testController1 = new BackOrderKeepOrCancelController();
		ApexPages.currentPage().getParameters().put('oid',orderRecord.Id);
		ApexPages.currentPage().getParameters().put('language','en');
		BackOrderKeepOrCancelController testController2 = new BackOrderKeepOrCancelController();
		testController2.customerResponse = 'No';
		testController2.saveResponse();		
		testController2.getOptionsList();
		
		ApexPages.currentPage().getParameters().put('oid',orderRecord2.Id);
		BackOrderKeepOrCancelController testController3 = new BackOrderKeepOrCancelController();
		testController3.customerResponse = 'No';
		testController3.saveResponse();	
		
		Order record = [SELECT Id, Status FROM Order WHERE Type = 'Sale'];
		System.assertEquals(record.Status, 'Cancelled');	

		Test.stopTest();
	}
}