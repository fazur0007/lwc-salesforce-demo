@RestResource(urlMapping='/identity/v1/init_password_reset')
global with sharing class CWSIdentityPasswordResetInitResource extends CWSIdentityAbstractResource {

    @HttpPost
    global static void initPasswordReset() {
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
           processRequest(traceId,requestPayload);
        }
        catch (Exception ex) {
            res.statusCode = 400;
            responsePayload = new CWSIdentityResponse.ErrorResponse(traceId,ex).asJson();
            res.responseBody = Blob.valueOf(responsePayload);
        }
        log(traceId,CWSIdentityPasswordResetInitResource.class,receivedAt);
    }
    
    public static void processRequest(String traceId, String payloadString) {
        CWSIdentityRequest.PasswordResetInitiationRequest req = 
            new CWSIdentityRequest.PasswordResetInitiationRequest(payloadString);
        CWSIdentityService.getInstance(traceId).initiatePasswordReset(req);
        RestContext.response.statusCode = 200;  
    }
}