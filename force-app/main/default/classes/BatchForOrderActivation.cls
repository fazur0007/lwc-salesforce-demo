global class BatchForOrderActivation implements Database.Batchable<sObject>, Schedulable{
  
  global void execute(SchedulableContext sc) {
        //check if already one batch is runnning then return this batch from execution
        //if(!Utility.isBatchRunning('BatchRMAReceiptPriceCalculation')){
            //we can set chunk size to only 1 as depending on chargent api
            Database.executeBatch(this, 1);
        //}
    }
  
  //start method to return new order list 
  global Database.QueryLocator start(Database.BatchableContext BC){
    String query='select id,ActivatedByPartner__c,OwnerId,CreatedById,Type,ActivatedById,OrderCustomerType__c  from Order where ActivatedByPartner__c = true AND statuscode = \'D\' AND Status != \'Cancelled\' ';
    return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC,List<Order> newOrderList){
  
    System.debug('newOrderList: '+newOrderList);    
    
    for(Order newOrder : newOrderList)
    {
       // Added while implementing SF-1008 : Remove existing Approval Process for B2B 
       //Accounts when an Order is placed from portal.

       if(newOrder.Type != null &  newOrder.Type == 'Sale' && newOrder.OrderCustomerType__c == 'B2B')
       {
           newOrder.status = 'Order Pending';
       } 
      
       else
       {
          newOrder.status = 'In Approval';
       }
       newOrder.ActivatedById = neworder.OwnerId;
    }
    Database.update(newOrderList, false);
  }
  global void finish(Database.BatchableContext BC){
       
  }
}