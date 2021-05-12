@isTest
public with sharing class BulkRMAAutoShipmentBatchTest {
    
    @testSetup
    public static void setupData() {
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	//Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        insert objProd;  
        
        List<Case> lstCase= new List<Case>();
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        //Insert Case  
        Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
            						Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
       // insert caseObj;
        lstCase.add(caseObj);
        insert lstCase;
                
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.Product__c=objProd.Id;
        rmaObj.currencyISOCode='USD';
        insert rmaObj;
    	
    	
    	zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS' ;
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
    	insert mcCustomAddress;
    	
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
    	insert upsCustomAddress;
        
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSettingUPS = new ShipmentSetting__c();
    	shipmentSettingUPS.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSettingUPS.ShipmatePreference__c = mcShipment.Id;
    	shipmentSettingUPS.ShipmateApp__c = 'FedEx';
        shipmentSettingUPS.UPSShipmatePreference__c=upsShipment.Id;
       // shipmentSetting.FedExShipmatePreference__c=mcShipment.Id;
    	insert shipmentSettingUPS; 
    }
    
     static testMethod void testMethodBulkRMAAutoShipmentBatchUPS(){
    	
    	List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        system.debug('caseRmaRecordTypeId'+caseRmaRecordTypeId); 
         
        List<Case> lstCase= new List<Case>(); 
        //Insert Case  
         Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        lstCase.add(caseObj); 
        insert lstCase;
                       
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.CurrencyIsoCode='USD'; 
        rmaObj.Product__c=objProd.Id;
        insert rmaObj;
    	
    	
    	zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
    	insert upsCustomAddress;
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.UPSShipmatePreference__c = upsShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'UPS';
        shipmentSetting.IsAccountAddress__c=true;
    	insert shipmentSetting;
    	
    	Test.startTest();
    	//BulkRMAAutoShipmateBatch.schduleBatch();
        BulkRMAAutoShipmateBatch bulkObj=new BulkRMAAutoShipmateBatch();
    	bulkObj.execute(null,lstCase); 
	    Test.stopTest();
    }
    
    
    static testMethod void testMethodBulkRMAAutoShipmentBatchMC(){
    	
    	List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	//Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        insert objProd;  
        
        List<Case> lstCase= new List<Case>();
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        //Insert Case  
        Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
            						Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
       // insert caseObj;
        lstCase.add(caseObj);
        insert lstCase;
                
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.Product__c=objProd.Id;
        rmaObj.currencyISOCode='USD';
        insert rmaObj;
    	
    	
    	zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS' ;
    	insert mcShipment;
    	
    	zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
    	mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
    	insert mcCustomAddress;
    	
        zkups__UPSShipmatePreference__c upsShipment=new zkups__UPSShipmatePreference__c();
        insert upsShipment;
        
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.ShipmatePreference__c = mcShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        shipmentSetting.UPSShipmatePreference__c=upsShipment.Id;
        insert shipmentSetting; 
       // shipmentSetting.FedExShipmatePreference__c=mcShipment.Id;
       
       /* zkmulti__MCShipment__c zkmcShipment=new zkmulti__MCShipment__c();
        zkmcShipment.Case__c=caseObj.Id;
        insert zkmcShipment;
		zkmulti__MCPackage__c mcPackage=new zkmulti__MCPackage__c(); 
        mcPackage.CurrencyIsoCode='USD';
        insert mcPackage;
        zkmulti__MCCustoms_Item__c mcCustomsItem=new zkmulti__MCCustoms_Item__c();
        mcCustomsItem.zkmulti__Carrier__c='UPS';
        insert mcCustomsItem;
        zkmulti__MCShipment_Special_Services__c specialServices=new zkmulti__MCShipment_Special_Services__c();
        specialServices.CurrencyIsoCode='USD'; 
        specialServices.zkmulti__Shipment__c=mcShipment.Id;
        insert specialServices;*/
        
    	
    	Test.startTest();
        
        BulkRMAAutoShipmateBatch bulkObj=new BulkRMAAutoShipmateBatch();
       // BulkRMAAutoShipmateBatch.MCShipmateWrapper wrapper=new BulkRMAAutoShipmateBatch.MCShipmateWrapper(zkmcShipment,mcPackage,mcCustomsItem,specialServices);
		
    	bulkObj.execute(null,lstCase);
	    Test.stopTest();
        
    }
    
    static testMethod void testMethodBulkRMAAutoShipmentBatchFedEx(){
       List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        system.debug('caseRmaRecordTypeId'+caseRmaRecordTypeId); 
         
        List<Case> lstCase= new List<Case>(); 
        //Insert Case  
         Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        lstCase.add(caseObj); 
        insert lstCase;
                       
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.CurrencyIsoCode='USD'; 
        rmaObj.Product__c=objProd.Id;
        insert rmaObj;
    	
    	
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
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.ShipmateApp__c = 'FedEx';
        shipmentSetting.FedExShipmatePreference__c = fedexShipment.Id;
    	insert shipmentSetting;
    	
    	Test.startTest();
    	//BulkRMAAutoShipmateBatch.schduleBatch();
        BulkRMAAutoShipmateBatch bulkObj=new BulkRMAAutoShipmateBatch();
    	bulkObj.execute(null,lstCase); 
	    Test.stopTest(); 
        
    }
    
    static testMethod void testMethodBulkRMAAutoShipmentBatchFedExDimension(){
       List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        system.debug('caseRmaRecordTypeId'+caseRmaRecordTypeId); 
         
        List<Case> lstCase= new List<Case>(); 
        //Insert Case  
         Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        lstCase.add(caseObj); 
        insert lstCase;
                       
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.CurrencyIsoCode='USD'; 
        rmaObj.Product__c=objProd.Id;
        insert rmaObj;
    	
    	
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
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.ShipmateApp__c = 'FedEx';
        shipmentSetting.FedExShipmatePreference__c = fedexShipment.Id;
    	insert shipmentSetting;
    	
    	Test.startTest();
    	//BulkRMAAutoShipmateBatch.schduleBatch();
        BulkRMAAutoShipmateBatch bulkObj=new BulkRMAAutoShipmateBatch();
    	//bulkObj.execute(null,lstCase); 
        String jobID = System.schedule('Schedule for all records Test ' + System.now(), '0 0 15 * * ?', bulkObj);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
	    Test.stopTest(); 
        
    }
    
   /* static testMethod void testMethodBulkRMAAutoShipmentBatchFedExNoShipment(){
       List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        system.debug('caseRmaRecordTypeId'+caseRmaRecordTypeId); 
         
        List<Case> lstCase= new List<Case>(); 
        //Insert Case  
         Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        lstCase.add(caseObj); 
        insert lstCase;
                       
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.CurrencyIsoCode='USD'; 
        rmaObj.Product__c=objProd.Id;
        insert rmaObj;
        
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
    	
    	Test.startTest();
    	BulkRMAAutoShipmateBatch.schduleBatch();
        BulkRMAAutoShipmateBatch bulkObj=new BulkRMAAutoShipmateBatch();
    	bulkObj.execute(null,lstCase); 
	    Test.stopTest(); 
        
    }*/
    
    
    static testMethod void testgetShipmentSetting(){
        //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
        
        ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.ShipmateApp__c = 'FedEx';
        shipmentSetting.FedExShipmatePreference__c = fedexShipment.Id;
        shipmentSetting.ReturnLocation__c=objAcc.Id;
    	insert shipmentSetting;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
         
        Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        
        insert caseObj;
        
        Id returnlocationId=objAcc.Id;
        Set<Id> locationIds=new Set<Id>();
        locationIds.add(objAcc.Id);
        test.startTest();
        
        
       // ShipmateUtility.getShipmentSetting(objAcc.Id);
        ShipmateUtility.getShpmntStngsByRtrnLocIds(locationIds);
        ShipmateUtility.getCaseDetails(caseObj.Id);
        test.stopTest();
    }
    
    static testMethod void testcreateUPSQueuedShipmentUtility(){
    	
    	List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        system.debug('caseRmaRecordTypeId'+caseRmaRecordTypeId); 
         
        List<Case> lstCase= new List<Case>(); 
        //Insert Case  
         Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        lstCase.add(caseObj); 
        insert lstCase;
        
        
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.CurrencyIsoCode='USD'; 
        rmaObj.Product__c=objProd.Id;
        insert rmaObj;
    	
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
        
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
    	insert mcShipment;
        
    	zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
        zkups__BulkShipment__c bulkShipment =  ShipmateUtility.createUPSBulkShipmate(upsShipment,true);
		Id UPSbulkShipmentId = bulkShipment.Id;
       
        zkfedex__BulkShipment__c fedexBulkShipment=ShipmateUtility.createFedExBulkShipmate(fedexShipment,true);
        Id fedExSbulkShipmentId=fedexBulkShipment.Id;
        
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        zkfedex__CustomAddressSource__c fedexCustomAddress=new zkfedex__CustomAddressSource__c();
        fedexCustomAddress.zkfedex__CustomAddressSourceObject__c='Case';
        insert fedexCustomAddress;
            
        zkups__CustomAddressSource__c customAddressSource = ShipmateUtility.getUPSCustomAddressSource('Case');
        Id UPScustomAddressSourceID = customAddressSource.Id;
        
        zkfedex__CustomAddressSource__c customFedExAddressSource = ShipmateUtility.getFedExCustomAddressSource('Case');
        Id FedExcustomAddressSourceID = customFedExAddressSource.Id;
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.UPSShipmatePreference__c = upsShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'UPS';
        shipmentSetting.IsAccountAddress__c=true;
    	insert shipmentSetting;
        
        ShipmentSetting__c shipmentSettingFedex = new ShipmentSetting__c();
    	shipmentSettingFedex.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
        shipmentSettingFedex.FedExShipmatePreference__c=fedexShipment.Id;
    	shipmentSettingFedex.ShipmateApp__c = 'FedEx';
        shipmentSettingFedex.IsAccountAddress__c=true;
    	insert shipmentSettingFedex;
        
    	String workingObject = 'Case';
        //String workingObject ='WorkOrder';
        Test.startTest();
       
        ShipmateUtility.createUPSQueuedShipment(upsShipment, workingObject, rmaObj.Id, caseObj, shipmentSetting,
                                                 bulkShipment.Id, true, true, 'returnDescription', UPScustomAddressSourceID, 
                                                 'UPS Standard')  ;
        
      
        ShipmateUtility.createFedExQueuedShipment(fedexShipment, workingObject, rmaObj.Id, caseObj, shipmentSettingFedex,
                                                 fedExSbulkShipmentId, true, true, 'returnDescription', FedExcustomAddressSourceID, 
                                                'UPS Standard')  ;
        
        ShipmateUtility.getMCShipmentPreference(mcShipment.Id);
        ShipmateUtility.processUPSBulkShipment(bulkShipment.Id, true);
        ShipmateUtility.processFedExBulkShipment(bulkShipment.Id, true);
        ShipmateUtility.processMCBulkShipment(bulkShipment.Id, true);
        ShipmateUtility.processUPSBulkShipment(bulkShipment.Id, false);
        ShipmateUtility.processFedExBulkShipment(bulkShipment.Id, false);
        ShipmateUtility.processMCBulkShipment(bulkShipment.Id, false);
        ShipmateUtility.getFedExShipmentPreference(fedexShipment.Id);
        ShipmateUtility.getUPSShipmentPreference(upsShipment.Id);
        ShipmateUtility.getShipmentSetting(objServiceAcc.Id);
	    Test.stopTest();
        
    }
    
    static testMethod void testcreateUPSFedExQueuedWorkOrderShipmentUtility(){
    	
    	List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Serviceable__c=true;
        insert objProd;  
        
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
       // insert contactObj;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();  
        system.debug('caseRmaRecordTypeId'+caseRmaRecordTypeId); 
         
        List<Case> lstCase= new List<Case>(); 
        //Insert Case  
         Case caseObj = new Case(
        							AccountId=objAcc.Id,
        							PriceCalculationRequired__c=false,
        							RMAStatus__c = 'Scheduled For Label Generation',
        							ContactId=contactObj.Id,
        							currencyISOCode='USD',
									Country__c='USA',
        							Service_Center__c=objServiceAcc.Id,
        							Product__c=objProd.Id,
        							Return_Location__c = 'USA WHSE TORR QC',
        							Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501',
        							RecordTypeId = caseRmaRecordTypeId
        						);  
       
        lstCase.add(caseObj); 
        insert lstCase;
        
        WorkOrder workorder=new WorkOrder();
        workorder.FirstName__c='Test';
        workorder.LastName__c='WorkOrder';
        workorder.CurrencyIsoCode='USD';
        workorder.Status='New';
        workorder.Email__c='test@123.com';
        workorder.CaseNumber__c='1234';
        workorder.ApprovalStatus__c='Approved';
        workorder.Product__c=objProd.Id;
        insert workorder;
                
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100);
        rmaObj.CurrencyIsoCode='USD'; 
        rmaObj.Product__c=objProd.Id;
        insert rmaObj;
    	
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
    	insert fedexShipment;
        
		zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
    	insert mcShipment;
        
    	zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
    	insert upsShipment;
    	
        zkups__BulkShipment__c bulkShipment =  ShipmateUtility.createUPSBulkShipmate(upsShipment,true);
		Id UPSbulkShipmentId = bulkShipment.Id;
       
        zkfedex__BulkShipment__c fedexBulkShipment=ShipmateUtility.createFedExBulkShipmate(fedexShipment,true);
        Id fedExSbulkShipmentId=fedexBulkShipment.Id;
        
    	zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
    	upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        zkfedex__CustomAddressSource__c fedexCustomAddress=new zkfedex__CustomAddressSource__c();
        fedexCustomAddress.zkfedex__CustomAddressSourceObject__c='Case';
        insert fedexCustomAddress;
            
        zkups__CustomAddressSource__c customAddressSource = ShipmateUtility.getUPSCustomAddressSource('Case');
        Id UPScustomAddressSourceID = customAddressSource.Id;
        
        zkfedex__CustomAddressSource__c customFedExAddressSource = ShipmateUtility.getFedExCustomAddressSource('Case');
        Id FedExcustomAddressSourceID = customFedExAddressSource.Id;
    	
    	//Insert Shipment Setting
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSetting.UPSShipmatePreference__c = upsShipment.Id;
    	shipmentSetting.ShipmateApp__c = 'UPS';
        shipmentSetting.IsAccountAddress__c=true;
    	insert shipmentSetting;
        
        ShipmentSetting__c shipmentSettingUps = new ShipmentSetting__c();
    	shipmentSettingUps.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
    	shipmentSettingUps.UPSShipmatePreference__c = upsShipment.Id;
    	shipmentSettingUps.ShipmateApp__c = 'UPS';
        shipmentSettingUps.IsAccountAddress__c=false;
    	insert shipmentSettingUps;
        
        ShipmentSetting__c shipmentSettingFedex = new ShipmentSetting__c();
    	shipmentSettingFedex.ReturnAddress__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
        shipmentSettingFedex.FedExShipmatePreference__c=fedexShipment.Id;
    	shipmentSettingFedex.ShipmateApp__c = 'FedEx';
        shipmentSettingFedex.IsAccountAddress__c=true;
    	insert shipmentSettingFedex;
        
    	//String workingObject = 'Case';
        String workingObject ='WorkOrder';
        Test.startTest();
       
        ShipmateUtility.createUPSQueuedShipment(upsShipment, workingObject, workorder.Id, caseObj, shipmentSetting,
                                                 bulkShipment.Id, true, true, 'returnDescription', UPScustomAddressSourceID, 
                                                 'UPS Standard')  ;
        
       
       
        ShipmateUtility.createFedExQueuedShipment(fedexShipment, workingObject, workorder.Id, caseObj, shipmentSettingFedex,
                                                 fedExSbulkShipmentId, true, true, 'returnDescription', FedExcustomAddressSourceID, 
                                                'UPS Standard')  ;
        
        ShipmateUtility.getMCShipmentPreference(mcShipment.Id);
        ShipmateUtility.processUPSBulkShipment(bulkShipment.Id, true);
        ShipmateUtility.processFedExBulkShipment(bulkShipment.Id, true);
        ShipmateUtility.processMCBulkShipment(bulkShipment.Id, true);
        ShipmateUtility.processUPSBulkShipment(bulkShipment.Id, false);
        ShipmateUtility.processFedExBulkShipment(bulkShipment.Id, false);
        ShipmateUtility.processMCBulkShipment(bulkShipment.Id, false);
        ShipmateUtility.getFedExShipmentPreference(fedexShipment.Id);
        ShipmateUtility.getUPSShipmentPreference(upsShipment.Id);
        ShipmateUtility.getShipmentSetting(objServiceAcc.Id);
	    Test.stopTest();
        
    }
    
    
}