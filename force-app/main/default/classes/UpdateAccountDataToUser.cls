public class UpdateAccountDataToUser implements Queueable{
	
	List<Account> accountList = new List<Account>();
	
	public UpdateAccountDataToUser(List<Account> accountList){
		this.accountList = accountList;
	}
	
	public void execute(QueueableContext context) {
    	List<User> updateUserList = new List<User>();
        
    	for(Account recAcct : accountList){
            List<User> usrList = recAcct.Users;
            User recUser = usrList.get(0);
            User recUpdateUser = new User();
            recUpdateUser.Id = recUser.Id;
            recUpdateUser.FirstName = recAcct.FirstName;
            recUpdateUser.LastName = recAcct.LastName;

            updateUserList.add(recUpdateUser);
		}
		if(updateUserList.isEmpty())
        	return;
        
        update updateUserList;
    }
    
}