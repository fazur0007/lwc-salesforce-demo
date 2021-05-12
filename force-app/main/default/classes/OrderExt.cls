public with sharing class OrderExt {
    
    public Order oId{get;set;}
    public Account acc{get;set;}
    public Order ordr{get;set;}
    public boolean isUSA {get; set;}
    public boolean isAUD {get; set;}
    
    public OrderExt(ApexPages.StandardController controller) {
        
        isUSA = false;
        isAUD = false;
        
        oId = (Order)controller.getRecord();
        ordr = [SELECT id, AccountId, Name,GST_Tax_Rate__c, Order_List_Price__c, Order_Discount_Amount__c, Order_Grand_Total__c, Tax__c, Carrier__c, AX_Order_Account__c, EffectiveDate, EndDate, Shipping_Amount__c, AX_Order_ID__c, Magic_Order_ID__c, (SELECT id, PricebookEntry.Product2.Name, QuantityShipped__c, Item_Discount__c, List_Price_Subtotal__c, PricebookEntry.Product2.Description,Product_Description__c, OrderItemNumber, Quantity,PricebookEntry.Product2.ProductCode, UnitPrice FROM OrderItems) FROM Order WHERE id =: oId.Id];
        acc = [select name, CurrencyIsoCode, BillingCity,BillingPostalCode, BillingStreet, BillingState, BillingCountry, Phone, Fax , 
																ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, SalesGroup__c
																from Account where id =: ordr.AccountId];
        
        
        if(acc.CurrencyIsoCode == 'USD'){
        	isUSA = true;
        }else if(acc.CurrencyIsoCode == 'AUD'){
        	isAUD = true;
        }else{
        	isUSA = true;
        }
        
        system.debug('Order Id'+oId);
        system.debug('Order '+ordr);
        system.debug('Account '+acc);
        system.debug('Order Items '+ordr.OrderItems);
    }
}