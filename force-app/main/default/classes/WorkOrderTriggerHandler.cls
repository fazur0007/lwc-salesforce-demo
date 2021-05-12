public without sharing class WorkOrderTriggerHandler {
    
    public  static boolean beforeTriggerRun = true;
    public  static boolean afterTriggerRun = true;
    
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
    
    
    public static void shareWithServiceCentre(list<WorkOrder> newWorkOrders,map<Id,WorkOrder> oldmap,Boolean isInsert){
        
        list<WorkOrder> worOrdersneedtoShare = new list<WorkOrder>();
        List<Id> shareIdsToDelete = new List<Id>();
        set<Id> serviceCentreAccountIds = new set<Id>();
        for(WorkOrder workorder : newWorkOrders){
            
            if(isInsert && workorder.ServiceCentre__c != NULL && workorder.Activated__c){
                System.debug('===inside Insert===');
                worOrdersneedtoShare.add(workorder);
                serviceCentreAccountIds.add(workorder.ServiceCentre__c);
            }else if(oldmap != null && workorder.Activated__c &&
                                 ((oldmap.get(workorder.id).ServiceCentre__c != workorder.ServiceCentre__c) 
                                        || (oldmap.get(workorder.id).OwnerId != workorder.OwnerId)
                                        || (oldmap.get(workorder.id).Activated__c != workorder.Activated__c))){
                
                System.debug('===inside Update===');
                //add to delete list to delete share records
                shareIdsToDelete.add(workorder.id);
                if(workorder.ServiceCentre__c != NULL){
                    worOrdersneedtoShare.add(workorder);
                    serviceCentreAccountIds.add(workorder.ServiceCentre__c);
                }
                
            }
        }
        
        System.debug('===shareIdsToDelete==='+shareIdsToDelete);
        if(!shareIdsToDelete.isEmpty()){
            List<WorkOrderShare> delList = [SELECT Id FROM WorkOrderShare 
					WHERE ParentId IN :shareIdsToDelete 
					AND RowCause = 'Manual'];
	        System.debug('===delList==='+delList);
            delete delList;
            
            //delete [SELECT Id FROM WorkOrderShare 
            //            WHERE ParentId IN :shareIdsToDelete 
            //            AND RowCause = 'Manual'];
        }

        System.debug('===worOrdersneedtoShare==='+worOrdersneedtoShare);
        System.debug('===serviceCentreAccountIds==='+serviceCentreAccountIds);

        if(!worOrdersneedtoShare.isEmpty()){
            Integer successCount = 0;
	        Integer errorCount = 0;
             List<WorkOrderShare> sharesToCreate = new List<WorkOrderShare>();
             map<Id,Set<Id>> partnerUserIdByAccountId = Utility.getPartnerUserIdByAccountId(serviceCentreAccountIds);
             System.debug('===partnerUserIdByAccountId==='+partnerUserIdByAccountId);

             for(WorkOrder workorder : worOrdersneedtoShare){
                if(partnerUserIdByAccountId.containsKey(workorder.ServiceCentre__c)){
                    System.debug('===partnerUserIdByAccountId ServiceCentre__c==='+ partnerUserIdByAccountId.get(workorder.ServiceCentre__c));

                    for(Id userId : partnerUserIdByAccountId.get(workorder.ServiceCentre__c)){
                        sharesToCreate.add(createWorkOrderShare(workorder.Id, userId));
                    }
                }
             }
            // Database.insert(sharesToCreate,false);

            System.debug('===sharesToCreate size==='+sharesToCreate.size());
	        System.debug('===sharesToCreate==='+sharesToCreate);

             list<Error_Log__c> errorLogs = new list<Error_Log__c>();
	         Database.SaveResult[] saveResult = Database.insert(sharesToCreate,false);

            try{
                if(saveResult != null && saveResult.size() > 0){
                    for(Integer i = 0; i < sharesToCreate.size(); i++) {
                        if (!saveResult[i].isSuccess()) {
                            errorCount++;

                            String msg = '';
                            msg += saveResult[i].errors[0].getMessage();
                            
                            Error_Log__c error = new Error_Log__c( 
                                                                    Error_Message__c = msg,
                                                                    Operation__c = 'WorkOrderTriggerHandler - shareWithServiceCentre - ' +
                                                                                            'Error while inserting WorkOrderShare records',
                                                                    Record_Id__c = String.valueOf(sharesToCreate[i].get('UserOrGroupId')),
                                                                    Work_Order__c = String.valueOf(sharesToCreate[i].get('ParentId')),
                                                                    Trace_Log__c = msg,
                                                                    Type__c = 'Error'
                            );
                            errorLogs.add(error);
                        }else{
                            successCount++;
                        }
                    }
                    insert  errorLogs;
                }
                System.debug('===successCount==='+successCount);
                System.debug('===errorCount==='+errorCount);
            }catch(Exception ex){
                ErrorLog.LogErrorActivity(ex,'Error while inserting WorkOrderShare records',true,'Error');
            }
        }
    }
    
    
    /** Method name : createWorkOrderShare
     * Arguments : Id caseId - Record id of the case record which needs to be shared
     * Id userOrGroupId - Record id of user or public group with which the case record needs to be shared
     * String caseAccessLevel - Record sharing access level - Read, Edit, All
     * Return type : WorkOrderShare
     * Description : Creates WorkOrder share record as per the parameters passed to the method
    **/
    public static WorkOrderShare createWorkOrderShare(Id workOrderId, Id userOrGroupId){
        WorkOrderShare share = new WorkOrderShare();
        share.ParentId = workOrderId;
        share.UserOrGroupId = userOrGroupId;                                              
        share.AccessLevel = 'Edit';
        share.RowCause = 'Manual';
        return share;
    }
    public static map<Id,Id> getPartnerUserIdByAccountId(set<Id> serviceCentreAccountIds){
        map<Id,Id> partnerUserIdByAccountId = new map<Id,Id>();
        
        for(User user : [SELECT Id, AccountId 
                            FROM User 
                            WHERE IsPortalEnabled =true
                            AND AccountId IN:serviceCentreAccountIds]){
                                
            partnerUserIdByAccountId.put(user.AccountId,user.Id);
        }
        return partnerUserIdByAccountId;
    }
    
    public static void createCaseforWorkOrder(list<WorkOrder> newWorkOrders){
        RecordType claimRecordType = [SELECT ID FROM RecordType WHERE Name='Claim' AND sobjecttype = 'WorkOrder' LIMIT 1][0];
        
        Set<String> emailSet = new Set<String>();
        Map<String,Account> oldAccountsMap = new Map<String,Account>();
        list<WorkOrder> newWorkOrdersWithoutCase = new list<WorkOrder>();
        list<WorkOrder> newWorkOrdersWithCase = new list<WorkOrder>();
        list<WorkOrder> callCenterCase = new list<WorkOrder>();
        Map<String, Case> caseNumberToCaseIdMap = new Map<String, Case>();
        
        Map<String, String> workorderIDtoCaseIDMap = new Map<String, String>();
        
        List<Account> accountList = new List<Account>();
        
        /* Get AccountId, Service Pricebook and CurrencyISOCode of Current User*/
        Map<Id, User> userIdToUserMap = new Map<Id, user>();
        User currentUser;
        list<User> userList = [select id, AccountId, Contact.Account.ServicePriceBook__c, DefaultCurrencyISOCode, Contact.AccountId from User where id=:UserInfo.getUserId()];
        if(userList != null && userList.size()>0){
            userIdToUserMap.put(userList[0].id, userList[0]);
            currentUser = userList[0];
        }
        
        Set<String> caseNumberSet = new Set<String>();
        Map<String, WorkOrder> emailToWorkOrder = new Map<String, WorkOrder>();
        
        /* Categorize Work Order into With Case, Without Case and Call Center Cases*/
        for(WorkOrder newWorkOrderRecord : newWorkOrders){
            Boolean hasError = false;
            if(!(newWorkOrderRecord.RecordTypeId != null && newWorkOrderRecord.RecordTypeId == claimRecordType.Id)){
                if((newWorkOrderRecord.CaseNumber__c == null || newWorkOrderRecord.CaseNumber__c == '') && newWorkOrderRecord.CaseId == null){
                    if(newWorkOrderRecord.FirstName__c == null || newWorkOrderRecord.FirstName__c == '' || newWorkOrderRecord.LastName__c == null || 
                            newWorkOrderRecord.LastName__c == '' || newWorkOrderRecord.Email__c == null || newWorkOrderRecord.Email__c == ''){
                        hasError = true;  
                        newWorkOrderRecord.addError('Please enter either First Name, Last Name and Email or Case Number.');
                    }
                    if(newWorkOrderRecord.Product__c == null || newWorkOrderRecord.BatchCode__c == null && newWorkOrderRecord.BatchCode__c == ''){
                        newWorkOrderRecord.addError('Please enter Product Details(Product, Batch Code)');
                        hasError = true;
                    }
                }
                if(newWorkOrderRecord.CaseNumber__c != null && newWorkOrderRecord.CaseNumber__c != '' && newWorkOrderRecord.caseId == null && !hasError){
                    newWorkOrdersWithCase.add(newWorkOrderRecord);
                    caseNumberSet.add(newWorkOrderRecord.CaseNumber__c);  
                }else if(newWorkOrderRecord.caseId != null){
                    callCenterCase.add(newWorkOrderRecord);
                }else if(newWorkOrderRecord.FirstName__c != null && newWorkOrderRecord.FirstName__c != '' 
                            && newWorkOrderRecord.LastName__c != null && newWorkOrderRecord.LastName__c != ''
                                && newWorkOrderRecord.Email__c != null && newWorkOrderRecord.Email__c != ''){
                    newWorkOrdersWithoutCase.add(newWorkOrderRecord);
                    if(newWorkOrderRecord.Email__c != null && newWorkOrderRecord.Email__c != '')
                        emailSet.add(newWorkOrderRecord.Email__c);
                        emailToWorkOrder.put(newWorkOrderRecord.Email__c, newWorkOrderRecord);
                }
            }
        }
        caseNumberToCaseIdMap = Utility.createCaseMap(caseNumberSet);
        
        /* Cases with Case Numnber being populated by ASC*/
        /*--------------------------------------------------------*/
        for(WorkOrder newWorkOrderRecord : newWorkOrdersWithCase){
            
            if(caseNumberToCaseIdMap != null){
                if(caseNumberToCaseIdMap.containsKey(newWorkOrderRecord.CaseNumber__c)){
                    //newWorkOrderRecord.caseId = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Id;
                    if(caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).AccountId != null){
                        //newWorkOrderRecord.AccountId = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).AccountId;
                        newWorkOrderRecord.FirstName__c = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.FirstName;
                        newWorkOrderRecord.LastName__c = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.LastName;
                        newWorkOrderRecord.Phone__c = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.Phone;
                        newWorkOrderRecord.Email__c = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.PersonEmail;
                        newWorkOrderRecord.Street = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.BillingStreet;
                        newWorkOrderRecord.City = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.BillingCity;
                        newWorkOrderRecord.State = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.BillingState;
                        newWorkOrderRecord.PostalCode = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.BillingPostalCode;
                        newWorkOrderRecord.Country = caseNumberToCaseIdMap.get(newWorkOrderRecord.CaseNumber__c).Account.BillingCountry;
                    }
                }
                
            }
            
            /* Assigning Service Centre, Pricebook and CurrencyISOCode to Work Order*/
            if(currentUser != null){
                if(currentUser.AccountId != null){
                    newWorkOrderRecord.ServiceCentre__c = currentUser.AccountId;
                }
                   
                if(currentUser.AccountId != null && currentUser.Contact.AccountId != null){
                    if(currentUser.Contact.Account.ServicePriceBook__c != null){
                        newWorkOrderRecord.ServicePricebook__c = currentUser.Contact.Account.ServicePriceBook__c;
                    }    
                }   
                    
                if(currentUser.DefaultCurrencyISOCode != null){
                    newWorkOrderRecord.CurrencyISOCode = currentUser.DefaultCurrencyISOCode;
                }    
            }
        }
        
        /*--------------------------------------------------------*/
        
        /*---------------------------------------*/
        /* To get old accounts having email in emailSet */
        if(emailSet != null && emailSet.size() > 0){
            for(Account oldAccount : [select id,firstName,lastName,PersonEmail,Phone,BillingStreet,  BillingCity, 
                                            BillingState, BillingPostalCode, BillingCountry 
                                        from Account where PersonEmail IN :emailSet]){
                if(oldAccount.PersonEmail != null && oldAccount.PersonEmail != '')
                    oldAccountsMap.put(oldAccount.PersonEmail, oldAccount);                            
            }
            
            for(String emailAddress : emailSet){
                if(!oldAccountsMap.containsKey(emailAddress)){
                    Account newAccount = createAccountRecord(emailToWorkOrder.get(emailAddress));
                    accountList.add(newAccount);
                    oldAccountsMap.put(newAccount.PersonEmail, newAccount);
                }
            }
            
            if(accountList != null && accountList.size() > 0){
                insert accountList;
            }
        }
        
        Map<Id, Id> accountIdToContactId = new Map<Id, Id>();
        for(WorkOrder newWorkOrderRecord : newWorkOrdersWithoutCase){
             newWorkOrderRecord.AccountId = oldAccountsMap.get(newWorkOrderRecord.Email__c).Id;
             accountIdToContactId.put(newWorkOrderRecord.AccountId, null);
        }
        if(accountIdToContactId != null && accountIdToContactId.size() > 0){
            for(Account account : [SELECT Id, PersonContactId FROM Account WHERE Id IN: accountIdToContactId.keySet()]){
                accountIdToContactId.put(account.Id, account.PersonContactId);
            } 
        }
        

        Map<WorkOrder, Case> workOrderToCaseMap = new Map<WorkOrder, Case>();        
         
        for(WorkOrder newWorkOrderRecord : newWorkOrdersWithoutCase){
            
            
            /* Assigning Service Centre, Pricebook and CurrencyISOCode to Work Order*/
            if(currentUser.AccountId != null){
                newWorkOrderRecord.ServiceCentre__c = currentUser.AccountId;
            }    
            if(currentUser.AccountId != null){
                if(currentUser.Contact.Account.ServicePriceBook__c != null){
                    newWorkOrderRecord.ServicePricebook__c = currentUser.Contact.Account.ServicePriceBook__c;
                }    
            }   
                
            if(currentUser.DefaultCurrencyISOCode != null){
                newWorkOrderRecord.CurrencyISOCode = currentUser.DefaultCurrencyISOCode;
            }    
            if(newWorkOrderRecord.Email__c != null && newWorkOrderRecord.Email__c != ''){
                newWorkOrderRecord.ContactId = accountIdToContactId.get(newWorkOrderRecord.AccountId);
                //newWorkOrderRecord.AccountId = oldAccountsMap.get(newWorkOrderRecord.Email__c).Id;
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
                Case newCase = createCase(newWorkOrderRecord, recordTypeId);
                workOrderToCaseMap.put(newWorkOrderRecord, newCase);
                
            }
        }
        
        /* Insert all Cases*/
        if(workOrderToCaseMap != null && workOrderToCaseMap.size() > 0){
            insert workOrderToCaseMap.values();
        }
        
        Map<Id, Case> caseIDToCaseMap = new Map<Id, Case>([SELECT Id, CaseNumber, Subject FROM Case WHERE Id IN: workOrderToCaseMap.values()]);
        
        /* Assigning CaseId, CaseNumber and Subject to Work Order*/
        for(WorkOrder newWorkOrderRecord : newWorkOrdersWithoutCase){
            String caseId = workOrderToCaseMap.get(newWorkOrderRecord).Id;
            newWorkOrderRecord.CaseId = caseId;
            newWorkOrderRecord.CaseNumber__c = caseIDToCaseMap.get(caseId).CaseNumber;
            newWorkOrderRecord.Complaint_Code__c = caseIDToCaseMap.get(caseId).Subject;
        }
        updateServiceChargesOnWorkOrder(newWorkOrders, currentUser);
    }   
    
    //Method to update the charges in case work order product is changed OR tier is changed for labor/inspection fee OR IsFreightFeeApplicable__c
    public static void updateServiceChargerOnUpdate(list<WorkOrder> newWorkOrders, Map<Id, WorkOrder> oldWorkOrderMap){
        List<WorkOrder> updatedWorkOrders = new List<WorkOrder>();
        for(WorkOrder workOrderRec : newWorkOrders){
            if(workOrderRec.Product__c != oldWorkOrderMap.get(workOrderRec.Id).Product__c
            		|| (workOrderRec.InspectionChargeTierLevel__c != oldWorkOrderMap.get(workOrderRec.Id).InspectionChargeTierLevel__c && 
            			workOrderRec.InspectionChargeTierLevel__c != null && workOrderRec.InspectionChargeTierLevel__c != '') 
            		|| (workOrderRec.LaborChargeTierLevel__c != oldWorkOrderMap.get(workOrderRec.Id).LaborChargeTierLevel__c && 
            			workOrderRec.LaborChargeTierLevel__c != null && workOrderRec.LaborChargeTierLevel__c != '')
            		|| (workOrderRec.IsFreightFeeApplicable__c != oldWorkOrderMap.get(workOrderRec.Id).IsFreightFeeApplicable__c && workOrderRec.IsFreightFeeApplicable__c)){
                updatedWorkOrders.add(workOrderRec);
            }
            if(workOrderRec.InspectionChargeTierLevel__c == null || workOrderRec.InspectionChargeTierLevel__c == ''){
            	workOrderRec.InspectionCharge__c = 0;
            	//workOrderRec.Discounted_Inspection_Charge__c = 0;
            }
            if(workOrderRec.LaborChargeTierLevel__c == null || workOrderRec.LaborChargeTierLevel__c == ''){
            	workOrderRec.LaborCharge__c = 0;
            	//workOrderRec.Discounted_Labor_Charge__c = 0;
            }
            if(!workOrderRec.IsFreightFeeApplicable__c){
            	workOrderRec.FreightCharge__c = 0;
            	//workOrderRec.Discounted_Flat_Service_Charge__c = 0;
            }
        }
        if(updatedWorkOrders != null && updatedWorkOrders.size() > 0){
            list<User> userList = [select id, AccountId, Contact.Account.ServicePriceBook__c, DefaultCurrencyISOCode, Contact.AccountId from User where id=:UserInfo.getUserId()];
            updateServiceChargesOnWorkOrder(updatedWorkOrders, userList[0]);
        }
    }
    
    public static void updateServiceChargesOnWorkOrder(list<WorkOrder> newWorkOrders, User currentUser){
        /* regionSet is Map of CurrencyISOCode to Region*/
        Map<String, String> regionSet = new Map<String, String>();
        set<String> brandSet = new set<String>();
        for(WorkOrder workOrderRecord : newWorkOrders){
            if(workOrderRecord.CurrencyIsoCode != null){
                String region = Utility.regionBased(String.valueOf(workOrderRecord.CurrencyIsoCode));
                regionSet.put(workOrderRecord.CurrencyIsoCode, region);
            }
            if(workOrderRecord.brand__c != null && workOrderRecord.brand__c != ''){
                brandSet.add(workOrderRecord.Brand__c);
            }
        }
        
        set<String> tempRegionSet = new set<String>();
        tempRegionSet.addAll(regionSet.values());
        Map<String, Id> regionToPricebookMap = Utility.createRegionToPricebookMap(tempRegionSet);
        map<String, map<String, Id>> regionToBRANDToPricebookIdMap = Utility.createRegionToWholesalePricebookMap(tempRegionSet, brandSet);
        Map<Id, Set<Id>> pricebookToProductMap = new Map<Id, Set<Id>>();
        Set<Id> allProducts = new Set<Id>();
                
        /*Assigning Wholesale Pricebook to Work Orders*/
        for(WorkOrder workOrderRecord : newWorkOrders){
            //String region = Utility.regionBased(String.valueOf(workOrder.CurrencyIsoCode));
            String region = regionSet.get(workOrderRecord.CurrencyIsoCode);
            
            if(workOrderRecord.PriceBook2Id == null){
                if(regionToBRANDToPricebookIdMap.containsKey(region) && regionToBRANDToPricebookIdMap.get(region).containsKey(workOrderRecord.Brand__c)){
                    workOrderRecord.pricebook2Id = regionToBRANDToPricebookIdMap.get(region).get(workOrderRecord.Brand__c);
                }
            }
        }
        /*Assigning Default Pricebook to Work Orders*/
        for(WorkOrder workOrderRecord : newWorkOrders){
            //String region = Utility.regionBased(String.valueOf(workOrder.CurrencyIsoCode));
            String region = regionSet.get(workOrderRecord.CurrencyIsoCode);
            if(workOrderRecord.ServicePricebook__c == null){
                if(regionToPricebookMap.containsKey(region)){
                    workOrderRecord.ServicePricebook__c = regionToPricebookMap.get(region);
                }
            }
        }
        
         /* Creating map of Pricebook to Set of Product Map*/
        for(WorkOrder workOrder : newWorkOrders){
            allProducts.add(workOrder.Product__c);
            if(workOrder.ServicePricebook__c != null){
                if(pricebookToProductMap.containsKey(workOrder.ServicePricebook__c)){
                    pricebookToProductMap.get(workOrder.ServicePricebook__c).add(workOrder.Product__c);
                }else{
                    pricebookToProductMap.put(workOrder.ServicePricebook__c, new Set<Id>{workOrder.Product__c});
                }
            }else{
                String regionCode = regionSet.get(String.valueOf(workOrder.CurrencyIsoCode));
                if(pricebookToProductMap.containsKey(regionToPricebookMap.get(regionCode))){
                    pricebookToProductMap.get(regionToPricebookMap.get(regionCode)).add(workOrder.Product__c);
                }else{
                    pricebookToProductMap.put(regionToPricebookMap.get(regionCode), new Set<Id>{workOrder.Product__c});
                }
            }
        }
        
        Map<Id,list<PricebookEntry>> pricebookIdToPriceBookEntryListMap = createPricebookIdToPriceBookEntryListMap(pricebookToProductMap.keySet(), allProducts);
        //Map that will store the charge type(Labor/Inspection) with the tier value with the corresponding field in Pricebook entry field
        //Map<Type, Map<Tier, PricebookEntryFieldName>>
        Map<String,Map<String, String>> chargeTypeToTierMappingFieldMap = new Map<String, Map<String, String>>();
        for(Work_Order_Tier_Mapping__mdt workOrderTierMapping : [SELECT Type__c, TierValue__c, PricebookEntryFieldName__c FROM Work_Order_Tier_Mapping__mdt]){
        	if(chargeTypeToTierMappingFieldMap.containsKey(workOrderTierMapping.Type__c)){
        		chargeTypeToTierMappingFieldMap.get(workOrderTierMapping.Type__c).put(workOrderTierMapping.TierValue__c, 
                                                                                      workOrderTierMapping.PricebookEntryFieldName__c);
        	}else{
        		chargeTypeToTierMappingFieldMap.put(workOrderTierMapping.Type__c, 
        													new Map<String, String>{workOrderTierMapping.TierValue__c => 
                                                                workOrderTierMapping.PricebookEntryFieldName__c});
        	}
        }
        
        for(WorkOrder workOrderRecord : newWorkOrders){
            checkServicePriceForWorkOrder(workOrderRecord, pricebookToProductMap, currentUser, pricebookIdToPriceBookEntryListMap, chargeTypeToTierMappingFieldMap);
        }
    } 
    
    private static Case createCase(WorkOrder workOrderRecord, Id recordTypeId){
        Case caseRec = new Case();
        caseRec.RecordTypeId = recordTypeId;
        caseRec.Purchase_Date__c = workOrderRecord.PurchaseDate__c; 
        caseRec.Serial__c = workOrderRecord.Serial__c;
        caseRec.Product__c = workOrderRecord.Product__c;
        caseRec.Batch_Code__c = workOrderRecord.BatchCode__c;
        caseRec.CurrencyIsoCode = workOrderRecord.CurrencyIsoCode;
        caseRec.Subject = workOrderRecord.Subject;
        caseRec.Description = workOrderRecord.Description;
        caseRec.AccountId = workOrderRecord.AccountId;
        caseRec.Origin = 'Partner';
        caseRec.Type = Label.Support_Service_Case;
        caseRec.Complaint_Code__c = workOrderRecord.ComplaintCode__c;
        caseRec.Sub_Complaint_Code__c = workOrderRecord.Sub_Complaint_Code__c;
        caseRec.Secondary_Sub_Complaint_Code__c = workOrderRecord.Secondary_Sub_Complaint_Code__c;
        return caseRec;
    }
    
    public static void calculateDiscount(list<WorkOrder> workOrders){
        for(WorkOrder workOrderRecord : workOrders){
            
            
            workOrderRecord.Discounted_Inspection_Charge__c = workOrderRecord.InspectionCharge__c;
            workOrderRecord.Discounted_Labor_Charge__c = workOrderRecord.LaborCharge__c;
            workOrderRecord.Discounted_Freight_Charge__c = workOrderRecord.FreightCharge__c;
            //Inspection charge
            //if(workOrderRecord.InspectionCharge__c != null  && (workOrderRecord.InspectionDiscount__c !=null || workOrderRecord.Discounted_Inspection_Charge__c !=null)){
                //if(workOrderRecord.InspectionDiscount__c !=null && !(Integer.valueOf(workOrderRecord.InspectionDiscount__c) == 0 
                													//&& workOrderRecord.InspectionCharge__c != workOrderRecord.Discounted_Inspection_Charge__c)){
                    //workOrderRecord.Discounted_Inspection_Charge__c = workOrderRecord.InspectionCharge__c - ((workOrderRecord.InspectionCharge__c * workOrderRecord.InspectionDiscount__c)/100);
                //}//else if(workOrderRecord.Discounted_Inspection_Charge__c !=null){
                    //workOrderRecord.InspectionDiscount__c = (100 * (workOrderRecord.InspectionCharge__c - workOrderRecord.Discounted_Inspection_Charge__c)) / workOrderRecord.InspectionCharge__c;
                //}
            //}//else if(workOrderRecord.InspectionCharge__c != null){
                //workOrderRecord.Discounted_Inspection_Charge__c = workOrderRecord.InspectionCharge__c;
                //workOrderRecord.InspectionDiscount__c = 0;
            //}
            
            //Labor charge
           // if(workOrderRecord.LaborCharge__c !=null && (workOrderRecord.LaborDiscount__c !=null || workOrderRecord.Discounted_Labor_Charge__c !=null)){
               // if(workOrderRecord.LaborDiscount__c !=null && !(Integer.valueOf(workOrderRecord.LaborDiscount__c) == 0 
                								//					&& workOrderRecord.LaborCharge__c != workOrderRecord.Discounted_Labor_Charge__c)){
             //       workOrderRecord.Discounted_Labor_Charge__c = workOrderRecord.LaborCharge__c - (workOrderRecord.LaborCharge__c * workOrderRecord.LaborDiscount__c/100);
                //}//else if(workOrderRecord.Discounted_Labor_Charge__c !=null){
                    //workOrderRecord.LaborDiscount__c = (100 * (workOrderRecord.LaborCharge__c - workOrderRecord.Discounted_Labor_Charge__c)) / workOrderRecord.LaborCharge__c;
                //}
            //}//else if(workOrderRecord.LaborCharge__c !=null){
               // workOrderRecord.Discounted_Labor_Charge__c = workOrderRecord.LaborCharge__c;
                //workOrderRecord.LaborDiscount__c = 0;
            //}
            
            //Freight charge
            //if(workOrderRecord.FreightCharge__c !=null && (workOrderRecord.FreightDiscount__c !=null || workOrderRecord.Discounted_Freight_Charge__c !=null)){
                //if(workOrderRecord.FreightDiscount__c !=null && !(Integer.valueOf(workOrderRecord.FreightDiscount__c) == 0 
                													//&& workOrderRecord.FreightCharge__c != workOrderRecord.Discounted_Freight_Charge__c)){
                   // workOrderRecord.Discounted_Freight_Charge__c = workOrderRecord.FreightCharge__c - (workOrderRecord.FreightCharge__c * workOrderRecord.FreightDiscount__c/100);
                //}//else if(workOrderRecord.Discounted_Freight_Charge__c !=null){
                    //workOrderRecord.FreightDiscount__c = (100 * (workOrderRecord.FreightCharge__c - workOrderRecord.Discounted_Freight_Charge__c)) / workOrderRecord.FreightCharge__c;
                //}
            //}//else if(workOrderRecord.FreightCharge__c !=null){
                //workOrderRecord.Discounted_Freight_Charge__c = workOrderRecord.FreightCharge__c;
                //workOrderRecord.FreightDiscount__c = 0;
            //}
            
            //Flat Service charge
            if(workOrderRecord.FlatServiceCharge__c !=null && (workOrderRecord.FlatServiceDiscount__c !=null || workOrderRecord.Discounted_Flat_Service_Charge__c !=null)){
                if(workOrderRecord.FlatServiceDiscount__c !=null && !(Integer.valueOf(workOrderRecord.FlatServiceDiscount__c) == 0 
                													&& workOrderRecord.FlatServiceCharge__c != workOrderRecord.Discounted_Flat_Service_Charge__c)){
                    workOrderRecord.Discounted_Flat_Service_Charge__c = workOrderRecord.FlatServiceCharge__c - (workOrderRecord.FlatServiceCharge__c * workOrderRecord.FlatServiceDiscount__c/100);
                }else if(workOrderRecord.Discounted_Flat_Service_Charge__c !=null){
                    workOrderRecord.FlatServiceDiscount__c = (100 * (workOrderRecord.FlatServiceCharge__c - workOrderRecord.Discounted_Flat_Service_Charge__c)) / workOrderRecord.FlatServiceCharge__c;
                }
            }else if(workOrderRecord.FlatServiceCharge__c !=null){
                workOrderRecord.Discounted_Flat_Service_Charge__c = workOrderRecord.FlatServiceCharge__c;
                workOrderRecord.FlatServiceDiscount__c = 0;
            }
        }
    }
    
    private static void checkServicePriceForWorkOrder(WorkOrder workOrder, Map<Id, Set<Id>> pricebookToProductMap, User currentUser, 
    												Map<Id,list<PricebookEntry>> pricebookIdToPriceBookEntryListMap, Map<String, Map<String, String>> chargeTypeToTierMappingFieldMap){
        if(workOrder.ServicePricebook__c != null && workOrder.Product__c != null){
            if(pricebookIdToPriceBookEntryListMap.get(workOrder.ServicePricebook__c) != null){
                for(PricebookEntry pbe : pricebookIdToPriceBookEntryListMap.get(workOrder.ServicePricebook__c)){
                    if(pbe.Product2Id == workOrder.Product__c && pbe.Pricebook2Id == workOrder.ServicePricebook__c && pbe.CurrencyIsoCode == workOrder.CurrencyIsoCode){
                    	
                    	if(workOrder.IsFreightFeeApplicable__c){
                        	workOrder.FreightCharge__c = pbe.FreightCharge__c;
                    	}
                    	if(workOrder.InspectionChargeTierLevel__c != null && workOrder.InspectionChargeTierLevel__c != ''){
                    		if(chargeTypeToTierMappingFieldMap.containsKey('Inspection Charge') && 
                    				chargeTypeToTierMappingFieldMap.get('Inspection Charge').containsKey(workOrder.InspectionChargeTierLevel__c)){
                    			String pricebookEntryFieldName = chargeTypeToTierMappingFieldMap.get('Inspection Charge').get(workOrder.InspectionChargeTierLevel__c);
                    			if(pbe.get(pricebookEntryFieldName) != null && (Double)pbe.get(pricebookEntryFieldName) > 0){
                    				workOrder.InspectionCharge__c = (Double)pbe.get(pricebookEntryFieldName);
                    			}else{
                    				workOrder.addError('No Inspection Charge found for selected selected Tier');
                    			}
                    		}else{
                    			workOrder.addError('Selected Tier is not applicable for selected Inspection Charge');
                    		}
                       		//workOrder.InspectionCharge__c = pbe.InspectionCharge__c;
                    	}
                    	if(workOrder.LaborChargeTierLevel__c != null && workOrder.LaborChargeTierLevel__c != ''){
                    		if(chargeTypeToTierMappingFieldMap.containsKey('Labor Charge') && 
                    				chargeTypeToTierMappingFieldMap.get('Labor Charge').containsKey(workOrder.LaborChargeTierLevel__c)){
                    			String pricebookEntryFieldName = chargeTypeToTierMappingFieldMap.get('Labor Charge').get(workOrder.LaborChargeTierLevel__c);
                    			if(pbe.get(pricebookEntryFieldName) != null && (Double)pbe.get(pricebookEntryFieldName) > 0){
                    				workOrder.LaborCharge__c = (Double)pbe.get(pricebookEntryFieldName);
                    			}else{
                    				workOrder.addError('No Labor Charge found for selected Tier');
                    			}
                    		}else{
                    			workOrder.addError('Selected Tier is not applicable for Labor Charge');
                    		}
                        	//workOrder.LaborCharge__c = pbe.LaborCharge__c;
                    	}
						//Populate Flat Service charge, applicable for US only
                        workOrder.FlatServiceCharge__c = pbe.ServiceCharge__c;
                        
                        //Populate the claim charge, applicable for USA
                        workOrder.ClaimableLaborCharge__c = pbe.ClaimCharge__c;
                    }
                }
            }
        }
    }
    
    /* Creating PricebookId to List of PricebookEntry Map*/
    private static  Map<Id, list<PricebookEntry>> createPricebookIdToPriceBookEntryListMap(Set<Id> priceBookIdSet, Set<Id> allProducts){
        Map<Id, list<PricebookEntry>> returnmap = new Map<Id, list<PricebookEntry>>();
        list<PricebookEntry> priceBookEntryList = [SELECT Id, Product2Id, CurrencyIsoCode, UnitPrice, ServiceCharge__c,
                                                            InspectionCharge__c, FreightCharge__c, LaborCharge__c, ClaimCharge__c, Pricebook2Id,
                                                            Tier2InspectionCharge__c, Tier2LaborCharge__c, Tier3LaborCharge__c, Tier4LaborCharge__c
                                                            FROM PricebookEntry 
                                                            WHERE IsActive = true
                                                            AND Pricebook2Id IN: priceBookIdSet
                                                            AND Product2Id IN: allProducts];
        if(priceBookEntryList != null && priceBookEntryList.size()>0){
            for(PricebookEntry pricebookEntryRecord : priceBookEntryList){
                if(returnmap.containsKey(pricebookEntryRecord.Pricebook2Id)){
                    returnmap.get(pricebookEntryRecord.Pricebook2Id).add(pricebookEntryRecord);
                }else{
                    list<PricebookEntry> PBEList = new list<PricebookEntry>();
                    PBEList.add(pricebookEntryRecord);
                    returnmap.put(pricebookEntryRecord.Pricebook2Id, PBEList);
                }
            }
        }
        return returnmap;
    }
    
    public static void checkWorkOrderStatus(list<WorkOrder> workOrdersList, map<Id, WorkOrder> oldWorkOrderMap){
        
        map<Id,Case> caseByIdmap = new map<Id,Case>();
        
        for(WorkOrder workOrder : workOrdersList){
            if(workOrder.IsClosed && !oldWorkOrderMap.get(workOrder.Id).IsClosed && workOrder.CaseId != null && !caseByIdmap.containsKey(workOrder.CaseId) && 
            	!workOrder.Status.equalsIgnoreCase('Repeat Workorder')){
                Case caseRec = new Case(Id = workOrder.CaseId, status = 'Closed');
                caseByIdmap.put(caseRec.Id,caseRec); 
            }
        }
        if(caseByIdmap != null && !caseByIdmap.isEmpty() ){
            update caseByIdmap.values();
        }
    }
    
    public static Account createAccountRecord(WorkOrder workorderRecord){
        Account newAccount = new Account();
        newAccount.FirstName = workorderRecord.FirstName__c;
        newAccount.lastName = workorderRecord.LastName__c;
        newAccount.PersonEmail = workorderRecord.Email__c;
        newAccount.Phone = workorderRecord.Phone__c;
        newAccount.BillingStreet = workorderRecord.Street;
        newAccount.BillingCity = workorderRecord.City;
        newAccount.BillingState = workorderRecord.State;
        newAccount.BillingStateCode = workorderRecord.StateCode;
        newAccount.BillingPostalCode = workorderRecord.PostalCode;
        newAccount.BillingCountry = workorderRecord.Country;
        newAccount.BillingCountryCode = workorderRecord.CountryCode;
        newAccount.CurrencyIsoCode = workorderRecord.CurrencyIsoCode;
        All_Literal__mdt literal = [select Value__c from All_Literal__mdt where DeveloperName='CustomUserId' LIMIT 1];
        newAccount.OwnerId = Id.valueOf(literal.Value__c);
        return newAccount;
    }
    
    public static void updateCaseIdOnWorkOrder(list<WorkOrder> workOrderList){
        RecordType claimRecordType = [SELECT ID FROM RecordType WHERE Name='Claim' AND sobjecttype = 'WorkOrder' LIMIT 1][0];
        map<Id, String> workorderIdToCaseNumberMap = new Map<Id, String>();
        Set<Id> caseIdSet = new Set<Id>();
        
        for(WorkOrder workOrder : workOrderList){
            if(!(workOrder.RecordTypeId != null && workOrder.RecordTypeId == claimRecordType.Id)){
                //Cases created by Call center but no work order created for them
                if(workOrder.CaseNumber__c != null && workOrder.CaseNumber__c != '' && workOrder.caseId == null){
                    workorderIdToCaseNumberMap.put(workOrder.Id, workOrder.CaseNumber__c);
                }else if(workOrder.caseId != null){
                    caseIdSet.add(workOrder.caseId);
                }
            }
        }
        
        if(workorderIdToCaseNumberMap != null && workorderIdToCaseNumberMap.size() > 0){
            System.enqueueJob(new UpdateCaseIdOnWorkOrder(workorderIdToCaseNumberMap));
        }
        
        if(caseIdSet != null && caseIdSet.size() > 0){
            System.enqueueJob(new UpdateContactIdOnCase(caseIdSet));
        }
    }
    
    /* this method will populate Tax rate record for ASC workorders 
    public static void populateTaxRecord(list<WorkOrder> workorderList){
        User currentUser = [select Id, IsPortalEnabled, AccountID, DefaultCurrencyIsoCode from User where Id =: UserInfo.getUserId()];
        list<Account> accountRecord = [SELECT ID, CurrencyIsoCode, ShippingPostalCode, ShippingStateCode,ShippingCountryCode FROM Account WHERE Id = :currentUser.AccountId];
        String addressFieldValue;
        
        Boolean isPortalUser = currentUser.IsPortalEnabled;
        if(isPortalUser){
            list<MasterTaxData__mdt> masterTaxDataList = [SELECT DeveloperName, IsZip2TaxApplicable__c, AddressFieldOnOrder__c, AddressFieldOnWorkOrder__c, CacheDurationInDays__c 
                                                            FROM MasterTaxData__mdt
                                                            WHERE DeveloperName =: currentUser.DefaultCurrencyIsoCode];
            addressFieldValue = (String)accountRecord[0].get(masterTaxDataList[0].AddressFieldOnWorkOrder__c);
        
            list<Tax_Rate__c> taxRateList = [SELECT Id, Name, LastModifiedDate, CitySalesTaxRate__c, City_Use_Tax_Rate__c, Combined_Rate__c, CombinedUseTaxRate__c, GST_Tax_Rate__c,
                                                    Country_Use_Tax_Rate__c, CountyUseTaxRate__c, Provincial_Tax_Rate__c, SpecialSalesTaxRate__c, SpecialUseTaxRate__c, StateUseTaxRate__c,
                                                    County_Sales_Tax_Rate__c, PricesInclusiveOfTaxes__c
                                                    FROM Tax_Rate__c
                                                    WHERE Name  = :addressFieldValue ORDER BY LastModifiedDate DESC LIMIT 1];
                                                    
            if(taxRateList != null && taxRateList.size() > 0){
                for(WorkOrder workOrderRecord : workorderList){
                    TaxRate taxRateRecord= new TaxRate();
                    taxRateRecord.filterWorkOrders(workOrderRecord, accountRecord[0], taxRateList[0]);
                }
            }
        }
    }
    */
    
    /* to populate Tax rate record for ASC work orders (considering Billing address of Customers) STARTS*/
    /*public static void populateTaxRecordwithBillingAddress(list<WorkOrder> workorderList){
    	
		   	
    	Map<Id,Id> workOrderIdToAccountId = new Map<Id,Id>();
    	Map<Id, Account> idToAccountMap = new Map<Id,Account>();
    	Map<String,String> currencyToAddressFieldMap = new Map<String, String>();
    	Set<String> addressFieldValues = new Set<String>();
    	Map<String, Tax_Rate__c> addressFieldToTaxRateRecordMap = new Map<String, Tax_Rate__c>();
    	List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
    	
    	for(WorkOrder workOrderRecord : workorderList){
    		if(workOrderRecord.AccountId != null){
    			workOrderIdToAccountId.put(workOrderRecord.Id, workOrderRecord.AccountId);
    			workOrdersToUpdate.add(new WorkOrder(Id=workOrderRecord.Id, CurrencyIsoCode=workOrderRecord.CurrencyIsoCode, AccountId=workOrderRecord.AccountId));
    		}
    	}
    	
    	list<MasterTaxData__mdt> masterTaxDataList = [SELECT DeveloperName, IsZip2TaxApplicable__c, AddressFieldOnOrder__c, AddressFieldOnWorkOrder__c, CacheDurationInDays__c 
                                                            FROM MasterTaxData__mdt];
		
		if(masterTaxDataList != null && masterTaxDataList.size() > 0){
			for(MasterTaxData__mdt masterTaxRecord : masterTaxDataList){
				currencyToAddressFieldMap.put(masterTaxRecord.DeveloperName, masterTaxRecord.AddressFieldOnWorkOrder__c);
			}
		}
    	
        list<Account> accountList = [SELECT ID, CurrencyIsoCode, BillingPostalCode, BillingStateCode, BillingCountryCode FROM Account 
        							WHERE Id IN :workOrderIdToAccountId.values()];
    	for(Account accountRecord: accountList){
    		idToAccountMap.put(accountRecord.Id, accountRecord);
    		addressFieldValues.add((String)accountRecord.get(currencyToAddressFieldMap.get(accountRecord.CurrencyIsoCode)));
    	}
    	
    	list<Tax_Rate__c> taxRateList = [SELECT Id, Name, LastModifiedDate, CitySalesTaxRate__c, City_Use_Tax_Rate__c, Combined_Rate__c, CombinedUseTaxRate__c, GST_Tax_Rate__c,
                                                    Country_Use_Tax_Rate__c, CountyUseTaxRate__c, Provincial_Tax_Rate__c, SpecialSalesTaxRate__c, SpecialUseTaxRate__c, StateUseTaxRate__c,
                                                    County_Sales_Tax_Rate__c, PricesInclusiveOfTaxes__c
                                                    FROM Tax_Rate__c
                                                    WHERE Name  = :addressFieldValues];
    	
    	if(taxRateList != null && taxRateList.size() > 0){
	    	for(Tax_Rate__c taxRateRecord : taxRateList){
	    		addressFieldToTaxRateRecordMap.put(taxRateRecord.Name, taxRateRecord);
	    	}
    	}
    	
    	for(WorkOrder workOrderRecord : workOrdersToUpdate){
            TaxRate taxRateRecord= new TaxRate();
            taxRateRecord.filterWorkOrders(workOrderRecord, idToAccountMap.get(workOrderRecord.AccountId), 
            								addressFieldToTaxRateRecordMap.get(idToAccountMap.get(workOrderRecord.AccountId).CurrencyIsoCode));
        }
        
        try{
        	update workOrdersToUpdate;
        }catch(DMLException ex){
        	
        }
    	
    }*/
    /* to populate Tax rate record for ASC work orders (considering Billing address of Customers) ENDS*/
    
    /*to populate Case order type on Case*/
    public static void poulateOrderTypeOnCase(list<WorkOrder> workOrderList){
        map<Id, Case> idToCaseMap = new map<Id, Case>();
        /*iterate through WorkOrder and update Case order type if WorkOrder contains Case*/ 
        for(WorkOrder workOrderRecord : workOrderList){
            if(workOrderRecord.CaseId != null){
                if(!idToCaseMap.containsKey(workOrderRecord.CaseId)){
                    idToCaseMap.put(workOrderRecord.CaseId, new Case(Id=workOrderRecord.CaseId, Order_Type__c='SERVICE'));
                }
            }
        }
        if(idToCaseMap != null && idToCaseMap.size() > 0){
            update idToCaseMap.values();
        }
        
    }
    /*poulateCaseTypeOnCase exits*/
    
    /*
    public static void updateQCAlertCounter(list<WorkOrder> workOrderList){
        Map<String, WorkOrder> caseNumberToWorkOrderMap = new Map<String, WorkOrder>();
        
        for(WorkOrder workOrder : workOrderList){
            if(workOrder.CaseNumber__c != null && workOrder.CaseNumber__c != '' && workOrder.Product__c != null){
                caseNumberToWorkOrderMap.put(workOrder.CaseNumber__c, workOrder);
            }
        }
        
        if(caseNumberToWorkOrderMap != null && caseNumberToWorkOrderMap.size() > 0){
            for(Case caseRec : [SELECT Id, CaseNumber, QC_Alert__c, Service_Center__c 
                                                        FROM Case 
                                                        WHERE CaseNumber IN: caseNumberToWorkOrderMap.keySet()
                                                        AND QC_Alert__c != NULL
                                                        AND Service_Center__c != NULL]){
            
            }
        }
    }
   */
   
   
   /*method to populate AX Account Number on Order based on Brand, Order Type, Region and Currency*/
    public static void populateAXAccountNumber(list<WorkOrder> orderList, map<Id, WorkOrder> oldMap){
        
        /*set and map to bulkify code*/
        Set<String> brandSet = new Set<String>();
        Set<String> currencySet = new Set<String>();
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<String, String> keyToAccountNumberMap = new Map<String, String>();
        List<WorkOrder> newOrderList = new List<WorkOrder>();
        Set<String> useASCAccountCode = new Set<String>();
        /*iterating Orders to create Sets*/
        if(orderList != null && orderList.size() > 0){
            for(WorkOrder orderRecord : orderList){
                String key = '';
                if((Trigger.isInsert) || 
                        (Trigger.isUpdate && (orderRecord.Brand__c != oldMap.get(orderRecord.Id).Brand__c ||
                                    orderRecord.CurrencyIsoCode != oldMap.get(orderRecord.Id).CurrencyIsoCode))){
                    
                    if(orderRecord.CurrencyIsoCode != null && orderRecord.CurrencyIsoCode != ''){
                        currencySet.add(orderRecord.CurrencyIsoCode);
                    }
                    if(orderRecord.ServiceCentre__c != null){
                        accountIdSet.add(orderRecord.ServiceCentre__c);
                    }
                    if(orderRecord.Product__c != null){
                        productIdSet.add(orderRecord.Product__c);
                    }
                    newOrderList.add(orderRecord);
                }
            }
        }
        
        map<Id, Product2> idToProductMap = new map<Id, Product2>([SELECT Id, Brand__c, Remanufactured__c FROM Product2 where Id IN :productIdSet]);
        
        map<Id, Account> idToAccountMap = new Map<Id, Account>([SELECT Id, VendAccount__c FROM Account WHERE Id IN: accountIdSet]);
        
        for(WorkOrder orderRecord : orderList){
            if(idToProductMap != null && idToProductMap.size() > 0){
                if(idToProductMap.containsKey(orderRecord.Product__c) && idToProductMap.get(orderRecord.Product__c) != null
                    && idToProductMap.get(orderRecord.Product__c).Brand__c != null && idToProductMap.get(orderRecord.Product__c).Brand__c != ''){
                        orderRecord.Brand__c = idToProductMap.get(orderRecord.Product__c).Brand__c;
                        brandSet.add(orderRecord.Brand__c);
                    }
            }
        }
                
        
        
        /*Iterating metadata and creating key and map*/
        list<AXAccountNumbers__mdt> accountNumbersList = [SELECT AccountNumber__c, Brand__c, HasRefurbish__c, Currency__c, Type__c,UsePartnerAXAccountCode__c FROM AXAccountNumbers__mdt
                                                WHERE Brand__c IN :brandSet AND Currency__c IN :currencySet AND Type__c = 'Accommodation' AND OrderOrWorkOrder__c = 'Work Order'];
        if(accountNumbersList != null && accountNumbersList.size() > 0){
            for(AXAccountNumbers__mdt accountNumberRecord : accountNumbersList){
                String key = '';
                if(accountNumberRecord.Brand__c != null && accountNumberRecord.Brand__c != ''){
                    key = key +accountNumberRecord.Brand__c;
                }
                if(accountNumberRecord.Currency__c != null && accountNumberRecord.Currency__c != ''){
                    key = key +accountNumberRecord.Currency__c;
                }
                if(accountNumberRecord.HasRefurbish__c != null){
                    key = key +accountNumberRecord.HasRefurbish__c;
                }
                keyToAccountNumberMap.put(key.toUpperCase(), accountNumberRecord.AccountNumber__c);
                if(accountNumberRecord.UsePartnerAXAccountCode__c || accountNumberRecord.AccountNumber__c == 'ASC'){
                    useASCAccountCode.add(key.toUpperCase()); 
                }
            }
        }                                       
        
        /*iterating Orders again to assign AX Account Number from the Map created above*/
        if(newOrderList != null && newOrderList.size() > 0){
            for(WorkOrder orderRecord : newOrderList){
                Boolean isRefurbished = false;
                if(idToProductMap != null && orderRecord.Product__c != null && idToProductMap.containsKey(orderRecord.Product__c) 
                                    && idToProductMap.get(orderRecord.Product__c).Remanufactured__c){
                    isRefurbished = true;
                }
                String key = createKey(orderRecord, isRefurbished);
                if(useASCAccountCode.contains(key)){
                    if(orderRecord.ServiceCentre__c != null && idToAccountMap != null && idToAccountMap.size() > 0 && idToAccountMap.containsKey(orderRecord.ServiceCentre__c) 
                                    && idToAccountMap.get(orderRecord.ServiceCentre__c).VendAccount__c != null && idToAccountMap.get(orderRecord.ServiceCentre__c).VendAccount__c != ''){
                        orderRecord.AXAccountNumber__c = idToAccountMap.get(orderRecord.ServiceCentre__c).VendAccount__c;
                    }else{
                        orderRecord.AXAccountNumber__c = '';
                    }
                }else{
                    if(keyToAccountNumberMap.containsKey(key)){
                        orderRecord.AXAccountNumber__c = keyToAccountNumberMap.get(key);
                    }
                }
            }
        }
    }
    /* populateAXAccountNumber exits*/
    
    /* create key map*/
    private static String createKey(WorkOrder orderRecord, Boolean isRefurbished){
        String key = '';
        if(orderRecord.Brand__c != null && orderRecord.Brand__c != ''){
            key = key +orderRecord.Brand__c;
        }
        if(orderRecord.CurrencyIsoCode != null && orderRecord.CurrencyIsoCode != ''){
            key = key +orderRecord.CurrencyIsoCode;
        }
        if(isRefurbished){
            key = key +'true';
        }else{
            key = key +'false';
        }
        return key.toUpperCase();
    }
    /*createKey exits*/
   
    //
    public static void populatePricebookIdOnClaim(list<WorkOrder> workOrderList){
        Id claimRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        Set<WorkOrder> claimSet = new Set<WorkOrder>();
        Set<Id> parentWorkOrderSet = new Set<Id>();
        Map<Id, Id> workOrderIdtoPricebookIdMap = new Map<Id, Id>();
        if(claimRecordTypeId != null){
            for(WorkOrder workOrderRec : workOrderList){
                if(workOrderRec.WorkOrder__c != null && workOrderRec.RecordTypeId != null && workOrderRec.RecordTypeId == claimRecordTypeId){
                    claimSet.add(workOrderRec);
                    parentWorkOrderSet.add(workOrderRec.WorkOrder__c);
                }
            }
        }
        
        if(claimSet != null && claimSet.size() > 0 ){
            for(WorkOrder workOrderRec : [SELECT Id, Pricebook2Id FROM WorkOrder WHERE Id IN: parentWorkOrderSet AND Pricebook2Id != null]){
                workOrderIdtoPricebookIdMap.put(workOrderRec.Id, workOrderRec.Pricebook2Id);
            }
            
            for(WorkOrder claim : claimSet){
                if(workOrderIdtoPricebookIdMap.containsKey(claim.WorkOrder__c)){
                    claim.Pricebook2Id = workOrderIdtoPricebookIdMap.get(claim.WorkOrder__c);
                }
            }
        }
    }
    
    /*method to populate approved status on work order line items*/
    public static void populateApprovalStatusOnLineItems(list<WorkOrder> workOrdersList, map<Id, WorkOrder> oldWorkOrderMap){
    	
    	set<Id> workOrderIdSet = new set<Id>();
    	for(WorkOrder workOrderRecord : workOrdersList){
    		if(workOrderRecord.ApprovalStatus__c == 'Approved' && oldWorkOrderMap.get(workOrderRecord.Id).ApprovalStatus__c != workOrderRecord.ApprovalStatus__c){
    			workOrderIdSet.add(workOrderRecord.Id);
    		}
    	}
    	list<WorkOrderLineItem> workOrderLineItemList = [SELECT Id, IsApproved__c FROM WorkOrderLineItem where WorkOrderId IN :workOrderIdSet AND IsApproved__c = false];
    	if(workOrderLineItemList != null && workOrderLineItemList.size() > 0){
    		for(WorkOrderLineItem lineItem : workOrderLineItemList){
    			lineItem.IsApproved__c = true; 
    		}
    		try{
    			update workOrderLineItemList;
    		}catch(DMLException e){
    			ErrorLog.logErrorActivity(e,'Error in updating Work Order Line Items from WorkOrderTriggerHandler METHOD populateApprovalStatusOnLineItems',true,'Error');
    		}
    	}
    	
    }
    
    public static void updateASCEmail(list<WorkOrder> workOrdersList, map<Id, WorkOrder> oldWorkOrderMap){
    	List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
    	Set<Id> serviceCenterIdSet = new Set<Id>();
    	for(WorkOrder workOrderRec : workOrdersList){
    		if(workOrderRec.ServiceCentre__c != null && 
    					(Trigger.isInsert || (Trigger.isUpdate && workOrderRec.ServiceCentre__c != oldWorkOrderMap.get(workOrderRec.Id).ServiceCentre__c))){
    			workOrdersToUpdate.add(workOrderRec);
    			serviceCenterIdSet.add(workOrderRec.ServiceCentre__c);
    		}
    	}
    	if(workOrdersToUpdate != null && workOrdersToUpdate.size() > 0 && serviceCenterIdSet != null && serviceCenterIdSet.size() > 0){
    		Map<Id, Account> serviceCenterIdASCMap = new Map<Id, Account>([SELECT Id, BusinessCommunicationEmail__c 
    																	FROM Account WHERE Id IN: serviceCenterIdSet AND BusinessCommunicationEmail__c != null]);
    		if(serviceCenterIdASCMap != null && serviceCenterIdASCMap.size() > 0){															
	    		for(WorkOrder wo : workOrdersToUpdate){
	    			if(serviceCenterIdASCMap.containsKey(wo.ServiceCentre__c)){
	    				wo.ServiceCenterEmail__c = serviceCenterIdASCMap.get(wo.ServiceCentre__c).BusinessCommunicationEmail__c;
	    			}
	    		}	
    		}														
    	}
    }
    
    public static void populateCaseInfo(list<WorkOrder> workOrdersList){
    	Set<Id> caseIds = new Set<Id>(); 
    	for(WorkOrder workOrderRecord : workOrdersList){
    		if(workOrderRecord.CaseId != null){
    			caseIds.add(workOrderRecord.CaseId);
    		}
    	}
    	Map<Id, Case> idToCaseMap = new Map<Id, Case>([SELECT Id, Batch_Code__c, Serial__c, Purchase_Date__c FROM Case WHERE Id IN :caseIds]);
    	
    	if(idToCaseMap != null && idToCaseMap.size() > 0){
    		for(WorkOrder workOrderRecord : workOrdersList){
    			System.debug('### 1');
	    		if(workOrderRecord.CaseId != null && idToCaseMap.get(workOrderRecord.CaseId) != null){
	    			if(workOrderRecord.BatchCode__c == null || workOrderRecord.BatchCode__c == '')
	    				workOrderRecord.BatchCode__c = idToCaseMap.get(workOrderRecord.CaseId).Batch_Code__c;
	    			if(workOrderRecord.PurchaseDate__c == null)
	    				workOrderRecord.PurchaseDate__c = idToCaseMap.get(workOrderRecord.CaseId).Purchase_Date__c;
	    			if(workOrderRecord.Serial__c == null || workOrderRecord.Serial__c == '')
	    				workOrderRecord.Serial__c = idToCaseMap.get(workOrderRecord.CaseId).Serial__c;
	    		}
	    	}
    	}
    	
    }
    
   
}