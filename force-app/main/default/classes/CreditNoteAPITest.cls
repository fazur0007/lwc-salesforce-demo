@isTest
private class CreditNoteAPITest {
    
    @isTest 
    static void testEmptyBody() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('[]');
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        System.assertEquals('Body cannot be empty.', responses[0].error);
        Test.stopTest();
    } 
    
    @isTest 
    static void testCaseNotFound() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder='';
        req.RMANumber = 'XYZ';
        req.InvoiceNumber = '0001';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        System.assertEquals('RMA record could not be found.', responses[0].error);
        Test.stopTest();
    }  
    
     @isTest 
    static void testCaseIdOrderIdNotGiven() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder='';
        req.RMANumber = '';
        req.InvoiceNumber = '0001';
        req.SalesOrigin = 'SF';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        System.assertEquals('Please provide either Case Id or Order Id.', responses[0].error);
        Test.stopTest();
    } 
     @isTest 
    static void testInvalidPurchaseId() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder='801c00000025';
        req.RMANumber = '';
        req.InvoiceNumber = '0001';
        req.SalesOrigin = 'SF';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        System.assertEquals('PurchaseOrder is an invalid Salesforce Id.', responses[0].error);
        Test.stopTest();
    } 
    
    
    @isTest 
    static void testUpdateCase() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        Case caseRecord2 = [SELECT Case_Number_Ext__c FROM Case LIMIT 1];
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.RMANumber = caseRecord2.Case_Number_Ext__c;
        req.InvoiceNumber = '0001';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(true, responses[0].isSuccess);
        Test.stopTest();
    }
    
    @isTest 
    static void testOrderNotFound() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder = '801c00000025HDm';
        req.InvoiceNumber = '0001';
        req.SalesOrigin = 'SF';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        System.assertEquals('Order record could not be found.', responses[0].error);
        Test.stopTest();
    }  
    
    @isTest 
    static void testUpdateOrder1() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        Order orderRecord2 = [SELECT Id FROM Order LIMIT 1];
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder = orderRecord2.Id;
        req.InvoiceNumber = '0001';
        req.SalesOrigin = 'SF';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(true, responses[0].isSuccess);
        Test.stopTest();
    }
    
    @isTest 
    static void testRequestWithoutInvoiceNumber(){
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        Order orderRecord2 = [SELECT Id FROM Order LIMIT 1];
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder = orderRecord2.Id;
        req.SalesOrigin = 'SF';
        req.BusinessUnit='BUS';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateOrder2() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        Order orderRecord2 = [SELECT Id FROM Order LIMIT 1];
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder = orderRecord2.Id;
        req.InvoiceNumber = '0001';
        req.BusinessUnit='BUS';
        req.SalesOrigin='Shopify';
        req.ConsumerOrder=orderRecord2.Id;
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(true, responses[0].isSuccess);
        Test.stopTest();
    }
    
    @isTest 
    static void testWebOrder() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        Order orderRecord2 = [SELECT Id,WebSiteOrderNumber__c FROM Order where WebSiteOrderNumber__c!=null LIMIT 1];
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder = orderRecord2.WebSiteOrderNumber__c;
        req.InvoiceNumber = '0001';
        req.BusinessUnit='BUS';
        req.SalesOrigin='Shopify';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        
        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(false, responses[0].isSuccess);
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateWorkOrder() {
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/services/apexrest/CreditNoteService/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        WorkOrder woRecord = [SELECT WorkOrderNumber FROM WorkOrder LIMIT 1];
        
        CreditNoteAPI.RequestWrapper req = new CreditNoteAPI.RequestWrapper();
        req.PurchaseOrder = woRecord.WorkOrderNumber;
        req.InvoiceNumber = '0001';
        req.SalesOrigin='SF';
        req.BusinessUnit='BUS';
        req.D365OrderNumber= 'SOTest';
        
        String reqString = JSON.serialize(new List<CreditNoteAPI.RequestWrapper> {req});
        
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;

        Test.startTest();
        List<CreditNoteAPI.ResponseWrapper> responses = CreditNoteAPI.doPost();
        System.assertEquals(true, responses[0].isSuccess);
        Test.stopTest();
    }
    
    @TestSetup
    static void setup() {
        String axItemNo = 'ZBBL800BSS1BCA1';
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.AX_Item_Number__c=axItemNo;
        insert productRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        insert caseRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        insert standardPrice;
        
        Order orderRecord = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookId, Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(), 'Sale',
                                                               '', 'Breville','USD');
        orderRecord.OrderSubcategory__c = 'Employee Sale';
        orderRecord.Country__c='USA';
        orderRecord.Magic_Order_ID__c = 'SO30005174';
        insert orderRecord;
        
        List<OrderItem> orderItemsList=TestDataFactory.createOrderItem(standardPrice.Id,orderRecord.Id,3,50,1);
        orderItemsList[0].LineStatus__c='Shipped';
        insert orderItemsList;
        
        Order orderRecord2 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookId, Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(), 'Sale',
                                                               '', 'Breville','USD');
        orderRecord2.Country__c='USA';
        orderRecord2.WebSiteOrderNumber__c='Test1234';
        orderRecord2.Magic_Order_ID__c = 'SO30009824';
        insert orderRecord2;
        
        WorkOrder workOrderObj = new WorkOrder(CaseId=caseRecord.Id, AccountId=accountRecord.Id,CurrencyIsoCode='USD',Pricebook2Id = pricebookId,ServiceCentre__c=accountRecord.Id); 
        workOrderObj.CC_Authorization_ID__c = '1234';
        insert workOrderObj; 
    }
}