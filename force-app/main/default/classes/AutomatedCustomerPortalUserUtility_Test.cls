@isTest class AutomatedCustomerPortalUserUtility_Test {
    @testSetup static void setup() {
        Account acctObj = new Account();
        acctObj.FirstName = 'Breville';
        acctObj.LastName  = 'Customer';
        acctObj.PersonEmail = 'breville.customer@yopmail.com';
        acctObj.AccountSource = 'Web';
        acctObj.PreferredLanguage__c = 'English';
        acctObj.Agreed_for_Opt_in__c = true;
        acctObj.Email_External_ID__c = 'breville.customer@yopmail.com';
        insert acctObj;
    }
    @isTest public static void testPlatformEvent(){
        Account acct = [SELECT Id, FirstName, LastName,
            PersonEmail, AccountSource, PreferredLanguage__c,
            Agreed_for_Opt_in__c, Email_External_ID__c, PersonContact_SafeID__c
            FROM Account Limit 1
        ];
        User_Registration__e userEvent = new User_Registration__e(
                Account_ID__c = acct.Id,Source__c = 'Product Registration Offer', ExpId__c = 'BrevilleENUS',RecordId__c=''
        );
        Test.startTest();            
            Database.SaveResult sr = EventBus.publish(userEvent);
        Test.stopTest();
    } 
    @isTest public static void testisBeanzUserToBeCreated(){
        AutomatedCustomerPortalUserUtility.isBeanzUserToBeCreated('abc123');
    }
    
    @isTest public static void testgetEmailTempalteName(){
        AutomatedCustomerPortalUserUtility.getEmailTempalteName('Post Product Registration Offer',true);
        AutomatedCustomerPortalUserUtility.getEmailTempalteName('Post product purchase',true);
        AutomatedCustomerPortalUserUtility.getEmailTempalteName('Post product purchase',false);
        AutomatedCustomerPortalUserUtility.getEmailTempalteName('Product purchase',true);
        AutomatedCustomerPortalUserUtility.getEmailTempalteName('Product purchase',false);
        AutomatedCustomerPortalUserUtility.getEmailTempalteName('Product purchase1212',false);
    }
    
     @isTest public static void testsetUserDefaultForBeanzPromo(){
         User Obj = new user();
        AutomatedCustomerPortalUserUtility.setUserDefaultForBeanzPromo(Obj,'Product purchase','123',false);
    }
    
    @isTest public static void testcheckEligibilityForBeanzPromo(){
         User Obj = new user();
        AutomatedCustomerPortalUserUtility.checkEligibilityForBeanzPromo('Product Registration Offer','');
        AutomatedCustomerPortalUserUtility.checkEligibilityForBeanzPromo('Product purchase','8011h0000003R72AAE');
    }
    
   
}