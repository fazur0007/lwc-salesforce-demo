@isTest(SeeAllData = true)
public with sharing class EditWorkOrderLineItemsExtnTest {
    
    static testMethod void testEditWorkOrderLineItemsExtn(){
    	
    	//Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1',true);
    	
    	
    	//Insert Product2
        Product2 objProd = new Product2(Name= 'Parent Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Serviceable__c = true;
        insert objProd; 
    	
    	//Insert Product2
        Product2 objProd1 = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd1.Serviceable__c = true;
        objProd1.Spare_Part__c = true;
        objProd1.Parent_SKU__c = objProd.id;
        
        insert objProd1;   
        
        
        //Product2 objProd = new Product2();
        //objProd = [select id from Product2 where IsStandard=true];
        	
        					
        Pricebook2 objPricebook = new Pricebook2();
        objPricebook = [select id from Pricebook2 where IsStandard=true];

		 //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook.Id, Product2Id=objProd1.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj; 
		
	        
        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
        workOrderObj.Product__c = objProd.id;
        workOrderObj.PriceBook2Id = objPricebook.Id;
        workOrderObj.BatchCode__c = '1234';
        workOrderObj.PurchaseDate__c = Date.today();
        workOrderObj.CaseNumber__c = '461346';
        workOrderObj.FirstName__c = 'Joe';
        workOrderObj.LastName__c = 'John';
        workOrderObj.Email__c = 'John@example.com';
        insert workOrderObj;
    	//Insert WorkOrderLineItem
    	WorkOrderLineItem workOrderLineItem = TestDataFactory.createWorkOrderLineItemRecord(pricebookEntryObj.id, workOrderObj.id,10,100.0, false);
    	workOrderLineItem.Type__c = 'Parts';
    	insert workOrderLineItem;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(workOrderObj);
	    EditWorkOrderLineItemsExtn editWorkOrderLineItemsExtnObj = new EditWorkOrderLineItemsExtn(sc);
	    
	    editWorkOrderLineItemsExtnObj.addLineItem();
	    editWorkOrderLineItemsExtnObj.remove();
	     //editWorkOrderLineItemsExtnObj.saveLineItems();
	     
	    List<SelectOption> options = editWorkOrderLineItemsExtnObj.getWorkOrderTypes();
    }
    
}