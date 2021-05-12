@isTest
private class CWSIdentityEmailVerificationResourceTest {

    private static void runTest(String payload) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/identity/v1/verify_email';
        req.addParameter('token',payload);
        req.addParameter('experience_id','app');
        req.httpMethod = 'GET';
        
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CWSIdentityEmailVerificationResource.verifyEmail();
        Test.stopTest();
    }
    
    private static void assertBadRequest(Integer expectedStatusCode, String expectedErrorCode) {
        RestResponse res = RestContext.response;
        
        System.assertEquals(expectedStatusCode,res.statusCode,'HTTP response status code');
        
       
    }
    
    private static void assertSuccess() {
        RestResponse res = RestContext.response;
         
        System.assertNotEquals(null,res,'HTTP Response - valid request should produce a response');
        //System.assertEquals(null,res.responseBody,'HTTP Response - valid request should produce an empty response body');
        System.assertNotEquals(null,res.headers,'HTTP Response - headers');
        //System.assertEquals('application/json',res.headers.get('Content-Type'),'Content-Type response header');
        System.assertEquals(301,res.statusCode,'HTTP response status code');
    }

    @isTest(seeAllData=true)  static void testVerifyEmailWithEmptyRequest() {
        runTest(null);
        assertBadRequest(301,CWSIdentityException.INVALID_REQUEST);
    }
    
    @isTest(seeAllData=true)  static void testVerifyEmailWithInvalidToken() {
        String payload = '{"email_verification_token":"' + 'foobar' + '"}';
        runTest('foobar');
        assertBadRequest(301,CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN);
    }
    
    @isTest(seeAllData=true) static void testVerifyEmail() {
        
           CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
        String payload = '{"email_verification_token":"' + token.value + '"}';
        runTest(token.value);

        assertSuccess();
    }
    
    @isTest(seeAllData=true)  static void testVerifyEmailWithRedeemedToken() {
         CWSIdentityUserTestDataFactory.ExpectedObservedUser result  = 
            CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
        token.redeem();
        String payload = '{"email_verification_token":"' + token.value + '"}';
        runTest(token.value);

        assertBadRequest(301,CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN);
    }
}