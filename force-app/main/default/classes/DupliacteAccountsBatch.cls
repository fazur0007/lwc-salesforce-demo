global class DupliacteAccountsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
	public String currencyCode;
	
	public DupliacteAccountsBatch(){
        
    }
    global static void scheduleBatch(){

    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 200);
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	String tempEmail = System.Label.Duplicate_Account_Emails;
    	currencyCode = System.Label.Duplicate_Account_Currency;
    	if(currencyCode == null || currencyCode == '' || currencyCode == 'none'){
    		currencyCode = 'USD';
    	}
    	String query = 'SELECT PersonEmail FROM Account WHERE Is_Duplicate_Checked__c = false AND IsPersonAccount = true AND CurrencyIsoCode = :currencyCode';    	
    	List<String> emails = tempEmail.split('\\,');
    	if(tempEmail != 'none' && tempEmail != ''){
    		query += ' AND PersonEmail IN :emails';
    	}
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> accountList){
    	set<String> emailList = new set<String>();
    	set<String> accountIds = new set<String>();
    	set<String> oldEmailList = new set<String>();
    	map<String, Duplicate_Account__c> emailToDuplicateAccountMap = new map<String, Duplicate_Account__c>();
    	map<String, Duplicate_Account__c> emailToDuplicateAccountMapLatest = new map<String, Duplicate_Account__c>();
    	list<Account> accountsToUpdate = new list<Account>();
    	map<String, Duplicate_Account__c> duplicateAccountMapToInsert = new map<String, Duplicate_Account__c>();
    	map<String,Integer> emailToDuplicateNumberMap = new map<String,Integer>();
    	
    	/*creating set of email and acocunt ids*/
    	for(Account record: accountList){
    		if(record.PersonEmail != null && record.PersonEmail != ''){
    			emailList.add(record.PersonEmail);
    			accountIds.add(record.Id);
    			/*creating map to find if there are duplicates in current chunk itself(more than 1 account with same email)*/
    			if(!emailToDuplicateNumberMap.containsKey(record.PersonEmail)){
    				emailToDuplicateNumberMap.put(record.PersonEmail, 1);
    			}else{
    				emailToDuplicateNumberMap.put(record.PersonEmail, (emailToDuplicateNumberMap.get(record.PersonEmail) + 1));
    			}
    		}
    	}
    	
    	/*creating a map of existing duplicate account records*/
    	list<Duplicate_Account__c> duplicateAccountList = [SELECT Email__c, CurrencyIsoCode FROM Duplicate_Account__c WHERE Email__c IN :emailList AND CurrencyIsoCode = :currencyCode];
    	if(duplicateAccountList != null && duplicateAccountList.size() > 0){
    		for(Duplicate_Account__c record: duplicateAccountList){
    			emailToDuplicateAccountMap.put(record.Email__c, record);
    		}
    	}
    	
    	/*querying old accounts where email matches with email list and accpunt ids*/
    	list<Account> oldAccounts = [SELECT PersonEmail, Is_Duplicate_Checked__c FROM Account WHERE IsPersonAccount = true AND PersonEmail IN :emailList AND Id 
    									NOT IN :accountIds AND CurrencyIsoCode = :currencyCode];
    	if(oldAccounts != null && oldAccounts.size() > 0){
	    	for(Account record: oldAccounts){
	    		if(record.PersonEmail != null && record.PersonEmail != ''){
	    			oldEmailList.add(record.PersonEmail);
	    		}
	    	}
    	}
    	
    	
    	if(accountList != null && accountList.size() > 0){
	    	for(Account record: accountList){
	    		/*check if account is in current duplicate records and mark the record as checked*/
	    		if(record.PersonEmail != null && record.PersonEmail != ''){
		    		if(emailToDuplicateAccountMap.containsKey(record.PersonEmail)){
		    			record.Is_Duplicate_Checked__c = true;
		    			record.Duplicate_Account__c = emailToDuplicateAccountMap.get(record.PersonEmail).Id;
		    			accountsToUpdate.add(record);
		    		}
		    		/*check if account matched with old records or if there are duplicates in current chunk itself and mark the record as checked*/
		    		else if((oldEmailList != null && oldEmailList.contains(record.PersonEmail)) || emailToDuplicateNumberMap.get(record.PersonEmail) > 1){
		    			if(!duplicateAccountMapToInsert.containsKey(record.PersonEmail)){
		    				Duplicate_Account__c duplicateRecord = new Duplicate_Account__c(Email__c = record.PersonEmail, CurrencyIsoCode = currencyCode);
		    				duplicateAccountMapToInsert.put(record.PersonEmail, duplicateRecord);
		    			}
		    			record.Is_Duplicate_Checked__c = true;
		    			accountsToUpdate.add(record);
		    		}
		    		/*else mark the record as checked*/
		    		else{
		    			record.Is_Duplicate_Checked__c = true;
		    			accountsToUpdate.add(record);
		    		}
	    		}
	    	}
	    }
	    
	    /*insertng duplicate accounts records*/
	    if(duplicateAccountMapToInsert != null && duplicateAccountMapToInsert.size() > 0){
	    	insert duplicateAccountMapToInsert.values();
	    }
	    
	    /*querying duplicate accounts again to get Ids of new records*/
    	list<Duplicate_Account__c> duplicateAccountListLatest = [SELECT Email__c FROM Duplicate_Account__c WHERE Email__c IN :emailList AND CurrencyIsoCode = :currencyCode];
    	if(duplicateAccountListLatest != null && duplicateAccountListLatest.size() > 0){
    		for(Duplicate_Account__c record: duplicateAccountListLatest){
    			emailToDuplicateAccountMapLatest.put(record.Email__c, record);
    		}
    	}
    	
    	/*updating old accounts with duplicate check flag*/
    	if(emailToDuplicateAccountMapLatest != null && oldAccounts != null){
    		for(Account record: oldAccounts){
    			if(emailToDuplicateAccountMapLatest.containsKey(record.PersonEmail)){
    				if(!record.Is_Duplicate_Checked__c){
    					record.Is_Duplicate_Checked__c = true;
    					accountsToUpdate.add(record);
    				}
    			}
    		}
    	}    	
    	
    	/*updating all accounts with duplicate account record id*/
    	if(emailToDuplicateAccountMapLatest != null){
	    	for(Account record: accountsToUpdate){
				if(record.Duplicate_Account__c == null && emailToDuplicateAccountMapLatest.containsKey(record.PersonEmail)){
					record.Duplicate_Account__c = emailToDuplicateAccountMapLatest.get(record.PersonEmail).Id;
				}
			}
    	}
		
		/*updating all accounts*/
		if(accountsToUpdate!=  null){
    		Database.saveResult [] urList=  Database.update(accountsToUpdate, false);
    		for(Database.saveResult record: urList){
    			if(!record.isSuccess()){
    				for(Database.Error error : record.getErrors()){
    					System.debug('Error : ' +error.getStatusCode() +': ' +error.getMessage());
    				}
    			}
    		}
		}
    	
    }
    global void finish(Database.BatchableContext BC){
       
    }
    
    
}