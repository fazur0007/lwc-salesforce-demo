public class CWSIdentityRequest {
    
   @TestVisible private static String EXPERIENCE_ID = 'experience_id';
   @TestVisible private static String APP_ID = 'app_id';
   @TestVisible private static String LOGIN_NAME = 'username';
   @TestVisible private static String PASSWORD = 'password';
   @TestVisible private static String USER = 'user_id';
   @TestVisible private static String REFRESH_TOKEN = 'refresh_token';
   @TestVisible private static String ACCESS_TOKEN = 'access_token';
   @TestVisible private static String PASSWORD_RESET_TOKEN = 'password_reset_token';
   @TestVisible private static String EMAIL_VERIFICATION_TOKEN = 'email_verification_token';
   @TestVisible private static String NEW_PASSWORD = 'new_password';
   
  
   private Enum ItemType {ATTRIBUTE, PARAMETER, ARGUMENT}
   
   private static Map<Type,Set<String>> requiredAttributes = new Map<Type,Set<String>>{
       LoginRequest.class => new Set<String>{EXPERIENCE_ID,APP_ID,LOGIN_NAME,PASSWORD},
       RegistrationRequest.class => new Set<String>{EXPERIENCE_ID,APP_ID,LOGIN_NAME,PASSWORD},
       ReauthorizationRequest.class => new Set<String>{REFRESH_TOKEN,APP_ID}
   };
       

   private static String getAttribute(String name, Map<String,Object> attributes) {
         Object value = attributes.get(name);
         if (value != null && !(value instanceof String))
              throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,
                     String.format('Attribute {0} with a value of {1} is expected to be a JSON string', 
                         new List<Object>{name,value}));   
                         
         return (String)value;
    }
         
    private static Integer getAttributeAsInteger(String name, Map<String,Object> attributes) {
         Object value = attributes.get(name);
         if (value != null && !(value instanceof Integer))
              throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,
                     String.format('Attribute {0} with a value of {1} is expected to be a JSON number that is an integer', 
                         new List<Object>{name,value}));   
                         
         return (Integer)value;
    }
    
    private static List<Object> getAttributeAsList(String name, Map<String,Object> attributes) {
        List<Object> value = (List<Object>)attributes.get(name);
        if (value == null)
            throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,
           String.format('Attribute {0} with a value of {1} is expected to be a List', 
            new List<Object>{name,value}));   
        
        return value;
    }
    
    private static void verifyRequiredItem(ItemType itemType, String name, Object value) {
        if (value == null || (value instanceof String && String.isBlank((String)value)))
             throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,
                 String.format('{0} {1} is required yet its value was not found', 
                     new List<Object>{itemType.name(),name}));
    }

    private abstract class BaseRequest {
         protected Map<String,Object> attributes;
         
       
         BaseRequest(Map<String,Object> attributes, Type t) {
             verifyRequiredAttributes(requiredAttributes.get(t),attributes);
             this.attributes = attributes;
         }
         BaseRequest(String payload, Type t) {
              this((Map<String,Object>)JSON.deserializeUntyped(payload),t);
         }
         
         String getAttribute(String name) {
             return getAttribute(name,attributes);
         }
         
         Integer getAttributeAsInteger(String name) {
              return getAttributeAsInteger(name,attributes);    
         }
        
        List<Object> getAttributeAsList(String name) {
            return getAttributeAsList(name,attributes);    
        }
         
         private void verifyRequiredAttributes(Set<String> requiredAttributes, Map<String,Object> values) {
             if (requiredAttributes != null)
                 for(String attribute : requiredAttributes) 
                     verifyRequiredItem(ItemType.Attribute,attribute,values.get(attribute));
         }
     }
     
    public class RegistrationRequest extends RegistrationOrLoginRequest { 
        public RegistrationRequest(String payload) {
            super(payload,RegistrationRequest.class);
        }
    }
    
    public class LoginRequest extends RegistrationOrLoginRequest {
        public LoginRequest (String payload) {
            super(payload,LoginRequest.class);
        }
    }
     
    public abstract class RegistrationOrLoginRequest extends BaseRequest {
        
       public String experienceId {get;private set;}
       public String appId {get;private set;}
       public String loginName {get;private set;}
       public String password {get;private set;}

       public RegistrationOrLoginRequest(String payload, Type t) {
           super(payload,t);
           
           this.experienceId = getAttribute(EXPERIENCE_ID);
           this.appId = getAttribute(APP_ID);
           this.loginName = getAttribute(LOGIN_NAME);
           this.password = getAttribute(CWSIdentityRequest.PASSWORD);
       }
     
    }
    
    public class ReauthorizationRequest extends BaseRequest {
        
       public String refreshToken {get; private set;}
       public String appId {get; private set;}

       public ReauthorizationRequest(String payload) {
           super(payload,ReauthorizationRequest.class);
           
           this.appId = getAttribute(APP_ID);
           this.refreshToken = getAttribute(REFRESH_TOKEN);
       }
    }
    
    public class EmailVerificationRequest {
     
       public String emailVerificationToken {get;private set;}
       
       public EmailVerificationRequest(CWSIdentityToken token) {
           this(token.value,false);
       }
       
       public EmailVerificationRequest(String tokenValue, boolean notUsed) {
           verifyRequiredItem(ItemType.ATTRIBUTE,EMAIL_VERIFICATION_TOKEN,tokenValue);
           this.emailVerificationToken = tokenValue;
       }
       
       public EmailVerificationRequest(Map<String,Object> request) {
           this(CWSIdentityRequest.getAttribute('token',request),false);
       }

       public EmailVerificationRequest(String payload) {
            this((Map<String,Object>)JSON.deserializeUntyped(payload)); 
       }
     }
     
    public class PasswordResetCompletionRequest {
     
       public String passwordResetToken {get;private set;}
       public String password {get;private set;}
       
       public PasswordResetCompletionRequest (String token, String newPassword ) {
           verifyRequiredItem(ItemType.ATTRIBUTE,PASSWORD_RESET_TOKEN,token); 
           verifyRequiredItem(ItemType.ATTRIBUTE,NEW_PASSWORD,newPassword);  
           
           this.passwordResetToken  = token; 
           this.password = newPassword;
       }
     }
     
     
    public class PasswordResetInitiationRequest {
      
       public String loginName {get;private set;}
       public String experienceId {get; private set;}
       public String appId {get; private set;}
     
       public PasswordResetInitiationRequest(String loginName, String experienceId, String appId) {
           verifyRequiredItem(ItemType.ATTRIBUTE,LOGIN_NAME,loginName); 
           verifyRequiredItem(ItemType.ATTRIBUTE,EXPERIENCE_ID,experienceId);  
           verifyRequiredItem(ItemType.ATTRIBUTE,APP_ID,appId);  
           
           this.loginname = loginName; 
           this.experienceId = experienceId;
           this.appId = appId;
       }
       
       private PasswordResetInitiationRequest (Map<String,Object> request) {
           this(CWSIdentityRequest.getAttribute(LOGIN_NAME,request),
           CWSIdentityRequest.getAttribute(EXPERIENCE_ID,request),
            CWSIdentityRequest.getAttribute(APP_ID,request)
           );
       }
       
       public PasswordResetInitiationRequest (String payload) {
          this((Map<String,Object>)JSON.deserializeUntyped(payload));
       }
       
     }
}