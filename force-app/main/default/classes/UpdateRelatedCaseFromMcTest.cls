@isTest
public class UpdateRelatedCaseFromMcTest {

     public static testmethod void testForInsert() 
     {
     
        Account acc = new Account(Name = 'Test Account');
        
        insert acc;
        
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        
        insert caseObj;
        
        zkmulti__MCShipment__c objzkupsMCShipmentc = new zkmulti__MCShipment__c();
        objzkupsMCShipmentc.zkmulti__Recipient_Company__c='abc';
        objzkupsMCShipmentc.zkmulti__Recipient_Phone__c='1254345121';
        objzkupsMCShipmentc.zkmulti__Recipient_Street__c='pune';
        objzkupsMCShipmentc.zkmulti__Recipient_State_Province__c='maha';
        objzkupsMCShipmentc.zkmulti__Recipient_Country__c='india';
        objzkupsMCShipmentc.zkmulti__Recipient_City__c='pune';
        objzkupsMCShipmentc.zkmulti__Recipient_Zip_Postal_Code__c='424306';
        objzkupsMCShipmentc.zkmulti__Weight_Units__c='45';
        objzkupsMCShipmentc.zkmulti__Return_Shipment__c =true;
        objzkupsMCShipmentc.Case__c = caseObj.Id;
        objzkupsMCShipmentc.zkmulti__Status_Description__c = 'TestStatus';
        objzkupsMCShipmentc.zkmulti__Tracking_Number__c = 'TestMaster';
        
        Test.startTest();
        
        insert objzkupsMCShipmentc;
        
        Test.StopTest();

        Case result =
            [SELECT Id, RA_Tracking_Status__c, RA_Tracking__c
             FROM Case
             WHERE Id = :caseObj.Id];
             
        List<Error__c> errorList =[select Id,Case__c,Description__c 
                                   From Error__c];


        System.assert(result.RA_Tracking_Status__c == objzkupsMCShipmentc.zkmulti__Status_Description__c);
        System.assert(result.RA_Tracking__c == objzkupsMCShipmentc.zkmulti__Tracking_Number__c);
        //system.assertEquals(errorList.size(),1);
    }
    
    public static testmethod void testForUpdate() 
     {
     
        Account acc = new Account(Name = 'Test Account');
        
        insert acc;
        
        Case caseObj = new Case(Origin = 'Email',Status='Open',Type='Other',AccountId = acc.Id);
        
        insert caseObj;
        
        zkmulti__MCShipment__c objzkupsMCShipmentc = new zkmulti__MCShipment__c();
        objzkupsMCShipmentc.zkmulti__Recipient_Company__c='abc';
        objzkupsMCShipmentc.zkmulti__Recipient_Phone__c='1254345121';
        objzkupsMCShipmentc.zkmulti__Recipient_Street__c='pune';
        objzkupsMCShipmentc.zkmulti__Recipient_State_Province__c='maha';
        objzkupsMCShipmentc.zkmulti__Recipient_Country__c='india';
        objzkupsMCShipmentc.zkmulti__Recipient_City__c='pune';
        objzkupsMCShipmentc.zkmulti__Recipient_Zip_Postal_Code__c='424306';
        objzkupsMCShipmentc.zkmulti__Weight_Units__c='45';
        objzkupsMCShipmentc.zkmulti__Return_Shipment__c =true;
        
        
        insert objzkupsMCShipmentc;
        
        objzkupsMCShipmentc.Case__c = caseObj.Id;
        objzkupsMCShipmentc.zkmulti__Status_Description__c = 'TestStatus';
        objzkupsMCShipmentc.zkmulti__Tracking_Number__c = 'TestMaster';
        
        Test.startTest();
        
        update objzkupsMCShipmentc;
        
        Test.StopTest();

        Case result =
            [SELECT Id, RA_Tracking_Status__c, RA_Tracking__c
             FROM Case
             WHERE Id = :caseObj.Id];
             
        List<Error__c> errorList =[select Id,Case__c,Description__c 
                                   From Error__c];


        System.assert(result.RA_Tracking_Status__c == objzkupsMCShipmentc.zkmulti__Status_Description__c);
        System.assert(result.RA_Tracking__c == objzkupsMCShipmentc.zkmulti__Tracking_Number__c);
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
        
        zkmulti__MCShipment__c objzkupsMCShipmentc = new zkmulti__MCShipment__c();
        objzkupsMCShipmentc.zkmulti__Recipient_Company__c='abc';
        objzkupsMCShipmentc.zkmulti__Recipient_Phone__c='1254345121';
        objzkupsMCShipmentc.zkmulti__Recipient_Street__c='pune';
        objzkupsMCShipmentc.zkmulti__Recipient_State_Province__c='maha';
        objzkupsMCShipmentc.zkmulti__Recipient_Country__c='india';
        objzkupsMCShipmentc.zkmulti__Recipient_City__c='pune';
        objzkupsMCShipmentc.zkmulti__Recipient_Zip_Postal_Code__c='424306';
        objzkupsMCShipmentc.zkmulti__Weight_Units__c='45';
        objzkupsMCShipmentc.zkmulti__Return_Shipment__c =true;
        objzkupsMCShipmentc.Case__c = caseObj.Id;
        objzkupsMCShipmentc.zkmulti__Status_Description__c = 'TestStatus';
        objzkupsMCShipmentc.zkmulti__Tracking_Number__c = 'TestMaster';
        objzkupsMCShipmentc.WorkOrder__c = workOrderObj.id;
        Test.startTest();
        
        insert objzkupsMCShipmentc;
        
        Test.StopTest();

        
    }

}