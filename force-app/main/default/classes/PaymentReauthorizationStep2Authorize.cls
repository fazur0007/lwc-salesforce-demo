public with sharing class PaymentReauthorizationStep2Authorize implements Queueable, Database.AllowsCallouts {
    
    private Id transactionId;
    private Id parentRecordId;
    private Id ownerId;

    public PaymentReauthorizationStep2Authorize(Id transactionId,Id parentRecordId,Id ownerId){
        this.transactionId = transactionId;
        this.parentRecordId = parentRecordId;
        this.ownerId = ownerId;
    }
    public void execute(QueueableContext context) {
        Chargent_APIUtility.authorizeChargentOrder(transactionId,'Payment Reauthorization', parentRecordId,ownerId);
    }
    
}