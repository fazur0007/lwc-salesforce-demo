@isTest
private class CWSIdentityUserRepositoryTest {
    
    private final static String VALID_LOGIN_NAME2 = 'alex12345';
    private final static String VALID_PASSWORD = 'Welcome1';
    private final static Id INVALID_USER_ID = '0058A000002126x';
    
    
    @isTest static void testFindOneByIdWithInvalidId() {
        boolean userNotFound = false;
        try {
            CWSIdentityUserRepository.getInstance().findOneById(INVALID_USER_ID); 
        }
        catch (CWSIdentityException e) {
          userNotFound = CWSIdentityException.INVALID_USER == e.messageCode;
          System.assert(userNotFound,
            String.format('User found based on invalid id. Search criteria: {0} -> {1}. Expected error code: {2} Observed error code: {3}',
                new List<Object>{'id',INVALID_USER_ID,CWSIdentityException.INVALID_USER,e.messageCode}));
        }
    }
    
    @isTest static void testFindOneByIdWithValidId() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(result.observed.id); 
        System.assertEquals(result.observed.id,u.id,
            String.format('User not found based on valid id. Search criteria: {0} -> {1}',
                new List<Object>{'id',result.observed.id}));
    }
    
    @isTest static void testExistsByUsername() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        boolean userFound = CWSIdentityUserRepository.getInstance().existsByUsername(result.observed.username); 
        System.assertEquals(true,userFound);
    }
    
     @isTest static void testFindOneByUsername() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneByUsername(result.observed.username); 
         System.assertEquals(result.observed.id,u.id,
            String.format('User not found based provided username. Search criteria: {0} -> {1}',
                new List<Object>{'id',result.observed.username}));
    }
    
}