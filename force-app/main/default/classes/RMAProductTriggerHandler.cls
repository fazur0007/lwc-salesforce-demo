public with sharing class RMAProductTriggerHandler {
    
    public static boolean beforeTriggerRun = true;
    public static boolean afterTriggerRun = true;
    public static boolean runOnceBeforeTrigger(){
        if(beforeTriggerRun){
            beforeTriggerRun = false;
            return true;
        }else{
            return beforeTriggerRun;
        }
    }
    public static boolean runOnceAfterTrigger(){
        if(afterTriggerRun){
            afterTriggerRun = false;
            return true;
        }else{
            return afterTriggerRun;
        }
    }
    
    public static void updatePriceCalculationPendingFlag(list<RMA_Product__c> rmaProductList,map<Id,RMA_Product__c> oldmap,Boolean isInsert){
        
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        
        for(RMA_Product__c rmaProduct : rmaProductList){
            if(isInsert){
                caseIdSet.add(rmaProduct.Case__c);
            }else if(rmaProduct.Product__c != oldmap.get(rmaProduct.Id).Product__c ){
                caseIdSet.add(rmaProduct.Case__c); 
            }
        }
        
        
        if(caseIdSet != null && caseIdSet.size() > 0){
            for(Id caseId : caseIdSet){
                caseListToUpdate.add(new Case(Id = caseId, PriceCalculationRequired__c = true));
            }
            
            if(caseListToUpdate != null && caseListToUpdate.size() > 0){
                update caseListToUpdate;
            }
        }
        
    }
    
    public static void populateRMAProductUniqueId(List<RMA_Product__c> newRMAProducts) {
    	Set<Id> productIds = new Set<Id>();
    	Set<Id> caseIds = new Set<Id>();
    	for(RMA_Product__c rmaProduct : newRMAProducts){
    		productIds.add(rmaProduct.Product__c);
    		caseIds.add(rmaProduct.Case__c);
    	}
    	Map<Id, Product2> rmaProductToProductMap = new Map<Id, Product2>([Select Id, AX_Unique_ID__c From Product2 Where Id IN :productIds]);
    	Map<Id, Case> rmaProductToCaseMap = new Map<Id, Case>([Select Id, CaseNumber From Case Where Id IN :caseIds]);
    	for(RMA_Product__c rmaProduct : newRMAProducts){
    		if(rmaProductToCaseMap.containsKey(rmaProduct.Case__c) && rmaProductToProductMap.containsKey(rmaProduct.Product__c)) {
	    		if(rmaProductToProductMap.get(rmaProduct.Product__c).AX_Unique_ID__c != null) {
	    			rmaProduct.RMA_Product_Unique_Id__c = rmaProductToCaseMap.get(rmaProduct.Case__c).CaseNumber 
	    													+ rmaProductToProductMap.get(rmaProduct.Product__c).AX_Unique_ID__c;
	    		}
    		}
    	}
    } 
}