public with sharing class EditWorkOrderLineItemsExtn {
    public WorkOrder workorderRec 									{get;set;}
    public list<WorkOrderLineItem> workOrderLineItems 				{get;set;}
    private PricebookEntry pricebookEntry 							{get;set;}
    
    public EditWorkOrderLineItemsExtn(ApexPages.StandardController stdController){
    	
    	if (!Test.isRunningTest()) {
        list<String> workOrderFields = new list<String>{
    													'Case.Product__c',
    													'Pricebook2Id'
    													};
    	stdController.addFields(workOrderFields);
    }
    	
    	
    	
    	workorderRec = (WorkOrder)stdController.getRecord();
    	if(workorderRec != null && workorderRec.Id != null){
    		
    		workOrderLineItems = [SELECT id,WorkOrderId,Quantity,Product2Id,Type__c,
    										Discount,ListPrice,UnitPrice,Description 
    								FROM WorkOrderLineItem 
    								WHERE WorkOrderId =: workorderRec.Id];
    		if(workOrderLineItems == null){
    			workOrderLineItems = new list<WorkOrderLineItem>(); 
    		}
    	}
    	
    }
    
   
    
    public void addLineItem(){
    	
    	String workOrderType = ApexPages.currentPage().getParameters().get('type');
    	if(pricebookEntry == null){
    		setPriceBookEntry();
    	}
    	map<String,String> priceFieldMapbyType  = getPriceAndTypeMapping();
    	
    	WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem();
    	workOrderLineItem.type__c = workOrderType;
    	workOrderLineItem.Quantity = 1;
    	if(priceFieldMapbyType.containsKey(workOrderType) && priceFieldMapbyType.get(workOrderType) != ''){
    		workOrderLineItem.UnitPrice = (Decimal)pricebookEntry.get(priceFieldMapbyType.get(workOrderType));
    		workOrderLineItem.Product2Id = workorderRec.Case.Product__c ;
    	}
    	workOrderLineItems.add(workOrderLineItem);
    	
    	
    }
    public void setPriceBookEntry(){
    	
    	list<PricebookEntry> priceBookEntries =  [SELECT Id, Pricebook2Id, Product2Id, LaborCharge__c, FreightCharge__c, InspectionCharge__c,UnitPrice 
    												FROM PricebookEntry 
    												WHERE Product2Id =: workorderRec.Case.Product__c 
    												AND Pricebook2Id =: workorderRec.Pricebook2Id];
    												
    	if(priceBookEntries != null && priceBookEntries.size() > 0){
    		pricebookEntry = priceBookEntries[0];
    	}else{
    		pricebookEntry = new PricebookEntry();
    	}
    }
    public void remove(){
    	String removeIndex = ApexPages.currentPage().getParameters().get('removeindex');
    	if(removeIndex != null && removeIndex != ''){
    		workOrderLineItems.remove(Integer.valueOf(removeIndex));
    	}
    } 
    public void saveLineItems(){
    	upsert workOrderLineItems;
    }
    public  List<SelectOption> getWorkOrderTypes(){
    	return  Utility.getPickValues(new WorkOrderLineItem(), 'Type__c', null); 
    }
    
    public map<String,String> getPriceAndTypeMapping(){
    	map<String,String> priceFieldMapbyType = new  map<String,String>();
    	priceFieldMapbyType.put('Parts','');
    	priceFieldMapbyType.put('Freight Charge','FreightCharge__c');
    	priceFieldMapbyType.put('Inspection Charge','InspectionCharge__c');
    	priceFieldMapbyType.put('Labor Charge','LaborCharge__c');
 		return priceFieldMapbyType;
    }
}