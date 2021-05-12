public class CreateTaskForSendingShippingLabels implements Queueable{
    
    Public list<Task> taskList;
    
    public CreateTaskForSendingShippingLabels(list<Task> taskList){
        system.debug('++++++ IN CreateTaskForSendingShippingLabels');
        this.taskList = taskList;
    }
    
    public void execute(QueueableContext context){
        list<Task> sendEmailTasks = new list<Task>();
        Set<Id> attachmentIdSet = new Set<Id>(); 
        //Code to identify the org wide email address
        Set<String> brandSet = new Set<String>();
        Set<String> currencySet = new Set<String>();
        Map<Id,String> taskIdToCaseIdMap=new Map<Id,String>();
        List<Case> caseRecordsToUpdate=new List<Case>();
        
        System.debug('### before insert');
        insert taskList;
        System.debug('### after insert');
        
        for(Task task : taskList){
        	System.debug('### task.Id' +task.Id);
            System.debug('### inside task for loop');
            System.debug('### task.ShipmentLabelAttachmentId__c' +task.ShipmentLabelAttachmentId__c);
            System.debug('### task.WhoId' +task.WhoId);
            System.debug('### task.Description' +task.Description);
            System.debug('### task.Brand__c' +task.Brand__c);
            
            taskIdToCaseIdMap.put(task.Id,task.WhatId);

            //if(task.ShipmentLabelAttachmentId__c != null && task.WhoId != null && task.Description != null && task.Description.containsIgnoreCase('PDF')){
            //removed PDF condition as all the shipping label should be sent via Apex code. Disabled Shipping Label Generation Process Builder due to blank attachment issue 
            if(task.ShipmentLabelAttachmentId__c != null && task.WhoId != null && task.Description != null){
                System.debug('### 1');
                attachmentIdSet.add(task.ShipmentLabelAttachmentId__c);
                sendEmailTasks.add(task);
                brandSet.add(task.Brand__c);
                currencySet.add(task.CurrencyIsoCode);
            }
        }
        System.debug('taskIdToCaseIdMap ::::: '+ taskIdToCaseIdMap);
        if(attachmentIdSet != null && attachmentIdSet.size() > 0 && sendEmailTasks != null && sendEmailTasks.size() > 0){
            
            System.debug('### 2');
            Map<String, SendPDFReturnLabels__mdt> currencyBrandtoOrgWideIdMap = new Map<String, SendPDFReturnLabels__mdt>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            System.debug('brandSet ::::: '+ brandSet);
            System.debug('currencySet ::::: '+ currencySet);
            for(SendPDFReturnLabels__mdt sendPDFMetadata : [SELECT DeveloperName, Brand__c, WarrantyStatus__c, CurrencyISOCode__c, 
                                                                OrgWideEmailAddressId__c, TemplateId__c, Carrier_Type__c
                                                                FROM SendPDFReturnLabels__mdt 
                                                                WHERE Brand__c IN: brandSet AND CurrencyISOCode__c IN: currencySet]){
                
                System.debug('### 3');
                String keyFromMetadata = sendPDFMetadata.CurrencyISOCode__c + sendPDFMetadata.Brand__c + sendPDFMetadata.WarrantyStatus__c;
                if (sendPDFMetadata.Carrier_Type__c!= null) {
                    keyFromMetadata = keyFromMetadata + sendPDFMetadata.Carrier_Type__c;
                }
                keyFromMetadata = keyFromMetadata.tolowercase();
                System.debug('### keyFromMetadata: ' + keyFromMetadata);                                              
                currencyBrandtoOrgWideIdMap.put(keyFromMetadata, sendPDFMetadata);
                System.debug('currencyBrandtoOrgWideIdMap ::::: '+ currencyBrandtoOrgWideIdMap);
            }
            /*
            All_Literal__mdt literalMetadata= [SELECT DeveloperName, Value__c FROM All_Literal__mdt where DeveloperName='ShippingLabelGeneratedEmailAddress' LIMIT 1  ];
            
            if(literalMetadata.value__c != null){
                list<OrgWideEmailAddress>  emailAddressList = [select id, Address from OrgWideEmailAddress where Address =: literalMetadata.value__c];
               
                if(emailAddressList != null && emailAddressList.size() > 0 ){
                    orgWideEmailId = emailAddressList[0].id;
                }
            }
            
            Id templateId = Id.valueOf([SELECT Id, Value__c 
                                FROM All_Literal__mdt 
                                WHERE Category__c = 'Email Template Id' 
                                AND DeveloperName = 'Return_Label_Generated_Email_TemplateId' 
                                LIMIT 1].Value__c);
            */
            Map<Id, Attachment> attachmentIdToAttachmentMap = new Map<Id, Attachment>([SELECT Id, Body, ContentType FROM Attachment WHERE Id IN: attachmentIdSet]);
            Map<Id,Case> caseIdToRecordMap = new Map<Id,Case>();
            if (taskIdToCaseIdMap != null){
                caseIdToRecordMap = new Map<Id,Case>([select id,Shipment_Email_Sent__c, RecordType.DeveloperName from Case where Id IN :taskIdToCaseIdMap.values()]);
            }
            System.debug('caseIdToRecordMap ::::: '+ caseIdToRecordMap);
            for(Task task : taskList){
                System.debug('### 4');
                String warrantyStatus = task.Warranty__c;
                
                //USDBrevilleOut of Warranty
                //Only for AUS region
                String brand = task.Brand__c;
                if(task.Warranty__c == null || task.Warranty__c == ''){
                    System.debug('### 5');
                    warrantyStatus = 'Out of Warranty';
                }
                
                if(task.CurrencyIsoCode == 'NZD'){
                    System.debug('### 6');
                    //Only for NZ region
                    warrantyStatus = 'Out of Warranty';
                    if(brand != 'Kambrook'){
                        System.debug('### 7');
                        brand = 'Breville';
                    }
                }else if(task.CurrencyIsoCode == 'EUR'){
                    brand = 'Sage';
                    warrantyStatus = 'Out of Warranty';
                }else if(task.CurrencyIsoCode != 'AUD'){
                    System.debug('### 8');
                    
                    //Onlu for USA, CAN & UK region
                    warrantyStatus = 'Out of Warranty';
                    if(brand == null || brand == ''){
                        brand = 'Breville';
                    }
                    
                }
                
                String key = task.CurrencyIsoCode + brand + warrantyStatus;
                if(task.CurrencyIsoCode== 'USD' && task.CarrierName__c == 'UPS') {
                    key = key + task.CarrierName__c;
                }
                key = key.tolowercase();
                System.debug('### key : ' +key);
                System.debug('currencyBrandtoOrgWideIdMap.get(key) ::::: '+ currencyBrandtoOrgWideIdMap.get(key));
                Id templateId = currencyBrandtoOrgWideIdMap.get(key).TemplateId__c;
                Id orgWideEmailId = currencyBrandtoOrgWideIdMap.get(key).OrgWideEmailAddressId__c;
                Case caseRecord= new Case();
                if(caseIdToRecordMap.size() > 0 ) {
                    caseRecord = caseIdToRecordMap.get(taskIdToCaseIdMap.get(task.Id));
                }
                System.debug('caseRecord ::::: '+ caseRecord);
                if(attachmentIdToAttachmentMap.containsKey(task.ShipmentLabelAttachmentId__c) && caseRecord!= null && caseRecord.Shipment_Email_Sent__c==false ){
                    System.debug('### 9');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(task.WhoId);
                    mail.setSaveAsActivity(false);
                    mail.setTemplateID(templateId);
                    mail.setWhatId(task.Id);
                    if(orgWideEmailId != null){
                        System.debug('### 10');
                        mail.setorgWideEmailAddressId(orgWideEmailId);
                    }
                    
                    //Attachment
                    Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
                    if(task.Description.containsIgnoreCase('PDF')){
                        System.debug('### 11');
                        //Only for AUS
                        emailFileAttachment.setFileName('AuthorizeReturn.pdf');
                        emailFileAttachment.setContentType(attachmentIdToAttachmentMap.get(task.ShipmentLabelAttachmentId__c).ContentType);
                    }else{
                        System.debug('### 12');
                        //For other regions
                        emailFileAttachment.setFileName('AuthorizeReturn.png');
                        emailFileAttachment.setContentType('image/png');
                    }
                    
                    emailFileAttachment.setBody(attachmentIdToAttachmentMap.get(task.ShipmentLabelAttachmentId__c).Body);
                    //emailFileAttachment.setInline(false);
                    //Adding attachment in email
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {emailFileAttachment});
                    if(caseRecord!= null && caseRecord.Id == taskIdToCaseIdMap.get(mail.getWhatId())){
                    	caseRecordsToUpdate.add(caseRecord);
                    }
                    mails.add(mail);
                }
            }
            System.debug('caseRecordsToUpdate ::::: '+ caseRecordsToUpdate);
            for(Case caseToUpdate : caseRecordsToUpdate){
                System.debug('caseToUpdate.RecordType.DeveloperName ::::: '+ caseToUpdate.RecordType.DeveloperName);
                if(caseToUpdate.RecordType.DeveloperName != 'RMA'){
                    caseToUpdate.Shipment_Email_Sent__c=true;
                }
            }
            Database.update(caseRecordsToUpdate);
            //Sends the email
            if(mails != null && mails.size() > 0){
                System.debug('### 13');
                if(!Test.isRunningTest()){
                    System.debug('### 14');
                    Messaging.sendEmail(mails);
                }   
            }
        }
    }
}