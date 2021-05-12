public class CWSIdentityService {

   private CWSIdentityUserRepository userRepo;
   private CWSIdentityTokenRepository tokenRepo;
   private CWSIdentityConfiguration config;
   private String traceId;
   
    private CWSIdentityService(String traceId) {
       this.userRepo = CWSIdentityUserRepository.getInstance();
       this.tokenRepo = CWSIdentityTokenRepository.getInstance();
       this.config = CWSIdentityConfiguration.getInstance();
       this.traceId = traceId;
    }
    
    public static CWSIdentityService getInstance() {
        return new CWSIdentityService(new Uuid().getValue());
    }
    
    public static CWSIdentityService getInstance(String traceId) {
        return new CWSIdentityService(traceId);
    }
    
    private void elapsedTime(String operation, long startTime) {
        long elapsed = System.currentTimeMillis() - startTime;
        System.debug('ELAPSED TIME: operation ' + operation + ' took ' + elapsed + ' ms');
    }
     
    public CWSIdentityResponse.KeySetResponse renderKeySet() {
        return new CWSIdentityResponse.KeySetResponse(CWSIdentityKeySet.getInstance());
    }
    
     @TestVisible private void verifyClientApp(String appId) {
         if (!config.allowClientApp(appId))
            throw new CWSIdentityException(CWSIdentityException.INVALID_APP,
                String.format('Application {0} is invalid or access is denied}', new List<Object>{appId}));
    }
     
    public CWSIdentityResponse.RegistrationResponse createUser(CWSIdentityRequest.RegistrationRequest req) {
        System.debug(String.format('Creating a new user with login name = {0} app = {1} experience id = {2} [{3}]',
                new List<Object>{req.loginName,req.appId,req.experienceId,traceId}));

        verifyClientApp(req.appId);
        
        boolean loginNameTaken = userRepo.existsByUsername(req.loginName);
        
        if (loginNameTaken)
            throw new CWSIdentityException(CWSIdentityException.USERNAME_ALREADY_EXISTS,
                String.format('User with login name {0} is already registered}', new List<Object>{req.loginName}));
                
        CWSIdentityUser u = new CWSIdentityUser(req.loginName,req.password,req.experienceId);
        
        if (!Test.isRunningTest())
            CWSIdentityEmailService.initiateEmailVerification(traceId,u.id,u.email,req.experienceId,req.appId);
        
        CWSIdentityUser u1 = userRepo.findOneById(u.Id); // need this to read fields that are in DB but not in memory
        return new CWSIdentityResponse.RegistrationResponse(traceId,req.appId,u1);
     }
     
    public CWSIdentityResponse.LoginResponse authenticateUser(CWSIdentityRequest.LoginRequest req) {
          System.debug(String.format('Authenticating user with login name = {0} app = {1} [{2}]',
              new List<Object>{req.loginName,req.appId,traceId}));
         
         verifyClientApp(req.appId);
         
         long startTime = System.currentTimeMillis();
         CWSIdentityUser u = userRepo.findOneByUsername(CWSIdentityUtils.usernameWithSuffix(req.loginName));
         elapsedTime('userRepo.findOneByLoginName',startTime);
         
         startTime = System.currentTimeMillis();
         CWSIdentityAuthenticator.AuthenticationResult result = authenticate(u,req.password);
         elapsedTime('authenticate',startTime);
         
         CWSIdentityToken refreshToken = new CWSIdentityToken(CWSIdentityToken.Usage.RENEW_AUTHORIZATION,u.Id,req.appId);
          
          /*
          if (!u.isEmailVerified()) { // this step MUST be executed AFTER the password is verified, else we're leaking info
                 CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.REDO_VERIFY_EMAIL,u.Id);
                 throw new CWSIdentityEmailVerificationException(u.Email,token.value); 
          }
          */
         
          return new CWSIdentityResponse.LoginResponse(traceId,req.appId,u,result.sessionId,refreshToken);
    }
     
    public CWSIdentityResponse.ReauthorizationResponse reauthorize(CWSIdentityRequest.ReauthorizationRequest req) {
         System.debug(String.format('Reauthorizing with refresh_token = {0} for client = {1} [{2}]',
                new List<Object>{req.refreshToken,req.appId,traceId}));
        
        verifyClientApp(req.appId);
        
        CWSIdentityToken reauthorizeToken = tokenRepo.findOneByValue(req.refreshToken);
        if (reauthorizeToken == null)
            throw new CWSIdentityException(CWSIdentityToken.Usage.RENEW_AUTHORIZATION,
                String.format('Valid {0} token {1} was not found',
                    new List<Object>{CWSIdentityToken.Usage.RENEW_AUTHORIZATION,req.refreshToken})); 
        
        String accessToken = getAccessToken(reauthorizeToken.issuedTo()); // revoke this access token if redeem() fails
        CWSIdentityToken newReauthorizeToken = reauthorizeToken.redeem();

        return new CWSIdentityResponse.ReauthorizationResponse(traceId,req.appId,accessToken,newReauthorizeToken);
    }
    
    public void verifyEmail(CWSIdentityRequest.EmailVerificationRequest req) {
         System.debug(String.format('Verifying email address with token = {0} [{1}]',
             new List<Object>{req.emailVerificationToken,traceId}));
        
        findAndRedeemToken(CWSIdentityToken.Usage.VERIFY_EMAIL,req.emailVerificationToken).issuedTo().setEmailVerified();
    }
    
  
    public void initiatePasswordReset(CWSIdentityRequest.PasswordResetInitiationRequest req) {
         System.debug(String.format('Initiating password reset for user {0} with app = {1} experienceId = {2} [{3}]', 
             new List<Object>{req.loginName,req.appId,req.experienceId,traceId}));
         
         verifyClientApp(req.appId);
         
         CWSIdentityUser u = userRepo.findOneByUsername(CWSIdentityUtils.usernameWithSuffix(req.loginName));
         CWSIdentityToken token = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,u.Id,req.appId);
         
         if (!Test.isRunningTest())
             CWSIdentityEmailService.initiateForgotPassword(traceId,u.Id,token.value,req.experienceId); 
    }
     
    public void completePasswordReset(CWSIdentityRequest.PasswordResetCompletionRequest req) {
         System.debug(String.format('Completing password reset with password reset token = {0} and new password = {1} [{2}]', 
             new List<Object>{req.passwordResetToken,req.password,traceId}));
         
         CWSIdentityUser u = findAndRedeemToken(CWSIdentityToken.Usage.PASSWORD_RESET,req.passwordResetToken).issuedTo();
         u.setPassword(req.password);
         
/*         if (!Test.isRunningTest())
             CWSIdentityEmailService.passwordReset(traceId,u.id);    */ // notify user
     }
     
    private CWSIdentityAuthenticator.AuthenticationResult authenticate(CWSIdentityUser u, String password) {
        
        long startTime = System.currentTimeMillis();
        CWSIdentityAuthenticator.AuthenticationResult result = 
            CWSIdentityAuthenticator.getInstance().authenticateUser(u,password);
        elapsedTime('authenticateUser',startTime);
        
        System.debug('Authentication result: ' + result);
        
        if (result.status != CWSIdentityAuthenticator.AuthenticationOutcome.OK) {
            
            /*
            if (result.status == CWSIdentityAuthenticator.AuthenticationOutcome.LockedPassword && !Test.isRunningTest()) {
                CWSIdentityEmailService.userLockedOut(traceId,u.Id); // notify user
            }
            */
            
            String fmt = 'Failed to authenticate user {0} (login: {1})';
            throw new CWSIdentityException(result.status, 
                String.isBlank(result.message) ?
                 String.format(fmt,new List<Object>{u.id,u.username}) :
                 String.format(fmt + ' -> {2}',new List<Object>{u.id,u.username,result.message}));
        }
        return result;
     }
     
       
    @TestVisible private String getAccessToken(CWSIdentityUser u) {
        
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(u.Username);
        jwt.setAud(CWSIdentityUtils.genericServiceEndpoint().toExternalForm());
        jwt.setIss(config.userImpersonationClientId);
        
        Auth.JWS jws = new Auth.JWS(jwt, config.userImpersonationSigningCertificate);
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
            CWSIdentityUtils.oAuthTokenEndpoint().toExternalForm(), jws);
        return bearer.getAccessToken();
    }
    
    private CWSIdentityToken findAndRedeemToken(CWSIdentityToken.Usage usage, String tokenValue) {
    
        CWSIdentityToken token = tokenRepo.findOneByValue(tokenValue);
        if (token == null)
            throw new CWSIdentityException(usage,'Valid ' + usage + ' token ' + tokenValue + ' was not found'); 
             
        return token.redeem();
    }
 
     
}