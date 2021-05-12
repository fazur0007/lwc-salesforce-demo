@isTest 
public with sharing class CWSIdentityEmailServiceTest {

    @isTest 
    public static void testCWSIdentityEmailService() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(result.observed.id);
        String traceId = new Uuid().getValue();
        String appId = CWSIdentityConfiguration.getInstance().appIds()[0];

        CWSIdentityEmailService emServ = new CWSIdentityEmailService(u,traceId);

        CWSIdentityEmailService.initiateEmailVerification(traceId,u.Id,u.email,result.expectedExperienceId,appId);

    }
     @isTest 
    public static void testForgotPassword() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(result.observed.id);
        String traceId = new Uuid().getValue();
        
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);

        CWSIdentityEmailService emServ = new CWSIdentityEmailService(u,traceId);
// public static void initiateForgotPassword(String traceid, Id userId, String tokenValue,String experienceId) {
        CWSIdentityEmailService.initiateForgotPassword(traceId,u.Id,token.value,result.expectedExperienceId);

    }
}