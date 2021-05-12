global class BatchConvertIndividualAccounts {
	
/*
implements Database.Batchable<sObject>, Database.Stateful
{ 
    String query;
    private final String personAcctRecId;
    private final String adminId;
    private final String settingsId;
    String[] errors = new String[]{};
    Integer successCount = 0;
        
    global BatchConvertIndividualAccounts(Boolean testMode) {
        // get person-account record type id
        RecordType[] recordTypes = [Select SobjectType, Name, IsPersonType, IsActive, Id, DeveloperName, CreatedDate 
                From RecordType where SobjectType = 'Account' and IsPersonType = true and IsActive = true Order by CreatedDate Desc];
        if (recordTypes.size()>0) {
            this.personAcctRecId = recordTypes[0].Id;
        }

        pymt__Settings__c[] settings = [Select Id from pymt__Settings__c where isDeleted = false];
        if (settings.size()>0) {
            this.settingsId = settings[0].Id;
        }
        this.query = 'Select Id, OwnerId, (Select Id, OwnerId from Contacts Limit 2) from Account where pymt__Convert_To_Person_Account__c = true '+
                    ' and isPersonAccount = false and isDeleted = false and Conversion_Attempt__c = null';
        if (testMode) this.query += ' and Name like \'%ApexConvert%\' limit 10';
        //System.debug('======> query string: '+this.query);
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //System.debug('=====> start method');
        Database.QueryLocator result =  Database.getQueryLocator(query);
        System.debug(result);   
        return result;
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
     { 
    
        //System.debug('=====> execute method');
        
        Account[] accountsToConvert = new Account[]{};
        Account[] errorsToMark = new Account[]{};
        // Convert
        // When converting a business account to a person account, there must be a one-to-one relationship between each business 
        // account record and its corresponding contact record. Furthermore, fields common to both records such as Owner and Currency 
        // must have identical values.
        try {
            accountsToConvert.clear();
            errorsToMark.clear(); 
            for (SObject obj :scope) {
                Account flaggedAccount = (Account)obj;
                if (flaggedAccount.Contacts == null || flaggedAccount.Contacts.size() <> 1) {
                    flaggedAccount.Conversion_Attempt__c = 'ERROR|Account must have exactly one contact record for conversion to Person Account.';
                    errorsToMark.add(flaggedAccount);
                    this.errors.add('Account '+flaggedAccount.Id+' cannot be converted: '+flaggedAccount.Conversion_Attempt__c);    
                } else if (flaggedAccount.ownerId <> flaggedAccount.Contacts[0].ownerId){
                    flaggedAccount.Conversion_Attempt__c = 'ERROR|Account and Contact record owner must match for conversion to Person Account.';
                    errorsToMark.add(flaggedAccount);
                    this.errors.add('Account '+flaggedAccount.Id+' cannot be converted: '+flaggedAccount.Conversion_Attempt__c);
                } else {
                    // account/contact pair appears to qualify for conversion
                    flaggedAccount.RecordTypeId = personAcctRecId;
                    accountsToConvert.add(new Account(id=flaggedAccount.Id, RecordTypeId = personAcctRecId));
                    
                }
            }
    
            Database.SaveResult[] results = Database.update(accountsToConvert,false);
             Integer index = 0;
            for (Database.SaveResult result :results) {
                if (!result.isSuccess()) {
                    // Store error message in account record for each failed conversion
                    // todo write
                    Database.Error errorRecord = result.getErrors()[0];
                    String message = 'ERROR|'+errorRecord.getStatusCode()+': '+errorRecord.getMessage();
                    if (message.length() >255) {
                        message = message.substring(0,254); // make sure error message don't overflow field size
                    }
                    errorsToMark.add(new Account(Id=accountsToConvert[index].Id,
                                                Conversion_Attempt__c = message
                                                 )); 
                    
                } else {
                    this.successCount += 1;
                }
                index += 1;
            }
            
            if (errorsToMark.size()>0) {
                results = Database.update(errorsToMark,false);
    
                for (Database.Saveresult result :results) {
                    if (!result.isSuccess()) {
                    
                        System.debug('Error recording conversion attempt value for '+result.getId()+': '+result.getErrors()[0]);                        
                        this.errors.add('Error recording conversion attempt value for '+result.getId()+': '+result.getErrors()[0]);
                    }
                }           
            }
            
        } catch (Exception ex) {
            System.debug('Error converting records to person-accounts: '+ex.getMessage());
            this.errors.add('Error converting records to person-accounts: '+ex.getMessage());
        }
     }
 
    global void finish(Database.BatchableContext BC) {
        //System.debug('=====> finish method');
        try {
            String message = '';
            
            if (this.successCount>0) {
                message = 'Successfully converted '+this.successCount+' individual accounts to Person Accounts.';
                logEvent('BatchConvertIndividualAccounts: '+this.successCount+' records converted',
                            message,
                            null,
                            this.settingsId, null, null, null);             
            }
            if (this.errors.size()>0) {
    
                message = 'Errors encountered while attempting to batch convert PaymentConnect Individual Accounts to Person-Accounts: \n';
                for (String errString :this.errors) {
                    message += errString+'\n';
                }
                if (message.length()>32000) {
                    message = message.substring(1, 31500)+'\nMessage size limit reached.  ';
                }
                logError('BatchConvertIndividualAccounts: '+this.errors.size()+' errors encountered',
                    message,
                    null);
                    
            }
        } catch (Exception ex) {
            
            System.debug('Error in batchConvertIndividualAccounts finish method: '+ex.getMessage());
        }
    }



        
    public static void logError(String subject, 
                                    String body, 
                                    Integer errorCode, 
                                    Id paymentId, 
                                    Id recurringPaymentId,
                                    Id paymentMethodId,
                                    Id processorConnectionId
                                    ) {
        list<pymt__Settings__c> settings = [Select id from pymt__Settings__c where isDeleted=false limit 1];
        system.debug('****************settings'+settings.size());
        
        try {
            system.debug('****************settings'+settings);
            if (settings.size() > 0 ) {
                String errorCodeString = errorCode == null?'':String.valueOf(errorCode);
                pymt__Log_Entry__c logEntry = new pymt__Log_Entry__c(name = subject,
                                            pymt__Type__c = 'Error',
                                            pymt__Code__c = errorCodeString,
                                            pymt__Details__c = body,
                                            pymt__PaymentConnect_Settings__c = settings[0].Id,
                                            pymt__Payment__c = paymentId,
                                            pymt__Recurring_Payment__c = recurringPaymentId,
                                            pymt__Payment_Method__c = paymentMethodId,
                                            pymt__Processor_Connection__c = processorConnectionId
                                            );
                Database.Insert(logEntry);
            }
        } catch (Exception ex) {
            System.debug('Error: Error logging error message: '+ex+', '+body);          
        }       
    }   



    public static void logError(String subject, String body, Integer errorCode) {
        logError(subject, body, errorCode, null, null, null, null);
    }   
    
    public static void logEvent(String subject, 
                                    String body, 
                                    String eventCode, 
                                    Id paymentId, 
                                    Id recurringPaymentId,
                                    Id paymentMethodId,
                                    Id processorConnectionId
                                    ) {
        list<pymt__Settings__c> settings = [Select id from pymt__Settings__c where isDeleted=false limit 1];
        try {
            if (settings.size() > 0) {
                pymt__Log_Entry__c logEntry = new pymt__Log_Entry__c(name = subject,
                                            pymt__Type__c = 'Event',
                                            pymt__Code__c = eventCode,
                                            pymt__Details__c = body,
                                            pymt__PaymentConnect_Settings__c = settings[0].Id,
                                            pymt__Payment__c = paymentId,
                                            pymt__Recurring_Payment__c = recurringPaymentId,
                                            pymt__Payment_Method__c = paymentMethodId,
                                            pymt__Processor_Connection__c = processorConnectionId
                                            );
                Database.Insert(logEntry);
            }
        } catch (Exception ex) {
            System.debug('Error: Error logging error message: '+ex+', '+body);          
        }       
    }   

    
    
    private static testmethod void testBatchConvertIndividualAccounts() {
        // NOTE: This test method assumes that a PaymentConnect Settings record has been added to the current instance of Salesforce

        logError('Subject', 'Message body', 0);
       logEvent('Subject', 'Message body', 'E1000', null, null, null, null);
        
        Account account;
        Contact contact;
        
        Contact[] contacts = [Select id from Contact where lastname like 'ApexConvert%' ];
        if (contacts !=null && contacts.size() > 0) delete contacts;
        Account[] accounts = [Select id from Account where name like '%ApexConvert%' ];
        if (accounts !=null && accounts.size() > 0) delete accounts;
        
        account = new Account(
                    Name = 'Merge1 ApexConvertToPersonAccountTest',
                    pymt__Convert_To_Person_Account__c = true 
                     );
        insert account;
        
        contact = new Contact( 
                    FirstName = 'Merge1',
                    LastName = 'ApexConvertToPersonAccountTest',
                    email = 'merge1@apextest.com',
                    AccountId = account.Id
                     );
        insert contact;

        // Account with no contact
        account = new Account(
                    Name = 'Merge2 ApexConvertToPersonAccountTest',
                    pymt__Convert_To_Person_Account__c = true 
                     );
        insert account;
                
        // Account with error from previous run
        account = new Account(
                    Name = 'Merge3 ApexConvertToPersonAccountTest',
                    pymt__Convert_To_Person_Account__c = true ,
                    Conversion_Attempt__c = 'ERROR_DURING_UPDATE'                   
                     );
        insert account;
        contact = new Contact( 
                    FirstName = 'Merge3',
                    LastName = 'ApexConvertToPersonAccountTest',
                    email = 'merge1@apextest.com',
                    AccountId = account.Id
                     );
        insert contact;
                        
        Test.startTest();

            BatchConvertIndividualAccounts b = new BatchConvertIndividualAccounts(true);
            Database.executeBatch(b);
        
        Test.stopTest();     
    }
    */

}