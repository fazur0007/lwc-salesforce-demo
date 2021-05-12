public class CWSIdentityAuthenticator {

    public enum AuthenticationOutcome {OK,InvalidPassword,ExpiredPassword,LockedPassword,FrozenUser,InactiveUser,
        PasswordPolicyViolationPasswordHistory,PasswordPolicyViolation}

    @TestVisible private final static String ENVELOPE_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    @TestVisible private final static String ENVELOPE_NS_PREFIX = 'SOAP-ENV';
    @TestVisible private final static String SF_PARTNER_NS = 'urn:partner.soap.sforce.com';
    @TestVisible private final static String SF_NS_PREFIX = 'ns1';
    private final static String SOAP_SERVICES_URI = '/services/Soap/u/50.0';
    private final static String endpoint = URL.getOrgDomainUrl().toExternalForm() + SOAP_SERVICES_URI;
    
     
    private CWSIdentityUserLoginRepository userLoginRepo;
    
    private static CWSIdentityAuthenticator INSTANCE = 
        new CWSIdentityAuthenticator(CWSIdentityUserLoginRepository.getInstance());
       

    public static CWSIdentityAuthenticator getInstance() {
        return instance;
    }


    private CWSIdentityAuthenticator(CWSIdentityUserLoginRepository userLoginRepo) {
        this.userLoginRepo = userLoginRepo;
    }
   
    
/*
-- Request --

<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:partner.soap.sforce.com">
  <SOAP-ENV:Header>
    <ns1:LoginScopeHeader>
      <ns1:organizationId>...</ns1:organizationId>
    </ns1:LoginScopeHeader>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:login>
      <ns1:username>...</ns1:username>
      <ns1:password>...</ns1:password>
    </ns1:login>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
*/
    private static dom.Document buildRequest() {
        dom.Document doc = new dom.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope',ENVELOPE_NS,ENVELOPE_NS_PREFIX);
        envelope.setNamespace(SF_NS_PREFIX, SF_PARTNER_NS);
        
        envelope
            .addChildElement('Header',ENVELOPE_NS,'SOAP-ENV')
            .addChildElement('LoginScopeHeader',SF_PARTNER_NS,SF_NS_PREFIX)
            .addChildElement('organizationId',SF_PARTNER_NS,SF_NS_PREFIX).addTextNode(UserInfo.getOrganizationId());
        
        dom.XmlNode login = envelope
            .addChildElement('Body',ENVELOPE_NS,ENVELOPE_NS_PREFIX)
            .addChildElement('login',SF_PARTNER_NS,SF_NS_PREFIX);
            
        login.addChildElement('username',SF_PARTNER_NS,SF_NS_PREFIX).addTextNode('{0}');
        login.addChildElement('password',SF_PARTNER_NS,SF_NS_PREFIX).addTextNode('{1}');
        return doc;
    }
    
    private static String buildPayload(String username, String password) {
        long startTime = System.currentTimeMillis();
        String aTemplate = null;
        if (!Test.isRunningTest()) {
            try {
                Cache.OrgPartition cache = Cache.Org.getPartition('local.identity');
                aTemplate = (String)cache.get(AuthenticationRequestCacheBuilder.class, CWSIdentityAuthenticator.class.toString());
            }
            catch(Exception e) {
                System.debug('Failed to retrieve an instance of CWSIdentityAuthenticator from cache: ' + e.getMessage());
            }
        }
        elapsedTime('buildPayload - retrieve template from cache',startTime);
        
        String template = aTemplate == null ? buildRequest().toXmlString() : aTemplate;
        System.debug('SOAP service request template: ' + template);
        startTime = System.currentTimeMillis();
        String payload = String.format(template,new List<Object>{username,password.escapeXml()});
        elapsedTime('buildPayload - interpolate variables into payload',startTime);
        return payload;
    }
    
    class AuthenticationRequestCacheBuilder implements Cache.CacheBuilder {
        public Object doLoad(String key) {
           return buildRequest().toXmlString();
        }
    }
    
    private static void elapsedTime(String operation, long startTime) {
        long elapsed = System.currentTimeMillis() - startTime;
        System.debug('ELAPSED TIME: operation ' + operation + ' took ' + elapsed + ' ms');
    }
    
    public AuthenticationResult authenticateUser(CWSIdentityUser user, String password) {
            return authenticateExternalIdentity(user,password);
    }
    
    public static AuthenticationOutcome isUserAuthConstrained(CWSIdentityUser user) {
    
        if (!user.isActive())
            return AuthenticationOutcome.InactiveUser;
        
        UserLogin ul = CWSIdentityUserLoginRepository.getInstance().findOneById(user.id);
        if (ul != null) {
            System.debug(String.format('UserLogin: frozen: {0} locked out: {1}',
                new List<Object>{ul.isFrozen,ul.isPasswordLocked}));
            if (ul.isFrozen)
                 return AuthenticationOutcome.FrozenUser;   
            else if (ul.isPasswordLocked)
                return AuthenticationOutcome.LockedPassword; 
        }
        return null;
    }
    
    
    private static AuthenticationResult authenticateExternalIdentity(CWSIdentityUser user, String password) {
    
        System.debug('Verifying password for ' + user);
              
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('SOAPAction', '""');
        request.setHeader('Content-Type', 'text/xml');
        request.setBody(buildPayload(user.username,password));

        try {
            long startTime = System.currentTimeMillis();
            HttpResponse response = new Http().send(request);
            elapsedTime('authenticateExternalIdentity - send/receive SOAP request/response',startTime);
            
            String responseBody = response.getBody();
            System.debug('Authentication reponse (SOAP payload): '+ responseBody);
            SoapEnvelope envelope = parseResponse(responseBody);
            return buildResult(envelope,user);
        }
        catch (Exception e) {
           System.debug(String.format('Failed to authenticate user {0} via a SOAP service endpoint at {1}: {2}',
               new List<Object>{user.id,endpoint,e.getMessage()}));
           return new AuthenticationResult(e);
        }
    }
    
    private static AuthenticationResult buildResult(SoapEnvelope envelope,CWSIdentityUser user) {
        if (envelope.fault != null) {
            System.debug(LoggingLevel.ERROR,String.format('Failed to authenticate user {0}: {1}',
                new List<Object>{user.id,envelope.fault}));
            AuthenticationOutcome constraints = isUserAuthConstrained(user);
            
            AuthenticationResult result = constraints != null ?
                new AuthenticationResult(constraints,envelope.fault) : 
                new AuthenticationResult(envelope.fault);
            System.debug('Authentication result: ' + result);
            return result;
        }
        return (envelope.passwordExpired != null && envelope.passwordExpired) ?
            new AuthenticationResult(AuthenticationOutcome.ExpiredPassword,null,null) :
            new AuthenticationResult(AuthenticationOutcome.OK,null,envelope.sessionId);
     }
    
    
    public class AuthenticationResult {
    
        public AuthenticationOutcome status {get;private set;}
        public String sessionId {get;private set;}
        public String message {get;private set;}
              
        private AuthenticationResult(AuthenticationOutcome status, String message, String sessionId) {
            this.status = status;
            this.message = message;
            this.sessionId = sessionId;
        }
        
        private AuthenticationResult(AuthenticationOutcome status,SoapFault fault) {
            this(status,fault.message != null ? fault.message : 'Authentication failed',null);
        }
        
        private AuthenticationResult(SoapFault fault) {
            this(AuthenticationOutcome.InvalidPassword,fault);
        }
        
        public AuthenticationResult(Exception e) {
            this(AuthenticationOutcome.InvalidPassword,e.getMessage(),null);
        }
       
    }
    
/*
-- Response --
OK:
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <soapenv:Body>
        <loginResponse>
            <result>
                <passwordExpired>false</passwordExpired>
                ...
            </result>
        </loginResponse>
      </soapenv:Body>
    </soapenv:Envelope>
     
FAIL:
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <soapenv:Body>
        <soapenv:Fault>
            <faultcode>sf:INVALID_LOGIN</faultcode>
            <faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring>
            <detail>
                <sf:LoginFault xsi:type="sf:LoginFault">
                    <sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode>
                    <sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage>
                </sf:LoginFault>
            </detail>
        </soapenv:Fault>
      </soapenv:Body>
    </soapenv:Envelope>|           
*/
    private static SoapEnvelope parseResponse(String xml) {
        
        System.debug('Parsing XML: ' + xml);
        
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.XmlNode envelope = doc.getRootElement(); 
        Dom.XmlNode body = envelope.getChildElement('Body',ENVELOPE_NS);
       
        Dom.XmlNode fault = body.getChildElement('Fault',ENVELOPE_NS);
        if (fault != null) return new SoapEnvelope(new SoapFault(fault));
       
        Dom.XmlNode result = body.getChildElement('loginResponse',SF_PARTNER_NS)?.getChildElement('result',SF_PARTNER_NS);
        Dom.XmlNode passwordExpiredXmlNode = result?.getChildElement('passwordExpired',SF_PARTNER_NS);
        String sessionId = result?.getChildElement('sessionId',SF_PARTNER_NS)?.getText();
        
        Boolean passwordExpired = passwordExpiredXmlNode?.getText() != null ? 
            Boolean.valueOf(passwordExpiredXmlNode?.getText()) : Boolean.valueOf('false');
            
        System.debug('Parsed passwordExpired: ' + passwordExpired + ' and sessionId: ' + sessionId);
              
        return new SoapEnvelope(passwordExpired,sessionId);
    }
    
    private class SoapEnvelope {
        public SoapFault fault {get; private set;}
        public Boolean passwordExpired {get; private set;}
        public String sessionId {get; private set;}
        
        public SoapEnvelope(SoapFault fault) {
            this.fault = fault;
        }
        
        public SoapEnvelope(Boolean passwordExpired, String sessionId) {
            this.passwordExpired = passwordExpired;    
            this.sessionId = sessionId;   
        }
    }
    
    private class SoapFault {
        public String code {get;private set;}
        public String message {get;private set;}
       
        public SoapFault(Dom.XmlNode fault) {
        
            this.code = fault.getChildElement('faultcode',null)?.getText();
            this.message = fault.getChildElement('faultstring',null)?.getText();
        }
    }

}