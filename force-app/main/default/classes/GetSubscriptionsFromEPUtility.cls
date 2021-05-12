public without sharing class GetSubscriptionsFromEPUtility {
    static final string REQ_HEADER_USER_ID_PARAM_NAME = 'x-ep-user-id';
    static final string REQ_HEADER_USER_ROLES_PARAM_NAME = 'x-ep-user-roles';
    static final string REQ_HEADER_USER_ROLES_PARAM_VALUE = 'REGISTERED';
    static final string REQ_HEADER_REQUEST_ID_PARAM_NAME = 'x-request-id';
    static final string REQ_HEADER_USER_SCOPES_PARAM_NAME = 'x-ep-user-scopes';
    static final string REQ_HEADER_API_KEY_PARAN_NAME = 'x-api-key';
    @AuraEnabled
    public static String doCancelSubscriptionAPI(String selectedBrand, String accountId, String subscriptionId)
    {
        String userId;
        String sfdc_business_unit = 'BUS';
        String strUserLanguage = 'en_us';
        system.debug('accountId:'+accountId);
        if (accountId != null)
        {
            List<User> users = [SELECT Id, Account.BusinessUnitFormula__c,LanguageLocaleKey FROM User WHERE Account_Id__c =: accountId];
            if ( users.isEmpty() ) {
                if (Test.isRunningTest())
                    userId = 'testUserId';
                else {
                    return 'User record does not exist for this Customer';
                }
            }
            else {
                userId = users.get(0).Id;
                strUserLanguage = users[0].LanguageLocaleKey;
                if (String.isNotBlank(users.get(0).AccountId) && String.isNotBlank(users.get(0).Account.BusinessUnitFormula__c))
                    sfdc_business_unit = users.get(0).Account.BusinessUnitFormula__c;
            }

        }        
        Business_Region_Mapping__mdt busRegion = [SELECT DeveloperName, Label, Business_Unit__c,Business_Unit_Beanz__c FROM 
                                                  Business_Region_Mapping__mdt WHERE DeveloperName =: sfdc_business_unit  LIMIT 1];
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:SubscriptionAPI');
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type','application/json');
        request.setHeader(REQ_HEADER_USER_ID_PARAM_NAME, userId);
        request.setHeader(REQ_HEADER_USER_ROLES_PARAM_NAME, REQ_HEADER_USER_ROLES_PARAM_VALUE);
        //request.setHeader(REQ_HEADER_USER_SCOPES_PARAM_NAME, selectedBrand.containsIgnoreCase('Beanz') ? busRegion.Business_Unit_Beanz__c : busRegion.Business_Unit__c);
        request.setHeader(REQ_HEADER_USER_SCOPES_PARAM_NAME, selectedBrand.containsIgnoreCase('Beanz') ? 'BrevilleUSMP':'BrevilleCA');
        request.setHeader(REQ_HEADER_REQUEST_ID_PARAM_NAME, getUUID());
        request.setHeader(REQ_HEADER_API_KEY_PARAN_NAME, '{!$Credential.Password}');
        
        request.setBody(payload(subscriptionId));
        Http http = new Http();
        HTTPResponse res = http.send(request);
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            return res.getBody();
        }else {
            throw new AuraHandledException('Error:Callout failed');
        }
    }
    public static String payload(String subscriptionId){
        return JSON.serialize(new Map<String,Object>{
            'standing-order-id' => subscriptionId,
            'standing-order-action' => 'Cancelled'                
       });
    }
    @AuraEnabled
    public static SubscriptionAPIWrapper getSubscriptions(String selectedBrand, String accountId, Integer pageSize, Integer pageNumber)
    {
        HttpRequest request = new HttpRequest();
        String userId;
        String sfdc_business_unit = 'BUS';
        SubscriptionAPIWrapper result = new SubscriptionAPIWrapper();
        String strUserLanguage = 'en_us';
        system.debug('accountId:'+accountId);

        if (accountId != null)
        {
            List<User> users = [SELECT Id, Account.BusinessUnitFormula__c,LanguageLocaleKey FROM User WHERE Account_Id__c =: accountId];
            System.debug ('Users: ' + users);

            if ( users.isEmpty() ) {
                if (Test.isRunningTest())
                    userId = 'testUserId';
                else {
                    result.status = 'ERROR';
                    result.Message = 'User record does not exist for this Customer';
                    return result;
                }
            }
            else {
                userId = users.get(0).Id;
                strUserLanguage = users[0].LanguageLocaleKey;
                if (String.isNotBlank(users.get(0).AccountId) && String.isNotBlank(users.get(0).Account.BusinessUnitFormula__c))
                    sfdc_business_unit = users.get(0).Account.BusinessUnitFormula__c;
            }

        }
        
        Business_Region_Mapping__mdt busRegion = [SELECT DeveloperName, Label, Business_Unit__c,Business_Unit_Beanz__c FROM 
                                                  Business_Region_Mapping__mdt WHERE DeveloperName =: sfdc_business_unit  LIMIT 1];
        
        request.setEndpoint('callout:SubscriptionAPI');
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setHeader(REQ_HEADER_USER_ID_PARAM_NAME, userId);
        request.setHeader(REQ_HEADER_USER_ROLES_PARAM_NAME, REQ_HEADER_USER_ROLES_PARAM_VALUE);
        //request.setHeader(REQ_HEADER_USER_SCOPES_PARAM_NAME, selectedBrand.containsIgnoreCase('Beanz') ? busRegion.Business_Unit_Beanz__c : busRegion.Business_Unit__c);
        request.setHeader(REQ_HEADER_USER_SCOPES_PARAM_NAME, selectedBrand.containsIgnoreCase('Beanz') ? 'BrevilleUSMP':'BrevilleCA');
        request.setHeader(REQ_HEADER_REQUEST_ID_PARAM_NAME, getUUID());
        request.setHeader(REQ_HEADER_API_KEY_PARAN_NAME, '{!$Credential.Password}');
        
        Http http = new Http();
        HTTPResponse res = http.send(request);
        if (res.getStatusCode() != 200)
        {
            result.status = 'ERROR';
            result.Message = 'Failed to get subscriptions for the User';
            System.debug ('Response: ' + res.getStatus());
            System.debug ('Response: ' + res.getBody());
            System.debug ('Response: ' + res.getStatusCode());
            return result;
        }
        System.debug ('Response: ' + res.getBody());
        SubscriptionsResponseModel resp = SubscriptionsResponseModel.parse(res.getBody());
        
        if (resp.data == null || resp.data.isEmpty())
        {
            result.status = 'SUCCESS';
            result.Message = 'No subscriptions exist for the User';
            return result;
        }
        Set<String> skuCodes = new Set<String>();
        List<Subscription> subscriptions = new List<Subscription>();
        system.debug('data**'+JSON.serializePretty(resp.data));
        for (SubscriptionsResponseModel.Data dt: resp.data)
        {
            Subscription recSubscription = new Subscription();
            recSubscription.id = dt.standingorderid;
            recSubscription.skuCode = doInsertEmpty(dt.skucode);
            recSubscription.quantity = dt.quantity != null ? dt.quantity : 0;
            recSubscription.description = dt.skudisplayname;
            recSubscription.status = doInsertEmpty(dt.status);
            recSubscription.currencyType = doInsertEmpty(dt.currencyType);
            recSubscription.totalAmount = dt.totalamount != null ? dt.totalamount : 0;
            recSubscription.storeCode = dt.storecode;
            Set<String> setOfBeanzCodes = new Set<String>{'brevilleUSMP'};            
            sfdc_business_unit = setOfBeanzCodes.contains(recSubscription.storeCode) ? 'BUS':'BCA';
            
            if (String.isNotBlank(dt.nextdeliverydate))
            {
                String nextdeliverydate = dt.nextdeliverydate;
                recSubscription.nextChargeDate = 
                    Date.newInstance(Integer.valueOf(nextdeliverydate.substringAfterLast('/')), 
                                     Integer.valueOf(nextdeliverydate.substringAfter('/').left(2)), 
                                     Integer.valueOf(nextdeliverydate.substringBefore('/')));
            }
            system.debug('UserInfo.getLanguage:'+UserInfo.getLanguage());
            String frequency;
            for (SubscriptionsResponseModel.Plandetails plan: dt.plandetails)
            {
                if (plan.selected == true)
                {
                    for (SubscriptionsResponseModel.Displayvalues displayValue : plan.displayvalues)
                    {
                        //if (displayValue.locale.equalsIgnoreCase(strUserLanguage))
                        if (displayValue.locale.startsWithIgnoreCase('en'))
                        {
                            frequency = displayValue.displayname;
                        }
                    }
                    recSubscription.discountAmount = plan.discountValue != null ? plan.discountValue : 0;
                    recSubscription.discountType = doInsertEmpty (plan.discountType);
                }
            }
            recSubscription.frequency = frequency;
            skuCodes.add(sfdc_business_unit + recSubscription.skuCode);
            System.debug (recSubscription.id + '|' + recSubscription.skuCode + '|' + recSubscription.description + '|' +
                          recSubscription.status + '|' +recSubscription.currencyType + '|' +recSubscription.quantity + '|' +
                          recSubscription.frequency);
            subscriptions.add(recSubscription);
            
        }
        System.debug('SKUCodes: ' + skuCodes);
        Map<String, Product2> skuCodeNameProductMap = new Map<String, Product2>();
        for (Product2 prd: [Select Id, AX_Item_Number__c, SKU__c, Name, Description from 
                            Product2 where AX_Unique_ID__c =: skuCodes ])
        {
            skuCodeNameProductMap.put(prd.AX_Item_Number__c, prd);
        }
        
        if (!skuCodeNameProductMap.isEmpty())
        {
            System.debug('SKUCode Product Map: ' + skuCodeNameProductMap);
            for (Subscription recSubscription: subscriptions)
            {
                Product2 prd = skuCodeNameProductMap.get(recSubscription.skuCode);
                if(prd!=null)
                {
                    recSubscription.description = prd.Description;
                    recSubscription.skuCode = prd.Name + '[' + prd.AX_Item_Number__c + ']'; 
                    System.debug ('Description: ' + recSubscription.description);
                }
            }
        }
        result.status = 'SUCCESS';
        result.subscriptions = subscriptions;
        return result;
    }
    
    //Method to get orders for a subscription
    @AuraEnabled
    public static List<SubscriptionOrder> getOrders(Integer subscriptionId)
    {
        String id = '' + subscriptionId;
        List<SubscriptionOrder> lstSubscriptionOrders = new List<SubscriptionOrder>();
        for(OrderItem objOrderItem: 
            [SELECT Order.OrderNumber,Order.WebSiteOrderId__c, Id, Product_SKU__c, Quantity, Product_Description__c,TotalPrice, 
             OrderId, Line_Item_Discount__c, EP_Standing_Order_Iteration__c, Order.Narvar_Tracking_Link__c, Order.Carrier_Link__c, 
             AX_Item_Number__c, EP_Standing_Order_Id__c,EP_Line_Tax__c,Order.ShippingCountryCode,TrackingNumbers__c,EP_Standing_Order_Frequency__c 
             FROM OrderItem WHERE EP_Standing_Order_Id__c =:id order by EP_Standing_Order_Iteration__c desc])
        {
            SubscriptionOrder objOrder = new SubscriptionOrder();
            objOrder.OrderId = objOrderItem.OrderId;
            objOrder.frequency = doInsertEmpty(objOrderItem.EP_Standing_Order_Frequency__c);
            objOrder.SubscriptionId = doInsertEmpty(objOrderItem.EP_Standing_Order_Id__c);
            objOrder.OrderNumber =  string.isBlank(objOrderItem.Order.WebSiteOrderId__c)?objOrderItem.Order.OrderNumber:objOrderItem.Order.WebSiteOrderId__c;
            objOrder.Product = doInsertEmpty(objOrderItem.Product_SKU__c + '[' + objOrderItem.AX_Item_Number__c + ']');
            objOrder.Description = doInsertEmpty(objOrderItem.Product_Description__c);
            objOrder.Quantity = objOrderItem.Quantity != null ? objOrderItem.Quantity : 0;
            Double LineItemTax = objOrderItem.EP_Line_Tax__c != null ? objOrderItem.EP_Line_Tax__c : 0;
            objOrder.Total = objOrderItem.TotalPrice != null ? objOrderItem.TotalPrice : 0;
            objOrder.Total += LineItemTax;
            objOrder.Total = objOrder.Total.setScale(2);
            objOrder.Discount = objOrderItem.Line_Item_Discount__c != null ? objOrderItem.Line_Item_Discount__c : 0;
            objOrder.Iteration = objOrderItem.EP_Standing_Order_Iteration__c  != null ? objOrderItem.EP_Standing_Order_Iteration__c : 0;
            objOrder.TrackingNumber = doInsertEmpty(objOrderItem.TrackingNumbers__c);
            if (objOrderItem.Order.ShippingCountryCode.equalsIgnoreCase('US'))
                objOrder.TrackingLink = doInsertEmpty(objOrderItem.Order.Narvar_Tracking_Link__c);
            else
                objOrder.TrackingLink = doInsertEmpty(objOrderItem.Order.Carrier_Link__c);
            lstSubscriptionOrders.Add(objOrder);
        }
        return lstSubscriptionOrders;
    }
    
    private static String doInsertEmpty(String fieldValue){
        return String.isNotBlank(fieldValue) ? fieldValue : '';
    }
    
    private static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
    
    public class Subscription {
        @AuraEnabled public Integer id {get;set;}
        @AuraEnabled public String skuCode {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Integer quantity {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Double totalAmount {get;set;}
        @AuraEnabled public String currencyType {get;set;}
        @AuraEnabled public String frequency {get;set;}
        @AuraEnabled public Date nextChargeDate {get;set;}
        @AuraEnabled public Double discountAmount{get;set;}
        @AuraEnabled public String discountType {get;set;}
        @AuraEnabled public String storeCode {get;set;}
    }
    
    public class SubscriptionAPIWrapper 
    {
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String Message {get;set;}
        @AuraEnabled public List<Subscription> subscriptions {get;set;}
    }
    
    public class SubscriptionOrder
    {
        @AuraEnabled public string SubscriptionId {get;set;}
        @AuraEnabled public string OrderNumber {get;set;}
        @AuraEnabled public string frequency {get;set;}
        @AuraEnabled public string Product {get;set;}
        @AuraEnabled public string Description {get;set;}
        @AuraEnabled public Decimal Quantity {get;set;}
        @AuraEnabled public Decimal Total {get;set;}
        @AuraEnabled public Double Discount {get;set;}
        @AuraEnabled public Double Iteration {get;set;}
        @AuraEnabled public string TrackingLink {get;set;}
        @AuraEnabled public String TrackingNumber {get;set;}
        @AuraEnabled public String OrderId {get;set;}
    }
}