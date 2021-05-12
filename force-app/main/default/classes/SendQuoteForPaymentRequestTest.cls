@isTest
private class SendQuoteForPaymentRequestTest {

    static testMethod void allMethodsTest() {
		SendQuoteForPaymentRequest senDQuoteRecord = new SendQuoteForPaymentRequest();
		
		Test.startTest();
		
		Id idValue= senDQuoteRecord.getPaymentRequestId();
		senDQuoteRecord.setPaymentRequestId(idValue);
		
		Test.stopTest();
    }
}