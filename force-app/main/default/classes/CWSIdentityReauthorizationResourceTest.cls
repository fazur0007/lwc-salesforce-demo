@isTest 
private class CWSIdentityReauthorizationResourceTest {


    @isTest 
    static void  testCWSIdentityReauthorizationResource() {

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/identity/v1/register';
        req.httpMethod = 'POST';
         String password = CWSIdentityUserTestDataFactory.VALID_PASSWORD;
        
        String payload = '{"refresh_token":' + '"adfasdf"' + ',"app_id":"blah"}';
        if (payload != null)
            req.requestBody = Blob.valueOf(payload);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CWSIdentityReauthorizationResource.doWork();
        Test.stopTest();
        
        System.debug('REST Response: ' + RestContext.response);
        if (RestContext.response.responseBody != null)
            System.debug('REST Response - body: ' + RestContext.response.responseBody.toString());
    }
}