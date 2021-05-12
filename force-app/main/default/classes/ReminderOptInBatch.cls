/**
* This is the batch class for Marketing Opt In Reminder mails
* @author deepak_tomar@persistent.com
* @version 1.0
* @since April 17, 2018
*/

global class ReminderOptInBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    private String currencyISOCode;
    private String soqlQuery;
    
    public ReminderOptInBatch(String currencyISOCode){
        this.currencyISOCode = currencyISOCode;
        this.soqlQuery = 'SELECT Id, SendNLReminderEmail__c, Subscribe_to_our_newsletter__c, MkgOptEmailSent__c FROM Account WHERE Subscribe_to_our_newsletter__c = false AND SendNLReminderEmail__c = false AND MkgOptEmailSent__c = N_DAYS_AGO:7 and currencyISOCode= :currencyISOCode ';
    }
    
    global static void scheduleBatch(){
        ReminderOptInBatch reminderOptInBatchForUSA = new ReminderOptInBatch('USD');
        String jobIDForUSA = system.schedule('ReminderOptInBatch JobUSA', '0 30 8 1/1 * ? *', reminderOptInBatchForUSA);
        
        ReminderOptInBatch reminderOptInBatchForCAN = new ReminderOptInBatch('CAD');
        String jobIDForCAN = system.schedule('ReminderOptInBatch JobCAN', '0 30 5 1/1 * ? *', reminderOptInBatchForCAN);
        
        ReminderOptInBatch reminderOptInBatchForAUS = new ReminderOptInBatch('AUD');
        String jobIDForAUS = system.schedule('ReminderOptInBatch JobAUS', '0 30 13 1/1 * ? *', reminderOptInBatchForAUS);
        
        ReminderOptInBatch reminderOptInBatchForNZ = new ReminderOptInBatch('NZD');
        String jobIDForNZ = system.schedule('ReminderOptInBatch JobNZ', '0 30 11 1/1 * ? *', reminderOptInBatchForNZ);
        
        ReminderOptInBatch reminderOptInBatchForUK = new ReminderOptInBatch('GBP');
        String jobIDForUK = system.schedule('ReminderOptInBatch JobUK', '0 30 0 1/1 * ? *', ReminderOptInBatchForUK);
        
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 200);
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*String query = 'SELECT Id, SendNLReminderEmail__c, Subscribe_to_our_newsletter__c, MkgOptEmailSent__c FROM Account WHERE Subscribe_to_our_newsletter__c = false AND SendNLReminderEmail__c = false AND MkgOptEmailSent__c = N_DAYS_AGO:7 and currencyISOCode!=\'EUR\'';
       
        return Database.getQueryLocator(query);*/
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,List<Account> accountList){
        system.debug('accountList --- ' + accountList);
    	for(Account acc: accountList){
    		acc.SendNLReminderEmail__c =true;
    	}
    	Database.update(accountList);
    }
    
      global void finish(Database.BatchableContext BC){
       
    }
}