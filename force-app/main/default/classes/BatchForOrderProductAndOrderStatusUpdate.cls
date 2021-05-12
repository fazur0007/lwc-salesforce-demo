global class BatchForOrderProductAndOrderStatusUpdate implements Database.Batchable <sObject>,Schedulable{
    
    	/* will be added later */
	global static void scheduleBatch(){
		String oncePerDay =  '0 30 5 ? * *';
       // String oncePerHour ='0 0 * ? * *';
        BatchForOrderProductAndOrderStatusUpdate orderAndOrderItemUpdateBatch = new BatchForOrderProductAndOrderStatusUpdate();
        String jobId = system.schedule('BatchForOrderProductAndOrderStatusUpdate Job',oncePerDay, orderAndOrderItemUpdateBatch);
    } 
    
    
      global void execute(SchedulableContext sc) {
        Database.executeBatch(this, 40);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        list<D365_DI_Region_Currency__mdt> currencyCode = [select Currency__c,Region__c from D365_DI_Region_Currency__mdt];
        list<String> currencylist = new list<String>();
        
        for(D365_DI_Region_Currency__mdt data:currencyCode){
            currencylist.add(data.Currency__c);          
        }
        
        Datetime dt = Datetime.now();
        DateTime dateBeforeTwoMonths = dt.addMonths(-2);
        String twoMonthsOldOrdersDate = dateBeforeTwoMonths.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
       
        String orderItmQuery='select id,Product2.name,Product2.AX_Item_number__C,orderId,LineStatus__c, Order.Brand__c,Order.Status,Order.Type,Order.ActivatedDate,Order.Sent_to_AX__c,Order.OrderNumber,Order.websiteordernumber__C, Order.CurrencyIsoCode, Order.AX_Order_ID__C,Order.Magic_Order_Id__c'+
            +' from OrderItem where LineStatus__c in (\'Shipped\',\'Invoiced\') AND Order.Status =\'Order Shipped\' and Order.AX_Order_ID__C !=NULL ' +
            +'and (Order.CurrencyIsoCode in :currencylist OR (Order.CurrencyIsoCode =\'USD\' and Order.Brand__c= \'Beanz\')) and Order.ActivatedDate >= '+twoMonthsOldOrdersDate +'';
            
          return Database.getQueryLocator(orderItmQuery);
    }
    global void execute(Database.BatchableContext BC,List<OrderItem> orderItemList)
    {       
       
        set<Id> orderIdSet= new set<ID>();
        List <OrderItem> orderItmUpdatedList = new List<OrderItem>();
        List<Order> orderUpdatedList = new List<Order>();
        
        for(OrderItem orderItm :orderItemList)
        {
            if(orderItm.LineStatus__c=='Shipped'){
                orderItm.LineStatus__c='Invoiced';
            }
            orderIdSet.add(OrderItm.orderId);
            orderItmUpdatedList.add(orderItm);
        }
        List<Id> orderList= new List<Id>();
        orderList.addAll(orderIdSet);
        
        for(Id odrId : orderList){
            Order odr= new Order(Id=odrId, Status='Invoiced');
            orderUpdatedList.add(odr);
        }
        Database.SaveResult[] results = Database.update(orderItmUpdatedList, false);
        for (Integer i = 0; i < orderItmUpdatedList.size(); i++) {
            if (!results[i].isSuccess()) {
                String errorMsg=results[i].errors[0].getMessage();            
            }
        }  
        
        Database.SaveResult[] orderResults = Database.update(orderUpdatedList, false);
        for (Integer i = 0; i < orderUpdatedList.size(); i++) {
            if (!results[i].isSuccess()) {
                String errorMsg=orderResults[i].errors[0].getMessage();           
            }
        }  
    }
    
    global void finish(Database.BatchableContext bc){
    }
}