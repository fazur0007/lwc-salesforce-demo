public class OrderTriggerHandler {
    
    public static boolean beforeTriggerRun = true;
    public static boolean afterTriggerRun = true;
    public static boolean runPopulateAXAccountNumber = true;
    
    public static boolean runOnceBeforeTrigger(){
        if(beforeTriggerRun){
            beforeTriggerRun = false;
            return true;
        }else{
            return beforeTriggerRun;
        }
    }
    
    
    public static boolean runOnceAfterTrigger(){
        if(afterTriggerRun){
            afterTriggerRun = false;
            return true;
        }else{
            return afterTriggerRun;
        }
    }
    
    //Shipping amount will be calculated in this method
    //Auth amount calculated will be updated by adding shipping method in this method
    public static void updateShippingAmount(list<Order> newOrderList, map<Id, Order> orderMap){
        
        //Employee sale orders with respective region code
        map<String, list<Order>> regionToEmployeeSaleOrdersMap = new Map<String, list<Order>>();
        map<String, list<Order>> regionToOtherSalesOrderMap = new Map<String, list<Order>>();
        Set<String> currecnyISOCodeSet = new Set<String>();
        Set<String> shippingMethodSet = new Set<String>();
        set<Id> accountIdSet = new set<Id>();  
        list<Account> accountList = new list<Account>();
        
        for(Order orderRec : newOrderList){
            if(orderRec != null && orderRec.Channel__c != 'ECOMM'){
                accountIdSet.add(orderRec.AccountId);
            }
        }
        
        map<Id, Account> accountIdAccountMap = new map<Id, Account>([SELECT Id, PO_Box_APO_Foreign__c FROM Account WHERE Id IN :accountIdSet AND PO_Box_APO_Foreign__c = true]);
        
        for(Order orderRec : newOrderList){
            
            if(orderRec.Channel__c == 'ECOMM'){ 
                continue;
            }
            //code added by Nikhil to populate Shipping method
            if(orderRec.AccountId != null && accountIdAccountMap != null && accountIdAccountMap.size() > 0 && accountIdAccountMap.containsKey(orderRec.AccountId) 
               && (orderRec.Shipping_Method__c == null || (orderRec.Shipping_Method__c != null && orderRec.Shipping_Method__c == ''))){
                   orderRec.Shipping_Method__c = 'EMPLOYEE PICKUP';
               }
            
            //code added by Tapan to populate Advanced Shippping check box
            if(orderRec.Type != null && orderRec.Type.equalsIgnoreCase('Accommodation') 
               && orderRec.CC_Authorization_ID__c != null && orderRec.AdvanceShippingStatus__c == null ){
                   orderRec.AdvanceShippingStatus__c = 'Advance Shipping Placed';
                   orderRec.AdvanceShippingAuthDate__c = Datetime.now();
               }
            if(orderRec.Type != null && (orderRec.Type.equalsIgnoreCase('Sample')|| (orderRec.Type.equalsIgnoreCase('Employee Sale') && orderRec.deliver_Breville_Office__c == true) && 
                                         (orderRec.Shipping_Method__c == null || orderRec.Shipping_Method__c == ''))){
                                             orderRec.Shipping_Method__c = 'EMPLOYEE PICKUP';
                                         }
            if(Trigger.isInsert || (Trigger.isUpdate 
                                    && (orderRec.CC_Authorization_Amount__c != orderMap.get(orderRec.Id).CC_Authorization_Amount__c
                                        || orderRec.Complimentary_Shipping__c != orderMap.get(orderRec.Id).Complimentary_Shipping__c
                                        || orderRec.Shipping_Method__c != orderMap.get(orderRec.Id).Shipping_Method__c
                                        || orderRec.OverrideShippingAmount__c != orderMap.get(orderRec.Id).OverrideShippingAmount__c))){
                                            if(orderRec.Complimentary_Shipping__c){
                                                orderRec.Shipping_Amount__c = 0;
                                            }else if(orderRec.OverrideShippingAmount__c){
                                                orderRec.CC_Authorization_Amount__c += orderRec.Shipping_Amount__c;
                                                orderRec.CC_Authorization_Amount__c = orderRec.CC_Authorization_Amount__c.round(System.RoundingMode.HALF_DOWN);
                                            }else if(orderRec.Source__c != null && orderRec.Source__c.equalsIgnoreCase('Breville') &&  orderRec.Type != null && 
                                                     orderRec.Type.equalsIgnoreCase('Employee Sale') && orderRec.Shipping_Method__c != null){
                                                         orderRec.Shipping_Amount__c = 0;            
                                                         currecnyISOCodeSet.add(orderRec.currencyISOCode);
                                                         if(regionToEmployeeSaleOrdersMap.containsKey(orderRec.currencyISOCode)){
                                                             regionToEmployeeSaleOrdersMap.get(orderRec.currencyISOCode).add(orderRec);
                                                         }else{
                                                             regionToEmployeeSaleOrdersMap.put(orderRec.currencyISOCode, new list<Order>{orderRec});
                                                         }
                                                     }else if(orderRec.Type != null && (orderRec.Type.equalsIgnoreCase('Sale') || orderRec.Type.equalsIgnoreCase('Employee Sale') 
                                                                                        || orderRec.Type.equalsIgnoreCase('Retail Employee Sales') || orderRec.Type.equalsIgnoreCase('Partner & Associate Sales') 
                                                                                        || orderRec.Type.equalsIgnoreCase('Retail Event Sales') || orderRec.Type.equalsIgnoreCase('Holiday Promo') 
                                                                                        || orderRec.Type.equalsIgnoreCase('Event Sales Coffee') || orderRec.Type.equalsIgnoreCase('Specialty Roaster'))) {
                                                                                            if(orderRec.Shipping_Method__c != null && orderRec.Shipping_Method__c != ''){
                                                                                                orderRec.Shipping_Amount__c = 0;
                                                                                                currecnyISOCodeSet.add(orderRec.currencyISOCode);
                                                                                                shippingMethodSet.add(orderRec.Shipping_Method__c);
                                                                                                if(regionToOtherSalesOrderMap.containsKey(orderRec.currencyISOCode)){
                                                                                                    regionToOtherSalesOrderMap.get(orderRec.currencyISOCode).add(orderRec);
                                                                                                }else{
                                                                                                    regionToOtherSalesOrderMap.put(orderRec.currencyISOCode, new list<Order>{orderRec});
                                                                                                }
                                                                                            }
                                                                                        }
                                        }
        }
        
        if(currecnyISOCodeSet != null && currecnyISOCodeSet.size() > 0){
            
            Map<String, Map<String, Double>> currecnyCodeToEmployeeShippingAmount = new Map<String, map<String, Double>>();
            //Map<String, Map<String, ShippingAmount__c>> currecnyToSalesTypeAmountMap = new Map<String, Map<String, ShippingAmount__c>>();
            Map<String, Map<String, List<ShippingAmount__c>>> currecnyToOrderType_ShipMethodToShipAmountMap = new Map<String, Map<String, List<ShippingAmount__c>>>();
            String query = 'SELECT CurrencyIsoCode, ShippingAmount__c, Shipping_Method__c, MaxAmount__c, ShippingChargeAlwaysApplicable__c, OrderType__c ' +
                ' FROM ShippingAmount__c ' +
                ' WHERE currencyISOCode IN: currecnyISOCodeSet ';
            if(shippingMethodSet != null && shippingMethodSet.size() > 0){
                query += ' AND (OrderType__c = \'Employee Sale\' '
                    + 'OR (OrderType__c IN (\'Sale\', \'Retail Employee Sales\', \'Partner & Associate Sales\', \'Retail Event Sales\', \'Holiday Promo\', \'Specialty Roaster\', \'Event Sales Coffee\') AND Shipping_Method__c IN: shippingMethodSet)) ';
            }else{
                query += ' AND OrderType__c = \'Employee Sale\'';
            }
            for(ShippingAmount__c shippingAmount : Database.query(query)){
                String OrderType_ShippingMethod = shippingAmount.OrderType__c + '_' +shippingAmount.Shipping_Method__c;
                
                if(shippingAmount.OrderType__c.equalsIgnoreCase('Employee Sale')){// && shippingAmount.Shipping_Method__c.equalsIgnoreCase('EMPLOYEE PICKUP')){
                    if(currecnyCodeToEmployeeShippingAmount.containsKey(shippingAmount.CurrencyIsoCode)){
                        currecnyCodeToEmployeeShippingAmount.get(shippingAmount.CurrencyIsoCode).put(shippingAmount.Shipping_Method__c.toUpperCase(),
                                                                                                     shippingAmount.ShippingAmount__c);
                    }else{
                        currecnyCodeToEmployeeShippingAmount.put(shippingAmount.CurrencyIsoCode, 
                                                                 new map<String, Double>{shippingAmount.Shipping_Method__c.toUpperCase() => shippingAmount.ShippingAmount__c});
                    }
                }else if(shippingAmount.OrderType__c.equalsIgnoreCase('Sale') || shippingAmount.OrderType__c.equalsIgnoreCase('Employee Sale')
                         || shippingAmount.OrderType__c.equalsIgnoreCase('Retail Employee Sales')
                         || shippingAmount.OrderType__c.equalsIgnoreCase('Partner & Associate Sales')
                         || shippingAmount.OrderType__c.equalsIgnoreCase('Retail Event Sales')
                         || shippingAmount.OrderType__c.equalsIgnoreCase('Event Sales Coffee')
                         || shippingAmount.OrderType__c.equalsIgnoreCase('Holiday Promo')
                         || shippingAmount.OrderType__c.equalsIgnoreCase('Specialty Roaster')){
                             if(currecnyToOrderType_ShipMethodToShipAmountMap.containsKey(shippingAmount.CurrencyIsoCode)){
                                 if(currecnyToOrderType_ShipMethodToShipAmountMap.get(shippingAmount.CurrencyIsoCode).containsKey(OrderType_ShippingMethod)){
                                     currecnyToOrderType_ShipMethodToShipAmountMap.get(shippingAmount.CurrencyIsoCode).get(OrderType_ShippingMethod.toUpperCase()).add(shippingAmount);
                                 } else {
                                     currecnyToOrderType_ShipMethodToShipAmountMap.get(shippingAmount.CurrencyIsoCode).put(OrderType_ShippingMethod.toUpperCase(), new List<ShippingAmount__c>{shippingAmount});
                                 }
                             }else{
                                 currecnyToOrderType_ShipMethodToShipAmountMap.put(shippingAmount.CurrencyIsoCode,
                                                                                   new map<String, List<ShippingAmount__c>>{OrderType_ShippingMethod.toUpperCase() => new List<ShippingAmount__c>{shippingAmount}});
                             }
                         }                                               
            }
            
            
            if(currecnyCodeToEmployeeShippingAmount != null && currecnyCodeToEmployeeShippingAmount.size() > 0){
                for(String currencyCode : regionToEmployeeSaleOrdersMap.keySet()){
                    if(currecnyCodeToEmployeeShippingAmount.containsKey(currencyCode)){
                        for(Order orderRec : regionToEmployeeSaleOrdersMap.get(currencyCode)){
                            if(currecnyCodeToEmployeeShippingAmount.get(currencyCode).containsKey(orderRec.Shipping_Method__c.toUpperCase())){
                                orderRec.Shipping_Amount__c = currecnyCodeToEmployeeShippingAmount.get(currencyCode).get(orderRec.Shipping_Method__c.toUpperCase());
                                orderRec.CC_Authorization_Amount__c += orderRec.Shipping_Amount__c;
                            }
                        }
                    }
                }
            }
            if(currecnyToOrderType_ShipMethodToShipAmountMap != null && currecnyToOrderType_ShipMethodToShipAmountMap.size() > 0){
                for(String currencyCode : regionToOtherSalesOrderMap.keySet()){
                    if(currecnyToOrderType_ShipMethodToShipAmountMap.containsKey(currencyCode)){
                        for(Order orderRec : regionToOtherSalesOrderMap.get(currencyCode)){
                            String OrderType_ShippingMethod = orderRec.Type + '_' + orderRec.Shipping_Method__c;
							if(orderRec.Brand__c=='Beanz' && orderRec.Source__c!='ECOMM')
                            {                                
                                orderRec.Shipping_Amount__c = Decimal.Valueof([select value__c from Beanz_setting__mdt where developername='Beanz_US_Shipping_Charge'].value__c);// 7.50;
                            }
                            else
                            {
								if(orderRec.Source__c != 'GWP'){
									if(orderRec.TotalAmount != null && currecnyToOrderType_ShipMethodToShipAmountMap.get(currencyCode).containsKey(OrderType_ShippingMethod.toUpperCase())){ 
										List<ShippingAmount__c> shipAmountList = currecnyToOrderType_ShipMethodToShipAmountMap.get(currencyCode).get(OrderType_ShippingMethod.toUpperCase());
										if(shipAmountList != null && shipAmountList.size() >0 ){
											for(ShippingAmount__c sa : shipAmountList) {
												//if(OrderType_ShippingMethod.equalsIgnoreCase(orderRec.Type + '_' + orderRec.Shipping_Method__c)) {
												if(sa.ShippingChargeAlwaysApplicable__c) {
													orderRec.Shipping_Amount__c = sa.ShippingAmount__c;
												} else if(orderRec.TotalAmount < sa.MaxAmount__c){
													orderRec.Shipping_Amount__c = sa.ShippingAmount__c;
												} else{
													orderRec.Shipping_Amount__c = 0;
												}
												//}
											}
										}
									}else{
										orderRec.Shipping_Amount__c = 0;
									}
									
								}else if(orderRec.Source__c == 'GWP'){
									orderRec.Shipping_Amount__c = 0;
								}
							}	
                            orderRec.CC_Authorization_Amount__c += orderRec.Shipping_Amount__c;
                            orderRec.CC_Authorization_Amount__c = orderRec.CC_Authorization_Amount__c.round(System.RoundingMode.HALF_DOWN);
                        }
                    }
                }
            }
        }
    }
    
    //Update InclusiveofTaxes for B2B accounts orders
    public static void updateInclusiveOfTaxesForB2BOrders(list<Order> orderlist, map<Id, Order> OldOrderMap){
        Set<Id> accountIdsSet = new Set<Id>();
        List<Order> ordersWithInclusiveOfTaxes = new list<Order>(); 
        for(Order orderRec : orderlist){
            if(orderRec.PricesInclusiveOfTaxes__c && orderRec.AccountId != null 
               && (Trigger.isInsert || (Trigger.isUpdate && orderRec.AccountId != OldOrderMap.get(orderRec.Id).AccountId))){
                   ordersWithInclusiveOfTaxes.add(orderRec);
                   accountIdsSet.add(orderRec.AccountId);
               }
        }
        
        if(ordersWithInclusiveOfTaxes != null && ordersWithInclusiveOfTaxes.size() > 0 && accountIdsSet != null && accountIdsSet.size() > 0){
            Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            Set<Id> b2bAccountIds = new Set<Id>();
            for(Account account : [SELECT Id FROM Account WHERE Id IN: accountIdsSet AND RecordTypeId =: businessAccountRecordTypeId]){
                b2bAccountIds.add(account.Id);
            }
            
            if(b2bAccountIds != null && b2bAccountIds.size() > 0){
                for(Order OrderRecord : ordersWithInclusiveOfTaxes){
                    if(b2bAccountIds.contains(OrderRecord.AccountId)){
                        OrderRecord.PricesInclusiveOfTaxes__c = false;
                    }
                }
            }
        }
    }
    
    //Addition of shipping amount will be done in shipping calculation method
    public static void populateCCAuthroizationAmount(list<Order> orderList){
        for(Order orderRec : orderList){
            if(orderRec.Type != null && orderRec.Type.equalsIgnoreCase('Sample')){
                orderRec.CC_Authorization_Amount__c = 0;
            }else if(orderRec.Type != null && !orderRec.Type.equalsIgnoreCase('Accommodation')){
                orderRec.CC_Authorization_Amount__c = (orderRec.TotalAmount != null ? orderRec.TotalAmount : 0);
                if(orderRec.Tax__c != null && !orderRec.PricesInclusiveOfTaxes__c ){
                    orderRec.CC_Authorization_Amount__c += orderRec.Tax__c;
                }
            }                    
        }
    }
    
    /*method to populate AX Account Number on Order based on Brand, Order Type, Region and Currency*/
    public static void populateAXAccountNumber(list<Order> orderList, map<Id, Order> oldMap){
        
        /*set and map to bulkify code*/
        Set<String> brandSet = new Set<String>();
        Set<String> typeSet = new Set<String>();
        Set<String> currencySet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<String, AXAccountNumbers__mdt> keyToAccountNumberMap = new Map<String, AXAccountNumbers__mdt>();
        List<Order> newOrderList = new List<Order>();
        Set<Id> workOrderIdSet = new Set<Id>();
        Map<Id, Boolean> workOrderHasPayment = new Map<Id, Boolean>();
        list<Order> partnerOrders = new list<Order>();
        map<String, String> roleNameToAxAccountNumber = new map<String, String>();
        User currentUserRecord = [SELECT UserRole.Name, Profile.Name FROM User WHERE Id = :UserInfo.getuserId()];
        String roleName = currentUserRecord.UserRole.Name;
        
        for(AX_Account_Number_for_Partners__mdt masterData : [SELECT AxAccountNumber__c, RoleName__c FROM AX_Account_Number_for_Partners__mdt]){
            roleNameToAxAccountNumber.put(masterData.RoleName__c, masterData.AxAccountNumber__c);
        }
        
        
        /*iterating Orders to create Sets*/
        if(orderList != null && orderList.size() > 0){
            for(Order orderRecord : orderList){
                if(((Trigger.isInsert && orderRecord.Channel__c != 'ECOMM') || 
                    (Trigger.isUpdate && orderRecord.Channel__c != 'ECOMM' && (orderRecord.ShippingCountryCode != oldMap.get(orderRecord.Id).ShippingCountryCode ||
                                                                               orderRecord.Brand__c != oldMap.get(orderRecord.Id).Brand__c ||
                                                                               orderRecord.Type != oldMap.get(orderRecord.Id).Type ||
                                                                               orderRecord.Recall_Fasttrack__c != oldMap.get(orderRecord.Id).Recall_Fasttrack__c || 
                                                                               orderRecord.CurrencyIsoCode != oldMap.get(orderRecord.Id).CurrencyIsoCode ||
                                                                               orderRecord.RMItems__c != oldMap.get(orderRecord.Id).RMItems__c))) 
                   && (!roleNameToAxAccountNumber.keySet().contains(roleName))
                   && orderRecord.OverrideAXAccNum__c == false){
                       
                       if(orderRecord.Brand__c != null && orderRecord.Brand__c != ''){
                           brandSet.add(orderRecord.Brand__c);
                       }
                       if(orderRecord.Type != null && orderRecord.Type != ''){
                           typeSet.add(orderRecord.Type);
                       }
                       if(orderRecord.CurrencyIsoCode != null && orderRecord.CurrencyIsoCode != ''){
                           currencySet.add(orderRecord.CurrencyIsoCode);
                       }
                       if(orderRecord.AccountId != null){
                           accountIdSet.add(orderRecord.AccountId);
                       }
                       if(orderRecord.ServiceOrder__c != null && orderRecord.Type.equalsIgnoreCase('Repair Replacement')){
                           workOrderIdSet.add(orderRecord.ServiceOrder__c);
                       }
                       newOrderList.add(orderRecord);
                   }else if(roleNameToAxAccountNumber.keySet().contains(roleName)){
                       partnerOrders.add(orderRecord);
                   }
            }
        }
        if(workOrderIdSet != null && workOrderIdSet.size() > 0){
            for(WorkOrder workOrder : [SELECT Id, CC_Authorization_ID__c FROM WorkOrder WHERE Id IN: workOrderIdSet]){
                Boolean hasPayment = false;
                if(workOrder.CC_Authorization_ID__c != null && workOrder.CC_Authorization_ID__c != ''){
                    hasPayment = true;
                }
                workOrderHasPayment.put(workOrder.Id, hasPayment);
            }
        }
        
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        map<Id, Account> idToAccountMap = new map<Id, Account>([SELECT Id, RecordTypeId, VendAccount__c FROM Account WHERE Id IN :accountIdSet 
                                                                AND RecordTypeId = :businessAccountRecordTypeId]);
        /*Iterating metadata and creating key and map*/
        list<AXAccountNumbers__mdt> accountNumbersList = [SELECT AccountNumber__c, Brand__c, HasRefurbish__c, Currency__c, Type__c, HasPayment__c,
                                                          RecallAXAccountNumber__c, Country_Code__c,Source__c
                                                          FROM AXAccountNumbers__mdt
                                                          WHERE Brand__c IN :brandSet 
                                                          AND Currency__c IN :currencySet 
                                                          AND Type__c IN :typeSet 
                                                          AND OrderOrWorkOrder__c = 'Order'];
        if(accountNumbersList != null && accountNumbersList.size() > 0){
            for(AXAccountNumbers__mdt accountNumberRecord : accountNumbersList){
                String key = '';
                if(accountNumberRecord.Brand__c != null && accountNumberRecord.Brand__c != ''){
                    key = key +accountNumberRecord.Brand__c;
                }
                if(accountNumberRecord.Type__c != null && accountNumberRecord.Type__c != ''){
                    key = key +accountNumberRecord.Type__c;
                }
                if(accountNumberRecord.Currency__c != null && accountNumberRecord.Currency__c != ''){
                    key = key +accountNumberRecord.Currency__c;
                }
                if(accountNumberRecord.HasRefurbish__c != null){
                    key = key +accountNumberRecord.HasRefurbish__c;
                }
                if(accountNumberRecord.Type__c != null && accountNumberRecord.Type__c.equalsIgnoreCase('Repair Replacement')){
                    key = key +accountNumberRecord.HasPayment__c;
                }
                if(String.isNotBlank(accountNumberRecord.Country_Code__c) && accountNumberRecord.Currency__c.equalsIgnoreCase('EUR')){
                    key = key +accountNumberRecord.Country_Code__c;
                    if(String.isNotBlank(accountNumberRecord.Source__c) && accountNumberRecord.Source__c.equalsIgnoreCase('GWP')){
                        key = key + accountNumberRecord.Source__c;
                    }
                }
                keyToAccountNumberMap.put(key.toUpperCase(), accountNumberRecord);
            }
        }                    
        
        /*iterating Orders again to assign AX Account Number from the Map created above*/
        if(newOrderList != null && newOrderList.size() > 0){
            for(Order orderRecord : newOrderList){
                String hasPayment = '';
                if( orderRecord.Type != null && orderRecord.Type.equalsIgnoreCase('Repair Replacement')){
                    if(orderRecord.ServiceOrder__c != null && workOrderHasPayment.containsKey(orderRecord.ServiceOrder__c) && workOrderHasPayment.get(orderRecord.ServiceOrder__c)){
                        hasPayment = 'TRUE';
                    }else{
                        hasPayment = 'FALSE';
                    }
                }
                String key = createKey(orderRecord, hasPayment);
                if(keyToAccountNumberMap.containsKey(key) && !idToAccountMap.containsKey(orderRecord.AccountId) && keyToAccountNumberMap.get(key).AccountNumber__c != null){
                    orderRecord.AX_Order_Account__c = keyToAccountNumberMap.get(key).AccountNumber__c;
                    if(orderRecord.Recall_Fasttrack__c && keyToAccountNumberMap.get(key).RecallAXAccountNumber__c != null 
                       && keyToAccountNumberMap.get(key).RecallAXAccountNumber__c != ''){
                           orderRecord.AX_Order_Account__c = keyToAccountNumberMap.get(key).RecallAXAccountNumber__c;
                       }
                }else if(idToAccountMap.containsKey(orderRecord.AccountId) && (idToAccountMap.get(orderRecord.AccountId).VendAccount__c != null
                                                                               || idToAccountMap.get(orderRecord.AccountId).VendAccount__c != '')){
                                                                                   orderRecord.AX_Order_Account__c = idToAccountMap.get(orderRecord.AccountId).VendAccount__c;
                                                                               }else {
                                                                                   orderRecord.AX_Order_Account__c = '';
                                                                               }
            }
        }
        
        for(Order orderRecord: partnerOrders){
            orderRecord.AX_Order_Account__c = roleNameToAxAccountNumber.get(roleName);
        }
        
        
        
    }
    /* populateAXAccountNumber exits*/
    
    /* create key map*/
    private static String createKey(Order orderRecord, String hasPayment){
        String key = '';
        if(orderRecord.Brand__c != null && orderRecord.Brand__c != ''){
            key = key +orderRecord.Brand__c;
        }
        if(orderRecord.Type != null && orderRecord.Type != ''){
            key = key +orderRecord.Type;
        }
        if(orderRecord.CurrencyIsoCode != null && orderRecord.CurrencyIsoCode != ''){
            key = key +orderRecord.CurrencyIsoCode;
        }
        if(orderRecord.RMItems__c > 0){
            key = key +'true';
        }else{
            key = key +'false';
        }
        key = key + hasPayment;
        
        if(orderRecord.ShippingCountryCode != null && orderRecord.ShippingCountryCode != '' && orderRecord.CurrencyIsoCode == 'EUR'){
            key = key +orderRecord.ShippingCountryCode;
            if(String.isNotBlank(orderRecord.Source__c) && orderRecord.Source__c.equalsIgnoreCase('GWP')){
              key = key + orderRecord.Source__c;
          }
        }
        
        return key.toUpperCase();
    }
    /*createKey exits*/
    
    public static void lockActivatedOrder(List <Order> orderList){
        list<Order> ordersListToLock = new list<Order>();    
        for(Order orderRec : orderList){
            if(orderRec.ActivatedByPartner__c){
                ordersListToLock.add(orderRec);
            }
        }
        
        if(ordersListToLock != null && ordersListToLock.size() > 0){
            Approval.LockResult[] lrList = Approval.lock(ordersListToLock, false);
        }
    }
    
    /*to populate Case order type on Case*/
    public static void poulateOrderTypeOnCase(list<Order> orderList){
        map<Id, Case> idToCaseMap = new map<Id, Case>();
        
        
        /*iterate through Order and update Case order type if Order contains Case*/ 
        for(Order orderRecord : orderList){
            if(orderRecord.Case__c != null){
                if(orderRecord.Type.equalsIgnoreCase('Sale')){
                    if(!idToCaseMap.containsKey(orderRecord.Case__c)){
                        idToCaseMap.put(orderRecord.Case__c, new Case(Id=orderRecord.Case__c, Order_Type__c='SALE'));
                    }
                }else if(orderRecord.Type.equalsIgnoreCase('Accommodation')){
                    if(!idToCaseMap.containsKey(orderRecord.Case__c)){
                        idToCaseMap.put(orderRecord.Case__c, new Case(Id=orderRecord.Case__c, Order_Type__c='ACCOMMODATION'));  
                    }
                }
            }
        }
        if(idToCaseMap != null && idToCaseMap.size() > 0){
            update idToCaseMap.values();
        }
    }
    /*poulateCaseTypeOnCase exits*/
    
    
    public static void populatebackOrderNotificationDate(list<Order> orderList, map<Id,Order> triggerOldMap){
        
        if(orderList != null && orderList.size() > 0 && triggerOldMap != null && triggerOldMap.size() > 0){
            
            for(Order orderRecord : orderList){
                if(orderRecord.Order_Pending_Reason__c != 'Waiting on Backorder Item' && triggerOldMap.get(orderRecord.Id).Order_Pending_Reason__c != orderRecord.Order_Pending_Reason__c){
                    orderRecord.NextNotificationDate__c = null;
                }else if(orderRecord.Order_Pending_Reason__c == 'Waiting on Backorder Item' && triggerOldMap.get(orderRecord.Id).Order_Pending_Reason__c != orderRecord.Order_Pending_Reason__c){
                    orderRecord.NextNotificationDate__c = Date.today();
                }
                
            }
        }
    }
    
    public static void populateSplitShipmentDetails(List<Order> orderList, map<Id,Order> oldMap){
       for(Order orderRec : orderList){
            
            if(oldMap.get(orderRec.Id).AX_Order_ID__c != null && oldMap.get(orderRec.Id).AX_Order_ID__c!= '' &&
               oldMap.get(orderRec.Id).AX_Order_ID__c != orderRec.AX_Order_ID__c && 
               ! oldMap.get(orderRec.Id).AX_Order_ID__c.contains(orderRec.AX_Order_ID__c)){
                   orderRec.AX_Order_ID__c = oldMap.get(orderRec.Id).AX_Order_ID__c +','+ orderRec.AX_Order_ID__c;
               }
            
            //append tracking number
            if(oldMap.get(orderRec.Id).Order_Tracking__c != null && oldMap.get(orderRec.Id).Order_Tracking__c!= '' &&
               oldMap.get(orderRec.Id).Order_Tracking__c != orderRec.Order_Tracking__c && 
               ! oldMap.get(orderRec.Id).Order_Tracking__c.contains(orderRec.Order_Tracking__c)){
                   orderRec.Order_Tracking__c = oldMap.get(orderRec.Id).Order_Tracking__c +','+ orderRec.Order_Tracking__c;
               }
           

            //append picking ticket no
            if(oldMap.get(orderRec.Id).Picking_Ticket__c != null && oldMap.get(orderRec.Id).Picking_Ticket__c != ''){
                if (orderRec.Picking_Ticket__c != null && orderRec.Picking_Ticket__c != ''){
                    if(oldMap.get(orderRec.Id).Picking_Ticket__c != orderRec.Picking_Ticket__c && 
                       ! oldMap.get(orderRec.Id).Picking_Ticket__c.contains(orderRec.Picking_Ticket__c) ){
                           orderRec.Picking_Ticket__c = oldMap.get(orderRec.Id).Picking_Ticket__c +','+ orderRec.Picking_Ticket__c;
                       }
                    
                    else if (oldMap.get(orderRec.Id).Picking_Ticket__c.contains(orderRec.Picking_Ticket__c) ){
                        orderRec.Picking_Ticket__c = oldMap.get(orderRec.Id).Picking_Ticket__c;
                    }
                }
                else {
                    orderRec.Picking_Ticket__c = oldMap.get(orderRec.Id).Picking_Ticket__c;
                }
            }
           
            //append magic order id and changes for Marketplace Beanz / US Order -> D365I-78 
          if(orderRec.CurrencyIsoCode == 'EUR' || orderRec.CurrencyIsoCode == 'CHF' || 
              orderRec.CurrencyIsoCode == 'GBP' || orderRec.CurrencyIsoCode == 'USD'){
                if(oldMap.get(orderRec.Id).Magic_Order_ID__c != null && oldMap.get(orderRec.Id).Magic_Order_ID__c != ''){
                     if (orderRec.Magic_Order_ID__c != null && orderRec.Magic_Order_ID__c != ''){
                    if(oldMap.get(orderRec.Id).Magic_Order_ID__c != orderRec.Magic_Order_ID__c && 
                       ! oldMap.get(orderRec.Id).Magic_Order_ID__c.contains(orderRec.Magic_Order_ID__c)){
                           orderRec.Magic_Order_ID__c = oldMap.get(orderRec.Id).Magic_Order_ID__c +','+ orderRec.Magic_Order_ID__c;
                       }
                    else if (oldMap.get(orderRec.Id).Magic_Order_ID__c.contains(orderRec.Magic_Order_ID__c)){
                        orderRec.Magic_Order_ID__c = oldMap.get(orderRec.Id).Magic_Order_ID__c;
                    }
                     }else{
                         orderRec.Magic_Order_ID__c = oldMap.get(orderRec.Id).Magic_Order_ID__c;
                     }
                }
           }
            
            
            //append the carrier
            if(oldMap.get(orderRec.Id).Carrier__c != null && oldMap.get(orderRec.Id).Carrier__c!= '' &&
               oldMap.get(orderRec.Id).Carrier__c != orderRec.Carrier__c && 
               ! oldMap.get(orderRec.Id).Carrier__c.contains(orderRec.Carrier__c)){
                   orderRec.Carrier__c = oldMap.get(orderRec.Id).Carrier__c +','+ orderRec.Carrier__c;
               }
            
        }
    }
    
    public static void populateB2bEmail(List<Order> orderList){
        list<Id> accountIds = new list<Id>();
        for(Order orderRecord: orderList){
            if(orderRecord.AccountId != null)
                accountIds.add(orderRecord.AccountId);
        }
        
        map<Id, Account> b2bAccounts = new map<Id,Account>([SELECT Id, RecordType.Name, BusinessCommunicationEmail__c FROM Account WHERE Id IN :accountIds 
                                                            AND RecordType.Name = 'Business Account']);
        
        if(b2bAccounts != null && b2bAccounts.size() > 0){
            for(Order orderRecord: orderList){
                if(b2bAccounts.containsKey(orderRecord.AccountId) && b2bAccounts.get(orderRecord.AccountId) != null 
                   && b2bAccounts.get(orderRecord.AccountId).BusinessCommunicationEmail__c != null && b2bAccounts.get(orderRecord.AccountId).BusinessCommunicationEmail__c != ''){ 
                       orderRecord.B2BEmail__c = b2bAccounts.get(orderRecord.AccountId).BusinessCommunicationEmail__c;
                   }
            }
        }
        
    }
    
    
    //To create a new Record for TnCAgreement
    public static void CreateTnCAgreementForOrder(list<Order> orderList){
        
        List<TnC_Agreement__c> tnCAgreementRecordList = new List<TnC_Agreement__c>();
        list<Order> orderToConsider = new list<Order>();
        Set<String> currencyList = new Set<String>();
        
        for(Order orderRecord : orderList){
            if(orderRecord.TnC_Agreement__c && orderRecord.Channel__c == 'ECOMM' && orderRecord.Source__C == 'AEM'){
                currencyList.add(orderRecord.currencyISOCode);
                orderToConsider.add(orderRecord);
            }
        }
        
        if(orderToConsider != null && orderToConsider.size() > 0){
            
            list<TermsAndCondition__c> termsAndConditionsList = [select id, currencyISOCode, applicable_date__c from termsAndCondition__c where 
                                                                 currencyISOCode IN :currencyList order by applicable_date__c desc];
            
            
            /*iterate through Order and create TnCAgreement Record*/ 
            for(Order orderRecord : orderToConsider){
                TnC_Agreement__c tnCAgreement = new TnC_Agreement__c();
                if(orderRecord.AccountId !=null)
                    tnCAgreement.Account_ID__c = orderRecord.AccountId;
                tnCAgreement.Order__c = orderRecord.id;
                
                for(TermsAndCondition__c record: termsAndConditionsList){
                    if(orderRecord.CurrencyIsoCode == record.CurrencyIsoCode && orderRecord.EffectiveDate >= record.applicable_date__c){
                        tnCAgreement.TnC__c = record.Id;
                        break;
                    }
                }
                tnCAgreementRecordList.add(tnCAgreement);
            }
            Database.SaveResult[] saveResult;
            list<Error_Log__c> errorLogs = new list<Error_Log__c>();
            if(tnCAgreementRecordList != null && tnCAgreementRecordList.size() > 0){
                saveResult = Database.insert(tnCAgreementRecordList,false);
                for(Integer i=0; i<saveResult.size();i++){
                    if(!saveResult[i].isSuccess()){
                        String msg = '';
                        msg += saveResult[i].errors[0].getMessage();
                        Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting a record in TnC Agreement ', msg, 'OrderTriggerHandler --CreateTnCAgreementForOrder',false, 'Tracking error' );
                        errorLogs.add(error);
                    }
                }
                insert errorLogs;      
            }
        }
    }
    
     /* Changes for D365I-89 Order Header Status & Line Level Status */
    public static void updateShippedNotificationSent(List<Order> orderList,Map<Id, Order> triggerOldMap){
        Map <Id, Order> orderMap = new Map <Id, Order>();
        List<OrderItem> orderProducts=new List<OrderItem>();
        for(Order updatedOrder:orderList){
            if((updatedOrder.CurrencyIsoCode== 'USD'
                || updatedOrder.CurrencyIsoCode== 'EUR' || updatedOrder.CurrencyIsoCode== 'GBP'
                || updatedOrder.CurrencyIsoCode== 'CHF')
               && updatedOrder.ShipConfirmRecieved__c!=triggerOldMap.get(updatedOrder.Id).ShipConfirmRecieved__c 
               && updatedOrder.ShipConfirmRecieved__c==false){
                   orderMap.put(updatedOrder.Id,updatedOrder);
               }
        }
       
        if(orderMap.size()>0){
            orderProducts=[select id,OrderId,ShippedNotificationSent__c from OrderItem where LineStatus__c IN ('Shipped','Invoiced') AND OrderId IN :orderMap.keySet()];
        }
       
        if(orderProducts.size()>0){
            for(OrderItem orderItem:orderProducts){
                orderItem.ShippedNotificationSent__c=true;
            }
            update orderProducts;
        }
    }

        /* Changes for Line Level Status for order cancellation */
    public static void updateCancelledNotificationSent(List<Order> orderList,Map<Id, Order> triggerOldMap){
        Map <Id, Order> orderMap = new Map <Id, Order>();
        List<OrderItem> orderProducts=new List<OrderItem>();
        for(Order updatedOrder:orderList){
            if((updatedOrder.CurrencyIsoCode== 'USD'
            || updatedOrder.CurrencyIsoCode== 'EUR' || updatedOrder.CurrencyIsoCode== 'GBP'
            || updatedOrder.CurrencyIsoCode== 'CHF')
            && updatedOrder.Cancellation_Received__c!=triggerOldMap.get(updatedOrder.Id).Cancellation_Received__c && updatedOrder.Cancellation_Received__c==false){
                orderMap.put(updatedOrder.Id,updatedOrder);
            }
        }
        if(orderMap.size()>0){
            orderProducts=[select id,OrderId,CancelledNotificationSent__c from OrderItem where LineStatus__c IN ('Cancelled') AND OrderId IN :orderMap.keySet()];
        }
        if(orderProducts.size()>0){
            for(OrderItem orderItem:orderProducts){
                orderItem.CancelledNotificationSent__c=true;
            }
            update orderProducts;
        }
    }

}