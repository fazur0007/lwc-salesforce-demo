@isTest
public class BrevilleCommunityOrdersRESTResourceTest {
    public static Integer subscriptionId = 10;

    static void createTestRecords (String orderStatus, String brand, String source) {
        Account acct = new Account();
        acct.Name = 'TestCompany';
        acct.CurrencyIsoCode = 'USD';
        insert acct;
        
        Account recAccount = [Select Id, Name from Account LIMIT 1];
      
        Product2 product = new Product2();
        product.Name = 'NewProduct-001';
        product.IsActive = true;
        product.AX_Item_Number__c = 'Test';
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
        recOrder.Status = orderStatus;
        recOrder.Pricebook2Id = Test.getStandardPricebookId();
        recOrder.ShippingCountryCode = 'US';
        if (orderStatus.equalsIgnoreCase('Auth Cancelled'))
            recOrder.Cancel_date__c = System.today();
        if (orderStatus.equalsIgnoreCase('Invoiced'))
        {
            recOrder.Order_Shipped_Date__c = System.today();
            recOrder.CC_Authorization_ID__c = 'test122';
            recOrder.Status = 'Open';
        }
        recOrder.Brand__c = brand;
        recOrder.source__c = source;
        recOrder.Carrier__c ='UPS';
        recOrder.Order_Tracking__c = 'TestTrack01';
        
        insert recOrder;
        
        Order recOrderObj = [Select Id, Name from Order LIMIT 1];
        
        OrderItem recOrderItem = new OrderItem();
        recOrderItem.OrderId = recOrderObj.Id;
        recOrderItem.EP_Standing_Order_Id__c = '' + subscriptionId;
        recOrderItem.PricebookEntryId = recPriceBookEntry.Id;
        recOrderItem.UnitPrice = 10;
        recOrderItem.Quantity = 1;
        recOrderItem.EP_Line_Tax__c = 1;
        recOrderItem.Line_Item_Discount__c = 0.0;
        recOrderItem.Carrier__c = 'UPS';
        recOrderItem.Carrier_Code__c = 'UPSN';
        
      	recOrderItem.TrackingNumbers__c = 'TestTrack01';
        insert recOrderItem;
    }
 
    @isTest
    public static void testAuthCancelledOrder()
    {
        createTestRecords ('Auth Cancelled', 'Breville', 'AEM');
        BrevilleCommunityOrdersRESTResource.doGet();
    }
    
    @isTest
    public static void testWebOpenOrder()
    {
        createTestRecords ('Open', 'Breville', 'AEM');
        BrevilleCommunityOrdersRESTResource.doGet();
    }

    @isTest
    public static void testSFOpenOrder()
    {
        createTestRecords ('Open', 'Breville', 'Salesforce');
        BrevilleCommunityOrdersRESTResource.doGet();
    }

    @isTest
    public static void testWebShippedOrder()
    {
        createTestRecords ('Invoiced', 'Breville', 'AEM');
        BrevilleCommunityOrdersRESTResource.doGet();
    }
    
    @isTest
    Public static void testGenerateImageUrlForBeanz()
    {
        BrevilleCommunityOrdersRESTResource.GenerateImageUrlForBeanz('TestRoaster','MRBZ121212','https://www.beanz.com');
    }
}