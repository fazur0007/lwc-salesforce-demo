public class CWSIdentityResponse {

   private static String TRACE_ID = 'trace_id';
   private static String ACCESS_TOKEN = 'access_token';
   private static String REFRESH_TOKEN = 'refresh_token';
   private static String NAME = 'name';
   private static String EMAIL_VERIFIED = 'email_verified';
   private static String PERSON_ID = 'person_id';
   private static String ISSUED_AT = 'iat';

    public interface JsonView {
        String asJson();
    }

    private abstract class BaseResponse implements JsonView {
        
        public String asJson () {
            return JSON.serialize(this,true); // suppress null values
        }
    }
    
    private abstract class IdTokenResponse extends BaseResponse {
    
        public String id_token {get;private set;}
    
        public IdTokenResponse(String traceId, String audience, CWSIdentityUser u, Map<String,Object> claims) {
            System.debug(String.format('Building ID token for audience = {0} user = {1} claims = {2} [{3}]',
                new List<Object>{audience,u.Id,claims,traceId}));
            this.id_token = buildIdToken(audience,u,claims);
        }
        
        private String buildIdToken(String audience,CWSIdentityUser u,Map<String,Object> claims) {
            Auth.JWT jwt = new Auth.JWT();
           
            jwt.setIss(URL.getOrgDomainUrl().toExternalForm());
            jwt.setSub(u.Id);
            jwt.setAud(audience);
            jwt.setValidityLength(600);
            claims.put(ISSUED_AT,DateTime.now().getTime()); 
            
            jwt.setAdditionalClaims(claims);
            
            Auth.JWS signedToken = new Auth.JWS(jwt, CWSIdentityConfiguration.getInstance().tokenSigningCertificate);
            return signedToken.getCompactSerialization();
        }
    }
    
     public virtual class ErrorResponse extends BaseResponse {
    
        public String message {get; private set;}
        public String error_code {get; private set;}
        public String user_id {get; private set;}
       
        public ErrorResponse (String aTraceId, Exception e) {
           this(aTraceId,
               e instanceof CWSIdentityException ? ((CWSIdentityException)e).messageCode : CWSIdentityException.INVALID_REQUEST,
               e.getMessage(),
               e instanceof CWSIdentityPasswordPolicyException ? ((CWSIdentityPasswordPolicyException)e).userId: null
               );
        }
        
        public ErrorResponse(String aTraceId, String message) {
            this(aTraceId,CWSIdentityException.INVALID_REQUEST,message,null);
        }
        
        private ErrorResponse (String aTraceId, String code, String message, String userId) {
            this.error_code = code;
            this.message = message;
            this.user_id = userId;
        }
   
    }
    
     public class LoginResponse extends IdTokenResponse {
    
        public LoginResponse(String aTraceId, String client, CWSIdentityUser u, String accessToken, CWSIdentityToken refreshToken) {
           super(aTraceId,client,u,
               new Map<String,Object> {
                   ACCESS_TOKEN => accessToken,
                   REFRESH_TOKEN => refreshToken.value,
                   NAME => u.name,
                   EMAIL_VERIFIED => u.emailVerified,
                   PERSON_ID => u.personId
               }
           );
        }       
     }
     
     public class RegistrationResponse extends IdTokenResponse {
    
        public RegistrationResponse(String aTraceId, String client, CWSIdentityUser u) {
           super(aTraceId,client,u,
               new Map<String,Object> {
                   PERSON_ID => u.personId
               }
           );
        }       
     }
     
    public class ReauthorizationResponse extends IdTokenResponse {
     
        public ReauthorizationResponse(String aTraceId, String client, String accessToken, CWSIdentityToken refreshToken) 
        {
               super(aTraceId,client,refreshToken.issuedTo(),
                   new Map<String,Object> {
                       ACCESS_TOKEN => accessToken,
                       REFRESH_TOKEN => refreshToken.value
                   }
               );
        }       
    }
     
    public class KeySetResponse extends BaseResponse {
     
        public List<CWSIdentityKeySet.JWK> keys {get; private set;}
    
        public KeySetResponse(CWSIdentityKeySet keySet) {
            this.keys = keySet.keys;
        }   
     }
}