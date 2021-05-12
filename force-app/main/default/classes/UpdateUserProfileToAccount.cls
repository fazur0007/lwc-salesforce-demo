public class UpdateUserProfileToAccount implements Queueable{
	
	list<User> userList = new list<User>();
	map<Id,Account> accountNameMap = new map<Id,Account>();
	list<Account> updatedAccount = new list<Account>();
	
	public UpdateUserProfileToAccount(list<User> sortedUserList, map<Id,Account> nameMap){
		
		this.userList = sortedUserList;
		this.accountNameMap = nameMap;
	}
	
	public void execute(QueueableContext context) {
    	
    	for(User user : userList){
			if(Trigger.isUpdate){
				Account parent = accountNameMap.get(user.AccountId);
				parent.FirstName = user.FirstName;
				parent.LastName = user.LastName;
				
				updatedAccount.add(parent);
			}
		}
		if(updatedAccount.size() > 0){
			update updatedAccount;
		}
    }
	
}