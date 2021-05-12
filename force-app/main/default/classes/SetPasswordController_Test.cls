@isTest public class SetPasswordController_Test {
    private static User createTestUser(String expId) {
        Profile profile = [Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Admin';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Exp_ID__c = expId;
        insert testUser;
        return testUser;
    }
    @isTest static void validateOverralMethods() {
        System.runAs(createTestUser('BrevilleENUS')) {
            Test.startTest();
                doTestInitOperationsforBreville();                
            Test.stopTest();
        }
    }
    @isTest public static void doTestInitOperationsforBreville(){
       SetPasswordController sp = new SetPasswordController (); 
       sp.hidePasswordIcon = true;
       sp.hideConfirmPasswordIcon  = true;
       sp.passwordPlaceHolder = 'Test';
       sp.confirmPasswordPlaceHolder = 'test';
       sp.passwordLabel = 'test';
       sp.confirmPasswordLabel  = 'Test';
       sp.saveNewPassword  = 'test';
       sp.newPassword = 'Test123#';
       sp.verifyNewPassword = 'Test123#';
       sp.errorMessage  = 'Error';
       sp.Min_6_characters_1_number  = 'Test';
       sp.passwordStrengthLabel = 'Test';
       sp.saveNewPasswordCss = 'css';
       sp.doInitActions();
       sp.setPassword();
       sp.verifyNewPassword = 'Test123@';
       sp.setPassword();
    }
    
    @isTest static void validateBeanzProcessMethods() {
        System.runAs(createTestUser('beanzENUS')) {
            Test.startTest();
            doTestInitOperationsforBeanz();
            Test.stopTest();
        }
    }
    
    @isTest public static void doTestInitOperationsforBeanz(){
       SetPasswordController sp = new SetPasswordController (); 
       sp.hidePasswordIcon = true;
       sp.hideConfirmPasswordIcon  = true;
       sp.passwordPlaceHolder = 'Test';
       sp.confirmPasswordPlaceHolder = 'test';
       sp.passwordLabel = 'test';
       sp.confirmPasswordLabel  = 'Test';
       sp.saveNewPassword  = 'test';
       sp.newPassword = 'Test123#';
       sp.verifyNewPassword = 'Test123#';
       sp.errorMessage  = 'Error';
       sp.Min_6_characters_1_number  = 'Test';
       sp.passwordStrengthLabel = 'Test';
       sp.saveNewPasswordCss = 'css';
       sp.doInitActions();
       sp.setPassword();
       sp.verifyNewPassword = 'Test123@';
       sp.setPassword();
    }
    
    @isTest static void validateAppProcessMethods() {
        System.runAs(createTestUser('AppENUS')) {
            Test.startTest();
                doTestInitOperationsforApp();                
            Test.stopTest();
        }
    }
    
    @isTest public static void doTestInitOperationsforApp(){
       SetPasswordController sp = new SetPasswordController (); 
       sp.hidePasswordIcon = true;
       sp.hideConfirmPasswordIcon  = true;
       sp.passwordPlaceHolder = 'Test';
       sp.confirmPasswordPlaceHolder = 'test';
       sp.passwordLabel = 'test';
       sp.confirmPasswordLabel  = 'Test';
       sp.saveNewPassword  = 'test';
       sp.newPassword = 'Test123#';
       sp.verifyNewPassword = 'Test123#';
       sp.errorMessage  = 'Error';
       sp.Min_6_characters_1_number  = 'Test';
       sp.passwordStrengthLabel = 'Test';
       sp.saveNewPasswordCss = 'css';
       sp.doInitActions();
       sp.setPassword();
       sp.verifyNewPassword = 'Test123@';
       sp.setPassword();
    }
    
    
}