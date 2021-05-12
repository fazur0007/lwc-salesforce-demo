/**
* This is the text class for MarketingOptInControllerTest
* @author deepak_tomar@persistent.com
* @version 1.0
* @since April 24, 2018
*/

@isTest
public class MarketingOptInControllerTest{
    
    @testsetup
    static void setup(){
        createAccount('ABC', 'abc@example.com');
    }

    public static void createAccount(String lname, String email){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = lname;
        record.firstName = 'firstName';
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = email;
        record.TerritoryAssigned__c = false;
        record.SendNLReminderEmail__c = false;
        record.Subscribe_to_our_newsletter__c = false;
        record.MkgOptEmailSent__c = System.Now();

        insert record;
    }
	
    // set NewsLetterSubscription__c on click of the valid link
    static testMethod void testAccountUpdate(){
        //Test.startTest();
        PageReference thankYouForSubscribing = Page.Thank_you_for_subscribing;
        Test.setCurrentPage(thankYouForSubscribing );
        
        // query user account
        Account acc = [SELECT Id, PersonEmail  FROM ACCOUNT LIMIT 1];
        
        // Put p, q into the current page Parameters
        Blob p = blob.valueof(acc.Id);
        Blob q = blob.valueof(acc.PersonEmail );
        
        ApexPages.currentPage().getParameters().put('p', EncodingUtil.base64Encode(p));
        ApexPages.currentPage().getParameters().put('q', EncodingUtil.base64Encode(q));

        try {
            MarketingOptInController obj = new MarketingOptInController();
            obj.init();
            System.assertEquals(obj.updateStatus, 'updated');
            
            // when the user has already subscribed.
            obj.init();
        } catch(Exception err) {
            System.debug('error -> ' + err);
        }
    }
    
    // when the URL is tamepered with
    static testMethod void testInvalidAccount(){
        //Test.startTest();
        PageReference thankYouForSubscribing = Page.Thank_you_for_subscribing;
        Test.setCurrentPage(thankYouForSubscribing );
        
        // query user account
        Account acc = [SELECT Id, PersonEmail  FROM ACCOUNT LIMIT 1];
        
        // Put p, q into the current page Parameters
        Blob p = blob.valueof('xyz');  // wrong parameter
        Blob q = blob.valueof(acc.PersonEmail );
        
        ApexPages.currentPage().getParameters().put('p', EncodingUtil.base64Encode(q)); // wrong url parameter is passed
        ApexPages.currentPage().getParameters().put('q', EncodingUtil.base64Encode(q));
        
        try {
            MarketingOptInController obj = new MarketingOptInController();
            obj.init();
            System.assertEquals(obj.updateStatus, 'wrongURL');
            
        } catch(Exception err) {
            System.debug('error -> ' + err);
        }
    }
    
    // when the URL has expired
    static testMethod void testExpiredURL(){
        //Test.startTest();
        PageReference thankYouForSubscribing = Page.Thank_you_for_subscribing;
        Test.setCurrentPage(thankYouForSubscribing );
        
        // query user account
        Account acc = [SELECT Id, PersonEmail  FROM ACCOUNT LIMIT 1];
        acc.MkgOptEmailSent__c = Date.today().addDays(-30);
        update acc;
        
        // Put p, q into the current page Parameters
        Blob p = blob.valueof(acc.Id);
        Blob q = blob.valueof(acc.PersonEmail );
        
        ApexPages.currentPage().getParameters().put('p', EncodingUtil.base64Encode(p)); // wrong url parameter is passed
        ApexPages.currentPage().getParameters().put('q', EncodingUtil.base64Encode(q));
        
        try {
            MarketingOptInController obj = new MarketingOptInController();
            obj.init();
            System.assertEquals(obj.updateStatus, 'expiredLink');
            
        } catch(Exception err) {
            System.debug('error -> ' + err);
        }
    }

}