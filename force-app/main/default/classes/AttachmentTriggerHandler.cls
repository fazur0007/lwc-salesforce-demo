/* 
* Functionality :
* Email to case creation and checking the size of attachment if it is less than or equal to 5mb store it in S3 and create a record in knowledgebase object 
and if greater than 5mb delete it and send email notificatin to customer.
* Revision History: 
*
* Version       Author            Date            Description 
*  1.0        Payal Yadav      07/25/2016        Initial Draft 
*/
public class AttachmentTriggerHandler {
    
    public static boolean afterTriggerRun = true;
    public static boolean runOnceAfterTrigger(){
        if(afterTriggerRun){
            afterTriggerRun = false;
            return true;
        }else{
            return afterTriggerRun;
        }
    }
    
    public static boolean attachmentCloneRun = true;
    
    public static All_Literal__mdt literalMetadata{get;set;}
    
    public static void sendAttachmentsForS3(List<Attachment> newAttachments){
        List<Attachment> caseAttachmentList = new List<Attachment>();
        List<Attachment> caseAttachmentListForS3Upload = new List<Attachment>();
        List<Attachment> caseAttachmentListForError = new List<Attachment>();
        map<Id, list<Attachment>> emailMessageIdToAttachmentListMap = new Map<Id, list<Attachment>>{};
            String emailMessageObjectPrefix = EmailMessage.sObjectType.getDescribe().getKeyPrefix();
        
        for (Attachment attach : newAttachments){   
            //getting attachment parrent id from emailmessage
            if (attach.ParentId != null && String.valueOf(attach.ParentId).substring(0,3).equalsIgnoreCase(emailMessageObjectPrefix)){
                if (emailMessageIdToAttachmentListMap.containsKey(attach.ParentId)){
                    emailMessageIdToAttachmentListMap.get(attach.ParentId).add(attach);
                }else{
                    emailMessageIdToAttachmentListMap.put(attach.ParentId, new list<Attachment>{attach});
                }
            }
            
        }
        //getting EmailMessage parrent id (case)
        map<Id,Id> caseIdbyEmailMessageId = new map<Id,Id>();
        for(EmailMessage message: [Select Id, ParentId 
                                   From EmailMessage 
                                   Where Id IN: emailMessageIdToAttachmentListMap.keySet() 
                                   AND ParentId != null ]){
            if(emailMessageIdToAttachmentListMap.containsKey(message.Id) && emailMessageIdToAttachmentListMap.get(message.Id).size() > 0 ){
                caseAttachmentList.addAll(emailMessageIdToAttachmentListMap.get(message.Id));
                caseIdbyEmailMessageId.put(message.Id,message.ParentId);
            } 
        } 
        //check attachement size
        if(caseAttachmentList!=null && caseAttachmentList.size() > 0 ){
            List<All_Literal__mdt> caseAttachmentSizeCheck = [select Value__c from All_Literal__mdt where DeveloperName='Case_Attachment_Size' LIMIT 1];
            for(Attachment attachment : caseAttachmentList){
                //File Size is greater than 5 MB
                if(attachment.BodyLength >( (Integer.valueOf(caseAttachmentSizeCheck[0].Value__c)*1024 *1024))){
                    caseAttachmentListForError.add(attachment);
                }else{
                    caseAttachmentListForS3Upload.add(attachment);
                }
            }
        }
        if(!caseAttachmentListForError.isEmpty()){
            sendAttachmentLimitError(caseAttachmentListForError,caseIdbyEmailMessageId);
        }
        if(!caseAttachmentListForS3Upload.isEmpty()){
            for(Attachment attach : caseAttachmentListForS3Upload){
                if(Limits.getLimitFutureCalls() - Limits.getFutureCalls() > 0 ){
                    sendAttachemntToS3(attach.id);
                }else{
                    break;
                }
                
            }
        }
        
    }
    
    public static void sendAttachmentLimitError(list<Attachment>attachmentList,map<Id,Id> caseIdbyEmailMessageId ){   
        try{
            // obtaining case id for checking the parrent Id,set the Attachment_Limit_Error__c value true and update the records and deleting teh attachments 
            Set<Id> caseIds= new set<Id>();
            List<case> caseIdList = new List<case>();
            for (Attachment attach: attachmentList)
            {
                if(caseIdbyEmailMessageId.containsKey(attach.ParentId) && !caseIds.contains(caseIdbyEmailMessageId.get(attach.ParentId)))
                {
                    caseIds.add(caseIdbyEmailMessageId.get(attach.ParentId));
                    caseIdList.add(new Case(Id = caseIdbyEmailMessageId.get(attach.ParentId),Attachment_Limit_Error__c =true));
                }
            }
            update caseIdList;
            
            List<Attachment> attId = new List<Attachment>();
            for(Attachment attach : attachmentList)
            {
                attId.add(new Attachment(id = attach.id));
            }
            delete attId;
            //delete the list of attachments from recycle bin 
            Database.emptyRecycleBin(attId);
        }catch(DmlException e){
            ErrorLog.logErrorActivity(e,'get error message whn limit is excedded',true,'Error');
        } 
    }
    
    @future (callout=true)
    public static void sendAttachemntToS3(Id attachmentId){   
        //check status code if it is 200  check the etag, check the parent id and bind with knowlegdge base  athen insert object and del attachmnent
        List<Attachment> attachmenttoupdateS3 = [Select Id,Name,Body,ParentId,ContentType From Attachment where Id =:attachmentId];
        literalMetadata= [SELECT DeveloperName, Value__c FROM All_Literal__mdt where DeveloperName='CaseAttachments' LIMIT 1  ];           
        
        try{  
            //retieving attachment record for parrent id and body
            if(attachmenttoupdateS3 !=null && attachmenttoupdateS3.size() > 0){
                //list of storing the case id, case number to display in S3 
                List<EmailMessage> storingCaseIds= [Select Id,Parent.caseNumber,Parent.Id,Parent.CurrencyIsoCode, Parent.ParentId
                                                    From EmailMessage 
                                                    where id =:attachmenttoupdateS3[0].ParentId];
                String region = Utility.regionBased(storingCaseIds[0].Parent.CurrencyIsoCode);
                
                //upload attachment s3 using rest api
                HttpResponse res = AmazonS3Utility.saveToS3HttpCallout(AttachmenttoupdateS3[0].Body,
                                            attachmenttoupdateS3[0].ContentType,'CaseAttachments/'+storingCaseIds[0].Parent.caseNumber+'/'+attachmenttoupdateS3[0].Id,'PUT',region);
                
                //custom metadata for constant value //checking te status of response
                if (res.getStatusCode() == 200){
                    Id KBCaseAttachmentRecordTypeId = Schema.SObjectType.Knowledge_Base__c.getRecordTypeInfosByName().get('Case Atttachment').getRecordTypeId();
                    Knowledge_Base__c creatingKnowledgeBaseRecord = new Knowledge_Base__c( 
                        Region__c = region,
                        RecordtypeId = KBCaseAttachmentRecordTypeId,
                        FileType__c = attachmenttoupdateS3[0].ContentType,
                        Title__c = attachmenttoupdateS3[0].Name,
                        Etag__c = res.getHeader('ETag'),
                        FileKey__c = literalMetadata.Value__c+storingCaseIds[0].Parent.caseNumber+'/'+attachmenttoupdateS3[0].Id);
                        
                        /* if cloned email message is found, populate parent case of cloned email message on knowledge base */
                        if(storingCaseIds[0].Parent.parentId != null){
                            creatingKnowledgeBaseRecord.Case__c = storingCaseIds[0].Parent.ParentId;
                        }else{
                            creatingKnowledgeBaseRecord.Case__c = storingCaseIds[0].Parent.Id;
                        }
                        
                    insert creatingKnowledgeBaseRecord;
                    //deleted the attachment after it is inserted into S3 and created the knowledgebase record.
                    delete attachmenttoupdateS3;
                    //delete the list of attachments from recycle bin 
                    Database.emptyRecycleBin(attachmenttoupdateS3);
                }
            }
        }catch(DmlException e){
            ErrorLog.logErrorActivity(e,'get error message when atachment send to S3',true,'Error');
        } 
        
    }
    
    public static void associateAttachmentToCaseOrWorkOrder(list<Attachment> attachmentList){
                
        String multiCarrierShipmentePrefix = zkmulti__MCShipment__c.sObjectType.getDescribe().getKeyPrefix();
        String FedExShipmentePrefix = zkfedex__Shipment__c.sObjectType.getDescribe().getKeyPrefix();
        
        Map<Id, Attachment> FedExShipmentIdToAttachmentMap = new Map<Id, Attachment>();
        Map<Id, Attachment> multiCarrierShipmentIdToAttachmentMap = new Map<Id, Attachment>();
        
        Map<Id, Attachment> workOrderIdToAttachmentMap = new Map<Id, Attachment>();
        Map<Id, Attachment> caseIdToAttachmentMap = new Map<Id, Attachment>();
        
        list<Task> tasksToInsert = new list<Task>();
        
        List<All_Literal__mdt> caseAttachmentSizeCheck = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName='Case_Attachment_Size' LIMIT 1];
        
        for(Attachment attachment : attachmentList){
            if(attachment.ParentId != null 
               && String.valueOf(attachment.ParentId).startsWithIgnoreCase(FedExShipmentePrefix)){
                   if(attachment.BodyLength <( (Integer.valueOf(caseAttachmentSizeCheck[0].Value__c)*1024 *1024)) && !attachment.Name.startsWithIgnoreCase('OrderSummary')){
                        FedExShipmentIdToAttachmentMap.put(attachment.parentId, attachment);
                        attachmentCloneRun = false;
                   }
                        
                   
               }else if(attachment.ParentId != null 
                    && String.valueOf(attachment.ParentId).substring(0,3).equalsIgnoreCase(multiCarrierShipmentePrefix)){
                        if(attachment.BodyLength <( (Integer.valueOf(caseAttachmentSizeCheck[0].Value__c)*1024 *1024)) && !attachment.Name.startsWithIgnoreCase('OrderSummary') 
                        		&& !attachment.Name.startsWithIgnoreCase('Commercial')){
                            multiCarrierShipmentIdToAttachmentMap.put(attachment.parentId, attachment);
                            attachmentCloneRun = false;
                        }
                            
            }
        }
        
        list<zkfedex__Shipment__c> FedExShipmentList = [SELECT id,WorkOrder__c, WorkOrder__r.Brand__c, Case__c, Case__r.Product__c, Case__r.Product__r.Brand__c, 
                                                            zkfedex__SsProcessReturnShipment__c,
                                                            Case__r.RecordTypeId,Case__r.ContactId, Case__r.CurrencyIsoCode, Case__r.Warranty__c, 
                                                            Case__r.CaseNumber,Case__r.Service_Center__c, Case__r.Service_Center__r.Name,
                                                            Case__r.Service_Center__r.ShippingStreet, Case__r.Service_Center__r.ShippingCity, 
                                                            Case__r.Service_Center__r.ShippingState, Case__r.Service_Center__r.ShippingPostalCode, Case__r.Service_Center__r.Phone, 
                                                            Case__r.Service_Center__r.Business_Email__c, Case__r.Contact.Email, Case__r.Service_Center__r.Type,
                                                            Case__r.ReturnLocation__c, Case__r.ReturnLocation__r.Name, Case__r.ReturnLocation__r.ShippingStreet, 
                                                            Case__r.ReturnLocation__r.ShippingCity, Case__r.ReturnLocation__r.ShippingState,
                                                            Case__r.ReturnLocation__r.ShippingPostalCode, Case__r.ReturnLocation__r.Phone, 
                                                            Case__r.ReturnLocation__r.Business_Email__c, Case__r.ReturnLocation__r.Type
                                                            FROM zkfedex__Shipment__c 
                                                        WHERE id IN :FedExShipmentIdToAttachmentMap.keySet()];
        
        list<zkmulti__MCShipment__c> multiCarrierShipmentList = [SELECT Id, WorkOrder__c, WorkOrder__r.Brand__c, Case__c, Case__r.Product__c, Case__r.Product__r.Brand__c, 
                                                                    zkmulti__Return_Shipment__c, zkmulti__Carrier__c,Case__r.Shipment_Email_Sent__c,
                                                                    Case__r.RecordTypeId, Case__r.ContactId, Case__r.Service_Center__c,
                                                                    zkmulti__Label_Image_Type__c, Case__r.CurrencyIsoCode, Case__r.Warranty__c, Case__r.CaseNumber, 
                                                                    Case__r.Service_Center__r.Name, Case__r.Country__c,
                                                                    Case__r.Service_Center__r.ShippingStreet, Case__r.Service_Center__r.ShippingCity, 
                                                                    Case__r.Service_Center__r.ShippingState,Case__r.RecordType.DeveloperName,
                                                                    Case__r.Service_Center__r.ShippingPostalCode, Case__r.Service_Center__r.Phone, 
                                                                    Case__r.Service_Center__r.Business_Email__c, Case__r.Contact.Email, Case__r.Service_Center__r.Type,
                                                                    Case__r.ReturnLocation__c, Case__r.ReturnLocation__r.Name, Case__r.ReturnLocation__r.ShippingStreet, 
                                                                    Case__r.ReturnLocation__r.ShippingCity, Case__r.ReturnLocation__r.ShippingState,
                                                                    Case__r.ReturnLocation__r.ShippingPostalCode, Case__r.ReturnLocation__r.Phone, 
                                                                    Case__r.ReturnLocation__r.Business_Email__c, Case__r.ReturnLocation__r.Type
                                                                    FROM zkmulti__MCShipment__c 
                                                                WHERE id IN :multiCarrierShipmentIdToAttachmentMap.keySet()];

        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId(); 
        
        if(FedExShipmentList != null && FedExShipmentList.size() > 0){
            for(zkfedex__Shipment__c FedExShipmentRecord : FedExShipmentList){
                String brand = '';
                String returnCenterType = '';
                
                if(FedExShipmentRecord.WorkOrder__c != null){
                    if(FedExShipmentRecord.WorkOrder__r.Brand__c != null && FedExShipmentRecord.WorkOrder__r.Brand__c != ''){
                        brand = FedExShipmentRecord.WorkOrder__r.Brand__c;
                    }
                    if(FedExShipmentRecord.Case__r.Service_Center__c != null && FedExShipmentRecord.Case__r.Service_Center__r.Type != null && 
                        FedExShipmentRecord.Case__r.Service_Center__r.Type != ''){
                        returnCenterType = 'Authorized Service Center';
                    }
                }else if(FedExShipmentRecord.Case__c != null){
                    if(FedExShipmentRecord.Case__r.Product__c != null && FedExShipmentRecord.Case__r.Product__r.Brand__c != null &&
                        FedExShipmentRecord.Case__r.Product__r.Brand__c != ''){
                        brand = FedExShipmentRecord.Case__r.Product__r.Brand__c;
                    }
                    if(FedExShipmentRecord.Case__r.ReturnLocation__c != null && FedExShipmentRecord.Case__r.ReturnLocation__r.Type != null && 
                        FedExShipmentRecord.Case__r.ReturnLocation__r.Type != ''){
                        returnCenterType = 'Return Center';
                    }
                }else{
                    brand = 'Breville';
                    returnCenterType = 'Authorized Service Center';
                }
                
                if(brand == ''){
                	brand = 'Breville';
                }
                
                /*
                String returnCenterType = '';
                if(FedExShipmentRecord.Case__r.Service_Center__c != null && FedExShipmentRecord.Case__r.Service_Center__r.Type != null && 
                    FedExShipmentRecord.Case__r.Service_Center__r.Type != ''){
                    //returnCenterType = FedExShipmentRecord.Case__r.Service_Center__r.Type;
                    returnCenterType = 'Authorized Service Center';
                }else if(FedExShipmentRecord.Case__r.ReturnLocation__c != null && FedExShipmentRecord.Case__r.ReturnLocation__r.Type != null && 
                    FedExShipmentRecord.Case__r.ReturnLocation__r.Type != ''){
                    //returnCenterType = FedExShipmentRecord.Case__r.ReturnLocation__r.Type;
                    returnCenterType = 'Return Center';
                }
                */
                if(FedExShipmentRecord.zkfedex__SsProcessReturnShipment__c && FedExShipmentRecord.Case__c != null && FedExShipmentRecord.Case__r.ContactId != null){
                    String labelType = 'Image';
                    
                    if(FedExShipmentRecord.Case__r.ReturnLocation__c != null){
                        tasksToInsert.add(createTask(FedExShipmentRecord.Case__c, FedExShipmentRecord.Case__r.ContactId, 
                                                        FedExShipmentIdToAttachmentMap.get(FedExShipmentRecord.Id).Id, labelType, FedExShipmentRecord.Case__r.CurrencyIsoCode, 
                                                        FedExShipmentRecord.Case__r.Warranty__c, FedExShipmentRecord.Case__r.CaseNumber,
                                                        FedExShipmentRecord.Case__r.ReturnLocation__r.Name, FedExShipmentRecord.Case__r.ReturnLocation__r.ShippingStreet,
                                                        FedExShipmentRecord.Case__r.ReturnLocation__r.ShippingCity, FedExShipmentRecord.Case__r.ReturnLocation__r.ShippingState, 
                                                        FedExShipmentRecord.Case__r.ReturnLocation__r.ShippingPostalCode, FedExShipmentRecord.Case__r.ReturnLocation__r.Phone, 
                                                        FedExShipmentRecord.Case__r.ReturnLocation__r.Business_Email__c, 
                                                        FedExShipmentRecord.Case__r.Contact.Email, brand, returnCenterType, 'FedEx'
                        ));
                    }else{
                        tasksToInsert.add(createTask(FedExShipmentRecord.Case__c, FedExShipmentRecord.Case__r.ContactId, 
                                                    FedExShipmentIdToAttachmentMap.get(FedExShipmentRecord.Id).Id, labelType, FedExShipmentRecord.Case__r.CurrencyIsoCode, 
                                                    FedExShipmentRecord.Case__r.Warranty__c, FedExShipmentRecord.Case__r.CaseNumber,
                                                    FedExShipmentRecord.Case__r.Service_Center__r.Name, FedExShipmentRecord.Case__r.Service_Center__r.ShippingStreet,
                                                    FedExShipmentRecord.Case__r.Service_Center__r.ShippingCity, FedExShipmentRecord.Case__r.Service_Center__r.ShippingState, 
                                                    FedExShipmentRecord.Case__r.Service_Center__r.ShippingPostalCode, FedExShipmentRecord.Case__r.Service_Center__r.Phone, 
                                                    FedExShipmentRecord.Case__r.Service_Center__r.Business_Email__c, 
                                                    FedExShipmentRecord.Case__r.Contact.Email, brand, returnCenterType, 'FedEx'
                                                    ));
                    }                               
                }
                if(FedExShipmentRecord.WorkOrder__c != null && !FedExShipmentRecord.zkfedex__SsProcessReturnShipment__c){
                    workOrderIdToAttachmentMap.put(FedExShipmentRecord.WorkOrder__c, FedExShipmentIdToAttachmentMap.get(FedExShipmentRecord.Id));
                }else if(FedExShipmentRecord.Case__c != null && FedExShipmentRecord.Case__r.RecordTypeId == caseRmaRecordTypeId 
                         && FedExShipmentRecord.zkfedex__SsProcessReturnShipment__c){
                    caseIdToAttachmentMap.put(FedExShipmentRecord.Case__c, FedExShipmentIdToAttachmentMap.get(FedExShipmentRecord.Id));
                }               
            }
        }
        
        if(multiCarrierShipmentList != null && multiCarrierShipmentList.size() > 0){
            for(zkmulti__MCShipment__c multiCarrierShipmentRecord : multiCarrierShipmentList){
                String brand='';
                String returnCenterType = '';
                if(multiCarrierShipmentRecord.WorkOrder__c != null){
                    if(multiCarrierShipmentRecord.WorkOrder__r.Brand__c != null && multiCarrierShipmentRecord.WorkOrder__r.Brand__c != ''){
                        brand = multiCarrierShipmentRecord.WorkOrder__r.Brand__c;
                    }
                    if(multiCarrierShipmentRecord.Case__r.Service_Center__c != null && multiCarrierShipmentRecord.Case__r.Service_Center__r.Type != null && 
                        multiCarrierShipmentRecord.Case__r.Service_Center__r.Type != ''){
                        returnCenterType = 'Authorized Service Center';
                    }   
                }else if(multiCarrierShipmentRecord.Case__c != null){
                    if(multiCarrierShipmentRecord.Case__r.Product__c != null && 
                        multiCarrierShipmentRecord.Case__r.Product__r.Brand__c != null && multiCarrierShipmentRecord.Case__r.Product__r.Brand__c != ''){
                        brand = multiCarrierShipmentRecord.Case__r.Product__r.Brand__c;
                    }
                    if(multiCarrierShipmentRecord.Case__r.ReturnLocation__c != null && multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Type != null && 
                        multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Type != ''){
                        returnCenterType = 'Return Center';
                    }
                    if(multiCarrierShipmentRecord.Case__r.Country__c == 'DE' 
                    	|| multiCarrierShipmentRecord.Case__r.Country__c == 'CH' 
                    	||multiCarrierShipmentRecord.Case__r.Country__c == 'UK') {
                    	brand = 'Sage';
                    }
                }else{
                    brand = 'Breville';
                    returnCenterType = 'Authorized Service Center';
                }
                
                if(brand == ''){
                	brand = 'Breville';
                }
                /*
                if(multiCarrierShipmentRecord.Case__r.Service_Center__c != null && multiCarrierShipmentRecord.Case__r.Service_Center__r.Type != null && 
                    multiCarrierShipmentRecord.Case__r.Service_Center__r.Type != ''){
                    //returnCenterType = multiCarrierShipmentRecord.Case__r.Service_Center__r.Type;
                    returnCenterType = 'Authorized Service Center';
                }else if(multiCarrierShipmentRecord.Case__r.ReturnLocation__c != null && multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Type != null && 
                    multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Type != ''){
                    //returnCenterType = multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Type;
                    returnCenterType = 'Return Center';
                }
                */
                /*Code to poulate the attachment Id on Case record, to trigger the labels to consumers via email using email alert*/
                if(multiCarrierShipmentRecord.zkmulti__Return_Shipment__c && multiCarrierShipmentRecord.Case__c != null && multiCarrierShipmentRecord.Case__r.ContactId != null 
                   && multiCarrierShipmentRecord.Case__r.Shipment_Email_Sent__c==false){
                    String labelType = 'Image';
                    if((multiCarrierShipmentRecord.zkmulti__Label_Image_Type__c != null && multiCarrierShipmentRecord.zkmulti__Label_Image_Type__c.containsIgnoreCase('PDF')) || 
                    (multiCarrierShipmentIdToAttachmentMap.containsKey(multiCarrierShipmentRecord.Id)
                            && multiCarrierShipmentIdToAttachmentMap.get(multiCarrierShipmentRecord.Id).Name.containsIgnoreCase('PDF'))){
                        labelType = 'PDF';
                    }
                    if(multiCarrierShipmentRecord.Case__r.ReturnLocation__r != null){
                        tasksToInsert.add(createTask(multiCarrierShipmentRecord.Case__c, multiCarrierShipmentRecord.Case__r.ContactId, 
                                                multiCarrierShipmentIdToAttachmentMap.get(multiCarrierShipmentRecord.Id).Id, labelType,
                                                multiCarrierShipmentRecord.Case__r.CurrencyIsoCode, multiCarrierShipmentRecord.Case__r.Warranty__c,
                                                multiCarrierShipmentRecord.Case__r.CaseNumber,
                                                multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Name, multiCarrierShipmentRecord.Case__r.ReturnLocation__r.ShippingStreet,
                                                multiCarrierShipmentRecord.Case__r.ReturnLocation__r.ShippingCity, multiCarrierShipmentRecord.Case__r.ReturnLocation__r.ShippingState, 
                                                multiCarrierShipmentRecord.Case__r.ReturnLocation__r.ShippingPostalCode, multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Phone, 
                                                multiCarrierShipmentRecord.Case__r.ReturnLocation__r.Business_Email__c, multiCarrierShipmentRecord.Case__r.Contact.Email,
                                                brand, returnCenterType, multiCarrierShipmentRecord.zkmulti__Carrier__c
                                                ));
                    }else{
                        tasksToInsert.add(createTask(multiCarrierShipmentRecord.Case__c, multiCarrierShipmentRecord.Case__r.ContactId, 
                                                multiCarrierShipmentIdToAttachmentMap.get(multiCarrierShipmentRecord.Id).Id, labelType,
                                                multiCarrierShipmentRecord.Case__r.CurrencyIsoCode, multiCarrierShipmentRecord.Case__r.Warranty__c,
                                                multiCarrierShipmentRecord.Case__r.CaseNumber,
                                                multiCarrierShipmentRecord.Case__r.Service_Center__r.Name, multiCarrierShipmentRecord.Case__r.Service_Center__r.ShippingStreet,
                                                multiCarrierShipmentRecord.Case__r.Service_Center__r.ShippingCity, multiCarrierShipmentRecord.Case__r.Service_Center__r.ShippingState, 
                                                multiCarrierShipmentRecord.Case__r.Service_Center__r.ShippingPostalCode, multiCarrierShipmentRecord.Case__r.Service_Center__r.Phone, 
                                                multiCarrierShipmentRecord.Case__r.Service_Center__r.Business_Email__c, multiCarrierShipmentRecord.Case__r.Contact.Email,
                                                brand, returnCenterType, multiCarrierShipmentRecord.zkmulti__Carrier__c
                                                ));
                    }                           
                }
                
                if(multiCarrierShipmentRecord.WorkOrder__c != null && !multiCarrierShipmentRecord.zkmulti__Return_Shipment__c){
                    workOrderIdToAttachmentMap.put(multiCarrierShipmentRecord.WorkOrder__c, multiCarrierShipmentIdToAttachmentMap.get(multiCarrierShipmentRecord.Id));
                }else if(multiCarrierShipmentRecord.Case__c != null && multiCarrierShipmentRecord.Case__r.RecordTypeId == caseRmaRecordTypeId 
                         && multiCarrierShipmentRecord.zkmulti__Return_Shipment__c == true){
                    caseIdToAttachmentMap.put(multiCarrierShipmentRecord.Case__c, multiCarrierShipmentIdToAttachmentMap.get(multiCarrierShipmentRecord.Id));
                }
            }
        }
        
        Set<Id> workOrderSet  = workOrderIdToAttachmentMap.keySet();
        Set<Id> caseSet = caseIdToAttachmentMap.keySet();
        
        list<Attachment> clonedAttachmentList = new list<Attachment>();
        
        if(workOrderSet != null && workOrderSet.size() > 0){
            for(Id workOrderRecordId : workOrderSet){
                Attachment clonedAttachment = Utility.cloneAttachmentFromWorkOrder(workOrderIdToAttachmentMap, workOrderRecordId);
                clonedAttachment.parentId = workOrderRecordId;
                clonedAttachmentList.add(clonedAttachment);
            }
        }       
        System.debug('caseSet :::::' + caseSet);
        if(caseSet != null && caseSet.size() > 0){
            for(Id caseRecordId : caseSet){
                Attachment clonedAttachment = Utility.cloneAttachmentFromCase(caseIdToAttachmentMap, caseRecordId);
                clonedAttachment.parentId = caseRecordId;
                clonedAttachmentList.add(clonedAttachment);
            }
        }
        try{
            Database.insert(clonedAttachmentList, false);
            if(tasksToInsert != null && tasksToInsert.size() > 0){
                System.enqueueJob(new CreateTaskForSendingShippingLabels(tasksToInsert));
                //insert tasksToInsert;
            }
        }catch(DMLException e){
            ErrorLog.logErrorActivity(e,'problem in inserting an attachment',true,'Error');
        }
    }
    
    public static Task createTask(Id whatId, Id whoId, Id attachmentId, String labelType, String currencyIsoCode, String warranty, String caseNumber, String name, String street, 
                                    String city, String state, String postalCode, String phone, String email, String contactEmail, String brand, String returnCenterType,
                                    String carrierName){
        Task taskRec = new Task();
        taskRec.ActivityDate = Date.today();
        taskRec.Description = labelType +' - Shipment Label Sent';
        
        if(contactEmail != null && contactEmail != ''){
            taskRec.Subject = 'Shipping Label Sent';
        }else{
            taskRec.Subject = 'Shipping Label Failed';
        }   
            
        taskRec.WhatId = whatId;
        taskRec.WhoId = whoId;
        taskRec.ShipmentLabelAttachmentId__c = attachmentId;
        taskRec.Status = 'Completed';
        taskRec.CurrencyIsoCode = currencyIsoCode;
        taskRec.CaseNumber__c = caseNumber;
        taskRec.ServiceCenterName__c = name;
        taskRec.ServiceCenterStreet__c = street;
        taskRec.ServiceCenterCity__c = city;
        taskRec.ServiceCenterState__c = state;
        taskRec.ServiceCenterPostalCode__c = postalCode;
        taskRec.ServiceCenterPhone__c = phone;
        taskRec.ServiceCenterEmail__c = email;
        taskRec.Warranty__c = warranty;
        taskRec.Brand__c = brand;
        taskRec.CarrierName__c = carrierName;
        
        if(returnCenterType != null && returnCenterType != ''){
            taskRec.ReturnCenterType__c = returnCenterType;
        }
        return taskRec;    
    }
}