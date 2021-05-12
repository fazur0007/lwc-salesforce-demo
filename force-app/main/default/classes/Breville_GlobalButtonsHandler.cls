global class Breville_GlobalButtonsHandler {
    @AuraEnabled
    global static OrderDetailsWrapper getOrderRecord(String recordId) {
        Order order = [Select Id, Status, Source__c, Channel__c,
            Name, Sent_to_AX__c, AccountType__c, RequestedShipDate__c,
            ActivatedDate,BillToContactId,OrderCustomerType__c,Shipping_Method__c
            From Order Where Id =: recordId Limit 1
        ];
        if(order != Null){
            OrderDetailsWrapper orderWrap = new OrderDetailsWrapper();
            orderWrap.Id = checkNull(order.Id);
            orderWrap.Name = checkNull(order.Name);
            orderWrap.Status = checkNull(order.Status);
            orderWrap.Source = checkNull(order.Source__c);
            orderWrap.Channel = checkNull(order.Channel__c);
            orderWrap.Sent_to_AX = checkNull(order.Sent_to_AX__c);
            orderWrap.AccountType = checkNull(order.AccountType__c);
            orderWrap.RequestedShipDate = checkNull(order.RequestedShipDate__c);
            orderWrap.ActivatedDate = checkNull(order.ActivatedDate);
            orderWrap.BillToContactId = checkNull(order.BillToContactId);
            orderWrap.OrderCustomerType = checkNull(order.OrderCustomerType__c);
            orderWrap.Shipping_Method = checkNull(order.Shipping_Method__c);
            
            return orderWrap;
        }else{
            throw new AuraHandledException('List is Empty');
        }
    }
    global static object checkNull(object fieldValue) {
        return fieldValue != Null ? fieldValue : '';
    }
    @AuraEnabled
    global static String cancelOrder(String orderRecord) {
        try {
            Order orderToUpdate = [select id, status from Order where Id =: orderRecord];
            if (orderToUpdate.status == 'Order Generated') {
                update new Order(
                    Id = orderToUpdate.Id,
                    Status = 'Cancellation Pending'
                );
            }
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    global static String sendQuote(String recordId) {
        Order orderRec = [Select Id, Status, Source__c, Channel__c, Name, AccountId, Account.PersonEmail, BillToContact.Email, BillToContactId, Account.PersonContactId, IsCalculated__c, SendQuoteEmail__c, Type, Shipping_Method__c,Asset__c From Order Where Id =: recordId Limit 1];
        Boolean hasError = false;
        //Condition for Asset is added to bypass Shipping method for existing Extended Warranty flow
        if (orderRec.Type != null && (orderRec.Shipping_Method__c == null || orderRec.Shipping_Method__c == '') && orderRec.Asset__c == Null) {
            hasError = true;
        }
        if (!hasError) {
            orderRec.SendQuoteEmail__c = null;

            if (orderRec.AccountId != null && !String.isBlank(orderRec.Account.PersonEmail)) {
                orderRec.SendQuoteEmail__c = orderRec.Account.PersonEmail;
            } else if (orderRec.BillToContactId != null && orderRec.BillToContact.Email != null) {
                orderRec.SendQuoteEmail__c = orderRec.BillToContact.Email;
            }
            if (orderRec.SendQuoteEmail__c == null || orderRec.SendQuoteEmail__c == '') {
                return System.Label.Send_Quote_Pop_Up_Email_Message;
            }
            try {
                ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(orderRec.Id);
                system.debug('newChargentOrder*****'+ChargentPaymentTerminalExtnInstance.chargentOrder);
                ChargentOrders__ChargentOrder__c newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
                //newChargentOrder.ChargentOrders__Gateway__c='a1o290000005gV4';
                insert newChargentOrder;
                system.debug('newChargentOrder*****'+newChargentOrder.Id);
                ChargentOrders__Payment_Request__c newPaymentRequest = new ChargentOrders__Payment_Request__c();
                newPaymentRequest.ChargentOrders__Payment_Request_Transaction_Type__c = Label.Payment_Request_Type; // 'Charge Full Amount';
                newPaymentRequest.ChargentOrders__Billing_Contact__c = orderRec.BillToContactId;
                newPaymentRequest.ChargentOrders__ChargentOrder__c = newChargentOrder.Id;
                insert newPaymentRequest;
                
                system.debug('newPaymentRequest*****'+newPaymentRequest);
                orderRec.PaymentId__c = newPaymentRequest.Id;
                orderRec.SendQuote__c = true;
                update orderRec;
                system.debug('orderRec*******'+orderRec);
                return Label.Breville_Quotation_Sent_Message;
                
            } catch (Exception ex) {
                ErrorLog.LogErrorActivity(ex, 'Send Quote ', true, 'SendQuoteController Error', null, orderRec.Id, null);
                throw new AuraHandledException(ex.getMessage());
            }
        } else {
            throw new AuraHandledException('Please select Shipping Method');
        }
    }
    @AuraEnabled
    global static String handleCancelOrder(String recordId) {
        try {
            update new Order(
                Id = recordId,
                Status = 'Cancelled',
                Cancel_date__c = System.today(),
                ActivatedByPartner__c = false
            );
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    global static String handleCalculateRecalculate(String recordId) {
        try {
            OrderPriceCalculationUtility.calculatePriceUtility(recordId);
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    global class OrderDetailsWrapper {
        @AuraEnabled public object  Id {get;set;}
        @AuraEnabled public object  Name {get;set;}
        @AuraEnabled public object  Status {get;set;}
        @AuraEnabled public object  Source {get;set;}
        @AuraEnabled public object  Channel {get;set;}
        @AuraEnabled public object  Sent_to_AX {get;set;}
        @AuraEnabled public object  AccountType {get;set;}
        @AuraEnabled public object  RequestedShipDate {get;set;}
        @AuraEnabled public object  ActivatedDate  {get;set;}
        @AuraEnabled public object  BillToContactId {get;set;}
        @AuraEnabled public object  OrderCustomerType {get;set;}
        @AuraEnabled public object  Shipping_Method {get;set;}       
    }
}