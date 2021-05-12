@isTest
private class CWSIdentityKeySetResourceTest {

    private static void runTest(boolean startStopTest) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/identity/v1/keys';
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        if (startStopTest) Test.startTest();
        CWSIdentityKeySetResource.keys();
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
    
    private static void assertSuccess() {
        RestResponse res = RestContext.response;
        
        System.assertNotEquals(null,res,'HTTP Response - valid request should produce a response');
        System.assertNotEquals(null,res.responseBody,'HTTP Response - valid request should NOT produce an empty response body');
        System.assertNotEquals(null,res.headers,'HTTP Response - headers');
        System.assertEquals('application/json',res.headers.get('Content-Type'),'Content-Type response header');
        System.assertEquals(200,res.statusCode,'HTTP response status code');
       
        CWSIdentityResponse.KeySetResponse keySetResponse = (CWSIdentityResponse.KeySetResponse)
            JSON.deserialize(res.responseBody.toString(),CWSIdentityResponse.KeySetResponse.class);
        System.assertNotEquals(null,keySetResponse);
        System.assertNotEquals(null,keySetResponse.keys,'JWKeySet');  
    }
    

    @isTest static void testLoginWithEmptyRequest() {
        runTest(true);
        assertSuccess();
    }
}