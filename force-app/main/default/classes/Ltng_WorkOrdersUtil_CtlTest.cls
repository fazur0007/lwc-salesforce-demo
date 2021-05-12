@isTest
public class Ltng_WorkOrdersUtil_CtlTest {
    @isTest
    public static void TestactivateWorkOrder()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',1,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        String result = Ltng_WorkOrdersUtil_Ctl.activateWorkOrder(workOrder.Id);
        system.assertEquals('success', result);
    }
    
    @isTest
    public static void TestactivateWorkOrder_WithoutServiceType()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',1,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        //WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        String result = Ltng_WorkOrdersUtil_Ctl.activateWorkOrder(workOrder.Id);
        system.assertEquals('Please Select Service Type before activating', result);
    }
    
    @isTest
    public static void TestsendQuote()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',1,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        Map<string, Object> result = Ltng_WorkOrdersUtil_Ctl.sendQuote(workOrder.Id);
        system.assertEquals(false, result.get('isReturnBoxNeeded'));
    }
    
    @isTest
    public static void TestsendQuote_WithReturnBox()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',2,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        lstProducts[0].Service_Return_Box__c = lstProducts[1].id;
        update lstProducts[0];
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        Map<string, Object> result = Ltng_WorkOrdersUtil_Ctl.sendQuote(workOrder.Id);
        system.assertEquals(true, result.get('isReturnBoxNeeded'));
    }
    
    @isTest
    public static void TestsendQuoteUtil()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',1,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        Ltng_WorkOrdersUtil_Ctl.sendQuoteUtil('',workOrder);
    }
    
    @isTest
    public static void TestsubmitResponse()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',1,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        try
        {
            Map<String,Object> result = Ltng_WorkOrdersUtil_Ctl.submitResponse(workOrder.Id,'Yes','Yes',true,true,true);
            system.assertEquals(true,result.get('quoteSent'));
        }
        catch(exception ex)
        {
            system.assertEquals('Please Enter Email Id	', ex.getMessage());
        }
    }
    
    @isTest
    public static void TestsubmitforWorkOrderApproval()
    {
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',1,'BCG1235',true);
        lstProducts[0].Serviceable__c = true;
        insert lstProducts;
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = '12345';
        workOrder.currencyISOCode = 'USD';
        workorder.Product__c = lstProducts[0].id;
        workorder.BatchCode__c = '1234';
        workorder.Subject = 'Test work order';
        workorder.ComplaintCode__c = 'Alignment / Fit';
        workorder.Sub_Complaint_Code__c = 'Bean Hopper';
        workorder.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        WorkOrder.FirstName__c = 'TestFN';
        WorkOrder.LastName__c = 'TestLN';
        WorkOrder.Email__c='test@gmail.com';
        WorkOrder.ServiceType__c = 'Field Service';
        insert workOrder;
        String result = Ltng_WorkOrdersUtil_Ctl.submitforWorkOrderApproval(workOrder.Id);
        system.assertEquals('Success', result);
    }
    
}