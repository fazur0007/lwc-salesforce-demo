@RestResource(urlMapping='/identity/v1/keys')
global with sharing class CWSIdentityKeySetResource extends CWSIdentityAbstractResource {

    @HttpGet
    global static void keys() {
      doWork();
    }
    
    public static void doWork() {
            
        DateTime receivedAt = initialize();
        String traceId = acquireTraceId();
        RestResponse res = RestContext.response;
        String responsePayload = null;
        String requestPayload = null;
       
       try {
           responsePayload = processRequest(traceId);
           RestContext.response.statusCode = 200;
        }
        catch (Exception ex) {
            res.statusCode = 400;
            responsePayload = new CWSIdentityResponse.ErrorResponse(traceId,ex).asJson();
        }
       
        RestContext.response.responseBody = Blob.valueOf(responsePayload);
        log(traceId,CWSIdentityKeySetResource.class,receivedAt);
    }
    
    public static String processRequest(String traceId) {
        CWSIdentityResponse.KeySetResponse res = CWSIdentityService.getInstance(traceId).renderKeySet();
        return res.asJson();
    } 
}