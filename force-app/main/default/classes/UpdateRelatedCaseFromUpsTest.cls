@isTest
public class UpdateRelatedCaseFromUpsTest {

     public static testmethod void testForInsert() 
     {
     
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Account objServiceAcc = TestDataFactory.createAccountRecord('Account2', 'BUS', 'test@email.com', '123456');
        objServiceAcc.Type = 'Authorized Service Center';
        insert objServiceAcc;
        
        //QCAlert__c qcAlertObj = TestDataFactory.createQCAlert('please review water and heating details','Test QC', true );
        QCAlert__c qcAlertObj = new QCAlert__c();
        insert qcAlertObj;
        Product2 productRecord = TestDataFactory.createProduct('Product #Product Name# one','BES920XL',true,false,false,15,true, true);
       
        
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
        
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        insert caseObj;
        
        caseObj.QC_Alert__c = qcAlertObj.id;
        caseObj.Service_Center__c = objServiceAcc.id;
        caseObj.RecordTypeId = caseRmaRecordTypeId;
        update caseObj;
        
        //Account serviceAccount = [SELECT Id FROM Account WHERE Id =: objServiceAcc.id limit 1];
        
        QCLocation__c qcLocationObj = TestDataFactory.createQCLocation(acc.Id,'USA',productRecord.Id, qcAlertObj.Id,false);
        qcLocationObj.Count__c = 100;
        qcLocationObj.ReturnLocation__c = caseObj.Service_Center__c;
        qcLocationObj.QCAlertReturnLocationCompositeKey__c = caseObj.QC_Alert__c+''+caseObj.Service_Center__c;
        insert qcLocationObj;
        
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
        objzkupsUPSShipmentc.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc.zkups__MasterTrackingId__c = 'TestMaster';
        
        Test.startTest();
        
        insert objzkupsUPSShipmentc;
        
        Test.StopTest();

        Case result =
            [SELECT Id, RA_Tracking_Status__c, RA_Tracking__c
             FROM Case
             WHERE Id = :caseObj.Id];
             
        List<Error__c> errorList =[select Id,Case__c,Description__c 
                                   From Error__c];


        System.assert(result.RA_Tracking_Status__c == objzkupsUPSShipmentc.zkups__StatusDescription__c);
        System.assert(result.RA_Tracking__c == objzkupsUPSShipmentc.zkups__MasterTrackingId__c);
        //system.assertEquals(errorList.size(),1);
    }
    
    public static testmethod void testForUpdate() 
     {
     
        Account acc = new Account(Name = 'Test Account');
        
        insert acc;
        
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        
        insert caseObj;
        
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
        
        insert objzkupsUPSShipmentc;
        
        objzkupsUPSShipmentc.Case__c = caseObj.Id;
        objzkupsUPSShipmentc.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc.zkups__MasterTrackingId__c = 'TestMaster';
        
        Test.startTest();
        
        update objzkupsUPSShipmentc;
        
        Test.StopTest();

        Case result =
            [SELECT Id, RA_Tracking_Status__c, RA_Tracking__c
             FROM Case
             WHERE Id = :caseObj.Id];
             
        List<Error__c> errorList =[select Id,Case__c,Description__c 
                                   From Error__c];


        System.assert(result.RA_Tracking_Status__c == objzkupsUPSShipmentc.zkups__StatusDescription__c);
        System.assert(result.RA_Tracking__c == objzkupsUPSShipmentc.zkups__MasterTrackingId__c);
        //system.assertEquals(errorList.size(),2);
    }
    
    public static testmethod void test1()
     {
     
        Account acc = new Account(Name = 'Test Account');
        
        insert acc;
        
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        
        insert caseObj;
        
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
	        objProd.CurrencyIsoCode = 'USD';
	        objProd.Serviceable__c = true;
	        insert objProd;  
        
        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        insert workOrderObj;
        
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
        objzkupsUPSShipmentc.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc.zkups__MasterTrackingId__c = 'TestMaster';
        objzkupsUPSShipmentc.WorkOrder__c = workOrderObj.id;
        Test.startTest();
        
        insert objzkupsUPSShipmentc;
        
        Test.StopTest();
    }

    public static testmethod void test2()
     {
     
        Account acc = new Account(Name = 'Test Account');
        
        insert acc;
        
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        
        insert caseObj;
        
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
	        objProd.CurrencyIsoCode = 'USD';
	        objProd.Serviceable__c = true;
	        insert objProd;  
        
        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        insert workOrderObj;
        
        zkups__UPSShipment__c objzkupsUPSShipmentc = new zkups__UPSShipment__c();
        objzkupsUPSShipmentc.zkups__RecipientCompany__c='abc';
        objzkupsUPSShipmentc.zkups__RecipientPhone__c='1254345121';
        objzkupsUPSShipmentc.zkups__RecipientStreet__c='pune';
        objzkupsUPSShipmentc.zkups__RecipientState__c='maha';
        objzkupsUPSShipmentc.zkups__RecipientCountry__c='india';
        objzkupsUPSShipmentc.zkups__RecipientCity__c='pune';
        objzkupsUPSShipmentc.zkups__RecipientPostalCode__c='424306';
        objzkupsUPSShipmentc.zkups__WeightUnits__c='45';
        objzkupsUPSShipmentc.zkups__SsProcessReturnShipment__c =false;
        objzkupsUPSShipmentc.Case__c = caseObj.Id;
        objzkupsUPSShipmentc.zkups__StatusDescription__c = 'TestStatus';
        objzkupsUPSShipmentc.zkups__MasterTrackingId__c = 'TestMaster';
        objzkupsUPSShipmentc.WorkOrder__c = workOrderObj.id;
        Test.startTest();
        
        insert objzkupsUPSShipmentc;
        
        Test.StopTest();
    }
    
    
}