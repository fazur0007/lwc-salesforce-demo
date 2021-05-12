/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ReceivingTriggerHandlerTest {
    
    @testsetup
    static void setup(){
        //Create Account-1
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA1', 'BUS','servicecentre_usa1@example.com','7896541231');
	    ServiceCentreAccount.BillingPostalCode = '440022';
	    ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Supported_Brands__c = 'Breville;Ronson';
        ServiceCentreAccount.VendAccount__c = 'CUS12345';
	    insert ServiceCentreAccount;
        
        //Create contact
        Contact contactRecord1 = new Contact(FirstName = 'Test', Lastname = 'Last 001', AccountId = ServiceCentreAccount.Id, Email = 'test@test.com');
        insert contactRecord1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Retailer Community']; 
        
        //Create Portal user
        User u = new User(Alias = 'sysadm', Email='sysadminuser@example.com', 
            				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            				LocaleSidKey='en_US', ProfileId = p.Id, 
            				TimeZoneSidKey='America/Los_Angeles', UserName='sysadminuser@example.com',
                          	ContactId = contactRecord1.Id);
        insert u;
        
        //Create Account-2	
	        Account location1 = TestDataFactory.createAccountRecord('Service_Centre USA2', 'BUS','servicecentre_usa2@example.com','7896541232');
	        location1.BillingPostalCode = '440022';
	        location1.ShippingPostalCode = '440022';
	        location1.ReevingReturnLocation__c = 'USA PRC';
	        insert location1;
	    
        //Create Account-2
	        Account location2 = TestDataFactory.createAccountRecord('Service_Centre USA3', 'BUS','servicecentre_usa3@example.com','7896541233');
	        location2.BillingPostalCode = '440022';
	        location2.ShippingPostalCode = '440022';
	        location2.ReevingReturnLocation__c = 'USA PRC';
	        insert location2;
	        
        	/*Account accountRecord2 = new Account();
            accountRecord2.firstName = 'abc';
            accountRecord2.lastName = 'def';
            accountRecord2.Phone = '9898989898';
            accountRecord2.PersonEmail = 'abc@example.com';*/
        
        	//Create Product
        	Product2 productRecord = TestDataFactory.createProduct('Product 998', true, false);
        	productRecord.Finished_Good__c = true;
            productRecord.AutoScrap_on_Receipt__c = true;
            productRecord.Brand__c = 'BREVILLE';
            insert productRecord;
        
            Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
            
        	//Create Case-1
            Case caseRecord1 = TestDataFactory.createCase(ServiceCentreAccount.Id, 'Email', 'Open', 'subject 998', 'USD', productRecord.Id, 'Feedback', 'Dented', '1051', false );
            caseRecord1.RecordTypeId = caseRecordType;
            caseRecord1.Country__c = 'USA';
            caseRecord1.Return_Location__c = 'USA PRC';
            caseRecord1.Return_Address__c = '10095 INTERNATIONAL BLVD, WEST CHESTER, OH 45246';
            caseRecord1.Purchased_From__c = 'Breville';
            caseRecord1.RTV__c = 'AW TEST 100';
            insert caseRecord1;        
        
        	//Create Case-2
        	Case caseRecord2 = TestDataFactory.createCase(ServiceCentreAccount.Id, 'Email', 'Open', 'subject 999', 'USD', productRecord.Id, 'Feedback', 'Dented', '1051', false );
            caseRecord2.RecordTypeId = caseRecordType;
            caseRecord2.Country__c = 'USA';
            caseRecord2.Return_Location__c = 'USA PRC';
            caseRecord2.Return_Address__c = '10095 INTERNATIONAL BLVD, WEST CHESTER, OH 45246';
            caseRecord2.Purchased_From__c = 'Breville';
        	caseRecord2.RTV__c = '1234';
            insert caseRecord2;
        
        	
        	//Create QC Alert
        	QCAlert__c QCAlertRecord = TestDataFactory.createQCAlert('Test','Test','USD', productRecord.Id,'Alignment / Fit','Return Center', True);
                
                
        	//Create QCLocation__c
        	QCLocation__c QCLocationRecord = TestDataFactory.createQCLocation(ServiceCentreAccount.Id, 'USA', QCAlertRecord.Id, productRecord.Id, True, 'CORE CENTRIC', '1903', True);
            
        
        System.runAs(u){
            Test.startTest();
            
            Receiving__c receivingRecord = TestDataFactory.createReceivingRecord(caseRecord1.Id);
            receivingRecord.RMACalculatedUnitPrice__c = 100.0;
            receivingRecord.Return_Location__c = 'USA PRC';
            receivingRecord.AX_Warehouse__c = '236';
            receivingRecord.Received_Product__c = productRecord.Id;
            receivingRecord.Received_PDC__c = '1805';
            receivingRecord.GenerateNewFormatRMA__c = true;
            receivingRecord.Breville_Serial__c = '10ABCDEF190300001';
            //receivingRecord.Account__c = ServiceCentreAccount.Id;
            receivingRecord.Cust_Acct_ID__c = 'CUS12345';
            receivingRecord.RTV__c = 'AW TEST 100';
            insert receivingRecord;

            Test.stoptest();
        }
    }
    
    static testMethod void testMethodnew(){
        User u = [Select Id from User where UserName='sysadminuser@example.com'];
        Case caseRecord2 = [Select Id,CaseNumber from Case where Subject = 'subject 999'];
        Product2 productRecord = [Select Id from Product2 where Name = 'Product 998'];
        Account ServiceCentreAccount = [Select Id from Account where Name = 'Service_Centre USA1'];
        
        System.runAs(u){
            Test.startTest();

            Receiving__c receivingRecord1 = TestDataFactory.createReceivingRecord(caseRecord2.Id);
            receivingRecord1.RMACalculatedUnitPrice__c = 100.0;
            receivingRecord1.Return_Location__c = 'USA PRC';
            receivingRecord1.AX_Warehouse__c = '236';
            receivingRecord1.Received_Product__c = productRecord.Id;
            receivingRecord1.Received_PDC__c = '1805';
            receivingRecord1.GenerateNewFormatRMA__c = true;
            //receivingRecord1.Account__c = ServiceCentreAccount.Id;
            receivingRecord1.Cust_Acct_ID__c = 'CUS12345';
            receivingRecord1.RACaseNumber__c = caseRecord2.CaseNumber;
            insert receivingRecord1;
            
            Test.stoptest();
        }
    }    
    
    /*static testMethod void testmethod2(){
        User u = [Select id, name, IsPortalEnabled from User where id =: UserInfo.getUserId()];
        System.debug('===u==='+u);
        
        Case caseRecord1 = [Select id from Case limit 1];
        Product2 productRecord = [Select id from Product2 limit 1];
            
        System.runAs(u){
        	Test.startTest();
            
        	Receiving__c receivingRecord = TestDataFactory.createReceivingRecord(caseRecord1.Id);
            receivingRecord.RMACalculatedUnitPrice__c = 100.0;
            receivingRecord.Return_Location__c = 'USA PRC';
            receivingRecord.Received_Product__c = productRecord.Id;
            receivingRecord.Received_PDC__c = '1805';
            receivingRecord.GenerateNewFormatRMA__c = true;
            receivingRecord.Breville_Serial__c = '10ABCDEF190300001';
        	receivingRecord.Case__c = caseRecord1.Id;
            insert receivingRecord;
        	System.debug('===receivingRecord==='+receivingRecord);
            
            Test.stoptest();
        }
    }
    */
    /*static testMethod void shareWithServiceCentreTest() {
        Test.startTest();
                    
        /*Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        insert ServiceCentreAccount;
        Contact contact = new Contact(LastName ='testCon',AccountId = ServiceCentreAccount.Id);
        insert contact;  
		Profile profile = [SELECT Id, Name FROM Profile where Name =: 'Service Repairer Community' LIMIT 1];
		User userRecord = new User();
		userRecord.ContactId = contact.Id;
		userRecord.UserName = 'TestUser' + String.valueOf(Datetime.now().getTime()) + '_' + UserInfo.getOrganizationId() + '@breville.com.test';
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
		insert userRecord;*/

        
        /*System.runAs(new User(Id = UserInfo.getUserId())){
            //Account accountRecord2 = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BUS','nikhil998@example.com','9527785432');
        	//insert accountRecord2;
        	Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA1', 'BUS','servicecentre_usa1@example.com','7896541231');
	        ServiceCentreAccount.BillingPostalCode = '440022';
	        ServiceCentreAccount.ShippingPostalCode = '440022';
	        insert ServiceCentreAccount;
	        
	        Account location1 = TestDataFactory.createAccountRecord('Service_Centre USA2', 'BUS','servicecentre_usa2@example.com','7896541232');
	        location1.BillingPostalCode = '440022';
	        location1.ShippingPostalCode = '440022';
	        location1.ReevingReturnLocation__c = 'USA PRC';
	        insert location1;
	        
	        Account location2 = TestDataFactory.createAccountRecord('Service_Centre USA3', 'BUS','servicecentre_usa3@example.com','7896541233');
	        location2.BillingPostalCode = '440022';
	        location2.ShippingPostalCode = '440022';
	        location2.ReevingReturnLocation__c = 'USA PRC';
	        insert location2;
	        
        	Account accountRecord2 = new Account();
            accountRecord2.firstName = 'abc';
            accountRecord2.lastName = 'def';
            accountRecord2.Phone = '9898989898';
            accountRecord2.PersonEmail = 'abc@example.com';
            
            Product2 productRecord = TestDataFactory.createProduct('Product 998', true, false);
            productRecord.AutoScrap_on_Receipt__c = true;
            insert productRecord;
            Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
            
            Case caseRecord1 = TestDataFactory.createCase(ServiceCentreAccount.Id, 'Email', 'Open', 'subject 998', 'USD', productRecord.Id, 'Feedback', 'Dented', '1051', false );
            caseRecord1.RecordTypeId = caseRecordType;
            caseRecord1.Country__c = 'USA';
            caseRecord1.Return_Location__c = 'USA PRC';
            caseRecord1.Return_Address__c = '500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
            caseRecord1.Purchased_From__c = 'Breville';
            caseRecord1.RTV__c = 'rtv';
            insert caseRecord1;
            
            Case caseRecord2 = TestDataFactory.createCase(ServiceCentreAccount.Id, 'Email', 'Open', 'subject 998', 'USD', productRecord.Id, 'Feedback', 'Dented', '1051', false );
            caseRecord2.RecordTypeId = caseRecordType;
            caseRecord2.Country__c = 'USA';
            caseRecord2.Return_Location__c = 'USA PRC';
            caseRecord2.Return_Address__c = '500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
            caseRecord2.Purchased_From__c = 'Breville';
            insert caseRecord2;
            
            Case caseRecord3 = TestDataFactory.createCase(ServiceCentreAccount.Id, 'Email', 'Open', 'subject 998', 'USD', productRecord.Id, 'Feedback', 'Dented', '1051', false );
            caseRecord3.RecordTypeId = caseRecordType;
            caseRecord3.Country__c = 'USA';
            caseRecord3.Return_Location__c = 'USA PRC';
            caseRecord3.Return_Address__c = '500 MIDDLE COUNTRY ROAD, ST JAMES, NY 1178';
            caseRecord3.Purchased_From__c = 'Breville';
            insert caseRecord3;
            
            Receiving__c receivingRecord = TestDataFactory.createReceivingRecord(caseRecord1.Id);
            receivingRecord.RMACalculatedUnitPrice__c = 100.0;
            receivingRecord.Return_Location__c = 'USA PRC';
            receivingRecord.Received_Product__c = productRecord.Id;
            receivingRecord.Received_PDC__c = '1805';
            receivingRecord.GenerateNewFormatRMA__c = true;
            receivingRecord.Breville_Serial__c = '10ABCDEF190300001';
            insert receivingRecord;
                        
            Receiving__c receivingRecord2 = TestDataFactory.createReceivingRecord(caseRecord2.Id);
            receivingRecord2.Return_Location__c = 'USA PRC';
            receivingRecord2.Received_Product__c = productRecord.Id;
            receivingRecord2.Received_PDC__c = '1805';
            receivingRecord2.GenerateNewFormatRMA__c = true;
            insert receivingRecord2;
            
            receivingRecord2.Zip__c='440022';
            receivingRecord2.Case__c = caseRecord3.Id;
            
            update receivingRecord2;
        }
		//Receiving__Share receivingShare =  ReceivingTriggerHandler.createRecevingShare(receivingRecord.id, userRecord.id);
		
		Test.stoptest();
		
    }*/
    
    static testMethod void testMethod1(){        
        Receiving__c receivingRecord = [Select id, Zip__c, Case__c from Receiving__c limit 1];
        Case caseRecord2 = [Select Id,CaseNumber from Case where Subject = 'subject 999'];
        
        Test.startTest();
        
       	receivingRecord.Zip__c='440022';
        receivingRecord.Case__c = caseRecord2.Id;  
        receivingRecord.RTV__c = '';
        receivingRecord.RMACalculatedTotalPrice__c = 0;
        receivingRecord.RMACalculatedUnitPrice__c = null;
        update receivingRecord;
        
        Test.stopTest();
    }
    
    static testMethod void createRecevingShareTest(){        
        Receiving__c receivingRecord = [Select id, Zip__c, Case__c from Receiving__c where Breville_Serial__c != null limit 1];
        
        Test.startTest();
        
       	Receiving__Share receivingShare =  ReceivingTriggerHandler.createRecevingShare(receivingRecord.id, UserInfo.getUserId());
        
        Test.stopTest();
    }
    
    static testMethod void serialNumberValidationTest(){
        Receiving__c receivingRecord = [Select id, Zip__c, Case__c, Breville_Serial__c from Receiving__c limit 1];
        
        Test.startTest();
        
        try{
        	receivingRecord.Breville_Serial__c = '10ABCDEF19030000M';
	    	update receivingRecord;
        }catch(Exception e){
            System.debug('Error while updating Serial Number: ' + e );
        }
        
        Test.stopTest();
        
        String serialNum = [SELECT Id, Breville_Serial__c FROM Receiving__c where Breville_Serial__c != null].Breville_Serial__c;
        //System.assertEquals('10ABCDEF190300001', serialNum);         
	}
    static testMethod void createRMACaseOnReceivingTest(){
        Receiving__c receivingRecord=new Receiving__c();
        receivingRecord.Country__c='DE';
        receivingRecord.CurrencyIsoCode='EUR';
        receivingRecord.isBlanketRMA__c=True;
        Account testAccount=new Account();
        testAccount.Name='Test Account';
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        testAccount.IsPrimary__c=true;
        testAccount.VendAccount__c='CUS1234567';
		insert testAccount;
        receivingRecord.cus_sf_id__c=testAccount.Id;
        receivingRecord.Return_Location__c='Windhorn Return Center(DHL) - DE';
        receivingRecord.Cust_Acct_ID__c='CUS60019';
        receivingRecord.RTV__c='BL1190824';
        receivingRecord.Magic_RA__c='AO12345678';
        String PRCId='WHN12345678';
        receivingRecord.PRC_Item_ID__c=PRCId;
        receivingRecord.PRC_Serial__c='123456';
        receivingRecord.AX_Warehouse__c='901';  
        receivingRecord.QTY__c=1;
        Product2 testProduct=TestDataFactory.createProduct('Product',true,false);
        testProduct.Finished_Good__c=true;
        testProduct.CurrencyISOCode='EUR';
        insert testProduct;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=testProduct.Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'EUR');
        insert pbe;
        
        receivingRecord.Received_Product__c=testProduct.Id;
        receivingRecord.Received_PDC__c='1826';
        Test.startTest();
        insert receivingRecord;
        Test.stopTest();
    }
	
}