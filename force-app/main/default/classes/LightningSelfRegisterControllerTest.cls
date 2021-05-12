@IsTest(SeeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() {
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
        System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
    }
    @IsTest
    static void testSiteAsContainerEnabled() {
        System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
    }
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        System.assertNotEquals(null, LightningSelfRegisterController.setExperienceId('Breville'));
        LightningSelfRegisterController.initialize();
        LightningSelfRegisterController.redirectOnSignUp('user@test.com', 'password?@12334');
        //System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), '', paramsMap.get('regConfirmUrl'), '', paramsMap.get('startUrl'), true));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        //System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        //System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
    }
    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithProperCredentials() {
        Map < String, String > paramsMap = initializeParams();
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true);
        //System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true);
    }
    
     /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithValidatepwdFail() {
        Map < String, String > paramsMap = initializeParams();
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 'abcdef', 'abcdef', null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true);      
    }
    
    /* Verifies SelfRegistration flow with an accounId that is created within the test */
    @IsTest
    static void testSelfRegisterWithCreatedAccount() {
        Account acc = new Account(name = 'test acc');
        insert acc;
        List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;
        Map < String, String > paramsMap = initializeParams();
        LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false);
    }
    @IsTest
    static void testGetNullExtraFields() {
        LightningSelfRegisterController.getExtraFields('');
    }
    @IsTest
    static void testGetNonEmptyExtraFields() {
        LightningSelfRegisterController.getExtraFields('field1');
    }
    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
    }
    @IsTest
    static void LightningSelfRegisterControllerInstantiation() {
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        System.assertNotEquals(controller, null);
    }
    
    
    @IsTest
    static void testWithEmptyEmail()
    {
        LightningSelfRegisterController.selfRegister('abishekh','test123', '', 'abi@123', 'abi@123', '', '', '', '', true);
        //LightningSelfRegisterController.selfRegister('abishekh','test123', 'abc@abc123.com', 'abi@123', 'abi@12', '', '', '', '', true);
    }
    
    @IsTest
    static void testWithNoMatchPassword()
    {
        //LightningSelfRegisterController.selfRegister('abishekh','test123', '', 'abi@123', 'abi@123', '', '', '', '', true);
        LightningSelfRegisterController.selfRegister('abishekh','test123', 'abc1237654@gmail.com', 'abi@123', 'abi@12', '', '', '', '', true);
    }
    
    @IsTest
    static void testWithExistingUser()
    {
        //LightningSelfRegisterController.selfRegister('abishekh','test123', '', 'abi@123', 'abi@123', '', '', '', '', true);
        User newuser = new User();
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
        LightningSelfRegisterController.selfRegister('abishekh','test123', 'abc1237654@gmail.com', 'abi@123', 'abi@12', '', '', '', '', true);
    }
    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    
    @IsTest
    static void testWithWrongPassword()
    {
        Id recordtype = [select id from RecordType where name='Person Account'].Id;
    
         Account acc = new Account(lastname= 'test acc',personemail='abc1237654@gmail.com',RecordTypeId=recordtype);
        insert acc;
        
        LightningSelfRegisterController.selfRegister('testuser','test123', 'abc1237654@gmail.com', '123', '123', '', '', '', '', true);
        
    }
    
    @IsTest
    static void testdoGetCurrentUserConfig()
    {
        //LightningSelfRegisterController.selfRegister('abishekh','test123', '', 'abi@123', 'abi@123', '', '', '', '', true);
        User newuser = new User();
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
        LightningSelfRegisterController.doGetCurrentUserConfig(newuser.Id);
    }
    
    @IsTest
    static void testselfRegister1()
    {
        //LightningSelfRegisterController.selfRegister('abishekh','test123', '', 'abi@123', 'abi@123', '', '', '', '', true);
        User newuser = new User();
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
       LightningSelfRegisterController.selfRegister('testuser','test123', 'abc1237654@gmail.com', '123', '123', '', '', '', '', true);
    }
}