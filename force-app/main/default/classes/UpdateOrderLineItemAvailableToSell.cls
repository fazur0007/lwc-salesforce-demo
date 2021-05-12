public with sharing class UpdateOrderLineItemAvailableToSell implements Queueable{
    
    list<OrderItem> listOrderItemToUpdate = new list<OrderItem>();
    
    public UpdateOrderLineItemAvailableToSell(list<OrderItem> listOrderItemToUpdate){
    	this.listOrderItemToUpdate = listOrderItemToUpdate;
    }
    
    public void execute(QueueableContext context) {
    	Database.SaveResult[] results = Database.update(listOrderItemToUpdate, false);
    	try{
	    	list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
	        for (Integer i = 0; i < listOrderItemToUpdate.size(); i++) {
	            if (!results[i].isSuccess()) {
	                
	                String msg = '';
	                msg += results[i].errors[0].getMessage();
	                
	                Error_Log__c error = new Error_Log__c( 
	                										Error_Message__c = msg,
	                										Operation__c = 'ProductHandler - UpdateOrderLineItemAvailableToSell - ' +
	                																'Error while updating Available to Sell on Order Item from Product',
	                										Record_Id__c = String.valueOf(listOrderItemToUpdate[i].get('Id')),
	                										Trace_Log__c = msg,
	                										Type__c = 'Error'
	                );
	                errorLogs.add(error);
	            }
	        }
	        insert  errorLogs;
    	}catch(Exception ex){
    		ErrorLog.LogErrorActivity(ex,'Error loading Avaialble to Sell on Order Item',true,'Error');
    	}
    }
}