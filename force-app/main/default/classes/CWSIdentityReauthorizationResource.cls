@RestResource(urlMapping='/identity/v1/reauthorize')
global with sharing class CWSIdentityReauthorizationResource extends CWSIdentityAbstractResource {

    @HttpPost
    global static void reauthorizeUser() {
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
        log(traceId,CWSIdentityReauthorizationResource.class,receivedAt);
    }
    
    public static String processRequest(String traceId, String payloadString) {
        CWSIdentityRequest.ReauthorizationRequest req = new CWSIdentityRequest.ReauthorizationRequest(payloadString);
        CWSIdentityResponse.ReauthorizationResponse res = CWSIdentityService.getInstance(traceId).reauthorize(req);
    
        RestContext.response.statusCode = 200;
        return res.asJson();
    }
    
}