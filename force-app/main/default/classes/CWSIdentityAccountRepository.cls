public class CWSIdentityAccountRepository {

    private static final CWSIdentityAccountRepository INSTANCE = new CWSIdentityAccountRepository();
    
    public static CWSIdentityAccountRepository getInstance(){
       return INSTANCE;
    }
  
    public List<Account> findByEmail(String email) {
        System.debug(String.format('Locating an Account record with email = {0}',new List<Object>{email}));
    
      return [
            SELECT Id,Customer_Portal_User__c,Marketing_Opt_In__c 
            FROM Account 
            WHERE PersonEmail = :email];
    }
}