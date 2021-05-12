@isTest
private class CWSIdentityServiceTest {

    private static CWSIdentityRequest.RegistrationRequest registrationRequest(String username) 
    {
    
         String password = CWSIdentityUserTestDataFactory.VALID_PASSWORD;
         String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
         System.assertNotEquals(null,appId,'At least one client must be registered');
         String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
         
        String payload = '{"username":"' + username + '","password":"' + password + '","app_id":"' + appId + 
            '","experience_id":"' + expId + '"}';

        return new CWSIdentityRequest.RegistrationRequest(payload);
    }
    
    @isTest static void testCreateUser() {
        String traceId = new Uuid().getValue();
      
        String username = CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME;
        System.debug('Attempting to create a user with username = ' + username);
        CWSIdentityRequest.RegistrationRequest req = registrationRequest(username);
        System.debug('Registration request: ' + req);
        CWSIdentityResponse.RegistrationResponse res = CWSIdentityService.getInstance(traceId).createUser(req);
        System.debug('Registration response: ' + res);
       
        CWSIdentityUser user = CWSIdentityUserRepository.getInstance().findOneByUsername(username);
                 
        System.assertNotEquals(null,user,'Newly created user');
        System.assertNotEquals(null,res.id_token,'ID Token');
    }
    
    @isTest static void testCreateUserLoginNameTaken() {
    
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        
        CWSIdentityRequest.RegistrationRequest req = registrationRequest(result.observed.username);
        
        boolean faulted = false;
        try {
            CWSIdentityService.getInstance().createUser(req);
        }
        catch (CWSIdentityException e) {
            faulted = true;
            System.assertEquals(CWSIdentityException.USERNAME_ALREADY_EXISTS,e.messageCode,'Error message code');
        }
        System.assert(faulted,'Login name is taken yet no exception was thrown');
         
    }
    
    
    @isTest static void testVerifyEmailWithInvalidToken() {
    
        CWSIdentityRequest.EmailVerificationRequest req = new CWSIdentityRequest.EmailVerificationRequest('foo123',false);
        boolean invalidRequest = true;
        try {
            CWSIdentityService.getInstance().verifyEmail(req);
        }
        catch (CWSIdentityException e) {
            System.assertEquals(CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN,e.messageCode,'Error message code');
        }
        System.assert(invalidRequest,'Email verification request with an incorrect token should be invalid');
    }
    
    @isTest static void testVerifyEmail() {
    
        CWSIdentityUser thisUser  = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        System.assert(!thisUser.emailVerified,'Email is verified - invalid baseline for this test'); 
       
        System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()){
        
            CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,thisUser.id);
            CWSIdentityRequest.EmailVerificationRequest req = new CWSIdentityRequest.EmailVerificationRequest(token);
           
            CWSIdentityService.getInstance().verifyEmail(req);
            CWSIdentityUser user = CWSIdentityUserRepository.getInstance().findOneById(thisUser.id);
            System.assert(user.emailVerified,'Email is not verified');
            
            List<Identity_Service_Token__c> issuedTokens = 
                CWSIdentityTokenRepository.getInstance().findAllByUsageAndIssuedTo(token.type,thisUser.id);
            System.assertEquals(1,issuedTokens.size(),'Number of verify email tokens issued to this user');
            CWSIdentityToken aToken = new CWSIdentityToken(issuedTokens[0]);
            System.assert(aToken.isRedeemed(),'Email verification token has NOT been redeemed');
        }
    }
    
    @isTest static void testVerifyClientApp() {
        try{
            CWSIdentityService.getInstance().verifyClientApp('blah');
            System.assert(true,'Verifying a random client app did NOT throw an exception');
        }
        catch(Exception e){
           
        }
    }

    @isTest static void testRenderKeySet(){
        try{
            CWSIdentityService.getInstance().renderKeySet();
        }
        catch(Exception e){
            System.assert(true,'Failed to render JWKeySet: ' + e.getMessage());
        }
    }

    @isTest static void testInitiatePasswordReset() {
         
        CWSIdentityUser user = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        List<String> appIds = CWSIdentityConfiguration.getInstance().appIds();
        String appId = appIds[0];  
        CWSIdentityRequest.PasswordResetInitiationRequest req = 
            new CWSIdentityRequest.PasswordResetInitiationRequest(user.username,'app',appId);

        CWSIdentityService.getInstance().initiatePasswordReset(req);
        
        String tokenType = CWSIdentityToken.tokenUsageToType.get(CWSIdentityToken.Usage.PASSWORD_RESET);
        List<Identity_Service_Token__c> issuedTokens = 
            CWSIdentityTokenRepository.getInstance().findAllByUsageAndIssuedTo(tokenType,user.id);
        System.assertEquals(1,issuedTokens.size(),'Number of password reset tokens issued to this user');
        CWSIdentityToken token = new CWSIdentityToken(issuedTokens[0]);
        System.assertEquals(false,token.isRedeemed(),'Password reset token has been redeemed');
    }
    
    @isTest static void testCompletePasswordReset() {
        
        CWSIdentityUser user = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        CWSIdentityToken aToken = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,user.id);
       
        CWSIdentityRequest.PasswordResetCompletionRequest req = 
            new CWSIdentityRequest.PasswordResetCompletionRequest(aToken.value,
                'Welcome1!1');
        CWSIdentityService.getInstance().completePasswordReset(req);
        
        String tokenType = CWSIdentityToken.tokenUsageToType.get(CWSIdentityToken.Usage.PASSWORD_RESET);
        List<Identity_Service_Token__c> issuedTokens = 
            CWSIdentityTokenRepository.getInstance().findAllByUsageAndIssuedTo(tokenType,user.Id);
        System.assertEquals(1,issuedTokens.size(),'Number of password reset tokens issued to this user');
        CWSIdentityToken token = new CWSIdentityToken(issuedTokens[0]);
        System.assertEquals(false,token.isRedeemed(),'Password reset token is multi-use and should not be tagged as redeemed');
    }

    
    @isTest static void testAuthenticateUser() {
        CWSIdentityUser user = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        try{
        CWSIdentityService.getInstance().getAccesSToken(user);
        }
        catch(Exception e){}
      
         String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
         System.assertNotEquals(null,appId,'At least one client app must be registered');
         String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
         
         String payload =  '{"' + CWSIdentityRequest.LOGIN_NAME + '":"' + user.username + 
            '","' + CWSIdentityRequest.PASSWORD + '":"' + CWSIdentityUserTestDataFactory.VALID_PASSWORD + 
            '","' + CWSIdentityRequest.APP_ID  + '":"' + appId + 
            '","' + CWSIdentityRequest.EXPERIENCE_ID  + '":"' + expId + '"}';
        
        CWSIdentityRequest.LoginRequest req = new CWSIdentityRequest.LoginRequest(payload);
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class,CWSIdentityAuthenticatorMock.ok());
        
        Test.stopTest();
        
        
     }
     
     @isTest static void testAuthenticateUserWithInvalidPassword() {
         CWSIdentityUser user = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
      
         String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
         System.assertNotEquals(null,appId,'At least one client app must be registered');
         String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
         
         String payload =  '{"' + CWSIdentityRequest.LOGIN_NAME + '":"' + user.username + 
            '","' + CWSIdentityRequest.PASSWORD + '":"' + CWSIdentityUserTestDataFactory.INVALID_PASSWORD + 
            '","' + CWSIdentityRequest.APP_ID  + '":"' + appId + 
            '","' + CWSIdentityRequest.EXPERIENCE_ID  + '":"' + expId + '"}';
            
         boolean invalidRequest = true;
          
         CWSIdentityRequest.LoginRequest req = new CWSIdentityRequest.LoginRequest(payload);
         Test.setMock(HttpCalloutMock.class,CWSIdentityAuthenticatorMock.loginFailed());
         try {
             CWSIdentityResponse.LoginResponse res = CWSIdentityService.getInstance().authenticateUser(req);
             invalidRequest = false;
         }
         catch (CWSIdentityException e) {
             System.assertEquals(CWSIdentityException.PASSWORD_INVALID,e.messageCode,'Error message code');
         }
         System.assert(invalidRequest,'Authentication request with an incorrect password should be invalid');
     }
}