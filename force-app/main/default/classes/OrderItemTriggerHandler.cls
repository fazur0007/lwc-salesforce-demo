public without sharing class OrderItemTriggerHandler {
    
    public  static boolean afterTriggerRun = true;
    public  static boolean beforeTriggerRun = true;
    public static boolean runOnceAfterTrigger() {
        if (afterTriggerRun) {
            afterTriggerRun = false;
            return true;
        } else {
            return afterTriggerRun;
        }
    }
    public static boolean runOnceBeforeTrigger() {
        if (beforeTriggerRun) {
            beforeTriggerRun = false;
            return true;
        } else {
            return beforeTriggerRun;
        }
    }
    
    private static final Set<String> LINE_STATUSES_FOR_PRODUCT_REG = new Set<String> { 'Shipped', 'Invoiced' };
    
    /*This method will 
    * 1. Update a flag on Order record if any order Item is created or udpated, this will ensure the price check from AX in case order is for Retailer
    * 2. Update the Order Authorization Amount in case of 'Accomodation' Order i.e. Sum of landing cost of order line items + 25% of sum calculated earlier
    */
    public static void updateParentOrder(list<OrderItem> orderItemList, map<Id, OrderItem> triggerOldMap, Boolean isDelete, Boolean isUpdate) {
        Set<Id> orderSet = new Set<Id>();
        Set<Id> accommodationOrderIdSet = new Set<Id>();
        List<Order> orderListToUpdate = new List<Order>();
        map<Id, Order> orderIdToOrderMap = new Map<Id, Order>();
        Set<Id> orderRecalculationRequired = new Set<Id>();
        
        for (OrderItem orderItemRecord : orderItemList) {
            if (isUpdate && (orderItemRecord.Quantity != triggerOldMap.get(orderItemRecord.Id).Quantity
                            || orderItemRecord.PriceBookEntryID != triggerOldMap.get(orderItemRecord.Id).PriceBookEntryID 
                            || orderItemRecord.UnitPrice != triggerOldMap.get(orderItemRecord.Id).UnitPrice )) {
                orderRecalculationRequired.add(orderItemRecord.OrderId);
            }
            orderSet.add(orderItemRecord.OrderId);
        }
        
        for (Order orderRec : [SELECT Id, Order_List_Price__c, Type, CC_Authorization_Amount__c, IsCalculated__c, BackOrderLineItemCount__c FROM Order WHERE Id IN: orderSet]) {
            orderRec.Order_List_Price__c = 0;
            if (orderRec.Type != null && orderRec.Type.equalsIgnoreCase(ApplicationLiterals.ACCOMMODATION_TYPE)) {
                accommodationOrderIdSet.add(orderRec.Id);
                orderRec.CC_Authorization_Amount__c = 0;
            }
            orderRec.BackOrderLineItemCount__c = 0;
            
            orderIdToOrderMap.put(orderRec.Id, orderRec);
        }
        if (orderSet != null && orderSet.size() > 0) {
            for (OrderItem orderItemRec : [SELECT Id, Order.IsCalculated__c, OrderId, Order.CreatedFromPortal__c, Order.CreatedBy.Profile.Name, Order.Type, Order.Account.Type,
                                          PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Landed_Cost__c, Quantity, List_Price_Subtotal__c,
                                          Available_to_Sell__c, PricebookEntry.Product2.Available_To_Sell__c, 
                                          Order.OrderCustomerType__c, PricebookEntry.Product2.Quantity_Available__c, PricebookEntry.Product2.Quantity_Available_for_B2B__c,
                                          PricebookEntry.Product2.Product_Type__c,PricebookEntry.Product2.Wholesale_Cost__c
                                          FROM OrderItem
                                          WHERE OrderId IN: orderSet]) {
                //Setting subtotal field                            
                orderIdToOrderMap.get(orderItemRec.OrderId).Order_List_Price__c = orderIdToOrderMap.get(orderItemRec.OrderId).Order_List_Price__c + orderItemRec.List_Price_Subtotal__c;
                
                if (!isDelete && orderItemRec.Order.Account.Type != null && orderItemRec.Order.Account.Type == 'Retailer' && orderRecalculationRequired != null && 
                    orderRecalculationRequired.size() > 0 && orderRecalculationRequired.contains(orderItemRec.OrderId)) {
                        orderIdToOrderMap.get(orderItemRec.OrderId).IsCalculated__c = false;
                    } else if (orderItemRec.Order.Type == ApplicationLiterals.ACCOMMODATION_TYPE) {
                        Double authAmount = orderIdToOrderMap.get(orderItemRec.OrderId).CC_Authorization_Amount__c;
                        if (orderItemRec.PricebookEntry.Product2.Landed_Cost__c != null) {
                            if (orderItemRec.PricebookEntry.Product2.Landed_Cost__c > 100) {
                                authAmount += (orderItemRec.PricebookEntry.Product2.Landed_Cost__c * orderItemRec.Quantity * (1.25));
                            } else {
                                authAmount += (orderItemRec.PricebookEntry.Product2.Landed_Cost__c * orderItemRec.Quantity * (1.75));
                            }
                        }
                        authAmount = Decimal.valueOf(authAmount).round(System.RoundingMode.HALF_DOWN);
                        //authAmount += (orderItemRec.PricebookEntry.Product2.Landed_Cost__c * orderItemRec.Quantity * (1.25));
                        orderIdToOrderMap.get(orderItemRec.OrderId).CC_Authorization_Amount__c = authAmount;
                    }
                
                if (!orderItemRec.PricebookEntry.Product2.Available_To_Sell__c) {
                    orderIdToOrderMap.get(orderItemRec.OrderId).BackOrderLineItemCount__c += 1;
                }
            }
            if (orderIdToOrderMap.values() != null && orderIdToOrderMap.values().size() > 0) {
                update orderIdToOrderMap.values();
            }
        }
        
    }
    
    public static void populateSplitShipmentDetails(list<OrderItem> orderItemList,map<Id,OrderItem> oldMap) {
       
        for (OrderItem orderItem : orderItemList) {
            if (oldMap.get(orderItem.Id).ExternalInvoiceID__c != null &&
               oldMap.get(orderItem.Id).ExternalInvoiceID__c != orderItem.ExternalInvoiceID__c && 
               !oldMap.get(orderItem.Id).ExternalInvoiceID__c.contains(orderItem.ExternalInvoiceID__c)) {

                orderItem.ExternalInvoiceID__c = oldMap.get(orderItem.Id).ExternalInvoiceID__c +','+ orderItem.ExternalInvoiceID__c;
            }
            
            // copy the Carrier Name
            if (oldMap.get(orderItem.Id).Carrier__c != null &&
               oldMap.get(orderItem.Id).Carrier__c != orderItem.Carrier__c && 
               !oldMap.get(orderItem.Id).Carrier__c.contains(orderItem.Carrier__c)) {

                orderItem.Carrier__c = oldMap.get(orderItem.Id).Carrier__c +','+ orderItem.Carrier__c;
            }
            
            //copy the tracking numbers
            if (oldMap.get(orderItem.Id).TrackingNumbers__c != null &&
               oldMap.get(orderItem.Id).TrackingNumbers__c != orderItem.TrackingNumbers__c && 
               !oldMap.get(orderItem.Id).TrackingNumbers__c.contains(orderItem.TrackingNumbers__c)) {
                   
                orderItem.TrackingNumbers__c = oldMap.get(orderItem.Id).TrackingNumbers__c +';'+ orderItem.TrackingNumbers__c;
            }
            
            //copy the picking ticket no
            if (oldMap.get(orderItem.Id).Picking_Ticket__c != null) {
                if (orderItem.Picking_Ticket__c!= null  && orderItem.Picking_Ticket__c!= '') {
                    if (oldMap.get(orderItem.Id).Picking_Ticket__c != orderItem.Picking_Ticket__c &&  
                        !oldMap.get(orderItem.Id).Picking_Ticket__c.contains(orderItem.Picking_Ticket__c)) {
                       orderItem.Picking_Ticket__c = oldMap.get(orderItem.Id).Picking_Ticket__c +','+ orderItem.Picking_Ticket__c;
                    } else if (oldMap.get(orderItem.Id).Picking_Ticket__c.contains(orderItem.Picking_Ticket__c)) {
                        orderItem.Picking_Ticket__c = oldMap.get(orderItem.Id).Picking_Ticket__c;
                    }
                } else {
                    orderItem.Picking_Ticket__c = oldMap.get(orderItem.Id).Picking_Ticket__c;
                }
            }
            
            // copy external ID and changes for Marketplace Beanz Order>>D365I-78
            if (orderItem.CurrencyIsoCode == 'EUR' || orderItem.CurrencyIsoCode == 'CHF' || 
                orderItem.CurrencyIsoCode == 'GBP' || ( orderItem.CurrencyIsoCode == 'USD' /*&& orderItem.order.Brand__c == 'Beanz'*/)) {
                if (oldMap.get(orderItem.Id).External_Order_ID__c != null) {
                    if (orderItem.External_Order_ID__c != null && orderItem.External_Order_ID__c != '') {
                        if (oldMap.get(orderItem.Id).External_Order_ID__c != orderItem.External_Order_ID__c && 
                        !oldMap.get(orderItem.Id).External_Order_ID__c.contains(orderItem.External_Order_ID__c)) {
                            orderItem.External_Order_ID__c = oldMap.get(orderItem.Id).External_Order_ID__c +','+ orderItem.External_Order_ID__c;
                        }
                        else if (oldMap.get(orderItem.Id).External_Order_ID__c.contains(orderItem.External_Order_ID__c)) {
                            orderItem.External_Order_ID__c = oldMap.get(orderItem.Id).External_Order_ID__c ;
                        }
                    } else {
                        orderItem.External_Order_ID__c = oldMap.get(orderItem.Id).External_Order_ID__c ;
                    }
                }
            }
        }
    }
    
    public static void populateUniqueLineID(list<OrderItem> orderItemList) {
        for (OrderItem orderItem : orderItemList) {
            if (orderItem.AX_Unique_Line_ID__c == null || orderItem.AX_Unique_Line_ID__c == '') {
                orderItem.AX_Unique_Line_ID__c = orderItem.OrderId + orderItem.AX_Item_Number__c;
                orderItem.OP_NewUniqueId__c = orderItem.AX_Unique_Line_ID__c;
            }
        }
    }
    
    /*This method will create Assets for all FG Products after Shipment*/
    public static void autoRegistrationforFinishedGoods(list<OrderItem> orderItemList, map<Id, OrderItem> triggerOldMap) {
        System.debug('===inside autoRegistrationforFinishedGoods===');
        try {
            List<Asset> assetList = new List<Asset>();
            Map<Id, List<ProductExtended_warranty__c>> ProductExtwarrantyMap = new Map<Id, List<ProductExtended_warranty__c>>();
            
            list<OrderItem> filteredorderItemList = [SELECT LineStatus__c, Quantity, EndDate, Order.Account.FirstName, Order.Account.LastName, 
                                                     Order.AccountId, Order.CreatedDate, Order.BillToContactId, 
                                                     Order.Account.personEmail, Order.CurrencyIsoCode,Order.OrderNumber,Order.PricesInclusiveOfTaxes__c,
                                                     PricebookEntry.Product2Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.Warranty_In_Months__c,
                                                     PricebookEntry.Product2.Product_Sub_Family__c,
                                                     (SELECT Id FROM Assets__r LIMIT 1)
                                                     FROM OrderItem 
                                                     WHERE Id In : orderItemList
                                                     AND PricebookEntry.Product2.Finished_Good__c = True 
                                                     AND PricebookEntry.Product2.Spare_Part__c = False 
                                                     AND PricebookEntry.Product2.Accessory__c = False
                                                     AND Order.OrderCustomerType__c = 'B2C'
                                                     AND LineStatus__c = :LINE_STATUSES_FOR_PRODUCT_REG];
            
            if (filteredorderItemList != Null && filteredorderItemList.size() > 0) {
                for (ProductExtended_warranty__c prodExtWarr : [SELECT Id, Parent_order_product__c, 
                                                                  Warranty_order_product__r.UnitPrice, 
                                                                  Warranty_order_product__c, Warranty_order_product__r.Quantity, 
                                                                  Warranty_order_product__r.PricebookEntry.Product2.Warranty_In_Months__c
                                                                FROM ProductExtended_warranty__c 
                                                                WHERE Parent_order_product__c IN : filteredorderItemList]) {
                    if (ProductExtwarrantyMap.containsKey(prodExtWarr.Parent_order_product__c)) {
                        ProductExtwarrantyMap.get(prodExtWarr.Parent_order_product__c).add(prodExtWarr);
                    } else {
                        ProductExtwarrantyMap.put(prodExtWarr.Parent_order_product__c, new list<ProductExtended_warranty__c>{prodExtWarr});
                    }
                }
            }
            
            for (OrderItem orderItem : filteredorderItemList) {
                if (orderItem.Assets__r.size() == 0 &&  orderItem.LineStatus__c != triggerOldMap.get(orderItem.Id).LineStatus__c) {
                    Integer quantity = (Integer)orderItem.Quantity;
                    Integer i=0;
                    
                    /*Populate EW Attributes*/
                    if (ProductExtwarrantyMap != Null && ProductExtwarrantyMap.size() > 0) {
                        List<ProductExtended_warranty__c> pewList = ProductExtwarrantyMap.get(orderItem.Id);
                        
                        if (pewList != null && pewList.size() > 0) {
                            for (ProductExtended_warranty__c pew : pewList) {
                                for (Integer pewCount = 0; pewCount< pew.Warranty_order_product__r.Quantity; pewCount++) {
                                    Asset assetRecord = assetRecordFromOrderProduct(orderItem);
                                    assetRecord.Product_Extended_warranty__c = pew.Id;
                                    assetRecord.EW_Present__c = True;
                                    assetRecord.EW_Status__c = 'Active';
                                    if (orderItem.PricebookEntry.Product2.Warranty_In_Months__c != Null) {
                                        assetRecord.EW_Start__c = assetRecord.PurchaseDate.addMonths(Integer.valueOf(orderItem.PricebookEntry.Product2.Warranty_In_Months__c)); 
                                    }
                                    if (pew.Warranty_order_product__r.PricebookEntry.Product2.Warranty_In_Months__c != Null && assetRecord.EW_Start__c != Null) {
                                        assetRecord.EW_End__c = assetRecord.EW_Start__c.addMonths(Integer.valueOf(pew.Warranty_order_product__r.PricebookEntry.Product2.Warranty_In_Months__c));
                                    }
                                    
                                    
                                    assetRecord.EW_Paid__c = pew.Warranty_order_product__r.UnitPrice;
                                    
                                    assetList.add(assetRecord);
                                    i++;
                                }
                            }
                        }
                    }
                    for (; i < quantity; i++) {
                        Asset assetRecord = assetRecordFromOrderProduct(orderItem);
                        assetList.add(assetRecord);
                    }
                }
            }
            if (assetList.size() > 0) {
                Database.SaveResult[] results = Database.insert(assetList, false);
                
                list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
                for (Integer i = 0; i < assetList.size(); i++) {
                    if (! results[i].isSuccess()) {
                        String msg = '';
                        msg += results[i].errors[0].getMessage();
                        
                        Error_Log__c error = ErrorLog.logErrorActivity(msg, 'error while inserting assets from OrderItemTriggerHandler : autoRegistrationforFinishedGoods', 
                                                                       'ServiceContract - AutoRegistrationFinishedGoods', false, 'OrderItemTriggerHandler',String.valueOf(assetList[i].get('ParentOrder__c'))); 
                        errorLogs.add(error);
                    }
                }
                if (errorLogs.size() > 0)
                    insert  errorLogs;
            }
        } catch (Exception ex) {
            Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
                                                           'error inside autoRegistrationforFinishedGoods', 
                                                           'ServiceContract - AutoRegistrationFinishedGoods',false, 'OrderItemTriggerHandler');
            insert error;
        }
    }
    
    /*Create Asset for FG products*/
    public static Asset assetRecordFromOrderProduct(OrderItem orderItem) {
        Asset assetRecord = new Asset();
        assetRecord.Name = orderItem.Order.Account.FirstName + ' ' + orderItem.Order.Account.LastName + ' - ' + orderItem.PricebookEntry.Product2.Name;
        assetRecord.AccountId = orderItem.Order.AccountId;
        assetRecord.ContactId = orderItem.Order.BillToContactId;
        assetRecord.product2Id = orderItem.PricebookEntry.Product2Id;
        assetRecord.Account_Email__c = orderItem.Order.Account.personEmail;
        assetRecord.CurrencyIsoCode = orderItem.Order.CurrencyIsoCode;
        assetRecord.Warranty_Product_Sub_Category__c = orderItem.PricebookEntry.Product2.Product_Sub_Family__c;
        //assetRecord.Channel__c = 'CCC';
        DateTime dt = orderItem.EndDate ; 
        Date orderShippedDate = (dt != Null) ? date.newinstance(dt.year(), dt.month(), dt.day()) : Date.today();
        assetRecord.PurchaseDate = orderShippedDate; 
        assetRecord.ParentOrder__c= orderItem.OrderId;
        assetRecord.Order_Product__c = orderItem.Id;
        assetRecord.IsAutoRegistered__c = true;
        assetRecord.Status = 'Pre-registered';
        
        return assetRecord;
    }
    
    /*This method will update Assets for all ExtWTY Products to update EW attributes after Shipment*/
    public static void updateAssetExistingRegProduct(list<OrderItem> orderItemList, map<Id, OrderItem> triggerOldMap) {
        System.debug('===inside updateAssetExistingRegProduct===');
        try {
            List<Asset> assetList = new List<Asset>();
            
            list<OrderItem> filteredorderItemList = [SELECT LineStatus__c, Quantity, EndDate, UnitPrice, Line_Item_Tax__c, Order.Asset__c, 
                                                     Order.Asset__r.PurchaseDate, Order.Asset__r.Product2.Warranty_In_Months__c, 
                                                     Order.CreatedDate, Order.CurrencyIsoCode, Order.PricesInclusiveOfTaxes__c,
                                                     PricebookEntry.Product2Id,PricebookEntry.Product2.Warranty_In_Months__c,
                                                     PricebookEntry.Product2.Landed_Cost__c,
                                                     (SELECT Id FROM Assets__r LIMIT 1)
                                                     FROM OrderItem 
                                                     WHERE Id In : orderItemList
                                                     AND Order.Asset__c != Null
                                                     AND PricebookEntry.Product2.Product_Type__c = 'EXTWTY'
                                                     AND Order.OrderCustomerType__c = 'B2C'
                                                     AND LineStatus__c = 'Shipped'];
          
            for (OrderItem orderItem : filteredorderItemList) {
                
                /*Populate EW Attributes*/
                if (orderItem.LineStatus__c != triggerOldMap.get(orderItem.Id).LineStatus__c) {
                    DateTime dt = orderItem.EndDate ; 
                    Date orderShippedDate = (dt != Null) ? date.newinstance(dt.year(), dt.month(), dt.day()) : Date.today();
                    
                    Asset assetRecord = new Asset();
                    assetRecord.Id = orderItem.Order.Asset__c;
                    assetRecord.EW_Present__c = True;
                    assetRecord.EW_Status__c = 'Active';
                    
                    if (orderItem.Order.Asset__r.Product2.Warranty_In_Months__c != Null) {
                        assetRecord.EW_Start__c = orderShippedDate.addMonths(Integer.valueOf(orderItem.Order.Asset__r.Product2.Warranty_In_Months__c)); 
                    }
                    
                    if (orderItem.PricebookEntry.Product2.Warranty_In_Months__c != Null && assetRecord.EW_Start__c != Null) {
                        assetRecord.EW_End__c = assetRecord.EW_Start__c.addMonths(Integer.valueOf(orderItem.PricebookEntry.Product2.Warranty_In_Months__c));
                    }
                    
                    assetRecord.EW_Paid__c = orderItem.UnitPrice;
                    assetList.add(assetRecord);
                }
            }
            if (assetList.size() > 0) {
                Database.SaveResult[] results = Database.update(assetList, false);
                
                list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
                for (Integer i = 0; i < assetList.size(); i++) {
                    if (! results[i].isSuccess()) {
                        String msg = '';
                        msg += results[i].errors[0].getMessage();
                        
                        Error_Log__c error = ErrorLog.logErrorActivity(msg, 'error while updating assets from OrderItemTriggerHandler : updateAssetExistingRegProduct', 
                                                                       'ServiceContract - UpdateExistingAssets',false, 'OrderItemTriggerHandler', String.valueOf(assetList[i].get('Id'))); 
                        errorLogs.add(error);
                    }
                }
                if (errorLogs.size() > 0)
                    insert  errorLogs;
            }
        } catch (Exception ex) {
            Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
                                                           'error inside updateAssetExistingRegProduct', 
                                                           'ServiceContract - UpdateExistingAssets',false, 'OrderItemTriggerHandler');
            insert error;
        }
    }            
    
    public static void setAvailableToSell(List<OrderItem> orderItems) {
        if (orderItems != null && !orderItems.isEmpty()) {
            Set<Id> orderIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            for (OrderItem item : orderItems) {
                orderIds.add(item.OrderId);
                productIds.add(item.Product2Id);
            }
            if (orderIds.size() > 0 && productIds.size() > 0) {
                Map<Id, Order> orders = new Map<Id, Order>([SELECT Id, Type, AX_Order_Account__c FROM Order WHERE Id IN: orderIds]);
                Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, AX_Reserved_Inventory__c, Available_To_Sell__c FROM Product2 WHERE Id IN :productIds]);
                
                for (OrderItem item : orderItems) {
                    Order orderObj = orders.get(item.OrderId);
                    Product2 productObj = products.get(item.Product2Id);
                    if (orderObj != null && productObj != null) {
                        item.Available_to_Sell__c = Utility.isAvailableToSell(orderObj, productObj);
                    } else {
                        item.Available_to_Sell__c = false;
                    }
                }
            }
        }
    }
    
  /*  public static void setTaxData (List<OrderItem> orderItems){
        if (orderItems == null || orderItems.isEmpty())
            return;
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (OrderItem item : orderItems) {
            orderIds.add(item.OrderId);
            productIds.add(item.Product2Id);
        }

    }*/
}