@isTest
public with sharing class WorkOrderTriggerHandlerTest {
    
    static testMethod void testMethodWorkOrderTriggerHandler(){
        
        Test.startTest();
        
        //Insert Account
        Account accountRecord = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BUS','nikhil998@example.com','9527785432');
        insert accountRecord; 
        
        //insert Service Account
		Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
		ServiceCentreAccount.BillingPostalCode = '440022';
		ServiceCentreAccount.ShippingPostalCode = '440022';
		insert ServiceCentreAccount;
		
        //Insert Product
		Product2 productRecord = TestDataFactory.createProduct('Product 998', true, false);
		productRecord.AX_Item_Number__c = '1234';
		productRecord.Serviceable__c = true;
		insert productRecord;
		
        //Insert Contact
        Contact contactRecord = TestDataFactory.createContact(ServiceCentreAccount.Id, 'palekar998', true);

        //Insert Portal User
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
	        User userRecord = new User();
	        Profile profile = [SELECT Id, Name FROM Profile where Name =: 'Specialty Roaster Community' LIMIT 1];
	        userRecord.UserName = 'TestUser' + String.valueOf(Datetime.now().getTime()) + '_' + UserInfo.getOrganizationId() + '@breville.com.test';
	        userRecord.profileId = profile.Id;
	        userRecord.Alias = 'a';
	        userRecord.CommunityNickname = 'b';
	        userRecord.Email = 'c@example.com';
	        userRecord.CurrencyIsoCode = 'USD';
	        userRecord.LastName = 'test';
	        userRecord.TimeZoneSidKey = 'GMT';
	        userRecord.LocaleSidKey = 'en_US';
	        userRecord.EmailEncodingKey = 'ISO-8859-1';
	        userRecord.LanguageLocaleKey = 'en_US';
	        userRecord.ContactId = contactRecord.id;
	        insert userRecord;
        }
		
        //Insert Case  
        Case caseRecord1 = TestDataFactory.createCase(accountRecord.Id, 'Email', 'Open', 'subject 998', 'USD', productRecord.Id, 'Feedback', 'Dented', '1051', true );
        Case caseRecord2 = TestDataFactory.createCase(accountRecord.Id, 'Email', 'Open', 'subject 997', 'USD', productRecord.Id, 'Feedback', 'Dented', '1050', true );
        
        //Insert PriceBook
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale', Brand__c='Breville');
        insert pricebookRecord;
        
        
        //Insert WorkOrders        
        list<WorkOrder> workOrderList = new list<WorkOrder>();
          
        WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(null, accountRecord.Id, 'USD', pricebookRecord.Id, ServiceCentreAccount.Id, 'workorder1@example.com','440022');
		list<Case> caseList = [select id, CaseNumber from Case where Subject='subject 998' limit 1];
		workOrderRecord1.CaseNumber__c = String.valueOf(caseList[0].CaseNumber);
		workOrderRecord1.InspectionCharge__c = 10;
		workOrderRecord1.LaborCharge__c = 20;
		workOrderRecord1.FreightCharge__c = 30;
		workOrderRecord1.FlatServiceCharge__c = 40;
		workOrderRecord1.Discounted_Inspection_Charge__c = 8;
		workOrderRecord1.Discounted_Labor_Charge__c = 18;
		workOrderRecord1.Discounted_Freight_Charge__c = 27;
		workOrderRecord1.Discounted_Flat_Service_Charge__c = 36;
		workOrderRecord1.Product__c = productRecord.Id;
        workOrderRecord1.BatchCode__c = 'T1';
        workOrderRecord1.PurchaseDate__c = Date.today();
        workOrderRecord1.Activated__c = true;
		workOrderList.add(workOrderRecord1);
		
		WorkOrder workOrderRecord2 = TestDataFactory.createWorkOrderRecord(caseRecord1.Id, accountRecord.Id, 'USD', pricebookRecord.Id, ServiceCentreAccount.Id, 'workorder2@example.com','440022');
		workOrderRecord2.Product__c = productRecord.Id;
        workOrderRecord2.BatchCode__c = 'T1';
        workOrderRecord2.PurchaseDate__c = Date.today();
        workOrderRecord2.ServiceCentre__c = ServiceCentreAccount.Id;
		workOrderList.add(workOrderRecord2);

		
		WorkOrder workOrderRecord3 = TestDataFactory.createWorkOrderRecord(null, accountRecord.Id, 'USD', pricebookRecord.Id, ServiceCentreAccount.Id, 'workorder3@example.com','440022');
		workOrderRecord3.FirstName__c = 'Nikhil';
		workOrderRecord3.LastName__c = 'Palekar998';
		workOrderRecord3.Email__c = 'nikhilPalekar998@example.com';
		workOrderRecord3.InspectionCharge__c = 10;
		workOrderRecord3.LaborCharge__c = 20;
		workOrderRecord3.FreightCharge__c = 30;
		workOrderRecord3.FlatServiceCharge__c = 40;
		workOrderRecord3.Product__c = productRecord.Id;
        workOrderRecord3.BatchCode__c = 'T1';
        workOrderRecord3.PurchaseDate__c = Date.today();
        workOrderRecord3.Activated__c = true;

		workOrderList.add(workOrderRecord3);
		
		WorkOrder workOrderRecord4 = TestDataFactory.createWorkOrderRecord(caseRecord1.Id, accountRecord.Id, 'USD', null, ServiceCentreAccount.Id, 'workorder3@example.com','440022');
		workOrderRecord4.Activated__c = true;
		workOrderList.add(workOrderRecord4);
		
		insert workOrderList;
		
		//Update Workorder
		WorkOrderTriggerHandler.beforeTriggerRun = true;
		WorkOrderTriggerHandler.afterTriggerRun = true;
		workOrderRecord2.Status = '	Closed';
        workOrderRecord2.Activated__c = true;
		update workOrderRecord2;
		
		
		Set<Id> setIds = new Set<Id>();
		setIds.add(ServiceCentreAccount.id);
		
		WorkOrderTriggerHandler.getPartnerUserIdByAccountId(setIds);
		WorkOrderShare workOrderShare = WorkOrderTriggerHandler.createWorkOrderShare(workOrderRecord2.id, thisUser.Id);
		
		Test.stopTest();		           
    }    
}