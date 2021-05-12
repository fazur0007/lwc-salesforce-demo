/* 
* SendQuoteController is class which operate from Send Quote button on Order
*
* Functionality :
* (1) Creates the payment record for order.
* (2) Send breville email template with order line item to customer.
* (3) Send polyscience email template with order line item to customer.
*

*/
public with sharing class SendQuoteController {
    
    private Order orderRec; 
    public SendQuoteController(ApexPages.StandardController stdController) {
        String orderFieldStr = 'AccountId,Account.PersonEmail,BillToContact.Email,BillToContactId,Account.PersonContactId,IsCalculated__c,SendQuoteEmail__c,Type,Shipping_Method__c';
       
		if (!Test.isRunningTest()) {
        	list<String> orderFields = orderFieldStr.split(',');
        	stdController.addFields(orderFields);
        	orderRec = (Order) stdController.getRecord();
        }else {
        	orderRec = [Select Id,AccountId,Account.PersonEmail,BillToContactId,IsCalculated__c,Type,Shipping_Method__c 
        	            from Order limit 1];
        }
        
     }
   	public SendQuoteController(){
   	
   	}
    public void init(){
        Boolean hasError = false;
        if(orderRec.Type != null && (orderRec.Shipping_Method__c == null || orderRec.Shipping_Method__c == '')){
        	hasError = true;
        }
        if(!hasError){
        
            orderRec.SendQuoteEmail__c = null;
            
            if(orderRec.AccountId  != null && !String.isBlank(orderRec.Account.PersonEmail)){
                 orderRec.SendQuoteEmail__c =  orderRec.Account.PersonEmail;
            }else if(orderRec.BillToContactId != null && orderRec.BillToContact.Email != null){
                 orderRec.SendQuoteEmail__c = orderRec.BillToContact.Email;
            }
            if(orderRec.SendQuoteEmail__c == null || orderRec.SendQuoteEmail__c == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Send_Quote_Pop_Up_Email_Message));
                return;
            }
            try{
	            ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(orderRec.Id);
	            ChargentOrders__ChargentOrder__c newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
	            //newChargentOrder.ChargentOrders__Gateway__c='a1o290000005gV4';
	            insert newChargentOrder;
	                    
	            ChargentOrders__Payment_Request__c newPaymentRequest = new ChargentOrders__Payment_Request__c();
	            newPaymentRequest.ChargentOrders__Payment_Request_Transaction_Type__c = Label.Payment_Request_Type; // 'Charge Full Amount';
	            newPaymentRequest.ChargentOrders__Billing_Contact__c = orderRec.BillToContactId;
	            newPaymentRequest.ChargentOrders__ChargentOrder__c = newChargentOrder.Id; 
	            insert newPaymentRequest;
	            
	            orderRec.PaymentId__c = newPaymentRequest.Id;
	            orderRec.SendQuote__c = true;
	            update orderRec;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Label.Breville_Quotation_Sent_Message));
        }catch(Exception ex){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
           ErrorLog.LogErrorActivity(ex, 'Send Quote ',true,'SendQuoteController Error',
                                           null,orderRec.Id,null);
		}
        }else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Shipping Method'));
        }
        
    }
    
    public PageReference initPaymentForEmpPortal(){
        Boolean hasError = false;
        String orderId = ApexPages.currentPage().getParameters().get('id');
        String paymentlink = PaymentUtility.createPaymentRequestForOrder(orderId);
        if(paymentlink != null){
        	PageReference paymentPage = new PageReference(paymentlink);
       		paymentPage.setRedirect(true);
			return paymentPage;
        }else{
        	return null;
        }
    }
}