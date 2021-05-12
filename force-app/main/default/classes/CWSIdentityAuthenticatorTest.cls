@isTest
private class CWSIdentityAuthenticatorTest {

    private static Map<String,CWSIdentityAuthenticator.AuthenticationOutcome> stringToOutcome = 
        new Map<String,CWSIdentityAuthenticator.AuthenticationOutcome> {
            'OK' => CWSIdentityAuthenticator.AuthenticationOutcome.OK,
            'ExpiredPassword' => CWSIdentityAuthenticator.AuthenticationOutcome.ExpiredPassword
    };
    
    private static Map<CWSIdentityAuthenticator.AuthenticationOutcome,String> outcomeToString = 
        new Map<CWSIdentityAuthenticator.AuthenticationOutcome,String> {
            CWSIdentityAuthenticator.AuthenticationOutcome.OK => 'OK',
            CWSIdentityAuthenticator.AuthenticationOutcome.ExpiredPassword => 'ExpiredPassword'
    };
    
    private static Map<CWSIdentityAuthenticator.AuthenticationOutcome, HttpCalloutMock> mocks = 
        new Map<CWSIdentityAuthenticator.AuthenticationOutcome, HttpCalloutMock> {
            CWSIdentityAuthenticator.AuthenticationOutcome.OK => CWSIdentityAuthenticatorMock.ok(),
            CWSIdentityAuthenticator.AuthenticationOutcome.ExpiredPassword => CWSIdentityAuthenticatorMock.passwordExpired()
    };

    
    private static User makeUser(String email,String expId) {
        
        Account acct = new Account();
        acct.Email_External_ID__c = email;
        boolean doCreateAccount = true;
        acct = CommunityUserManagementUtility.FetchAccountDefaults(acct,expId,doCreateAccount);
        insert acct;
        
        User u = CWSIdentityUser.createUserForAccount(acct,email,expId);
        insert u;
        
        return u;
    }
    
    @future(callout=true)
    public static void calloutViaMock(Id userId, String expectedOutcome) {
   
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(userId);
        CWSIdentityAuthenticator.AuthenticationOutcome outcome = stringToOutcome.get(expectedOutcome);
        System.debug('Expected outcome: ' + expectedOutcome + ' outcome: ' + outcome);

        Test.setMock(HttpCalloutMock.class,mocks.get(outcome));
        CWSIdentityAuthenticator.AuthenticationResult auth = 
            CWSIdentityAuthenticator.getInstance().authenticateUser(u,CWSIdentityUserTestDataFactory.VALID_PASSWORD);
        System.assertEquals(outcome,auth.status); 
    }

    
    @isTest static void testAuthenticateUserOk() {
        User u = makeUser(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME, 
            CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID);
            
        Test.startTest(); 
        calloutViaMock(u.Id,outcomeToString.get(CWSIdentityAuthenticator.AuthenticationOutcome.OK));
        Test.stopTest();
    }
    
    @isTest static void testAuthenticateUserExpiredPassword() {
         User u = makeUser(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME, 
            CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID);
         
        Test.startTest(); 
        calloutViaMock(u.Id,outcomeToString.get(CWSIdentityAuthenticator.AuthenticationOutcome.ExpiredPassword));
        Test.stopTest();
    }
    
    @isTest 
    public static void testAuthenticated(){
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(result.observed.id);
             CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);

    
            CWSIdentityAuthenticator.isUserAuthConstrained(u);
    }

    @isTest static void testAuthenticateUserInvalidPassword() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(result.observed.id);

        
        Test.startTest();      
        Test.setMock(HttpCalloutMock.class,CWSIdentityAuthenticatorMock.loginFailed());
        CWSIdentityAuthenticator.AuthenticationResult auth = 
            CWSIdentityAuthenticator.getInstance().authenticateUser(result.observed,'bogus');
        System.assertEquals(CWSIdentityAuthenticator.AuthenticationOutcome.InvalidPassword,auth.status);
        Test.stopTest();
    }
    
    @isTest static void testAuthenticateUserFrozen() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
                
        UserLogin ul = CWSIdentityUserLoginRepository.getInstance().findOneById(result.observed.id);
        ul.IsFrozen = true;
        update ul;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,CWSIdentityAuthenticatorMock.loginFailed());
        CWSIdentityAuthenticator.AuthenticationResult auth = 
            CWSIdentityAuthenticator.getInstance().authenticateUser(result.observed,'bogus');
        System.assertEquals(CWSIdentityAuthenticator.AuthenticationOutcome.InvalidPassword,auth.status);
        Test.stopTest();
    }
    
    @isTest static void testAuthenticationResultConstructors() {
        String msg = 'Authentication failed';
        CWSIdentityException e = new CWSIdentityException(CWSIdentityException.RUNTIME_ERROR,msg);
        CWSIdentityAuthenticator.AuthenticationResult auth = new  CWSIdentityAuthenticator.AuthenticationResult(e);
        System.assertEquals(CWSIdentityAuthenticator.AuthenticationOutcome.InvalidPassword,auth.status);
        System.assertEquals(auth.message,msg);    
    }
    
}