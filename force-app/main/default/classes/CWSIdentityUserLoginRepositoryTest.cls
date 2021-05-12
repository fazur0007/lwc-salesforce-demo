@isTest
private class CWSIdentityUserLoginRepositoryTest {

   @isTest static void testFindOneById() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        UserLogin ul = CWSIdentityUserLoginRepository.getInstance().findOneById(result.observed.id);
        System.assert(ul != null,'UserLogin record does not exist');
        System.assert(!ul.IsFrozen,'User is frozen');
        System.assert(!ul.IsPasswordLocked,'User account is locked');
   }
}