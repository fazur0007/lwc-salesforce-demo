@isTest
private class CWSIdentityUserTest {

    private final static String INVALID_EMAIL = 'alex%identigral.com';
    private final static String INVALID_PASSWORD_LENGTH = 'W3lc';
    private final static String INVALID_PASSWORD_COMPLEXITY = 'welcome';
   
    
    // Attempt to change the password such that the new password violates policy
    private static void testPolicyViolatingChangeOfPassword(CWSIdentityUser observed, String password,String expectedErrorCode) {
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(observed.id);
        boolean invalidPassword = false;
        try {
            u.setPassword(password); 
        }
        catch (CWSIdentityPasswordPolicyException e) {
            invalidPassword = expectedErrorCode == e.messageCode;
            System.assert(invalidPassword ,
                String.format('Changing the password to {0} one should violate policy. Expected error code: {1} Observed error code: {2}',
                    new List<Object>{password,expectedErrorCode,e.messageCode}));
        }
        System.assert(invalidPassword ,'Changing password to an invalid one should generate an error');
    }
    
    @isTest static void testProperties() {
          CWSIdentityUser u  = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
          
          System.assertNotEquals(null,u.email,'User email');
          System.assertNotEquals(null,u.name,'User.Name');
          System.assertNotEquals(null,u.personId, 'Person Id');
          System.assertNotEquals(true,u.emailVerified,'User: email is verified');
          System.assertNotEquals(null,u.username,'Username');
          System.assertNotEquals(false,u.isActive(),'User status: active');
          System.assertNotEquals(true,u.isFrozen(),'User status: active');
          System.assertNotEquals(true,u.isLockedOut(),'User status: active');
    }
    
    // Create a newly preregistered user
    @isTest static void testNewUserRegistration() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        result.verify(); 
    }
    
    // Create a newly registered user with one incorrectly formatted field
    @isTest static void testNewUserRegistrationWithInvalidLogin() {
        Map<String,Object> expectedValues = new Map<String,Object>{
            CWSIdentityUserTestDataFactory.LOGIN_NAME =>    CWSIdentityUserTestDataFactory.INVALID_LOGIN_NAME,
            CWSIdentityUserTestDataFactory.EXPERIENCE_ID =>    CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID
        };
        boolean invalidUser = false;
        try {
            CWSIdentityUserTestDataFactory.createUser(expectedValues);
        }
        catch (CWSIdentityException e) {
              invalidUser = true;
              System.assertEquals(CWSIdentityException.INVALID_REQUEST,e.messageCode,
                String.format('Creating a user with an invalid email address should generate an error. Expected error code: {0} Observed error code: {1}',
                    new List<Object>{CWSIdentityException.INVALID_REQUEST,e.messageCode}));
        }
        System.assertEquals(true,invalidUser,'Creating a user with an invalid email address should generate an error');

        boolean invalidUserNotFound = false;
        try {
            CWSIdentityUser u = CWSIdentityUserRepository.getInstance()
                .findOneByUsername(CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME);
        }
        catch (CWSIdentityException e1) {
             invalidUserNotFound = true;
             System.assertEquals(CWSIdentityException.INVALID_USER,e1.messageCode,
                String.format('Newly preregistered user with an invalid email should not exist. Expected error code: {0} Observed error code: {1}',
                    new List<Object>{CWSIdentityException.INVALID_USER,e1.messageCode}));  
        }   
        System.assertEquals(true,invalidUserNotFound,'Finding a non-existent user should generate an error');
    }
    
    // Create a newly registered user and change their password to one that violates password policy complexity rules
    @isTest static void testChangeOfPasswordWithInvalidPasswordComplexity() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        testPolicyViolatingChangeOfPassword(result.observed,
            INVALID_PASSWORD_COMPLEXITY,CWSIdentityException.PASSWORD_POLICY_VIOLATION);
    }
    
    // Create a newly registered user and change their password to one that violates password policy minimum length rule
    @isTest static void testChangeOfPasswordWithInvalidPasswordLength() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        testPolicyViolatingChangeOfPassword(result.observed,
            INVALID_PASSWORD_LENGTH,CWSIdentityException.PASSWORD_POLICY_VIOLATION);
    }
    
    // Create a newly preregistered user and change their password to one that violates password policy history rule
    @isTest static void testChangeOfPasswordWithInvalidPasswordHistory() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        testPolicyViolatingChangeOfPassword(result.observed,
            CWSIdentityUserTestDataFactory.VALID_PASSWORD,CWSIdentityException.PASSWORD_POLICY_VIOLATION_PASSWORD_HISTORY);
    }
    @isTest 
    static void testcodeCoverage(){
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityUser u= result.observed;
        try{
        u.saveUserWithPassword('balha',null);
        }
        catch(Exception e){
            //we expect to fail
        }
        try{
        u.savePassword('Blah',null);
        }
        catch(Exception e){
            //we expect to fail
        }
    }
}