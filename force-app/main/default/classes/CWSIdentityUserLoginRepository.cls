public class CWSIdentityUserLoginRepository {

    private static final CWSIdentityUserLoginRepository instance = new CWSIdentityUserLoginRepository();
    
    public static CWSIdentityUserLoginRepository getInstance(){
       return instance;
    }

    public UserLogin findOneById(Id userId) {
        System.debug(String.format('Locating a UserLogin record with user id = {0}',new List<Object>{userId}));
          
        List<UserLogin> users = [SELECT Id,IsFrozen,IsPasswordLocked FROM UserLogin WHERE UserId = :userId ORDER BY LastModifiedDate DESC LIMIT 1] ;
        return users.size() == 1 ? users.get(0) : null;
    }
}