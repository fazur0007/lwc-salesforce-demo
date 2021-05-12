@isTest
public class ShareReceivingsBatchTest{
	static User userRecord = new User();
	static void testData(){
		
		Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        insert ServiceCentreAccount;
        Contact contact = new Contact(LastName ='testCon',AccountId = ServiceCentreAccount.Id);
        insert contact;
		Profile profile = [SELECT Id, Name FROM Profile where Name =: 'Service Repairer Community' LIMIT 1];
		userRecord = new User();
		userRecord.UserName = 'TestUser' + String.valueOf(Datetime.now().getTime()) + '_' + UserInfo.getOrganizationId() + '@breville.com.test';
        userRecord.ContactId = contact.Id;
        userRecord.profileId = profile.Id;
		userRecord.Alias = 'a';
        userRecord.CommunityNickname = 'b';
        userRecord.Email = 'c@example.com';
        userRecord.CurrencyIsoCode = 'USD';
        userRecord.LastName = 'test';
        userRecord.TimeZoneSidKey = 'GMT';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.EmailEncodingKey = 'ISO-8859-1';
        userRecord.LanguageLocaleKey = 'en_US';
		insert userRecord;
		
		Account location2 = TestDataFactory.createAccountRecord('Service_Centre USA3', 'BAU','servicecentre_usa3@example.com','7896541233');
        location2.BillingPostalCode = '440022';
        location2.ShippingPostalCode = '440022';
        location2.ReevingReturnLocation__c = 'AUS GLOBAL';
        insert location2;
        
        Product2 productRecord = TestDataFactory.createProduct('Product 998', true, false);
        productRecord.AutoScrap_on_Receipt__c = true;
        productRecord.CurrencyIsoCode = 'AUD';
        insert productRecord;
        
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
            
        Case caseRecord1 = TestDataFactory.createCase(ServiceCentreAccount.Id, 'Email', 'Open', 'subject 998', 'AUD', productRecord.Id, 'Feedback', 'Dented', '1051', false );
        caseRecord1.RecordTypeId = caseRecordType;
        caseRecord1.Country__c = 'AUS';
        caseRecord1.Return_Location__c = 'AUS GLOBAL';
        caseRecord1.Return_Address__c = 'Minto, Global Traders';
        caseRecord1.Purchased_From__c = 'Breville';
        caseRecord1.RTV__c = 'rtv';
        insert caseRecord1;
		
		Receiving__c receivingRecord = TestDataFactory.createReceivingRecord(caseRecord1.Id);
        receivingRecord.RMACalculatedUnitPrice__c = 100.0;
        receivingRecord.Return_Location__c = 'AUS GLOBAL';
        receivingRecord.Received_Product__c = productRecord.Id;
        receivingRecord.GenerateNewFormatRMA__c = true;
        receivingRecord.CurrencyIsoCode = 'AUD';
        receivingRecord.Received_PDC__c = '1903';
        receivingRecord.AX_Warehouse__c = '621';
        insert receivingRecord;
        
	}
	
	static testMethod void saveResponseTest(){
		Test.startTest();
			testData();
			Id batchId = Database.executeBatch(new ShareReceivingsBatch(userRecord.Id, 'AUS GLOBAL', 'AUD'), 1);
		Test.stopTest();
	}
	
}