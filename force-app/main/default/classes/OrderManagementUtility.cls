public class OrderManagementUtility 
{    
    public static Order createOrderRecord(Account recAcct, Id contactId, Asset recAsset,String brand, String source, Id pricebookId,Offer_Order__c offerOrder)
    {
        Order orderRecord = new Order();
        orderRecord.AccountId = recAcct.Id;
        orderRecord.BillToContactId = contactId;
        orderRecord.Status = 'Open';
        orderRecord.Source__c = source;
        orderRecord.Type = 'Sale';
        
        orderRecord.Brand__c = brand;
        orderRecord.EffectiveDate = Date.today();
        
        //GWP promtions - Map the original asset to the GWP order
        if (recAsset != null && recAsset.Id != null) {                                       
            orderRecord.Asset__c = recAsset.Id;
            orderRecord.AppliedOfferCode__c = recAsset.Offer_Code_Applied__c;
            orderRecord.ExactOfferCode__c = offerOrder.Offer__r.OfferCode__c;
        }
        system.debug('recAsset.CreatedDate.date()>>>>'+recAsset.CreatedDate.date());
        system.debug('Integer.valueOf(offerOrder.ActivateOrderOnNDay__c)>>>'+Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
        //orderRecord.Offer_Activation_Date__c = 
        //  assetRecord.PurchaseDate.addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
        orderRecord.Offer_Activation_Date__c = 
            recAsset.CreatedDate.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
        DateTime dateTimeRecord;
        if(recAsset.PurchaseDate != null){
            dateTimeRecord = recAsset.PurchaseDate;
        }else{
            dateTimeRecord = recAsset.CreatedDate;
        }
        if(dateTimeRecord.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c)) <= Date.TODAY()){
            orderRecord.Offer_Activation_Date__c = Date.TODAY().addDays(1);
        }else{
            orderRecord.Offer_Activation_Date__c = dateTimeRecord.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
        }
        
        orderrecord.PriceBook2Id = pricebookId;
        orderrecord.CurrencyIsoCode = offerOrder.CurrencyIsoCode;
        String region = Utility.regionBased(orderrecord.CurrencyIsoCode);
        orderRecord.Shipping_Method__c = getDefaultShippingMethod(offerOrder.CurrencyIsoCode);
        if(String.isNotBlank (region)){
            orderRecord.Country__c = region;
        }
        
        if(offerOrder.AX_Order_Account__c != null){
            orderrecord.AX_Order_Account__c = offerOrder.AX_Order_Account__c;
            orderrecord.OverrideAXAccNum__c = true;
        }
        
        orderRecord.BillingCountryCode = recAcct.BillingCountryCode;
        orderRecord.BillingStateCode = recAcct.BillingStateCode;
        orderRecord.BillingPostalCode = recAcct.BillingPostalCode;
        orderRecord.BillingCity = recAcct.BillingCity;
        orderRecord.BillingStreet = recAcct.BillingStreet;
        orderRecord.Ship_To_Name__c = recAcct.Name;
        
        if (String.isBlank(recAcct.ShippingCountryCode) || String.isBlank (recAcct.ShippingPostalCode) ||
            String.isBlank (recAcct.ShippingStreet) || String.isBlank (recAcct.ShippingCity) ||
            String.isBlank (recAcct.ShippingStateCode))
        {
            orderRecord.ShippingCountryCode = recAcct.BillingCountryCode;
            orderRecord.ShippingCity = recAcct.BillingCity;
            orderRecord.ShippingPostalCode = recAcct.BillingPostalCode;
            orderRecord.ShippingStateCode = recAcct.BillingStateCode;
            orderRecord.ShippingStreet = recAcct.BillingStreet;
        }
        else {
            orderRecord.ShippingCountryCode = recAcct.ShippingCountryCode;
            orderRecord.ShippingCity = recAcct.ShippingCity;
            orderRecord.ShippingPostalCode = recAcct.ShippingPostalCode;
            orderRecord.ShippingStateCode = recAcct.ShippingStateCode;
            orderRecord.ShippingStreet = recAcct.ShippingStreet;
        }
        return orderRecord;
    }
    
    public static void createSubscriptionOrder(Id SubscriptionId){
        system.debug('Inside >>>>'+SubscriptionId);
        //Subscription__c currSubscriptionRecord = [select Id from Subscription__c]; 
        Subscription__c currSubscriptionRecord = [select Account__c,Unit_Price__c,Gift_Code__c,Product__c,Quantity__c,Source_order__c,Subscription_Shipping_Address__c,Maximum_iterations__c,Iteration_Count__c,Next_Run_Date__c,Frequency_Duration__c,Frequency_Type__c,Last_Run_Date__c from Subscription__c  where id=:SubscriptionId limit 1]; 
        system.debug('currSubscriptionRecord>>>>'+currSubscriptionRecord);
        Order SourceOrder = [select id,AccountId,BillToContactId,Source__c,Type,Brand__c,Asset__c,AppliedOfferCode__c,ExactOfferCode__c,PriceBook2Id,CurrencyIsoCode,Shipping_Method__c,AX_Order_Account__c,OverrideAXAccNum__c  from order where id=:currSubscriptionRecord.Source_order__c limit 1];
        Account recAcct = [select id,ShippingCountryCode,ShippingPostalCode,ShippingStreet,ShippingCity,ShippingStateCode,BillingCountryCode,BillingStateCode,BillingPostalCode,BillingCity,BillingStreet,Name from Account where id=:currSubscriptionRecord.Account__c limit 1]; 
        Order orderRecord = new Order();
        orderRecord.AccountId = recAcct.Id;
        orderRecord.BillToContactId = SourceOrder.BillToContactId;
        orderRecord.Status = 'Open';
        orderRecord.Source__c = SourceOrder.Source__c;
        orderRecord.Type = SourceOrder.Type;
        
        orderRecord.Brand__c = SourceOrder.Brand__c;
        orderRecord.EffectiveDate = Date.today();
        
        orderRecord.Asset__c = SourceOrder.Asset__c;
        orderRecord.AppliedOfferCode__c = SourceOrder.AppliedOfferCode__c;
        orderRecord.ExactOfferCode__c = SourceOrder.ExactOfferCode__c;
        orderRecord.Offer_Activation_Date__c =  system.today();
        
        orderrecord.PriceBook2Id = SourceOrder.PriceBook2Id;
        orderrecord.CurrencyIsoCode = SourceOrder.CurrencyIsoCode;
        String region = Utility.regionBased(orderrecord.CurrencyIsoCode);
        orderRecord.Shipping_Method__c = getDefaultShippingMethod(orderrecord.CurrencyIsoCode);
        if(String.isNotBlank (region)){
            orderRecord.Country__c = region;
        }
        
        orderrecord.AX_Order_Account__c = SourceOrder.AX_Order_Account__c;
        orderrecord.OverrideAXAccNum__c = true;
        
        orderRecord.BillingCountryCode = recAcct.BillingCountryCode;
        orderRecord.BillingStateCode = recAcct.BillingStateCode;
        orderRecord.BillingPostalCode = recAcct.BillingPostalCode;
        orderRecord.BillingCity = recAcct.BillingCity;
        orderRecord.BillingStreet = recAcct.BillingStreet;
        orderRecord.Ship_To_Name__c = recAcct.Name;
        
        orderRecord.ShippingCountryCode = recAcct.ShippingCountryCode;
        orderRecord.ShippingCity = recAcct.ShippingCity;
        orderRecord.ShippingPostalCode = recAcct.ShippingPostalCode;
        orderRecord.ShippingStateCode = recAcct.ShippingStateCode;
        orderRecord.ShippingStreet = recAcct.ShippingStreet;

        insert orderRecord;
        PriceBookEntry currPBE = [select id from PriceBookEntry where Pricebook2Id=:SourceOrder.PriceBook2Id and Product2Id=:currSubscriptionRecord.Product__c limit 1];
        OrderItem currOrderItem = createOrderItemRecord(orderRecord.Id,currPBE.Id,currSubscriptionRecord.Quantity__c,currSubscriptionRecord.Unit_Price__c);
        insert currOrderItem;   
        If(currSubscriptionRecord.Iteration_Count__c!=null)
            currSubscriptionRecord.Iteration_Count__c = currSubscriptionRecord.Iteration_Count__c+1;
        else
            currSubscriptionRecord.Iteration_Count__c = 1;
        currSubscriptionRecord.Last_Run_Date__c = System.Date.today();
        //If(getNexRunDate(currSubscriptionRecord)!=null)            
            currSubscriptionRecord.Next_Run_Date__c = getNexRunDate(currSubscriptionRecord);
        if(currSubscriptionRecord.Next_Run_Date__c == null)
            currSubscriptionRecord.Status__c = 'Completed';
        update currSubscriptionRecord;
    }
    
    public static OrderItem createOrderItemRecord(Id orderId, Id priceBookEntryId, Decimal quantity, Decimal unitPrice)
    {
        OrderItem recOrderItem = new OrderItem();
        recOrderItem.OrderId = orderId;
        recOrderItem.PriceBookEntryId = priceBookEntryId;
        recOrderItem.Quantity = quantity;
        recOrderItem.UnitPrice = unitPrice;
        return recOrderItem;
    }
        
    private static String getDefaultShippingMethod (String currencyCode)
    {
        String shippingMethod = '';        
        for(Region_Specific__mdt recConfig:[SELECT DeveloperName, Currency__c,DefaultShippingMethod__c FROM Region_Specific__mdt WHERE Currency__c =: currencyCode ])
        {
            shippingMethod = recConfig.DefaultShippingMethod__c;
        }
        return shippingMethod;
    }
    
    public static date getNexRunDate(Subscription__c currSubscriptionRecord)
    {
        //Maximum_iterations__c,Iteration_Count__c,Next_Run_Date__c,Frequency_Duration__c,Frequency_Type__c,Last_Run_Date__c
        Date nextRunDate = null;
        if(currSubscriptionRecord.Iteration_Count__c < currSubscriptionRecord.Maximum_iterations__c)
        {
            integer iNumberOfDaysToAdd=1;
            switch on currSubscriptionRecord.Frequency_Type__c
            {
                when 'Month' {                    
                    nextRunDate = System.Date.today().addMonths(Integer.valueOf(currSubscriptionRecord.Frequency_Duration__c));
                }   
                when 'Week' {
                    iNumberOfDaysToAdd = Integer.valueOf(currSubscriptionRecord.Frequency_Duration__c*7);
                    nextRunDate = System.Date.today().addDays(iNumberOfDaysToAdd);
                }
                when 'Day' {                    
                    nextRunDate = System.Date.today().addDays(iNumberOfDaysToAdd);
                }
                when else {
                    nextRunDate = System.Date.today().addDays(iNumberOfDaysToAdd);
                }
            }            
        }
        return nextRunDate;
    }
}