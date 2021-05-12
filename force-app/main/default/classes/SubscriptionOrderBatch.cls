global class SubscriptionOrderBatch implements  Database.Batchable<sObject>  {
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext)
    {      
        
        String query ='Select Id,Iteration_Count__c,Maximum_iterations__c from Subscription__c where Next_Run_Date__c=TODAY' ;
        if (Test.isRunningTest()) {
            query = 'Select Id,Iteration_Count__c,Maximum_iterations__c from Subscription__c LIMIT 1' ;
        }
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext batchableContext , List<Subscription__c> subscriptions)
    {        
     
        Id subscriptionId ;
        
            for(Subscription__c currSubscription : subscriptions)
            {
                subscriptionId = currSubscription.Id;
                System.debug('Inside of  execute:' +currSubscription.Id) ;
                try
                {
                    if(currSubscription.Iteration_Count__c<currSubscription.Maximum_iterations__c)
                        OrderManagementUtility.createSubscriptionOrder(subscriptionId);
                }
                catch (Exception ex)   
                {
                    Error_Log__c error = ErrorLog.logErrorActivity(ex.getStackTraceString(),ex.getMessage(),'SubscriptionOrderBatch',false,'Subscription order creation',subscriptionId);
                    system.debug('error:'+error);
                    insert error;
                } 
            }            
     }
        
    
    global void finish(Database.BatchableContext batchableContext){
        System.debug('Inside of  finish:') ;
    }
    
    
}