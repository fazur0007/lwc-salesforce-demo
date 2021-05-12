@isTest
private class CWSIdentityRegistrationResourceTest {

    private static void runTest(String payload) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/identity/v1/register';
        req.httpMethod = 'POST';
        if (payload != null)
            req.requestBody = Blob.valueOf(payload);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CWSIdentityRegistrationResource.createUser();
        Test.stopTest();
        
        System.debug('REST Response: ' + RestContext.response);
        if (RestContext.response.responseBody != null)
            System.debug('REST Response - body: ' + RestContext.response.responseBody.toString());
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
    
    private static void assertSuccess(String expectedUserId) {
        RestResponse res = RestContext.response;
        
        System.assertNotEquals(null,res,'HTTP Response - valid request should produce a response');
        System.assertNotEquals(null,res.responseBody,'HTTP Response - valid request should NOT produce an empty response body');
        System.assertNotEquals(null,res.headers,'HTTP Response - headers');
        System.assertEquals('application/json',res.headers.get('Content-Type'),'Content-Type response header');
        System.assertEquals(201,res.statusCode,'HTTP response status code');
        
        CWSIdentityResponse.RegistrationResponse regResponse = (CWSIdentityResponse.RegistrationResponse)
            JSON.deserialize(res.responseBody.toString(),CWSIdentityResponse.RegistrationResponse.class);
        System.assertNotEquals(null,regResponse);
        System.assertNotEquals(null,regResponse.id_token,'ID Token');
    }
    
    @isTest static void testCreateUserWithEmptyRequest() {
        runTest(null);
        assertBadRequest(400,CWSIdentityException.INVALID_REQUEST);
    }
    
    @isTest static void testCreateUserWithMalformedRequest() {
        String password = CWSIdentityUserTestDataFactory.VALID_PASSWORD;
        
        String payload = '{"username":' + 123 + ',"password":"' + password + '"}';
        runTest(payload);
        assertBadRequest(400,CWSIdentityException.INVALID_REQUEST);
    }
    
    private static String buildPayload(String username, String password, String appId, String expId) {
        return '{"username":"' + username + '","password":"' + password + '","app_id":"' + appId + 
            '","experience_id":"' + expId + '"}';
    }
    
    @isTest static void testCreateUser() {
        String password = CWSIdentityUserTestDataFactory.VALID_PASSWORD;
        String username = CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME;
        List<String> appIds = CWSIdentityConfiguration.getInstance().appIds();
        System.assertNotEquals(null,appIds?.get(0),'At least one client app must be available');
        String appId = appIds[0];
        String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
        
        String payload = buildPayload(username,password,appId,expId);
        runTest(payload);
        CWSIdentityUser user = CWSIdentityUserRepository.getInstance().findOneByUsername(username);
        assertSuccess(user.id);
    }
    
    @isTest static void testCreateUserWithTakenUsername() {
    
        String username = CWSIdentityUserTestDataFactory.newlyRegisteredUser().observed.username;
        String password = CWSIdentityUserTestDataFactory.VALID_PASSWORD;
        List<String> appIds = CWSIdentityConfiguration.getInstance().appIds();
        System.assertNotEquals(null,appIds?.get(0),'At least one client app must be available');
        String appId = appIds[0];
        String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;

        String payload = buildPayload(username,password,appId,expId);
        runTest(payload);
        assertBadRequest(400,CWSIdentityException.USERNAME_ALREADY_EXISTS);
    }
    
    
    @isTest static void testCreateUserWithPolicyViolatingPassword() {
        
        String username = CWSIdentityUserTestDataFactory.VALID_LOGIN_NAME;
        String password = CWSIdentityUserTestDataFactory.INVALID_PASSWORD;
        List<String> appIds = CWSIdentityConfiguration.getInstance().appIds();
        System.assertNotEquals(null,appIds?.get(0),'At least one client app must be available');
        String appId = appIds[0];
        String expId = CWSIdentityUserTestDataFactory.VALID_EXPERIENCE_ID;
        
        String payload = buildPayload(username,password,appId,expId);
        runTest(payload);
        
        assertBadRequest(400,CWSIdentityException.PASSWORD_POLICY_VIOLATION);
    }
}