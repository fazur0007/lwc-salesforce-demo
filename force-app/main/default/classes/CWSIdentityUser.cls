public without sharing class CWSIdentityUser {

    private User user;
    
    public CWSIdentityUser(String email, String password, String expId) {
        
        Account acct = createOrUseExistingAccount(email,expId);
        this.user = createUserForAccount(acct,email,expId);
        
        Savepoint tx = Database.setSavepoint();
        saveUserWithPassword(password,tx);
    }
    
    private static Account createOrUseExistingAccount(String email,String expId) {
      
        List<Account> existingAccounts = CWSIdentityAccountRepository.getInstance().findByEmail(email);
        if (existingAccounts.size() > 1)
            throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,
                String.format(
                    'Too many accounts: found {0} accounts for {1}',new List<Object>{existingAccounts.size(),email}));
        
        
        Account acct = new Account();
        acct.Email_External_ID__c = email;
        acct.PersonEmail = email;
        boolean doCreateAccount = true;
        
        if (existingAccounts.size() == 1) {
            acct = existingAccounts[0];
            doCreateAccount = false;
        }
        
        try {
            acct = CommunityUserManagementUtility.FetchAccountDefaults(acct,expId,doCreateAccount);
     
            if (doCreateAccount) {
                insert acct;
                System.debug('Account created: ' + acct);
            }
            else {
                update acct;
                System.debug('Account updated: ' + acct);
            }    
            return acct;
        }
        catch (Exception e) {
            throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST, 
                  String.format('Failed to create or update account for {0}: {1}', new List<Object>{email,e.getMessage()}));
        }
        
    }
    
    
    @TestVisible
    private static User createUserForAccount(Account acct, String email, String expId) {
    
 
        boolean doCreateUser = true;
        User u = new User();
        u.Email = email;
        u = CommunityUserManagementUtility.FetchUserDefaults(u,acct,expId,doCreateUser);
        u.Email_verification_network_Id__c = CWSIdentityConfiguration.getInstance().community;
        u.Send_Mail_Verification_Email__c = false;
        u.CommunityNickname = email;
        u.isActive = true;
        System.debug('the username is now: ' + u.username);
        
        Contact c = CWSIdentityContactRepository.getInstance().findOneByAccount(acct);
 
        if (c == null)
             throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST, 
                  String.format('Failed to retrieve the Contact for/from Person Account {0}', new List<Object>{acct.id}));
                  
        u.ContactId = c.Id;
        return u;
    }
    
    public void setPassword(String password) {
        Savepoint tx = Database.setSavepoint();
        savePassword(password,tx);
    }
    
    @TestVisible private void savePassword(String password, Savepoint tx) {
        try {
          System.setPassword(user.Id,password);
          System.debug('Successfully set or changed the password for user ' + user.Id);
        }
        catch (InvalidParameterValueException ex) {
           System.debug(String.format('Failed to set or change the password for user {0}: {1}',new List<Object>{this.id,ex.getMessage()}));
           Database.rollback(tx);
           throw new CWSIdentityPasswordPolicyException(this,ex);
        }
        catch (Exception e) {
            Database.rollback(tx);
            throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST, 
                  String.format('Failed to set or change a password for user {0}: {1}', new List<Object>{this.id,e.getMessage()}));
        }
     }
    
   
    @TestVisible private void saveUserWithPassword(String password, Savepoint tx) {
        try {
            insert user;
            System.debug('Successfully created a User record: ' + user);
        }
        catch (Exception e) {
            throw new CWSIdentityException(CWSIdentityException.INVALID_REQUEST,'Failed to create the User record for ' + 
                this.email + ' -> ' + e.getMessage());
        }
        savePassword(password,tx);
    }
    
    public Id id {
        get {return user.Id;}
    }
    public String email {
        get { return user.Email;}
    }
    
    public String name {
        get { return user.Name; }
    }
    
    public Id personId {
        get { return user.AccountId; }
    }
    

    public boolean emailVerified {
        get { return user.Community_Email_Verified__c; }
    }
    
    public void setEmailVerified() {
        user.Community_Email_Verified__c = true;
        update user;
    }
    
    public String username {
        get { return user.Username; }   
    }
    
    public boolean isActive() {
        return user.isActive;
    }
    
    public boolean isFrozen() {
        UserLogin ul = CWSIdentityUserLoginRepository.getInstance().findOneById(this.id);
        return ul != null && ul.IsFrozen;
    }
    
    public boolean isLockedOut() {
        UserLogin ul = CWSIdentityUserLoginRepository.getInstance().findOneById(this.id);
        return ul != null && ul.IsPasswordLocked;
    }
    
    public CWSIdentityUser(User u) {
        this.user = u;
    }
}