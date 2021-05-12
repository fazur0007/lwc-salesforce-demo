/**
*BrevilleRMAComponentControlletTest is test class for BrevilleRMAComponentController
* Version       Author             Date                  Description 
*  1.0        Yogesh Sharma      09/09/2016             Initial Draft
**/
@isTest
private class BrevilleRMAComponentControllerTest {

    static testMethod void testCaseRecordFound() {
       Account objAcc = new Account();
       objAcc.BillingCity= 'street';
       objAcc.ShippingCity = 'street';
       objAcc.BillingCountryCode = 'US';
       objAcc.ShippingCountryCode = 'US';
       objAcc.ShippingPostalCode = '1234';
       objAcc.BillingPostalCode = '1234';
       objAcc.BillingStateCode = 'CA';
       objAcc.ShippingStateCode = 'CA';
       objAcc.BillingStreet = 'city';
       objAcc.ShippingStreet = 'city';
       objAcc.Name='acc1';
       objAcc.Phone='1234567890';
       objAcc.Fax='0987654321';
       objAcc.VendAccount__c= 'dfgdfg2323';
       insert objAcc;

       Contact objCon = new Contact();
       objCon.FirstName = 'testFirst';
       objCon.LastName = 'testFirst';
       objCon.Email ='a@a.com';
       objCon.AccountId = objAcc.id;
       insert objCon;

       RecordType objRT =[select Id from RecordType where Name= 'RMA' limit 1];
       Case objCase = new Case();
       objCase.AccountId = objAcc.Id;
       objCase.ContactId = objCon.Id;
       objCase.RTV__c = 'testRTV';
       objCase.Requested_Product_Value__c=124;
       objCase.Return_Product_Required__c =true;
       objCase.Destroy_in_Field__c=true;
       objCase.Other_Action__c =true;
       objCase.Other_Action_Description__c='tesing description';
       //objCase.Return_Location__c= 'PRC';
       //objCase.Return_Address__c='19400 S WESTERN AVE, TORRANCE, CA 90501'; 
       objCase.Return_Ready_Date__c= date.today();
       objCase.Return_Carrier__c='return Carrier';
       objCase.Return_Tracking__c='RETUEN';
       objCase.Consignee_Contact_Name__c= 'consignee name';
       objCase.Consignee_Phone__c='234234';
       objCase.Return_Freight_BOL_No__c= '234234';
       objCase.Return_Pro_No__c='435345';
       objCase.Freight_Reference__c='454556';
       objCase.Carton_Count__c=34534.67;
       objCase.Stackable_Freight__c=false;
       objCase.Pallet_Gaylord_Count__c=456.56;
       objCase.Return_Load_Weight__c='4564';
       
       insert objCase;
       
       Product2 prod = new Product2(); 
       prod.Name = 'Test';
       prod.Family = 'Hardware';
       prod.Description = 'Hardware prod';
       insert prod;
       
       RMA_Product__c objRmaProduct =  new RMA_Product__c();
       objRmaProduct.Quantity__c = 1;
       objRmaProduct.Price__c = 100;
       objRmaProduct.Product__c = prod.id;
       objRmaProduct.Case__c = objCase.id;
       insert objRmaProduct;
       
       BrevilleRMAComponentController obj = new BrevilleRMAComponentController();
       obj.caseId = objCase.id;
       obj.getinit();
       
       //Check asserts
       system.assertEquals(obj.caseId,objCase.id);        
    }//End of testCaseRecordFound
}//End of BrevilleRMAComponentControllerTest