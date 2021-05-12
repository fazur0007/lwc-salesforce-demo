global without sharing class CancelOrderUtility {
    WebService static void cancelOrder(Id orderRecord){
    	Order orderToUpdate = [select id, status from Order where id=:orderRecord];
    	if(orderToUpdate.status == 'Order Generated'){
    		orderToUpdate.status = 'Cancellation Pending';
    		update orderToUpdate;
    	}
    }
}