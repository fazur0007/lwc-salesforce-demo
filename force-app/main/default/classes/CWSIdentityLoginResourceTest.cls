@isTest
private class CWSIdentityLoginResourceTest {

    private static void runTest(String payload) {
        runTest(payload,true);
    }

    private static void runTest(String payload, boolean startStopTest) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/identity/v1/login';
        req.httpMethod = 'POST';
        if (payload != null)
            req.requestBody = Blob.valueOf(payload);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        if (startStopTest) Test.startTest();
        CWSIdentityLoginResource.login();
        if (startStopTest) Test.stopTest();
        
        System.debug('REST response: ' + RestContext.response);
        System.debug('REST response body: ' + RestContext.response.responseBody.toString());
    }
    
    private static CWSIdentityResponse.ErrorResponse assertBadRequest(Integer expectedStatusCode, String expectedErrorCode) {
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
        return errorResponse;
    }
    
    private static void assertSuccess(CWSIdentityUser expectedUser) {
        RestResponse res = RestContext.response;
        
        System.assertNotEquals(null,res,'HTTP Response - valid request should produce a response');
        System.assertNotEquals(null,res.responseBody,'HTTP Response - valid request should NOT produce an empty response body');
        System.assertNotEquals(null,res.headers,'HTTP Response - headers');
        System.assertEquals('application/json',res.headers.get('Content-Type'),'Content-Type response header');
        System.assertEquals(200,res.statusCode,'HTTP response status code');
       
        CWSIdentityResponse.LoginResponse loginResponse = (CWSIdentityResponse.LoginResponse)
            JSON.deserialize(res.responseBody.toString(),CWSIdentityResponse.LoginResponse.class);
        System.assertNotEquals(null,loginResponse);
        System.assertNotEquals(null,loginResponse.id_token,'ID Token');  
    }
    
    private static String buildPayload(String username, String password, String appId, String expId) {
        return '{"' + CWSIdentityRequest.LOGIN_NAME + '":"' + username + 
            '","' + CWSIdentityRequest.PASSWORD + '":"' + password + 
            '","' + CWSIdentityRequest.APP_ID  + '":"' + appId + 
            '","' + CWSIdentityRequest.EXPERIENCE_ID  + '":"' + expId + '"}';
    }

    @isTest static void testLoginWithEmptyRequest() {
        runTest(null);
        assertBadRequest(400,CWSIdentityException.INVALID_REQUEST);
    }
    
    @isTest static void testLoginWithMalformedRequest() {
        CWSIdentityUser u = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        String payload ='{"foo":"bar",}';
        runTest(payload);
        assertBadRequest(400,CWSIdentityException.INVALID_REQUEST);
    }
    
    @isTest static void testLoginWithInvalidPassword() {
        CWSIdentityUser u = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed;
        List<String> appIds =  CWSIdentityConfiguration.getInstance().appIds();
        System.assertNotEquals(null,appIds);
        System.assert(appIds.size() > 0, 'Must have at least one client app');
        u.setEmailVerified();
        System.debug('THe username in test is:'+u.username);
        String payload = buildPayload(u.username,CWSIdentityUserTestDataFactory.INVALID_PASSWORD,
            appIds[0],CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID);
        runTest(payload);
        assertBadRequest(400,CWSIdentityException.PASSWORD_INVALID);
    }
    
}