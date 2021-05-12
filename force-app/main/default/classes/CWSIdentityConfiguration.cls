global with sharing class CWSIdentityConfiguration {

    private static final String DEFAULT_CONFIGURATION_SET_NAME = 'master';

    private static final CWSIdentityConfiguration INSTANCE = 
        new CWSIdentityConfiguration(DEFAULT_CONFIGURATION_SET_NAME);
   
    // Constants
    public Enum TimeUnit { MINUTES, HOURS, DAYS }
    private Map<String,TimeUnit> unitsOfTime = 
        new Map<String,TimeUnit> {
           'minutes' =>  TimeUnit.MINUTES,
           'hours' => TimeUnit.HOURS , 
           'days' => TimeUnit.DAYS
       };
       
    private Map<String,CWSIdentityEvent.Topic> eventLoggingTopics = new Map<String,CWSIdentityEvent.Topic> {
        'ALL' => CWSIdentityEvent.Topic.ALL,
        'NONE' => CWSIdentityEvent.Topic.NONE,
        'ALL_FAILURES' => CWSIdentityEvent.Topic.ALL_FAILURES
    };
    
    // User defaults
    public Id community {get; private set;} // community that owns (hosts) the External Identity user records
    @TestVisible private String serviceAccount;
    
    // Token semantics
    public Integer passwordResetTokenExpirationDuration {get;private set;}
    public TimeUnit passwordResetTokenExpirationDurationUnits {get;private set;}
    public Integer emailVerificationTokenExpirationDuration {get;private set;}
    public TimeUnit emailVerificationTokenExpirationDurationUnits {get;private set;}
    public Integer redoEmailVerificationMaxAttempts {get; private set;}
    public Integer refreshTokenExpirationDuration {get;private set;}
    public TimeUnit refreshTokenExpirationDurationUnits {get;private set;}
    
    // Token signing
    public String tokenSigningCertificate {get; private set;}
    
    // User impersonation
    public String userImpersonationSigningCertificate {get; private set;}
    public String userImpersonationClientId {get; private set;}
    
    // Messaging
    private String forgotPasswordURLTemplate;
    private String verifyEmailURLTemplate;
    public URL verifyEmailBaseURL {get; private set;}
    public URL verifyEmailLandingPageBaseURL {get; private set;}
    
    // Event logging
    public CWSIdentityEvent.Topic eventLoggingTopic { get; private set; }
    @TestVisible private void setEventLoggingTopic(CWSIdentityEvent.Topic t) { this.eventLoggingTopic = t; }
    
    // Client apps
    private Map<String,CWSIdentityClientApplication> clientApps;
    
    private CWSIdentityConfiguration (String configurationSetName) {
        String myConfigurationSetName = configurationSetName == null ? DEFAULT_CONFIGURATION_SET_NAME : configurationSetName;
        
          Identity_Services__mdt configurationSet = [
            SELECT 
               Id,
               Password_Reset_Token_Expiration__c,
               Password_Reset_Token_Expiration_Units__c,
               Verify_Email_Token_Expiration__c,
               Verify_Email_Token_Expiration_Units__c,
               Refresh_Token_Expiration__c,
               Refresh_Token_Expiration_Units__c,
               Token_Signing_Certificate__c,
               User_Impersonation_Token_Signing_Cert__c,
               User_Impersonation_Client_Id__c,
               Forgot_Password_Base_URL__c,
               Forgot_Password_URI_Template__c,
               Verify_Email_Base_URL__c,
               Verify_Email_URI_Template__c,
               Service_Event_Logging_Topic__c,
               Community_Name__c,
               Service_Account__c
            FROM Identity_Services__mdt
            WHERE DeveloperName = :myConfigurationSetName
            LIMIT 1];
            
        // Token semantics
        this.passwordResetTokenExpirationDuration = configurationSet.Password_Reset_Token_Expiration__c.intValue();
        this.passwordResetTokenExpirationDurationUnits = 
            unitOfTime(configurationSet.Password_Reset_Token_Expiration_Units__c);
        this.emailVerificationTokenExpirationDuration = configurationSet.Verify_Email_Token_Expiration__c.intValue();
        this.emailVerificationTokenExpirationDurationUnits =  
            unitOfTime(configurationSet.Verify_Email_Token_Expiration_Units__c);
        this.refreshTokenExpirationDuration = configurationSet.Refresh_Token_Expiration__c.intValue();
        this.refreshTokenExpirationDurationUnits =  
            unitOfTime(configurationSet.Refresh_Token_Expiration_Units__c);
     
        // Token signing
        this.tokenSigningCertificate = configurationSet.Token_Signing_Certificate__c;
        this.userImpersonationSigningCertificate = configurationSet.User_Impersonation_Token_Signing_Cert__c;
        this.userImpersonationClientId = configurationSet.User_Impersonation_Client_Id__c;
          
        // Messaging
        this.forgotPasswordURLTemplate = configurationSet.Forgot_Password_Base_URL__c +
            configurationSet.Forgot_Password_URI_Template__c;
            
        this.verifyEmailBaseUrl =  new URL(configurationSet.Verify_Email_Base_URL__c);        
        this.verifyEmailURLTemplate = configurationSet.Verify_Email_Base_URL__c +
            configurationSet.Verify_Email_URI_Template__c;
        this.verifyEmailLandingPageBaseURL= new URL(configurationSet.Forgot_Password_Base_URL__c);
     
        // Event Logging
        this.eventLoggingTopic = eventLoggingTopics.containsKey(configurationSet.Service_Event_Logging_Topic__c) ?
            eventLoggingTopics.get(configurationSet.Service_Event_Logging_Topic__c) : CWSIdentityEvent.Topic.ALL_FAILURES;
        
        // User defaults
        this.community = [SELECT Id FROM Network WHERE Name = :configurationSet.Community_Name__c]?.Id; 
        this.serviceAccount = configurationSet.Service_Account__c;
        
        buildClientApps();
        
       System.debug(LoggingLevel.DEBUG,'Configuration set: ' + this);    
    }
    
    private void buildClientApps() {
        
        List<Identity_Services_Client_Application__mdt> apps = [
            SELECT
                Id,
                Application_Id__c,
                Password_Reset_Token_Expiration__c,
                Password_Reset_Token_Expiration_Units__c,
                Verify_Email_Token_Expiration__c,
                Verify_Email_Token_Expiration_Units__c,
                Reauthorize_Token_Expiration__c ,
                Reauthorize_Token_Expiration_Units__c 
            FROM 
                Identity_Services_Client_Application__mdt];
        
        clientApps = new Map<String,CWSIdentityClientApplication>();
        for (Identity_Services_Client_Application__mdt app : apps) {
            clientApps.put(app.Application_Id__c,new CWSIdentityClientApplication(this,app));
        }    
    }
   
    public static CWSIdentityConfiguration getInstance() {
        return instance;
    }
    
    public boolean allowClientApp(String appId) {
        return clientApps.get(appId) != null;
    }
    
    @TestVisible
    private List<String> appIds() {
        List<String> ids = new List<String>(clientApps.keySet()); 
        ids.sort();  
        return ids;
    }
    
 
    public URL renderForgotPasswordMessageURL(CWSIdentityUser u, CWSIdentityToken token) {
        return renderMessageURL(forgotPasswordURLTemplate,token.value); 
    }
    
    public URL renderVerifyEmailMessageURL(CWSIdentityUser u, CWSIdentityToken token) {
        return renderMessageURL(verifyEmailURLTemplate,token.value); 
    }
    
    private URL renderMessageURL(String urlTemplate, String token) {
    
        String url = String.format(urlTemplate,new List<Object>{token});
        System.debug(String.format('Interpolating token {1} into URL template {0}: {2}',
            new List<Object>{urlTemplate,token,url}));
            
        return new URL(url);
    }
    
    public TimeUnit unitOfTime(String value) {
        return unitsOfTime.get(value.toLowerCase());
    }
    
    public Integer tokenExpiryDuration(CWSIdentityToken.Usage tokenType, String appId) {
        CWSIdentityClientApplication app = clientApps.get(appId);
        switch on tokenType {
            when PASSWORD_RESET {
                return app == null ? this.passwordResetTokenExpirationDuration : app.passwordResetTokenExpirationDuration;
            }
            when VERIFY_EMAIL {
                return app == null ? this.emailVerificationTokenExpirationDuration : app.emailVerificationTokenExpirationDuration;
            }
            when RENEW_AUTHORIZATION {
                return app == null ? this.refreshTokenExpirationDuration : app.reauthorizeTokenExpirationDuration;
            }
            when else {
               throw new CWSIdentityException(CWSIdentityException.RUNTIME_ERROR,'Unknown token type: ' + tokenType);
            }
        
        }
    }
    
    public TimeUnit tokenExpiryDurationUnits(CWSIdentityToken.Usage tokenType, String appId) {
        CWSIdentityClientApplication app = clientApps.get(appId);
        switch on tokenType {
            when PASSWORD_RESET {
                return app == null ? this.passwordResetTokenExpirationDurationUnits : 
                    app.passwordResetTokenExpirationDurationUnits;
            }
            when VERIFY_EMAIL {
                return app == null ? this.emailVerificationTokenExpirationDurationUnits : 
                    app.emailVerificationTokenExpirationDurationUnits;
            }
            when RENEW_AUTHORIZATION {
                return app == null ? this.refreshTokenExpirationDurationUnits : 
                    app.reauthorizeTokenExpirationDurationUnits;
            }
            when else {
                throw new CWSIdentityException(CWSIdentityException.RUNTIME_ERROR,'Unknown token type: ' + tokenType);
            }
        
        }
    }
    
}