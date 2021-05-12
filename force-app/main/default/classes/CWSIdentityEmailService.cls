public class CWSIdentityEmailService {


    private String traceId;
    private CWSIdentityUser u;
    
    public CWSIdentityEmailService(CWSIdentityUser u, String traceId) {
        this.traceId = traceId;
        this.u = u;
    }
    
   
    @future
    public static void initiateEmailVerification(String traceId,Id userId, String email, String experienceId, String appId) {
       System.debug(String.format('Initiating email verification for user = {0} email = {1} experienceId = {2} app = {3} [{4}]',
           new List<Object>{userId,email,experienceId, appId, traceId}));
           
       CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(userId);
       
       /*
        * Acquisition of a token via CWSIdentityToken constructor is a DML operation, thus it cannot be performed in a 
        * parent transaction. This is so in our specific case because the parent creates a User record. The latter is 
        * considered to be a 'setup' object. DML on setup objects cannot be mixed with DML on 'regular' objects in the 
        * same transaction. This is why we're acquiring the token in this rather than parent transaction.
        */
        
       CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,u.Id,appId);
       CWSIdentityMessage msg = new CWSIdentityMessage(CWSIdentityMessage.MessageType.VERIFY_EMAIL,u,token,experienceId);
       new CWSIdentityEmailService(u,traceId).sendMessage(msg);  
    }
    
    @future
    public static void initiateForgotPassword(String traceid, Id userId, String tokenValue,String experienceId) {
       System.debug(String.format('Initiating forgot password email for user = {0} token = {1} experienceid = {2} [{3}]',
           new List<Object>{userId,tokenValue,experienceId,traceId}));
           
       CWSIdentityUser u = CWSIdentityUserRepository.getInstance().findOneById(userId);
       CWSIdentityToken token = CWSIdentityTokenRepository.getInstance().findOneByValue(tokenValue);
       CWSIdentityMessage msg = new CWSIdentityMessage(CWSIdentityMessage.MessageType.FORGOT_PASSWORD,u,token,experienceId);
    
       new CWSIdentityEmailService(u,traceId).sendMessage(msg);  
    }

    
    public void sendMessage(CWSIdentityMessage message) {
       sendEmail(u.email,message.subject,message.payload);
    }
   
    public Messaging.SendEmailResult sendEmail(String recipient,String subject,String htmlBody) {
        
        String orgWideEmail = 'noreply@brevilleusa.com';
        OrgWideEmailAddress owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address 
            FROM OrgWideEmailAddress WHERE Address = :orgWideEmail  LIMIT 1];
        
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       if (owe != null)
           mail.setOrgWideEmailAddressId(owe.Id); 
       mail.setToAddresses(new String[] {recipient});
       mail.setSubject(subject);
       mail.setUseSignature(false);
       mail.setSaveAsActivity(false); // TODO ask team if this is wanted
       //mail.setPlainTextBody(plainTextBody);
       mail.setHtmlBody(htmlBody);
       
       Messaging.reserveSingleEmailCapacity(2);
       List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
       Messaging.SendEmailResult r = results?.get(0);
       
       if (r != null)
           System.debug('Email message ' + mail + ' has been requested to be sent: ' + r);
       return r;
   }
}