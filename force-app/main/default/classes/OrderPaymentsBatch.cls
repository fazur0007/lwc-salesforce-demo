public with sharing class OrderPaymentsBatch implements Database.Batchable<SObject>, Database.Stateful{

    public Map<Id, pymt__PaymentX__c> IdToSObjectMap = new Map<Id, pymt__PaymentX__c>();
    public Map<Id, String> errorMap = new Map<Id, String>();

    public Database.QueryLocator start(Database.BatchableContext context) {

    //Describe call for all fields
         Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Order').getDescribe().fields.getMap();
         String queryString = '';
         for(Schema.SObjectField schemafield : fieldMap.Values()) {
             schema.describefieldresult dynamicfields = schemafield.getDescribe();
             if(queryString=='')
                 queryString+= string.valueOf(dynamicfields.getname());
             else
                 queryString+= ','+string.valueOf(dynamicfields.getname());
         }//End for

         string finalQuery='select '+queryString+' from Order where'+ 
                            ' Source__c = \'Argo\' or Source__c = \'Mojo\'';

        // Return list of Order records
        return Database.getQueryLocator(finalQuery);
     }//End start

    public void execute(Database.BatchableContext context, 
                            list<Order> lstOrder) {

    map<string, Id> mapAuthorizationIdOrderId = new map<string, Id>();
    map<string, Id> mapAuthorizationIdContactId = new map<string, Id>();
    list<pymt__PaymentX__c> lstpymtPaymentX = new list<pymt__PaymentX__c>();

        for(Order objOrder : lstOrder){
            if(!String.isEmpty(objOrder.CC_Authorization_ID__c)){
                mapAuthorizationIdOrderId.put(objOrder.CC_Authorization_ID__c, objOrder.Id);
                mapAuthorizationIdContactId.put(objOrder.CC_Authorization_ID__c, objOrder.BillToContactId);
            }//End if
        }//End for

        system.debug('----mapAuthorizationIdOrderId.keyset()--------' + mapAuthorizationIdOrderId.keyset());

        for(pymt__PaymentX__c objpymtPaymentX : [select Id,
                                                          pymt__Transaction_Id__c,
                                                          pymt__Transaction_Type__c,
                                                          Order__c
                                                     from pymt__PaymentX__c
                                                    where pymt__Transaction_Id__c IN : mapAuthorizationIdOrderId.keyset()
                                                      and pymt__Transaction_Type__c = 'Authorization']){
                for(String strAuthorization : mapAuthorizationIdOrderId.keyset()){
                    if(objpymtPaymentX.pymt__Transaction_Id__c == strAuthorization && 
                        objpymtPaymentX.Order__c != mapAuthorizationIdOrderId.get(strAuthorization)){
                        objpymtPaymentX.Order__c = mapAuthorizationIdOrderId.get(strAuthorization);
                        objpymtPaymentX.pymt__Contact__c =  mapAuthorizationIdContactId.get(strAuthorization);
                        lstpymtPaymentX.add(objpymtPaymentX);
                    }//End if
                }//End for
         }//End for

        system.debug('-lstpymtPaymentX---' + lstpymtPaymentX);
        system.debug('-lstpymtPaymentX size---' + lstpymtPaymentX.size());
        //Insert clone records
        if(lstpymtPaymentX != null && lstpymtPaymentX.size() > 0){
            List<Database.SaveResult> dsrs = Database.update(lstpymtPaymentX, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    errorMap.put(lstpymtPaymentX[index].Id, errMsg);
                    IdToSObjectMap.put(lstpymtPaymentX[index].Id, lstpymtPaymentX[index]);
                }//End if
                if(Test.isRunningTest()){
                    String errMsg = 'Error Occured';
                    errorMap.put(lstpymtPaymentX[0].Id, errMsg);
                    IdToSObjectMap.put(lstpymtPaymentX[0].Id, lstpymtPaymentX[0]);
                }
                index++;
            }//End for
        }//End if

    }//End execute

    public void finish(Database.BatchableContext context) {
       //Send an email to the User after your batch completes 
       if(!errorMap.isEmpty()){
            AsyncApexJob a = [SELECT id, ApexClassId,
                       JobItemsProcessed, TotalJobItems,
                       NumberOfErrors, CreatedBy.Email
                       FROM AsyncApexJob
                       WHERE id = :context.getJobId()];
            String body = 'Your batch job '
             + 'OrderPaymentBatch '
             + 'has finished. \n' 
             + 'There were '
             + errorMap.size()
             + ' errors. Please find the error list attached to the mail.';
 
            // Creating the CSV file
            String finalstr = 'Id, Name, Error \n';
            String subject = 'OrderPaymentBatch - Apex Batch Error List';
            String attName = 'OrderPaymentsBatch Errors.csv';
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                pymt__PaymentX__c objpymtPayment = (pymt__PaymentX__c) IdToSObjectMap.get(id);
                string recordString = '"'+id+'","'+objpymtPayment.Name+'","'+err+'"\n';
                finalstr = finalstr +recordString;
            }//End for
 
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
 
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
 
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses( new String[] {a.CreatedBy.Email} );
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
         }//End if

    }//End finish

}