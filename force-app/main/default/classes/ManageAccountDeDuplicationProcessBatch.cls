public class ManageAccountDeDuplicationProcessBatch implements Database.Batchable<sObject>{

    static final string queryString = 'SELECT Id, Email__c FROM Merged_Account__c WHERE Processed__c = FALSE';
        
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Merged_Account__c> recList){
        System.debug ('Record List size: ' + recList.size());
        AccountDeDuplicateProcess.execute(recList);
        return;
    }

    public void finish(Database.BatchableContext BC){
        return;
    }
}