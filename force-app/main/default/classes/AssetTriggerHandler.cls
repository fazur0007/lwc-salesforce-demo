public with sharing class AssetTriggerHandler {
    
    /*This method will populate the warranty duration on Asset from Product*/
    public static void populateWarrantyDurationOnAsset(list<Asset> newAssetList){
        
        Set<Id> productIdSet = new Set<Id>();
        Map<Id, Integer> productIdToWarrantyMap = new Map<Id, Integer>();
        
        for(Asset assetRecord : newAssetList){
            if(CaseTriggerHandler.isBatchCodeValid(assetRecord.Batch_Code__c, Datetime.now(), assetRecord.PurchaseDate)){
                productIdSet.add(assetRecord.Product2Id);
            }else{
                assetRecord.addError(Label.Invalid_Batch_Code);
            }
        }
        
        if(productIdSet != null && productIdSet.size() > 0){
            for(Product2 product : [SELECT Id, Warranty_In_Months__c FROM Product2 WHERE Id IN: productIdSet AND Warranty_In_Months__c != null]){
                productIdToWarrantyMap.put(product.Id, Integer.valueOf(product.Warranty_In_Months__c));
            }
            
            if(productIdToWarrantyMap != null && productIdToWarrantyMap.size() > 0){
                for(Asset assetRecord : newAssetList){
                    if(assetRecord.Product2Id != null && assetRecord.Warranty_In_Months__c == null && productIdToWarrantyMap.containsKey(assetRecord.Product2Id)){
                        assetRecord.Warranty_In_Months__c =  productIdToWarrantyMap.get(assetRecord.Product2Id);
                    }
                }
            }
        }
        
    }
    
    /*This method will udpate the Case Warranty if Asset warranty period is changed*/
    public static void updateCaseWarrantyOnAssetUpdate(Map<Id,Asset> triggerNewMap, Map<Id, Asset> triggerOldMap){
        
        list<Asset> assetsWithUpdatedWarrantyList = new list<Asset>();
        Map<Id, list<Case>> assetIdToCaseListMap = new Map<Id, list<Case>>();
        Set<Id> productIdSet = new Set<Id>();
        Map<Id, Integer> productIdToWarrantyInMonthsMap = new Map<Id, Integer>();
        Map<Id, Integer> productIdToExtendedWarrantyMap = new Map<Id, Integer>();
        Set<Id> alwaysInWarrantyProducts = new Set<Id>();
        list<Case> caseListToUpdate = new list<Case>();
        
        //Iterate over the assets which have been updated
        for(Asset asset : triggerNewMap.values()){
            
            Boolean hasValidBatchCode = true;
            if(asset.Batch_Code__c != triggerOldMap.get(asset.Id).Batch_Code__c && !CaseTriggerHandler.isBatchCodeValid(asset.Batch_Code__c, asset.CreatedDate, asset.PurchaseDate)){
                asset.addError(Label.Invalid_Batch_Code); 
                hasValidBatchCode = false;
            }
            
            //Assets whose warranty period is modified needs to be considered
            if(hasValidBatchCode && asset.Warranty_In_Months__c != triggerOldMap.get(asset.Id).Warranty_In_Months__c){           
                assetsWithUpdatedWarrantyList.add(asset);
                productIdSet.add(asset.Product2Id);
            }
            
            
        }

        //Check Assets whose warranty has been modified
        if(assetsWithUpdatedWarrantyList != null && assetsWithUpdatedWarrantyList.size() > 0){
            
            
                                    
            //Query cases which are associated to these Assets
            for(Case caseRecord : [Select Id, AssetId, CreatedDate, Warranty_Based_on_Batch_Code__c, Batch_Code__c, Product__c,
                                                 Warranty_Based_on_Registration_Date__c, Warranty_Based_on_Purchase_Date__c, Purchase_Date__c, 
                                                 Warranty_Expiration_Date__c, Extended_Warranty_Expiration_Date__c
                                        FROM Case WHERE AssetId IN: triggerNewMap.keySet()] ){
                if(assetIdToCaseListMap.containsKey(caseRecord.AssetId)){
                    assetIdToCaseListMap.get(caseRecord.AssetId).add(caseRecord);
                }else{
                    assetIdToCaseListMap.put(caseRecord.AssetId, new list<Case>{caseRecord});
                }
            }
            
            //check the map
            if(assetIdToCaseListMap != null && assetIdToCaseListMap.size() > 0){
                
                for(Product2 productRecord : [SELECT Id, Warranty_In_Months__c, Extended_Warranty_in_months__c, Always_in_Warranty__c 
                                                        FROM Product2
                                                        WHERE Id IN: productIdSet]){
                    if(productRecord.Warranty_In_Months__c != null){
                        productIdToWarrantyInMonthsMap.put(productRecord.Id, Integer.valueOf(productRecord.Warranty_In_Months__c));
                    }
                    if(productRecord.Extended_Warranty_in_months__c != null){
                        productIdToExtendedWarrantyMap.put(productRecord.Id, Integer.valueOf(productRecord.Extended_Warranty_in_months__c));
                    }
                    if(productRecord.Always_in_Warranty__c){
                        alwaysInWarrantyProducts.add(productRecord.Id);
                    }
                }
                
                for(Id assetId : assetIdToCaseListMap.keySet()){
                    for(Case caseRecord : assetIdToCaseListMap.get(assetId)){
                        if(caseRecord.Product__c != null){
                            if(!alwaysInWarrantyProducts.contains(caseRecord.Product__c)){
                                CaseTriggerHandler.updateWarrantyFieldStatus(caseRecord, 'N/A');
                                Case associatedCaseRecord = 
                                    CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(triggerNewMap.get(assetId), 
                                                                                                caseRecord, 
                                                                                                productIdToWarrantyInMonthsMap.get(caseRecord.Product__c), 
                                                                                                CaseTriggerHandler.getBatchCodeDate(caseRecord.Batch_Code__c), 
                                                                                                productIdToExtendedWarrantyMap.get(caseRecord.Product__c));
                                caseListToUpdate.add(associatedCaseRecord);
                            }else{
                                caseRecord.Warranty__c = 'In Warranty';
                                CaseTriggerHandler.updateWarrantyFieldStatus(caseRecord, 'True');
                                caseListToUpdate.add(caseRecord);
                            }
                        }
                    }
                }
                
                //caseListToUpdate
                if(caseListToUpdate != null && caseListToUpdate.size() > 0){
                    try{
                        update caseListToUpdate;
                    }catch(Exception ex){
                        ErrorLog.logErrorActivity(ex, ' While updating Case Warranty Status from Asset', true, 'Error');
                    }
                }
                
            }
        }
    }
        
    public static void createOfferOrders(List<Asset> newAssetList, Map<Id, Asset> oldAssets){
        list<String> offerCodes = new list<String>();
        list<String> listExactOfferCode;
        Map<String,Offer__c> offerCodeToOfferMap = new Map<String,Offer__c>();
        Map<Id, List<Offer__c>> assetToOfferMap = new Map<Id, List<Offer__c>>();
        
        for (Asset record : newAssetList) {
            Asset oldAsset = oldAssets == null ? null : oldAssets.get(record.Id);
            if (String.isNotBlank(record.ExactOfferCode__c)){
                if((oldAsset == null || oldAsset.ExactOfferCode__c != record.ExactOfferCode__c) && !record.IsApprovalRequired__c){
                    string splitOffer = record.ExactOfferCode__c;
                    offerCodes = splitOffer.split(';');
            }else if(oldAsset != null){ 
                    if(((oldAsset.ExactOfferCode__c == record.ExactOfferCode__c) || (oldAsset.ExactOfferCode__c != record.ExactOfferCode__c)) 
                       && (record.IsApprovalRequired__c && oldAsset.Approval_Status__c != record.Approval_Status__c && record.Approval_Status__c =='Approved')){
                           string splitOffer = record.ExactOfferCode__c;
                    offerCodes = splitOffer.split(';');
                    }
                }
            }
        }
        
        if (!offerCodes.isEmpty()) {
            for (Offer__c record : [Select Id, OfferCode__c, Brand__c FROM Offer__c WHERE OfferCode__c IN :offerCodes AND Active__c = true]) {
                offerCodeToOfferMap.put(record.OfferCode__c, record);
            }
        }
        
        if (offerCodeToOfferMap.size() > 0) {
            for (Asset record : newAssetList) {
                if (String.isNotBlank(record.ExactOfferCode__c)) {
                    String splitOffer = record.ExactOfferCode__c;
                    listExactOfferCode= splitOffer.split(';');
                    
                    if (listExactOfferCode != null && listExactOfferCode.size() > 0) {
                        for (String strExactOfferCode : listExactOfferCode) {
                            if (assetToOfferMap.containsKey(record.Id)) {
                                assetToOfferMap.get(record.Id).add(offerCodeToOfferMap.get(strExactOfferCode));
                            } else {
                                assetToOfferMap.put(record.Id, new List<Offer__c> {offerCodeToOfferMap.get(strExactOfferCode)});
                            } 
                        }
                    }
                }
            }
        }
        if (assetToOfferMap != null && assetToOfferMap.size() > 0) {
            OfferRedemptionUtility.createOrderFromOfferOnAsset(assetToOfferMap);
        }
    }
}