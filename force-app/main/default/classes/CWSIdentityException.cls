public virtual class CWSIdentityException extends Exception {

    public static final String USERNAME_ALREADY_EXISTS = 'username_exists';

    public static final String PASSWORD_POLICY_VIOLATION = 'password_policy_violation';
    public static final String PASSWORD_POLICY_VIOLATION_PASSWORD_HISTORY = 'password_policy_violation_repeated_password';
    public static final String INVALID_USER = 'invalid_user';
    public static final String INVALID_APP = 'invalid_app';
    public static final String PASSWORD_INVALID = 'invalid_password';
    public static final String PASSWORD_EXPIRED = 'expired_password';
    public static final String USER_LOCKED_OUT = 'user_locked_out';
    public static final String USER_FROZEN = 'user_frozen';
    public static final String USER_INACTIVE = 'user_inactive';
    public static final String INVALID_REQUEST = 'invalid_request';
    public static final String INVALID_PASSWORD_RESET_TOKEN = 'invalid_reset_token';
    public static final String INVALID_EMAIL_VERIFICATION_TOKEN = 'invalid_email_verification_token';
    public static final String INVALID_REFRESH_TOKEN = 'invalid_refresh_token';
    public static final String UNVERIFIED_EMAIL = 'unverified_email';
    public static final String RUNTIME_ERROR = 'runtime_error';
    
    private final static Map<CWSIdentityAuthenticator.AuthenticationOutcome,String> authenticationFailures = 
        new Map<CWSIdentityAuthenticator.AuthenticationOutcome,String> {
           CWSIdentityAuthenticator.AuthenticationOutcome.PasswordPolicyViolation => PASSWORD_POLICY_VIOLATION,
           CWSIdentityAuthenticator.AuthenticationOutcome.PasswordPolicyViolationPasswordHistory => PASSWORD_POLICY_VIOLATION_PASSWORD_HISTORY,
           CWSIdentityAuthenticator.AuthenticationOutcome.InvalidPassword => PASSWORD_INVALID,
           CWSIdentityAuthenticator.AuthenticationOutcome.LockedPassword => USER_LOCKED_OUT, 
           CWSIdentityAuthenticator.AuthenticationOutcome.FrozenUser => USER_LOCKED_OUT, // was USER_FROZEN 
           CWSIdentityAuthenticator.AuthenticationOutcome.InactiveUser => USER_LOCKED_OUT, // was USER_INACTIVE 
           CWSIdentityAuthenticator.AuthenticationOutcome.ExpiredPassword => USER_LOCKED_OUT // was PASSWORD_EXPIRED 
       };
    
    private static final Map<CWSIdentityToken.Usage,String> tokenFailures = new Map<CWSIdentityToken.Usage,String>{
        CWSIdentityToken.Usage.PASSWORD_RESET => CWSIdentityException.INVALID_PASSWORD_RESET_TOKEN,
        CWSIdentityToken.Usage.VERIFY_EMAIL => CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN,
        CWSIdentityToken.Usage.RENEW_AUTHORIZATION => CWSIdentityException.INVALID_REFRESH_TOKEN
    }; 
    

    public String messageCode {get; private set;}

    public CWSIdentityException(String code, String msg) {
        this(msg);
        this.messageCode = code;
    }
    
    
    public CWSIdentityException(CWSIdentityAuthenticator.AuthenticationOutcome authenticationResult, String msg) {
        this(msg);
        String reason = authenticationFailures.get(authenticationResult);
        this.messageCode = reason == null ? PASSWORD_INVALID : reason;
    }
    
     public CWSIdentityException(CWSIdentityToken.Usage usage, String msg) {
        this(msg);
        this.messageCode = tokenFailures.get(usage);
    }
}