global class NotifyMeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    private String currencyISOCode;
    private String soqlQuery;
    map<String, Integer> axUniqueIdToUsedQuantityCCC = new map<String, Integer>();
    map<String, Integer> axUniqueIdToUsedQuantityECOMM = new map<String, Integer>();
    
    public NotifyMeBatch(){
    }
    
    public NotifyMeBatch(String currencyISOCode){
        this.currencyISOCode = currencyISOCode;
        list<All_Literal__mdt> condition = [Select Value__c from All_Literal__mdt where Label='AddCondnNotifyMeBatch'];
        
        String query = 'Select Id, ax_item_number__c, Country_code__c, product_available__c, currencyIsoCode, email__c, email_sent__c, Channel__c from Product_Preference__c where email_sent__c= null AND product_available__c=false AND CurrencyIsoCode=:CurrencyIsoCode ';
        
        if(String.isNotBlank(condition[0].Value__c)) {
        	query += condition[0].Value__c;
        }
        this.soqlQuery = query;
    }
    
    global static void schduleBatch(){
        
        NotifyMeBatch notifyMeBatchForUSA = new NotifyMeBatch('USD');
        String jobIDForUSA = system.schedule('NotifyMeBatch JobUSA', '0 0 8 1/1 * ? *', notifyMeBatchForUSA);
        
        NotifyMeBatch notifyMeBatchForCAN = new NotifyMeBatch('CAD');
        String jobIDForCAN = system.schedule('NotifyMeBatch JobCAN', '0 0 5 1/1 * ? *', notifyMeBatchForCAN);
        
        NotifyMeBatch notifyMeBatchForAUS = new NotifyMeBatch('AUD');
        String jobIDForAUS = system.schedule('NotifyMeBatch JobAUS', '0 0 13 1/1 * ? *', notifyMeBatchForAUS);
        
        NotifyMeBatch notifyMeBatchForNZ = new NotifyMeBatch('NZD');
        String jobIDForNZ = system.schedule('NotifyMeBatch JobNZ', '0 0 11 1/1 * ? *', notifyMeBatchForNZ);
        
        NotifyMeBatch notifyMeBatchForUK = new NotifyMeBatch('GBP');
        String jobIDForUK = system.schedule('NotifyMeBatch JobUK','0 0 0 1/1 * ? *', notifyMeBatchForUK);
        
        NotifyMeBatch notifyMeBatchForDE = new NotifyMeBatch('EUR');
        String jobIDForDE = system.schedule('NotifyMeBatch JobDE', '0 0 23 1/1 * ? *', notifyMeBatchForDE);
        
        NotifyMeBatch notifyMeBatchForCH = new NotifyMeBatch('CHF');
        String jobIDForCH = system.schedule('NotifyMeBatch JobCH', '0 15 23 1/1 * ? *', notifyMeBatchForCH);
        
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 200);
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,List<Product_Preference__c> productPreferenceList){
    	system.debug('axUniqueIdToUsedQuantityCCC ::::: '+ axUniqueIdToUsedQuantityCCC);
        system.debug('axUniqueIdToUsedQuantityECOMM ::::: '+ axUniqueIdToUsedQuantityECOMM);
        set<String> axItemNumberCCCList = new set<String>();
        set<String> axItemNumberECOMMList = new set<String>();
        Map<String, List<Product_preference__c>> axUniqueIdToProductPreferenceMap = new Map<String, List<Product_preference__c>>();
        list<Product_Preference__c> productPreferenceToUpdate = new list<Product_Preference__c>();
        map<String, Integer> axUniqueIdToConsideredQuantityCCC = new map<String, Integer>();
        map<String, Integer> axUniqueIdToConsideredQuantityECOMM = new map<String, Integer>();
        
        /*getting Quantity to condider for to notify and creating map for CCC and ECOMM products*/
        Decimal NotifyMeQuantityToConsiderInPercentage;
        list<All_Literal__mdt> literalRec = [SELECT Value__c, DeveloperName FROM All_Literal__mdt WHERE DeveloperName ='NotifyMeQuantityToConsider' ];
  		if(literalRec != null && literalRec.size() > 0){
    		NotifyMeQuantityToConsiderInPercentage = Decimal.valueOf(literalRec[0].Value__c);
 		}
        /*creating products to list of Product Preference map*/
        for(Product_Preference__c preferenceRecord: productPreferenceList){
            
            if(preferenceRecord.ax_item_number__c != null && preferenceRecord.ax_item_number__c != '' && preferenceRecord.currencyIsoCode != null && 
                    preferenceRecord.currencyIsoCode != ''){
                
                if(preferenceRecord.Channel__c == 'ECOMM'){
                    axItemNumberECOMMList.add(preferenceRecord.ax_item_number__c);
                }else if(preferenceRecord.Channel__c == 'CCC'){
                    axItemNumberCCCList.add(preferenceRecord.ax_item_number__c);
                }
                String axUniqueId = Utility.fetchBusinessUnitFromCountryCode(preferenceRecord.Country_code__c) + preferenceRecord.ax_item_number__c;
                if(!axUniqueIdToProductPreferenceMap.containsKey(axUniqueId)){
                    axUniqueIdToProductPreferenceMap.put(axUniqueId, new list<Product_Preference__c>{preferenceRecord});
                }else{
                	axUniqueIdToProductPreferenceMap.get(axUniqueId).add(preferenceRecord);
                }
                
            }
        }

        list<Product2> productList = [SELECT Id, CurrencyIsoCode, AX_Item_Number__c, Quantity_Available__c, Quantity_Available_Web__c, AX_Unique_ID__c, Available_To_Sell__c FROM 
        								Product2 WHERE AX_Unique_ID__c IN :axUniqueIdToProductPreferenceMap.keySet()];
        
        /* iterating products to get total quantity to consider for CCC and ECOMM records*/
        for(Product2 productRecord : productList){
            
            Decimal availableQuantityCCC = 0;
            Decimal availableQuantityECOMM = 0;
            
            if(productRecord.Quantity_Available__c != null){
                availableQuantityCCC = productRecord.Quantity_Available__c;
            }
            
            if(productRecord.Quantity_Available_Web__c != null){
                availableQuantityECOMM = productRecord.Quantity_Available_Web__c;
            }
           
            Decimal cccPreferenceProductsToConsiderTemp = 0;
            Decimal eCommPreferenceProductsToConsiderTemp = 0;
            
            
            if(availableQuantityCCC != null && availableQuantityCCC > 0){
                cccPreferenceProductsToConsiderTemp = availableQuantityCCC*(NotifyMeQuantityToConsiderInPercentage/100);
            }
            if(availableQuantityECOMM != null && availableQuantityECOMM > 0){
                eCommPreferenceProductsToConsiderTemp = availableQuantityECOMM*(NotifyMeQuantityToConsiderInPercentage/100);
            } 
            Integer cccPreferenceProductsToConsider = Integer.valueOf(cccPreferenceProductsToConsiderTemp.round(System.RoundingMode.HALF_UP));
            Integer eCommPreferenceProductsToConsider = Integer.valueOf(eCommPreferenceProductsToConsiderTemp.round(System.RoundingMode.HALF_UP));
           
            axUniqueIdToConsideredQuantityCCC.put(productRecord.AX_Unique_ID__c, cccPreferenceProductsToConsider); 
            axUniqueIdToConsideredQuantityECOMM.put(productRecord.AX_Unique_ID__c, eCommPreferenceProductsToConsider );
        }
        
        if(axUniqueIdToProductPreferenceMap != null && axUniqueIdToProductPreferenceMap.size() > 0){
        	/*iterating through every product*/
            for(String uniqueId : axUniqueIdToProductPreferenceMap.keySet()){
                
                Integer cccPreferenceProductsToConsider = 0;
                Integer eCommPreferenceProductsToConsider = 0;
                
                /*getting CCC Product Preference to Condider*/
                if(axUniqueIdToConsideredQuantityCCC != null && axUniqueIdToConsideredQuantityCCC.containsKey(uniqueId)){
                    cccPreferenceProductsToConsider = axUniqueIdToConsideredQuantityCCC.get(uniqueId);
                }
                /*getting ECOMM Product Prefereces to Consider*/
                if(axUniqueIdToConsideredQuantityECOMM != null && axUniqueIdToConsideredQuantityECOMM.containsKey(uniqueId)){
                    eCommPreferenceProductsToConsider = axUniqueIdToConsideredQuantityECOMM.get(uniqueId);
                }
                Integer tempQuantityCCC = 0;
                Integer tempQuantityECOMM = 0;
                /*iterating through Product Preference records for each product*/
                for(Product_Preference__c productPreferenceRecord : axUniqueIdToProductPreferenceMap.get(uniqueId)){
                	/*saving CCC/ECOMM Product preference to update*/
                    if(((axUniqueIdToUsedQuantityCCC != null  && ((axUniqueIdToUsedQuantityCCC.containsKey(uniqueId) && cccPreferenceProductsToConsider > (axUniqueIdToUsedQuantityCCC.get(uniqueId) + tempQuantityCCC)) || (!axUniqueIdToUsedQuantityCCC.containsKey(uniqueId) && cccPreferenceProductsToConsider > 0 && cccPreferenceProductsToConsider > tempQuantityCCC))) 
                    		|| (axUniqueIdToUsedQuantityCCC.size() == 0 && cccPreferenceProductsToConsider > 0 && cccPreferenceProductsToConsider > tempQuantityCCC)) && productPreferenceRecord.Channel__c == 'CCC'){
                        
                        productPreferenceRecord.Product_Available__c = true;
                        productPreferenceToUpdate.add(productPreferenceRecord);
                       tempQuantityCCC++;
                       /* if(axUniqueIdToUsedQuantityCCC != null && axUniqueIdToUsedQuantityCCC.size() > 0 && axUniqueIdToUsedQuantityCCC.containsKey(uniqueId)){
                        	Integer tempQuantity = axUniqueIdToUsedQuantityCCC.get(uniqueId);
                        	axUniqueIdToUsedQuantityCCC.put(uniqueId, ++tempQuantity);
                        }else{
                        	axUniqueIdToUsedQuantityCCC.put(uniqueId, 1);
                        }*/
                        continue;
                    }else if(((axUniqueIdToUsedQuantityECOMM != null  && ((axUniqueIdToUsedQuantityECOMM.containsKey(uniqueId) && eCommPreferenceProductsToConsider > (axUniqueIdToUsedQuantityECOMM.get(uniqueId)+ tempQuantityECOMM)) || (!axUniqueIdToUsedQuantityECOMM.containsKey(uniqueId) && eCommPreferenceProductsToConsider > 0 && eCommPreferenceProductsToConsider > tempQuantityECOMM))) 
                    		|| (axUniqueIdToUsedQuantityECOMM.size() == 0 && eCommPreferenceProductsToConsider > 0 && eCommPreferenceProductsToConsider > tempQuantityECOMM)) && productPreferenceRecord.Channel__c == 'ECOMM'){
                        productPreferenceRecord.Product_Available__c = true;
                        productPreferenceToUpdate.add(productPreferenceRecord);
                        tempQuantityECOMM++;
                       /* if(axUniqueIdToUsedQuantityECOMM != null && axUniqueIdToUsedQuantityECOMM.size() > 0 && axUniqueIdToUsedQuantityECOMM.containsKey(uniqueId)){
                        	Integer tempQuantity = axUniqueIdToUsedQuantityECOMM.get(uniqueId);
                        	axUniqueIdToUsedQuantityECOMM.put(uniqueId, ++tempQuantity);
                        }else{
                        	axUniqueIdToUsedQuantityECOMM.put(uniqueId, 1);
                        }*/
                        continue;
                    }
                    /*If all the available quantity are considered for the product both CCC and ECOMM Product Preference, break the loop*/
                    if(cccPreferenceProductsToConsider >= axUniqueIdToUsedQuantityCCC.get(uniqueId) && eCommPreferenceProductsToConsider >= axUniqueIdToUsedQuantityECOMM.get(uniqueId)){
                        break;
                    }
                }
                if(axUniqueIdToUsedQuantityCCC != null && axUniqueIdToUsedQuantityCCC.containsKey(uniqueId)){
                	tempQuantityCCC = axUniqueIdToUsedQuantityCCC.get(uniqueId) + tempQuantityCCC;
                	axUniqueIdToUsedQuantityCCC.put(uniqueId, tempQuantityCCC);
                }else{
                	axUniqueIdToUsedQuantityCCC.put(uniqueId, tempQuantityCCC);
                }
                if(axUniqueIdToUsedQuantityECOMM != null && axUniqueIdToUsedQuantityECOMM.containsKey(uniqueId)){
                	tempQuantityECOMM = axUniqueIdToUsedQuantityECOMM.get(uniqueId) + tempQuantityECOMM;
                	axUniqueIdToUsedQuantityECOMM.put(uniqueId, tempQuantityECOMM);
                }else{
                	axUniqueIdToUsedQuantityECOMM.put(uniqueId, tempQuantityECOMM);
                }
            }
        }
        
        System.debug('productPreferenceToUpdate ::::: '+ productPreferenceToUpdate);
        
        if(productPreferenceToUpdate != null && productPreferenceToUpdate.size() > 0){
        	/*Saving data to the databases*/
        	list<Error_Log__c> errorLogs = new list<Error_Log__c>();
            Database.SaveResult[] saveresult = Database.update(productPreferenceToUpdate, false);
            for(Integer i=0; i<saveResult.size();i++){
	    		if(!saveResult[i].isSuccess()){
	    			String msg = '';
	    			msg += saveResult[i].errors[0].getMessage();
	    			Error_Log__c error = ErrorLog.logErrorActivity('Error while updating product preference Record ', msg, 'NotifyMeBatch -- execute',false, 'Tracking error', saveResult[i].getId());
	    			errorLogs.add(error);
	    		}
	    	}
			insert errorLogs;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
       
    }
}