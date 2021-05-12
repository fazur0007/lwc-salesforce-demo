public class LoanerProgramSelectionBatch implements Database.Batchable<sObject>,Schedulable {
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 20);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String loanerPgmQuery;
        loanerPgmQuery='SELECT Id,Name, Active__c, ProgramName__c,Product__c,Product__r.Quantity_Available__c,Run_Selection_Process__c '+ 
            +'FROM Loaner_Program__c where Active__c=true';
        return Database.getQueryLocator(loanerPgmQuery);
    }
    
    public void execute(Database.BatchableContext BC,List<Loaner_Program__c> loanerProgram){
        
        list<Loaner_Nomination__c> loanerNomSelectedList = new list<Loaner_Nomination__c>();
        List<Loaner_Nomination__c> loanerNomUpdatedList = new List<Loaner_Nomination__c>();
        Map<Id, List<Loaner_Nomination__c>> mapLoanerProgramLoanerNominations = new Map<Id, List<Loaner_Nomination__c>>();
        Map<Id,Decimal> mapLoanerPgmQuantity = new Map<Id, Decimal>();
        
        List<Id> loanerPgmIds;
        Map<Id,Loaner_Program__c> loanerPgmVal=new Map<Id,Loaner_Program__c>();
        String status='Nomination Applied';
        String programName='Control Freak';
        
        for(Loaner_Program__c lp:loanerProgram){
            loanerPgmVal.put(lp.Id,lp);
            
        }
        
        loanerNomSelectedList=[SELECT Id, Name, CreatedDate, Status__c, Account__c, Loaner_Program__c,Loaner_Program__r.Product__r.Quantity_Available__c,
                               Email__c FROM Loaner_Nomination__c where Status__c=:status AND Loaner_Program__c IN :loanerPgmVal.keySet()
                               Order by  CreatedDate ASC Limit: Limits.getLimitQueryRows()];
        
        for(Loaner_Nomination__c loanerNom : loanerNomSelectedList){
            if(mapLoanerProgramLoanerNominations.containsKey(loanerNom.Loaner_Program__c)){
                mapLoanerProgramLoanerNominations.get(loanerNom.Loaner_Program__c).add(loanerNom);
                
            } else {
                mapLoanerProgramLoanerNominations.put(loanerNom.Loaner_Program__c, new List<Loaner_Nomination__c> {loanerNom});
                mapLoanerPgmQuantity.put(loanerNom.Loaner_Program__c,loanerNom.Loaner_Program__r.Product__r.Quantity_Available__c);
            } 
        }
        
        for(Id loanerPgmId:mapLoanerPgmQuantity.keySet()){
            Integer qty=(Integer)mapLoanerPgmQuantity.get(loanerPgmId);
            
            for(Loaner_Nomination__c loanerNom: mapLoanerProgramLoanerNominations.get(loanerPgmId)){
                if(qty>0){
                    loanerNom.Status__c='Selected for Program';
                    loanerNomUpdatedList.add(loanerNom);
                    qty--;
                }
            }
            
            //update loanerNomUpdatedSet;
            Database.SaveResult[] results = Database.update(loanerNomUpdatedList, false);
            for (Integer i = 0; i < loanerNomUpdatedList.size(); i++) {
                if (!results[i].isSuccess()) {
                    String errorMsg=results[i].errors[0].getMessage();        	  
                }
            }   
        }
    }  
    
    public void finish(Database.BatchableContext bc){
        
    } 
    
}