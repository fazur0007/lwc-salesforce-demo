public class LWC_CreateSparePartOrder_Cls {
    
    @AuraEnabled(cacheable = true)
    public static List < WrapperClass > doLoadInitData(String workOrderId) {
        List < WrapperClass > wrapperList = new List < WrapperClass > ();
        WorkOrder workOrderRecord = [Select Id From WorkOrder Where Id =: workOrderId Limit 1];
        wrapperList = queryWorkOrders(new list < WorkOrder > {
            workOrderRecord
                });
        return wrapperList;
    }
    public static list < WrapperClass > queryWorkOrders(list < WorkOrder > workOrdersList) {
        List < WorkOrder > workOrderList = [SELECT Id, RecordTypeId, ServiceCentre__c, Brand__c, Order__c FROM WorkOrder WHERE Id IN: workOrdersList];
        if (!validateWorkOrderList(workOrderList)) {
            List < WrapperClass > wrapperList = new List < WrapperClass > ();
            wrapperList = createLineItemList(workOrderList);
            if (wrapperList.isEmpty()) {
                throw new AuraHandledException('No Spare Parts found for the selected WorkOrders');
            }
            return wrapperList;
        }
        return null;
    }
    public static boolean validateWorkOrderList(List < WorkOrder > workOrderList) {
        String Brand = 'Breville';
        Boolean hasError = false;
        Id accountId;
        Set < Id > accountIdSet = new Set < Id > ();
        Set < String > brandSet = new Set < String > ();
        Id workOrderRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Work Order').getRecordTypeId();
        for (WorkOrder workOrderRec: workOrderList) {
            if (workOrderRec.Brand__c != null) {
                brandSet.add(workOrderRec.Brand__c);
                brand = workOrderRec.Brand__c;
            }
            if (workOrderRec.ServiceCentre__c != null) {
                accountIdSet.add(workOrderRec.ServiceCentre__c);
                accountId = workOrderRec.ServiceCentre__c;
            }
            if (workOrderRec.RecordTypeId != workOrderRecordTypeId) {
                hasError = true;
                throw new AuraHandledException('Only WorkOrders can be selected');
            }
        }
        if (accountIdSet.size() > 1) {
            hasError = true;
            throw new AuraHandledException('WorkOrders for multiple Account Selected');
            
        }
        if (brandSet.size() > 1) {
            hasError = true;
            throw new AuraHandledException('WorkOrders for multiple Brands Selected');
        }
        
        return hasError;
    }
    public static list < WrapperClass > createLineItemList(List < WorkOrder > workOrderList) {
        Set < Id > productIdSet = new Set < Id > ();
        Map < Id, WrapperClass > wrapperMap = new Map < Id, WrapperClass > ();
        for (WorkOrderLineItem items: [SELECT Id, PricebookEntryId, Quantity, PricebookEntry.Product2.Name, PricebookEntry.Product2Id, PricebookEntry.Product2.Description,
                                       PricebookEntry.Product2.Available_To_Sell__c
                                       FROM WorkOrderLineItem
                                       WHERE WorkOrderId IN: workOrderList
                                      ]) {
                                          productIdSet.add(items.PricebookEntry.Product2Id);
                                          if (wrapperMap.containsKey(items.PricebookEntry.Product2Id) && items.Quantity != null && items.Quantity > 0) {
                                              Double qty = wrapperMap.get(items.PricebookEntry.Product2Id).quantity;
                                              wrapperMap.get(items.PricebookEntry.Product2Id).quantity = qty + items.Quantity;
                                          }
                                          else {
                                              wrapperMap.put(items.PricebookEntry.Product2Id,
                                                             new WrapperClass(items.PricebookEntry.Product2.Name, items.PricebookEntry.Product2.Description,
                                                                              Double.valueOf(items.Quantity), items.PricebookEntry.Product2Id, items.PricebookEntry.Product2.Available_To_Sell__c));
                                          }
                                      }
        return wrapperMap.values();
    }
    
    @AuraEnabled
    Public static String createsparePartOrder(String workOrderId, String selectedOrderProducts) {
        String brand = 'Breville';
        String accountId;
        try
        {
            List < WorkOrder > workOrderList = [SELECT Id, RecordTypeId, ServiceCentre__c, Brand__c, Order__c FROM WorkOrder WHERE Id =: workOrderId];
            for (WorkOrder workOrderRec: workOrderList) {
                if (workOrderRec.Brand__c != null) {
                    brand = workOrderRec.Brand__c;
                }
                if (workOrderRec.ServiceCentre__c != null) {
                    accountId = workOrderRec.ServiceCentre__c;
                }
            }
            
            list < object > selectedWrapperList = (list < object > ) JSON.deserializeUntyped(selectedOrderProducts);
            
            if (selectedWrapperList != null && selectedWrapperList.size() > 0) {
                if (accountId != null) {
                    User currentUser = [SELECT Id, IsPortalEnabled FROM User WHERE Id =: UserInfo.getUserId() Limit 1];
                    Order orderRecord = createOrder(accountId, workOrderList, currentUser, brand, selectedWrapperList);
                    system.debug('orderRecord *******'+JSON.serializePretty(orderRecord.Id));
                    for (WorkOrder woRecord: workOrderList) {
                        woRecord.Order__c = orderRecord.Id;
                    }
                    update workOrderList;
                    return orderRecord.Id;
                }
                else {
                    throw new AuraHandledException('Error finding the Service Center');
                }
            }
        }
        catch(exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }
    
    public static Order createOrder(String accountId, List < WorkOrder > workOrderList, User currentUser, String brand, List < Object > wrapperList) {
        system.debug('workOrderList*******'+JSON.serializePretty(workOrderList));
        system.debug('currentUser*******'+JSON.serializePretty(currentUser));
        String region;
        Set < Id > productIdSet = new Set < Id > ();
        for (WorkOrderLineItem items: [SELECT Id, PricebookEntryId, Quantity, PricebookEntry.Product2.Name, PricebookEntry.Product2Id, PricebookEntry.Product2.Description,
                                       PricebookEntry.Product2.Available_To_Sell__c
                                       FROM WorkOrderLineItem
                                       WHERE WorkOrderId IN: workOrderList
                                      ]) {
                                          productIdSet.add(items.PricebookEntry.Product2Id);
                                      }
        list < OrderItem > OrderItemList = new list < OrderItem > ();
        list < Account > accountList = [SELECT Id, Name, BillingCity, BillingCountryCode, BillingPostalCode, BillingStateCode, BillingStreet,
                                        ShippingCountryCode, ShippingCity, ShippingPostalCode, ShippingStateCode, ShippingStreet, CurrencyIsoCode, VendAccount__c
                                        FROM Account
                                        WHERE Id =: accountId
                                       ];
        region = Utility.regionBased(accountList[0].CurrencyIsoCode);
        system.debug('region *******'+JSON.serializePretty(region));
        
        Order newOrder = new Order();
        newOrder.AccountId = accountId;
        newOrder.BillingCity = accountList[0].BillingCity;
        newOrder.BillingCountryCode = accountList[0].BillingCountryCode;
        newOrder.BillingPostalCode = accountList[0].BillingPostalCode;
        newOrder.BillingStateCode = accountList[0].BillingStateCode;
        newOrder.BillingStreet = accountList[0].BillingStreet;
        newOrder.ShippingCountryCode = accountList[0].ShippingCountryCode;
        newOrder.ShippingCity = accountList[0].ShippingCity;
        newOrder.ShippingPostalCode = accountList[0].ShippingPostalCode;
        newOrder.ShippingStateCode = accountList[0].ShippingStateCode;
        newOrder.ShippingStreet = accountList[0].ShippingStreet;
        newOrder.CurrencyIsoCode = accountList[0].CurrencyIsoCode;
        newOrder.Ship_To_Name__c = accountList[0].Name;
        newOrder.AX_Order_Account__c = accountList[0].VendAccount__c;
        newOrder.EffectiveDate = Date.today();
        if (currentUser.IsPOrtalEnabled) {
            newOrder.Type = 'Sale';
        }
        else {
            newOrder.Type = 'Repair Parts';
        }
        newOrder.status = 'Open';
        newOrder.Brand__c = brand;
        newOrder.Country__c = region;
        
        TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(newOrder);
        
        String priceBookType = 'Accommodation';
        if (currentUser.IsPOrtalEnabled) {
            priceBookType = 'Wholesale';
        }
        system.debug('priceBookType:'+priceBookType);
        system.debug('brand:'+brand);
        system.debug('region:'+region);
        List < Pricebook2 > pricebookList = [SELECT Id, Brand__c, Region__c, Type__c
                                             FROM Pricebook2
                                             WHERE Region__c =: region
                                             AND Brand__c =: brand
                                             AND Type__c =: priceBookType
                                            ];
        if (pricebookList != null && pricebookList.size() > 0) {
            newOrder.PriceBook2Id = pricebookList[0].Id;
            insert newOrder;
        }
        else {
            throw new AuraHandledException('PriceBook cannot be found');
        }
        if (wrapperList != null && wrapperList.size() > 0) {
            map < Id, PriceBookEntry > productIdToPriceBookEntryMap = new map < Id, PriceBookEntry > ();
            for (PriceBookEntry pbe: [SELECT Id, Product2Id, PriceBook2Id, UnitPrice
                                      FROM PriceBookEntry WHERE Product2Id IN: productIdSet AND PriceBook2Id =: newOrder.PriceBook2Id
                                     ]) {
                                         productIdToPriceBookEntryMap.put(pbe.Product2Id, pbe);
                                     }
            if (productIdToPriceBookEntryMap != null && productIdToPriceBookEntryMap.size() > 0) {
                system.debug('wrapperList*******'+JSON.serializePretty(wrapperList));
                for (object wrapperClassObj: wrapperList) {
                    Map < string, object > eachRecordMap = (map < string, object > ) wrapperClassObj;
                    if (productIdToPriceBookEntryMap.containsKey((string) eachRecordMap.get('productId'))) {
                        OrderItem orderProduct = new OrderItem();
                        orderProduct.OrderId = newOrder.Id;
                        orderProduct.PriceBookEntryId = productIdToPriceBookEntryMap.get((string) eachRecordMap.get('productId')).Id;
                        orderProduct.Quantity = Double.valueOf(eachRecordMap.get('quantity')) != null ? Double.valueOf(eachRecordMap.get('quantity')) : null;
                        orderProduct.UnitPrice = productIdToPriceBookEntryMap.get((string) eachRecordMap.get('productId')).UnitPrice;
                        OrderItemList.add(orderProduct);
                    }
                }
                
            }
            
            if (OrderItemList != null && OrderItemList.size() > 0) {
                insert OrderItemList;
            }
        }
        return newOrder;
    }
    
    public class WrapperClass {
        @AuraEnabled Public String productSKU                {get;set;}
        @AuraEnabled Public Id productId                     {get;set;}
        @AuraEnabled Public String description               {get;set;}
        @AuraEnabled Public Double quantity                  {get;set;}
        @AuraEnabled Public Boolean isSelected               {get;set;}
        @AuraEnabled Public Boolean isAvailable              {get;set;}
        public WrapperClass(String SKUName, String description, Double qty, Id productId, Boolean available) {
            this.productSKU = SKUName;
            this.quantity = qty;
            this.isSelected = true;
            this.description = description;
            this.productId = productId;
            this.isAvailable = available;
        }
    }
}