public class CaptureAuthorizationBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private final String soqlQuery;
    public List<Error_Log__c> errorList= new List<Error_Log__c>();
    public List<Database.SaveResult> saveresultList = new List<Database.SaveResult>();
    public Map<String, List<ChargentOrders__Transaction__c>> recordsToReport = new Map<String, List<ChargentOrders__Transaction__c>>();
    public CaptureAuthorizationBatch(String query){
        this.soqlQuery = query;
    }
    
    public CaptureAuthorizationBatch(){
        list<All_Literal__mdt> whereCondition = [Select Value__c from All_Literal__mdt where Label='PaymentCaptureCondition'];
        
        String query = 'SELECT id, Name, Batch_Processing_Action__c, ' +
            'ChargentOrders__Credit_Card_Type__c, '+
            'Order__r.Id, Order__r.Status, Order__r.CurrencyIsoCode, '+
            'Order__r.Type, Order__r.Ordernumber, '+
            'Workorder__r.Id, Workorder__r.WorkorderNumber, WorkOrder__r.CurrencyIsoCode, '+
            'Scheduled_Payment_Date__c '+
            'FROM ChargentOrders__Transaction__c '+
            'WHERE ChargentOrders__Type__c  = \'Authorization\' '+
            'AND Batch_Processing_Action__c = \'\' '+
            'AND CC_Auth_Exp__c <= NEXT_N_DAYS:2 '+
            'AND ((Order__c != null AND Order__r.Type IN '+
            '(\'Sale\', \'Employee Sale\', \'Accommodation\', \'Retail Employee Sales\', \'Partner & Associate Sales\', \'Retail Event Sales\', \'Specialty Roaster\', \'Holiday Promo\', \'Event Sales Coffee\') '+
            ') OR Workorder__r.WorkOrderNumber != null) ';
        
        if(String.isNotBlank(whereCondition[0].Value__c)) {
            query += whereCondition[0].Value__c;
        }
        this.soqlQuery = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(SchedulableContext sc) {
        CaptureAuthorizationBatch capAuthBatch = new CaptureAuthorizationBatch();
        Database.executeBatch(capAuthBatch, 200);
    }
    
    public void execute(Database.BatchableContext BC, List<ChargentOrders__Transaction__c> transactionList){
        for(ChargentOrders__Transaction__c transactionRecord : transactionList){
            if((transactionRecord.Order__c != NULL && transactionRecord.Order__r.Type == 'Accommodation')||(transactionRecord.Order__c != NULL
                     && (transactionRecord.Order__r.Status == 'Order Pending'
                      || transactionRecord.Order__r.Status == 'In Approval'
                      || transactionRecord.Order__r.Status == 'Order Generated'
                      || transactionRecord.Order__r.Status == 'Open')
                    && (transactionRecord.Order__r.Type == 'Sale' 
                        || transactionRecord.Order__r.Type == 'Employee Sale' 
                        || transactionRecord.Order__r.Type == 'Retail Employee Sales'
                        || transactionRecord.Order__r.Type == 'Partner & Associate Sales' 
                        || transactionRecord.Order__r.Type == 'Retail Event Sales'
                        || transactionRecord.Order__r.Type == 'Event Sales Coffee' 
                        || transactionRecord.Order__r.Type == 'Holiday Promo' 
                        || transactionRecord.Order__r.Type == 'Specialty Roaster'))||transactionRecord.WorkOrder__c != NULL) {
                transactionRecord.Batch_Processing_Action__c = 'Capture';
              transactionRecord.Scheduled_Payment_Date__c =  Date.TODAY();
            }
        }
        saveresultList.addAll(Database.update(transactionList, false));
    }
    
    public void finish(Database.BatchableContext bc) {
    }  
}