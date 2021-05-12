public class CWSIdentityPasswordPolicyException extends CWSIdentityException {

    private final static String PASSWORD_POLICY_VIOLATION_PASSWORD_HISTORY_PATTERN = 'invalid repeated password';
    public Id userId {get;private set;}
    
    public CWSIdentityPasswordPolicyException (CWSIdentityUser user, String errorMsg) {
        super(CWSIdentityException.PASSWORD_POLICY_VIOLATION, errorMsg);
        this.userId = user.id;
    }
    
    public CWSIdentityPasswordPolicyException (CWSIdentityUser user, InvalidParameterValueException ex) {               
        super(ex.getMessage() != null &&
            ex.getMessage().endsWithIgnoreCase(PASSWORD_POLICY_VIOLATION_PASSWORD_HISTORY_PATTERN) ? 
            CWSIdentityException.PASSWORD_POLICY_VIOLATION_PASSWORD_HISTORY : CWSIdentityException.PASSWORD_POLICY_VIOLATION, 
            ex.getMessage());
              
        this.userId = user.id;
    }
}