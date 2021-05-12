public with sharing class CreateSparePartsOrderController {
    
    private ApexPages.StandardSetController setController;
    private ApexPages.StandardController stdController;
    public List<WorkOrder> workOrderList                {get;set;}
    public List<WrapperClass> wrapperList               {get;set;}
    private String brand;
    private Id accountId;
    private User currentUser;
    private Set<Id> productIdSet;
    
    public CreateSparePartsOrderController(ApexPages.StandardSetController setController) {
    	brand = 'Breville';
        this.setController = setController;
        workOrderList = new list<WorkOrder>();
        queryWorkOrders(setController.getSelected());
        
        if(!validateWorkOrderList()){
            wrapperList = new list<WrapperClass>();
            wrapperList = createLineItemList();
            
            if(wrapperList.isEmpty()){
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No Spare Parts found for the selected WorkOrders'));
            }
        }
    }
    
    public CreateSparePartsOrderController(ApexPages.StandardController stdController){
    	brand = 'Breville';
    	workOrderList = new list<WorkOrder>();
    	WorkOrder workOrderRecord = (WorkOrder)stdController.getRecord();
        
        queryWorkOrders(new list<WorkOrder>{workOrderRecord});
        if(!validateWorkOrderList()){
        	wrapperList = createLineItemList();
            
	        if(wrapperList.isEmpty()){
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No Spare Parts found for the selected WorkOrders'));
	        }
        }
        
    }
    
    public void queryWorkOrders(list<WorkOrder> workOrdersList){
    	workOrderList = [SELECT Id, RecordTypeId, ServiceCentre__c, Brand__c, Order__c FROM WorkOrder WHERE Id IN: workOrdersList];
    }
    
    public boolean validateWorkOrderList(){
        Boolean hasError = false;
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> brandSet = new Set<String>();
        Id workOrderRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Work Order').getRecordTypeId();
        for(WorkOrder workOrderRec : workOrderList){
        	if(workOrderRec.Brand__c != null){
	            brandSet.add(workOrderRec.Brand__c);
	            brand = workOrderRec.Brand__c;
        	}
        	if(workOrderRec.ServiceCentre__c != null){
            	accountIdSet.add(workOrderRec.ServiceCentre__c);
            	accountId = workOrderRec.ServiceCentre__c;
        	}
            if(workOrderRec.RecordTypeId != workOrderRecordTypeId){
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only WorkOrders can be selected'));
            }
        }
        if(accountIdSet.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'WorkOrders for multiple Account Selected'));
            hasError = true;
        }
        if(brandSet.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'WorkOrders for multiple Brands Selected'));
            hasError = true;
        }
        
        return hasError;
    }
    
    
    
    public list<WrapperClass> createLineItemList(){
    	productIdSet = new Set<Id>();
        Map<Id, WrapperClass> wrapperMap = new Map<Id, WrapperClass>();
        for(WorkOrderLineItem items: [SELECT Id, PricebookEntryId, Quantity, PricebookEntry.Product2.Name, PricebookEntry.Product2Id, PricebookEntry.Product2.Description,
        											PricebookEntry.Product2.Available_To_Sell__c
                                                FROM WorkOrderLineItem 
                                                WHERE WorkOrderId IN: workOrderList]){
            productIdSet.add(items.PricebookEntry.Product2Id);
            if(wrapperMap.containsKey(items.PricebookEntry.Product2Id) && items.Quantity != null && items.Quantity > 0){
                Double qty = wrapperMap.get(items.PricebookEntry.Product2Id).quantity;
                wrapperMap.get(items.PricebookEntry.Product2Id).quantity = qty + items.Quantity; 
            }else{
                wrapperMap.put(items.PricebookEntry.Product2Id, 
                								new WrapperClass(items.PricebookEntry.Product2.Name, items.PricebookEntry.Product2.Description, 
                									Double.valueOf(items.Quantity), items.PricebookEntry.Product2Id, items.PricebookEntry.Product2.Available_To_Sell__c));
            } 
        }
        return wrapperMap.values();
    }
    
    Public PageReference createsparePartOrder(){ 
    	list<WrapperClass> selectedWrapperList = new List<WrapperClass>();
        for(WrapperClass wrapperObj : wrapperList ){
        	if(wrapperObj.isSelected){
        		selectedWrapperList.add(wrapperObj);
        	}
        }
        if(selectedWrapperList != null && selectedWrapperList.size() > 0){
        	if(accountId != null){
        		List<User> curretUserList = [SELECT Id, IsPortalEnabled FROM User WHERE Id =: UserInfo.getUserId()];
        		currentUser = curretUserList[0];
        		Order orderRecord = createOrder();
        		
        		for(WorkOrder woRecord : workOrderList){
        			woRecord.Order__c = orderRecord.Id;
        		}
        		update workOrderList;
        		
        		PageReference pageRef = new PageReference(System.Url.getSalesforceBaseURL().toExternalForm() + Site.getPathPrefix() + '/' + orderRecord.Id);
		        pageRef.setRedirect(true);
		        return pageRef;
        	}else{
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error finding the Service Center'));
        	}
        }else{
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select items to add in an Order'));
        }
        return null;
    }
    
    public Order createOrder(){
    	String region;
    	list<OrderItem> OrderItemList = new list<OrderItem>();
    	list<Account> accountList = [SELECT Id, Name, BillingCity, BillingCountryCode, BillingPostalCode, BillingStateCode, BillingStreet, 
    										ShippingCountryCode, ShippingCity, ShippingPostalCode, ShippingStateCode, ShippingStreet, CurrencyIsoCode, VendAccount__c 
    										FROM Account 
    										WHERE Id =: accountId];
    	region = Utility.regionBased(accountList[0].CurrencyIsoCode);
    	
    	Order newOrder = new Order();
    	newOrder.AccountId = accountId;
    	newOrder.BillingCity = accountList[0].BillingCity;
    	newOrder.BillingCountryCode = accountList[0].BillingCountryCode;
    	newOrder.BillingPostalCode = accountList[0].BillingPostalCode;
    	newOrder.BillingStateCode = accountList[0].BillingStateCode;
    	newOrder.BillingStreet = accountList[0].BillingStreet;
    	newOrder.ShippingCountryCode = accountList[0].ShippingCountryCode;
    	newOrder.ShippingCity = accountList[0].ShippingCity;
    	newOrder.ShippingPostalCode = accountList[0].ShippingPostalCode;
    	newOrder.ShippingStateCode = accountList[0].ShippingStateCode;
    	newOrder.ShippingStreet = accountList[0].ShippingStreet;
    	newOrder.CurrencyIsoCode = accountList[0].CurrencyIsoCode;
    	newOrder.Ship_To_Name__c = accountList[0].Name;
    	newOrder.AX_Order_Account__c = accountList[0].VendAccount__c;
    	newOrder.EffectiveDate = Date.today();
    	if(currentUser.IsPOrtalEnabled){
    		newOrder.Type = 'Sale';
    	}else{
    		newOrder.Type = 'Repair Parts';
    	}
    	newOrder.status='Open';
    	newOrder.Brand__c = brand;
    	newOrder.Country__c = region;
    	
    	TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(newOrder);
        
        String priceBookType = 'Accommodation';
        if(currentUser.IsPOrtalEnabled){
        	priceBookType = 'Wholesale';
        }
        
        List<Pricebook2> pricebookList = [SELECT Id, Brand__c, Region__c, Type__c 
        												FROM Pricebook2 
        												WHERE Region__c =: region 
        												AND Brand__c =: brand 
        												AND Type__c =: priceBookType];
        if(pricebookList != null && pricebookList.size() > 0){
    		newOrder.PriceBook2Id = pricebookList[0].Id;
    		insert newOrder;
    	}else{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'PriceBook cannot be found'));
    		return null;
    	}
    	
    	if(wrapperList != null && wrapperList.size() > 0){
    		map<Id, PriceBookEntry> productIdToPriceBookEntryMap = new map<Id, PriceBookEntry>();
    		for(PriceBookEntry pbe : [SELECT Id, Product2Id, PriceBook2Id, UnitPrice 
    												FROM PriceBookEntry WHERE Product2Id IN: productIdSet AND PriceBook2Id =: newOrder.PriceBook2Id]){
    			productIdToPriceBookEntryMap.put(pbe.Product2Id, pbe);
    		}
    		if(productIdToPriceBookEntryMap != null && productIdToPriceBookEntryMap.size() > 0){
    			for(WrapperClass wrapperClassObj : wrapperList){
    				if(productIdToPriceBookEntryMap.containsKey(wrapperClassObj.productId)){
	    				OrderItem orderProduct = new OrderItem();
	    				orderProduct.OrderId = newOrder.Id;
	    				orderProduct.PriceBookEntryId = productIdToPriceBookEntryMap.get(wrapperClassObj.productId).Id;
	    				orderProduct.Quantity = wrapperClassObj.quantity;
	    				orderProduct.UnitPrice = productIdToPriceBookEntryMap.get(wrapperClassObj.productId).UnitPrice;
	    				OrderItemList.add(orderProduct);
    				}
    			}
    		}
    		
    		if(OrderItemList != null && OrderItemList.size() > 0){
    			insert OrderItemList;
    		}
    	}
    	
    	return newOrder;
    }
    
    public class WrapperClass{
        Public String productSKU                {get;set;}
        Public Id productId						{get;set;}
        Public String description               {get;set;}
        Public Double quantity                  {get;set;}
        Public Boolean isSelected               {get;set;}
        Public Boolean isAvailable				{get;set;}
        
        public WrapperClass(String SKUName, String description, Double qty, Id productId, Boolean available){
            this.productSKU = SKUName;
            this.quantity = qty;
            this.isSelected = true;
            this.description = description;
            this.productId = productId;
            this.isAvailable = available;
        }
    }
    
}