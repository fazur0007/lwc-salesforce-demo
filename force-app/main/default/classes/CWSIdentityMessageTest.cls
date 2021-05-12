@isTest
private class CWSIdentityMessageTest {

   
    private static void runTest(CWSIdentityMessage.MessageType messageType) {
        runTest(messageType,null);
    }
    
    private static void runTest(CWSIdentityMessage.MessageType messageType, Map<String,Object> subscriberAttributes) {
    
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityMessage msg = new CWSIdentityMessage(messageType,result.observed);
    }
    
    
    @isTest static void testForgotPasswordWithoutToken() {
        boolean faultEncountered = false;
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        try {
            new CWSIdentityMessage(CWSIdentityMessage.MessageType.FORGOT_PASSWORD,result.observed,null,
                CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID);
        }
        catch (CWSIdentityException e) {
            System.assertEquals(e.messageCode,CWSIdentityException.INVALID_PASSWORD_RESET_TOKEN);
            faultEncountered = true;
        }
        System.assert(faultEncountered,'Expected a ' + CWSIdentityException.INVALID_PASSWORD_RESET_TOKEN + 
            ' error but did not see it');
    }
    
    @isTest static void testVerifyEmailWithoutToken() {
        boolean faultEncountered = false;
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        try {
            new CWSIdentityMessage(CWSIdentityMessage.MessageType.VERIFY_EMAIL,result.observed,null, 
                CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID);
        }
        catch (CWSIdentityException e) {
            System.assertEquals(e.messageCode,CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN);
            faultEncountered = true;
        }
        System.assert(faultEncountered,'Expected a ' + CWSIdentityException.INVALID_PASSWORD_RESET_TOKEN + 
            ' error but did not see it');
    }
    
    @isTest static void testVerifyEmail() {
        CWSIdentityConfiguration config = CWSIdentityConfiguration.getInstance();
        System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = 
                CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
            CWSIdentityMessage msg = new CWSIdentityMessage(CWSIdentityMessage.MessageType.VERIFY_EMAIL,
                result.observed,token, CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID);
        }
    }
}