@isTest
public class CWSIdentityUserTestDataFactory {

    @TestVisible private final static String LOGIN_NAME = '__' + CWSIdentityRequest.LOGIN_NAME;
    @TestVisible private final static String PASSWORD = '__' + CWSIdentityRequest.PASSWORD;
    @TestVisible private final static String EXPERIENCE_ID = '__' + CWSIdentityRequest.EXPERIENCE_ID;
    
    @TestVisible private final static String INVALID_LOGIN_NAME = 'testuser' + (Math.floor(Math.random() * 1000).intValue());
    @TestVisible private final static String INVALID_PASSWORD = 'foobar';

    @TestVisible private final static String VALID_LOGIN_NAME = INVALID_LOGIN_NAME + '@identigral.com';
    @TestVisible private final static String VALID_PASSWORD = 'Welcome1@';
    @TestVisible private final static String VALID_EXPERIENCE_ID = 'brevilleENUS';
   
  
    public static ExpectedObservedUser newlyRegisteredUser() {
        Map<String,Object> expectedValues = new Map<String,Object>{
            CWSIdentityUserTestDataFactory.LOGIN_NAME => VALID_LOGIN_NAME,
            CWSIdentityUserTestDataFactory.PASSWORD => VALID_PASSWORD,
            CWSIdentityUserTestDataFactory.EXPERIENCE_ID => VALID_EXPERIENCE_ID 
        };
        return createUser(expectedValues);
    }
    
    public static ExpectedObservedUser newlyRegisteredUserWithAnotherLogin(CWSIdentityUser user) {
    
        Map<String,Object> expectedValues = new Map<String,Object>{
            CWSIdentityUserTestDataFactory.LOGIN_NAME => INVALID_LOGIN_NAME + '1' + '@identigral.com',
            CWSIdentityUserTestDataFactory.PASSWORD => VALID_PASSWORD,
            CWSIdentityUserTestDataFactory.EXPERIENCE_ID => VALID_EXPERIENCE_ID 
        };
        return createUser(expectedValues);
    }
    
    public static ExpectedObservedUser createUser(Map<String,Object> expectedValues) {
    
        String loginName = (String)expectedValues.get(LOGIN_NAME);
        String password = (String)expectedValues.get(PASSWORD);
        String experienceId = (String)expectedValues.get(EXPERIENCE_ID);
        
        System.runAs(systemAdmin()) {
            CWSIdentityUser observedUser = new CWSIdentityUser(loginName,password,experienceId);
            return new ExpectedObservedUser(expectedValues,observedUser);
        }
        return null;
    }
    
    
    public class ExpectedObservedUser {
        public CWSIdentityUser observed {get; private set;}
        private Map<String,Object> expectedValues;
    
        public String expectedLoginName { get { return (String)expectedValues.get(LOGIN_NAME); } }
        public String expectedPassword { get { return (String)expectedValues.get(PASSWORD); } }
        public String expectedExperienceId { get { return (String)expectedValues.get(EXPERIENCE_ID); } }
        
        public ExpectedObservedUser(Map<String,Object> expectedValues, CWSIdentityUser user) {
            this.observed = CWSIdentityUserRepository.getInstance().findOneById(user.id);
            this.expectedValues = expectedValues ;
        }
        
        public void verify() {

            System.assertEquals(CWSIdentityUtils.usernameWithSuffix(this.expectedLoginName),observed.username,'User.Username');
            System.assertEquals(true,observed.isActive(),'User status');
            System.assertNotEquals(null,observed.id,'User.id');
            System.assertNotEquals(null,observed.name,'User.name');
            System.assertNotEquals(null,observed.emailVerified,'User.emailVerified');
            System.assertNotEquals(null,observed.personId,'User.personId');
            
            System.assertEquals(false,observed.emailVerified,'User status: email is verified');
            System.assertEquals(false,observed.isFrozen(),'User status: frozen');
            System.assertEquals(false,observed.isLockedOut(),'User status: locked out');
        }
    }
    
    public static User systemAdmin() {
        String username = CWSIdentityConfiguration.getInstance().serviceAccount;
        User u = [SELECT Id FROM User WHERE Username = :username];
        System.assertNotEquals(null,u,'Service account (username: ' + username + ') used for security context/runAs');
        return u;
    }
}