@RestResource(urlMapping='/identity/v1/register')
global with sharing class CWSIdentityRegistrationResource extends CWSIdentityAbstractResource {

    @HttpPost
    global static void createUser() {
      doWork();
    }
    
    public static void doWork() {
            
        DateTime receivedAt = initialize();
        String traceId = acquireTraceId();
        RestResponse res = RestContext.response;
        String responsePayload = null;
        String requestPayload = null;
       
       try {
           requestPayload = validatePayload();
           responsePayload = processRequest(traceId,requestPayload);
        }
        catch (Exception ex) {
            res.statusCode = 400;
            responsePayload = new CWSIdentityResponse.ErrorResponse(traceId,ex).asJson();
        }
       
        RestContext.response.responseBody = Blob.valueOf(responsePayload);
        log(traceId,CWSIdentityRegistrationResource.class,receivedAt);
    }
    
    public static String processRequest(String traceId, String payloadString) {
        CWSIdentityRequest.RegistrationRequest req = new CWSIdentityRequest.RegistrationRequest(payloadString);
        CWSIdentityResponse.RegistrationResponse res = CWSIdentityService.getInstance(traceId).createUser(req);
    
        RestContext.response.statusCode = 201;
        return res.asJson();
    }
    
}