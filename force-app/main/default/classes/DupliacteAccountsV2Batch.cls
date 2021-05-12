global class DupliacteAccountsV2Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    
    public DupliacteAccountsV2Batch(){
        
    }
    global static void scheduleBatch(){

    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 200);
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	String tempEmail = System.Label.External_Email;
    	List<String> emails = tempEmail.split('\\,');
    	String query = '';
    	if(tempEmail != 'none' && tempEmail != ''){
    		query = 'SELECT PersonEmail, Email_External_ID__c FROM Account WHERE isDataCleaned__c = false AND IsPersonAccount = true AND Email_External_ID__c IN :emails LIMIT 100';
    	}else{
    		query = 'SELECT PersonEmail, Email_External_ID__c FROM Account WHERE isDataCleaned__c = false AND IsPersonAccount = true LIMIT 100';
    	}
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> accountList){
        set<String> emailList = new set<String>();
        map<String, list<Account>> emailToaccountsMap = new map<String, list<Account>>();
        list<Account> accountsConsidered = new list<Account>();
        list<Account> accountsToUpdate = new list<Account>();
        
        for(Account record: accountList){
    		if(record.Email_External_ID__c != null && record.Email_External_ID__c != ''){
    			emailList.add(record.Email_External_ID__c);
    		}
    	}
    	
    	list<Account> oldAccounts = [SELECT PersonEmail, isDataCleaned__c, Email_External_ID__c FROM Account WHERE IsPersonAccount = true AND Email_External_ID__c IN :emailList 
    									Order by LastModifiedDate ASC];
    	for(Account record: oldAccounts){
    		if(emailToaccountsMap.containsKey(record.Email_External_ID__c)){
    			emailToaccountsMap.get(record.Email_External_ID__c).add(record);
    		}else{
    			emailToaccountsMap.put(record.Email_External_ID__c, new list<Account>{record});
    		}
    	}
    	
    	for(String email: emailToaccountsMap.keySet()){
    		list<Account> accList = emailToaccountsMap.get(email);
    		if(accList.size() > 0){
    			accList.remove(accList.size()-1);
    			accountsConsidered.addAll(accList);
    		}
    	}
    	
    	for(Account record: accountsConsidered){
    		accountsToUpdate.add(new Account(Id=record.Id, Email_External_ID__c = '', isDataCleaned__c = true));
    	}
    	update accountsToUpdate;
    }
    global void finish(Database.BatchableContext BC){
       
    }
    
    
}