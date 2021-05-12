global class BatchForOfferOrderActivation implements Database.Batchable<sObject>, Schedulable{
  
  
  global static void schduleBatch(){
        
        String oncePerDay =  '0 0 0 * * ? *';
        BatchForOfferOrderActivation offerbatch = new BatchForOfferOrderActivation();
        String jobId = system.schedule('BatchForOfferOrderActivation Job',oncePerDay, offerbatch);
        
    } 
    
    /* will be added later */
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 1);
    }
  
  
  
  //start method to return new order list 
  global Database.QueryLocator start(Database.BatchableContext BC){
    String query='select id,Status,OwnerId,ActivatedById from Order where Status = \'Open\' AND Offer_Activation_Date__c = TODAY AND Source__c = \'GWP\'';
    return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC,List<Order> newOrderList){
    for(Order newOrder : newOrderList)
    {
      newOrder.status = 'In Approval';
      newOrder.ActivatedById = neworder.OwnerId;
    }
    Database.update(newOrderList, false);
  }
  global void finish(Database.BatchableContext BC){
       
  }
}