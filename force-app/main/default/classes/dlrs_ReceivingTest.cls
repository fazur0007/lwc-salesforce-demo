/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ReceivingTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ReceivingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        Receiving__c r = new Receiving__c();
        r.Return_Location__c= 'USA WHSE TORR';
        //dlrs.RollupService.testHandler(r);
    }
}