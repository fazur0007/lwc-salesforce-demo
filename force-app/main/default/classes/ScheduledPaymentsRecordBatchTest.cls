@isTest
private class ScheduledPaymentsRecordBatchTest {

    static testMethod void batchtest(){

        DateTime now  = DateTime.now().addMinutes(30);
        String cronString = '0 0 0 * * ?';

        Test.startTest();
        Id jobId = System.schedule(ScheduledPaymentsRecordBatch.class.getName() + '-' + now.format(),
                                       cronString,
                                       new ScheduledPaymentsRecordBatch());
        Test.stopTest();
    }
}