@isTest
public class UserTriggerHandlerTest {
    static testMethod void test1() {
        List < User > userList = new List < User > ();
        Map < Id, User > triggerOldMap = new Map < Id, User > ();

        TestObjects to = new TestObjects();
        User u1 = to.getUser(true);
        u1.Alias = 'User1';
        update u1;

        userList.add(u1);
        triggerOldMap.put(u1.Id, u1);

        // UserTriggerHandler.populateCustomCurrencyISOCode(userList, triggerOldMap);
    }

    static testMethod void test2() {
        TestObjects to = new TestObjects();
        User acct = to.getUser(false);
        acct.Alias = 'User1';
        insert acct;
    }

    /*static testmethod void test3(){
        TestObjects to = new TestObjects();
        User acct = to.getUser(false);
        acct.Alias = 'User1';
        acct.IsPortalEnabled = true;
        acct.DefaultCurrencyIsoCode = 'USD';
        insert acct;
    }*/

    static testmethod void testPopulateCustomCurrencyISoCode() {
        User userRec = new TestObjects().getUser(false);
        userRec.DefaultCurrencyIsoCode = 'USD';
        insert userRec;

        User userRecord = [select ID, CurrencyISOCode__c, DefaultCurrencyIsoCode from user where id =: userRec.id];
        System.assert(userRecord.CurrencyISOCode__c == userRecord.DefaultCurrencyIsoCode);
    }

    static testmethod void testAssignToRegionSpecificPublicGroup() {
        User userRec = new TestObjects().getUser(false);
        userRec.DefaultCurrencyIsoCode = 'USD';
        userRec.Send_Mail_Verification_Email__c = true;
        userRec.Email_verification_network_Id__c = Network.getNetworkId();
        insert userRec;
        UserTriggerHandler.beforeTriggerRun = true;
        UserTriggerHandler.afterTriggerRun = true;
        User userRecord = [select ID, CurrencyISOCode__c, DefaultCurrencyIsoCode from user where id =: userRec.id];
        userRecord.DefaultCurrencyIsoCode = 'CAD';
        update userRecord;
    }
    @isTest public static void testAssyncUser() {
        string email = 'abc11234@xyz.com';
        Account userPersonalAccount = new Account();
        userPersonalAccount.Email_External_ID__c = email;
        userPersonalAccount.LastName = 'TestName';
        userPersonalAccount.RecordTypeId = [select id from recordtype where sobjecttype='Account' and Name='Person Account'].Id;
        userPersonalAccount.PersonEmail = email;   
        userPersonalAccount.CurrencyIsoCode = 'USD';       
        insert userPersonalAccount;
    }
    @isTest public static void createUserserPartner(){
        Id adminProfile = [select id from profile where name='System Administrator'].id;
        
        UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert role;
        
        User user = new User(alias = 'test1234', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = adminProfile, country='USA',IsActive =true,
                             UserRoleId = role.id,
                             timezonesidkey='America/Los_Angeles', username='tester21@noemail.com');
        insert user;
        system.runAs(user){
            Account ac = new Account(name ='Grazitti',CurrencyIsoCode = 'USD',DataAreaID__c	= 'BUS') ;
            insert ac;
            
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
            insert con;
            
        }   
    }
    /*   @isTest
public static void testParnerUser(){
Account ac1;
Contact con;
ac1 = new Account(name = 'Grazitti', BillingCountry = 'USA', ShippingCountry = 'USA');
insert ac1;
con = new Contact(LastName = 'testCon', AccountId = ac1.Id);
insert con;
System.debug('ac1----'+ac1);

User user = userPartnerTest(con.id,'AUD','DE;');
System.runAs(user){
//   UserTriggerHandler.GetPartnerProfileId();
insert user;
}
}  */
    @isTest public static void userPartnerTest(){
        
        //Create portal account owner
        Id sysAdminId = [select id from profile where name='System Administrator'].id   ;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = sysAdminId,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        
        insert portalAccountOwner1;
        System.debug('===portalAccountOwner1===' + portalAccountOwner1);
        
        
        
        system.runAs(portalAccountOwner1){
            Test.startTest();
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner1.Id
            );
            insert portalAccount1;
            
            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            insert contact1;
            
            //Create user
            Id pCommunityProfileId = [select id from profile where name='Breville Partner User'].id;
            System.debug('===pCommunityProfileId===' + pCommunityProfileId);
            User user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = pCommunityProfileId,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            
            UserTriggerHandler.afterTriggerRun = true;
            insert user1;
            Test.stopTest();
        }
        
    }  
    @isTest public static void testShareChildAccountWithParentUser() {
        try {
            User u;
            Account ac;
            Contact con;
           
            ac = new Account(name = 'Grazitti', BillingCountry = 'USA', ShippingCountry = 'USA');
            insert ac;
            /*
            Account acct = [Select Id,Account_SafeID__c From Account Where Id = :ac.Id];
            acct.ParentId = acct.Account_SafeID__c;
            update acct;
            */
            con = new Contact(LastName = 'testCon', AccountId = ac.Id);
            insert con;
            Profile p = [select id from profile where name = 'Service Repairer Community'];
            //UserRole r = [Select Id,Name,PortalType  From UserRole where PortalType  = 'CustomerPortal' limit 1];
            u = new User(alias = 'standt', email = 'standarduser@testorg.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = p.Id,
                //userroleid = r.Id,
                timezonesidkey = 'America/Los_Angeles',
                username = 'standarduser@testorg.com',
                ContactId = con.Id,
                CurrencyIsoCode = 'USD'
            );
            insert u;
            u.CurrencyIsoCode = 'CAD';
            update u;
            /*System.runAs(u) {
                UserTriggerHandler.shareChildAccountWithParentUser(new List < User > {
                    u
                });
            }*/
        }
        catch (exception e) {
            system.debug('error occured ***'+e.getMessage());
        }
    }

     @isTest
    static void testNameUpdateOnUsertoAcct() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            String email = 'test_user1@yopmail.com';
            
            Id personAccountRecordTypeId = [select id from RecordType where name='Person Account'].Id;
            Id myBrvProfileId = [select id from profile where name='Breville Customer Community'].Id;
            
            Account objAcct = new Account(FirstName='TestFN', LastName='TestLN', PersonEMail=email, RecordTypeId=personAccountRecordTypeId);
            insert objAcct;
            
            Contact recContact = [Select Id, Email from Contact WHERE Email=:email LIMIT 1];
            
            User recUser = new User(alias = 'test123', email=email, emailencodingkey='UTF-8', 
                                    lastname=objAcct.LastName, 
                                    languagelocalekey='en_US',
                                    localesidkey='en_US', 
                                    profileid = myBrvProfileId, 
                                    IsActive =true,
                                    contactId = recContact.Id,
                                    timezonesidkey='America/Los_Angeles', 
                                    username=email,
                                    Exp_ID__c ='beanzENUS');
            insert recUser;
            User updUser = new User();
            updUser.Id = recUser.Id;
            updUser.FirstName = 'TestFN TestFN';
            updUser.LastName = 'TestLN TestLN';
            update updUser;
        }
        
        System.debug ('Update Successful: ');
    }
    /*
    static testmethod void testAssignToRegionSpecificPublicGroupPortal()
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) {

            Account acc = TestDataFactory.createAccountRecord('Test User', true);
            Contact con = TestDataFactory.createContact(acc.Id, 'Test Last Name', true);
            User userRec = TestDataFactory.createUser('Service Repairer Community', 'Breville Australia Service Center Customer User', 'USD', false);
            userRec.DefaultCurrencyIsoCode = 'USD';
            userRec.ContactId = con.Id;
            insert userRec;
            UserTriggerHandler.beforeTriggerRun = true;
            UserTriggerHandler.afterTriggerRun = true;
            User userRecord = [select ID, CurrencyISOCode__c , DefaultCurrencyIsoCode from user where id =:userRec.id];
            userRecord.DefaultCurrencyIsoCode = 'CAD';
            update userRecord;
        }
        
    }*/
    /*     @isTest public static void testPartnerUser() {	
string email = 'abc11234@xyz.com';	
Account userPersonalAccount = new Account();	
userPersonalAccount.Email_External_ID__c = email;	
userPersonalAccount.LastName = 'TestName';	
userPersonalAccount.RecordTypeId = [select id from recordtype where sobjecttype='Account' and Name='Person Account'].Id;	
userPersonalAccount.PersonEmail = email;   	
userPersonalAccount.CurrencyIsoCode = 'USD';       	
insert userPersonalAccount;	
List<Network> lstNetwork = [select id, name from Network where Name = 'Breville | Sage Partners' Limit 1];	
User newuser = new User();      	
newuser.username = email;	
newuser.languagelocalekey = 'en_US';	
newuser.localesidkey= 'en_US';	
newuser.email = email;	
newuser.lastName = 'Test Name';	
String alias = 'br' + Integer.valueof((Math.random()*1000000));	
//Alias must be 8 characters or less	
if (alias.length() > 8) {	
alias = alias.substring(0, 8);	
}	
newuser.alias = alias;        	
newuser.emailEncodingKey = 'UTF-8';	
newuser.timeZoneSidKey = 'America/Los_Angeles';	
newuser.Account_ID__c = userPersonalAccount.Id;	
newuser.ContactId = [select id,PersonContactId from account where id=:userPersonalAccount.Id].PersonContactId;	
system.debug('userPersonalAccount.PersonContactId:'+userPersonalAccount.PersonContactId);	
newuser.profileId = [select id,name from profile where name='Breville Partner User'].Id;	
system.debug('NetworkId:'+lstNetwork[0].Id);	
newuser.Email_verification_network_Id__c=lstNetwork[0].Id;	
newuser.Send_Mail_Verification_Email__c = true;           	
newuser.CommunityNickname = email;	
insert newuser;	
system.debug('Portal user:'+newuser.Id);	
}    */
}