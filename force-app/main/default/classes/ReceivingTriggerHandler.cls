public  without sharing class ReceivingTriggerHandler{
    
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
    
    public static void shareWithServiceCentre(list<Receiving__c> newReceivings,map<Id,Receiving__c> oldmap,Boolean isInsert){
        
        list<Receiving__c> receivingneedtoShare = new list<Receiving__c>();
        List<Id> shareIdsToDelete = new List<Id>();
        set<Id> serviceCentreCaseIds = new set<Id>();
        set<Id> serviceCentreAccountIds = new set<Id>();
        map<Id,Id> accountIdByCaseId = new map<Id,Id>();
        
        for(Receiving__c receiving : newReceivings){
            
            if(isInsert && receiving.Case__c != NULL){
                receivingneedtoShare.add(receiving);
                serviceCentreCaseIds.add(receiving.Case__c);
                
            }else if(oldmap != null && ((oldmap.get(receiving.id).Case__c != receiving.Case__c) )){
                
                //add to delete list to delete share records
                shareIdsToDelete.add(receiving.id);
                if(receiving.Case__c != NULL){
                    receivingneedtoShare.add(receiving);
                    serviceCentreCaseIds.add(receiving.Case__c);
                }
                
            }
        }
        
        for(Case caseRec : [Select Id,AccountId from Case where Id IN :serviceCentreCaseIds and AccountId != NULL]){
            accountIdByCaseId.put(caseRec.Id,caseRec.AccountId);
            serviceCentreAccountIds.add(caseRec.AccountId);
        }
        
        if(!shareIdsToDelete.isEmpty()){
            delete [SELECT Id FROM Receiving__Share 
                    WHERE ParentId IN :shareIdsToDelete 
                    AND RowCause =: Schema.Receiving__Share.RowCause.ServiceCentreAccess__c];
        }
        
        if(!receivingneedtoShare.isEmpty()){
            List<Receiving__Share> sharesToCreate = new List<Receiving__Share>();
            map<Id, Set<Id>> partnerUserIdByAccountId = Utility.getPartnerUserIdByAccountId(serviceCentreAccountIds);
            for(Receiving__c receiving : receivingneedtoShare){
                if(accountIdByCaseId.containsKey(receiving.Case__c) && partnerUserIdByAccountId.containsKey((accountIdByCaseId.get(receiving.Case__c)))){
                    for(Id userId : partnerUserIdByAccountId.get(accountIdByCaseId.get(receiving.Case__c))){
                        sharesToCreate.add(createRecevingShare(receiving.Id, userId));
                    }
                }
            }
            Database.insert(sharesToCreate,false);
        }
        
        
    }
    
    public static Receiving__Share createRecevingShare(Id recevingId, Id userOrGroupId){
        Receiving__Share share = new Receiving__Share();
        share.ParentId = recevingId;
        share.UserOrGroupId = userOrGroupId;                                              
        share.AccessLevel = 'Read';
        share.RowCause = Schema.Receiving__Share.RowCause.ServiceCentreAccess__c;
        return share;
    }
    
    public static void setCaseRMAStatus(list<Receiving__c> newReceivings){
        set<ID> caseIDset = new Set<Id>();
        List<case> casesToUpdate = new List<Case>();
        for(Receiving__c receiving : newReceivings){
            if(receiving.Case__c != NULL){
                caseIDset.add(receiving.Case__c);
            }
        }
        
        if(!caseIDset.isEmpty()){ 
            for(Case c : [select id, rma_status__c from Case 
                          where id in :caseIDset 
                          and rma_status__c != 'Credit Pending' 
                          and rma_status__C != 'Credit Complete']){
                              
                              c.rma_status__c = 'Items Received';
                              casesToUpdate.add(c);
                          }
            
            Database.update(casesToUpdate,false);
            CaseTriggerHandler.afterTriggerRun = true;
            CaseTriggerHandler.beforeTriggerRun = true;
        }
    }
    
    public static void populateRTVUniqueIdANDCreditTotal(List<Receiving__c> newReceivings, map<Id,Receiving__c> oldmap, Boolean isInsert, Boolean isUpdate){
        List<Receiving__c> receivingWithBlankRTV = new List<Receiving__c>();
        List<Receiving__c> receivingWhereTotalIsUpdated = new List<Receiving__c>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Receiving__c receiving : newReceivings){
            if(receiving.Case__c != null && (receiving.RTV__c == null || (receiving.RTV__c != null && receiving.RTV__c == ''))){
                receivingWithBlankRTV.add(receiving);
                caseIdSet.add(receiving.Case__c);
            }
            
            if((isInsert || (isUpdate && (receiving.RMACalculatedUnitPrice__c != oldmap.get(receiving.Id).RMACalculatedUnitPrice__c || 
                                          receiving.Received_Qty__c != oldmap.get(receiving.Id).Received_Qty__c)))
               && receiving.RMACalculatedUnitPrice__c != null && receiving.Received_Qty__c != null){
                   receivingWhereTotalIsUpdated.add(receiving);
               }
            if(isUpdate && receiving.RMACalculatedTotalPrice__c != null && (receiving.RMACalculatedUnitPrice__c == null || receiving.Received_Qty__c == null)){
                receiving.RMACalculatedTotalPrice__c = null;
            }
        }
        
        if(receivingWithBlankRTV != null && receivingWithBlankRTV.size() > 0){
            Map<Id, String> caseIdToRTVValue = new Map<Id, String>();
            
            for(Case caseRecord : [SELECT Id, RTV__c FROM Case WHERE Id IN: caseIdSet AND RTV__c != null]){
                caseIdToRTVValue.put(caseRecord.Id, caseRecord.RTV__c);
            }
            
            if(caseIdToRTVValue != null && caseIdToRTVValue.size() > 0){
                for(Receiving__c receiving : receivingWithBlankRTV){
                    if(caseIdToRTVValue.containsKey(receiving.Case__c)){
                        receiving.RTV__c = caseIdToRTVValue.get(receiving.Case__c);
                    }
                }
            }
        }
        
        if(receivingWhereTotalIsUpdated != null && receivingWhereTotalIsUpdated.size() > 0 ){
            for(Receiving__c receiving : receivingWhereTotalIsUpdated){
                receiving.RMACalculatedTotalPrice__c = receiving.RMACalculatedUnitPrice__c * receiving.Received_Qty__c;
            }
        }
    }
    
    
    public static void createNewCaseFromReceiving(list<Receiving__c> receivingList){
        
        set<Id> caseIdSet = new set<Id>();
        map<String,Case> newCaseByRTVUniqueId = new map<String,Case>();
        map<String,Case> oldCaseByCaseId = new map<String,Case>();
        String unqiueId = '';
        
        for(Receiving__c receivingRecord : receivingList){
            if( receivingRecord.GenerateNewFormatRMA__c  ){
                caseIdSet.add(receivingRecord.Case__c);
                //unqiueId = 'BVL' + receivingRecord.AccountNumber__c+ (receivingRecord.RTV__C != null ? receivingRecord.RTV__C : receivingRecord.RA__c);
                //newCaseNumberByRTVUniqueId.put(receivingRecord.RA__c,unqiueId);
                //caseIdToReceivingMap.put(receivingRecord.Case__c, receivingRecord);
            }
        }
        system.debug('###caseIdSet'+caseIdSet);
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
        if(caseIdSet != null && caseIdSet.size() > 0){
            
            for( Case caseRec : [SELECT Id, CaseNumber, AccountId, Country__c,CurrencyIsoCode, OldRMACaseNumber__c,New_Old_RMA_Case__c, RTV_Unique_ID__c, 
                                 RTV__c, Return_Location__c, Status, recordTypeId,  Type, Subject
                                 FROM Case WHERE Id IN :caseIdSet ]){
                                     if(caseRec.CaseNumber.startsWith('BVL')){
                                         
                                         oldCaseByCaseId.put(caseRec.id,caseRec);
                                     }
                                     
                                 }
            system.debug('###oldCaseByCaseId'+oldCaseByCaseId);
            for(Receiving__c receivingRecord : receivingList){
                
                if(oldCaseByCaseId.containsKey(receivingRecord.Case__c) && oldCaseByCaseId.get(receivingRecord.Case__c).New_Old_RMA_Case__c == null){
                    
                    unqiueId = 'BVL' + receivingRecord.AccountNumber__c+ (receivingRecord.RTV__C != null ? receivingRecord.RTV__C : receivingRecord.RA__c);
                    
                    newCaseByRTVUniqueId.put(receivingRecord.Case__c, 
                                             new Case(
                                                 RTV_Unique_ID__c = unqiueId,
                                                 RecordTypeId =  caseRmaRecordTypeId,
                                                 OldRMACaseNumber__c = oldCaseByCaseId.get(receivingRecord.Case__c).CaseNumber,
                                                 CurrencyIsoCode = oldCaseByCaseId.get(receivingRecord.Case__c).CurrencyIsoCode,
                                                 Subject = oldCaseByCaseId.get(receivingRecord.Case__c).Subject,
                                                 Type = 'RMA',
                                                 RTV__C =  oldCaseByCaseId.get(receivingRecord.Case__c).RTV__C,
                                                 Status =oldCaseByCaseId.get(receivingRecord.Case__c).Status,
                                                 AccountId = oldCaseByCaseId.get(receivingRecord.Case__c).AccountId
                                             )
                                            );
                }
            }
            CaseTriggerHandler.runCaseTrigger = false;
            upsert newCaseByRTVUniqueId.values() RTV_Unique_ID__c;
            list<Receiving__c> recevingList = new list<Receiving__c>(); 
            for(Receiving__c receivingRecord : receivingList){
                
                if(receivingRecord.GenerateNewFormatRMA__c  ){
                    
                    if(oldCaseByCaseId.containsKey(receivingRecord.Case__c)){
                        system.debug('###'+oldCaseByCaseId.get(receivingRecord.Case__c).New_Old_RMA_Case__c);
                        if(oldCaseByCaseId.get(receivingRecord.Case__c).New_Old_RMA_Case__c != null){
                            recevingList.add(new Receiving__c(Id=receivingRecord.id,
                                                              OldCase__c = receivingRecord.Case__c,
                                                              Case__c= oldCaseByCaseId.get(receivingRecord.Case__c).New_Old_RMA_Case__c));
                        }else if(newCaseByRTVUniqueId.containsKey(receivingRecord.Case__c)){
                            recevingList.add(new Receiving__c(Id=receivingRecord.id,
                                                              OldCase__c = receivingRecord.Case__c,
                                                              Case__c= newCaseByRTVUniqueId.get(receivingRecord.Case__c).Id));
                        }
                        
                    }
                    
                }
            }
            system.debug('###recevingList'+recevingList);
            update recevingList;
            
        }
        
    }
    
    public static void populateRreceivingValuesForPartners(list<Receiving__c> receivingList){
        
        User currentUser;
        map<String,Id> caseByCaseNumberOrRTV = new map<String,Id>();
        set<String> rtvs = new set<String>();
        set<String> racases = new set<String>();
        list<User> currentUserList = [SELECT id, IsPortalEnabled,DefaultCurrencyIsoCode, Contact.Account.ReevingReturnLocation__c,  Contact.Account.BillingCountry
                                      FROM User WHERE Id =: UserInfo.getUserId()];
        
        if(currentUserList != null && currentUserList.size() > 0){
            if(currentUserList[0].IsPortalEnabled){
                currentUser = currentUserList[0];
            }else{
                return;
            }
        }else{
            return;
        }
        for(Receiving__c receving :  receivingList){
            
            if(receving.Return_Location__c == null || receving.Return_Location__c == ''){
                receving.Return_Location__c = currentUser.Contact.Account.ReevingReturnLocation__c;
            }
            if(receving.Country__c == null || receving.Country__c == ''){
                receving.Country__c = currentUser.Contact.Account.BillingCountry;
            }
            
            if(receving.RACaseNumber__c != null && receving.RACaseNumber__c != ''){
                racases.add(receving.RACaseNumber__c);
            }else if(receving.RTV__c != null && receving.RTV__c != ''){
                rtvs.add(receving.RTV__c);
            }
            
        }
        
        //assign case on the basis of RTV
        if(rtvs != null && rtvs.size() > 0){
            
            for(Case caseRec : [select id,CurrencyIsoCode,RTV__c,CaseNumber from Case where RTV__c IN: rtvs 
                                and CurrencyIsoCode =:currentUser.DefaultCurrencyIsoCode]){
                                    caseByCaseNumberOrRTV.put(caseRec.RTV__c,caseRec.Id);
                                }
        }
        if(racases != null && racases.size() > 0){
            //explicity done two SOQL to avoid non selective query on trigger as we need IN quires with OR condtion. 
            for(Case caseRec : [select id,CurrencyIsoCode,RTV__c,CaseNumber from Case where CaseNumber IN: racases
                                and CurrencyIsoCode =:currentUser.DefaultCurrencyIsoCode]){
                                    caseByCaseNumberOrRTV.put(caseRec.CaseNumber,caseRec.Id);
                                }
        }
        if(!caseByCaseNumberOrRTV.isEmpty()){
            for(Receiving__c receving :  receivingList){ 
                
                if(receving.RACaseNumber__c != null && caseByCaseNumberOrRTV.containsKey(receving.RACaseNumber__c)){
                    receving.Case__c = caseByCaseNumberOrRTV.get(receving.RACaseNumber__c);
                }else if(receving.RTV__c != null && caseByCaseNumberOrRTV.containsKey(receving.RTV__c)){
                    receving.Case__c = caseByCaseNumberOrRTV.get(receving.RTV__c);
                }
                
            }
        }	
    }
    
    
    // to show auto scrap notification on receiving 
    public static void showAutoScrapNotification(list<Receiving__c> receivingList, map<Id,Receiving__c> triggerOldMap){
        set<Id> receivedProductIds = new set<Id>();
        map<Id,Receiving__c> productToReceivingMap = new map<Id,Receiving__c>();
        map<Id, Product2> productIdToProduct = new map<Id, Product2>();
        list<Receiving__c> receivingToUpdate = new list<Receiving__c>();
        List<All_Literal__mdt> allLiteralsList = [SELECT Value__c from All_Literal__mdt WHERE DeveloperName = 'ReceivingNotifications'];
        
        
        // iterating receivingList to create map and list 
        for(Receiving__c receivingRecord : receivingList){
            if(receivingRecord.Return_Location__c != null && receivingRecord.Return_Location__c != ''){
                if(allLiteralsList[0].Value__c.containsIgnoreCase(receivingRecord.Return_Location__c)){
                    receivedProductIds.add(receivingRecord.Received_Product__c);
                    productToReceivingMap.put(receivingRecord.Received_Product__c,receivingRecord);
                }
            }
        }
        
        // iterating product ids to create map of products 
        list<Product2> productList = [SELECT Id, AutoScrap_on_Receipt__c FROM Product2 WHERE ID IN :receivedProductIds];
        if(productList != null && productList.size() > 0){
            for(Product2 productRecord : productList){
                productIdToProduct.put(productRecord.Id, productRecord);
            }
        }
        System.debug('productIdToProduct>>' + productIdToProduct);
        // updating receiving if product is auto scrapped 
        for(Receiving__c receivingRecord : receivingList){
            if(productIdToProduct != null && productIdToProduct.size() > 0){
                if(Trigger.isInsert || (Trigger.isUpdate && receivingRecord.Received_Product__c != triggerOldMap.get(receivingRecord.Id).Received_Product__c && receivingRecord.Received_Product__c != null && productIdToProduct != null && productIdToProduct.size() > 0 && 
                                        productIdToProduct.containsKey(receivingRecord.Received_Product__c))){
                                            if(productIdToProduct.get(receivingRecord.Received_Product__c).AutoScrap_on_Receipt__c == true){
                                                receivingRecord.ShowAutoScrapNotification__c = true;
                                                receivingRecord.Received_Product_Condition__c = 'Scrap';
                                            }else{
                                                receivingRecord.ShowAutoScrapNotification__c = false;
                                                //receivingRecord.Received_Product_Condition__c = 'Pending';
                                            }
                                        }
            }
        }
    }
    
    
    public static void QCAlertFieldUpdate(List<Receiving__c> triggerNewReceivingList,map<Id,Receiving__c> triggerOldMap,Boolean isInsert){
        Set<Id> receivedProductIds = new Set<Id>(); 
        set<String> receivingRegioncurrency = new Set<String>(); 
        List<Receiving__c> receivingList = new list<Receiving__c>();
        Map<Id,list<QCLocation__c>> qcLocationsByProduct = new Map<Id,list<QCLocation__c>>();
        
        
        for(Receiving__c receivingRecord : triggerNewReceivingList){ 
            
            if(isInsert || receivingRecord.Received_Product__c != triggerOldMap.get(receivingRecord.Id).Received_Product__c){
                receivingRecord.QC_Alert__c = null;          
                receivingList.add(receivingRecord);
                if(receivingRecord.Received_Product__c != null){
                    receivedProductIds.add(receivingRecord.Received_Product__c);
                } 
                
                if(receivingRecord.currencyIsoCode != null){
                    receivingRegioncurrency.add(Utility.regionBased(receivingRecord.CurrencyIsoCode));
                }
            }
        }
        
        String query = 'SELECT Id, Product__c,QCAlert__c,Batch_Code_From__c,Batch_Code_To__c,QCAlert__r.Complaint_Code__c,Region__c,StartDate__c FROM QCLocation__c' 
            + ' WHERE IsActive__c = true' 
            + ' AND Product__c IN: receivedProductIds'
            + ' AND Region__c IN: receivingRegioncurrency'
            + ' AND QCAlert__r.Channel__c includes (\'Return Center\')'
            + ' AND StartDate__c <= TODAY ';
        
        
        //get all QC Locations where IsActive is true
        if(receivedProductIds != null && receivedProductIds.size() > 0){
            for(QCLocation__c qcLocationRecord : Database.query(query)){
                
                if(!qcLocationsByProduct.containsKey(qcLocationRecord.Product__c)){
                    qcLocationsByProduct.put(qcLocationRecord.Product__c,new list<QCLocation__c>());
                }
                qcLocationsByProduct.get(qcLocationRecord.Product__c).add(qcLocationRecord);
            }
            if(qcLocationsByProduct != null && !qcLocationsByProduct.isEmpty()){
                //updated QCAlert__c field of Receiving to true if Received product is present in activeQCLocationProductIdSet
                for(Receiving__c receivingRecord : receivingList){
                    String receivingRegion = Utility.regionBased(receivingRecord.CurrencyIsoCode);
                    if(qcLocationsByProduct.containsKey(receivingRecord.Received_Product__c)){
                        for(QCLocation__c qcLocationData : qcLocationsByProduct.get(receivingRecord.Received_Product__c)){
                            
                            if(qcLocationData.Region__c != null && qcLocationData.Region__c == receivingRegion){ 
                                receivingRecord.QC_Alert__c = qcLocationData.QCAlert__c;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void processReceiving(List<Receiving__c> receivingRecords) {
        Set<Id> receivingsToProcess = new Set<Id>();
        if (receivingRecords.size() > 0) {
            Set<Id> caseIds = new Set<Id>();
            for (Receiving__c receiving : receivingRecords) {
                if (receiving.Sent_to_AX__c == null && receiving.IsPriceCalculated__c) {
                    caseIds.add(receiving.Case__c);
                }
            }
            
            Map<Id, Case> cases = new Map<Id, Case> ([SELECT Id, CurrencyIsoCode, RecordTypeId, CreatedDate FROM Case WHERE Id IN :caseIds]);
            
            for (Receiving__c receiving : receivingRecords) {
                Case caseRecord = cases.get(receiving.Case__c);
                if (receiving.Sent_to_AX__c == null 
                    && receiving.IsPriceCalculated__c 
                    && caseRecord != null 
                    && Utility.isD365Enabled(caseRecord)) {
                        receivingsToProcess.add(receiving.Id);
                    }
            }
            
            if (!receivingsToProcess.isEmpty()) {
                System.enqueueJob(new D365APIUtility.ProcessRMA(receivingsToProcess, D365APIUtility.Action.ProcessReceiving));
            }
        }
    }
    
    //create new case for newly inserted receiving
    public static void insertCaseRecord(List<Receiving__c> receivingRecords){
        Set<String> warehouseIdsSet=new Set<String>();
        Map<String,Case> uniqueIdCaseMap = new Map<String,Case>();
        
        for(Receiving__c receivingRecord : receivingRecords){
            if(receivingRecord.isBlanketRMA__c==True && receivingRecord.Case_SF_Id__c==null && 
               (receivingRecord.Country__c=='UK' || receivingRecord.Country__c=='DE')){
                   warehouseIdsSet.add(receivingRecord.AX_Warehouse__c);
               }
        }
        // List of actual Account records that would be used to create a map
        List<Account> returnCenters = [SELECT id, Name, Warehouse_ID__c FROM Account WHERE Type='Return Center' 
                                       AND Warehouse_ID__c IN :warehouseIdsSet AND RecordType.DeveloperName = 'Business_Account'];
        
        // Map that would be used to populate return location
        Map<String, Id> returnCenterWarehouseMap = new Map<String, Id>();
        for(Account returnCenter: returnCenters){
            returnCenterWarehouseMap.put(returnCenter.Warehouse_ID__c,returnCenter.Id);
        }
        
        for(Receiving__c receiving : receivingRecords){
            if(receiving.isBlanketRMA__c==True && receiving.Case_SF_Id__c==null && 
               (receiving.Country__c=='UK' || receiving.Country__c=='DE')){
                   Case newCase=new Case();
                   newCase.AccountId=receiving.cus_sf_id__c;
                   newCase.Country__c=receiving.Country__c;
                   newCase.IsBlanketRMA__c=receiving.isBlanketRMA__c;
                   if(receiving.RTV__c==null){
                       newCase.RTV__c=receiving.Magic_RA__c;
                   }
                   else{
                       newCase.RTV__c=receiving.RTV__c;
                   }
                   newCase.RTV_Unique_ID__c=receiving.Cust_Acct_ID__c+newCase.RTV__c+receiving.Magic_RA__c;
                   newCase.Status='Open';
                   newCase.Subject=receiving.Return_Location__c+' Return';
                   newCase.Type='RMA';
                   newCase.ReturnLocation__c=returnCenterWarehouseMap.get(receiving.AX_Warehouse__c);
                   newCase.RMA_Type__c='Goods to be return (Defective return)';
                   newCase.CurrencyIsoCode=receiving.CurrencyIsoCode;
                   newCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
                   uniqueIdCaseMap.put(newCase.RTV_Unique_ID__c,newCase);
               }
        }
        if(uniqueIdCaseMap != null && !uniqueIdCaseMap.isEmpty()){
            Schema.SObjectField uniqueIDField = Case.Fields.RTV_Unique_ID__c;
            Database.upsert(uniqueIdCaseMap.values(),uniqueIDField,true);
        }
        for(Receiving__c receiving : receivingRecords){
            Case caseForReceiving=uniqueIdCaseMap.get(receiving.Cust_Acct_ID__c+receiving.RTV__c+receiving.Magic_RA__c);
            if(caseForReceiving!=null){
            	receiving.Case__c = caseForReceiving.Id;
            }
        }
    }
    
}