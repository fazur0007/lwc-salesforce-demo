@isTest
private class ScheduledOrderPaymentBatchTest {

    static testMethod void batchtest(){

        DateTime now  = DateTime.now().addMinutes(30);
        String cronString = '0 0 0 * * ?';

        Test.startTest();
        Id jobId = System.schedule(ScheduledOrderPaymentBatch.class.getName() + '-' + now.format(),
                                       cronString,
                                       new ScheduledOrderPaymentBatch());
        Test.stopTest();
    }
}