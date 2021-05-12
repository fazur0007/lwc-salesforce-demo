global class BackOrderNotificationBatch implements Database.Batchable<sObject>,Schedulable, Database.Stateful{
	
	list<String> currencySet = new list<String>();
	
	global BackOrderNotificationBatch(){
		/* getting region wise settings from metadata*/
        List<BackOrderNotificationMetadata__mdt> backOrderMetadataList = [SELECT Currency__c, IsActive__c 
                                                                                        FROM BackOrderNotificationMetadata__mdt 
                                                                                        WHERE IsActive__c = true];
        
        /* currency set of considered cases */
        for(BackOrderNotificationMetadata__mdt metadateRecord : backOrderMetadataList){
            currencySet.add(metadateRecord.Currency__c);
        }
	}
	
	/* will be added later */
	global static void schduleBatch(){
		String oncePerDay =  '0 0 23 * * ? *';
        BackOrderNotificationBatch backOrderBatch = new BackOrderNotificationBatch();
        String jobId = system.schedule('BackOrderNotificationBatch Job',oncePerDay, backOrderBatch);
    } 
    
    /* will be added later */
    global void execute(SchedulableContext sc){
    	Database.executeBatch(this, 200);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Id, SendBackOrderNotification__c, NextNotificationDate__c FROM Order'+
						' WHERE Order_Pending_Reason__c = \'Waiting on Backorder Item\' AND CurrencyIsoCode IN :currencySet AND Sent_to_AX__c = null AND NextNotificationDate__c != null AND' +
						' NextNotificationDate__c = Today';
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> orderList){
    	for(Order orderRecord :  orderList){
    		orderRecord.SendBackOrderNotification__c = true;
    		orderRecord.NextNotificationDate__c = Date.today().addDays(ApplicationLiterals.BACKORDERNOTIFICATION_Duration);
    	}
    	
    	/* updating the order list and saving the result if any record fails to update */
		Database.SaveResult[] saveResult;
		list<Error_Log__c> errorLogs = new list<Error_Log__c>();
		if(orderList != null && orderList.size() > 0){
			saveResult = Database.update(orderList);
		}
		
		
		/* saving the result of failed cases in error log */
		if(saveResult != null && saveResult.size() > 0){
			for(Integer i = 0; i < saveResult.size(); i++) {
	            if (!saveResult[i].isSuccess()) {
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while updating back orders for sending back order notification',
	                                                    saveResult[i].errors[0].getMessage(), 
	                                                'BackOrderNotificationBatch-execute method',false, 'Error in updating orders', null, null, null); 
	                errorLogs.add(error);
	            }
	        }
		}
        
        if(!errorLogs.isEmpty()){
  			insert errorLogs;
  		}
    	
    }
    
    global void finish(Database.BatchableContext BC){
		
	}
	
}