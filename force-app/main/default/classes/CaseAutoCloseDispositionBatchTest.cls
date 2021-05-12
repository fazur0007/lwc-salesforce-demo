@isTest
public class CaseAutoCloseDispositionBatchTest{
	static Case caseRecord;
	static Case caseRecord2;			 
	
	static void testData(){
		Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
        productRecord.CurrencyIsoCode = 'USD';
    	insert productRecord;
    	caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Waiting on consumer','Test Case1','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        //caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = true;
        caseRecord.Country__c = 'USA';
        caseRecord.ReplyBackNotificationSent1__c = false;
        caseRecord.CaseAutoCloseCheckDate__c = Date.today();
        insert caseRecord;
        
        caseRecord2 = TestDataFactory.createCase(accountRecord.id,'Chat','Soft Closed','Test Case2','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord2.Warranty__c ='In Warranty';
        //caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord2.RA_Delivered__c = true;
        caseRecord2.Country__c = 'USA';
        caseRecord2.ReplyBackNotificationSent1__c = true;
        caseRecord2.CaseAutoCloseCheckDate__c = Date.today();
        insert caseRecord2;
        
	}
	
	static testMethod void saveResponseTest(){
		Test.startTest();
		
		testData();
		Id batchId = Database.executeBatch(new CaseAutoCloseDispositionBatch(), 2);
		Case caseRecord1 = [SELECT ID, Status FROM Case WHERE Subject = 'Test Case1' limit 1];
		Case caseRecord2 = [SELECT ID, Status FROM Case WHERE Subject = 'Test Case2' limit 1];
		System.assertEquals(caseRecord2.Status, 'Soft Closed');
		Test.stopTest();
	}
}