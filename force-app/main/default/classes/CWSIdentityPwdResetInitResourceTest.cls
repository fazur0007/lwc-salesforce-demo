@isTest
private class CWSIdentityPwdResetInitResourceTest {

    private static void runTest(String payload) {
        runTest(payload,true);
    }

    private static void runTest(String payload, boolean startStopTest) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/identity/v1/init_password_reset';
        req.httpMethod = 'POST';
        if (payload != null)
            req.requestBody = Blob.valueOf(payload);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        if (startStopTest) Test.startTest();
        CWSIdentityPasswordResetInitResource.initPasswordReset();
        if (startStopTest) Test.stopTest();
        
        System.debug('REST response: ' + RestContext.response);
        if (RestContext.response.responseBody != null)
            System.debug('REST response body: ' + RestContext.response.responseBody.toString());
    }
    
    private static void assertBadRequest(Integer expectedStatusCode, String expectedErrorCode) {
        RestResponse res = RestContext.response;
        
        System.assertNotEquals(null,res,'HTTP Response - invalid request should produce a response');
        System.assertNotEquals(null,res.responseBody,'HTTP Response - invalid request should produce a non-empty response body');
        System.assertEquals(expectedStatusCode,res.statusCode,'HTTP response status code');
        System.assertEquals('application/json',res.headers.get('Content-Type'),'Content-Type response header');
        
        CWSIdentityResponse.ErrorResponse errorResponse = (CWSIdentityResponse.ErrorResponse)
            JSON.deserialize(res.responseBody.toString(),CWSIdentityResponse.ErrorResponse.class);
        System.assertNotEquals(null,errorResponse,'Error response');
        System.assertNotEquals(null,errorResponse.message,'Error message');
        System.assertEquals(expectedErrorCode,errorResponse.error_code,'Response - error code');
    }
    
    private static void assertSuccess() {
        RestResponse res = RestContext.response;
        
        System.assertNotEquals(null,res,'HTTP Response - valid request should produce a response');
        System.assertEquals(null,res.responseBody,'HTTP Response - valid request should produce an empty response body');
        System.assertNotEquals(null,res.headers,'HTTP Response - headers');
        System.assertEquals('application/json',res.headers.get('Content-Type'),'Content-Type response header');
        System.assertEquals(200,res.statusCode,'HTTP response status code');
    }

    @isTest static void testInitPasswordResetWithEmptyRequest() {
        runTest(null);
        assertBadRequest(400,CWSIdentityException.INVALID_REQUEST);
    }
    
    @isTest static void testInitPasswordResetWithMalformedRequest() {
        String payload = '{"username":"foo","user_id":' + 1234567 + '"}';
        runTest(payload);
        assertBadRequest(400,CWSIdentityException.INVALID_REQUEST);
    }
    
    @isTest static void testInitPasswordReset() {
        
        CWSIdentityUser u = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
        System.assertNotEquals(null,appId,'At least one client app must be registered');
        
        String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
        
        
        String payload = '{"username":"' + u.username + '","app_id":"' + appId + '","experience_id":"' + expId +  '"}';
        runTest(payload);
        assertSuccess();
    }
}