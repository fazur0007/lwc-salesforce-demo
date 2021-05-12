@isTest
public with sharing class CreateReturnLabelCtrlTest {
    
    static testMethod void testMethodInitiateCreateReturnShipmate(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
       
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
       /*
        //Insert QC Location
        QCAlert__c qcAlert = new QCAlert__c();
        qcAlert.Complaint_Code__c = 'Alignment / Fit';
        
        QCLocation__c qcLocation = new QCLocation__c();
        qcLocation.Product__c = objProd.Id;
        //qcLocation.ReturnLocation__cId = objAcc.Id;
        qcLocation.QCAlert__c = qcAlert.Id;
        qcLocation.Batch_Code_From__c = '001';
        qcLocation.Batch_Code_To__c = '002';
		insert qcLocation;
       */ 
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        //caseObj.Return_Location__c = 'USA PRC';
        //caseObj.Return_Address__c='500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
       
        ctrl.caseRecordId = caseObj.id;
        //System.debug()
    	ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        ctrl.returnLabelFor = 'Return Location';
        ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
    	ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());
		// Check that the error message you are expecting is in pageMessages
		Boolean messageFound = false;
		
		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == 'System.Label.No_Shipping_Preference_found'
		        && message.getSeverity() == ApexPages.Severity.ERROR) {
		        messageFound = true;        
		    }
		}
		
		System.assert(true,messageFound);
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
		
		
        
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
    	//shipmentSetting.DimensionUnits__c = 'LB / IN';
    	//PackagingType__c, PaymentType__c,, ReturnType__c, ServiceType__c,ShipmatePreference__c,,WeightUnits__c,ShippingCarrier__c,SortDimension__c
    	insert shipmentSetting;
    	
    	
    	ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		
		
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	shipmentSetting.UPSShipmatePreference__c = null;
    	shipmentSetting.ShipmatePreference__c = mcShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'Multi Carrier';
    	upsert shipmentSetting;
    	
    	ctrl.createReturnShipmate();
    	ctrl.processBulkShipment();
    	
    	Case caseTest = ctrl.getCaseRecord();
    	
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
    	
    	
        List<Product2> product = new List<Product2>();
        product = [Select id,DimensionUnits__c,WeightUnits__c from Product2 where id =: objProd.id limit 1];
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
    	
    	
    	ShipmateUtility.DimensionBean dimension =  new ShipmateUtility.DimensionBean(

                caseObj.Product__r.Length__c,caseObj.Product__r.Width__c,
                caseObj.Product__r.Height__c,caseObj.Product__r.Weight__c,shipmentSetting,
                product[0].DimensionUnits__c,product[0].WeightUnits__c
            );
    	dimension.checkForUnitConversion();
    	
    	ShipmateUtility.DimensionBean dimension1 =  new ShipmateUtility.DimensionBean('11 1/2 X 9 1/8 X 16 3/8',10.0,shipmentSetting,'CM', 'LB');
    	
    	shipmentSetting.SortDimension__c = true;
    	upsert shipmentSetting;
    	dimension.sortTheDimension();
    	
    	ctrl.cancel();
    }
    
    static testMethod void testMethodInitiateCreateReturnShipmate1(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
    	
    	List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	//Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        objAcc.BillingCountryCode = 'US';
        objAcc.BillingPostalCode = '85363';
        objAcc.BillingStateCode = 'CA';
        objAcc.BillingStreet = 'Baker Street';
        objAcc.ShippingCountryCode = 'US';
        objAcc.ShippingCity = 'Colorado';
        objAcc.BillingCity = 'Colorado';
        objAcc.ShippingPostalCode = '85363';
		objAcc.ShippingStateCode = 'CA';
        
        insert objAcc;
        
        //Insert Service Account
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd1 = new Product2(Name= 'Testing Product',AX_Item_Number__c='ZCDL800BSS2BCA1'); 
        insert objProd1;  
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        objProd.Service_Return_Box__c = objProd1.id;
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
        ctrl.createReturnShipmate();
        
        ctrl.caseRecordId = caseObj.id;

        objProd.Weight__c = 12.0;
        objProd.Length__c = null;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
    	
        insert shipmentSetting;
    	
    	ctrl.returnLabelFor = 'Service Center';
    	ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		ctrl.setShipmentSettingFromCarrier();
		
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	shipmentSetting.UPSShipmatePreference__c = null;
    	shipmentSetting.ShipmatePreference__c = mcShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'Multi Carrier';
    	upsert shipmentSetting;
    	
    	ctrl.createReturnShipmate();
    	ctrl.processBulkShipment();
    	
    	Case caseTest = ctrl.getCaseRecord();
    	
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
    	
    	
        List<Product2> product = new List<Product2>();
        product = [Select id,DimensionUnits__c,WeightUnits__c from Product2 where id =: objProd.id limit 1];
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
    	
    	
    	ShipmateUtility.DimensionBean dimension =  new ShipmateUtility.DimensionBean(

                caseObj.Product__r.Length__c,caseObj.Product__r.Width__c,
                caseObj.Product__r.Height__c,caseObj.Product__r.Weight__c,shipmentSetting,
                product[0].DimensionUnits__c,product[0].WeightUnits__c
            );
    	dimension.checkForUnitConversion();
    	
    	ShipmateUtility.DimensionBean dimension1 =  new ShipmateUtility.DimensionBean('11 1/2 X 9 1/8 X 16 3/8',10.0,shipmentSetting,'CM', 'LB');
    	
    	shipmentSetting.SortDimension__c = true;
    	upsert shipmentSetting;
    	dimension.sortTheDimension();
    	
    	ctrl.cancel();
    	
    }
    
    static testMethod void testMethodInitiateCreateReturnShipmate2(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'Case';
    	
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        //caseObj.ReturnLocation__c= objServiceAcc.Id;
        insert caseObj;
        
        ctrl.createReturnShipmate();
        
        ctrl.caseRecordId = caseObj.id;
		
        objProd.Weight__c = 12.0;
        objProd.Length__c = null;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        
        //Create return shipment for UPS
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
    	
    	zkfedex__CustomAddressSource__c fedexCustomAddress = new zkfedex__CustomAddressSource__c();
    	fedexCustomAddress.zkfedex__CustomAddressSourceObject__c = 'Case';
    	insert fedexCustomAddress;
    	
    	zkfedex__BulkShipment__c fedexBulk = new zkfedex__BulkShipment__c();
		fedexBulk.zkfedex__ShipmatePreference__c =  fedexShipment.Id;   	
    	insert fedexBulk;
    	
    	zkfedex__QueuedShipment__c fedexQueued = new zkfedex__QueuedShipment__c();
    	fedexQueued.zkfedex__CustomAddressSource__c = fedexCustomAddress.Id;
    	fedexQueued.zkfedex__BulkShipment__c = fedexBulk.Id;
    	
    	
    	/*zkfedex__QueuedShipmentStatus__c fedexQueuedStatus  = new zkfedex__QueuedShipmentStatus__c();
    	fedexQueuedStatus.zkfedex__Status__c = 'ERROR';
    	fedexQueuedStatus.zkfedex__BulkShipment__c = fedexBulk.Id;
    	fedexQueuedStatus.zkfedex__QueuedShipment__c = fedexQueued.Id;
    	insert fedexQueuedStatus;*/
    	
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createFedExShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, fedexShipment.Id, 'FedEx');
    	//shipmentSetting.ServiceType__c = 'Domestic: FedEx 2Day';
    	insert shipmentSetting;
    	
    	ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		ctrl.setShipmentSettingFromCarrier();
        
    	Case caseTest = ctrl.getCaseRecord();
    	
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
        List<Product2> product = new List<Product2>();
        product = [Select id,DimensionUnits__c,WeightUnits__c from Product2 where id =: objProd.id limit 1];
        caseObj.Product__c=objProd.Id;
        upsert caseObj;    	
    	
    	ShipmateUtility.DimensionBean dimension =  new ShipmateUtility.DimensionBean(

                caseObj.Product__r.Length__c,caseObj.Product__r.Width__c,
                caseObj.Product__r.Height__c,caseObj.Product__r.Weight__c,shipmentSetting,
                product[0].DimensionUnits__c,product[0].WeightUnits__c
            );
    	dimension.checkForUnitConversion();
    	
    	ShipmateUtility.DimensionBean dimension1 =  new ShipmateUtility.DimensionBean('11 1/2 X 9 1/8 X 16 3/8',10.0,shipmentSetting,'CM', 'LB');
    	
    	shipmentSetting.SortDimension__c = true;
    	upsert shipmentSetting;
    	dimension.sortTheDimension();
    	
    	ctrl.cancel();
    	
    }
    
    
    static testMethod void testCreateReturnShipmateForMultiCarrier(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
    	
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
       
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        //caseObj.Return_Location__c = 'USA PRC';
        //caseObj.Return_Address__c='500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
       
        ctrl.caseRecordId = caseObj.id;
        //System.debug()
    	ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        ctrl.returnLabelFor = 'Service Center';
        ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
    	ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());
		// Check that the error message you are expecting is in pageMessages
		Boolean messageFound = false;
		
		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == 'System.Label.No_Shipping_Preference_found'
		        && message.getSeverity() == ApexPages.Severity.ERROR) {
		        messageFound = true;        
		    }
		}
		
		System.assert(true,messageFound);
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
		
		
        
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
    	//shipmentSetting.DimensionUnits__c = 'LB / IN';
    	//PackagingType__c, PaymentType__c,, ReturnType__c, ServiceType__c,ShipmatePreference__c,,WeightUnits__c,ShippingCarrier__c,SortDimension__c
    	insert shipmentSetting;
    	
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
       // mcShipment.zkmulti__Sender_Country__c='Australia';
       // mcShipment.zkmulti__Recipient_Country__c='Australia';
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	shipmentSetting.UPSShipmatePreference__c = null;
    	shipmentSetting.ShipmatePreference__c = mcShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'Multi Carrier';
    	upsert shipmentSetting;
    	
        ctrl.shipmateSet=shipmentSetting;
    	ctrl.createReturnShipmate();
    	ctrl.processBulkShipment();
    	
    	Case caseTest = ctrl.getCaseRecord();
    	
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
    	
    	
        List<Product2> product = new List<Product2>();
        product = [Select id,DimensionUnits__c,WeightUnits__c from Product2 where id =: objProd.id limit 1];
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
    	
    	
    	ShipmateUtility.DimensionBean dimension =  new ShipmateUtility.DimensionBean(

                caseObj.Product__r.Length__c,caseObj.Product__r.Width__c,
                caseObj.Product__r.Height__c,caseObj.Product__r.Weight__c,shipmentSetting,
                product[0].DimensionUnits__c,product[0].WeightUnits__c
            );
    	dimension.checkForUnitConversion();
    	
    	//ShipmateUtility.DimensionBean dimension1 =  new ShipmateUtility.DimensionBean('11 1/2 X 9 1/8 X 16 3/8',10.0,shipmentSetting,'CM', 'LB');
    	
    	shipmentSetting.SortDimension__c = true;
    	upsert shipmentSetting;
    	dimension.sortTheDimension();
    	ctrl.dimension=dimension;
    	ctrl.cancel();
    }
    
    
    
    static testMethod void testCreateReturnShipmateForFedEx(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
    	
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
       
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        //caseObj.Return_Location__c = 'USA PRC';
        //caseObj.Return_Address__c='500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
       
        ctrl.caseRecordId = caseObj.id;
        //System.debug()
    	ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        ctrl.returnLabelFor = 'Service Center';
        ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
    	ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());
		// Check that the error message you are expecting is in pageMessages
		Boolean messageFound = false;
		
		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == 'System.Label.No_Shipping_Preference_found'
		        && message.getSeverity() == ApexPages.Severity.ERROR) {
		        messageFound = true;        
		    }
		}
		
		System.assert(true,messageFound);
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
		
		
        
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
    	//shipmentSetting.DimensionUnits__c = 'LB / IN';
    	//PackagingType__c, PaymentType__c,, ReturnType__c, ServiceType__c,ShipmatePreference__c,,WeightUnits__c,ShippingCarrier__c,SortDimension__c
    	insert shipmentSetting;
    	
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
       // mcShipment.zkmulti__Sender_Country__c='Australia';
       // mcShipment.zkmulti__Recipient_Country__c='Australia';
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
    	//shipmentSetting.ShipmatePreference__c = fedexShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'FedEx';
    	upsert shipmentSetting;
    	
        ctrl.shipmateSet=shipmentSetting;
    	ctrl.createReturnShipmate();
    	ctrl.processBulkShipment();
    	
    	Case caseTest = ctrl.getCaseRecord();
    	
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
    	
    	
        List<Product2> product = new List<Product2>();
        product = [Select id,DimensionUnits__c,WeightUnits__c from Product2 where id =: objProd.id limit 1];
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
    	
    	
    	ShipmateUtility.DimensionBean dimension =  new ShipmateUtility.DimensionBean(

                caseObj.Product__r.Length__c,caseObj.Product__r.Width__c,
                caseObj.Product__r.Height__c,caseObj.Product__r.Weight__c,shipmentSetting,
                product[0].DimensionUnits__c,product[0].WeightUnits__c
            );
    	dimension.checkForUnitConversion();
    	
    	shipmentSetting.SortDimension__c = true;
    	upsert shipmentSetting;
    	dimension.sortTheDimension();
    	ctrl.dimension=dimension;
    	ctrl.cancel();
    }
    
    static testMethod void testInitiateCreateReturnShipmate(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
    	
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
        ctrl.createReturnShipmate();
        
        ctrl.caseRecordId = caseObj.id;

        objProd.Weight__c = 12.0;
        objProd.Length__c = null;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting;
        
        ShipmentSetting__c shipmentSetting1 = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, mcShipment.Id, 'UPS');
        insert shipmentSetting1;
    	
    	ctrl.returnLabelFor = 'Service Center';
    	ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    		
    }
    
    static testMethod void testCreateReturnShipmate(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
    	
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
       
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        //caseObj.Return_Location__c = 'USA PRC';
        //caseObj.Return_Address__c='500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
       
        ctrl.caseRecordId = caseObj.id;
        //System.debug()
    	ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        ctrl.returnLabelFor = 'Service Center';
        ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
    	ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());
		// Check that the error message you are expecting is in pageMessages
		Boolean messageFound = false;
		
		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == 'System.Label.No_Shipping_Preference_found'
		        && message.getSeverity() == ApexPages.Severity.ERROR) {
		        messageFound = true;        
		    }
		}
		
		System.assert(true,messageFound);
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
		
		
        
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
    	//shipmentSetting.DimensionUnits__c = 'LB / IN';
    	//PackagingType__c, PaymentType__c,, ReturnType__c, ServiceType__c,ShipmatePreference__c,,WeightUnits__c,ShippingCarrier__c,SortDimension__c
    	shipmentSetting.ShipmateApp__c = 'FedEx';
        insert shipmentSetting;
    	
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
       // mcShipment.zkmulti__Sender_Country__c='Australia';
       // mcShipment.zkmulti__Recipient_Country__c='Australia';
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'FedEx';
    	upsert shipmentSetting;
    	
        ctrl.shipmateSet=shipmentSetting;
    	ctrl.createReturnShipmate();
    	ctrl.processBulkShipment();
    	
    	Case caseTest = ctrl.getCaseRecord();
    	
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
    	
    	
        List<Product2> product = new List<Product2>();
        product = [Select id,DimensionUnits__c,WeightUnits__c from Product2 where id =: objProd.id limit 1];
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
    	
    	
    	ShipmateUtility.DimensionBean dimension =  new ShipmateUtility.DimensionBean(

                caseObj.Product__r.Length__c,caseObj.Product__r.Width__c,
                caseObj.Product__r.Height__c,caseObj.Product__r.Weight__c,shipmentSetting,
                product[0].DimensionUnits__c,product[0].WeightUnits__c
            );
    	dimension.checkForUnitConversion();
    	
    	shipmentSetting.SortDimension__c = true;
    	upsert shipmentSetting;
    	dimension.sortTheDimension();
    	ctrl.dimension=dimension;
    	ctrl.cancel();
    }
    
    static testMethod void testcheckForUnitConversionShipmateUtility(){
    	CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
    	ctrl.workingObject = 'WorkOrder';
    	
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
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.CurrencyIsoCode = 'USD';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
       
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Service_Center__c=null;
        caseObj.Product__c=null;
        caseObj.Pickup_City__c ='';
        caseObj.Consignee_Contact_Name__c='';
        caseObj.Pickup_Country__c='';
        caseObj.Consignee_Email__c='';
        caseObj.Consignee_Phone__c='';
        caseObj.Pickup_State__c='';
        caseObj.Pickup_Address_1__c='';
        caseObj.Pickup_Postal_Code__c='';
        insert caseObj;
        
       
        ctrl.caseRecordId = caseObj.id;
    	ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
    	
    	caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        ctrl.returnLabelFor = 'Service Center';
        ctrl.initiateCreateReturnShipmate();
    	ctrl.initiateCreateOutboundShipmate();
    	
    	ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());
		Boolean messageFound = false;
		
		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == 'System.Label.No_Shipping_Preference_found'
		        && message.getSeverity() == ApexPages.Severity.ERROR) {
		        messageFound = true;        
		    }
		}
		
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
		
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'WorkOrder';
    	insert upsCustomAddress;
    	
    	ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
    	shipmentSetting.ShipmateApp__c = 'FedEx';
        shipmentSetting.DimensionUnits__c = 'CM';
        insert shipmentSetting;
    	
        ctrl.initiateCreateReturnShipmate();
		ctrl.initiateCreateOutboundShipmate();
    	ctrl.createReturnShipmate();
		ctrl.processBulkShipment();
		
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        insert mcShipment;
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
        
     	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'WorkOrder';
    	insert mcCustomAddress;
    	
    	shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'FedEx';
    	upsert shipmentSetting;
        
    	shipmentSetting.DimensionUnits__c = 'CM';
    	shipmentSetting.WeightUnits__c = 'LB';
    	upsert shipmentSetting;
    	
        ShipmateUtility.DimensionBean dimension1 =  new ShipmateUtility.DimensionBean('11 1/2 X 9 1/8 X 16 3/8',10.0,shipmentSetting,'CM', 'LB');
    	dimension1.checkForUnitConversion();
        
    }
}