@isTest
public class LWC_CreateSparePartOrder_ClsTest {
    
    @isTest
    public static void TestdoLoadInitData()
    {
        Account ObjNewServiceCenter = new Account();
        ObjNewServiceCenter.Name = 'TestServiceCenter';
        ObjNewServiceCenter.Type = 'Authorized Service Center';
        ObjNewServiceCenter.CurrencyIsoCode = 'USD';
        ObjNewServiceCenter.recordtypeid = [select id from recordtype where name='Business Account'].id;
        insert ObjNewServiceCenter;
        
        List<Product2> lstProducts = TestDataFactory.createProductList('TestProd1',2,'BCGA1235',true);
        lstProducts[0].Serviceable__c = true;
        lstProducts[1].Spare_Part__c = true;
        insert lstProducts;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Accommodation'
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        WorkOrder workOrder1 = new WorkOrder();
        workOrder1.PostalCode = '12345';
        workOrder1.currencyISOCode = 'USD';
        workOrder1.ServiceCentre__c = ObjNewServiceCenter.Id;
        workOrder1.Product__c = lstProducts[0].id;
        workOrder1.BatchCode__c = '1234';
        workOrder1.Subject = 'Test work order';
        workOrder1.ComplaintCode__c = 'Alignment / Fit';
        workOrder1.Sub_Complaint_Code__c = 'Bean Hopper';
        workOrder1.RecordTypeId = [select id from recordtype where name='Work Order'].Id;
        workOrder1.FirstName__c = 'TestFN';
        workOrder1.LastName__c = 'TestLN';
        workOrder1.Email__c='test@gmail.com';
        workOrder1.ServiceType__c = 'Field Service';
        workOrder1.Brand__c = 'Breville';
        workOrder1.Pricebook2Id =  standardPricebook.Id;
        insert workOrder1;
        
        
        
        
        List<PricebookEntry> lstPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = lstProducts[0].Id,
            UnitPrice = 1020,
            IsActive = true
        );
        lstPbe.add(pbe);
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = lstProducts[1].Id,
            UnitPrice = 1021,
            IsActive = true
        );
        lstPbe.add(pbe1);
        Insert lstPbe;
        
        WorkOrderLineItem objLineItem =  TestDataFactory.createWorkOrderLineItemRecord(lstPbe[0].Id,workOrder1.Id,1,11.2,'Parts',true);
        List<LWC_CreateSparePartOrder_Cls.WrapperClass> result = LWC_CreateSparePartOrder_Cls.doLoadInitData(workOrder1.Id);
        
        string selectedProducts = '[{"description":"54mm Steam Ring","isAvailable":true,"isSelected":true,"productId":"' +  lstProducts[1].Id + '","productSKU":"BES860XL/02.6","quantity":"2"}]';
        String result1 = LWC_CreateSparePartOrder_Cls.createsparePartOrder(workOrder1.Id,selectedProducts);
    }
}