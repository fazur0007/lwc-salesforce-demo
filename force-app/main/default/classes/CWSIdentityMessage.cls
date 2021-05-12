public class CWSIdentityMessage {

    /*
     * Password_Changed, Password_Reset and User_Locked_Out are push-style email notifications proactively sent 
     * after one of these events happened. User does not directly trigger these notifications.
     *
     * Verify_Email can be triggered directly by the user or sent push-style based on a particular event such as
     * new user registration
     *
     * Forgot_Password is directly triggered by the user
     */
    public enum MessageType { FORGOT_PASSWORD, VERIFY_EMAIL, PASSWORD_CHANGED, PASSWORD_RESET,  USER_LOCKED_OUT}
    
    public String payload {get; private set;}
    public MessageType messageType {get; private set;}
    public Id recipient {get; private set;}
    public String subject {get; private set;}
    public String experienceId {get; private set;}
    
    private CWSIdentityConfiguration config = CWSIdentityConfiguration.getInstance();
    
    public CWSIdentityMessage(MessageType messageType, CWSIdentityUser user) {
        this(messageType,user,null,null);
    }
   
    public CWSIdentityMessage(MessageType messageType, CWSIdentityUser u, CWSIdentityToken token, String experienceId) {
       
        this.messageType = messageType;
        this.recipient = u.id;
        this.experienceId = experienceId;

        switch on messageType {
            when FORGOT_PASSWORD {
                buildForgotPasswordMessage(u,token);
            }
            when VERIFY_EMAIL {
                buildEmailVerificationMessage(u,token);  
            }
        }
    }
    
    private void buildEmailVerificationMessage(CWSIdentityUser u, CWSIdentityToken token) {
    
        if (token == null || String.isBlank(token.value))
                     throw new CWSIdentityException(CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN,
                         'Failed to build a ' + messageType + ' message: email verification token is not found');
             
         String emailVerificationURL = config.renderVerifyEmailMessageURL(u,token).toExternalForm();
         Integer expirationPeriod = config.emailVerificationTokenExpirationDuration;
         String expirationPeriodUnits = config.emailVerificationTokenExpirationDurationUnits.name().toLowerCase();
         String emailTemplate = 'IdentityServicesVerifyEmail';
         
         Messaging.SingleEmailMessage m = renderTemplate(emailTemplate);
         
         this.payload = m.getHtmlBody()
             .replace('{$emailVerificationURL}',emailVerificationURL)
             .replace('{$expirationPeriod}',expirationPeriod+'')
             .replace('{$expirationPeriodUnits}',expirationPeriodUnits);
             
         this.subject = m.subject;
    }
    
    private void buildForgotPasswordMessage(CWSIdentityUser u, CWSIdentityToken token) {
    
        if (token == null || String.isBlank(token.value))
                 throw new CWSIdentityException(CWSIdentityException.INVALID_PASSWORD_RESET_TOKEN,
                     'Failed to build a ' + messageType + ' message: password reset token is not found');
             
         String passwordResetURL = config.renderForgotPasswordMessageURL(u,token).toExternalForm();
         Integer expirationPeriod = config.passwordResetTokenExpirationDuration;
         String expirationPeriodUnits = config.passwordResetTokenExpirationDurationUnits.name().toLowerCase();
         String emailTemplate = 'IdentityServicesForgotPassword';
         
         Messaging.SingleEmailMessage m = renderTemplate(emailTemplate);
         
         this.payload = m.getHtmlBody()
             .replace('{$passwordResetURL}',passwordResetURL)
             .replace('{$expirationPeriod}',expirationPeriod+'')
             .replace('{$expirationPeriodUnits}',expirationPeriodUnits);
             
         this.subject = m.subject;
    }
    
    private Messaging.SingleEmailMessage renderTemplate(String templateName) {

       EmailTemplate emailTemplate = [SELECT Id, Subject,HtmlValue, Body FROM EmailTemplate 
           WHERE DeveloperName = :templateName LIMIT 1];
           
       if (emailTemplate == null)
            throw new CWSIdentityException(CWSIdentityException.RUNTIME_ERROR,
                'Failed to retrieve email template: ' + templateName);
       
       return Messaging.renderStoredEmailTemplate(emailTemplate.Id,recipient,null);
    }
}