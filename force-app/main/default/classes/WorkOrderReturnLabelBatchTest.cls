@isTest
public with sharing class WorkOrderReturnLabelBatchTest {
	static testMethod void testMethodInitiateCreateReturnLabelUPS(){
		Test.startTest();
		WorkOrderReturnLabelBatch woBatch = new WorkOrderReturnLabelBatch();
		List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
		//Insert Account    		
         Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
         objAcc.BillingCity = 'OAKLAND';
         objAcc.BillingCountryCode = 'US';
         objAcc.BillingPostalCode = '94602';
         objAcc.BillingStateCode = 'CA';
         objAcc.BillingStreet = 'HAMPEL ST';
         objAcc.ShippingCity = 'OAKLAND';
         objAcc.ShippingCountryCode = 'US';
         objAcc.ShippingPostalCode = '94602';
         objAcc.ShippingStateCode = 'CA';
         objAcc.ShippingStreet = 'HAMPEL ST';
        insert objAcc;
        
        //Insert Service Account
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Brand__c = 'Breville';
        objProd.CurrencyIsoCode = 'USD';
        objProd.Description = 'testing';
        insert objProd;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        Pricebook2 objPricebook2 = new Pricebook2(Id=standardPriceBookId);
        objPricebook2.Brand__c = 'Breville';
        objPricebook2.IsActive = true;
        objPricebook2.Region__c= 'USA';
        update objPricebook2;
        
        //Insert PricebookEntry1
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj; 


        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        insert caseObj;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId = caseObj.Id;
        wo.AutoReturnLabelStatus__c = 'Scheduled';
        wo.CC_Authorization_ID__c = 'CB12345';
        wo.CreateBoxOrder__c = true;
        insert wo;
        
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
    	shipmentSetting.UPSShipmatePreference__c = upsShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'UPS';
    	insert shipmentSetting;
        
        
        DataBase.executeBatch(woBatch);
        //zkfedex__Shipment__c
        list<zkups__UPSShipment__c> fedExList = [SELECT Id, Case__c FROM zkups__UPSShipment__c WHERE Case__c = :caseObj.Id];
        //System.assert(fedExList != null && fedExList.size() > 0);  
        Test.stopTest();
	} 
    
    static testMethod void testMethodInitiateCreateReturnLabelFedEx(){
		WorkOrderReturnLabelBatch woBatch = new WorkOrderReturnLabelBatch();
		List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
		//Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        //Insert Service Account
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Description = 'testing';
        insert objProd;
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        insert caseObj;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId = caseObj.Id;
        wo.AutoReturnLabelStatus__c = 'Scheduled';
        wo.CC_Authorization_ID__c = 'CB12345';

        insert wo;
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
    	
    	zkfedex__CustomAddressSource__c fedexCustomAddress = new zkfedex__CustomAddressSource__c();
    	fedexCustomAddress.zkfedex__CustomAddressSourceObject__c = 'WorkOrder';
    	insert fedexCustomAddress;
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
    	shipmentSetting.FedExShipmatePreference__c = fedexShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'FedEx';
    	insert shipmentSetting;
        
        Test.startTest();
        DataBase.executeBatch(woBatch);
        Test.stopTest();
	}
    
    static testMethod void schduleTestMethod() {        
        test.starttest();
        //WorkOrderReturnLabelBatch.schduleBatch();
        WorkOrderReturnLabelBatch woBatch = new WorkOrderReturnLabelBatch();
        String jobID = System.schedule('Schedule for all records Test ' + System.now(), '0 0 15 * * ?', woBatch);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        test.stopTest();
    }
  
    static testMethod void testMethodInitiateCreateReturnLabelMC(){
		WorkOrderReturnLabelBatch woBatch = new WorkOrderReturnLabelBatch();
		List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
		//Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        //Insert Service Account
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.CurrencyIsoCode = 'USD';
        objProd.Description = 'testing Multi Carrier';
        insert objProd;
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        insert caseObj;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId = caseObj.Id;
        wo.AutoReturnLabelStatus__c = 'Scheduled';
        wo.CC_Authorization_ID__c = 'CB12345';
        insert wo;
        
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
    	shipmentSetting.ShipmatePreference__c = mcShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'Multi Carrier';
    	insert shipmentSetting;
        
        Test.startTest();
        DataBase.executeBatch(woBatch); 
        Test.stopTest();
	}
	
     static testMethod void schedulartest(){
        DateTime now  = DateTime.now().addMinutes(30);
        String cronString = '0 0 0 * * ?';
        WorkOrderReturnLabelBatch.schduleBatchName = 'ScheduleApexClassTest';
         
        Test.startTest();
        
        WorkOrderReturnLabelBatch.schduleBatch();        
        Id jobId = System.schedule(WorkOrderReturnLabelBatch.class.getName() + '-' + now.format(), cronString, new WorkOrderReturnLabelBatch());
        System.assertNotEquals(Null, jobId);
        
        Test.stopTest();
    }
}