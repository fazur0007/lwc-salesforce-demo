public with sharing class RMAProcessBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    
    public enum Action {
        ProcessReceiving,
        CompleteRMA
    }
    
    String query;
    Action actionType;
    
    public RMAProcessBatch(Action actionType) {
        this.actionType = actionType;
        switch on this.actionType {
            when ProcessReceiving {
                list<All_Literal__mdt> RMAReceivedDate = [Select Value__c from All_Literal__mdt where DeveloperName='D365RMAReceivedDate'];
                String receivedDateDuration = '';
                if (RMAReceivedDate != null && RMAReceivedDate.size() > 0) {
                    receivedDateDuration = RMAReceivedDate[0].Value__c;
                }
                query = 'SELECT Id,' +
                        'Case__r.CurrencyIsoCode, Case__r.CreatedDate ' +
                        ' FROM Receiving__c  ' +
                        ' WHERE IsPriceCalculated__c = true ' +
                        ' AND Sent_to_AX__c = null ';
                query += (String.isNotBlank(receivedDateDuration) ? ' AND (' + receivedDateDuration + ')': '');
            }
            when else {
                list<All_Literal__mdt> RMAReceivedDate = [Select Value__c from All_Literal__mdt where DeveloperName='D365RMAReceivingCompleteDate'];
                String receivingCompleteDateDuration = '';
                if (RMAReceivedDate != null && RMAReceivedDate.size() > 0) {
                    receivingCompleteDateDuration = RMAReceivedDate[0].Value__c;
                }
                query = 'SELECT Id,' +
                        ' CurrencyIsoCode, CreatedDate, ' +
                        ' (SELECT Id FROM Receiving__r WHERE Sent_to_AX__c = null LIMIT 1) ' +
                        ' FROM Case' +
                        ' WHERE ReceivingComplete__c = true ' +
                        ' AND IsClosed = false ' + 
                        ' AND IsRMAComplete__c = false ' +
                        ' AND D365RMANumber__c != null ';
                query += (String.isNotBlank(receivingCompleteDateDuration) ? ' AND (' + receivingCompleteDateDuration + ')': '');
            }
        }
        
        System.debug('query :: ' + query);
    }
    
    public static void scheduleBatch(){
        RMAProcessBatch rmaProcessBatch = new RMAProcessBatch(Action.ProcessReceiving);
        String sch = '0 0 * * * ?';
        String jobID = system.schedule('Process RMA Job', sch, rmaProcessBatch);
        RMAProcessBatch caseCompleteBatch = new RMAProcessBatch(Action.CompleteRMA);
        String sch2 = '0 15 * * * ?';
        String jobID2 = system.schedule('Complete RMA Job', sch2, caseCompleteBatch);
    }
    
    public void execute(SchedulableContext sc){
        list<All_Literal__mdt> RMAProcessBatchSize = [Select Value__c from All_Literal__mdt where DeveloperName='RMAProcessBatchSize'];
        Integer batchSize = 20;
        if (RMAProcessBatchSize != null && RMAProcessBatchSize.size() > 0) {
            batchSize = Integer.valueOf(RMAProcessBatchSize[0].Value__c);
        }
        Database.executeBatch(this, batchSize);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query :: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext ctx, List<SObject> records) {
        switch on this.actionType {
            when ProcessReceiving {
                List<Receiving__c> receivingRecords = (List<Receiving__c>) records;
                Set<Id> filteredReceivingIds = new Set<Id>();
                for (Receiving__c receiving : receivingRecords) {
                    Case caseRecord = receiving.Case__r;
                    if (Utility.isD365Enabled(caseRecord)) {
                        filteredReceivingIds.add(receiving.Id);
                    }
                }
                if (!filteredReceivingIds.isEmpty()) {
                    D365APIUtility.processRMA(filteredReceivingIds);
                }
            }
            when else {
                List<Case> caseRecords = (List<Case>) records;
                Set<Id> filteredCaseIds = new Set<Id>();
                for (Case caseRecord : caseRecords) {
                    if (caseRecord.Receiving__r.size() == 0 && Utility.isD365Enabled(caseRecord)) {
                        filteredCaseIds.add(caseRecord.Id);
                    }
                }
                if (!filteredCaseIds.isEmpty()) {
                    D365APIUtility.completeRMA(filteredCaseIds);
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext ctx) {
        //To Do
    }
}