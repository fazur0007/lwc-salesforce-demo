@isTest
public class RMAProductTriggerHandlerTest {
	@testsetup
    static void setup(){
        Account accountRecord = new Account();
        accountRecord.firstName = 'abc';
        accountRecord.lastName = 'def';
        accountRecord.Phone = '9898989898';
        accountRecord.PersonEmail = 'abc@example.com';
        insert accountRecord;
        
		Product2 productRecord1 = TestDataFactory.createProduct('Product 998', true, false);
        insert productRecord1;
        
        Product2 productRecord2 = TestDataFactory.createProduct('Product 999', true, false);
        productRecord2.AX_Unique_ID__c = '123asd';
        insert productRecord2;
        
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
            
        Case caseRecord1 = TestDataFactory.createCase(accountRecord.Id, 'Email', 'Open', 'subject 998', 'USD', productRecord1.Id, 'Feedback', 'Dented', '1051', false );
        caseRecord1.RecordTypeId = caseRecordType;
        caseRecord1.Country__c = 'USA';
        caseRecord1.Return_Location__c = 'USA WHSE TORR';
        caseRecord1.Return_Address__c = '19400 S WESTERN AVE, TORRANCE, CA 90501';
        caseRecord1.Purchased_From__c = 'Breville';
        caseRecord1.RTV__c = 'rtv';
        insert caseRecord1;	
        
        Test.startTest();
        
        RMA_Product__c rmaProductRecord = new RMA_Product__c();
        rmaProductRecord.Product__c = productRecord1.Id;
        rmaProductRecord.Quantity__c = 1;
        rmaProductRecord.Case__c = caseRecord1.Id;
        insert rmaProductRecord; 
        
        Test.stopTest();
    }
    
    static testMethod void testMethodForUpdate(){
        RMA_Product__c rmaProductRecord = [Select Id from RMA_Product__c limit 1];
        Product2 productRecord2 = [Select Id from Product2 where Name = 'Product 999' limit 1];
            
    	Test.startTest();
        
        rmaProductRecord.Product__c = productRecord2.Id;
        update rmaProductRecord; 
        
        RMA_Product__c updatedRMAProductRecord = [Select Id, RMA_Product_Unique_Id__c, Case__c from RMA_Product__c limit 1];
		String caseNum = [Select Id, CaseNumber from Case where id =: updatedRMAProductRecord.Case__c].CaseNumber; 
        
        String rmaProductUniqueId = updatedRMAProductRecord.RMA_Product_Unique_Id__c;
        System.assertEquals(caseNum + '123asd', rmaProductUniqueId);
        
        Test.stopTest();
    }
}