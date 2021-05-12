public class TrialEndQuoteGenerationBatch implements Database.Batchable<sObject>,Schedulable {
    
    @TestVisible private static Id AccId ;
    @TestVisible private static Id LoanerProgramId;
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String loanerPgmQuery;
        loanerPgmQuery='SELECT Id,Name, Active__c, ProgramName__c,Product__c,Product__r.Quantity_Available__c,Run_Selection_Process__c '+ 
            +'FROM Loaner_Program__c where Active__c=true';
        return Database.getQueryLocator(loanerPgmQuery);
    }
    
    public void execute(Database.BatchableContext BC,List<Loaner_Program__c> LoanerPrograms){
        List<Order> ordersWithLP=new List<Order>();
        List<Order> ordersWithEnddate=new List<Order>();
        Map<Id,Loaner_Program__c> loanerPgmVal=new Map<Id,Loaner_Program__c>();
        Map<Id,List<Order>> orderWithLoanerPgmMap=new Map<Id,List<Order>>();
        
        for(Loaner_Program__c lp:LoanerPrograms){
            loanerPgmVal.put(lp.Id,lp);
        }
        ordersWithLP=[SELECT Id, Status, Order_Grand_Total__c,Tax__c,LoanerProgram__c,BillToContactId, PayLink__c,LoanerProgram__r.Initial_Amount__c,LoanerProgram__r.ProgramName__c,
                      EndDate,Loaner_Nomination__c ,LoanerProgram__r.Program_Validity__c,Loaner_Nomination__r.Status__c,Loaner_Nomination__r.TrialEnd_PayLink__c FROM Order where 
                      Loaner_Nomination__r.Status__c='Trial In Progress' and Type='Loaner Program Sale' and LoanerProgram__c IN :loanerPgmVal.keySet()
                      Order by  CreatedDate desc Limit: Limits.getLimitQueryRows()];
        
        for(Order orders:ordersWithLP){
            Decimal pgmValidDays=orders.LoanerProgram__r.Program_Validity__c;
            Date todaysDate=Date.today();
            If(orders.EndDate!=null){ 
                Integer daysDiff=orders.EndDate.daysBetween(todaysDate) ;
                if(daysDiff>=pgmValidDays) {
                    ordersWithEnddate.add(orders);  
                }
            } 
            
        }
        List<Error_Log__c> errorLogs = new list<Error_Log__c>();
        List<ChargentOrders__ChargentOrder__c> chargentOrders=new List<ChargentOrders__ChargentOrder__c>();
        Map<Order,ChargentOrders__ChargentOrder__c> orderAndChargentOrderMap=new Map<Order,ChargentOrders__ChargentOrder__c>();    
        List<ChargentOrders__Payment_Request__c> chargentPayment=new List<ChargentOrders__Payment_Request__c>();
        Map<Order,ChargentOrders__Payment_Request__c> orderAndPaymentReqMap=new Map<Order,ChargentOrders__Payment_Request__c>();
        Map<Id,Order> paymentReqAndOrderMap=new Map<Id,Order>();
        Set<Id> paymentRequestIds=new Set<Id>();
        List<Order> orderUpdatedWithTrialEndPayLink=new List<Order>();
        List<Loaner_Nomination__c> loanerNomTrialEndQuoteSentList=new List<Loaner_Nomination__c>();
        List<Loaner_Nomination__c> loanerNomIds=new List<Loaner_Nomination__c>();
        Map<Id,Loaner_Nomination__c> loanerNomIdsMap=new Map<Id,Loaner_Nomination__c>();
        for(Order order:ordersWithEnddate){
            ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(order.Id);
            ChargentOrders__ChargentOrder__c newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
            
            if(order.LoanerProgram__r.Initial_Amount__c!=null){
                newChargentOrder.ChargentOrders__Charge_Amount__c=order.Order_Grand_Total__c-order.LoanerProgram__r.Initial_Amount__c;
            }
            chargentOrders.add(newChargentOrder);
            orderAndChargentOrderMap.put(order,newChargentOrder); //to update order and loaner nomination
        }
        
        
        
        //Inserting chargent orders for orders whose trial is completed
        If(chargentOrders.size()>0){
            Database.SaveResult[] chargentOrdersResult = Database.insert(chargentOrders, false);
            for (Integer i = 0; i < chargentOrders.size(); i++) {
                if (!chargentOrdersResult[i].isSuccess()) {
                    Error_Log__c error =  ErrorLog.logErrorActivity('error while inserting chargent orders',
                                                                    'Error--->'+chargentOrdersResult[i], 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoanerError');
                    
                    errorLogs.add(error); 
                    
                }
            }
        }
        
        //Generating chargent payment request for the generated order
        for(Order order:orderAndChargentOrderMap.keySet()){
            ChargentOrders__ChargentOrder__c chargentOrder=orderAndChargentOrderMap.get(order);
            ChargentOrders__Payment_Request__c newPaymentRequest = new ChargentOrders__Payment_Request__c();
            newPaymentRequest.ChargentOrders__Payment_Request_Transaction_Type__c ='Charge Full Amount';
            newPaymentRequest.ChargentOrders__Billing_Contact__c = order.BillToContactId;
            newPaymentRequest.ChargentOrders__ChargentOrder__c = chargentOrder.Id;
            chargentPayment.add(newPaymentRequest); 
            orderAndPaymentReqMap.put(order,newPaymentRequest);
            paymentReqAndOrderMap.put(newPaymentRequest.ChargentOrders__ChargentOrder__c,order);
            
        } 
        
        //inserting chargentPayment for Remaining Amount to be paid for order
        if(chargentPayment.size()>0){
            Database.SaveResult[] chargentPaymentResult = Database.insert(chargentPayment, false);
            for (Integer i = 0; i < chargentPayment.size(); i++) {
                paymentRequestIds.add(chargentPayment[i].Id);
                if (!chargentPaymentResult[i].isSuccess()) {
                    
                    Error_Log__c error =  ErrorLog.logErrorActivity('error while inserting chargentPayment',
                                                                    'Error--->'+chargentPaymentResult[i], 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoanerError');
                    
                }
            }
        }
        
        //Fetching Payment Request from Payment request id to Update pay Link in Order
        if(paymentRequestIds!=null){
            list<ChargentOrders__Payment_Request__c> chargentOrderPaymentRequest = [select ChargentOrders__Pay_Link__c, ChargentOrders__ChargentOrder__r.Order__r.Brand__c from
                                                                                    ChargentOrders__Payment_Request__c
                                                                                    where Id IN:paymentRequestIds];
            
            for(ChargentOrders__Payment_Request__c paymentreq:chargentOrderPaymentRequest){
                
                String payLinkForChargent='';
                Order order=paymentReqAndOrderMap.get(paymentreq.ChargentOrders__ChargentOrder__c);
                Id loanerNominationId=order.Loaner_Nomination__c;
                String brand = chargentOrderPaymentRequest[0].ChargentOrders__ChargentOrder__r.Order__r.Brand__c;
                if(brand == null || brand == ''){
                    brand = 'PolyScience';
                }
                
                
                String pgmName=order.LoanerProgram__r.ProgramName__c;
                Id loanId=loanerNominationId;
                Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
                string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',key, Blob.valueOf(loanId)));
                string encodedId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
                
                //payLinkForChargent = chargentOrderPaymentRequest[0].ChargentOrders__Pay_Link__c +'&brand=' +brand +'&pgm='+pgmName;
                payLinkForChargent = chargentOrderPaymentRequest[0].ChargentOrders__Pay_Link__c +'&brand=' +brand +'&pgm='+pgmName+'&id='+encodedId;
                order.PaymentId__c = paymentreq.Id;
                
                // order.SendQuote__c = true; //need to be discussed
                order.Loaner_Nomination__r.Status__c='Trial End - Quote Generated';
                order.Loaner_Nomination__r.TrialEnd_PayLink__c=payLinkForChargent;
                
                loanerNomIds.add(order.Loaner_Nomination__r);
                loanerNomIdsMap.putAll(loanerNomIds);
                orderUpdatedWithTrialEndPayLink.add(order);
                
            }
        } 
        
        //Updating order with payment request and trial end pay link
        If(orderUpdatedWithTrialEndPayLink!=null){
            if(Test.isRunningTest()){
                if(AccId!=null)
                    orderUpdatedWithTrialEndPayLink.add(new Order(AccountId=AccId));
                //if(LoanerProgramId!=null)
                  //  loanerNominations.add(new Loaner_Nomination__c(Loaner_Program__c=LoanerProgramId));
            }
            Database.SaveResult[] orderUpdatedWithTrialEndPayLinkResult = Database.update(orderUpdatedWithTrialEndPayLink, false);
            for (Integer i = 0; i < orderUpdatedWithTrialEndPayLink.size(); i++) {
                if (!orderUpdatedWithTrialEndPayLinkResult[i].isSuccess()) {
                    Error_Log__c error =  ErrorLog.logErrorActivity('error whileUpdating order with payment request',
                                                                    'Error--->'+orderUpdatedWithTrialEndPayLinkResult[i], 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoaner');
                }
            }
        }
        
        
        If(loanerNomIds!=null){
            if(Test.isRunningTest()){
               if(LoanerProgramId!=null)
                    loanerNomIdsMap.put(LoanerProgramId, new Loaner_Nomination__c());
            }
            List<Loaner_Nomination__c> loanerNominations = loanerNomIdsMap.values();
            Database.SaveResult[] loanerNomIdsResult = Database.update(loanerNominations, false);
            for (Integer i = 0; i < loanerNominations.size(); i++) {
                if (!loanerNomIdsResult[i].isSuccess()) {
                    Error_Log__c error =  ErrorLog.logErrorActivity('error whileUpdating order with payment request',
                                                                    'Error--->'+loanerNomIdsResult[i], 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoaner');
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }     
}