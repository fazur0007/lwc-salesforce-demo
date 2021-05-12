@RestResource(urlMapping='/identity/v1/verify_email')
global with sharing class CWSIdentityEmailVerificationResource extends CWSIdentityAbstractResource {

    private Enum ResponseStatus {FAIL, OK}
    
    private static Map<ResponseStatus,String> responseStatusToString = new Map<ResponseStatus,String> {
        ResponseStatus.FAIL => 'FAILURE',
        ResponseStatus.OK => 'SUCCESS'
    };

    @HttpGet
    global static void verifyEmail() {
      doWork();
    }
    
    public static void doWork() {
            
        DateTime receivedAt = initialize();
        String traceId = acquireTraceId();
        RestResponse res = RestContext.response;
        String responsePayload = null;
        Map<String,Object> requestPayload = null;
        
       try {
           requestPayload = validateRequestParameters();
           processRequest(traceId,requestPayload);
        }
        catch (Exception ex) {
            respond(ResponseStatus.FAIL);
        }
        log(traceId,CWSIdentityEmailVerificationResource.class,receivedAt);
    }
    
    public static void processRequest(String traceId, Map<String,Object> payloadString) {
        CWSIdentityRequest.EmailVerificationRequest req = new CWSIdentityRequest.EmailVerificationRequest(payloadString);
        CWSIdentityService.getInstance(traceId).verifyEmail(req);
        respond(ResponseStatus.OK);
    }
    
    private static void respond(ResponseStatus status) {

        String baseURL =  CWSIdentityConfiguration.getInstance().verifyEmailLandingPageBaseURL.toExternalForm();
        String destination = String.format(baseURL+'/CWSEmailVerification?Status={0}&experience_id=app',
                new List<Object>{responseStatusToString.get(status)});
                
        RestContext.response.statusCode = 301;
        RestContext.response.addHeader('Location',destination);
        RestContext.response.addHeader('http-equiv','refresh');    
    }
}