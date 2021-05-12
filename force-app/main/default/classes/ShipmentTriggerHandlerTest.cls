@isTest

public class ShipmentTriggerHandlerTest {

     public static testmethod void testForInsert() 
     {
     
        Account acc = new Account(Name = 'Test Account1', CurrencyISOcode='USD');
        Account serviceCenter = new Account(Name = 'Test Account2', CurrencyISOcode='USD');
        serviceCenter.Type='Authorized Service Center';
        
        insert acc;
        insert serviceCenter;
        QCAlert__c qcAlertObj = TestDataFactory.createQCAlert('please review water and heating details','Test QC', true );
         
        Id rt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
       
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        caseObj.QC_Alert__c = qcAlertObj.Id;
        caseObj.Service_Center__c = serviceCenter.Id;
        caseObj.RA_Tracking__c = '1ZE388F29096824016';
        caseObj.RecordtypeId = rt ;
        caseObj.Country__c = 'USA';
       
        
        Product2 productRecord = TestDataFactory.createProduct('Product 998', true, false);
		productRecord.AX_Item_Number__c = '4567';
		productRecord.Serviceable__c = true;
		insert productRecord;
		
        WorkOrder workOrderRecord = TestDataFactory.createWorkOrder('424306', 'USD', false);
        workOrderRecord.BatchCode__c = '1234';
        workOrderRecord.PurchaseDate__c = Date.today();
        workOrderRecord.Product__c = productRecord.Id;
        workOrderRecord.FirstName__c = 'Nihkil';
        workOrderRecord.lastName__c = 'Palekar';
        workOrderRecord.Email__c = 'nikhil_palekar@example.com';
        
        insert caseObj;
        insert workOrderRecord;
        
        zkups__UPSShipment__c objzkupsUPSShipmentc = new zkups__UPSShipment__c();
        objzkupsUPSShipmentc.zkups__RecipientCompany__c='abc';
        objzkupsUPSShipmentc.zkups__RecipientPhone__c='1254345121';
        objzkupsUPSShipmentc.zkups__RecipientStreet__c='pune';
        objzkupsUPSShipmentc.zkups__RecipientState__c='maha';
        objzkupsUPSShipmentc.zkups__RecipientCountry__c='india';
        objzkupsUPSShipmentc.zkups__RecipientCity__c='pune';
        objzkupsUPSShipmentc.zkups__RecipientPostalCode__c='424306';
        objzkupsUPSShipmentc.zkups__WeightUnits__c='45';
        objzkupsUPSShipmentc.zkups__SsProcessReturnShipment__c =true;
        objzkupsUPSShipmentc.Case__c = caseObj.Id;
        objzkupsUPSShipmentc.WorkOrder__c = workOrderRecord.Id;
        objzkupsUPSShipmentc.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc.zkups__MasterTrackingId__c = 'TestMaster';
        
        zkmulti__MCShipment__c objzkmultiShipmentc = new zkmulti__MCShipment__c();
        objzkmultiShipmentc.zkmulti__Recipient_Company__c='abc';
        objzkmultiShipmentc.zkmulti__Recipient_Phone__c='1254345121';
        objzkmultiShipmentc.zkmulti__Recipient_Street__c='pune';
        objzkmultiShipmentc.zkmulti__Recipient_State_Province__c='maha';
        objzkmultiShipmentc.zkmulti__Recipient_Country__c='india';
        objzkmultiShipmentc.zkmulti__Recipient_City__c='pune';
        objzkmultiShipmentc.zkmulti__Recipient_Zip_Postal_Code__c='424306';
        objzkmultiShipmentc.zkmulti__Weight_Units__c='45';
        objzkmultiShipmentc.zkmulti__Shipment_Processing_Completed__c =true;
        objzkmultiShipmentc.Case__c = caseObj.Id;
        objzkmultiShipmentc.WorkOrder__c = workOrderRecord.Id;
        objzkmultiShipmentc.zkmulti__Return_Shipment__c = true;
        objzkmultiShipmentc.zkmulti__Status_Description__c = 'TestStatus';
        objzkmultiShipmentc.zkmulti__Tracking_Number__c = 'TestMaster';
        objzkmultiShipmentc.zkmulti__Tracking_Stage__c = 'In Transit';
        
        zkfedex__Shipment__c objzkFedexShipmentc = new zkfedex__Shipment__c();
        objzkFedexShipmentc.zkfedex__RecipientCompany__c='abc';
        objzkFedexShipmentc.zkfedex__RecipientPhone__c='1254345121';
        objzkFedexShipmentc.zkfedex__RecipientStreet__c='pune';
        objzkFedexShipmentc.zkfedex__RecipientState__c='maha';
        objzkFedexShipmentc.zkfedex__RecipientCountry__c='india';
        objzkFedexShipmentc.zkfedex__RecipientCity__c='pune';
        objzkFedexShipmentc.zkfedex__RecipientPostalCode__c='424306';
        objzkFedexShipmentc.zkfedex__WeightUnits__c='45';
        objzkFedexShipmentc.zkfedex__SsProcessReturnShipment__c =true;
        objzkFedexShipmentc.Case__c = caseObj.Id;
        objzkFedexShipmentc.WorkOrder__c = workOrderRecord.Id;
        objzkFedexShipmentc.zkfedex__StatusDescription__c = 'TestStatus';
        objzkFedexShipmentc.zkfedex__MasterTrackingId__c = 'TestMaster';
        
        
        zkups__UPSShipment__c objzkupsUPSShipmentc2 = new zkups__UPSShipment__c();
        objzkupsUPSShipmentc2.zkups__RecipientCompany__c='abc';
        objzkupsUPSShipmentc2.zkups__RecipientPhone__c='1254345121';
        objzkupsUPSShipmentc2.zkups__RecipientStreet__c='pune';
        objzkupsUPSShipmentc2.zkups__RecipientState__c='maha';
        objzkupsUPSShipmentc2.zkups__RecipientCountry__c='india';
        objzkupsUPSShipmentc2.zkups__RecipientCity__c='pune';
        objzkupsUPSShipmentc2.zkups__RecipientPostalCode__c='424306';
        objzkupsUPSShipmentc2.zkups__WeightUnits__c='45';
        objzkupsUPSShipmentc2.zkups__SsProcessReturnShipment__c =true;
        objzkupsUPSShipmentc2.WorkOrder__c = workOrderRecord.Id;
        objzkupsUPSShipmentc2.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc2.zkups__MasterTrackingId__c = 'TestMaster';
        
        zkmulti__MCShipment__c objzkmultiShipmentc2 = new zkmulti__MCShipment__c();
        objzkmultiShipmentc2.zkmulti__Recipient_Company__c='abc';
        objzkmultiShipmentc2.zkmulti__Recipient_Phone__c='1254345121';
        objzkmultiShipmentc2.zkmulti__Recipient_Street__c='pune';
        objzkmultiShipmentc2.zkmulti__Recipient_State_Province__c='maha';
        objzkmultiShipmentc2.zkmulti__Recipient_Country__c='india';
        objzkmultiShipmentc2.zkmulti__Recipient_City__c='pune';
        objzkmultiShipmentc2.zkmulti__Recipient_Zip_Postal_Code__c='424306';
        objzkmultiShipmentc2.zkmulti__Weight_Units__c='45';
        objzkmultiShipmentc2.zkmulti__Shipment_Processing_Completed__c =true;
        objzkmultiShipmentc2.WorkOrder__c = workOrderRecord.Id;
        objzkmultiShipmentc2.zkmulti__Status_Description__c = 'TestStatus';
        objzkmultiShipmentc2.zkmulti__Tracking_Number__c = 'TestMaster';
        objzkmultiShipmentc2.zkmulti__Tracking_Stage__c = 'In Transit';
        
        zkfedex__Shipment__c objzkFedexShipmentc2 = new zkfedex__Shipment__c();
        objzkFedexShipmentc2.zkfedex__RecipientCompany__c='abc';
        objzkFedexShipmentc2.zkfedex__RecipientPhone__c='1254345121';
        objzkFedexShipmentc2.zkfedex__RecipientStreet__c='pune';
        objzkFedexShipmentc2.zkfedex__RecipientState__c='maha';
        objzkFedexShipmentc2.zkfedex__RecipientCountry__c='india';
        objzkFedexShipmentc2.zkfedex__RecipientCity__c='pune';
        objzkFedexShipmentc2.zkfedex__RecipientPostalCode__c='424306';
        objzkFedexShipmentc2.zkfedex__WeightUnits__c='45';
        objzkFedexShipmentc2.zkfedex__SsProcessReturnShipment__c =true;
        objzkFedexShipmentc2.WorkOrder__c = workOrderRecord.Id;
        objzkFedexShipmentc2.zkfedex__StatusDescription__c = 'TestStatus';
        objzkFedexShipmentc2.zkfedex__MasterTrackingId__c = 'TestMaster';
        
        
        zkups__UPSShipment__c objzkupsUPSShipmentc3 = new zkups__UPSShipment__c();
        objzkupsUPSShipmentc3.zkups__RecipientCompany__c='abc';
        objzkupsUPSShipmentc3.zkups__RecipientPhone__c='1254345121';
        objzkupsUPSShipmentc3.zkups__RecipientStreet__c='pune';
        objzkupsUPSShipmentc3.zkups__RecipientState__c='maha';
        objzkupsUPSShipmentc3.zkups__RecipientCountry__c='india';
        objzkupsUPSShipmentc3.zkups__RecipientCity__c='pune';
        objzkupsUPSShipmentc3.zkups__RecipientPostalCode__c='424306';
        objzkupsUPSShipmentc3.zkups__WeightUnits__c='45';
        objzkupsUPSShipmentc3.zkups__SsProcessReturnShipment__c =false;
        objzkupsUPSShipmentc3.WorkOrder__c = workOrderRecord.Id;
        objzkupsUPSShipmentc3.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc3.zkups__MasterTrackingId__c = 'TestMaster';
        
        zkmulti__MCShipment__c objzkmultiShipmentc3 = new zkmulti__MCShipment__c();
        objzkmultiShipmentc3.zkmulti__Recipient_Company__c='abc';
        objzkmultiShipmentc3.zkmulti__Recipient_Phone__c='1254345121';
        objzkmultiShipmentc3.zkmulti__Recipient_Street__c='pune';
        objzkmultiShipmentc3.zkmulti__Recipient_State_Province__c='maha';
        objzkmultiShipmentc3.zkmulti__Recipient_Country__c='india';
        objzkmultiShipmentc3.zkmulti__Recipient_City__c='pune';
        objzkmultiShipmentc3.zkmulti__Recipient_Zip_Postal_Code__c='424306';
        objzkmultiShipmentc3.zkmulti__Weight_Units__c='45';
        objzkmultiShipmentc3.zkmulti__Shipment_Processing_Completed__c =false;
        objzkmultiShipmentc3.WorkOrder__c = workOrderRecord.Id;
        objzkmultiShipmentc3.zkmulti__Status_Description__c = 'TestStatus';
        objzkmultiShipmentc3.zkmulti__Tracking_Number__c = 'TestMaster';
        
        zkfedex__Shipment__c objzkFedexShipmentc3 = new zkfedex__Shipment__c();
        objzkFedexShipmentc3.zkfedex__RecipientCompany__c='abc';
        objzkFedexShipmentc3.zkfedex__RecipientPhone__c='1254345121';
        objzkFedexShipmentc3.zkfedex__RecipientStreet__c='pune';
        objzkFedexShipmentc3.zkfedex__RecipientState__c='maha';
        objzkFedexShipmentc3.zkfedex__RecipientCountry__c='india';
        objzkFedexShipmentc3.zkfedex__RecipientCity__c='pune';
        objzkFedexShipmentc3.zkfedex__RecipientPostalCode__c='424306';
        objzkFedexShipmentc3.zkfedex__WeightUnits__c='45';
        objzkFedexShipmentc3.zkfedex__SsProcessReturnShipment__c = false;
        objzkmultiShipmentc3.WorkOrder__c = workOrderRecord.Id;
        objzkFedexShipmentc3.zkfedex__StatusDescription__c = 'TestStatus';
        objzkFedexShipmentc3.zkfedex__MasterTrackingId__c = 'TestMaster';
        
        Test.startTest();
        
        insert objzkupsUPSShipmentc;
        insert objzkmultiShipmentc;
        insert objzkFedexShipmentc;
        insert objzkupsUPSShipmentc2;
        insert objzkmultiShipmentc2;
        insert objzkFedexShipmentc2;
        insert objzkupsUPSShipmentc3;
        insert objzkmultiShipmentc3;
        insert objzkFedexShipmentc3;
        
        Test.StopTest();


        //system.assertEquals(errorList.size(),1);
    }
}