/*
* Functionality :
* This class is a driver class on the Accounts trigger. This class populates 
* the Billing_Street__1, Billing_Streer__2 with data from the BillingStreet on
* the account. It also populates Shipping_Street_1 and Shipping_Street_2 with
* data from the ShippingStreet field on the account.

* Revision History: 
*
* Version       Author            Date            Description 
*  1.0        Payal Yadav      08/10/2016        Initial Draft 
 */
 public class AccountTriggerHandler{
 	
 	public static boolean beforeTriggerRun = true;
 	public static boolean afterTriggerRun = true;
     
	public static boolean runOnceBeforeTrigger(){
		if(beforeTriggerRun){
			beforeTriggerRun = false;
			return true;
		}else{
			return beforeTriggerRun;
		}
	}
	
	public static boolean runOnceAfterTrigger(){
		if(afterTriggerRun){
			afterTriggerRun = false;
			return true;
		}else{
			return afterTriggerRun;
		}
	}
	
	/**
	 * This method is called by the trigger for either insert or update
	 */
	public static void updateStreets(List<Account> accounts){
		populateBillingFields(accounts);
		//populateShippingFields(accounts);
	}
		
	/**
	 * This method will appropriately populate the Billing_Street_Line fields
	 */
	public static void populateBillingFields(List<Account> accts){
		
		Set<Id> parentIdsList = new Set<Id>();
		
		for(Account accountRecords : accts){
			parentIdsList.add(accountRecords.ParentId);
		}
		
		map<Id,Account> parentMap = new map<Id,Account>([SELECT Id, Billing_Street_Line_1__c, Billing_Street_Line_2__c,
																			BillingCountryCode, BillingCity, BillingStateCode, BillingPostalCode 
															FROM Account WHERE Id in :parentIdsList]); 
		
		for(Account a : accts){
			if(a.ParentId != null && parentMap.containsKey(a.ParentId) && a.isPersonAccount == false){
				Account parent = parentMap.get(a.ParentId);
				if(parent.Billing_Street_Line_1__c != null && parent.Billing_Street_Line_1__c != ''){
					a.Billing_Street_Line_1__c = parent.Billing_Street_Line_1__c;
					a.BillingStreet = a.Billing_Street_Line_1__c;
				}
				if(parent.Billing_Street_Line_2__c != null &&  parent.Billing_Street_Line_2__c != ''){
					a.Billing_Street_Line_2__c = parent.Billing_Street_Line_2__c;
					if(a.BillingStreet != null && a.BillingStreet != ''){
						a.BillingStreet = a.BillingStreet + a.Billing_Street_Line_2__c;	
					}else{
						a.BillingStreet = a.Billing_Street_Line_2__c;		
					}
				}
				
				a.BillingCountryCode = parent.BillingCountryCode; 
				a.BillingCity = parent.BillingCity;
				a.BillingStateCode = parent.BillingStateCode;
				a.BillingPostalCode = parent.BillingPostalCode;
				
			}
			
			/*
			if(a.BillingStreet == null || a.BillingStreet == ''){
				a.Billing_Street_Line_1__c = null;
				a.Billing_Street_Line_2__c = null;
				
			} else if(a.BillingStreet.contains('\n')){
				String[] bStreet = a.BillingStreet.split('\n');
				String line1 = bStreet[0].trim();
				String line2 = bStreet[1].trim();
				a.Billing_Street_Line_1__c = line1.length() > 30 ? line1.substring(0,30) : line1;
				a.Billing_Street_Line_2__c = line2.length() > 30 ? line2.substring(0,30) : line2;
					
			} else {
				a.Billing_Street_Line_1__c = a.BillingStreet.length() > 30 ? a.BillingStreet.substring(0,30) : a.BillingStreet;
				a.Billing_Street_Line_2__c = null;
			}*/
		}
	}
	
	/**
	 * This method will populate the Shippint_Street_Line fields.
	 
	public static void populateShippingFields(Account[] accounts){
		for(Account a : accounts){
			if(a.ShippingStreet == null || a.ShippingStreet == ''){
				a.Shipping_Street_Line_1__c = null;
				a.Shipping_Street_Line_2__c = null;
			}
			else if(a.ShippingStreet.contains('\n')){
				String[] sStreet = a.ShippingStreet.split('\n');
				String line1 = sStreet[0].trim();
				String line2 = sStreet[1].trim();
				a.Shipping_Street_Line_1__c = line1.length() > 30 ? line1.substring(0,30) : line1;
				a.Shipping_Street_Line_2__c = line2.length() > 30 ? line2.substring(0,30) : line2;
			}
			else {
				a.Shipping_Street_Line_1__c = a.ShippingStreet.length() > 30 ? a.ShippingStreet.substring(0,30) : a.ShippingStreet;
				a.Shipping_Street_Line_2__c = null;
			}
		}
	}*/
	
	public static void shareChildAccountWithParentUser(list<Account> newAccountRecords){
		
		map<Id,list<Account>> parentChildMap = new map<Id,list<Account>>();
		List<AccountShare> sharesToCreate = new List<AccountShare>();
        for(Account accountRecords : newAccountRecords){
			if(accountRecords.ParentId != NULL){
				if(parentChildMap.containskey(accountRecords.ParentId)){
					parentChildMap.get(accountRecords.ParentId).add(accountRecords);
				}else{
					parentChildMap.put(accountRecords.ParentId, new list<Account>{accountRecords});
				}
			}
        }
        
        if(parentChildMap.keySet() != null && parentChildMap.size() > 0){
	        for(User user : [Select Id, AccountId from User where AccountId IN: parentChildMap.keySet()]){
	        	for(Account childAccount : parentChildMap.get(user.AccountId)){
	        		sharesToCreate.add(Utility.createUserShare(childAccount.Id, user.Id));
	        	}
	        }
        }
        
        if(sharesToCreate.size() > 0){
        	Database.SaveResult[] srList = Database.insert(sharesToCreate, false);

			// Iterate through each returned result
			for (Database.SaveResult sr : srList) {
			    if (sr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        ErrorLog.logAdditionalErrorInfo('Successfully shared child account with parent user. Account ID: ' + sr.getId());
			    } else {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            //ErrorLog.logErrorActivity(err, err.getStatusCode() + ': ' + err.getMessage() ,true, 'Error');
			        }
			    }
			}
        }
	}
	
	public static void updateEmailOptOut(list<Account> newAccountRecords, map<Id, Account> oldMap){
		for(Account accountRecord : newAccountRecords){
			if(accountRecord.IsPersonAccount){
                if(accountRecord.Subscribe_to_our_newsletter__c){
                	if(Trigger.isUpdate && oldMap.get(accountRecord.Id).PersonHasOptedOutOfEmail && !oldMap.get(accountRecord.Id).Subscribe_to_our_newsletter__c){
                		accountRecord.PersonHasOptedOutOfEmail = false;
                	}else{
                		if(accountRecord.PersonHasOptedOutOfEmail){
                			accountRecord.Subscribe_to_our_newsletter__c = false;
                		}
                	}
                }
			}
		}
	}
     
    public static void updateAccountDataToUser(List<Account> accountList, Map<Id, Account> triggerOldMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        Id myBrvProfileId = UserTriggerHandler.GetExternalIdentityProfileId();
        
        for(Account recAccount : accountList) {
            Account acctOldRec = triggerOldMap.get(recAccount.Id);
            if(recAccount.IsPersonAccount && recAccount.IsCustomerPortal && acctOldRec != null &&  
                    (recAccount.FirstName != acctOldRec.FirstName || recAccount.LastName != acctOldRec.LastName)){
                accountIdSet.add(recAccount.Id);
            }
        }
         
        if (accountIdSet.isEmpty())
            return;
         
        List<Account> tobeUpdatedAccountList = new List<Account>();
        for (Account recAcct : [SELECT Id, FirstName, Lastname,
                                (SELECT Id, FirstName, LastName, ProfileId, Profile.Name FROM Users) 
                                FROM Account where Id =:accountIdSet])
        {
            List<User> userList = recAcct.Users;
            if (userList == null || userList.isEmpty())
                continue;
            User recUser = userList.get(0);
            if (recUser.ProfileId == myBrvProfileId)
                tobeUpdatedAccountList.add(recAcct);
        }
        if (tobeUpdatedAccountList.isEmpty())
            return;
        
        System.enqueueJob(new UpdateAccountDataToUser(tobeUpdatedAccountList));
    }
}