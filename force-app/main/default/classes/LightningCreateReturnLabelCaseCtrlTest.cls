@isTest
public class LightningCreateReturnLabelCaseCtrlTest{
    
    static testMethod void testMethodValidateCaseBeforShipment(){
        CreateReturnLabelCtrl ctrl = new CreateReturnLabelCtrl();
        ctrl.workingObject = 'Case';
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        //Insert Account        
        Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
                
        //Insert Contact
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        caseObj.RecordTypeId = recordTypeRecord.id;
        caseObj.Purchase_Invoice_No__c = 'TT01' ;
        caseObj.currencyISOCode='USD';
        caseObj.ContactId=contactObj.Id;
        caseObj.Return_Location__c=Null;
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
        
        Id locationId = Null;
        LightningCreateReturnLabelCaseCtrl.validateCaseBeforShipment(locationId, caseObj);
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
        
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createFedExShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, fedexShipment.Id, 'FedEx');
        insert shipmentSetting;
        
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
        LightningCreateReturnLabelCaseCtrl.initiateCreateOutboundShipmate(caseObj.Id,caseObj.Id,'Service Center',true);
        //ctrl.cancel();
        
    }
    
    
    static testMethod void testCreateReturnShipmateForMultiCarrier(){
        
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
        
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
        
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        Boolean messageFound = false;
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
        insert upsShipment;
        
        zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting;
        
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        // mcShipment.zkmulti__Sender_Country__c='Australia';
        // mcShipment.zkmulti__Recipient_Country__c='Australia';
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.ShipmatePreference__c = mcShipment.Id;
        shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        upsert shipmentSetting;
        
        //Case caseTest = ctrl.getCaseRecord();
        
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
        LightningCreateReturnLabelCaseCtrl.initiateCreateReturnShipmate(caseObj.Id,caseObj.Id,'Service Center',true);
        LightningCreateReturnLabelCaseCtrl.initLoadConfig(caseObj.Id);
    }
    
    static testMethod void testCreateOutboundShipmateForMultiCarrier_ReturnLocation(){
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        //Insert Account        
        Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        //Insert Service Account
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Return Center';
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
        
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
        
        //caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.ReturnLocation__c = objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        Boolean messageFound = false;
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
        insert upsShipment;
        
        zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting;
         ShipmentSetting__c shipmentSetting1 = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1179', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting1;
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        // mcShipment.zkmulti__Sender_Country__c='Australia';
        // mcShipment.zkmulti__Recipient_Country__c='Australia';
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.ShipmatePreference__c = mcShipment.Id;
        shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        upsert shipmentSetting;
        
        //Case caseTest = ctrl.getCaseRecord();
        
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
        LightningCreateReturnLabelCaseCtrl.initiateCreateOutboundShipmate(caseObj.Id,caseObj.Id,'Return Location',true);
        LightningCreateReturnLabelCaseCtrl.initLoadConfig(caseObj.Id);
    }
    
    static testMethod void testCreateReturnShipmateForMultiCarrier_ReturnLocation(){
        
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        //Insert Account        
        Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
        insert objAcc;
        
        //Insert Service Account
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Return Center';
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
        
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
        
        //caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.ReturnLocation__c = objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        Boolean messageFound = false;
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
        insert upsShipment;
        
        zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting;
        ShipmentSetting__c shipmentSetting1 = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1179', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting1;
        
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        // mcShipment.zkmulti__Sender_Country__c='Australia';
        // mcShipment.zkmulti__Recipient_Country__c='Australia';
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.ShipmatePreference__c = mcShipment.Id;
        shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        upsert shipmentSetting;
        
        //Case caseTest = ctrl.getCaseRecord();
        
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
        LightningCreateReturnLabelCaseCtrl.initiateCreateReturnShipmate(caseObj.Id,caseObj.Id,'Return Location',true);
        LightningCreateReturnLabelCaseCtrl.initLoadConfig(caseObj.Id);
    }
    
    static testMethod void testCreateReturnShipmateForFedEx(){   
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
        
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
        
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean messageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getSummary() == 'System.Label.No_Shipping_Preference_found'
               && message.getSeverity() == ApexPages.Severity.ERROR) {
                   messageFound = true;        
               }
        }
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
        insert upsShipment;
        
        zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'FedEx');
        insert shipmentSetting;
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
        insert fedexShipment;
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
        //shipmentSetting.ShipmatePreference__c = fedexShipment.Id;
        shipmentSetting.ShipmateApp__c = 'FedEx';
        upsert shipmentSetting;
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
        
        LightningCreateReturnLabelCaseCtrl.createReturnShipmate(caseObj.Id,caseObj.Id,objServiceAcc.Id,shipmentSetting,shipmentSetting
                                                                ,true,'case',true,'','Service Center','','FedEx','',12,12.0,12.0,12.0,12.0);
    }
    
    
    
    
    static testMethod void testCreateReturnShipmateForUPS(){
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
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        upsert objProd;  
        
        caseObj.Service_Center__c=objServiceAcc.Id;
        caseObj.Product__c=objProd.Id;
        upsert caseObj;
        Boolean messageFound = false;
        //Create return shipment for UPS
        zkups__UPSShipmatePreference__c upsShipment = new zkups__UPSShipmatePreference__c();
        insert upsShipment;
        
        zkups__CustomAddressSource__c upsCustomAddress = new zkups__CustomAddressSource__c();
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting;
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
        insert fedexShipment;
        // mcShipment.zkmulti__Sender_Country__c='Australia';
        // mcShipment.zkmulti__Recipient_Country__c='Australia';
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = upsShipment.Id;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
        //shipmentSetting.ShipmatePreference__c = fedexShipment.Id;
        shipmentSetting.ShipmateApp__c = 'UPS';
        upsert shipmentSetting;
        
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
        
        LightningCreateReturnLabelCaseCtrl.createReturnShipmate(caseObj.Id,caseObj.Id,objServiceAcc.Id,shipmentSetting,shipmentSetting
                                                                ,true,'case',true,'','Service Center','','UPS','',12,12.0,12.0,12.0,12.0);
        
    }
    
    static testMethod void testCreateReturnShipmateForMultiCarrier1(){
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
        
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
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
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        insert shipmentSetting;
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
        insert fedexShipment;
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
        shipmentSetting.ShipmatePreference__c = mcShipment.Id;
        shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        upsert shipmentSetting;
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
        
        LightningCreateReturnLabelCaseCtrl.createReturnShipmate(caseObj.Id,caseObj.Id,objServiceAcc.Id,shipmentSetting,shipmentSetting
                                                                ,true,'Case',true,'','Service Center','','Multi Carrier','',12,12.0,12.0,12.0,12.0);
        LightningCreateReturnLabelCaseCtrl.getCaseRecord(caseObj.Id,'Service Center');
        LightningCreateReturnLabelCaseCtrl.setShipmentSettingFromCarrier(caseObj.Id,'Service Center',shipmentSetting.Id,objServiceAcc.Id,shipmentSetting,shipmentSetting);
    }
    
    
    
    static testMethod void testCreateReturnShipmate_bulkUPS(){
        
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
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
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
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        shipmentSetting.ShipmateApp__c = 'UPS';
        insert shipmentSetting;
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
        insert fedexShipment;
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
        shipmentSetting.ShipmateApp__c = 'UPS';
        upsert shipmentSetting;     
        
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
        zkups__UPSShipmatePreference__c shipmatePref = ShipmateUtility.getUPSShipmentPreference(upsShipment.id);
        zkups__BulkShipment__c bulkShipment = ShipmateUtility.createUPSBulkShipmate(shipmatePref, true);
        system.debug('bulkShipment****' + JSON.serialize(bulkShipment));
        Id bulkShipmentId = bulkShipment.Id;
        LightningCreateReturnLabelCaseCtrl.processBulkShipment(caseObj.Id,caseObj.Id,bulkShipmentId,shipmentSetting,true,'Service Center');
    }
    
    static testMethod void testCreateReturnShipmate_bulkFedex(){
        
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
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
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
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        shipmentSetting.ShipmateApp__c = 'FedEx';
        insert shipmentSetting;
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'UPS';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
        insert fedexShipment;
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
        shipmentSetting.ShipmateApp__c = 'FedEx';
        upsert shipmentSetting;     
        
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
        zkfedex__ShipmatePreference__c  shipmatePref = ShipmateUtility.getFedExShipmentPreference(fedexShipment.id);
        zkfedex__BulkShipment__c bulkShipment = ShipmateUtility.createfedexBulkShipmate(shipmatePref, true);
        system.debug('bulkShipment****' + JSON.serialize(bulkShipment));
        Id bulkShipmentId = bulkShipment.Id;
        LightningCreateReturnLabelCaseCtrl.processBulkShipment(caseObj.Id,caseObj.Id,bulkShipmentId,shipmentSetting,true,'Service Center');
    }
    
    
    static testMethod void testCreateReturnShipmate_bulkMC(){
        
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
        
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
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
        upsCustomAddress.zkups__CustomAddressSourceObject__c = 'Case';
        insert upsCustomAddress;
        
        ShipmentSetting__c shipmentSetting = TestDataFactory.createShipmentSettings('500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178', objServiceAcc.Id, upsShipment.Id, 'UPS');
        shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        insert shipmentSetting;
        
        
        
        //Create return shipment for MC
        zkmulti__MCShipmate_Preference__c mcShipment = new zkmulti__MCShipmate_Preference__c();
        mcShipment.zkmulti__Carrier__c = 'Multi Carrier';
        
        zkfedex__ShipmatePreference__c fedexShipment = new zkfedex__ShipmatePreference__c();
        insert fedexShipment;
        insert mcShipment;
        
        zkmulti__MCCustom_Address_Source__c mcCustomAddress = new zkmulti__MCCustom_Address_Source__c();
        mcCustomAddress.zkmulti__Custom_Address_Source_Object__c = 'Case';
        insert mcCustomAddress;
        
        shipmentSetting.UPSShipmatePreference__c = null;
        shipmentSetting.FedExShipmatePreference__c=fedexShipment.Id;
        shipmentSetting.ShipmateApp__c = 'Multi Carrier';
        upsert shipmentSetting;     
        
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
        zkmulti__MCShipmate_Preference__c  shipmatePref = ShipmateUtility.getMCShipmentPreference(mcShipment.id);
        zkmulti__MCBulk_Shipment__c  bulkShipment = ShipmateUtility.createMCBulkShipmate(shipmatePref, true);
        system.debug('bulkShipment****' + JSON.serialize(bulkShipment));
        Id bulkShipmentId = bulkShipment.Id;
        LightningCreateReturnLabelCaseCtrl.processBulkShipment(caseObj.Id,caseObj.Id,bulkShipmentId,shipmentSetting,true,'Service Center');
    }
    
}