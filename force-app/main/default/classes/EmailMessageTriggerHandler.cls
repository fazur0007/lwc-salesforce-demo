/*
* Functionality :    
* Trigger handler to assign the case in a particular queue based on region and currency. 
* Revision History: 
*
* Version       Author            Date            Description 
*  1.0        Payal Yadav      08/10/2016        Initial Draft 
 */
public without sharing class EmailMessageTriggerHandler{
	
	//public static boolean beforeTriggerRun = true; 
	public static boolean afterTriggerRun = true;
		
	private static String refKey = System.Label.EmailToCaseRefKey;
	
	
	/*public static boolean runOnceAfterTrigger(){
		if(afterTriggerRun){
            afterTriggerRun = false;
            return true;
        }else{
            return afterTriggerRun;
        }
    }*/
	
	/*public static boolean runOnceBeforeTrigger(){
		if(beforeTriggerRun){
            beforeTriggerRun = false;
            return true;
        }else{
            return beforeTriggerRun;
        }
    }
    
    public static void truncateEmailHeader(list<EmailMessage> triggerNew){
    	for(EmailMessage msg : triggerNew){
    		if(msg.Headers != null && msg.Headers != '' && msg.Headers.length() >= 32000){
    			msg.Headers = msg.Headers.left(32000);
    		}
    	}
    }*/
	
	public static void populateCurrencyCodeInCase(list<EmailMessage> triggerNew){  
		map<Id, list<EmailMessage>> emailMessageIdForCaseCreation = new Map<Id, list<EmailMessage>>{};
		set<String> toAddressSet = new set<String>() ;
		map<String, EmailToCaseConfiguration__mdt> regionalEmailToCurrencyMap  = new map<String, EmailToCaseConfiguration__mdt>();
		map<Id,String> caseIDToEmailAddressMap = new map<Id,String>();
		list<Case> caseListToUpdate = new list<Case>();
		map<Id, String> caseIdToOwnerType = new map<Id, String>();
        
        set<String> accountEmailSet = new set<String>();
    	map<Id,EmailMessage> caseIdToFromEmailMessageMap = new map<Id,EmailMessage>();
    	map<String,Account> emailToAccountmap = new map<String,Account>();
    	list<Case> casesToUpadte = new list<Case>();
    	
    	set<Id> oldAccountsIdSet = new set<Id>();
    	list<EmailMessage> clonedEmailMessageList = new list<EmailMessage>();
    	
    	map<Id, Task> idToTaskMap = new map<Id, Task>();
    	set<String> regionEmail = new set<String>();
         
        /* loading all email configurations from metadata */
        for(EmailToCaseConfiguration__mdt masterData : [SELECT RegionEmail__c, AssociatedBrand__c, RegionCurrency__c, Country__c,
        												DontAllowDuplicateCases__c FROM EmailToCaseConfiguration__mdt]){
			regionalEmailToCurrencyMap.put(masterData.RegionEmail__c, masterData);
			regionEmail.add(masterData.RegionEmail__c);
		}
         
		/* iterating the emailmessage record */
		for(EmailMessage emailMessageRecord : triggerNew){
			/* creating caseIDToEmailAddressMap for case to 'To address' mapping */
			if(checkForValidNewIncomingMail(emailMessageRecord)){
				list<String> emailAddressSet = getAllAddresses(emailMessageRecord);
				for(String email : emailAddressSet){
					if(regionalEmailToCurrencyMap.containsKey(email.trim())){
						caseIDToEmailAddressMap.put(emailMessageRecord.ParentId, email.trim());
						break;
					}
				}
			}
			
			/* creating caseIdToFromEmailMessageMap for case to 'from address' email message mapping */
			if(emailMessageRecord.Incoming){
    			if(emailMessageRecord.FromAddress != null && emailMessageRecord.FromAddress != ''){
	    			accountEmailSet.add(String.valueOf(emailMessageRecord.FromAddress));
	    		}
	    		if(emailMessageRecord.FromAddress != null && emailMessageRecord.FromAddress != '' && emailMessageRecord.ParentId != null){
	    			caseIdToFromEmailMessageMap.put(emailMessageRecord.ParentId, emailMessageRecord);
	    		}
    		}
    		
		}
		
		/* getting all old accounts using email message from address */                                  
    	for(Account accountRecord : [SELECT Id, FirstName, LastName, PersonEmail, PersonContactId FROM Account where PersonEmail IN :accountEmailSet]){
    		emailToAccountmap.put(accountRecord.PersonEmail, accountRecord);
    		oldAccountsIdSet.add(accountRecord.Id);
    	}
    	
    	/* creating case Id to case map to update all cases at once */		
		map<Id,Case> idToCaseMapToUpdate = new map<Id,Case>([SELECT Id, OwnerId, Owner.Type, AccountId, CurrencyIsoCode FROM Case WHERE ID IN: caseIDToEmailAddressMap.keySet()]);
		if(caseIDToEmailAddressMap != null && caseIDToEmailAddressMap.size() > 0){
			for(Case casrec : idToCaseMapToUpdate.values()){
				if(casrec.OwnerId != null && casrec.Owner.Type != null){
					caseIdToOwnerType.put(casrec.Id, casrec.Owner.Type);
				}
			}
		} 
        
        /* iterating through new cases to populate country, brand, currency and alias on case */
        if(regionalEmailToCurrencyMap != null && idToCaseMapToUpdate != null){       
			for(Id caseId : caseIDToEmailAddressMap.keySet()){
				if(caseIDToEmailAddressMap != null && caseIDToEmailAddressMap.containskey(caseId) && regionalEmailToCurrencyMap.containsKey(caseIDToEmailAddressMap.get(caseId))
					&& regionalEmailToCurrencyMap.get(caseIDToEmailAddressMap.get(caseId)) != null){
					if(idToCaseMapToUpdate != null && idToCaseMapToUpdate.size() > 0){
						Case caseRecord = idToCaseMapToUpdate.get(caseId);
						caseRecord.currencyISOcode = regionalEmailToCurrencyMap.get(caseIDToEmailAddressMap.get(caseId)).RegionCurrency__c;
						caseRecord.Country__c = regionalEmailToCurrencyMap.get(caseIDToEmailAddressMap.get(caseId)).Country__c;
						caseRecord.brand__c = regionalEmailToCurrencyMap.get(caseIDToEmailAddressMap.get(caseId)).AssociatedBrand__c;
						caseRecord.To_Address__c = caseIDToEmailAddressMap.get(caseId);
					}
				}
			}
        }
		
		/* populating account on case */
		populateAccountOnCase(emailToAccountmap, idToCaseMapToUpdate, caseIDToEmailAddressMap, caseIdToFromEmailMessageMap, regionEmail);
    	
    	/* getting cloned email message list */								
    	clonedEmailMessageList = checkForDuplicateCase(idToCaseMapToUpdate, caseIDToEmailAddressMap, caseIdToOwnerType, 
    												oldAccountsIdSet, regionalEmailToCurrencyMap, caseIdToFromEmailMessageMap, idToTaskMap);
		
		/* updating cases */
		try{
			update idToCaseMapToUpdate.values();
		}catch(Exception ex){
			ErrorLog.logErrorActivity(ex, 'While upadting case with currency code in Email2Case', true, 'Email to Case Error');
		}
		
		/* populate email message on old case if old open case is found for customer */
		if(clonedEmailMessageList != null && clonedEmailMessageList.size() > 0){
			try{
				afterTriggerRun = false;
				insert clonedEmailMessageList;
			}catch(Exception ex){
				ErrorLog.logErrorActivity(ex, 'while insering cloned email messages in Email2Case', true, 'Email to Case Error');
			}
		}
		
		/* updating Tasks to reference to old cases and changing owner */
		try{
			if(idToTaskMap != null && idToTaskMap.size() > 0){
				update idToTaskMap.values();
			}
		}catch(Exception ex){
			ErrorLog.logErrorActivity(ex, 'While upadting Tasks with owner and old case in Email2Case', true, 'Email to Case Error');
		}
		
	}
    
    /* to populate account on case */
    private static void populateAccountOnCase(map<String,Account> emailToAccountmap, map<Id,Case> idToCaseMapToUpdate, map<Id,String> caseIDToEmailAddressMap,
    									map<Id,EmailMessage> caseIdToFromEmailMessageMap, set<String> regionEmail){
    	
    	list<Account> accountsToAdd = new list<Account>();
    	set<Id> accountIsDet = new set<Id>();
    	map<Id, Account> caseIdToAccountMap = new map<Id, Account>();									
    	if(caseIDToEmailAddressMap != null && caseIDToEmailAddressMap.size() > 0){
    		if(caseIdToFromEmailMessageMap != null && caseIdToFromEmailMessageMap.size() > 0){
    			if(idToCaseMapToUpdate != null && idToCaseMapToUpdate.size() > 0){
			    	for(Id caseId : caseIDToEmailAddressMap.keySet()){
			    		if(caseIdToFromEmailMessageMap != null && caseIdToFromEmailMessageMap.size() > 0 && 
			    			!regionEmail.contains(caseIdToFromEmailMessageMap.get(caseId).FromAddress)){
							Case caseRecord = idToCaseMapToUpdate.get(caseId);
							/* if account is available, populate account and contact on case */
					    	if(caseRecord.AccountId == null && caseIdToFromEmailMessageMap != null && caseIdToFromEmailMessageMap.size() > 0){
								if(emailToAccountmap != null && emailToAccountmap.size() > 0 && caseIdToFromEmailMessageMap.get(caseRecord.Id) != null &&
										emailToAccountmap.containsKey(caseIdToFromEmailMessageMap.get(caseRecord.Id).FromAddress)){
									caseRecord.AccountId = emailToAccountmap.get(caseIdToFromEmailMessageMap.get(caseRecord.Id).FromAddress).Id;
									caseRecord.ContactId = emailToAccountmap.get(caseIdToFromEmailMessageMap.get(caseRecord.Id).FromAddress).PersonContactId;
									
									if(caseRecord.AccountId != null){
										idToCaseMapToUpdate.put(caseId,caseRecord);
									}
									
								}else{
									/* creating new account */
									Account accountToAdd = createAccount(caseIdToFromEmailMessageMap.get(caseRecord.Id), caseRecord.CurrencyIsoCode);
									accountsToAdd.add(accountToAdd);
									caseIdToAccountMap.put(caseRecord.Id, accountToAdd);
									idToCaseMapToUpdate.put(caseId,caseRecord);
								}
							}
			    		}
			    	}
    			}
    		}
    	}
    	
    	/* adding new accounts */
    	if(accountsToAdd != null && accountsToAdd.size() > 0){
    		try{
				insert accountsToAdd;
				map<Id,Account> idToAccountMap = new map<Id,Account>();
		    	if(accountsToAdd != null && accountsToAdd.size() > 0){
		    		idToAccountMap = new map<Id,Account>([SELECT Id, PersonContactId FROM Account where Id IN :accountsToAdd]);
		    	}
		    	
		    	/* assingning new account and contact to case*/
		    	for(Case caseRecord : idToCaseMapToUpdate.values()){
		    		if(caseIdToAccountMap != null && caseIdToAccountMap.size() > 0 && caseIdToAccountMap.get(caseRecord.Id) != null
		    				&& idToAccountMap != null && idToAccountMap.size() > 0 && idToAccountMap.get(caseIdToAccountMap.get(caseRecord.Id).Id) != null){
		    			caseRecord.AccountId = caseIdToAccountMap.get(caseRecord.Id).Id;
		    			caseRecord.ContactId = idToAccountMap.get(caseIdToAccountMap.get(caseRecord.Id).Id).PersonContactId;
		    		}
		    	}
			}catch(Exception ex){
				ErrorLog.logErrorActivity(ex, 'While adding Accounts in Email2Case', true, 'Email to Case Error');
			}
    	}
    	
    }
    
	/* to check duplicate case */
    private static list<EmailMessage> checkForDuplicateCase(map<Id,Case> idToCaseMapToUpdate, map<Id,String> caseIDToEmailAddressMap, map<Id, String> caseIdToOwnerType,
    					set<Id> oldAccountsIdSet, map<String, EmailToCaseConfiguration__mdt> regionalEmailToCurrencyMap, map<Id,EmailMessage> caseIdToFromEmailMessageMap,
    					map<Id, Task> idToTaskMap){
    												
    	map<Id, Case> accountIdToRecentCaseMap= new map<Id,Case>();
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.useDefaultRule= true;
		list<EmailMessage> clonedEmailMessageList = new list<EmailMessage>();
		/* getting case status from metadata that we have to consider for case duplication */
		list<All_Literal__mdt> caseStatus = [Select Value__c from All_Literal__mdt where DeveloperName='OldCaseStatusForEmailToCase'];
		String oldCaseQuery = 'SELECT Id, ParentId, AccountId, Status, CurrencyIsoCode, OwnerId FROM Case WHERE AccountId IN :oldAccountsIdSet AND ' +caseStatus[0].Value__c 
								+' ORDER BY CreatedDate DESC';
		list<Case> oldCaseList = Database.query(oldCaseQuery);
		
		/* iterating through cases to create map of accountToRegionToCases to get all cases associated with account */							
		for(Case caseRecord : oldCaseList){
			if(!caseIdToFromEmailMessageMap.containsKey(caseRecord.Id)){
				System.debug('## accountIdToRecentCaseMap.containsKey(caseRecord.AccountId) : ' +accountIdToRecentCaseMap.containsKey(caseRecord.AccountId));
				if(!accountIdToRecentCaseMap.containsKey(caseRecord.AccountId)){
					accountIdToRecentCaseMap.put(caseRecord.AccountId, caseRecord);
					System.debug('## CaseId : ' +caseRecord.Id);
				}
			}
		}
		
    	/* iterating through cases to find duplicate case */
    	if(caseIDToEmailAddressMap != null && caseIDToEmailAddressMap.size() > 0){
    		if(caseIdToFromEmailMessageMap != null && caseIdToFromEmailMessageMap.size() > 0){
    			if(idToCaseMapToUpdate != null && idToCaseMapToUpdate.size() > 0 && accountIdToRecentCaseMap != null && accountIdToRecentCaseMap.size() > 0){
			    	for(Id caseId : caseIDToEmailAddressMap.keySet() ){
						Case caseRecord = idToCaseMapToUpdate.get(caseId);
						if(accountIdToRecentCaseMap.containsKey(caseRecord.AccountId)){
							Case caseRec = accountIdToRecentCaseMap.get(caseRecord.AccountId);

							/* if dupliclate case found, change status and clone email message */
							if(regionalEmailToCurrencyMap.get(caseIDToEmailAddressMap.get(caseId)).DontAllowDuplicateCases__c){
	    						caseRecord.parentId = caseRec.Id;
	    						EmailMessage emailMessageClone = caseIdToFromEmailMessageMap.get(caseId).clone(false, true, false, false);
			    				emailMessageClone.parentId = caseRec.Id;
			    				//emailMessageClone.activityId = null;
			    				clonedEmailMessageList.add(emailMessageClone);
			    				caseRecord.status = 'Closed';
			    				caseRecord.Closed_Reason__c = 'Auto Email Duplicated';
			    				
			    				/* updated task to assign it to old case */
			    				if(String.valueOf(caseRec.OwnerId).startsWith('005')){
			    					Task taskRecord = new Task(Id=caseIdToFromEmailMessageMap.get(caseId).activityId, WhatId = caseRec.Id, ownerId = caseRec.OwnerId);
			    					idToTaskMap.put(caseIdToFromEmailMessageMap.get(caseId).activityId, taskRecord);
			    				}else{
			    					Task taskRecord = new Task(Id=caseIdToFromEmailMessageMap.get(caseId).activityId, WhatId = caseRec.Id);
			    					idToTaskMap.put(caseIdToFromEmailMessageMap.get(caseId).activityId, taskRecord);
			    				}
							}
						}
						if(caseIdToOwnerType == null || (caseIdToOwnerType != null && !caseIdToOwnerType.containsKey(caseId)) ||
						 (caseIdToOwnerType != null && caseIdToOwnerType.containsKey(caseId) && caseIdToOwnerType.get(caseId).equalsIgnorecase('Queue'))){
							idToCaseMapToUpdate.get(caseId).setOptions(dmlOpts);
						}
			    	}
    			}
		    	
    		}
    	}
    	return clonedEmailMessageList;
    }
    
    /* get all 'to address' from email message (toAddress, ccAddress ) */
    private static list<String> getAllAddresses(EmailMessage emailMessageRecord){
    	list<String> emailList = new list<String>();
    	if(emailMessageRecord.ToAddress != null && emailMessageRecord.ToAddress != ''){
    		emailList = emailMessageRecord.ToAddress.split('\\;');
		}
		if(emailMessageRecord.CcAddress != null && emailMessageRecord.CcAddress != ''){
			emailList.addAll(emailMessageRecord.CcAddress.split('\\;'));
		}
		return emailList;
    	
    }
    
    /* validating new incoming emails*/
    public static Boolean checkForValidNewIncomingMail(EmailMessage emailMessageRecord){
    	
    	//check if it is incoming
    	if(!(emailMessageRecord.Incoming && emailMessageRecord.ToAddress !=null)){
    		return false;
    	}
    	//check if subject contains ref id
    	if(emailMessageRecord.subject != null && emailMessageRecord.subject.containsIgnoreCase(refKey)){
    		return false;
    	}
    	//check if text body contain ref id
    	if(emailMessageRecord.TextBody != null  && emailMessageRecord.TextBody.containsIgnoreCase(refKey)){
    		return false;
    	}
    	//check if Html  body contain ref id
    	if(emailMessageRecord.HtmlBody != null  && emailMessageRecord.HtmlBody.containsIgnoreCase(refKey)){
    		return false;
    	}
         											 
    	return true;
    }
    
    /* creating account and assigning currencyIdoCode */
    private static Account createAccount(EmailMessage em, String CurrencyIsoCode){
    	String name = '';
    	if(em.FromName != null && em.FromName !=''){
    		name = em.FromName;
    	}
    	String FirstName='';
    	String LastName='';
    	String[] strings = new String[]{};
    	if(name != null && name != ''){
    		strings = name.split(' ');
    	}else{
    		LastName = em.FromAddress;
    	}
    	
    	if(strings != null && strings.size() > 1){
    		FirstName = strings[0];
    		LastName = strings[1];
    	}else if(strings.size() > 0){
    		LastName = strings[0];	
    	}else{
    		LastName = em.FromAddress;
    	}
    	All_Literal__mdt literal = [select Value__c from All_Literal__mdt where DeveloperName='CustomUserId' LIMIT 1];
        
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
    	Account newAccount = new Account(firstName = FirstName, lastName = LastName, PersonEmail = em.FromAddress, CurrencyIsoCode = CurrencyIsoCode,
    											OwnerId = Id.valueOf(literal.Value__c), RecordTypeId=personAccountRecordTypeId);
    	return newAccount; 
    	
    }
}