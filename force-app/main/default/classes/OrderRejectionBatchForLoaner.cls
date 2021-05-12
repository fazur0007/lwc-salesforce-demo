public class OrderRejectionBatchForLoaner implements Database.Batchable<sObject>, Schedulable{
    
    @TestVisible List<Loaner_Nomination__c> LoanerNomListToUpdate = new list<Loaner_Nomination__c>();
    list<Error_Log__c> errorLogs = new list<Error_Log__c>();
    List<Id> LoanerNominationId = new list<Id>();
    @TestVisible private static Id AccountId ;
    @TestVisible private static Id LoanerProgramId;
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='select id,ActivatedByPartner__c,OwnerId,ActivatedById , type,LoanerProgram__c,AccountId,Loaner_Nomination__c,Loaner_Nomination__r.Link_Expiration_date__c'
            +' from Order where type=\'Loaner Program Sale\' AND' 
            +' Status = \'Open\' AND CC_Authorization_ID__c = null AND CC_Transaction_ID__c = null  ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Order> newOrderList){
        for(Order newOrder : newOrderList)
        {
            if(newOrder.Loaner_Nomination__r.Link_Expiration_date__c < system.now()){
                newOrder.status = 'Cancelled';
                System.debug('newOrder id==>'+newOrder.Id);
                LoanerNominationId.add(newOrder.Loaner_Nomination__c);
            }
        }
        
        if(newOrderList != null && newOrderList.size() > 0 ){
            if(Test.isRunningTest()){
                if(AccountId!=null)
                newOrderList.add(new Order(AccountId=AccountId));
            }
            
            Database.SaveResult[] OrdersResult = Database.update(newOrderList, false);
            for (Integer i = 0; i < newOrderList.size(); i++) {
                if (!OrdersResult[i].isSuccess()) {
                    System.debug('Order Error==>'+OrdersResult[i]);
                    Error_Log__c error =  ErrorLog.logErrorActivity('error while Updating  orders',
                                                                    'error while Updating  orders '+OrdersResult[i], 
                                                                    'OrderActivationBatchForLoaner while updating status rejected',false, 'OrderandQuoteCreationBatchForLoanerError');
                    errorLogs.add(error); 
                }
            }
            
        }
        
        if(LoanerNominationId != null && LoanerNominationId.size() > 0 ){
            for(Loaner_Nomination__c lnRec:[SELECT Loaner_Program__c, Account__c, Id, Name,Status__c FROM Loaner_Nomination__c where Id =: LoanerNominationId] ){
                lnRec.Status__c = 'Trial Offer Rejected';
                LoanerNomListToUpdate.add(lnRec);
            }
        }
        
        if(LoanerNomListToUpdate != null && LoanerNomListToUpdate.size() > 0 ){
            if(Test.isRunningTest()){
                if(LoanerProgramId!=null)
                LoanerNomListToUpdate.add(new Loaner_Nomination__c(Loaner_Program__c=LoanerProgramId));
            }
            
            Database.SaveResult[] LoanerNOMResult = Database.update(LoanerNomListToUpdate, false);
            for (Integer i = 0; i < LoanerNomListToUpdate.size(); i++) {
                if (!LoanerNOMResult[i].isSuccess()) {
                    Error_Log__c error =  ErrorLog.logErrorActivity('error while Updating  LoanerNOM',
                                                                    'error while Updating  LoanerNOM '+LoanerNOMResult[i], 
                                                                    'OrderActivationBatchForLoaner while updating status rejected',false, 'OrderandQuoteCreationBatchForLoanerError');
                    errorLogs.add(error); 
                }
            }
        }
        
    }
    public void finish(Database.BatchableContext BC){
    }
}