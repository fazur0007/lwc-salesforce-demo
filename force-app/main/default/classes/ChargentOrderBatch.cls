public class ChargentOrderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable,Database.Stateful{
    
    private final String soqlQuery;
    private Date authExpireDate;
    public static void scheduleBatch(){
        ChargentOrderBatch chargeBatch = new ChargentOrderBatch();
        String sch = '0 45 12/1 1/1 * ? *';
        if(!Test.isRunningTest()){
            String jobID = system.schedule('ChargentOrderBatch Job',sch, chargeBatch);
        }
    }
    
    public void execute(SchedulableContext sc) {
        //check if already one batch is runnning then return this batch from execution
        if(!Utility.isBatchRunning('ChargentOrderBatch')){
            //we can set chunk size to only 1 as depending on chargent api
            Database.executeBatch(this, 1);
        }
    }
    public ChargentOrderBatch(String query){
        this.soqlQuery = query;
    }
    public ChargentOrderBatch(){
        String query = 'SELECT Id, ChargentOrders__Charge_Amount__c, Batch_Processing_Action__c, '
            + 'Order__c, Order__r.OwnerId '
            + 'FROM ChargentOrders__ChargentOrder__c '
            + 'WHERE Batch_Processing_Action__c = \'Authorize\' ';
        this.soqlQuery = query;
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        authExpireDate = Date.today();
        list<All_Literal__mdt> literalRec = [SELECT Value__c, DeveloperName FROM All_Literal__mdt WHERE DeveloperName ='Reauthorize_Interval_Date' ];
        
        if(literalRec != null && literalRec.size() > 0 && literalRec[0].Value__c != null){
            authExpireDate = authExpireDate.addDays(Integer.valueOf(literalRec[0].Value__c));
        }
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<ChargentOrders__ChargentOrder__c> scope){
        
        Id parentRecordId = scope[0].Order__c;
        Id ownerId = scope[0].Order__r.OwnerId;
        Chargent_APIUtility.authorizeChargentOrder(scope[0].Id,'Payment Authorization',parentRecordId,ownerId);
        
		scope[0].Batch_Processing_Action__c= null;
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        //Not required
    }
}