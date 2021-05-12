/* This class will be used to assign Contact Id and Owner Id to Case that will be created automatically while creating Work Order without Case Number. */

public with sharing class UpdateContactIdOnCase implements Queueable{
	
	Set<Id> caseIdSet = new Set<Id>();
	Map<Id, Id> accountIdToContactId = new Map<Id, Id>();
	List<Case> caseList = new List<Case>();
	All_Literal__mdt literal;
	
	public UpdateContactIdOnCase(Set<Id> caseIdSet){
		literal = [select Value__c from All_Literal__mdt where DeveloperName='CustomUserId' LIMIT 1];
		this.caseIdSet = caseIdSet;
		caseList = [SELECT Id, Origin, AccountId, Account.PersonContactId from Case WHERE Id IN :caseIdSet AND origin = 'Partner'];
		for(Case caseRecord : caseList){
			accountIdToContactId.put(caseRecord.AccountId, caseRecord.Account.PersonContactId);
		}
	}
	
	public void execute(QueueableContext context) {
		for(Case caseRecord : caseList){
			caseRecord.ContactId = accountIdToContactId.get(caseRecord.AccountId);
			caseRecord.ownerId = Id.valueOf(literal.Value__c);
		}
		Database.update(caseList, false);
	}
	
}