@isTest
private class Chargent_APIUtilityTest {

    static testMethod void allTestMethods() {
        Chargent_APIUtility.chargeAuthorizedTransactionFuture(null,'abc',null,null);
        Chargent_APIUtility.voidTransaction(null,'abc',null,null);
        Chargent_APIUtility.authorizeChargentOrder(null,'abc',null,null);
        Chargent_APIUtility.refundChargedTransactionFuture(null,'abc',null,null);
        Chargent_APIUtility.parseChargentResultV2(null,null,'abc',null,null);
        Chargent_APIUtility.chargeChargentOrder(null,'abc',null,null);
    }
}