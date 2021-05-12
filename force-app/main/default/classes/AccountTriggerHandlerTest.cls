@isTest
public class AccountTriggerHandlerTest {
    
    static testMethod void test1(){
        TestObjects to = new TestObjects();
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.BillingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        objAcc.Billing_Street_Line_1__c = '3190 Shinn Street';
        objAcc.Billing_Street_Line_2__c = '3190 Shinn Street';
        insert objAcc;
        
        Account acct = to.getAccount(false);
        acct.BillingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        acct.Billing_Street_Line_1__c = '3190 Shinn Street';
        acct.Billing_Street_Line_2__c = '3190 Shinn Street';
        acct.ParentId = objAcc.id;
        insert acct;
        Account account = [SELECT Id, ParentId, Billing_Street_Line_1__c, Billing_Street_Line_2__c, BillingStreet
                           FROM Account
                           WHERE Id = :acct.id];
        
        String[] bStreet = account.BillingStreet.split('\n');
        system.Assert(bStreet[0].trim() == account.Billing_Street_Line_1__c);
        system.Assert(bStreet[1].trim() == account.Billing_Street_Line_2__c);
    }
    
    static testMethod void test2(){
        TestObjects to = new TestObjects();
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.ShippingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        objAcc.Shipping_Street_Line_1__c = '3190 Shinn Street';
        objAcc.Shipping_Street_Line_2__c = '3190 Shinn Street';
        insert objAcc;
        
        Account acct = to.getAccount(false);
        acct.BillingStreet = '1234 S Main St \r\n Suite 123';
        acct.ParentId = objAcc.id;
        acct.ShippingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        acct.Shipping_Street_Line_1__c = '3190 Shinn Street';
        acct.Shipping_Street_Line_2__c = '3190 Shinn Street';
        insert acct;
        Account account = [SELECT Id, ParentId, Shipping_Street_Line_1__c, Shipping_Street_Line_2__c, ShippingStreet
                           FROM Account
                           WHERE Id = :acct.id];
        
        String[] sStreet = account.ShippingStreet.split('\n');
        system.Assert(sStreet[0].trim() == account.Shipping_Street_Line_1__c);
        system.Assert(sStreet[1].trim() == account.Shipping_Street_Line_2__c);
    }
    
    static testMethod void testWithoutBillingStreet(){
        TestObjects to = new TestObjects();
        Account acct = to.getAccount(false);
        acct.BillingStreet = null;
        insert acct;
        Account account = [SELECT Id, ParentId, Billing_Street_Line_1__c, Billing_Street_Line_2__c, BillingStreet
                           FROM Account
                           WHERE Id = :acct.id];
        
        system.Assert(account.BillingStreet == null);
    }
    
    static testMethod void testWithShippingStreet(){
        TestObjects to = new TestObjects();
        Account acct = to.getAccount(false);
        acct.ShippingStreet = '234 West Main Street Site 2346789';
        insert acct;
        Account account = [SELECT Id, ParentId, Shipping_Street_Line_1__c, Shipping_Street_Line_2__c, ShippingStreet
                           FROM Account
                           WHERE Id = :acct.id];
        
        system.Assert('234 West Main Street Site 2346789' == account.ShippingStreet);
    }
    
    static testMethod void test5(){
        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
        acct.BillingStreet = null;
        acct.Billing_Street_Line_1__c = null;
        acct.Billing_Street_Line_2__c = null;
        update acct;
        Account account = [SELECT Id, ParentId, Billing_Street_Line_1__c, Billing_Street_Line_2__c, BillingStreet
                           FROM Account
                           WHERE Id = :acct.id];
        
        system.Assert(account.BillingStreet == null);
    }
    
    static testMethod void test6(){
        List<Account> accts = new List<Account>();
        
        TestObjects to = new TestObjects();
        Account pa1 = to.getAccount(false);
        pa1.Name = 'pa1';
        pa1.Billing_Street_Line_1__c = '134 KENT ST. (CONF.COURT MALL)'; //1234 E Main st
        pa1.Billing_Street_Line_2__c = 'Street B';
        //pa1.BillingCountry = 'Canada';
        //pa1.BillingCity = 'CHARLOTTETOWN';
        //pa1.BillingState = 'Prince Edward Island';
        //pa1.BillingPostalCode = '0';
        insert pa1;
        
        Account ca1 = to.getAccount(true);
        ca1.Name = 'ca1';
        ca1.ParentId = pa1.Id;
        update ca1;
        
        accts.add(ca1);
        
        AccountTriggerHandler.populateBillingFields(accts); 
        
        Account account = [SELECT Id, ParentId, Billing_Street_Line_1__c, Billing_Street_Line_2__c, BillingStreet
                           FROM Account
                           WHERE Id = :ca1.id];
        
        system.Assert(account.BillingStreet == '1234 E Main st');
        
    }
    
    static testMethod void test7(){
        TestObjects to = new TestObjects();
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.ShippingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        objAcc.Shipping_Street_Line_1__c = '3190 Shinn Street';
        objAcc.Shipping_Street_Line_2__c = '3190 Shinn Street';
        insert objAcc;
        
        Account acct = new Account();
        acct.Name = 'Account2';
        acct.BillingStreet = '1234 S Main St \r\n Suite 123';
        acct.ParentId = objAcc.id;
        acct.ShippingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        acct.Shipping_Street_Line_1__c = '3190 Shinn Street';
        acct.Shipping_Street_Line_2__c = '3190 Shinn Street';
        insert acct;
        
        List<Account> accts = new List<Account>();
        accts.add(acct);
        
        AccountTriggerHandler.shareChildAccountWithParentUser(accts);
        AccountShare accountShareRecord = [Select Id, AccountId FROM AccountShare WHERE AccountId = :acct.Id AND UserOrGroupId = :UserInfo.getUserId()];
        system.Assert(accountShareRecord != null);
        
        
    }
    
    static testMethod void updateEmailOptOutTest(){
        Account objAcc = new Account();
        objAcc.FirstName = 'First2';
        objAcc.LastName = 'Last2';
        objAcc.DataAreaID__c='BUS';
        objAcc.ShippingStreet = '3190 Shinn Street \n 3190 Shinn Street';
        objAcc.Shipping_Street_Line_1__c = '3190 Shinn Street';
        objAcc.Shipping_Street_Line_2__c = '3190 Shinn Street';
        objAcc.PersonHasOptedOutOfEmail = true;
        objAcc.Subscribe_to_our_newsletter__c = true;
        insert objAcc;
        objAcc.Subscribe_to_our_newsletter__c = true;
        update objAcc;
        system.Assert(objAcc.Subscribe_to_our_newsletter__c);
        
    }
    
    @isTest
    static void testNameUpdateOnAccttoUser() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            String email = 'test_user1@yopmail.com';
            
            Id personAccountRecordTypeId = [select id from RecordType where name='Person Account'].Id;
            Id myBrvProfileId = [select id from profile where name='Breville External Identity'].Id;
            
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
            
            Account acct = [SELECT Id, FirstName, LastName, PersonEmail,
                            (Select Id, FirstName, LastName from Users) FROM Account WHERE PersonEmail=:email LIMIT 1];
            System.debug ('Account Queried: ' + acct);
            Account updAcct = new Account();
            updAcct.Id = acct.Id;
            updAcct.FirstName = 'TestFN TestFN';
            updAcct.LastName = 'TestLN TestLN';
            update updAcct;
            List<Account> updateList = new List<Account>();
            updateList.add(acct);
            System.enqueueJob(new UpdateAccountDataToUser(updateList));
        }
        
        System.debug ('Update Successful: ');
    }
    
}