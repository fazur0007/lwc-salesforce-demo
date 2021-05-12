/*
	Created to Share Receivings with users which are not owned by them.
	Parameters:
		usersId : userId to share the records with
		returnLocation: return location of Receiving
		currencyCode : currency of Receiving
*/


global class ShareReceivingsBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	Id userId;
	String returnLocation;
	String currencyCode;
	
	global ShareReceivingsBatch(Id userId, String returnLocation, String currencyCode){
		this.userId = userId;
		this.returnLocation = returnLocation;
		this.currencyCode = currencyCode;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
        Date todaysDate = Date.today();
        String query = 'SELECT Id, Return_Location__c FROM Receiving__c '+ 
                        + 'WHERE Return_Location__c = :returnLocation AND OwnerId != :userId AND CurrencyIsoCode = :currencyCode';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Receiving__c> receivingList){
    	list<Receiving__Share> recordsToShare = new list<Receiving__Share>();
		for(Receiving__c record : receivingList){
		    recordsToShare.add(SharingUtility.createReceivingShare(record.Id, userId));
		}
		
		Database.SaveResult[] saveResult;
		list<Error_Log__c> errorLogs = new list<Error_Log__c>();
		if(recordsToShare != null && recordsToShare.size() > 0){
		    System.debug('Receiving Size : ' +recordsToShare.size());
		    saveResult = Database.insert(recordsToShare);
		}
		
		
		/* saving the result of failed Receivings in error log */
		if(saveResult != null && saveResult.size() > 0){
		    for(Integer i = 0; i < saveResult.size(); i++) {
		        if (!saveResult[i].isSuccess()) {
		            Error_Log__c error = ErrorLog.logErrorActivity('Error while sharing old Receiving records with portal users',
		                                                           saveResult[i].errors[0].getMessage(), 
		                                                           'Anonymous Block',false, 'Error in sharing Receivings', null, null, null); 
		            errorLogs.add(error);
		        }
		    }
		}
		
		if(!errorLogs.isEmpty()){
		    System.debug('Error Log Size : ' +errorLogs.size());
		    insert errorLogs;
		}
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}