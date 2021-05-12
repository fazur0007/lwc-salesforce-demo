public without sharing class RefundChargedAccommodationOrders {
    @InvocableMethod(label='Refund Transactions')
    public static void findTransactions(List<Id> orderIds) {
        
        String query = 'SELECT Id, ChargentOrders__Order__c, Batch_Processing_Action__c, Order__c, WorkOrder__c, '
                        + 'Order__r.OwnerId, WorkOrder__r.OwnerId, CC_Auth_Exp__c, '
                        + 'Order__r.CC_Authorization_ID__c, ChargentOrders__Authorization__c '
                        + 'FROM ChargentOrders__Transaction__c '
                        + 'WHERE ChargentOrders__Type__c  = \'Charge\' '
                        + 'AND Order__r.ID IN :orderIds';
        
        List<ChargentOrders__Transaction__c> transactionList = Database.query(query);
        
        for(ChargentOrders__Transaction__c ctRec : transactionList) {
            Id parentRecordId = ctRec.Order__c;
            Id ownerId = ctRec.Order__r.OwnerId;
            if(ctRec.ChargentOrders__Authorization__c == ctRec.Order__r.CC_Authorization_ID__c) {
                Chargent_APIUtility.refundChargedTransaction(ctRec.Id,'Payment Refund', parentRecordId, ownerId);
            }
        }
    }
}