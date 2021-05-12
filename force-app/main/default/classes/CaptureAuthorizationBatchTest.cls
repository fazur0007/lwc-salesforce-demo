@isTest(seeAllData=true)
public class CaptureAuthorizationBatchTest {
    
    public static testmethod void testCaptureAuthorizationBatch() {
        Test.startTest();
        list<All_Literal__mdt> whereCondition = [Select Value__c from All_Literal__mdt where Label='PaymentCaptureCondition'];
        
        String query = 'SELECT id, Name, Batch_Processing_Action__c, ' +
            'ChargentOrders__Credit_Card_Type__c, '+
            'Order__r.Id, Order__r.Status, Order__r.CurrencyIsoCode, '+
            'Order__r.Type, Order__r.Ordernumber, '+
            'Workorder__r.Id, Workorder__r.WorkorderNumber, WorkOrder__r.CurrencyIsoCode, '+
            'Scheduled_Payment_Date__c '+
            'FROM ChargentOrders__Transaction__c '+
            'WHERE ChargentOrders__Type__c  = \'Authorization\' ';
        
        if(String.isNotEmpty(whereCondition[0].Value__c)) {
            query += whereCondition[0].Value__c + 'LIMIT 145';
        }
        CaptureAuthorizationBatch cab= new CaptureAuthorizationBatch(query);
        Database.executeBatch(cab);
        Test.stopTest();
    }
    
    public static testmethod void testCaptureAuthorizationBatch2() {
        CaptureAuthorizationBatch cab= new CaptureAuthorizationBatch();
        Database.executeBatch(cab);
    }
    
    static testmethod void testCaptureAuthorizationBatchSchedulable() {
        Test.startTest();
        CaptureAuthorizationBatch cab= new CaptureAuthorizationBatch();
        String jobID = System.schedule('Schedule for all records Test ' + System.now(), '0 0 15 * * ?', cab);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}