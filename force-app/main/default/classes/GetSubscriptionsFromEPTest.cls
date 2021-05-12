@isTest
public class GetSubscriptionsFromEPTest {
    
    public static Integer subscriptionId = 10;
    @testSetup
    static void createTestRecords () {
        Account acct = new Account();
        acct.Name = 'TestCompany';
        acct.CurrencyIsoCode = 'USD';
        insert acct;
        
        Account recAccount = [Select Id, Name from Account LIMIT 1];
      
        Product2 product = new Product2();
        product.Name = 'TestProd';
        product.IsActive = true;
        product.Description = 'Coffee beans';
        product.AX_Item_Number__c = 'SP0000031';
        product.AX_Unique_ID__c='BUSSP0000031';
        product.SKU__c = 'TestProd';
        insert product;
        
        Product2 recProduct = [Select Id from Product2 LIMIT 1];
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.UnitPrice = 10;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = product.Id;
        insert pbEntry;
        
        PricebookEntry recPriceBookEntry = [Select Id from PricebookEntry];
        
        Order recOrder = new Order();
        recOrder.AccountId = recAccount.Id;
        recOrder.EffectiveDate = System.today();
        recOrder.Status = 'Open';
        recOrder.Pricebook2Id = Test.getStandardPricebookId();
        recOrder.ShippingCountryCode = 'US';
        insert recOrder;
        
        Order recOrderObj = [Select Id, Name from Order LIMIT 1];
        
        OrderItem recOrderItem = new OrderItem();
        recOrderItem.OrderId = recOrderObj.Id;
        recOrderItem.EP_Standing_Order_Id__c = '' + subscriptionId;
        recOrderItem.PricebookEntryId = recPriceBookEntry.Id;
        recOrderItem.UnitPrice = 10;
        recOrderItem.Quantity = 1;
        insert recOrderItem;
    }

    @isTest
    static void getSubscriptionsTestSuccess() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ViewSubscriptionsAPIMock');
        mock.setStatusCode(200);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        Account recAccount = [Select Id, Name from Account LIMIT 1];
        GetSubscriptionsFromEPUtility.SubscriptionAPIWrapper result = GetSubscriptionsFromEPUtility.getSubscriptions('BrevilleCA',recAccount.Id, null, null);
        GetSubscriptionsFromEPUtility.doCancelSubscriptionAPI('BrevilleCA',recAccount.Id,'11654');
        Test.stopTest();
        
        System.assertEquals(5, result.subscriptions.size(), 'Subscription Count do not match');
    }
    
    @isTest
    static void getSubscriptionsNoDataTestSuccess() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ViewSubscriptionsAPI_Nodata_Mock');
        mock.setStatusCode(200);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        Account recAccount = [Select Id, Name from Account LIMIT 1];
        GetSubscriptionsFromEPUtility.SubscriptionAPIWrapper result = GetSubscriptionsFromEPUtility.getSubscriptions('BrevilleCA',recAccount.Id, null, null);
        Test.stopTest();
        
        System.assertEquals(null, result.subscriptions, 'Subscription Count do not match');
    }
    
    @isTest
    static void getSubscriptionOrdersTestSuccess() {
        List<GetSubscriptionsFromEPUtility.SubscriptionOrder> orderItems = GetSubscriptionsFromEPUtility.getOrders(subscriptionId);
        System.assertEquals(1, orderItems.size(), 'Order Count do not match');
    }
}