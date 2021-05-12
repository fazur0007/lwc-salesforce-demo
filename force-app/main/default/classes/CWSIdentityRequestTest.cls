@isTest
private class CWSIdentityRequestTest {

    private static String registrationOrLoginPayload() {
    
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
        String username = CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME;
        String password = CWSIdentityUserTestDataFactory.VALID_PASSWORD;
        String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
        
        String payload  = '{"' +  
            CWSIdentityRequest.LOGIN_NAME + '":"' + username + '","' + 
            CWSIdentityRequest.PASSWORD + '":"' + password + '","' + 
            CWSIdentityRequest.APP_ID + '":"' + appId + '","' + 
            CWSIdentityRequest.EXPERIENCE_ID + '":"' + expId + '"}';
       
       return payload;
    }
    
    
    @isTest static void testRegistrationRequestWithInvalidPayload() {
        String payload = '{"foo":"bar"}';
        boolean validPayload = false;
        try {
            CWSIdentityRequest.RegistrationRequest req = new CWSIdentityRequest.RegistrationRequest(payload);
            validPayload = true;
        }
        catch (CWSIdentityException e) {
            System.assertEquals(CWSIdentityException.INVALID_REQUEST,e.messageCode);
        }
        System.assertEquals(false,validPayload);
    }
    
    
    @isTest static void testRegistrationRequestWithValidPayload() {
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
         
        CWSIdentityRequest.RegistrationRequest req = new CWSIdentityRequest.RegistrationRequest(registrationOrLoginPayload());
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID,req.experienceId);
        System.assertEquals(appId,req.appId);
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME,req.loginName);
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_PASSWORD,req.password);
    }
    
    @isTest static void testLoginRequestWithInvalidPayload() {
        String payload = '{"foo":"bar"}';
        boolean validPayload = false;
        try {
            CWSIdentityRequest.LoginRequest req = new CWSIdentityRequest.LoginRequest(payload);
            validPayload = true;
        }
        catch (CWSIdentityException e) {
            System.assertEquals(CWSIdentityException.INVALID_REQUEST,e.messageCode);
        }
        System.assertEquals(false,validPayload);
    }
    
    @isTest static void testLoginRequestWithValidPayload() {
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
        CWSIdentityRequest.LoginRequest req = new CWSIdentityRequest.LoginRequest(registrationOrLoginPayload());
        
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID,req.experienceId);
        System.assertEquals(appId,req.appId);
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME,req.loginName);
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_PASSWORD,req.password);
    }
    
     @isTest static void testLoginRequestWithInvalidPayloadWrongAttributeType() {
        String payload = '{"experience_id":"foo","username":"foobar","password":"Welcome!1blah","app_id":10}';
        boolean validPayload = false;
        try {
            CWSIdentityRequest.LoginRequest req = new CWSIdentityRequest.LoginRequest(payload);
            validPayload = true;
        }
        catch (CWSIdentityException e) {
             System.assertEquals(CWSIdentityException.INVALID_REQUEST,e.messageCode,'Error message code');
        }
        System.assertEquals(false,validPayload,'Payload should be invalid');
    }
    
    @isTest static void testPasswordResetInitiationRequest() {
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
        
        CWSIdentityRequest.PasswordResetInitiationRequest req = 
            new CWSIdentityRequest.PasswordResetInitiationRequest(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME,
                CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID,appId);
                
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME,req.loginName);
        System.assertEquals(CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID,req.experienceId);
        System.assertEquals(appId,req.appId);
    }
    
    
    @isTest static void testPasswordResetInitiationRequestWithInvalidPayload() {
        String payload = '{"username":"foobar"}';
        boolean validPayload = false; 
        try {
            CWSIdentityRequest.PasswordResetInitiationRequest req = 
                new CWSIdentityRequest.PasswordResetInitiationRequest(payload);
            validPayload = true;
        }
        catch (CWSIdentityException e) {
            System.assertEquals(CWSIdentityException.INVALID_REQUEST,e.messageCode);    
        }
        System.assertEquals(false,validPayload);

    }
   
    
     @isTest static void testEmailVerificationRequestWithTokenPayload() {
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,UserInfo.getUserId());
        CWSIdentityRequest.EmailVerificationRequest req = 
            new CWSIdentityRequest.EmailVerificationRequest(token);
        System.assertEquals(token.value,req.emailVerificationToken);
    }
    
    @isTest static void testEmailVerificationRequestWithValidPayload() {
        String token = new Uuid().getValue();
         CWSIdentityRequest.EmailVerificationRequest req = 
            new CWSIdentityRequest.EmailVerificationRequest(token,false);
        System.assertEquals(token,req.emailVerificationToken);
    }
    
    @isTest static void testEmailVerificationRequestWithInvalidPayload() {
        String payload = '{"foo":"bar"}';
        boolean validPayload = false; 
        try {
            CWSIdentityRequest.EmailVerificationRequest req = 
                new CWSIdentityRequest.EmailVerificationRequest(payload);
            validPayload = true;
        }
        catch (CWSIdentityException e) {
            System.assertEquals(CWSIdentityException.INVALID_REQUEST,e.messageCode);    
        }
        System.assertEquals(false,validPayload);
    }
    
    
    @isTest static void testPasswordResetCompletionRequest () {
        String token = new Uuid().getValue();
        String newPassword = 'Welcome2blah';
        CWSIdentityRequest.PasswordResetCompletionRequest req = 
            new CWSIdentityRequest.PasswordResetCompletionRequest(token,newPassword);
        System.assertEquals(token,req.passwordResetToken);
        System.assertEquals(newPassword,req.password);
    }
}