public class CWSIdentityContactRepository {

    private static final CWSIdentityContactRepository INSTANCE = new CWSIdentityContactRepository();
    
    public static CWSIdentityContactRepository getInstance(){
       return INSTANCE;
    }
    
    public Contact findOneByAccount(Account acct) {
        return [SELECT Id FROM Contact WHERE Contact.Account.Id = :acct.id LIMIT 1];
    }
}