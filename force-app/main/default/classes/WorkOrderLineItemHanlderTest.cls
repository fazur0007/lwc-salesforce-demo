@isTest(SeeAllData = false)
public with sharing class WorkOrderLineItemHanlderTest {
    
    @testSetup
    static void testSetup(){
    	
        //Insert Account
        Account objAcc = TestDataFactory.createAccountRecord('Test','Account', true);
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
    	objAcc.RecordTypeId = accountRecordTypeId;
    	
    	//User user = TestDataFactory.createUser('System Administrator','Call Center Manager USA','USD',true);
    	//user.IsPortalEnabled = true;
    	//user.accountid = objAcc.id;
    	//update user;
    	
    	
    	//System.runAs(user){
    		
    	Product2 objProd = TestDataFactory.createProduct('Product1','BES920XL',false,false,false,15,true, false);
        objProd.CurrencyIsoCode = 'USD';
        objProd.Serviceable__c = true;
    	insert objProd;
        
        //Product2 objProd1 = TestDataFactory.createProduct('Product2','800BLXL',true,false,true,15,true, true);
        //Product2 objProd = [SELECT Name, AX_Item_Number__c, Serviceable__c FROM Product2 WHERE Name='800BLXL' limit 1];
       	Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 objPricebook = new Pricebook2(Id=pricebookId);
        //Pricebook2 objPricebook = [select id from Pricebook2 where Brand__c='Breville' AND Subtype__c='Flat Service Charge' AND Region__c='USA' limit 1];

		 //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=pricebookId, Product2Id=objProd.Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'USD');
        //[SELECT Id FROM PricebookEntry where Product2Id= :objProd.id and Pricebook2Id = :objPricebook.Id];
        insert pricebookEntryObj;
        pricebookEntryObj.FreightCharge__c = 5.00;
        pricebookEntryObj.ServiceCharge__c = 4.00;
        pricebookEntryObj.ClaimCharge__c = 5.00;
        pricebookEntryObj.InspectionCharge__c = 6.00;
        pricebookEntryObj.LaborCharge__c = 7.00;
        update pricebookEntryObj;
        
	    Case caseRecord1 = TestDataFactory.createCase(objAcc.Id, 'Email', 'Open', 'subject 998', 'USD', objProd.Id, 'Feedback', 'Dented', '1051', true );    
        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
        workOrderObj.caseId = caseRecord1.Id;
        workOrderObj.status = 'Completed';
        workOrderObj.startDate = Date.today();
        workOrderObj.EndDate = Date.today();
        workOrderObj.Product__c = objProd.id;
        workOrderobj.PriceBook2Id = objPricebook.Id;
        workOrderObj.BatchCode__c = '1234';
        workOrderObj.PurchaseDate__c = Date.today();
        workOrderObj.CaseNumber__c = '461346';
        workOrderObj.FirstName__c = 'Joe';
        workOrderObj.LastName__c = 'John';
        workOrderObj.Email__c = 'John@example.com';
        workOrderObj.ServicePricebook__c = objPricebook.id;
        insert workOrderObj;
        
        WorkOrder workOrderObj2 = TestDataFactory.createWorkOrder('1234', 'USD', false);
        workOrderObj2.caseId = caseRecord1.Id;
        workOrderObj2.startDate = Date.today();
        workOrderObj2.EndDate = Date.today();
        workOrderObj2.recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Claim').getRecordTypeId(); 
        workOrderObj2.Product__c = objProd.id;
        workOrderobj2.PriceBook2Id = objPricebook.Id;
        workOrderObj2.BatchCode__c = '1234';
        workOrderObj2.PurchaseDate__c = Date.today();
        workOrderObj2.CaseNumber__c = '461346';
        workOrderObj2.FirstName__c = 'Joe';
        workOrderObj2.LastName__c = 'John';
        workOrderObj2.Email__c = 'John1@example.com';
        workOrderObj2.WorkOrder__c = workOrderObj.Id;
        workOrderObj2.ServicePricebook__c = objPricebook.id;
        insert workOrderObj2;
        System.debug('workorder1  : '+workOrderObj);
        System.debug('workorder2 : '+workOrderObj2);

        //Update WorkOrderLineItem
    	//workOrderLineItem.ClaimAmount__c = 20.00;
    	//workOrderLineItem.Tier__c = 'Tier 1';
    	//update workOrderLineItem;

    }
    
    static testMethod void testForTypeLaborCharge(){
    	
        //Insert WorkOrderLineItem
        PricebookEntry pricebookEntryObj = [Select id from PricebookEntry limit 1];
        WorkOrder workOrderObj2 = [Select id from WorkOrder where Email__c = 'John1@example.com' limit 1];
        
    	WorkOrderLineItem workOrderLineItem = TestDataFactory.createWorkOrderLineItemRecord(pricebookEntryObj.id, workOrderObj2.id,10,100.0, false);
    	workOrderLineItem.Type__c = 'Labor Charge';
    	workOrderLineItem.ClaimAmount__c = 10.00;
    	workOrderLineItem.Tier__c = 'Tier 1';
    	insert workOrderLineItem;    	
    }
    
    static testMethod void testForTypeFreightCharge(){
    	
        PricebookEntry pricebookEntryObj = [Select id from PricebookEntry limit 1];
        WorkOrder workOrderObj2 = [Select id from WorkOrder where Email__c = 'John1@example.com' limit 1];
    	
    	WorkOrderLineItem workOrderLineItem2 = TestDataFactory.createWorkOrderLineItemRecord(pricebookEntryObj.id, workOrderObj2.id,10,100.0, false);
    	workOrderLineItem2.Type__c = 'Freight Charge';
    	workOrderLineItem2.ClaimAmount__c = 20.00;
    	insert workOrderLineItem2;
    	
    }
    
    static testMethod void testForTypeInspectionCharge(){
    	
        PricebookEntry pricebookEntryObj = [Select id from PricebookEntry limit 1];
        WorkOrder workOrderObj2 = [Select id from WorkOrder where Email__c = 'John1@example.com' limit 1];
        
    	WorkOrderLineItem workOrderLineItem2 = TestDataFactory.createWorkOrderLineItemRecord(pricebookEntryObj.id, workOrderObj2.id,10,100.0, false);
    	workOrderLineItem2.Type__c = 'Inspection Charge';
        workOrderLineItem2.Tier__c = 'Tier 1';
    	workOrderLineItem2.ClaimAmount__c = 20.00;
    	insert workOrderLineItem2;
    	
    }
    
    static testMethod void testForTypeParts(){
    	
        PricebookEntry pricebookEntryObj = [Select id from PricebookEntry limit 1];
        WorkOrder workOrderObj2 = [Select id from WorkOrder where Email__c = 'John1@example.com' limit 1];
    	
    	WorkOrderLineItem workOrderLineItem1 = TestDataFactory.createWorkOrderLineItemRecord(pricebookEntryObj.id, workOrderObj2.id,10,100.0, false);
    	workOrderLineItem1.Type__c = 'Parts';
    	workOrderLineItem1.ClaimAmount__c = 15.00;
    	insert workOrderLineItem1;
   		Profile p = [SELECT Id FROM Profile WHERE Name='Service Repairer Community'];
     	List<User> usrList = [SELECT Id From User Where Name='Spuzdrowski' AND Alias='spuz' AND Email='spuzdrowski@eqaservice.com' AND UserRoleId='00E0y000001o3pw'];
        System.runAs(usrList[0]){
            WorkOrderLineItemHanlder.populateClaimAmountBasedOnTier(new List<WorkOrderLineItem>{workOrderLineItem1}, null, true, false);
        }
    }
}