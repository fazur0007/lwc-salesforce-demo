public class SubscriptionManagementUtility {
    public static void createSubscriptionRecords( Map<Id, Order> offerOrderIdToOrderInsertMap,
                                                 Map<Id,Asset> mapAssetIdWithAsset) {
    
        Map<Id,Order> orderIdtoOrderRecordMap = new Map<Id,Order>();
        Map<Id,ContactPointAddress > orderIdtoContactPointAddressRecordMap = new Map<Id,ContactPointAddress >();

        for (Order ord : offerOrderIdToOrderInsertMap.values()) {
            ContactPointAddress contactPointAddrss = new ContactPointAddress(
                ParentId = ord.AccountId ,
                IsDefault = false,
                Name = ord.Ship_To_Name__c ,
                AddressType = 'Subscription',
                Street = ord.ShippingStreet,
                City = ord.ShippingCity ,
                PostalCode = ord.ShippingPostalCode,
                State = ord.ShippingState,
                Country = ord.ShippingCountry
            );
            orderIdtoContactPointAddressRecordMap.put(ord.id, contactPointAddrss);
            orderIdtoOrderRecordMap.put(ord.id, ord);
        } 
        try{
            if (!orderIdtoContactPointAddressRecordMap.values().isEmpty()) {
                Database.insert(orderIdtoContactPointAddressRecordMap.values(), false);
            }
        }catch(Exception ex){
            System.debug (ex.getMessage());
            System.debug (ex.getStackTraceString());
            System.debug (ex.getLineNumber());
        }
        Map<Id,PricebookEntry> priceBookEntryIdToPriceBookEntryMap = new  Map<Id,PricebookEntry>();
        Set<String> priceBookEntryId = new Set<String>();
        for(Offer_Order_Items__c record : [SELECT Id,
                                           Offer_Order__c,
                                           IsSubscription__c,
                                           PriceBook__c,
                                           PriceBookEntryId__c, 
                                           Quantity__c,
                                           Product__c,
                                           Subscription_frequency_Duration__c,
                                           Subscription_frequency__c
                                           FROM Offer_Order_Items__c
                                           WHERE Offer_Order__c IN: offerOrderIdToOrderInsertMap.keySet()
                                           AND IsSubscription__c = true
                                           ]){
            priceBookEntryId.add(record.PriceBookEntryId__c);      

        }
        priceBookEntryIdToPriceBookEntryMap = new Map<Id,PricebookEntry>([Select Id,UnitPrice FROM PriceBookEntry WHERE Id IN :priceBookEntryId ]);
        List<Subscription__c> subscriptionListToInsert = new List<Subscription__c>();
        User loggedInuser = [SELECT Id, Exp_ID__c, accountId FROM User WHERE Id =: UserInfo.getUserId()];

        for(Offer_Order_Items__c record : [SELECT Id,
                                           Offer_Order__c,
                                           IsSubscription__c,
                                           PriceBook__c,
                                           PriceBookEntryId__c, 
                                           Quantity__c,
                                           Product__c,
                                           Subscription_frequency_Duration__c,
                                           Subscription_Iterations__c,
                                           Subscription_frequency__c
                                           FROM Offer_Order_Items__c
                                           WHERE Offer_Order__c IN: offerOrderIdToOrderInsertMap.keySet() 
                                           AND IsSubscription__c = true
                                           ]){
            Subscription__c subscription = new Subscription__c();
            subscription.Account__c = orderIdtoOrderRecordMap.get(offerOrderIdToOrderInsertMap.get(record.Offer_Order__c).Id).AccountId;
            subscription.Frequency_Duration__c = record.Subscription_frequency_Duration__c;
            subscription.Iteration_Count__c =1;
            subscription.Maximum_iterations__c = record.Subscription_Iterations__c;
            subscription.Frequency_Type__c = record.Subscription_frequency__c;
            subscription.Last_Run_Date__c = Date.Today();
            
            subscription.Product__c = record.Product__c;
            subscription.Quantity__c = record.Quantity__c;
            subscription.Source_order__c = offerOrderIdToOrderInsertMap.get(record.Offer_Order__c).Id;
            Order currOrder = offerOrderIdToOrderInsertMap.get(record.Offer_Order__c);                                          
            Asset currAsset = mapAssetIdWithAsset.get(currOrder.Asset__c);
            subscription.Gift_Code__c =  currAsset.Asset_code__c;                                    
            subscription.Status__c = 'Active';
             //insert contact point address - Account as Parent, address fields,  Address Type = Subscription
            subscription.Subscription_Shipping_Address__c = orderIdtoContactPointAddressRecordMap.get(offerOrderIdToOrderInsertMap.get(record.Offer_Order__c).Id).Id;
            subscription.Unit_Price__c = priceBookEntryIdToPriceBookEntryMap.get(record.PriceBookEntryId__c).UnitPrice ;
            subscription.Next_Run_Date__c = OrderManagementUtility.getNexRunDate(subscription);
            subscription.Asset__c = currAsset.Id;
            subscriptionListToInsert.add(subscription);

        }
        try{
            if (!subscriptionListToInsert.isEmpty()) {
                Database.insert(subscriptionListToInsert, false);
            }
        }catch(Exception ex){
            System.debug (ex.getMessage());
            System.debug (ex.getStackTraceString());
            System.debug (ex.getLineNumber());
        }
    }
}