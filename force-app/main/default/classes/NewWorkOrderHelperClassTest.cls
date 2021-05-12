@isTest
public with sharing class NewWorkOrderHelperClassTest {
    
     static testMethod void testNewWorkOrderHelperClass(){
     	
     	//Insert Product2
        Product2 objProd = new Product2(Name= 'Parent Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Serviceable__c = true;
        insert objProd; 
    	
    	//ID recordTypeRecord = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Work Order').getRecordTypeId();
    	
	        Account objAccount = new Account();
	        objAccount.Name = 'Test';
	        objAccount.ShippingStreet = 'GEORGIA ST';
	        objAccount.ShippingCity = 'VANCOUVER';
	        objAccount.ShippingStateCode = 'NT'; 
	        objAccount.ShippingCountryCode = 'CA';
	        objAccount.ShippingPostalCode = '123564';
	        objAccount.BillingPostalCode = '123456';
	        insert objAccount;
	        
	        //Insert Service Account
	        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
	        objServiceAcc.Type = 'Authorized Service Center';
	        insert objServiceAcc;
	        
	        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        //workOrderObj.RecordTypeId = recordTypeRecord;
	        workOrderObj.ServiceCentre__c = objServiceAcc.Id;
	        insert workOrderObj;
     	
     	ApexPages.StandardController sc = new ApexPages.standardController(workOrderObj);
     	NewWorkOrderHelperClass ctrl = new NewWorkOrderHelperClass(sc);
     	
     	//PageReference pg = ctrl.getRedirect();
     }
    
}