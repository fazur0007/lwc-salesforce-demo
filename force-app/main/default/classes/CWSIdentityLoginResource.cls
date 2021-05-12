@RestResource(urlMapping='/identity/v1/login')
global with sharing class CWSIdentityLoginResource extends CWSIdentityAbstractResource {

    @HttpPost
    global static void login() {
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
        log(traceId,CWSIdentityLoginResource.class,receivedAt);
    }
    
    public static String processRequest(String traceId, String payloadString) {
        CWSIdentityRequest.LoginRequest req = new CWSIdentityRequest.LoginRequest(payloadString);
        CWSIdentityResponse.LoginResponse res = CWSIdentityService.getInstance(traceId).authenticateUser(req);
    
        RestContext.response.statusCode = 200;
        return res.asJson();
    }
    
}