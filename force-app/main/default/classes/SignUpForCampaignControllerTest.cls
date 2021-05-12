@isTest
public class SignUpForCampaignControllerTest {
    
    static testMethod void testMethodForNewAccount(){
        Account objAcc = new Account(firstName = 'ABC', lastName = 'XYZ', PersonEmail='test@example.com', Campaign_Subscription__c = 'pizzaiolo');
        insert objAcc;
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'DE');
        pageRef.getParameters().put('language', 'DE' );
        pageRef.getParameters().put('campaign', 'pizzaiolo');
        
        SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = 'test@example.com';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id from Account where personEmail='test@example.com' ];
        System.assertEquals(1, acc.size());

    }
    
    static testMethod void testMethodWithBlankEmail(){
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en_US' );
        pageRef.getParameters().put('campaign', 'pizzaiolo');
        
        SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = '';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id from Account where firstName='ABC' limit 1];
        System.assertEquals(0, acc.size());

    }
    
    static testMethod void testMethodWithInvalidEmail(){
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'CA');
        pageRef.getParameters().put('language', 'FR' );
        pageRef.getParameters().put('campaign', 'pizzaiolo');
        
        SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = 'testexample.com';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id from Account where firstName='ABC' limit 1];
        System.assertEquals(0, acc.size());

    }
    
     static testMethod void testMethodWithBlankCampaign(){
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'CA');
        
        SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = 'testexample.com';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id from Account where firstName='ABC' limit 1];
        System.assertEquals(0, acc.size());
    }
    
    static testMethod void testMethodForNewAccountWithZipCode(){
        Account objAcc = new Account(firstName = 'ABC', lastName = 'XYZ', PersonEmail='test@example.com', Campaign_Subscription__c = 'pizzaiolo');
        insert objAcc;
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'UK');
        pageRef.getParameters().put('language', 'en_UK' );
        pageRef.getParameters().put('campaign', 'Coffee Events');
        
        SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = 'test@example.com';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        //ctrl.dummyAccount.Marketing_Zip_Code__c = '1234asd';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id from Account where firstName='ABC' limit 1];
        System.assertEquals(1, acc.size());

    }
    
    static testMethod void testMethod1(){
        Account objAcc = new Account(firstName = 'ABC', lastName = 'XYZ', PersonEmail='abc@xyz.com', Campaign_Subscription__c = 'pizzaiolo');
        insert objAcc;
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en_US' );
        pageRef.getParameters().put('campaign', 'pizzaiolo');
        
        SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = 'abc@xyz.com';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id from Account where firstName='ABC' limit 1];
        System.assertEquals(1, acc.size());

}
    
     static testMethod void testMethodWithCampaignName(){
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'DE');
        pageRef.getParameters().put('language', 'DE' );
        pageRef.getParameters().put('campaignName', 'pizzaiolo');
         
        //Create Campaign
        Campaign camp = new Campaign();
        camp.Name='pizzaiolo';
        camp.CurrencyIsoCode = 'EUR';
        camp.IsActive = True;
        insert camp;
         
       	SignUpForCampaignController ctrl = new SignUpForCampaignController();
        ctrl.dummyAccount.personEmail = 'test@example.com';
        ctrl.dummyAccount.firstName = 'ABC';
        ctrl.dummyAccount.lastName = 'XYZ';
        
        Test.starttest();
        
        ctrl.subscriptionSave();
        
        Test.stopTest();
       
        List<Account> acc = [select id,PersonContactId from Account where personEmail='test@example.com' limit 1];
        System.assertEquals(1, acc.size());
         
        List<CampaignMember> campmemberList = [select Id ,ContactId ,CampaignId from CampaignMember 
                                               where CampaignId =: camp.Id and ContactId=:acc[0].PersonContactId limit 1];
        System.assertEquals(1, campmemberList.size());
                    
    }
    
}