@isTest(SeeAllData=true)
public class CreateSparePartsOrderControllerTest{
    static testMethod void testCreateSparePartsOrderController(){
        Test.startTest();
        
        Account accountRecord = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BAU','nikhil998@example.com','9527785432');
        insert accountRecord;            
        
        
        //createProduct(String ProdName,Boolean AvailableSell, Boolean insertRecord )
        /*Product2 productRecord = TestDataFactory.createProduct('Product 998', true, true);
        productRecord.AX_Item_Number__c = '1234';
        productRecord.Serviceable__c = true;
        update productRecord;
        */
        
        Product2 productRecord = new Product2();
        productRecord.Name = 'product1';
        productRecord.AX_Item_Number__c = 'productax1';
        productRecord.Serviceable__c = true;
        productRecord.CurrencyIsoCode = 'AUD';
        productRecord.Spare_Part__c = false;
        insert productRecord;
        Pricebook2 pricebookRecord = [select id from Pricebook2 where Brand__c='Breville' AND Type__c='Wholesale' AND Region__c='AUS' limit 1];
        Pricebook2 standardPricebook = [SELECT Id from Pricebook2 WHERE IsStandard=true LIMIT 1];
        PricebookEntry pricebookEntryRecord2 = new PricebookEntry();
        pricebookEntryRecord2.Product2Id = productRecord.Id;
        pricebookEntryRecord2.Pricebook2Id = standardPricebook.Id;
        pricebookEntryRecord2.ServiceCharge__c = 10;
        pricebookEntryRecord2.FreightCharge__c = 10;
        pricebookEntryRecord2.InspectionCharge__c = 10;
        pricebookEntryRecord2.Refurb_Fee__c = 10;
        pricebookEntryRecord2.InspectionCharge__c = 10;
        pricebookEntryRecord2.LaborCharge__c = 10;
        pricebookEntryRecord2.Tier2InspectionCharge__c = 10;
        pricebookEntryRecord2.Tier2LaborCharge__c = 10;
        pricebookEntryRecord2.Tier3LaborCharge__c = 10;
        pricebookEntryRecord2.Tier4LaborCharge__c = 10;
        pricebookEntryRecord2.UnitPrice = 10;
        pricebookEntryRecord2.IsActive = true;
        pricebookEntryRecord2.CurrencyIsoCode = 'AUD';
        insert pricebookEntryRecord2;
        
        PricebookEntry pricebookEntryRecord = new PricebookEntry();
        pricebookEntryRecord.Product2Id = productRecord.Id;
        pricebookEntryRecord.Pricebook2Id = pricebookRecord.Id;
        pricebookEntryRecord.ServiceCharge__c = 10;
        pricebookEntryRecord.FreightCharge__c = 10;
        pricebookEntryRecord.InspectionCharge__c = 10;
        pricebookEntryRecord.Refurb_Fee__c = 10;
        pricebookEntryRecord.InspectionCharge__c = 10;
        pricebookEntryRecord.LaborCharge__c = 10;
        pricebookEntryRecord.Tier2InspectionCharge__c = 10;
        pricebookEntryRecord.Tier2LaborCharge__c = 10;
        pricebookEntryRecord.Tier3LaborCharge__c = 10;
        pricebookEntryRecord.Tier4LaborCharge__c = 10;
        pricebookEntryRecord.UnitPrice = 10;
        pricebookEntryRecord.CurrencyIsoCode = 'AUD';
        pricebookEntryRecord.IsActive = true;
        
        insert pricebookEntryRecord;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre AUS', 'BAU','servicecentre_AUS@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.ServicePriceBook__c = pricebookRecord.Id;
        insert ServiceCentreAccount;
        //createContact(Id accountId, String lastNname, Boolean insertRecord)
        Contact contactRecord = TestDataFactory.createContact(accountRecord.Id, 'palekar998', true);
        Case caseRecord1 = TestDataFactory.createCase(accountRecord.Id, 'Email', 'Open', 'subject 998', 'AUD', productRecord.Id, 'Feedback', 'Dented', '1051', true );
        list<WorkOrder> workOrderList = new list<WorkOrder>();
        Id workOrderRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Work Order').getRecordTypeId();
          
        WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(caseRecord1.Id, accountRecord.Id, 'AUD', pricebookRecord.Id, ServiceCentreAccount.Id, 'workorder1@example.com','440022');
        list<Case> caseList = [select id, CaseNumber from Case where Subject='subject 998' limit 1];
        workOrderRecord1.CaseNumber__c = String.valueOf(caseList[0].CaseNumber);
        workOrderRecord1.InspectionCharge__c = 10;
        workOrderRecord1.LaborCharge__c = 20;
        workOrderRecord1.FreightCharge__c = 30;
        workOrderRecord1.FlatServiceCharge__c = 40;
        workOrderRecord1.Discounted_Inspection_Charge__c = 8;
        workOrderRecord1.Discounted_Labor_Charge__c = 18;
        //workOrderRecord1.Discounted_Freight_Charge__c = 27;
        workOrderRecord1.Discounted_Flat_Service_Charge__c = 36;
        workOrderRecord1.InspectionChargeTierLevel__c = 'Tier 1';
        workOrderRecord1.LaborChargeTierLevel__c = 'Tier 1';
        workOrderRecord1.recordTypeid = workOrderRecordTypeId;
        workOrderRecord1.IsFreightFeeApplicable__c = true;
        //workOrderRecord1.ApprovalStatus__c = 'Approved';
        
        
        workOrderRecord1.Product__c = productRecord.Id;
        System.debug('workOrderRecord1.Product__c : ' +workOrderRecord1.Product__c);
        workOrderRecord1.BatchCode__c = 'T1';
        workOrderRecord1.PurchaseDate__c = Date.today();
        workOrderRecord1.Activated__c = true;
        workOrderList.add(workOrderRecord1);
        
        insert workOrderList;
        
        Product2 productRecord2 = new Product2();
        productRecord2.Name = 'product1';
        productRecord2.AX_Item_Number__c = 'productax1';
        productRecord2.Serviceable__c = true;
        productRecord2.CurrencyIsoCode = 'AUD';
        productRecord2.Spare_Part__c = true;
        insert productRecord2;
        
        PricebookEntry pricebookEntryRecord23 = new PricebookEntry();
        pricebookEntryRecord23.Product2Id = productRecord2.Id;
        pricebookEntryRecord23.Pricebook2Id = standardPricebook.Id;
        pricebookEntryRecord23.ServiceCharge__c = 10;
        pricebookEntryRecord23.FreightCharge__c = 10;
        pricebookEntryRecord23.InspectionCharge__c = 10;
        pricebookEntryRecord23.Refurb_Fee__c = 10;
        pricebookEntryRecord23.InspectionCharge__c = 10;
        pricebookEntryRecord23.LaborCharge__c = 10;
        pricebookEntryRecord23.Tier2InspectionCharge__c = 10;
        pricebookEntryRecord23.Tier2LaborCharge__c = 10;
        pricebookEntryRecord23.Tier3LaborCharge__c = 10;
        pricebookEntryRecord23.Tier4LaborCharge__c = 10;
        pricebookEntryRecord23.UnitPrice = 10;
        pricebookEntryRecord23.IsActive = true;
        pricebookEntryRecord23.CurrencyIsoCode = 'AUD';
        insert pricebookEntryRecord23;
        
        PricebookEntry pricebookEntryRecord3 = new PricebookEntry();
        pricebookEntryRecord3.Product2Id = productRecord2.Id;
        pricebookEntryRecord3.Pricebook2Id = pricebookRecord.Id;
        pricebookEntryRecord3.ServiceCharge__c = 10;
        pricebookEntryRecord3.FreightCharge__c = 10;
        pricebookEntryRecord3.InspectionCharge__c = 10;
        pricebookEntryRecord3.Refurb_Fee__c = 10;
        pricebookEntryRecord3.InspectionCharge__c = 10;
        pricebookEntryRecord3.LaborCharge__c = 10;
        pricebookEntryRecord3.Tier2InspectionCharge__c = 10;
        pricebookEntryRecord3.Tier2LaborCharge__c = 10;
        pricebookEntryRecord3.Tier3LaborCharge__c = 10;
        pricebookEntryRecord3.Tier4LaborCharge__c = 10;
        pricebookEntryRecord3.UnitPrice = 10;
        pricebookEntryRecord3.CurrencyIsoCode = 'AUD';
        pricebookEntryRecord3.IsActive = true;
        
        insert pricebookEntryRecord3;
        
        WorkOrderLineItem workOrderLineItem1 = TestDataFactory.createWorkOrderLineItemRecord(pricebookEntryRecord.id, workOrderRecord1.id,10,100.0, false);
        workOrderLineItem1.Type__c = 'Parts';
        workOrderLineItem1.Quantity = 5;
        insert workOrderLineItem1;
        
        
        ApexPages.StandardSetController sCon = new ApexPages.StandardSetController(workOrderList);
        CreateSparePartsOrderController object1 = new CreateSparePartsOrderController(sCon);
        object1.createsparePartOrder();
        
        ApexPages.StandardController sCon2 = new ApexPages.StandardController(workOrderList[0]);
        CreateSparePartsOrderController object2 = new CreateSparePartsOrderController(sCon2);
        object2.createsparePartOrder();
        
        Test.stopTest();
        
    }
}