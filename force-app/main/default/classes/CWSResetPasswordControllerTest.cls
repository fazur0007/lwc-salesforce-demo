@isTest 
public with sharing class CWSResetPasswordControllerTest {

    @isTest 
    public static void testCWSResetPasswordController() {

        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);

        
        PageReference pageRef = Page.CWSResetPassword;
        System.debug('THE TOKEN IS: ' + token.value);
        pageRef.getParameters().put('token', token.value);
        pageRef.getParameters().put('experience_id',result.expectedExperienceId);

        Test.setCurrentPage(pageRef);
        CWSResetPasswordController cont = new CWSResetPasswordController();
        Test.startTest();
        cont.newPassword = 'Welcome1!';
        cont.verifyNewPassword = 'Welcome1!';
        
        try{
            cont.resetPassword();
        }catch(Exception e){}
        System.assertEquals(cont.showError,false);
        System.assertEquals(cont.resetComplete,true);
        Test.stopTest();

    }

        @isTest 
    public static void testBadResetPasswordPolicy() {

        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);
        CWSIdentityPasswordPolicyException ppe = new CWSIdentityPasswordPolicyException(result.observed,'Test');
    
        PageReference pageRef = Page.CWSResetPassword;
        pageRef.getParameters().put('token', token.value);
        pageRef.getParameters().put('experience_id',result.expectedExperienceId);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CWSResetPasswordController cont = new CWSResetPasswordController();
        cont.newPassword = '1234';
        cont.verifyNewPassword = '1234';
        
        cont.resetPassword();
        System.assertEquals(cont.showError,true);
        System.assertEquals(cont.resetComplete,false);
        Test.stopTest();

    }
          @isTest 
    public static void testNonMatchingPasswords() {

        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);

        
        PageReference pageRef = Page.CWSResetPassword;
        pageRef.getParameters().put('token', token.value);
        pageRef.getParameters().put('experience_id',result.expectedExperienceId);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CWSResetPasswordController cont = new CWSResetPasswordController();
        cont.newPassword = 'Welcome1!';
        cont.verifyNewPassword = 'Welcome2!';
        cont.resetPassword();
        System.assertEquals(cont.showError,true);
        System.assertEquals(cont.resetComplete,false);
        Test.stopTest();

    }

    

           @isTest 
    public static void testPasswordHistory() {

        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);

        
        PageReference pageRef = Page.CWSResetPassword;
        pageRef.getParameters().put('token', token.value);
        pageRef.getParameters().put('experience_id',result.expectedExperienceId);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CWSResetPasswordController cont = new CWSResetPasswordController();
        cont.newPassword = 'Welcome2!';
        cont.verifyNewPassword = 'Welcome2!';
        cont.resetPassword();

        CWSIdentityToken token2 = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);
        PageReference pageRef2 = Page.CWSResetPassword;
        pageRef2.getParameters().put('token', token2.value);
        pageRef2.getParameters().put('experience_id',result.expectedExperienceId);
        Test.setCurrentPage(pageRef);
        cont.newPassword = 'Welcome2!';
        cont.verifyNewPassword = 'Welcome2!';
        cont.resetPassword();
        System.assertEquals(cont.showError,true);
        System.assertEquals(cont.resetComplete,false);
        Test.stopTest();

    }

    @isTest
        public static void testBlankToken() {

     
        
        PageReference pageRef = Page.CWSResetPassword;
        pageRef.getParameters().put('token', null);
        pageRef.getParameters().put('experience_id','app');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CWSResetPasswordController cont = new CWSResetPasswordController();
        cont.newPassword = 'Welcome1!';
        cont.verifyNewPassword = 'Welcome2!';
        cont.resetPassword();
        System.assertEquals(cont.showError,true);
        System.assertEquals(cont.resetComplete,false);
        Test.stopTest();

    }
}