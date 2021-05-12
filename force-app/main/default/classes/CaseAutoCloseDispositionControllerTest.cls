@isTest
private class CaseAutoCloseDispositionControllerTest{
	
	static Case caseRecord;
	static Case caseRecord2;			 
	
	static void testData(){
		Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.CurrencyIsoCode = 'USD';
    	insert productRecord;
    	caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case1','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        //caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = true;
        caseRecord.Country__c = 'USA';
        insert caseRecord;
        
        caseRecord2 = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case1','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord2.Warranty__c ='In Warranty';
        //caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord2.RA_Delivered__c = true;
        caseRecord2.Country__c = 'USA';
        insert caseRecord2;
        
        Order orderRecord = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today()); 
		orderRecord.Type = 'Sale';
		orderRecord.Case__c = caseRecord.Id;
		insert orderRecord;
		
		WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(null, accountRecord.Id, 'USD', null, null, 'workorder1@example.com','440022');
		workOrderRecord1.caseId = caseRecord2.Id;
		insert workOrderRecord1;
        
	}
	
	static testMethod void saveResponseTest(){
		Test.startTest();
		
		testData();
		ApexPages.currentPage().getParameters().put('cid',caseRecord.Id);
		ApexPages.currentPage().getParameters().put('language','en');
		CaseAutoCloseDispositionController testController = new CaseAutoCloseDispositionController();
		testController.saveResponse();
		testController.customerResponse = 'Hold your case open';
		testController.comment = 'Test comment';
		testController.OrderWorkOrderResponse = 'Yes';
		testController.saveResponse();
		testController.validateResponse();
		testController.showOrderWorkOrderQuestion();
		testController.customerResponse = 'Close the case, everything is working';
		testController.OrderWorkOrderResponse = 'No';
		testController.saveResponse();
		testController.validateResponse();
		testController.showOrderWorkOrderQuestion();
		testController.customerResponse = 'Request a follow up from your support rep';
		testController.OrderWorkOrderResponse = 'Yes';
		testController.saveResponse();
		testController.validateResponse();
		testController.showOrderWorkOrderQuestion();
		testController.customerResponse = 'I do not have the product any longer';
		testController.OrderWorkOrderResponse = 'No';
		testController.saveResponse();
		testController.validateResponse();
		testController.showOrderWorkOrderQuestion();

		testController.getOptionsList();
		testController.getOptionsListAboutCase();

		ApexPages.currentPage().getParameters().put('cid',caseRecord2.Id);
		ApexPages.currentPage().getParameters().put('language','en');
		CaseAutoCloseDispositionController testController2 = new CaseAutoCloseDispositionController();
		testController2.saveResponse();
		testController2.customerResponse = 'Hold your case open';
		testController2.comment = 'Test comment';
		testController2.OrderWorkOrderResponse = 'Yes';
		testController2.saveResponse();
		testController2.validateResponse();
		testController2.showOrderWorkOrderQuestion();
		testController2.customerResponse = 'Close the case, everything is working';
		testController2.OrderWorkOrderResponse = 'No';
		testController2.saveResponse();
		testController2.validateResponse();
		testController2.showOrderWorkOrderQuestion();
		testController2.customerResponse = 'Request a follow up from your support rep';
		testController2.OrderWorkOrderResponse = 'Yes';
		testController2.saveResponse();
		testController2.validateResponse();
		testController2.showOrderWorkOrderQuestion();
		testController2.customerResponse = 'I do not have the product any longer';
		testController2.OrderWorkOrderResponse = 'No';
		testController2.saveResponse();
		testController2.validateResponse();
		testController2.showOrderWorkOrderQuestion();

		Test.stopTest();
	}
	
}