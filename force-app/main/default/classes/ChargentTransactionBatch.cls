global class ChargentTransactionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable,Database.Stateful{
    
    private final String soqlQuery;
    private Date authExpireDate;
    global static void schduleBatch(){
        ChargentTransactionBatch chargeBatch = new ChargentTransactionBatch();
        String sch = '0 0 * * * ?';
        if(!Test.isRunningTest()){
        	String jobID = system.schedule('ChargentTransactionBatch Job',sch, chargeBatch);
        }
    }
    
    global void execute(SchedulableContext sc) {
        //check if alreay one batch is runnning then return this batch from execution
        if(!Utility.isBatchRunning('ChargentTransactionBatch')){
            //we can set chunk size to only 1 as depending on chargent api
            Database.executeBatch(this, 1);
        }
    }
    global ChargentTransactionBatch(String query){
        this.soqlQuery = query;
    }
    global ChargentTransactionBatch(){
        String query = 'SELECT Id, ChargentOrders__Order__c, Batch_Processing_Action__c, Order__c, WorkOrder__c, '
            			+ 'Order__r.OwnerId, WorkOrder__r.OwnerId, CC_Auth_Exp__c '
            			+ 'FROM ChargentOrders__Transaction__c '
            			+ 'WHERE (ChargentOrders__Type__c  = \'Authorization\' '
            			+ 'AND (( Batch_Processing_Action__c  IN (\'Capture\',\'Void\') '
            			+ 'AND Scheduled_Payment_Date__c <= TODAY) OR (CC_Auth_Exp__c <= :authExpireDate ))) '
            			+ 'OR (ChargentOrders__Type__c  = \'Charge\' '
            			+ 'AND Batch_Processing_Action__c = \'Refund\' '
            			+ 'AND Scheduled_Payment_Date__c <= TODAY)';
        this.soqlQuery = query;
        System.debug('soqlQuery in constructor::::: '+ soqlQuery);
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        authExpireDate = Date.today();
        list<All_Literal__mdt> literalRec = [SELECT Value__c, DeveloperName FROM All_Literal__mdt WHERE DeveloperName ='Reauthorize_Interval_Date' ];
        
        if(literalRec != null && literalRec.size() > 0 && literalRec[0].Value__c != null){
            authExpireDate = authExpireDate.addDays(Integer.valueOf(literalRec[0].Value__c));
        }
        System.debug('soqlQuery in start method::::: '+ soqlQuery);
        return Database.getQueryLocator(soqlQuery);
    }

    global void execute(Database.BatchableContext BC, List<ChargentOrders__Transaction__c> scope){
        system.debug('scope.size::::: '+scope.size());
        system.debug('scope::::: '+scope);
        system.debug('authExpireDate::::: '+authExpireDate);
        Id parentRecordId = scope[0].Order__c != null ? scope[0].Order__c : scope[0].WorkOrder__c;
        system.debug('parentRecordId ::::: '+ parentRecordId);
        Id ownerId = scope[0].Order__c != null ? scope[0].Order__r.OwnerId : scope[0].WorkOrder__r.OwnerId;
        system.debug('ownerId ::::: '+ ownerId);
        if(scope[0].Batch_Processing_Action__c == 'Capture'){
            System.debug('Inside IF Capture:::::'+ authExpireDate);
            Chargent_APIUtility.chargeAuthorizedTransaction(scope[0].Id,'Payment Charge',parentRecordId,ownerId);
        }else if(scope[0].Batch_Processing_Action__c == 'Void'){
        	System.debug('Inside IF Void:::::'+ authExpireDate);
            Chargent_APIUtility.voidTransaction(scope[0].Id,'Payment Void',parentRecordId,ownerId);
        }else if(scope[0].Batch_Processing_Action__c == 'Refund'){
        	System.debug('Inside IF Refund:::::'+ authExpireDate);
            Chargent_APIUtility.refundChargedTransaction(scope[0].Id,'Payment Refund',parentRecordId,ownerId);
        }else if(scope[0].CC_Auth_Exp__c <= authExpireDate){
            system.debug('Inside IF CC_Auth_Exp__c:::::'+ authExpireDate);
            Boolean isSucess = Chargent_APIUtility.voidTransaction(scope[0].Id,'Payment Reauthorization',parentRecordId,ownerId);
            if(issucess){
                System.enqueueJob(new PaymentReauthorizationStep2Authorize(scope[0].ChargentOrders__Order__c,parentRecordId,ownerId));
                
            }
        } 
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        //Not required
    }
}