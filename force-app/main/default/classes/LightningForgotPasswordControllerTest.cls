@IsTest
public with sharing class LightningForgotPasswordControllerTest {

    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertNotEquals(LightningForgotPasswordController.forgotPassword('fakeuser@test.com', 'http://a.com', 'http://a.com'), Label.Site.invalid_email);
        System.assertNotEquals(LightningForgotPasswordController.forgotPassword(null, 'tester@noemail.com', 'http://a.com'), Label.Site.invalid_email);
        System.assertNotEquals(LightningForgotPasswordController.forgotPassword('fakeuser@test.com', 'http://a.com', '/home/home.jsp'), Label.Site.invalid_email);
    }
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
        System.assertNotEquals(null, LightningForgotPasswordController.setExperienceId('BrevilleENUS'));
        System.assertEquals('BrevilleENUS', LightningForgotPasswordController.getExperienceIdFromSite());
    }
    @isTest public static void testConfig() {
     Id recordtype = [select id from RecordType where name='Person Account'].Id;
    
         Account acc = new Account(lastname= 'test acc',personemail='abc1237654@gmail.com',RecordTypeId=recordtype);
        insert acc;
        User newuser = new User();
          newuser.Account_ID__c = acc.Id;
           // newuser.ContactId = [select id,PersonContactId from account where id=:acc.Id].PersonContactId;
        String alias = 'br' + Integer.valueof((Math.random()*100000000));
        alias = alias.substring(0, 8);
        newuser.emailEncodingKey = 'UTF-8';
        newuser.timeZoneSidKey = 'America/Los_Angeles';       
        newuser.profileId = [select id,name from profile where name='Call Centre User'].Id;
        newuser.email = 'abc1237654@gmail.com';
        newuser.Username = 'abc1237654@gmail.com';
        newuser.lastName = 'TestEmp';
        newuser.languagelocalekey = 'en_CA';
        newuser.localesidkey= 'en_CA';
        newuser.alias = alias; 
        insert newuser;
        LightningForgotPasswordController.getTranslationsByExpID('brevilleENUS');
        LightningForgotPasswordController.redirect(newuser,'brevilleENUS' , 'http://a.com', 'http://a.com');
    }
  /*public static void testupdateCurrentUserExpID() {
        LightningForgotPasswordController.updateCurrentUserExpID('abi@123.com');        
    }*/
    @isTest public static void testupdateCurrentUserExpID1() {
    Id recordtype = [select id from RecordType where name='Person Account'].Id;
      Account acc = new Account(lastname= 'test acc',personemail='abc1237654@gmail.com',RecordTypeId=recordtype);
        insert acc;
        User newuser = new User();
          newuser.Account_ID__c = acc.Id;
            //newuser.ContactId = [select id,PersonContactId from account where id=:acc.Id].PersonContactId;
        String alias = 'br' + Integer.valueof((Math.random()*100000000));
        alias = alias.substring(0, 8);
        newuser.emailEncodingKey = 'UTF-8';
        newuser.timeZoneSidKey = 'America/Los_Angeles';       
        newuser.profileId = [select id,name from profile where name='Call Centre User'].Id;
        newuser.email = 'abc1237654@gmail.com';
        newuser.Username = 'abc1237654@gmail.com';
        newuser.lastName = 'TestEmp';
        newuser.languagelocalekey = 'en_CA';
        newuser.localesidkey= 'en_CA';
        newuser.alias = alias; 
        insert newuser;
        LightningForgotPasswordController.updateCurrentUserExpID(newuser,'brevilleENUS');        
    }
}