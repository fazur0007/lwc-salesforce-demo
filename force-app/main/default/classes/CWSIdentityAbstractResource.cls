public abstract class CWSIdentityAbstractResource {

    private static final String AMZN_TRACE_ID_HEADER = 'X-Amzn-Trace-Id';
    private static final String TRACE_ID_HEADER = 'X-Breville-Trace-Id';

    private static final Map<Type,CWSIdentityEvent.Service> typesToServiceNames = new Map<Type,CWSIdentityEvent.Service>
    {   
        CWSIdentityEmailVerificationResource.class => CWSIdentityEvent.Service.VERIFY_EMAIL,
        CWSIdentityLoginResource.class => CWSIdentityEvent.Service.LOGIN,
        CWSIdentityPasswordResetInitResource.class => CWSIdentityEvent.Service.FORGOT_PASSWORD_INITIATE_RESET,
        CWSIdentityRegistrationResource.class => CWSIdentityEvent.Service.REGISTRATION,
        CWSIdentityKeySetResource.class => CWSIdentityEvent.Service.PUBLIC_KEYS
    };
    
   
    public static String getServiceName(Type t) {
        return t.getName();
    }

    public static DateTime initialize() {
    
        DateTime receivedAt = DateTime.now();
        RestContext.response.addHeader('Content-Type', 'application/json');
        return receivedAt;
    }
    
    public static String acquireTraceId() {
    
        String amznTraceId = RestContext.request.headers.get(AMZN_TRACE_ID_HEADER);
        String traceId = amznTraceId == null ? new Uuid().getValue() : amznTraceId;
        RestContext.response.addHeader(TRACE_ID_HEADER, traceId);
        return traceId;
    }
    
    public static Map<String,String> validateRequestParameters() {
        
        RestRequest req = RestContext.request;

        if (req.params == null || req.params.size() < 1)
          throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,'No request parameters have been found');
   
        return req.params;
    }
    
    public static String validatePayload() {
        
        RestRequest req = RestContext.request;

        if (req.requestBody == null || req.requestBody.size() < 1)
          throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,'Request body is empty');
   
        return req.requestBody.toString(); 
    }
    
    public static void log(String traceId, Type resourceClass, DateTime receivedAt)
    {
        System.debug(String.format('HTTP request/response: resource = {0}, source IP = {1}, method = {2}, URI = {3}, params = {4}, ' +
            'request = {5}, received at = {6}, response = {7}, response status = {8} [{9}]',
            new List<Object>{
            resourceClass.getName(),
            RestContext.request.remoteAddress,
            RestContext.request.httpMethod,
            RestContext.request.requestURI,
            RestContext.request.params,
            RestContext.request.requestBody,
            receivedAt,
            RestContext.response.responseBody,
            DateTime.now(),
            RestContext.response.statusCode,
            traceId}));
       
         log(traceId,
            resourceClass.getName(),
            RestContext.request.remoteAddress,
            RestContext.request.httpMethod,
            RestContext.request.requestURI,
            RestContext.request.params,
            RestContext.request.requestBody,
            receivedAt,
            RestContext.response.responseBody,
            DateTime.now(),
            RestContext.response.statusCode); 
         
    }
    
    
    @future
    private static void log(
        String traceId,
        String resourceClass, 
        String sourceIP,
        String requestMethodName,
        String requestURI,
        Map<String,String> requestParams,
        Blob requestBody, 
        Datetime receivedAt, 
        Blob responseBody, 
        Datetime respondedAt, 
        Integer responseStatusCode) 
    {
         
         String parentSegmentId = null, rootTraceId = traceId;
         if (!String.isBlank(traceId) && traceId.startsWith('Root=')) {
             rootTraceId = traceId.substringBetween('Root=',';');
             parentSegmentId = traceId.substringBetween('Parent=',';');
         }

       CWSIdentityEvent.Service service = typesToServiceNames.get(Type.forName(resourceClass));
       CWSIdentityEvent.RequestMethod requestMethod = CWSIdentityEvent.getRequestMethod(requestMethodName);
       CWSIdentityEvent evt = new CWSIdentityEvent(
           rootTraceId,
           parentSegmentId,
           service,
           sourceIP,
           requestMethod,
           requestURI,
           requestParams,
           requestBody,
           receivedAt, 
           responseBody, 
           respondedAt, 
           responseStatusCode);
       CWSIdentityEventLog.logInboundRESTCall(evt);
    } 
}