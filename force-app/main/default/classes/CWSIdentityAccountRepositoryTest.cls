@isTest
private class CWSIdentityAccountRepositoryTest {

   @isTest static void testFindByEmail() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        List<Account> accts = CWSIdentityAccountRepository.getInstance().findByEmail('foo');
        System.assertEquals(0,accts.size());
   }
}