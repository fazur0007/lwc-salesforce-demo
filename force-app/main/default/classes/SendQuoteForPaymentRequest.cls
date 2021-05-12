public with sharing class SendQuoteForPaymentRequest {
    
    public String payLinkForChargent{get;set;}
    public Id paymentRequestId;
    public  Id getPaymentRequestId(){   
        return paymentRequestId;

    }
    public  void setPaymentRequestId(Id paymentRequestIdValue){ 
        
        paymentRequestId = paymentRequestIdValue;
    
        list<ChargentOrders__Payment_Request__c> chargentOrderPaymentRequest = [select Id,ChargentOrders__Pay_Link__c, ChargentOrders__ChargentOrder__r.Order__r.Brand__c from
                                                                                ChargentOrders__Payment_Request__c
                                                                                where id =: paymentRequestIdValue];
        if(chargentOrderPaymentRequest != null &&chargentOrderPaymentRequest.size() > 0){
        	String brand = chargentOrderPaymentRequest[0].ChargentOrders__ChargentOrder__r.Order__r.Brand__c;
        	if(brand == null || brand == ''){
        		brand = 'Breville';
        	}
            payLinkForChargent = chargentOrderPaymentRequest[0].ChargentOrders__Pay_Link__c +'&brand=' +brand;
        }

    }
    
}