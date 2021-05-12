public class CWSIdentityClientApplication {

    private CWSIdentityConfiguration config;
    private Identity_Services_Client_Application__mdt app;
    
     // Token semantics
    public Integer passwordResetTokenExpirationDuration {get;private set;}
    public CWSIdentityConfiguration.TimeUnit passwordResetTokenExpirationDurationUnits {get;private set;}
    public Integer emailVerificationTokenExpirationDuration {get;private set;}
    public CWSIdentityConfiguration.TimeUnit emailVerificationTokenExpirationDurationUnits {get;private set;}
    public Integer redoEmailVerificationMaxAttempts {get; private set;}
    public Integer reauthorizeTokenExpirationDuration {get;private set;}
    public CWSIdentityConfiguration.TimeUnit reauthorizeTokenExpirationDurationUnits {get;private set;}
    
    public CWSIdentityClientApplication (CWSIdentityConfiguration config, Identity_Services_Client_Application__mdt app) {
        this.config = config;
        this.app = app;
        
        buildTokenSemantics();
    }
    
    private void buildTokenSemantics() {
    
        this.passwordResetTokenExpirationDuration = config.passwordResetTokenExpirationDuration;
        this.passwordResetTokenExpirationDurationUnits = config.passwordResetTokenExpirationDurationUnits;
    
        if (app.Password_Reset_Token_Expiration__c != null) {
            this.passwordResetTokenExpirationDuration = app.Password_Reset_Token_Expiration__c.intValue();
            this.passwordResetTokenExpirationDurationUnits = 
                config.unitOfTime(app.Password_Reset_Token_Expiration_Units__c);
        }
        
        this.emailVerificationTokenExpirationDuration = config.emailVerificationTokenExpirationDuration;
        this.emailVerificationTokenExpirationDurationUnits = config.emailVerificationTokenExpirationDurationUnits;
        
        if (app.Verify_Email_Token_Expiration__c != null) {
              this.emailVerificationTokenExpirationDuration = app.Verify_Email_Token_Expiration__c .intValue();
            this.emailVerificationTokenExpirationDurationUnits = 
                config.unitOftime(app.Verify_Email_Token_Expiration_Units__c);
        }
        
        this.reauthorizeTokenExpirationDuration = config.refreshTokenExpirationDuration;
        this.reauthorizeTokenExpirationDurationUnits = config.refreshTokenExpirationDurationUnits;
        
        if (app.Reauthorize_Token_Expiration__c != null) {
            this.reauthorizeTokenExpirationDuration = app.Reauthorize_Token_Expiration__c.intValue();
            this.reauthorizeTokenExpirationDurationUnits = 
                config.unitOfTime(app.Reauthorize_Token_Expiration_Units__c);
        }
    }


}