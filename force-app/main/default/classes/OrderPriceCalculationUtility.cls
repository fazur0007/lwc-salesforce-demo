global class OrderPriceCalculationUtility{
    WebService static void calculatePriceUtility(Id orderRecord){
        list<Order> newOrderRecord = new list<Order>();
        list<OrderItem> updatedOrderItemList = new list<OrderItem>();
        list<OrderItem> orderItemsList = [select id, Quantity, Order.Id, Order.RequestedShipDate__c, Order.CurrencyIsoCode, 
                                          Order.PODate, Order.EndDate,PricebookEntry.Product2.AX_Item_Number__c, AX_Item_Number__c 
                                          from OrderItem where Order.Id=:orderRecord];       
        
        newOrderRecord = [select id, AccountId, CurrencyIsoCode, recordtypeId, ShippingPostalCode, ShippingStateCode, ShippingCountryCode,
        					 PODate, CitySalesTaxRate__c, CountySalesTaxRate__c, Provincial_Tax_Rate__c, SpecialSalesTaxRate__c, RequestedShipDate__c,
        					Sales_Tax_Rate__c from Order where id=:orderRecord];
        					
       if(orderItemsList != null && orderItemsList.size()>0){     					
            if(newOrderRecord != null && newOrderRecord.size()>0){
                list<Account> accountRecord = [select id, DataAreaID__c, VendAccount__c, BusinessUnitFormula__c from Account where id=:newOrderRecord[0].AccountId];
                if(accountRecord != null && accountRecord.size()>0){
                	if(newOrderRecord[0].CurrencyIsoCode == 'EUR' || newOrderRecord[0].CurrencyIsoCode == 'CHF'){
                		updatedOrderItemList = AXProductPriceConnector.calculatePriceD365(orderItemsList,accountRecord[0]);
                	}else{
                    	updatedOrderItemList = AXProductPriceConnector.calculatePrice(orderItemsList,accountRecord[0]);
                	}
                }
             }
        }
        
        newOrderRecord[0].IsCalculated__c=true;
        TaxRate taxRate = new TaxRate();
        //taxRate.filterOrders(newOrderRecord[0]);
        if (!Test.isRunningTest()) {
	        update updatedOrderItemList;
	        update newOrderRecord[0];         
        }        
    }
}