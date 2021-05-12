public with sharing class PriceAPIErrorLog implements Queueable{
	public list<Error_Log__c> errorLogList;
	
	public PriceAPIErrorLog(list<Error_Log__c> errorLogList){
		this.errorLogList = errorLogList;
	}
	
	public void execute(QueueableContext context){
		if(errorLogList != null && errorLogList.size() > 0)
			insert errorLogList;
	}
	
}