// status -> Selected from program ... 
//Order Create and Quote and update L N record.
public class OrderandQuoteCreationBatchForLoaner implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts,Database.Stateful{
    
    List<Loaner_Program__c>  loanerPgmVal = new List<Loaner_Program__c>();
    Map<Id,Order> paymentReqAndOrderMap=new Map<Id,Order>();
    Map<Id, Order> updatedLonaerNominationWithOrderMap=new Map<Id, Order>();
    list<Error_Log__c> errorLogs = new list<Error_Log__c>();
    Set<Id> orderIds=new Set<Id>();
    Set<String> loanerNomCurrency=new Set<String>();
    Map<String,String> currencyShippingMethodMap = new Map<String,String>();
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 20);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String shippingMethod = '';
        List<Region_Specific__mdt> ShippingMethodData = [SELECT DeveloperName, Currency__c,DefaultShippingMethod__c 
                                                         FROM Region_Specific__mdt];
        
        
        for(Region_Specific__mdt data:ShippingMethodData){
            currencyShippingMethodMap.put(data.Currency__c,data.DefaultShippingMethod__c);          
        }
        
        String loanerNmQuery='SELECT Id, Name, CurrencyIsoCode, Account__c,Account__r.Name,Account__r.PersonContact_SafeID__c,Account__r.PersonEmail, Email__c, Loaner_Program__c, Status__c, Country_Code__c,Loaner_Program__r.Product__c,'
            +'Street__c, City__c, State_Code__c, Postal_Code__c,Acceptance_Email_check__c ,Loaner_Program__r.PriceBook__c,Loaner_Program__r.Initial_Amount__c,Loaner_Program__r.ProgramName__c,Loaner_Program__r.PriceBookEntryId__c '
            +'FROM Loaner_Nomination__c  where Status__c = \'Selected for Program\'';
        return Database.getQueryLocator(loanerNmQuery);
    }
    
    public void execute(Database.BatchableContext BC,List<Loaner_Nomination__c> loanerNm){
        
        Map<Loaner_Nomination__c, Order> LoanerNmToOrderInsertMap = new Map<Loaner_Nomination__c, Order>();
        list<OrderItem> LPOrderItemListToInsert = new list<OrderItem>();
        
        Map<Id, Loaner_Nomination__c>  loanerPgmID = new Map<Id, Loaner_Nomination__c>();
        map<string, Id> PBEntryMap = new map<string, Id>();
        map<Id , Decimal> unitPriceMap = new map<Id , Decimal>();
        List<Loaner_Program__c>  loanerPgmVal = new List<Loaner_Program__c>();
        
        for(Loaner_Nomination__c loanerNom : loanerNm){ 
            Order orderRecord = new Order();
            orderRecord.AccountId = loanerNom.Account__r.Id;
            orderRecord.BillToContactId = loanerNom.Account__r.PersonContact_SafeID__c;
            orderRecord.Status = 'Open'; 						 
            orderRecord.Source__c = 'Breville';						
            orderRecord.Type = 'Loaner Program Sale' ;	
            
            orderRecord.Shipping_Method__c=currencyShippingMethodMap.get(loanerNom.CurrencyIsoCode);
            orderRecord.Brand__c = 'PolyScience';		
            orderRecord.EffectiveDate = Date.today();
            orderrecord.PriceBook2Id = loanerNom.Loaner_Program__r.PriceBook__c;	
            orderrecord.CurrencyIsoCode = loanerNom.CurrencyIsoCode;		
            
            orderRecord.BillingCity = loanerNom.city__c;					
            orderRecord.BillingCountryCode = loanerNom.Country_Code__c;		
            orderRecord.BillingPostalCode = loanerNom.Postal_Code__c;			
            orderRecord.BillingStateCode = loanerNom.State_Code__c;		
            orderRecord.BillingStreet = loanerNom.Street__c;				
            orderRecord.ShippingCountryCode = loanerNom.Country_Code__c;		
            orderRecord.ShippingCity = loanerNom.city__c;				
            orderRecord.ShippingPostalCode = loanerNom.Postal_Code__c;		
            orderRecord.ShippingStateCode =loanerNom.State_Code__c;		
            orderRecord.ShippingStreet = loanerNom.Street__c;				
            orderRecord.Ship_To_Name__c = loanerNom.Account__r.Name;						
            orderRecord.LoanerProgram__c  = loanerNom.Loaner_Program__c ;	
            orderRecord.Loaner_Nomination__c = loanerNom.Id;
            TaxRate taxRateRecord = new TaxRate();
            taxRateRecord.filterOrders(orderRecord);
            LoanerNmToOrderInsertMap.put(loanerNom, orderRecord);
            loanerPgmID.put(loanerNom.Loaner_Program__c,loanerNom);
            PBEntryMap.put(loanerNom.Loaner_Program__r.PriceBookEntryId__c, loanerNom.Loaner_Program__c); 
            
            
        }
        
        
        
        for(PricebookEntry pbe :[SELECT UnitPrice, Id, PBEntry_SafeID__c FROM PricebookEntry where
                                 PBEntry_SafeID__c IN :PBEntryMap.keySet()]){
                                     unitPriceMap.put(PBEntryMap.get(pbe.PBEntry_SafeID__c), pbe.UnitPrice);
                                 }
        try{
            if(LoanerNmToOrderInsertMap != null && LoanerNmToOrderInsertMap.size() > 0 ){
                Database.SaveResult[] OrdersResult = Database.insert(LoanerNmToOrderInsertMap.values(), false);
                for (Integer i = 0; i < LoanerNmToOrderInsertMap.values().size(); i++) {
                    
                    if (!OrdersResult[i].isSuccess()) {
                        Error_Log__c error =  ErrorLog.logErrorActivity('error while inserting  orders',
                                                                        'error while inserting  orders '+OrdersResult[i], 
                                                                        'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoanerError');
                        errorLogs.add(error); 
                        
                    }
                }
                for(Loaner_Nomination__c loanerNmOrderId : LoanerNmToOrderInsertMap.keySet()){
                    
                    Order orderRecordToInsert = LoanerNmToOrderInsertMap.get(loanerNmOrderId);
                    if(orderRecordToInsert!=null && orderRecordToInsert.LoanerProgram__c!=null){
                        
                        if(orderRecordToInsert.LoanerProgram__c == loanerNmOrderId.Loaner_Program__c){
                            OrderItem orderItemRecord = new OrderItem();
                            orderItemRecord.OrderId = orderRecordToInsert.id;
                            orderItemRecord.PriceBookEntryId = loanerNmOrderId.Loaner_Program__r.PriceBookEntryId__c; 
                            orderItemRecord.Quantity = 1;
                            orderItemRecord.UnitPrice = unitPriceMap.get(loanerNmOrderId.Loaner_Program__c);
                            LPOrderItemListToInsert.add(orderItemRecord);
                            orderIds.add(orderRecordToInsert.Id); 
                            
                        }    
                    } 
                }	
            }
            try{
                
                
                Database.SaveResult[] OrdersItemResult = Database.insert(LPOrderItemListToInsert, false);
                
                for (Integer i = 0; i < LPOrderItemListToInsert.size(); i++) {
                    if (!OrdersItemResult[i].isSuccess()) {
                        Error_Log__c error =  ErrorLog.logErrorActivity('error while inserting chargent orders',
                                                                        'error while inserting chargent orders '+OrdersItemResult[i], 
                                                                        'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoanerError');
                        errorLogs.add(error); 
                        
                        
                    }
                }
                
                /*To Fetch Tax from Order and Add it in Initial Amount for Quote generation */
                List<Order> ordersWithTax=[Select Id,Tax__c,Loaner_Nomination__c From Order where Id= :orderIds] ;
                for(Order order:ordersWithTax){
                    updatedLonaerNominationWithOrderMap.put(order.Loaner_Nomination__c,order);
                    
                }
                
                generateQuoteForOrders(LoanerNmToOrderInsertMap);
                
            }catch(Exception ex){
                
                Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
                                                               'error while inserting orders from OrderandQuoteCreationBatchForLoaner', 
                                                               'OrderandQuoteCreationBatchForLoaner method',false, 'OrderandQuoteCreationBatchForLoanerError');
                insert error;
            }
        }catch(Exception e){
            
            Error_Log__c error = ErrorLog.logErrorActivity(e.getMessage(),
                                                           'error while inserting orders items from OrderandQuoteCreationBatchForLoaner', 
                                                           'OrderandQuoteCreationBatchForLoaner-createOrder method',false, 'OrderandQuoteCreationBatchForLoanerError');
            insert error;
        }
    }
    public void finish(Database.BatchableContext bc){
        
    } 
    
    
    
    
    /*
* Description: Method Generating Quotes for orders created
* @author -Monali Jagtap 
* @since November 12, 2019
*/
    public void generateQuoteForOrders(Map<Loaner_Nomination__c, Order> LoanerNmToOrderInsertMap){
        List<Order> orders=LoanerNmToOrderInsertMap.values();
        Map<Order,ChargentOrders__ChargentOrder__c> orderAndChargentOrderMap=new Map<Order,ChargentOrders__ChargentOrder__c>();
        Map<Order,Loaner_Nomination__c> orderAndLoanernominationMap=new Map<Order,Loaner_Nomination__c>();
        
        Map<Id,String> NominationLoanerPgmName=new Map<Id,String>();
        Map<Order,ChargentOrders__Payment_Request__c> orderAndPaymentReqMap=new Map<Order,ChargentOrders__Payment_Request__c>();
        List<Loaner_Nomination__c> loanerNom=new List<Loaner_Nomination__c>();
        List<ChargentOrders__ChargentOrder__c> chargentOrders=new List<ChargentOrders__ChargentOrder__c>();
        List<Loaner_Nomination__c> loanerNomQuoteSentList=new List<Loaner_Nomination__c>();
        List<Order> orderUpdated=new List<Order>();
        List<Order> orderUpdatedWithPayLink=new List<Order>();
        List<ChargentOrders__Payment_Request__c> chargentPayment=new List<ChargentOrders__Payment_Request__c>();
        Decimal Tax=0;
        Set<Id> paymentRequestIds=new Set<Id>();
        
        for(Loaner_Nomination__c loanerNmOrder : LoanerNmToOrderInsertMap.keySet()){
            Order orderRec = LoanerNmToOrderInsertMap.get(loanerNmOrder);
            
            If(updatedLonaerNominationWithOrderMap.containsKey(loanerNmOrder.Id)){
                Order updatedOrd=updatedLonaerNominationWithOrderMap.get(loanerNmOrder.Id);
                Tax=updatedOrd.Tax__c;
            }
            
            if(orderRec!=null){
                Boolean hasError = false;
                if(orderRec.Type != null && (orderRec.Shipping_Method__c == null || orderRec.Shipping_Method__c == '')){
                    hasError = true;
                }
                if(!hasError){
                    
                    orderRec.SendQuoteEmail__c = null;
                    if(orderRec.AccountId  != null && !String.isBlank(loanerNmOrder.Account__r.PersonEmail)){
                        orderRec.SendQuoteEmail__c = loanerNmOrder.Account__r.PersonEmail;
                        
                    }else if(orderRec.BillToContactId != null && orderRec.BillToContact.Email != null){
                        orderRec.SendQuoteEmail__c = orderRec.BillToContact.Email;
                    }
                    
                    try{
                        ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(orderRec.Id);
                        ChargentOrders__ChargentOrder__c newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
                        
                        if(loanerNmOrder.Loaner_Program__r.Initial_Amount__c!=null){
                            newChargentOrder.ChargentOrders__Charge_Amount__c=loanerNmOrder.Loaner_Program__r.Initial_Amount__c;
                        }
                        
                        chargentOrders.add(newChargentOrder);
                        orderAndChargentOrderMap.put(orderRec,newChargentOrder);
                        
                        orderAndLoanernominationMap.put(orderRec,loanerNmOrder);
                        nominationLoanerPgmName.put(loanerNmOrder.Id, loanerNmOrder.Loaner_Program__r.ProgramName__c);
                        
                        
                        
                    }catch(Exception ex){
                        
                        Error_Log__c error =  ErrorLog.LogErrorActivity(ex, 'OrderandQuoteCreationBatchForLoaner',true,'generateQuoteForOrders Error',
                                                                        null,orderRec.Id,null);
                        errorLogs.add(error); 
                    }
                }else{
                    Error_Log__c error =  ErrorLog.logErrorActivity('Order Type or Shipping Method is Not available',
                                                                    'Order Type or Shipping Method not found ', 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoanerError');
                    errorLogs.add(error); 
                }
                
            }  
        } 
        
        //inserting chargent orders for created order
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
        
        
        //inserting chargentPayment for created order
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
        if(orders.size()>0){
            if(paymentRequestIds!=null){
                
                list<ChargentOrders__Payment_Request__c> chargentOrderPaymentRequest = [select ChargentOrders__Pay_Link__c, ChargentOrders__ChargentOrder__r.Order__r.Brand__c from
                                                                                        ChargentOrders__Payment_Request__c
                                                                                        where Id IN:paymentRequestIds];
                
                for(ChargentOrders__Payment_Request__c paymentreq:chargentOrderPaymentRequest){
                    
                    String payLinkForChargent='';
                    Order order=paymentReqAndOrderMap.get(paymentreq.ChargentOrders__ChargentOrder__c);
                    Loaner_Nomination__c loanerNomination=orderAndLoanernominationMap.get(order);
                    
                    String brand = paymentreq.ChargentOrders__ChargentOrder__r.Order__r.Brand__c;
                    if(brand == null || brand == ''){
                        brand = 'PolyScience';
                    }
                    
                    
                    String pgmName=nominationLoanerPgmName.get(loanerNomination.Id);
                    Id loanId=loanerNomination.Id;
                    
                    Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
                    string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',key, Blob.valueOf(loanId)));
                    string encodedId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
                    
                    payLinkForChargent = paymentreq.ChargentOrders__Pay_Link__c +'&brand=' +brand +'&pgm='+pgmName+'&id='+encodedId;
                    
                    
                    order.PaymentId__c = paymentreq.Id;
                    order.SendQuote__c = true;
                    orderUpdatedWithPayLink.add(order);
                    
                    loanerNomination.Status__c='Order Created-Quote Sent';
                    loanerNomination.Pay_Link__c=payLinkForChargent;
                    loanerNomination.Link_Expiration_date__c = System.now().adddays(Integer.valueOf(System.Label.Link_Expiration_date));
                    
                    loanerNomQuoteSentList.add(loanerNomination);
                    
                }
            }
        }
        
        //Updating order with payment request and pay link
        If(orderUpdatedWithPayLink!=null){
            Database.SaveResult[] orderUpdatedWithPayLinkResult = Database.update(orderUpdatedWithPayLink, false);
            for (Integer i = 0; i < orderUpdatedWithPayLink.size(); i++) {
                if (!orderUpdatedWithPayLinkResult[i].isSuccess()) {
                    
                    Error_Log__c error =  ErrorLog.logErrorActivity('error whileUpdating order with payment request',
                                                                    'Error--->'+orderUpdatedWithPayLinkResult[i], 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoaner');
                    
                }
            }
        }
        
        
        //Updating Loaner Nomination with status as Order Created-Quote Sent
        If(loanerNomQuoteSentList!=null){
            Database.SaveResult[] loanerNomQuoteSentListResult = Database.update(loanerNomQuoteSentList, false);
            for (Integer i = 0; i < loanerNomQuoteSentList.size(); i++) {
                if (!loanerNomQuoteSentListResult[i].isSuccess()) {
                    
                    Error_Log__c error =  ErrorLog.logErrorActivity('error while Updating Loaner Nomination',
                                                                    'Error--->'+loanerNomQuoteSentListResult[i], 
                                                                    'OrderandQuoteCreationBatchForLoaner-generateQuoteForOrders method',false, 'OrderandQuoteCreationBatchForLoaner');
                    
                    
                }
            }
        }
        
    }
    
    
}