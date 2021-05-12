/*
* Functionality :
* Trigger handler for QC Alert sent out to service repairer community users
* Added Manual sharing code for QC Location
* Revision History: 
*
* Version       Author            Date            Description 
*  1.0        Payal Yadav      08/10/2016        Initial Draft 
*/

public with sharing class QCLocationTriggerHandler{ 
    
    public static void sendNotificationToServiceCentre(List<QCLocation__c> triggerNew,map<id,QCLocation__c> triggerOldMap){   
        list<QCLocation__c> qcLocations = new list<QCLocation__c>();
        set<String> qcLocationForEmail = new set<String>();
        for(QCLocation__c qcLocationDetails : triggerNew){
            if((trigger.isInsert &&  qcLocationDetails.IsActive__c) || (trigger.isUpdate && qcLocationDetails.IsActive__c 
                                                                        && !triggerOldMap.get(qcLocationDetails.id).IsActive__c )){
                                                                            qcLocationForEmail.add(qcLocationDetails.id); 
            }
        }
        qcLocations = [select Product__r.Name,ReturnLocation__r.Name,Region__c,
                       QCAlert__r.QCAlertDetails__c,QCAlert__r.Channel__c,
                       ReturnLocation__r.BillingStreet, ReturnLocation__r.BillingState,
                       ReturnLocation__r.BillingPostalCode, ReturnLocation__r.BillingCountry, ReturnLocation__r.BillingCity 
                       from  QCLocation__c 
                       where id IN :qcLocationForEmail
                       and QCAlert__r.Channel__c includes ('ASC','Partner')]; 
        
        set<String> currencyCodeSet = new set<String>();
        for(QCLocation__c qcLocationDetails : qcLocations){ 
            currencyCodeSet.add(Utility.currencyBasedRegions(qcLocationDetails.Region__c));
        }
       
        if(currencyCodeSet != null && !currencyCodeSet.isempty()){
            map<String,List<User>> userListByCurrencyCode = new map<String,List<User>>();
            // updated the condition below to not send email to MyBreville customers
            for(User u: [Select Id, Contact.Account.CurrencyIsoCode,Name, Contact.Account.Type from User 
                         where Contact.Account.CurrencyIsoCode IN:currencyCodeSet 
                         AND Contact.AccountId != null
                         AND Contact.Account.CurrencyIsoCode != null
                         AND IsPortalEnabled=true 
                         AND isActive=true
                         AND Profile.Name NOT IN ('Breville External Identity', 'Specialty Roaster Community')]){
                                                        
                if(!userListByCurrencyCode.containsKey(u.Contact.Account.CurrencyIsoCode)){
                    userListByCurrencyCode.put(u.Contact.Account.CurrencyIsoCode,new list<User>());
                 }
                    userListByCurrencyCode.get(u.Contact.Account.CurrencyIsoCode).add(u);                   
            }
            if(userListByCurrencyCode != null && !userListByCurrencyCode.isEmpty()){
                All_Literal__mdt literalMetadata= [SELECT DeveloperName, Value__c FROM All_Literal__mdt where DeveloperName='QCLocationAlertEmailId' LIMIT 1  ];                                        
                sendTemplateEmail(userListByCurrencyCode,qcLocations,'QC_Alert',literalMetadata.value__c);
            }
        }
    }
    public static void sendTemplateEmail(map<String,List<User>> userListByCurrencyCode,list<QCLocation__c> qcLocations, String templateApiName, 
                                         String orgwideIdByEmailAddress ) {
        Id orgWideEmailId;
        Messaging.SingleEmailMessage[] singleEmailMessages = new list<Messaging.SingleEmailMessage>();
        if(orgwideIdByEmailAddress != null){ 
            list<OrgWideEmailAddress>  emailAddressList = [select id, Address from OrgWideEmailAddress 
                                                            where Address =: orgwideIdByEmailAddress];
           
            if(emailAddressList != null && emailAddressList.size() > 0 ){
                orgWideEmailId = emailAddressList[0].id;
            }
        }
        EmailTemplate template;
        list<EmailTemplate> templates =  [select id, Subject, HtmlValue from EmailTemplate 
                                            where developername = : templateApiName limit 1];
        if(templates != null && templates.size() > 0){
             template = templates[0]; 
        }else{
             throw new BrevilleCustomException(Label.QC_Alert_Template_Error);
        }
        for(QCLocation__c qcLocation : qcLocations){
     
            String subject = template.Subject.replace('#Product Name#', qcLocation.Product__r.Name);
            String htmlBody = template.HtmlValue;
         
            htmlBody = htmlBody.replace('#Product Name#', qcLocation.Product__r.Name != null ? qcLocation.Product__r.Name : '');
            htmlBody = htmlBody.replace('#QC Location Details#',qcLocation.QCAlert__r.QCAlertDetails__c != null ? qcLocation.QCAlert__r.QCAlertDetails__c : '');
            htmlBody = htmlBody.replace('#QC Return Location Name#', qcLocation.ReturnLocation__r.Name != null ? qcLocation.ReturnLocation__r.Name : '');
            String address = addressAsString(qcLocation); 
            htmlBody = htmlBody.replace('#QC Return Location Address#', address != null ? address : '' );
            htmlBody = htmlBody.replace('{!Organization.Name}', UserInfo.getOrganizationName());
            String currencyCode = Utility.currencyBasedRegions(qcLocation.Region__c);
            String htmlBodyBeforeReplacingUserName = htmlBody;
            for(User user : userListByCurrencyCode.get(currencyCode)){
                if(qcLocation.QCAlert__r.Channel__c == Label.QC_Alert_Channel && user.Contact.Account.Type != Label.QCAlert_Multiple_Channel){
                    continue;
                }
                 
                 htmlBody = htmlBodyBeforeReplacingUserName;
                 htmlBody = htmlBody.replace('{!User.Name}',user.Name);
                 Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                 email.setTargetObjectId(user.id);
                 
                 if(orgWideEmailId != null){
                     email.setorgWideEmailAddressId(orgWideEmailId);
                 }
                 email.setHtmlBody(htmlBody);
                 email.setSubject(subject);
                 email.setSaveAsActivity(false);
                 singleEmailMessages.add(email);
            }
        }
        Messaging.sendemailResult[] emailResult = Messaging.sendEmail(singleEmailMessages);
    }
         
    public static String addressAsString (QCLocation__c qcLocation) {
        
        String addrStr = '';
        addrStr += (qcLocation.ReturnLocation__r.BillingStreet != null ? qcLocation.ReturnLocation__r.BillingStreet : '')
            +'\n'+(qcLocation.ReturnLocation__r.BillingCity != null ? qcLocation.ReturnLocation__r.BillingCity : '')
            +','+(qcLocation.ReturnLocation__r.BillingState != null ? qcLocation.ReturnLocation__r.BillingState : '')
            +','+(qcLocation.ReturnLocation__r.BillingPostalCode != null ? qcLocation.ReturnLocation__r.BillingPostalCode : '')
            +'\n'+(qcLocation.ReturnLocation__r.BillingCountry != null ? qcLocation.ReturnLocation__r.BillingCountry : '')+'\n';
        return addrStr;
    }  
    
    /* ----------------------Start-----------------------------------
            shareWithreturnLocationForQcLocation sharing method for qclocation */
    public static void shareWithreturnLocationForQcLocation(list<QCLocation__c> newqclocation,map<Id,QCLocation__c> oldmap,Boolean isInsert){
        
        list<QCLocation__c> qcLocationneedtoShare = new list<QCLocation__c>();
        List<Id> shareIdsToDelete = new List<Id>();
        set<Id> returnLocationAccountIds = new set<Id>();
        for(QCLocation__c qclocationRecords : newqclocation){
            
            if(isInsert && qclocationRecords.returnLocation__c != NULL){
                qcLocationneedtoShare.add(qclocationRecords);
                returnLocationAccountIds.add(qclocationRecords.ReturnLocation__c);
                
            }else if(oldmap != null && ((oldmap.get(qclocationRecords.id).ReturnLocation__c != qclocationRecords.ReturnLocation__c) || (oldmap.get(qclocationRecords.id).OwnerId != qclocationRecords.OwnerId))){
               //add to delete list to delete share records
                shareIdsToDelete.add(qclocationRecords.id);
                if(qclocationRecords.ReturnLocation__c != NULL){
                    qcLocationneedtoShare.add(qclocationRecords);
                    returnLocationAccountIds.add(qclocationRecords.ReturnLocation__c);
                }
            }
        }
        
        if(!shareIdsToDelete.isEmpty()){
            delete [SELECT Id FROM QCLocation__Share 
                    WHERE ParentId IN :shareIdsToDelete 
                    AND RowCause = 'Manual'];
        }
        if(!qcLocationneedtoShare.isEmpty()){
            List<QCLocation__Share> sharesToCreate = new List<QCLocation__Share>();
            map<Id, Set<Id>> partnerUserIdByAccountId = Utility.getPartnerUserIdByAccountId(returnLocationAccountIds);
            for(QCLocation__c qclocationRecordstoShare : qcLocationneedtoShare){
                if(partnerUserIdByAccountId.containsKey(qclocationRecordstoShare.ReturnLocation__c)){
                    for(Id userId : partnerUserIdByAccountId.get(qclocationRecordstoShare.ReturnLocation__c)){
                        sharesToCreate.add(createQcLocationShare(qclocationRecordstoShare.Id, userId));
                    }
                }
            }
            Database.insert(sharesToCreate,false);
        }
    }
    public static void populateQCAlertReturnLocationCompositeKey(list<QCLocation__c> newqclocation){
        
        
        for(QCLocation__c qcLoc : newqclocation){
            qcLoc.QCAlertReturnLocationCompositeKey__c =   qcLoc.QCAlert__c +''+ qcLoc.ReturnLocation__c;
        }
        
    }
    
    /** Method name : createQcLocationShare
    * Arguments : Id caseId - Record id of the case record which needs to be shared
    * Id userOrGroupId - Record id of user or public group with which the case record needs to be shared
    * String caseAccessLevel - Record sharing access level - Read, Edit, All
    * Return type : QcLocationShare
    * Description : Creates QcLocation share record as per the parameters passed to the method
    **/
    public static QCLocation__Share createQcLocationShare(Id QcLocationId, Id userOrGroupId){
        QCLocation__Share share = new QCLocation__Share();
        share.ParentId = QcLocationId;
        share.UserOrGroupId = userOrGroupId;                                              
        share.AccessLevel = 'Edit';
        share.RowCause = 'Manual';
        return share;
    }
   
}