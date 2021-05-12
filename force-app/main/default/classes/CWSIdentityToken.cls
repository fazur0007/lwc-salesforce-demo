public class CWSIdentityToken {

    public Enum Usage { PASSWORD_RESET, VERIFY_EMAIL, REDO_VERIFY_EMAIL, RENEW_AUTHORIZATION }
    
    @testVisible private static Map<Usage,String> tokenUsageToType = new Map<Usage,String> {
        Usage.PASSWORD_RESET => 'pwd_reset',
        Usage.VERIFY_EMAIL => 'verify_email',
        Usage.RENEW_AUTHORIZATION => 'renew_authorization'
    };
    
    private static Map<String,Usage> tokenTypeToUsage = new Map<String,Usage> {
        'pwd_reset' => Usage.PASSWORD_RESET,
        'verify_email' => Usage.VERIFY_EMAIL,
        'renew_authorization' => Usage.RENEW_AUTHORIZATION
    };
   
    private Identity_Service_Token__c token;
    
    public Id id {
        get { return token.id; }
    }    
    
    public DateTime expirationDate {
        get { return token.Expires_On__c; }
    }
    
    public Id issuedTo {
        get { return token.Subject__c; }
    }
    
    public String requestedBy {
        get { return token.Client__c; }
    }
    
    public Usage usage {
        get { return tokenTypeToUsage.get(token.Token_Type__c); }
    }
    
    public String type {
          get { return token.Token_Type__c; }    
    }
    
    public String value {
        get  { return token.Token__c; } 
    }
    
    public CWSIdentityUser issuedTo() {
        return CWSIdentityUserRepository.getInstance().findOneById(this.issuedTo);
    }
   
    
    public CWSIdentityToken(Identity_Service_Token__c token) {
       this.token = token;
    }
    
    public CWSIdentityToken(Usage usage, Id subject) {
        this(tokenUsageToType.get(usage),subject,determineExpirationDate(usage,null),null);
    }
    
    public CWSIdentityToken(Usage usage, Id subject, String appId) {
        this(tokenUsageToType.get(usage),subject,determineExpirationDate(usage,appId),appId);
    }
    
    private CWSIdentityToken(String tokenType, Id subject, DateTime expirationDate, String appId) {
        Identity_Service_Token__c token = new Identity_Service_Token__c();
        token.Token_Type__c = tokenType;
        token.Token__c = new Uuid().getValue();
        token.Subject__c = subject;
        token.Expires_On__c = expirationDate;
        token.Redeemed__c = false;
        token.Client__c = appId;
        this.Token = token;
        
        insert token;
    }
    
    @testVisible private static Integer convertToMinutes(Integer duration, CWSIdentityConfiguration.TimeUnit units) {
        switch on units {
            when MINUTES {
                return duration;
            }
            when HOURS {
                return duration * 60;
            }
            when DAYS {
                return duration * 60 * 24;
            }
            when else {
                throw new CWSIdentityException(CWSIdentityException.RUNTIME_ERROR,'Unknown unit of time: ' + units);
            }
        }
    }
    
    @testVisible private static DateTime determineExpirationDate(Usage usage, String appId) {
        switch on usage {
            when PASSWORD_RESET, VERIFY_EMAIL, RENEW_AUTHORIZATION  {
                CWSIdentityConfiguration config = CWSIdentityConfiguration.getInstance();
                return DateTime.now().addMinutes(
                    convertToMinutes(config.tokenExpiryDuration(usage,appId),
                    config.tokenExpiryDurationUnits(usage,appId)));      
            }
            when else {
                 throw new CWSIdentityException(CWSIdentityException.RUNTIME_ERROR,'Unknown token usage: ' + usage);
                // return DateTime.now().addYears(100); // this token "never" expires
            }
        }
    }
    
    public boolean isExpired() {
        return token.Expires_On__c < DateTime.now();
    }
    
    public boolean isRedeemed() {
        return isRedeemable() && token.Redeemed__c; 
    }
    
    /*
     * This method does not flush this change to the database and this is intentional. The goal of this method
     * is to ensure that an in-memory state of the Redeemed field on this object is in sync with the database. This is 
     * needed when the field is updated and the update is saved to DB via another object reference.
     */
    public void setRedeemed(boolean redeemed) {
        if (isRedeemable())
            token.Redeemed__c = redeemed;
    }
    
    public boolean isRedeemable() {
        return this.usage != CWSIdentityToken.Usage.PASSWORD_RESET; // ignore redemption flag for a multi-use token
    }
    
    
    public CWSIdentityToken redeem(String client) {
        if (this.requestedBy != client)
            throw new CWSIdentityException(this.usage,
                   String.format('Token {0} was not issued for client {1}', new List<Object>{this.value,client})); 
        return redeem();
    }
   
    public CWSIdentityToken redeem() {
        
        if (isRedeemed())
             throw new CWSIdentityException(this.usage,
                   String.format('Token {0} has already been redeemed', new List<Object>{this.value})); 
                   
        if (isExpired())
             throw new CWSIdentityException(this.usage,
                   String.format('Token {0} has expired on {1}', new List<Object>{this.value,this.expirationDate}));   
   
        try {
            CWSIdentityTokenRepository.getInstance().redeemAndSave(this);
            
            switch on this.usage {
                when RENEW_AUTHORIZATION {
                     return new CWSIdentityToken(CWSIdentityToken.Usage.RENEW_AUTHORIZATION,this.issuedTo,this.requestedBy);
                }
                when else {
                    return this;
                }
            }
        }
        catch (Exception e) {
            throw new CWSIdentityException(this.usage,
                String.format('Failed to redeem {0} token. Root cause: {1}', new List<Object>{this.type, e.getMessage()}));
        }
    }
     
}