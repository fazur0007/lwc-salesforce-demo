@isTest(SeeAllData=true)
public with sharing class RefundChargedOrderBatchTest {
    
    static testMethod void testRefundChargedOrderBatch(){
        
        String query = 'SELECT Id, ChargentOrders__Order__c, Batch_Processing_Action__c, Order__c, '
            + 'Order__r.OwnerId, CC_Auth_Exp__c '
            + 'FROM ChargentOrders__Transaction__c '
            + 'WHERE ChargentOrders__Type__c  = \'Charge\' '
            + 'AND Batch_Processing_Action__c = \'Refund\' '
            + 'AND Scheduled_Payment_Date__c <= TODAY LIMIT 1 ';
        RefundChargedOrderBatch refundChargedOrderBatchObj = new RefundChargedOrderBatch(query);
        //String jobId = System.schedule('Test', '0 0 15 * * ?', new RefundChargedOrderBatch());
        Database.executeBatch(refundChargedOrderBatchObj);
    }
    
    /*static testMethod void testSchedulable(){
        Test.startTest();
        String jobId = System.schedule('Test', '0 0 15 * * ?', new RefundChargedOrderBatch());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }*/
}