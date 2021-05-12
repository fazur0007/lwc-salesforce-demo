global class BatchTriggerMulberryWarrantyRegistration implements Database.Batchable<Sobject>,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<Order> lstOrder = [select id from order where Count_warranty_registrations__c>0 and status in ('Invoiced','Order Shipped') and warr_Order_ID__c=''];
        system.debug('Total record count:'+lstOrder.size());
        return Database.getQueryLocator('select id,Total_Invoiced_Product__c,xTotalProducts__c,OrderNumber from order where (Count_warranty_registrations__c>0 or Asset__c!=\'\') and status in (\'Invoiced\',\'Order Shipped\') and warr_Order_ID__c=\'\'');
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
        system.debug('Test inside execute');
        for(Sobject currOrder:scope)
        {
            Order currentOrderForProcessing = (Order)currOrder;     
            if(currentOrderForProcessing.xTotalProducts__c==currentOrderForProcessing.Total_Invoiced_Product__c)
            {
                MulberryAPIHelper.CreateWarranty(currentOrderForProcessing.Id);
                system.debug('Order Id:'+currentOrderForProcessing.Id);
            }
            else 
            {
                system.debug('Not all order products are invoiced hence ingnoring the order in batch:'+ currentOrderForProcessing.Id + ',Ordernumber:' + currentOrderForProcessing.OrderNumber);    
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Test inside final');
    }

}