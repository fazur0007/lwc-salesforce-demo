/**

 */
@isTest
private class OrderPaymentsBatchTest {

    static testMethod void myUnitTest() {

        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;

        Order objOrder = new Order();
        objOrder.AccountId = objAcc.Id;
        objOrder.Source__c = 'Argo';
        objOrder.EffectiveDate = system.today();
        objOrder.CC_Authorization_ID__c = 'Text';
        objOrder.Status = 'Open';
        objOrder.Type = 'Sale';
        insert objOrder;
        
        pymt__PaymentX__c objPayment = new pymt__PaymentX__c();
        objPayment.pymt__Transaction_Type__c = 'Authorization';
        objPayment.pymt__Transaction_Id__c = objOrder.CC_Authorization_ID__c;
        insert objPayment;
        
        Test.startTest();
        Database.executeBatch(new OrderPaymentsBatch(), 200);
        Test.stopTest();
    }
}