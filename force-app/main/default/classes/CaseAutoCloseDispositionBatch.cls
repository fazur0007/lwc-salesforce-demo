global class CaseAutoCloseDispositionBatch implements Database.Batchable<sObject>,Schedulable, Database.Stateful{
    
    list<String> currencySet = new list<String>();
    
    global CaseAutoCloseDispositionBatch(){
        
        /* getting region wise settings from metadata*/
        List<Case_Auto_Close_Disposition_Metadata__mdt> caseAutoCloseDispositionList = [SELECT RegionCurrency__c, IsActive__c 
                                                                                        FROM Case_Auto_Close_Disposition_Metadata__mdt 
                                                                                        WHERE IsActive__c = true];
        
        /* currency set of considered cases */
        for(Case_Auto_Close_Disposition_Metadata__mdt metadateRecord : caseAutoCloseDispositionList){
            currencySet.add(metadateRecord.RegionCurrency__c);
        }
       
    }
    
    /* will be added later */
    global static void schduleBatch(){
        
        String oncePerDay =  '0 0 23 * * ? *';
        CaseAutoCloseDispositionBatch autoClosebatch = new CaseAutoCloseDispositionBatch();
        String jobId = system.schedule('CaseAutoCloseDispositionBatch Job',oncePerDay, autoClosebatch);
        
    } 
    
    /* will be added later */
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 1);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        Date todaysDate = Date.today();
        String query = 'SELECT Id, CaseAutoCloseCheckDate__c, ReplyBackNotificationSent1__c, Closed_Reason__c,'+
                        ' Status FROM Case WHERE CaseAutoCloseCheckDate__c != null AND CaseAutoCloseCheckDate__c = TODAY' +
                        ' AND CurrencyIsoCode IN :currencySet';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases){
        list<Case> caseListToUpdate = new list<Case>();
        System.debug('### cases : ' +cases);
        /* cheking cases for soft close or hard close */
        for(Case caseRecord : cases){
            if((caseRecord.Status == 'Waiting on consumer' || caseRecord.Status == 'Waiting on return') && !caseRecord.ReplyBackNotificationSent1__c){
                caseRecord.Status = 'Soft Closed';
                caseRecord.Closed_Reason__c = ApplicationLiterals.CASEAUTOCLOSEDISPOSITION_SoftCloseReason;
                caseRecord.CaseAutoCloseCheckDate__c = Date.today().addDays(ApplicationLiterals.CASEAUTOCLOSEDISPOSITION_DaysForHardClose);
                caseListToUpdate.add(caseRecord);
            }else if(caseRecord.Status == 'Soft Closed' && caseRecord.ReplyBackNotificationSent1__c){
                caseRecord.Status = 'Closed';
                caseRecord.Closed_Reason__c = ApplicationLiterals.CASEAUTOCLOSEDISPOSITION_HardClosedReason;
                caseListToUpdate.add(caseRecord);
            }
        }
        
        /* updating the case list and saving the result any record fails to update */
        Database.SaveResult[] saveResult;
        list<Error_Log__c> errorLogs = new list<Error_Log__c>();
        if(caseListToUpdate != null && caseListToUpdate.size() > 0){
            saveResult = Database.update(caseListToUpdate);
        }
        
        
        /* saving the result of failed cases in error log */
        if(saveResult != null && saveResult.size() > 0){
            for(Integer i = 0; i < saveResult.size(); i++) {
                if (!saveResult[i].isSuccess()) {
                    Error_Log__c error = ErrorLog.logErrorActivity('Error while updating Soft/Hard Closed cases',
                                                        saveResult[i].errors[0].getMessage(), 
                                                    'CaseAutoCloseDispositionBatch-execute method',false, 'Error in updating cases', null, null, null); 
                    errorLogs.add(error);
                }
            }
        }
        
        if(!errorLogs.isEmpty()){
            insert errorLogs;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}