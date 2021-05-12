public  class ChargentOrders_TransactionTriggerHandler {
    
    public static void populateOrderWorkOrder(list<ChargentOrders__Transaction__c> transactions){
        set<Id> chargentOrderSet = new set<Id>();
        for(ChargentOrders__Transaction__c tran : transactions){
            chargentOrderSet.add(tran.ChargentOrders__Order__c);
        }
        
        map<Id,ChargentOrders__ChargentOrder__c> chargentOrdersById = new map<Id,ChargentOrders__ChargentOrder__c>(
            [SELECT Id, Order__c, WorkOrder__c 
             FROM ChargentOrders__ChargentOrder__c
             WHERE Id IN :chargentOrderSet]);
        for(ChargentOrders__Transaction__c tran : transactions){
            if(chargentOrdersById.containsKey(tran.ChargentOrders__Order__c)){
                tran.Order__c = chargentOrdersById.get(tran.ChargentOrders__Order__c).Order__c;
                tran.WorkOrder__c = chargentOrdersById.get(tran.ChargentOrders__Order__c).WorkOrder__c;
            }
        }
        
    }
    public static void updateAuthAndTransactionId(list<ChargentOrders__Transaction__c> transactions,
                                                  map<Id,ChargentOrders__Transaction__c> oldMap,Boolean isInsert){
                                                                                                
                                                          set<Id> chargentOrderSet = new set<Id>();
                                                          map<Id,SObject> sobjectById = new map<Id,SObject>();
                                                          Id OrderId ;
                                                       	List<Id> ordIds = new List<Id>();
                                                             
                                                          for(ChargentOrders__Transaction__c tran : transactions){
                                                              SObject sObjectRecord;
                                                              Id sObjectId;
                                                              
                                                              if(tran.Order__c != null){
                                                                  sObjectId = tran.Order__c;
                                                                  OrderId=sObjectId;
                                                                  
                                                                  sObjectRecord = sobjectById.containsKey(sObjectId)?sobjectById.get(sObjectId):new Order(Id=sObjectId);  
                                                              }else if(tran.WorkOrder__c != null){
                                                                  sObjectId = tran.WorkOrder__c;
                                                                  sObjectRecord = sobjectById.containsKey(sObjectId)?sobjectById.get(sObjectId):new WorkOrder(Id=sObjectId);      
                                                              }
                                                              if(isInsert || (tran.ChargentOrders__Gateway_Date__c != oldMap.get(tran.Id).ChargentOrders__Gateway_Date__c 
                                                                              && tran.ChargentOrders__Gateway_ID__c != null) 
                                                                 || (tran.CC_Auth_Exp__c != oldMap.get(tran.Id).CC_Auth_Exp__c)){
                                                                        
                                                                                                                                                           
                                                                
                                                              if(tran.ChargentOrders__Type__c  == 'Authorization' ){
                                                                  if(tran.ChargentOrders__Response_Status__c == 'Approved') {
                                                                      if(tran.ChargentOrders__Authorization__c != null) {
                                                                        sObjectRecord.put('CC_Authorization_ID__c',tran.ChargentOrders__Authorization__c);
                                                                      } else if(tran.ChargentOrders__Gateway_ID__c != null) {
                                                                        sObjectRecord.put('CC_Authorization_ID__c',tran.ChargentOrders__Gateway_ID__c);
                                                                      }
                                                                      sObjectRecord.put('CC_Auth_Exp__c',tran.CC_Auth_Exp__c);
                                                                  }
                                                                  
                                                              }else if(tran.ChargentOrders__Type__c  == 'Charge' ){
                                                                  if(tran.ChargentOrders__Response_Status__c == 'Approved') {
                                                                      //sObjectRecord.put('Charged_Date__c', tran.ChargentOrders__Gateway_Date__c);
                                                                      sObjectRecord.put('CC_Transaction_ID__c',tran.ChargentOrders__Gateway_ID__c);
                                                                      sObjectRecord.put('CC_Auth_Exp__c',tran.CC_Auth_Exp__c);
                                                                    //  sObjectRecord.put('Transaction__c',tran.Id);
                                                                  }
                                                              }else if(tran.ChargentOrders__Type__c  == 'Void' ){
                                                                  //sObjectRecord.put('CC_Authorization_ID__c',null);   
                                                              }
                                                              sObjectRecord.put('Credit_Card_Type__c',tran.ChargentOrders__Credit_Card_Type__c);
                                                              sObjectRecord.put('Credit_Card_Last_4_Digits__c',tran.ChargentOrders__Card_Last_4__c);
                                                              sobjectById.put(sObjectId,sObjectRecord);
                                                              
                                                          }
                                                          
                                                      }
                                                      
                                                try{
                                                      list<SObject> sObjects = sobjectById.values();
                                                      Database.SaveResult[] results = Database.update(sObjects, false);
                                                      //handle error
                                                      list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
                                                      for (Integer i = 0; i < sObjects.size(); i++) {
                                                          if (! results[i].isSuccess()) {
                                                             
                                                              String msg = '';
                                                              msg += 'CC Authorization ID = ' + sObjects[i].get('CC_Authorization_ID__c')  + '\n';
                                                              msg += 'CC Transaction ID = ' + sObjects[i].get('CC_Transaction_ID__c') + '\n\n';
                                                              msg += results[i].errors[0].getMessage();
                                                              
                                                              Error_Log__c error = ErrorLog.logErrorActivity('Error loading Payment tracking data',
                                                                                                             msg, 
                                                                                                             ' ChargentOrders_TransactionTriggerHandler',false, 'Payment Error',
                                                                                                             String.valueOf(sObjects[i].get('Id')),String.valueOf(sObjects[i].get('Id')),null); 
                                                              errorLogs.add(error);
                                                          }else{
                                                             ordIds.add(String.valueOf(sObjects[i].get('Id')));
                                                          }
                                                      }
                                                      insert  errorLogs;
                                                    
                                                      
                                                    
                                                  }catch(Exception ex){
                                                      ErrorLog.LogErrorActivity(ex,'Error loading Payment tracking data -ChargentOrders_TransactionTriggerHandler',true,'Payment Error');
                                                  }
                                                      List<Order> orderList = [Select Id,Status,Loaner_Nomination__c,Type from Order where Id in :ordIds and Type ='Loaner Program Sale' and Status = 'Open'];
                                                      if (orderList!= null && orderList.size()>0){
                                                          changeLoanerNominationStatus(orderList);  
                                                      }
                                                          
                                                      
    
    
}


public static void changeLoanerNominationStatus(List<Order> orderList ){
    List<Id> lnId = new List<Id>();
    for(Order ord : orderList){
        ord.Status = 'Order Pending';
        lnId.add(ord.Loaner_Nomination__c);
    }
       
    	Database.update(orderList, false);
   
    List<Loaner_Nomination__c> lnRec= [Select id,Congratulations_Email_Check__c, Status__c From Loaner_Nomination__c Where Id in :lnId];
    if(lnRec[0].Status__c == 'Order Created-Quote Sent'){
        lnRec[0].Status__c = 'Trial Offer Accepted';
          }
    Database.update(lnRec, true);
    
    
}
}