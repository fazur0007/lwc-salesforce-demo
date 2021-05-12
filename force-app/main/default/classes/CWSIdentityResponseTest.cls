@isTest
private class CWSIdentityResponseTest {
    
    @isTest static void testErrorResponseWithTraceIdAndMessage() {
        String traceId = new Uuid().getValue();
        String message = 'Oops';
        CWSIdentityResponse.ErrorResponse err = new CWSIdentityResponse.ErrorResponse(traceId,message);
        
        System.assertEquals(CWSIdentityException.INVALID_REQUEST,err.error_code,'Error code');
        System.assertEquals(message,err.message,'Error message');
    }

    
    @isTest static void testErrorResponseBasedOnCWSIdentityPasswordPolicyException() {
        
        String traceId = new Uuid().getValue();
        CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(UserInfo.getUserId());
        CWSIdentityException e = new CWSIdentityPasswordPolicyException(u,'Oops');   
        CWSIdentityResponse.ErrorResponse err = new CWSIdentityResponse.ErrorResponse(traceId,e);
        

        System.assertEquals(e.messageCode,err.error_code,'Error code');
        System.assertEquals(e.getMessage(),err.message,'Error message');

        System.assertEquals(UserInfo.getUserId(),err.user_id,'User id');
    }
    
    @isTest static void testErrorResponseBasedOnGenericException() {
        
        String traceId = new Uuid().getValue();
        try {
            String s = null;
            s.startsWith('foo');
        }
        catch (Exception e) {
            CWSIdentityResponse.ErrorResponse err = new CWSIdentityResponse.ErrorResponse(traceId,e);

            System.assertEquals(CWSIdentityException.INVALID_REQUEST,err.error_code,'Error code');
            System.assertEquals(e.getMessage(),err.message,'Error message');
            System.assertEquals(null,err.user_id,'User id is NOT null');
        }
    }
    
    @isTest static void testLoginResponse() {
    
        String traceId = new Uuid().getValue();
        String appId = CWSIdentityConfiguration.getInstance().appIds().get(0); 
           
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityUser u = result.observed;
        
        CWSIdentityToken refreshToken = new CWSIdentityToken(CWSIdentityToken.Usage.RENEW_AUTHORIZATION,u.Id,appId);
        System.assertNotEquals(null,refreshToken.value,'Refresh token - value');
       
        CWSIdentityResponse.LoginResponse res = 
            new CWSIdentityResponse.LoginResponse(traceId,appId,u,'bogusAccessToken',refreshToken);
        System.assertNotEquals(null,res.id_token,'ID Token');
    }
   
}