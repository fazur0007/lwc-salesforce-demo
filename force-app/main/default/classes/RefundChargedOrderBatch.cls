global class RefundChargedOrderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable,Database.Stateful{
    
    private final String soqlQuery;
    private Date authExpireDate;
    /*global static void schduleBatch(){
        RefundChargedOrderBatch chargeBatch = new RefundChargedOrderBatch();
        String sch = '0 0 * * * ?';
        if(!Test.isRunningTest()){
            String jobID = system.schedule('RefundChargedOrderBatch Job',sch, chargeBatch);
        }
    }*/
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RefundChargedOrderBatch(), 1);
    }
    global RefundChargedOrderBatch(String query){
        this.soqlQuery = query;
    }
    global RefundChargedOrderBatch(){
        String query = 'SELECT Id, ChargentOrders__Order__c, Batch_Processing_Action__c, Order__c, '
            			+ 'Order__r.OwnerId, CC_Auth_Exp__c '
            			+ 'FROM ChargentOrders__Transaction__c '
            			+ 'WHERE ChargentOrders__Type__c  = \'Charge\' '
            			+ 'AND Batch_Processing_Action__c = \'Refund\' '
            			+ 'AND Scheduled_Payment_Date__c <= TODAY ';
        this.soqlQuery = query;
        //System.debug('soqlQuery in constructor::::: '+ soqlQuery);
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<ChargentOrders__Transaction__c> scope){
        Id parentRecordId;
        Id ownerId;
        if(scope[0].Order__c != null) {
            parentRecordId = scope[0].Order__c;
            ownerId = scope[0].Order__r.OwnerId;
        }
        if(scope[0].Batch_Processing_Action__c == 'Refund'){
            Boolean isSuccess = Chargent_APIUtility.refundChargedTransaction(scope[0].Id,'Payment Refund',parentRecordId,ownerId);
            if(isSuccess) {
                scope[0].Batch_Processing_Action__c = 'Refunded';
                update scope[0];
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //Not required
    }
}