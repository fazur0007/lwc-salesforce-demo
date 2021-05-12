public class WorkOrderLineItemHanlder {
    
    private static boolean beforeTriggerRun = true;
    private static boolean afterTriggerRun = true;
    
    
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
    
    public static void populateClaimAmountBasedOnTier(list<WorkOrderLineItem> newWorkOrderLineItems, map<Id,WorkOrderLineItem> oldmap, Boolean isInsert, Boolean isUpdate){
      list<User> userList = [SELECT Id, IsPortalEnabled FROM User WHERE Id =: UserInfo.getUserId()];
      system.debug('userList'+userList);
      Set<String> applicableClaimTypeSet = ApplicationLiterals.applicableClaimTypes;
      list<WorkOrderLineItem> workOrderLineItemsWithError = new list<WorkOrderLineItem>();
      Set<Id> workOrderIdSet = new Set<Id>();
      //Set with workorders where currency ISO code is AUD or NZD
      Set<Id> workOrderIdWithError = new Set<Id>();
      Map<Id, list<WorkOrderLineItem>> workOrderIdToLineItemMap = new Map<Id, list<WorkOrderLineItem>>();
      Map<Id, Id> workOrderIdToProductIdMap = new Map<Id, Id>();
      Map<Id, Id> workOrderIdTOPriceBookIdMap = new Map<Id, Id>();
      Map<Id, Map<Id, PricebookEntry>> pricebookIdToEntryListMap = new Map<Id, Map<Id, PricebookEntry>>();
      System.debug('### 1 newWorkOrderLineItems: ' +newWorkOrderLineItems.size());
      
      for(WorkOrderLineItem lineitem : newWorkOrderLineItems){
        System.debug('### 2');
        if(lineitem.Type__c != null && lineitem.Type__c != '' && applicableClaimTypeSet.contains(lineitem.Type__c)){
          System.debug('### 3');
          if((isInsert || (isUpdate && (lineitem.Type__c != oldmap.get(lineitem.Id).Type__c || lineitem.Tier__c != oldmap.get(lineitem.Id).Tier__c )))){
            System.debug('### 4');
            workOrderIdSet.add(lineitem.WorkOrderId);
            if(workOrderIdToLineItemMap.containsKey(lineitem.WorkOrderId)){
              System.debug('### 5');
              workOrderIdToLineItemMap.get(lineitem.WorkOrderId).add(lineitem);
            }else{
              System.debug('### 6');
              workOrderIdToLineItemMap.put(lineitem.WorkOrderId, new list<WorkOrderLineItem>{lineitem});
            }
          }
        }
        if(lineitem.Type__c != null && lineitem.Type__c != '' && ApplicationLiterals.applicableClaimTypesExceptFreight.contains(lineitem.Type__c)){
          System.debug('### 7');  
          if(isUpdate && isUpdate && userList[0].IsPortalEnabled && lineitem.ClaimAmount__c != oldmap.get(lineitem.Id).ClaimAmount__c && 
            (lineitem.Type__c == oldmap.get(lineitem.Id).Type__c && lineitem.Tier__c == oldmap.get(lineitem.Id).Tier__c)){
              System.debug('### 8');
            workOrderIdSet.add(lineitem.WorkOrderId);
            workOrderLineItemsWithError.add(lineitem);
          }
        }
      }
      System.debug('workOrderIdSet ::::: '+ workOrderIdSet);
      if(workOrderIdSet != null && workOrderIdSet.size() > 0){
        System.debug('### 9');
        Set<String> applicableCurrencySet = ApplicationLiterals.applicableWorkOrderCurrencySet;
        System.debug('### 10');
        for(WorkOrder workOrderRec : [SELECT Id, Product__c, ServicePricebook__c, CurrencyIsoCode FROM WorkOrder WHERE ID IN: workOrderIdSet]){
          System.debug('### 11');
          if(workOrderIdToLineItemMap.containsKey(workOrderRec.Id)){
            System.debug('### 12');
            workOrderIdToProductIdMap.put(workOrderRec.Id, workOrderRec.Product__c);
            workOrderIdTOPriceBookIdMap.put(workOrderRec.Id, workOrderRec.ServicePricebook__c); 
          }
          System.debug('### 13');
          if(applicableCurrencySet.contains(workOrderRec.CurrencyIsoCode)){
            workOrderIdWithError.add(workOrderRec.Id);
            System.debug('### 14');
          }
        }
      }
      
      
      if(workOrderLineItemsWithError != null && workOrderIdWithError != null && workOrderIdWithError.size() > 0 && workOrderLineItemsWithError.size() > 0){
        System.debug('### 15');
        for(WorkOrderLineItem lineItem : workOrderLineItemsWithError){
          System.debug('### 16');
          if(workOrderIdWithError.contains(lineItem.WorkOrderId)){
            lineitem.addError('You cannot modify the Claim Amount for Labor, Inspection and Freight charges.');
            System.debug('### 17');
          }
        }
      }
      System.debug('workOrderIdTOPriceBookIdMap ::::: '+ workOrderIdTOPriceBookIdMap);
      System.debug('===workOrderIdToProductIdMap==='+workOrderIdToProductIdMap.values());
      if(workOrderIdToProductIdMap.values() != null && workOrderIdTOPriceBookIdMap.size() > 0){
        System.debug('### 18');
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
          pbeList = [SELECT Id, Product2Id, CurrencyIsoCode, UnitPrice, ServiceCharge__c,
                                                            InspectionCharge__c, FreightCharge__c, LaborCharge__c, ClaimCharge__c, Pricebook2Id,
                                                            Tier2InspectionCharge__c, Tier2LaborCharge__c, Tier3LaborCharge__c, Tier4LaborCharge__c
                                                            FROM PricebookEntry 
                                                            WHERE IsActive = true
                                                            AND Pricebook2Id IN: workOrderIdTOPriceBookIdMap.values()
                                                            AND Product2Id IN: workOrderIdToProductIdMap.values()];
        System.debug('===pbeList==='+pbeList);
          
        for(PricebookEntry pbe : [SELECT Id, Product2Id, CurrencyIsoCode, UnitPrice, ServiceCharge__c,
                                                            InspectionCharge__c, FreightCharge__c, LaborCharge__c, ClaimCharge__c, Pricebook2Id,
                                                            Tier2InspectionCharge__c, Tier2LaborCharge__c, Tier3LaborCharge__c, Tier4LaborCharge__c
                                                            FROM PricebookEntry 
                                                            WHERE IsActive = true
                                                            AND Pricebook2Id IN: workOrderIdTOPriceBookIdMap.values()
                                                            AND Product2Id IN: workOrderIdToProductIdMap.values()]){
                System.debug('### 19');
          if(pricebookIdToEntryListMap.containsKey(pbe.Pricebook2Id)){
            System.debug('### 20');
            pricebookIdToEntryListMap.get(pbe.Pricebook2Id).put(pbe.Product2Id, pbe);
          }else{
            pricebookIdToEntryListMap.put(pbe.Pricebook2Id, new Map<Id, PricebookEntry>{pbe.Product2Id => pbe});
            System.debug('### 21');
          }
        }
        System.debug('===End of workOrderIdToProductIdMap loop===');
      }
      
      System.debug('===workOrderIdToLineItemMap==='+workOrderIdToLineItemMap);
      if(workOrderIdToLineItemMap != null && workOrderIdToLineItemMap.size() > 0){
        System.debug('### 22');
        Map<String,Map<String, String>> chargeTypeToTierMappingFieldMap = new Map<String, Map<String, String>>();
          for(Work_Order_Tier_Mapping__mdt workOrderTierMapping : [SELECT Type__c, TierValue__c, PricebookEntryFieldName__c FROM Work_Order_Tier_Mapping__mdt]){
            System.debug('### 23');
            if(chargeTypeToTierMappingFieldMap.containsKey(workOrderTierMapping.Type__c)){
              chargeTypeToTierMappingFieldMap.get(workOrderTierMapping.Type__c).put(workOrderTierMapping.TierValue__c, workOrderTierMapping.PricebookEntryFieldName__c);
              System.debug('### 24');
            }else{
              chargeTypeToTierMappingFieldMap.put(workOrderTierMapping.Type__c, 
                                    new Map<String, String>{workOrderTierMapping.TierValue__c => workOrderTierMapping.PricebookEntryFieldName__c});
              System.debug('### 25');
            }
          }
        
        for(Id workOrderId : workOrderIdToLineItemMap.keySet()){
          System.debug('### 26');
          for(WorkOrderLineItem lineItem : workOrderIdToLineItemMap.get(workOrderId)){
            System.debug('### 27');
            if(workOrderIdToProductIdMap.containsKey(workOrderId) && workOrderIdTOPriceBookIdMap.containsKey(workOrderId) && 
              pricebookIdToEntryListMap.containsKey(workOrderIdTOPriceBookIdMap.get(workOrderId)) &&
              pricebookIdToEntryListMap.get(workOrderIdTOPriceBookIdMap.get(workOrderId)).containsKey(workOrderIdToProductIdMap.get(workOrderId))){
                System.debug('### 28');
              PricebookEntry priceBookEntryRec = pricebookIdToEntryListMap.get(workOrderIdTOPriceBookIdMap.get(workOrderId)).get(workOrderIdToProductIdMap.get(workOrderId));
              System.debug('====lineItem.Type__c==='+lineItem.Type__c);
              if(lineItem.Type__c.equalsIgnoreCase('Freight Charge')){
                lineItem.ClaimAmount__c = priceBookEntryRec.FreightCharge__c;
                System.debug('### 29');
              }else if(lineItem.Type__c.equalsIgnoreCase('Inspection Charge') && lineItem.Tier__c != null){
                System.debug('### 30');
                if(chargeTypeToTierMappingFieldMap.containsKey('Inspection Charge') && 
                            chargeTypeToTierMappingFieldMap.get('Inspection Charge').containsKey(lineItem.Tier__c)){
                              System.debug('### 31');
                          String pricebookEntryFieldName = chargeTypeToTierMappingFieldMap.get('Inspection Charge').get(lineItem.Tier__c);
                          if(priceBookEntryRec.get(pricebookEntryFieldName) != null && (Double)priceBookEntryRec.get(pricebookEntryFieldName) > 0){
                            lineItem.ClaimAmount__c = (Double)priceBookEntryRec.get(pricebookEntryFieldName);
                            System.debug('### 32');
                          }else{
                            lineItem.addError('No Inspection Charge found for selected selected Tier');
                            System.debug('### 33');
                          }
                        }else{
                          lineItem.addError('Selected Tier is not applicable for selected Inspection Charge');
                          System.debug('### 34');
                        }
              }else if(lineItem.Type__c.equalsIgnoreCase('Labor Charge') && lineItem.Tier__c != null){
                System.debug('### 35');
                if(chargeTypeToTierMappingFieldMap.containsKey('Labor Charge') && 
                            chargeTypeToTierMappingFieldMap.get('Labor Charge').containsKey(lineItem.Tier__c)){
                              System.debug('### 36');
                          String pricebookEntryFieldName = chargeTypeToTierMappingFieldMap.get('Labor Charge').get(lineItem.Tier__c);
                          if(priceBookEntryRec.get(pricebookEntryFieldName) != null && (Double)priceBookEntryRec.get(pricebookEntryFieldName) > 0){
                            lineItem.ClaimAmount__c = (Double)priceBookEntryRec.get(pricebookEntryFieldName);
                            System.debug('### 37');
                          }else{
                            lineItem.addError('No Labor Charge found for selected selected Tier');
                            System.debug('### 38');
                          }
                        }else{
                          lineItem.addError('Selected Tier is not applicable for selected Labor Charge');
                          System.debug('### 39');
                        }
              }
            }
          }
        }
      }
      System.debug('===End of workOrderIdToLineItemMap loop===');
    }
    
    public static void calculateTotal(list<WorkOrderLineItem> newWorkOrderLineItems,map<Id,WorkOrderLineItem> oldmap,Boolean isInsert,Boolean isDelete){
        System.debug('### 40' + '===newWorkOrderLineItems==='+ newWorkOrderLineItems + '===oldmap==='+ oldmap + '===isInsert==='+isInsert+'===isDelete==='+isDelete);
        set<Id> worOrdersPiceNeedtoBeCalcualted = new set<Id>();
        newWorkOrderLineItems = isDelete ? oldmap.values() : newWorkOrderLineItems;
        for(WorkOrderLineItem workOrderLineItem : newWorkOrderLineItems){
          System.debug('### 41');
            if(workOrderLineItem.Type__c=='Parts' ){
              System.debug('### 42');
                if((isInsert || isDelete) ){
                    worOrdersPiceNeedtoBeCalcualted.add(workOrderLineItem.WorkOrderId);
                  System.debug('### 43');
                }else if( (oldmap.get(workOrderLineItem.id).UnitPrice != workOrderLineItem.UnitPrice) 
                            || (oldmap.get(workOrderLineItem.id).Quantity != workOrderLineItem.Quantity)
                            || (oldmap.get(workOrderLineItem.id).Discount != workOrderLineItem.Discount)){
                    
                    worOrdersPiceNeedtoBeCalcualted.add(workOrderLineItem.WorkOrderId);
                    System.debug('### 44');
                }
            }
        }
        if(!worOrdersPiceNeedtoBeCalcualted.isEmpty()){
          System.debug('### 45');
            list<WorkOrder> workOrderForUpdate = new list<WorkOrder>();
            AggregateResult[] groupedResults = [SELECT WorkOrderId,SUM(TotalPrice) total,SUM(SubTotal) subtotal,Type__c 
                                                FROM WorkOrderLineItem  
                                                WHERE Type__c='Parts' 
                                                AND  WorkOrderId IN:worOrdersPiceNeedtoBeCalcualted
                                                GROUP BY WorkOrderId,Type__c];
            for (AggregateResult ar : groupedResults)  {
              System.debug('### 46');
                workOrderForUpdate.add(new WorkOrder(
                                            Id =  String.valueOf(ar.get('WorkOrderId')),
                                            PartsSubTotal__c = Double.valueOF(ar.get('SubTotal')),
                                            PartsTotal__c = Double.valueOF(ar.get('total')) 
                                        ));
                
            }
            
            try{
              if(workOrderForUpdate != null && workOrderForUpdate.size() > 0){
                System.debug('### 47');
                Database.SaveResult[] srList = Database.update(workOrderForUpdate, false);
                System.debug('### 48');
                list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
                for(Integer i = 0; i < workOrderForUpdate.size(); i++){
                  if(!srList[i].isSuccess()){
                    System.debug('### 49');
                    String msg = '';
                    Error_Log__c error = ErrorLog.logErrorActivity('Error while updating work order line item',
                                                          msg, 
                                                      ' WorkOrderLineItemHandler',false, 'Work Order Line Item calculate total error',
                                                      String.valueOf(workOrderForUpdate[i].get('Id')),String.valueOf(workOrderForUpdate[i].get('Id')),null); 
                          errorLogs.add(error);
                  }
                }
                System.debug('### 50');
                insert  errorLogs;
                System.debug('### 51');
              }
          }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex,'Error while updating work order line item',true,'Work Order Line Item calculate total error');
            System.debug('### 52');
          }
        }
        
    }
    
    /* To update IsCalculated field of Work Order
    
    public static void updateIsCalculate(list<WorkOrderLineItem> orderItemList){
    
    list<WorkOrder> orderListToUpdate = new List<WorkOrder>();
    
    set<Id> orderSet = new Set<Id>();
    if(orderItemList != null && orderItemList.size() > 0){
      for(WorkOrderLineItem orderItemRecord : orderItemList){
        orderSet.add(orderItemRecord.WorkOrderId);
      }
    }
    for(Id orderId : orderSet){
      orderListToUpdate.add(new WorkOrder(Id = orderId, IsCalculated__c = false));
    }
    
    if(orderListToUpdate != null && orderListToUpdate.size() > 0){
      update orderListToUpdate;
    }
  }
  */
    
}