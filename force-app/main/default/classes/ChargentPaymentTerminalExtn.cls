public without sharing class ChargentPaymentTerminalExtn {
    
    
    public ChargentOrders__ChargentOrder__c chargentOrder   {get;set;}
    private String paymentOrderId;
    public String objectAPIName                             {get;set;}
    
    public ChargentPaymentTerminalExtn(ApexPages.StandardController stdController) {
        this.chargentOrder = (ChargentOrders__ChargentOrder__c)stdController.getRecord();
        paymentOrderId = ApexPages.currentPage().getParameters().get('order_id');
        objectAPIName = '';
        chargentOrder.ChargentOrders__Date__c = Datetime.now();
        chargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
        chargentOrder.ChargentOrders__Manual_Charge__c = true;
        if(paymentOrderId != null && paymentOrderId != ''){
            objectAPIName = Id.valueOf(paymentOrderId).getSObjectType().getDescribe().getName();
            if(objectAPIName == 'Order'){
                populateChargentOrderFromSFOrder();
            }else if(objectAPIName == 'WorkOrder'){
                populateChargentOrderFromWorkOrder();
            }
        }
        populateCurreny();
        getDefaultGetWayId();
        
    }
      public ChargentPaymentTerminalExtn(Id orderId) {
        chargentOrder = new ChargentOrders__ChargentOrder__c();
        paymentOrderId = orderId;
        objectAPIName = '';
        chargentOrder.ChargentOrders__Date__c = Datetime.now();
        chargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
        chargentOrder.ChargentOrders__Manual_Charge__c = true;
        if(paymentOrderId != null && paymentOrderId != ''){ 
            objectAPIName = Id.valueOf(paymentOrderId).getSObjectType().getDescribe().getName();
            if(objectAPIName == 'Order'){
                populateChargentOrderFromSFOrder();
            }else if(objectAPIName == 'WorkOrder'){
                populateChargentOrderFromWorkOrder();
            }
        }
        populateCurreny();
        getDefaultGetWayId();
        
    }
    
    private void populateChargentOrderFromSFOrder(){
        
        map<String,String> orderFieldMapping = getOrderFieldMappingForOrder();
        //to remove duplicate entry
        Set<String> OrderFieldsSet = new Set<String>(orderFieldMapping.values());
        list<String> OrderFields = new list<String>(OrderFieldsSet);
        String soql = ''
                        + ' select ' + String.join(OrderFields, ',')
                        + ' from Order'
                        + ' where id =:paymentOrderId';
        list<Order> orderList = Database.query(soql);
        system.debug('Order List:'+orderList);
        if(orderList != null && orderList.size() > 0){
            mapFieldValues(orderFieldMapping,orderList[0]);
        }
        
    }
    private void populateCurreny(){
         list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT ChargentCurrency__c 
                                                                    FROM Region_Specific__mdt
                                                                    WHERE Currency__c =: chargentOrder.CurrencyIsoCode LIMIT 1];
            
        if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
            chargentOrder.ChargentOrders__Currency__c = RegionSpecificCurrencyCode[0].ChargentCurrency__c;
        }
        
    }
     private void populateChargentOrderFromWorkOrder(){
        
        map<String,String> workOrderFieldMapping = getWorkOrderFieldMappingForOrder();
        Set<String> workOrderFieldsSet = new Set<String>(workOrderFieldMapping.values());
        list<String> workOrderFields = new list<String>(workOrderFieldsSet);
        workOrderFields.add('SalesTax__c'); 
        workOrderFields.add('UsedServiceTax__c');
        String soql = ''
                        + ' select ' + String.join(workOrderFields, ',')
                        + ' from WorkOrder'
                        + ' where id =:paymentOrderId';
        list<WorkOrder> workOrderList = Database.query(soql);
        if(workOrderList != null && workOrderList.size() > 0){
            mapFieldValues(workOrderFieldMapping,workOrderList[0]);
        
            chargentOrder.ChargentOrders__Tax__c = workOrderList[0].SalesTax__c+workOrderList[0].UsedServiceTax__c;
        }
    }
    private void mapFieldValues(map<String,String> orderFieldMapping,SObject objectRecord){
        String orderField = '';
        for(String chargentOrderField : orderFieldMapping.keySet()){
            orderField = orderFieldMapping.get(chargentOrderField);
            if(!orderField.contains('.')){
                chargentOrder.put(chargentOrderField,objectRecord.get(orderField));
            }else{
                String[] referenceFields = orderField.split('\\.');
                if(objectRecord.getSobject(referenceFields[0]) != null){
                    chargentOrder.put(chargentOrderField,objectRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
                    
                }
            }
            
        }
    }
    public map<String,String> getOrderFieldMappingForOrder(){
        map<String,String> orderFieldMap = new  map<String,String>();
        orderFieldMap.put('ChargentOrders__Account__c','AccountId');
        orderFieldMap.put('ChargentOrders__Billing_First_Name__c','BillToContact.FirstName');
        orderFieldMap.put('ChargentOrders__Billing_Last_Name__c','BillToContact.LastName');
        orderFieldMap.put('ChargentOrders__Billing_City__c','BillingCity');
        orderFieldMap.put('ChargentOrders__Billing_Country__c','BillingCountryCode');
        orderFieldMap.put('ChargentOrders__Billing_Zip_Postal__c','BillingPostalCode');
        orderFieldMap.put('ChargentOrders__Billing_State__c','BillingStateCode');
        orderFieldMap.put('ChargentOrders__Billing_Address__c','BillingStreet');
        //orderFieldMap.put('ChargentOrders__Shipping_First_Name__c','Ship_to_Name_Formula__c');
        orderFieldMap.put('ChargentOrders__Shipping_Name__c','Ship_to_Name_Formula__c');
        orderFieldMap.put('ChargentOrders__Shipping_Country__c','ShippingCountryCode');
        orderFieldMap.put('ChargentOrders__Shipping_City__c','ShippingCity');
        orderFieldMap.put('ChargentOrders__Shipping_Zip_Postal__c','ShippingPostalCode');
        orderFieldMap.put('ChargentOrders__Shipping_State__c','ShippingStateCode');
        orderFieldMap.put('ChargentOrders__Shipping_Address__c','ShippingStreet');
        orderFieldMap.put('ChargentOrders__Billing_Phone__c','Account.Phone');
        orderFieldMap.put('ChargentOrders__Billing_Email__c','Account.PersonEmail');
        orderFieldMap.put('ChargentOrders__Billing_Fax__c','Account.Fax');
        orderFieldMap.put('CurrencyIsoCode','CurrencyIsoCode');
        orderFieldMap.put('Order__c','Id');
        orderFieldMap.put('ChargentOrders__Invoice_Number__c','OrderNumber');
        orderFieldMap.put('ChargentOrders__Tax__c','Tax__c');
        orderFieldMap.put('ChargentOrders__Shipping__c','Shipping_Amount__c');
        orderFieldMap.put('ChargentOrders__Charge_Amount__c','Amount_for_Authorization__c');
        orderFieldMap.put('ChargentOrders__Subtotal__c','TotalAmount');
        return orderFieldMap;
    }
    public map<String,String> getWorkOrderFieldMappingForOrder(){
        map<String,String> orderFieldMap = new  map<String,String>();
        orderFieldMap.put('ChargentOrders__Account__c','AccountId');
        orderFieldMap.put('ChargentOrders__Billing_First_Name__c','Account.FirstName');
        orderFieldMap.put('ChargentOrders__Billing_Last_Name__c','Account.LastName');
        orderFieldMap.put('ChargentOrders__Billing_City__c','Account.BillingCity');
        orderFieldMap.put('ChargentOrders__Billing_Country__c','Account.BillingCountryCode');
        orderFieldMap.put('ChargentOrders__Billing_Zip_Postal__c','Account.BillingPostalCode');
        orderFieldMap.put('ChargentOrders__Billing_State__c','Account.BillingStateCode');
        orderFieldMap.put('ChargentOrders__Billing_Address__c','Account.BillingStreet');
        orderFieldMap.put('ChargentOrders__Shipping_First_Name__c','Account.FirstName');
        orderFieldMap.put('ChargentOrders__Shipping_Name__c','Account.LastName');
        orderFieldMap.put('ChargentOrders__Shipping_Country__c','Account.ShippingCountryCode');
        orderFieldMap.put('ChargentOrders__Shipping_City__c','Account.ShippingCity');
        orderFieldMap.put('ChargentOrders__Shipping_Zip_Postal__c','Account.ShippingPostalCode');
        orderFieldMap.put('ChargentOrders__Shipping_State__c','Account.ShippingStateCode');
        orderFieldMap.put('ChargentOrders__Shipping_Address__c','Account.ShippingStreet');
        orderFieldMap.put('ChargentOrders__Billing_Phone__c','Account.Phone');
        orderFieldMap.put('ChargentOrders__Billing_Email__c','Account.PersonEmail');
        orderFieldMap.put('ChargentOrders__Billing_Fax__c','Account.Fax');
        orderFieldMap.put('CurrencyIsoCode','CurrencyIsoCode');
        orderFieldMap.put('WorkOrder__c','Id');
        orderFieldMap.put('ChargentOrders__Invoice_Number__c','WorkOrderNumber');
        //orderFieldMap.put('ChargentOrders__Tax__c','Tax__c');
        //orderFieldMap.put('ChargentOrders__Shipping__c','Shipping_Amount__c');
        orderFieldMap.put('ChargentOrders__Charge_Amount__c','AmountPayablebyCustomer__c');
        orderFieldMap.put('ChargentOrders__Subtotal__c','AmountPayablebyCustomer__c');
        return orderFieldMap;
    }
    public void getDefaultGetWayId(){
        if(chargentOrder.CurrencyIsoCode != null){
            list<Region_Specific__mdt> RegionSpecificGatewayIds = [SELECT DeveloperName, DefaultGatewayId__c FROM Region_Specific__mdt 
                                                                            WHERE Currency__c =: chargentOrder.CurrencyIsoCode 
                                                                    LIMIT 1];
            
            if(RegionSpecificGatewayIds != null && RegionSpecificGatewayIds.size() > 0 && RegionSpecificGatewayIds[0].DefaultGatewayId__c != null){
                chargentOrder.ChargentOrders__Gateway__c = RegionSpecificGatewayIds[0].DefaultGatewayId__c;
            }
        }
    }
}