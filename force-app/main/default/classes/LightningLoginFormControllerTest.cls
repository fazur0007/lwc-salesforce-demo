@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void testLoginWithInvalidCredentials() {
   String result =  LightningLoginFormController.getLoginErrorMessage('BrevilleENUS');
  //System.assertEquals(result, LightningLoginFormController.login('testUser', 'fakepwd', null));
 }
 
 @IsTest
 static void testLoginWithvalidCredentials() {
//   String result =  LightningLoginFormController.getLoginErrorMessage();
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
   LightningLoginFormController.login('abc1237654@gmail.com', 'fakepwd', null);
 }

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
 
 @IsTest
 static void testGetExpid() {
    LightningLoginFormController.getExperienceIdFromSite();
 }
 
  @IsTest
   static void testSetExpid() {
    LightningLoginFormController.setExperienceId('Test');
 }
 
}