@isTest
private class PaymentReauthorizationStep2AuthorizeTest {

    static testMethod void myUnitTest() {
    	Test.startTest();
        PaymentReauthorizationStep2Authorize record = new PaymentReauthorizationStep2Authorize(null, null, null);
        record.execute(null);
        test.stopTest();
    }
}