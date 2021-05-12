/* 
* SendQuoteOnWorkOrderController is class which operate from Send Quote button on Work Order
*
* Functionality :
* (1) Creates the payment record for work order.
* (2) Send breville email template with work order line item to customer.
* (3) Send polyscience email template with work order line item to customer.
*

*/
public with sharing class SendQuoteOnWorkOrderController {
    public boolean quoteSent {get;set;}
    public boolean createOrderPanel {get;set;}
    public String createReturnLabel {get;set;}
    public String createBoxOrder {get;set;}
    public boolean hidePanels {get;set;}
    private WorkOrder workOrderRec;
    private boolean isReturnBoxNeeded;
    
    public SendQuoteOnWorkOrderController(ApexPages.StandardController stdController) {
        String workOrderFieldStr = 'AccountId,Account.PersonEmail,Contact.Email,ContactId,Account.PersonContactId,IsCalculated__c,Email__c,Product__c,Product__r.Service_Return_Box__c';
        createReturnLabel = 'No';
        createBoxOrder = 'No';
        hidePanels = true;
        createOrderPanel = false;
        quoteSent = false;
        
		if (!Test.isRunningTest()) {
        	list<String> workOrderFields = workOrderFieldStr.split(',');
        	stdController.addFields(workOrderFields);
        	workOrderRec = (WorkOrder) stdController.getRecord();
        }else {
        	workOrderRec = [Select Id,AccountId,Account.PersonEmail,ContactId,IsCalculated__c,Email__c, Product__r.Service_Return_Box__c 
        	            from WorkOrder limit 1];
        }
        if(workOrderRec.Product__r.Service_Return_Box__c != null){
        	isReturnBoxNeeded = true;
        }else{
        	isReturnBoxNeeded = false;
        }
        
     }
   
    public void sendQuote(String createReturnLabel){
        Boolean hasError = false;
       
        if(!hasError){
        	workOrderRec.Email__c = null;
            
            if(workOrderRec.AccountId  != null && !String.isBlank(workOrderRec.Account.PersonEmail)){
                 workOrderRec.Email__c =  workOrderRec.Account.PersonEmail;
            }else if(workOrderRec.ContactId != null && workOrderRec.Contact.Email != null){
                 workOrderRec.Email__c = workOrderRec.Contact.Email;
            }
	        
            if(workOrderRec.Email__c == null || workOrderRec.Email__c == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Send_Quote_Pop_Up_Email_Message));
                return;
            }
            ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(workOrderRec.Id);
            ChargentOrders__ChargentOrder__c newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
            //newChargentOrder.ChargentOrders__Gateway__c='a1o290000005gV4';
            insert newChargentOrder;
                    
            ChargentOrders__Payment_Request__c newPaymentRequest = new ChargentOrders__Payment_Request__c();
            newPaymentRequest.ChargentOrders__Payment_Request_Transaction_Type__c = Label.Payment_Request_Type;
            newPaymentRequest.ChargentOrders__Billing_Contact__c = workOrderRec.ContactId;
            newPaymentRequest.ChargentOrders__ChargentOrder__c = newChargentOrder.Id; 
            insert newPaymentRequest;
            
            if(createReturnLabel.equalsIgnoreCase('Yes')){
            	 workOrderRec.AutoReturnLabelStatus__c = 'Scheduled';
            }
            
            workOrderRec.PaymentId__c = newPaymentRequest.Id;
            workOrderRec.Send_Quote__c = true;
            
        }
    }
 
    public void submitResponse(){
    	sendQuote(createReturnLabel);
    	if(createBoxOrder == 'Yes'){
    		workOrderRec.CreateBoxOrder__c = true;
    	}
    	
    	try{
    		update workOrderRec;
    	}catch(Exception ex){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
           ErrorLog.LogErrorActivity(ex, 'Send Quote ',true,'SendQuoteOnWorkOrderController Error',null,workOrderRec.Id,null);
		}
		
		createOrderPanel = false;
		quoteSent = true;
		hidePanels = false;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Label.Breville_Quotation_Sent_Message));
		
    }
    
    public void showOrderChange(){
    	
    	if(isReturnBoxNeeded && createReturnLabel == 'Yes'){
    		createOrderPanel = true;
    		createBoxOrder = 'No';
    	}else{
    		createOrderPanel = false;
    		createBoxOrder = 'No';
    	}
    }
    
}