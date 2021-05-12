public class CWSIdentityUserRepository {


    private static final CWSIdentityUserRepository instance = new CWSIdentityUserRepository();
    
    public static CWSIdentityUserRepository getInstance(){
       return instance;
    }
    
    public CWSIdentityUser findOneById(Id userId) {
        System.debug(String.format('Locating a User record with id = {0}',new List<Object>{userId}));
          
        List<User> users = [
            SELECT Id, IsActive, Name, Username, Email, AccountId, ContactId, Community_Email_Verified__c
            FROM User 
            WHERE Id = :userId];
            
       return oneUserOrError(users,'id: ' + userId);

    }
    
    public boolean existsByUsername(String aUsername) {
        String username = CWSIdentityUtils.usernameWithSuffix(aUsername);
        System.debug(String.format('Counting User records with username = {0} possibly modified to {1}',
            new List<Object>{aUsername,username}));
            
        return [
            SELECT COUNT()
            FROM User 
            WHERE Username = :username] > 0;
    }
    
    public CWSIdentityUser findOneByUsername(String aUsername) {
        String username = CWSIdentityUtils.usernameWithSuffix(aUsername);

        System.debug(String.format('Locating a User record with username = {0} possibly modified to {1}',
            new List<Object>{aUsername,username}));
          
        List<User> users = [
            SELECT Id, IsActive, Name, Username, Email, AccountId, ContactId, Community_Email_Verified__c
            FROM User 
            WHERE Username = :username];
            
       return oneUserOrError(users,'username: ' + username);

    }
   
   
    private CWSIdentityUser oneUserOrError(List<User> users, String searchCriteria) {
       if (users.size() == 1) {
           User u = users[0];
           System.debug('Found 1 user: ' + u);
           return new CWSIdentityUser(u);
       }
      
       throw new CWSIdentityException(CWSIdentityException.INVALID_USER,String.format(
            'Found {0} users based on search criteria -> {1}',new List<Object>{users.size(),searchCriteria}));
    }
    
}