@isTest(SeeAllData=true)

public with sharing class QCLocationTriggerHandlerTest 
{
    static testMethod void sendNotificationToServiceCentre(){   
            
            Test.startTest();
            
            list<QCLocation__c> locationList = new list<QCLocation__c>();
            Account accountObj = TestDataFactory.createAccountRecord('Test Account', false);
            accountObj.BillingStreet = 'GEORGIA ST';
            accountObj.BillingCity = 'VANCOUVER';
            accountObj.BillingState = 'NY'; 
            accountObj.BillingCountry = 'USA';
            accountObj.CurrencyISOCode= 'USD';
            accountObj.BillingPostalCode = '123';
            insert accountObj;
            
            Contact conObj = TestDataFactory.createContact(accountObj.id,'TstContact1','1234567897', false);
            conObj.CurrencyIsoCode = 'USD';
            insert conObj;
            
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
            
            System.runAs(thisUser){
	        	User userRecord = new User();
		        Profile profile = [SELECT Id, Name FROM Profile where Name =: 'Service Repairer Community' LIMIT 1];
		        //UserRole userRole = [SELECT Id, Name FROM UserRole where Name =: 'Service Centre USA Customer User' LIMIT 1];
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
		        //userRecord.AccountId = objAcc.Id;
		        userRecord.ContactId = conObj.Id;
		        //userRecord.UserRoleId=userRole.id;
		        //userRecord.IsPortalEnabled = true;
		        //userRecord.AccountId = accountObj.Id;
		        userRecord.IsActive = true;
		        //userRecord.PortalRole = 'Manager';
		        insert userRecord;
		        
		    
		        
		        
	        
            
            
            
            Case caseObj = TestDataFactory.createCase(accountObj.id,'Email','Open','Test Case for QC location','USD',null, 'Support & Service','Circulation','1130', Date.today(),'', true);
            //Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
            Product2 productRecord = TestDataFactory.createProduct('Product #Product Name# one','BES920XL',true,false,false,15,true, true);
            //Asset assetRecord = TestDataFactory.createAsset('Test Asset',null,'1230',productRecord.Id,accountObj.Id,15,true);
                        
            QCAlert__c qcAlertRecord = TestDataFactory.createQCAlert('details of qc alert','test review','USD',productRecord.id,'Circulation','Partner;ASC',false);
            qcAlertRecord.QCAlertDetails__c = 'test description';
            insert qcAlertRecord;
            system.debug(qcAlertRecord.Channel__c);
           
            QCLocation__c qcLocationRecord = TestDataFactory.createQCLocation(accountObj.id,'USA',qcAlertRecord.id,productRecord.id,true,accountObj.id,'1230',false);
            qcLocationRecord.IsActive__c = true;
      		   
            locationList.add(qcLocationRecord);
            
            upsert locationList;
            
            QCLocation__c qcLocationRecord2 = TestDataFactory.createQCLocation(accountObj.id,'USA',qcAlertRecord.id,productRecord.id,true,accountObj.id,'1230',false);
            qcLocationRecord2.IsActive__c = true;
            
          
            
            locationList.add(qcLocationRecord2);
            
           
            
            upsert locationList;
            
            
           //	OrgWideEmailAddress orgwideIdByEmailAddresstest = new OrgWideEmailAddress();
           	//orgwideIdByEmailAddresstest.Address ='askus.psldevint@gmail.com';
          	//insert orgwideIdByEmailAddresstest;
          	map<String,List<User>> userListByCurrencyCodetest = new map<String,List<User>>();
          	userListByCurrencyCodetest.put('USD',new list<User>{userRecord});
            Case caseRecord = TestDataFactory.createCase(accountObj.id,'Chat','Open','Test Case','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), '' ,true);
  			
  			
  			
  			/*QCLocationTriggerHandler.sendNotificationToServiceCentre(locationList, null);
  			QCLocationTriggerHandler.sendTemplateEmail(userListByCurrencyCodetest,locationList,'QC_Alert','adsfajfkkjk@example.com');
            QCLocationTriggerHandler.addressAsString(qcLocationRecord);
            QCLocationTriggerHandler.shareWithreturnLocationForQcLocation(locationList, null, true);
            QCLocationTriggerHandler.createQcLocationShare(qcLocationRecord.id ,UserInfo.getUserId() );
      		 */
     
            Test.stoptest();
	}
    }
}