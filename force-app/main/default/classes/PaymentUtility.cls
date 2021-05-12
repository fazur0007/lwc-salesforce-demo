public without sharing class PaymentUtility {
	
    public static String createPaymentRequestForOrder(Id orderId){
    	try{
    		boolean hasError = false;
    		boolean orderRecUpdated = false;
    		Order orderRec = [select Id,BillToContactId, Shipping_Method__c,  PaymentId__c, SendQuote__c,SendQuoteEmail__c, Amount_for_Authorization__c, 
        							AccountId, Account.PersonEmail, BillToContact.Email, Type  from Order 
        							where id = :orderId ];
		
	        if(orderRec.Type != null && orderRec.Type.equalsIgnoreCase('Sale') && 
	        					(orderRec.Shipping_Method__c == null || (orderRec.Shipping_Method__c != null && orderRec.Shipping_Method__c == ''))){
	        	hasError = true;
	        }
	        if(!hasError){
	        	orderRec.SendQuoteEmail__c = null;
            if(orderRec.AccountId  != null && !String.isBlank(orderRec.Account.PersonEmail)){
                 orderRec.SendQuoteEmail__c =  orderRec.Account.PersonEmail;
                 orderRecUpdated = true;
            }else if(orderRec.BillToContactId != null && orderRec.BillToContact.Email != null){
                 orderRec.SendQuoteEmail__c = orderRec.BillToContact.Email;
                 orderRecUpdated = true;
            }
            if(orderRec.SendQuoteEmail__c == null || orderRec.SendQuoteEmail__c == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Send_Quote_Pop_Up_Email_Message));
                return null;
            }   
            
            ChargentOrders__ChargentOrder__c newChargentOrder =  returnExistingChargentOrderIfExists(orderRec.Id, orderRec.Amount_for_Authorization__c);
            if(newChargentOrder == null){
		    	ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(orderRec.Id);
		        newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
		        //newChargentOrder.ChargentOrders__Gateway__c='a1o290000005gV4';
		        All_Literal__mdt literal = [select Value__c from All_Literal__mdt where DeveloperName='CustomUserId' LIMIT 1];
		        newChargentOrder.ownerId = literal.Value__c;
		        insert newChargentOrder;
            }
	                
	        ChargentOrders__Payment_Request__c newPaymentRequest = new ChargentOrders__Payment_Request__c();
	        newPaymentRequest.ChargentOrders__Payment_Request_Transaction_Type__c = Label.Payment_Request_Type;
	        newPaymentRequest.ChargentOrders__Billing_Contact__c = orderRec.BillToContactId;
	        newPaymentRequest.ChargentOrders__ChargentOrder__c = newChargentOrder.Id; 
	        insert newPaymentRequest;
	       
	        list<ChargentOrders__Payment_Request__c> chargentOrderPaymentRequest = [select Id,ChargentOrders__Pay_Link__c, 
	        																		ChargentOrders__ChargentOrder__r.Order__r.Brand__c from
                                                                                	ChargentOrders__Payment_Request__c
                                                                                	where id =: newPaymentRequest.Id];
	        if(chargentOrderPaymentRequest != null &&chargentOrderPaymentRequest.size() > 0){
	        	String brand = chargentOrderPaymentRequest[0].ChargentOrders__ChargentOrder__r.Order__r.Brand__c;
	        	if(brand == null || brand == ''){
	        		brand = 'Breville';
	        	}
	        	if(orderRecUpdated){
	        		update orderRec;
	        	}
	            return chargentOrderPaymentRequest[0].ChargentOrders__Pay_Link__c +'&brand=' +brand+'&Message=Success';
	            
	        }
	        	
	        }else{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Shipping Method'));
        	}
    		
    	}catch(Exception ex){
           //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
           ErrorLog.LogErrorActivity(ex, 'Send Quote ',true,'PaymentUtility Error',
                                           null,orderId,null);
		}
		return null;
    }
    
    public static ChargentOrders__ChargentOrder__c returnExistingChargentOrderIfExists(Id orderId, Decimal amount){
    	List<ChargentOrders__ChargentOrder__c> chargentOrderList = [select id from ChargentOrders__ChargentOrder__c 
    																		where Order__r.Id = :orderId and 
    																		ChargentOrders__Charge_Amount__c = :amount and
    																		CreatedDate >= :Date.Today().addDays(-30) 
    																		order by ChargentOrders__Date__c DESC];
		if(chargentOrderList !=null && chargentOrderList.size() > 0){
			return chargentOrderList[0];
		}else{
			return null;
		}
    }
}