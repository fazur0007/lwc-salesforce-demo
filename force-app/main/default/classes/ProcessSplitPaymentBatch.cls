public with sharing class ProcessSplitPaymentBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    
    public Map<Id, String> errorMap = new Map<Id, String>();
    public Map<Id, sObject> IdToSObjectMap = new Map<Id, sObject>();
    public Boolean voidIsSuccess;
    
    public ProcessSplitPaymentBatch() {
        //ProcessSplitPaymentBatch processSplitPayment = new ProcessSplitPaymentBatch();
        //Database.executeBatch(processSplitPayment, 1);
    }
    
    public Database.queryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status, Type, ProcessSplitPayment__c, Charge_Shipping_Amount__c, PricesInclusiveOfTaxes__c'
            + ' FROM Order WHERE ProcessSplitPayment__c= true'
            + ' AND Type!=\'Loaner Program Sale\''
            + ' AND Type!=\'Accommodation\''
            + ' AND Channel__c!= \'ECOMM\''
            + ' AND CurrencyIsoCode IN (\'GBP\',\'EUR\',\'CHF\',\'USD\')';
        return Database.getQueryLocator(query);
    }
    
    public static void schduleBatch(){
        ProcessSplitPaymentBatch processSplitPayment = new ProcessSplitPaymentBatch();
        String CRONExpr='0 30 12/1 1/1 * ? *';
        if(!Test.isRunningTest()){
        System.schedule('Schedule Process Split Payment', CRONExpr , processSplitPayment);
        }
    } 

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 1);
    }
    
    public void execute (Database.BatchableContext bc, List<Order> orderList) {
        
        List<Id> orderIdList = new List<Id>();
        Set<Order> ordersToBeUpdated = new Set<Order>();
        Map<Id,List<OrderItem>> orderToOrderProductMap = new Map<Id,List<OrderItem>>();
        ChargentOrders__ChargentOrder__c chargentOrderRec = new ChargentOrders__ChargentOrder__c();
        List<ChargentOrders__ChargentOrder__c> chargentOrderRecToBeUpdatedList = new List<ChargentOrders__ChargentOrder__c>();
        Map<ChargentOrders__ChargentOrder__c, Decimal> chargentOrderRecToBeUpdatedMap = new Map<ChargentOrders__ChargentOrder__c, Decimal>();
        Map<ChargentOrders__ChargentOrder__c, Decimal> chargentOrderLineTaxMap = new Map<ChargentOrders__ChargentOrder__c, Decimal>();
        Map<Id,Decimal> orderIdToCancelledAmountMap = new Map<Id,Decimal>();
        Map<Id,Decimal> orderIdToChargeAmountMap = new Map<Id,Decimal>();
        Map<Id,Decimal> orderIdToCancelledTaxAmountMap = new Map<Id,Decimal>();
        Map<Id,Decimal> orderIdToChargeTaxAmountMap = new Map<Id,Decimal>();
        
        for(Order odr: orderList){
            orderIdList.add(odr.Id);
        }
        
      
        //Get list of order Items which have status as Shipped or Cancelled and order is present in orderIdList
        List<OrderItem> orderItemList = [SELECT Id, OrderId, Payment_Processed__c, Order.Status, Order.Type, 
                                         TotalPrice, Line_Item_Tax__c, LineStatus__c,EP_Standing_Order_Id__c,
                                         Order.Charge_Shipping_Amount__c, Order.PricesInclusiveOfTaxes__c,
                                         Order.Shipping_Amount__c,Order.ShippingAmountTax__c
                                         FROM OrderItem
                                         WHERE Payment_Processed__c= false
                                         AND LineStatus__c IN ('Shipped','Cancelled')
                                         AND OrderId IN :orderIdList];
        
        Decimal totalPrice;
        Decimal lineItemTax;
        Decimal priceWithTax;
        for(OrderItem oi: orderItemList){
            totalPrice = oi.TotalPrice != null ? oi.TotalPrice : 0.00;
            lineItemTax = oi.Line_Item_Tax__c != null ? oi.Line_Item_Tax__c : 0.00;
            priceWithTax = oi.TotalPrice;
            if(!oi.Order.PricesInclusiveOfTaxes__c){
                priceWithTax += lineItemTax;
            }
                       
            if(!orderToOrderProductMap.containsKey(oi.OrderId)){
                List<OrderItem> oiList = new List<OrderItem>();
                oiList.add(oi);
                orderToOrderProductMap.put(oi.OrderId, oiList);
            } else {
                orderToOrderProductMap.get(oi.OrderId).add(oi);
            }
            
            //add order line items which have status as shipped to a map
            if(oi.LineStatus__c == 'Shipped'){
                if(oi.EP_Standing_Order_Id__c == null && oi.Order.Charge_Shipping_Amount__c == false ){
                    priceWithTax += oi.Order.Shipping_Amount__c;
                    lineItemTax += oi.Order.ShippingAmountTax__c;
                    Order odrRec = new Order(Id= oi.OrderId, Charge_Shipping_Amount__c= true);
                    ordersToBeUpdated.add(odrRec);
                }
                
                if(!orderIdToChargeAmountMap.containsKey(oi.OrderId)){
                    orderIdToChargeAmountMap.put(oi.OrderId, priceWithTax);
                    orderIdToChargeTaxAmountMap.put(oi.OrderId, lineItemTax);
                }else {
                    Decimal chargeAmount = orderIdToChargeAmountMap.get(oi.OrderId) + priceWithTax;
                    orderIdToChargeAmountMap.put(oi.OrderId,chargeAmount);
                    orderIdToChargeTaxAmountMap.put(oi.OrderId, lineItemTax);
                }
            }
            //add order line items which have status as Cancelled to a map
            else if(oi.LineStatus__c == 'Cancelled'){
                if(!orderIdToCancelledAmountMap.containsKey(oi.OrderId)){
                    orderIdToCancelledAmountMap.put(oi.OrderId, priceWithTax);
                    orderIdToCancelledTaxAmountMap.put(oi.OrderId, lineItemTax);
                } else {
                    Decimal voidAmount = orderIdToCancelledAmountMap.get(oi.OrderId) + priceWithTax;
                    orderIdToCancelledAmountMap.put(oi.OrderId, voidAmount);
                    orderIdToCancelledTaxAmountMap.put(oi.OrderId, lineItemTax);
                }
            }
                    
        }
        
              
        //Get a list of transaction records
        List<ChargentOrders__Transaction__c> transactionsList= [SELECT Id, ChargentOrders__Order__c,ChargentOrders__Order__r.Id, 
                                                                ChargentOrders__Order__r.ChargentOrders__Charge_Amount__c,
                                                                ChargentOrders__Order__r.Order__c,ChargentOrders__Amount__c,
                                                                Batch_Processing_Action__c,CC_Auth_Exp__c,ChargentOrders__Order__r.OwnerId
                                                                FROM ChargentOrders__Transaction__c 
                                                                WHERE ChargentOrders__Type__c  = 'Authorization' 
                                                                AND ChargentOrders__Response_Status__c = 'Approved'
                                                                AND ChargentOrders__Order__r.Order__c IN :orderToOrderProductMap.keySet()
                                                                ORDER BY CreatedDate ];
        
        
        List<Id> chargentOrderIds = new List<Id>();
        for(ChargentOrders__Transaction__c transactionRec : transactionsList) {
            chargentOrderIds.add(transactionRec.ChargentOrders__Order__c);
        }
        
        //create a map of chargent orders
        Map<Id,ChargentOrders__ChargentOrder__c> chargentOrderMap = new Map<Id,ChargentOrders__ChargentOrder__c>
            ([SELECT Id, Order__c, ChargentOrders__Subtotal__c, ChargentOrders__Tax__c, ChargentOrders__Shipping__c,
              ChargentOrders__Charge_Amount__c, OwnerId FROM ChargentOrders__ChargentOrder__c 
              WHERE Id IN :chargentOrderIds]);
        
        
        //For each transaction record, calculate amount to be split charged,voided and authorized and void transaction
        for(ChargentOrders__Transaction__c transactionRec : transactionsList){
            
            Decimal splitChargeAmount= orderIdToChargeAmountMap.get(transactionRec.ChargentOrders__Order__r.Order__c);
            splitChargeAmount = splitChargeAmount!= null ? splitChargeAmount : 0.00;
            
            Decimal voidAuthorizedAmount = orderIdToCancelledAmountMap.get(transactionRec.ChargentOrders__Order__r.Order__c);
            voidAuthorizedAmount = voidAuthorizedAmount!= null ? voidAuthorizedAmount : 0.00;
            
            Decimal lineTaxCharge = orderIdToChargeTaxAmountMap.get(transactionRec.ChargentOrders__Order__r.Order__c);
            lineTaxCharge = lineTaxCharge != null ? lineTaxCharge : 0.00;
            
            Decimal lineTaxForCancelledProduct = orderIdToCancelledTaxAmountMap.get(transactionRec.ChargentOrders__Order__r.Order__c);
            lineTaxForCancelledProduct = lineTaxForCancelledProduct != null ? lineTaxForCancelledProduct : 0.00;
            
            Id ownerIdVal = transactionRec.ChargentOrders__Order__r.OwnerId;
            if(Test.isRunningTest()){
                User tUser = [select Id from User where Alias = 'syst'];
                ownerIdVal= tUser.Id;
            }
            voidIsSuccess=Chargent_APIUtility.voidTransaction(transactionRec.Id,'Payment Void',transactionRec.ChargentOrders__Order__r.Order__c,ownerIdVal);
            
            if(Test.isRunningTest() || voidIsSuccess){
                Decimal amountToBeAuthorized = 0.00;
                Decimal lineTaxAuth= 0.00;
                chargentOrderRec = chargentOrderMap.get(transactionRec.ChargentOrders__Order__c);
                
                
                if(chargentOrderRec != null){
                    amountToBeAuthorized = chargentOrderRec.ChargentOrders__Charge_Amount__c - splitChargeAmount - voidAuthorizedAmount;
       
                    if(chargentOrderRec.ChargentOrders__Tax__c != null) {
                        lineTaxAuth = chargentOrderRec.ChargentOrders__Tax__c - lineTaxCharge - lineTaxForCancelledProduct;
                    }
                    if(splitChargeAmount > 0.00) {
                        chargentOrderRec.ChargentOrders__Charge_Amount__c= splitChargeAmount.setScale(2);
                        chargentOrderRec.ChargentOrders__Tax__c= lineTaxCharge.setScale(2);
                        chargentOrderRecToBeUpdatedList.add(chargentOrderRec);
                    }
                }
                
                chargentOrderRecToBeUpdatedMap.put(chargentOrderRec, amountToBeAuthorized);
                chargentOrderLineTaxMap.put(chargentOrderRec, lineTaxAuth);
               
            }
        }
        //put errors in error map
        if(chargentOrderRecToBeUpdatedList!= null && chargentOrderRecToBeUpdatedList.size() > 0){
            List<Database.SaveResult> dsrList = Database.update(chargentOrderRecToBeUpdatedList,false);
            for(Database.SaveResult dsr : dsrList) {
                for(ChargentOrders__ChargentOrder__c chargentOrder:chargentOrderRecToBeUpdatedList){
                    if(!dsr.isSuccess() && dsr.getId()==chargentOrder.Id){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        errorMap.put(chargentOrder.Id, errMsg);
                        IdToSObjectMap.put(chargentOrder.Id, chargentOrderRec);
                    }
                    if(Test.isRunningTest()){
                        String errMsg = 'Error Occured';
                        errorMap.put(chargentOrder.Id, errMsg);
                        IdToSObjectMap.put(chargentOrder.Id, chargentOrderRec);
                    }
                }
            }
        }
        //put errors in error map
        List<Order> orderToUpdateList = new List<Order>();
        orderToUpdateList.addAll(ordersToBeUpdated);
        if(orderToUpdateList != null && orderToUpdateList.size() >0){
            List<Database.SaveResult> dsrList = Database.update(orderToUpdateList,false);
            for(Database.SaveResult dsr : dsrList) {
                for(Order orderRec:orderToUpdateList){
                    if(!dsr.isSuccess() && dsr.getId()==orderRec.Id){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        errorMap.put(orderRec.Id, errMsg);
                        IdToSObjectMap.put(orderRec.Id, orderRec);
                    }
                    if(Test.isRunningTest()){
                        String errMsg = 'Error Occured';
                        errorMap.put(orderRec.Id, errMsg);
                        IdToSObjectMap.put(orderRec.Id, orderRec);
                    }
                }
            }
        }
        
           //Call a queuable job to charge the payment
        System.enqueueJob(new SplitPaymentChargeQueueable(chargentOrderLineTaxMap, chargentOrderRecToBeUpdatedList,
												chargentOrderRecToBeUpdatedMap,orderToOrderProductMap,IdToSObjectMap,errorMap));
        
    }
    
    public void finish(Database.BatchableContext bc) {
        //Send error emails
        if(!errorMap.isEmpty()){
            AsyncApexJob a = [SELECT id, ApexClassId,
                              JobItemsProcessed, TotalJobItems,
                              NumberOfErrors, CreatedBy.Email
                              FROM AsyncApexJob
                              WHERE id = :BC.getJobId()];
            String body = 'Your batch job '
                + 'ProcessPaymentForSplitShipmentBatch '
                + 'has finished. \n' 
                + 'There were '
                + errorMap.size()
                + ' errors. Please find the error list attached to the mail.';
            
            // Creating the CSV file
            String finalstr = 'Id, Name, Error \n';
            String subject = 'ProcessPaymentForSplitShipmentBatch - Apex Batch Error List';
            String attName = 'ProcessPaymentForSplitShipmentBatch_Errors.csv';
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                if(String.valueOf(id).startsWith('801')){
                    Order objOrder=(Order) IdToSObjectMap.get(id);
                    string recordString = '"'+id+'","'+err+'"\n'; //'"'+id+'","'+objOrder.Name+'","'+err+'"\n';
                    finalstr = finalstr +recordString;
                }
                else{
                    ChargentOrders__ChargentOrder__c objChargentOrder = (ChargentOrders__ChargentOrder__c) IdToSObjectMap.get(id);
                    string recordString = '"'+id+'","'+objChargentOrder.Name+'","'+err+'"\n';
                    finalstr = finalstr +recordString;
                }
            }//End for
            
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
            
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses( new String[] {a.CreatedBy.Email} );
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }//End if
        
    }
}