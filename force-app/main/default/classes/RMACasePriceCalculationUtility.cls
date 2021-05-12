global class RMACasePriceCalculationUtility {

    

	WebService static void calculatePriceUtility(Id caseRecord){
        list<Case> newCaseRecord = new list<Case>();
        list<RMA_Product__c> updatedOrderItemList = new list<RMA_Product__c>();
        list<RMA_Product__c> orderItemsList = [select id, Quantity__c, Case_Currency__c, Case__c,Case__r.AccountId, Case__r.PriceCalculationRequired__c, 
        							Case__r.Purchase_Invoice_No__c, CalculatedUnitPrice__c,Product__c, Product__r.AX_Item_Number__c, 
        						    Case__r.Account.VendAccount__c, Case__r.Account.DataAreaID__c, Case__r.Account.BusinessUnitFormula__c, Price__c, Case__r.CurrencyIsoCode  
        						    from RMA_Product__c where Case__c=:caseRecord];
       
        newCaseRecord = [select Id, AccountId, PriceCalculationRequired__c, Purchase_Invoice_No__c, CurrencyIsoCode, CreatedDate from Case where Id=:caseRecord limit 1];
      
      
    	/*
    	updatedOrderItemList = AXProductPriceConnector.calculatePriceForRMACase(orderItemsList);
       
        newCaseRecord[0].PriceCalculationRequired__c = false;
        update updatedOrderItemList;
        update newCaseRecord;
      
        */
      
      
      if(orderItemsList != null && orderItemsList.size()>0){     					
            if(newCaseRecord != null && newCaseRecord.size()>0){
                if (Utility.isD365Enabled(newCaseRecord[0])) {
                    updatedOrderItemList = AXProductPriceConnector.calculatePriceForRMACaseD365(orderItemsList, null);
                } else {
                    updatedOrderItemList = AXProductPriceConnector.calculatePriceForRMACase(orderItemsList);
                }
             }
        }
        
        if (newCaseRecord != null && newCaseRecord.size()>0){
            newCaseRecord[0].PriceCalculationRequired__c = false;
        }

        //TaxRate taxRate = new TaxRate();
        //taxRate.filterOrders(newOrderRecord[0]);
        if (!Test.isRunningTest()) {
            update updatedOrderItemList;
	        update newCaseRecord[0]; 
        }
    }
}