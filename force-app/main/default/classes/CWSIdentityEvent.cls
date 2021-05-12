public class CWSIdentityEvent {

public Enum RequestMethod { GET,PUT,POST,PATCH }
    
    private static Map<String,RequestMethod> requestMethods = new Map<String,RequestMethod>{
        RequestMethod.GET.name() => RequestMethod.GET,
        RequestMethod.PUT.name() => RequestMethod.PUT,
        RequestMethod.POST.name() => RequestMethod.POST,
        RequestMethod.PATCH.name() => RequestMethod.PATCH
    };
    
    public Enum Topic { ALL, NONE, ALL_FAILURES}

    public Enum Service { REGISTRATION, LOGIN, FORGOT_PASSWORD_INITIATE_RESET, FORGOT_PASSWORD_COMPLETE_RESET, 
        VERIFY_EMAIL, PUBLIC_KEYS}
        
    public Enum Source { REMOTE_CLIENT, IDENTITY_SERVICES}
    private static Map<Source,String> sources = new Map<Source,String>{
        Source.REMOTE_CLIENT => 'remote_client',
        Source.IDENTITY_SERVICES => 'sf_identity'
    };
    
    public Enum Destination {IDENTITY_SERVICES}
    private static Map<Destination,String> destinations = new Map<Destination,String>{
        Destination.IDENTITY_SERVICES => 'sf_identity'
    };
    
    
    private static Map<Service,String> services = new Map<Service,String>{
        Service.REGISTRATION => 'register',
        Service.LOGIN => 'login',
        Service.FORGOT_PASSWORD_INITIATE_RESET => 'forgot_password_initiate_reset',
        Service.FORGOT_PASSWORD_COMPLETE_RESET => 'forgot_password_complete_reset',
        Service.VERIFY_EMAIL => 'verify_email',
        Service.PUBLIC_KEYS => 'public_keys'
    };
   
    
    public static RequestMethod getRequestMethod(String aMethod) {
        return requestMethods.get(aMethod);
    }
    
    public static String getServiceName(Service service) {
        return services.get(service);
    }
   
    
    public String traceId {get; private set;}    
    public String parentSegmentId {get; private set;}
    public Service service {get; private set;}
    public String sourceIP {get; private set;}
    public RequestMethod requestMethod {get; private set;}
    public String requestURI {get; private set;}
    public Map<String,String> requestParams {get; private set;}
    public Blob requestBody {get; private set;}
    public Blob responseBody {get; private set;}
    public String responseFailureRootCause {get; private set;}
    public DateTime requestedAt {get; private set;}
    public DateTime respondedAt {get; private set;}
    public Integer responseStatusCode {get; private set;}
    
    public CWSIdentityEvent(String aTraceId, String aParentSegmentId, Service service, HttpRequest request, DateTime requestedAt, Exception ex) {
        this(
            aTraceId,
            aParentSegmentId,
            service,
            null,
            getRequestMethod(request.getMethod()),
            request.getEndpoint(),
            null,
            request.getBodyAsBlob(),
            requestedAt, 
            ex,
            DateTime.now());
    }
    
    public CWSIdentityEvent(String aTraceId, String aParentSegmentId, Service service, HttpRequest request, DateTime requestedAt, HttpResponse response) {
        this(
            aTraceId,
            aParentSegmentId,
            service,
            null,
            getRequestMethod(request.getMethod()),
            request.getEndpoint(),
            null,
            request.getBodyAsBlob(),
            requestedAt, 
            response.getBodyAsBlob(), 
            DateTime.now(),
            response.getStatusCode());
    }
    
    private CWSIdentityEvent(String aTraceId, String aParentSegmentId,
        Service aService, 
        String sourceIP,
        RequestMethod requestMethod,
        String requestURI,
        Map<String,String> requestParams,
        Blob aRequestBody, 
        DateTime aRequestedAt,
        DateTime aRespondedAt
        )
    {
        this.traceId = aTraceId;
        this.parentSegmentId = aParentSegmentId;
        this.service = aService;
        this.sourceIP = sourceIP;
        this.requestMethod = requestMethod;
        this.requestURI = requestURI;
        this.requestParams = requestParams;
        this.requestBody = aRequestBody;
        this.requestedAt = aRequestedAt;
        this.respondedAt = aRespondedAt;
    }

    public CWSIdentityEvent(String aTraceId, String aParentSegmentId,
        Service aService, 
        String sourceIP,
        RequestMethod requestMethod,
        String requestURI,
        Map<String,String> requestParams,
        Blob aRequestBody, 
        Datetime aRequestedAt, 
        Blob aResponseBody, 
        Datetime aRespondedAt, 
        Integer aResponseStatusCode) 
    {
        this(aTraceId,aParentSegmentId,aService,sourceIP,requestMethod,requestURI,requestParams,aRequestBody,aRequestedAt,aRespondedAt);
        
        this.responseBody= aResponseBody;
        this.responseStatusCode = aResponseStatusCode;
    }
    
     public CWSIdentityEvent(String aTraceId, String aParentSegmentId,
        Service aService, 
        String sourceIP,
        RequestMethod requestMethod,
        String requestURI,
        Map<String,String> requestParams,
        Blob aRequestBody, 
        Datetime aRequestedAt,
        Exception responseFailureRootCauseException,
        Datetime aRespondedAt)
    {
        this(aTraceId,aParentSegmentId,aService,sourceIP,requestMethod,requestURI,requestParams,aRequestBody,aRequestedAt,aRespondedAt);
        this.responseFailureRootCause = responseFailureRootCauseException.getMessage();

    }
    
    public String getServiceName() {
        return services.get(this.service);
    }
    
    public String getSourceName(Source source) {
        return sources.get(source);
    }
    
    public String getDestinationName(Destination destination) {
        return destinations.get(destination);
    }
    
    public boolean hasResponseFailureRootCause() { return !String.isBlank(responseFailureRootCause); }
    
    public boolean isError() {
        switch on service {
            when REGISTRATION {
                return responseStatusCode != 201;   
            }
            when VERIFY_EMAIL {
                return responseStatusCode != 301;
            }
            when else {
                return responseStatusCode != 200;   
            }
        }
    }
        
    public boolean accept(Topic topic,Destination target) {
        switch on topic {
            when ALL_FAILURES {
                return (hasResponseFailureRootCause() || isError());
            }
            when NONE {
                return false;
            }
            when else {
                return true;
            }
        }
    }    
}