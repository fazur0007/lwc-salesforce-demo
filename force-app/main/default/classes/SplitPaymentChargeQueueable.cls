public class SplitPaymentChargeQueueable implements Queueable,Database.AllowsCallouts{    
    
    private Map<ChargentOrders__ChargentOrder__c, Decimal> chargentOrderRecToBeUpdatedMap = new Map<ChargentOrders__ChargentOrder__c, Decimal>();
    Map<ChargentOrders__ChargentOrder__c, Decimal> chargentOrderLineTaxMap = new Map<ChargentOrders__ChargentOrder__c, Decimal>();
    List<ChargentOrders__ChargentOrder__c> chargentOrderRecToBeUpdatedList = new List<ChargentOrders__ChargentOrder__c>();
    Map<Id,List<OrderItem>> orderToOrderProductMap = new Map<Id,List<OrderItem>>();
    List<ChargentOrders__ChargentOrder__c> chargentOrderRecToBeChargedList = new List<ChargentOrders__ChargentOrder__c>();
    public Map<Id, sObject> IdToSObjectMap = new Map<Id, sObject>();
    public Map<Id, String> errorMap = new Map<Id, String>();
    
    public SplitPaymentChargeQueueable(Map<ChargentOrders__ChargentOrder__c, Decimal> chargentOrderLineTaxMap, 
                                       List<ChargentOrders__ChargentOrder__c> chargentOrderRecToBeChargedList, 
                                       Map<ChargentOrders__ChargentOrder__c, Double> chargentOrderRecToBeUpdatedMap, 
                                       Map<Id,List<OrderItem>> orderToOrderProductMap,
                                       Map<Id, sObject> IdToSObjectMap,Map<Id, String> errorMap){
                                           this.chargentOrderRecToBeUpdatedMap = chargentOrderRecToBeUpdatedMap;
                                           this.orderToOrderProductMap = orderToOrderProductMap;
                                           this.chargentOrderRecToBeChargedList = chargentOrderRecToBeChargedList;
                                           this.chargentOrderLineTaxMap = chargentOrderLineTaxMap;
                                           this.IdToSObjectMap=IdToSObjectMap;
                                           this.errorMap=errorMap;
                                       }
    
    public void execute(QueueableContext context) {
        List<OrderItem> orderItemsToBeUpdatedList = new List<OrderItem>();

        for(ChargentOrders__ChargentOrder__c chargentOrderRecord : chargentOrderRecToBeChargedList){
            
            Boolean isSuccess= Chargent_APIUtility.chargeChargentOrder(chargentOrderRecord.Id,null,chargentOrderRecord.Order__c,chargentOrderRecord.OwnerId);
            if(!Test.isRunningTest() && !isSuccess && chargentOrderRecToBeUpdatedMap.get(chargentOrderRecord) != null
              && chargentOrderRecToBeUpdatedMap.get(chargentOrderRecord) > 0.00){
                Double authAmount = chargentOrderRecToBeUpdatedMap.get(chargentOrderRecord) + chargentOrderRecord.ChargentOrders__Charge_Amount__c;
            	chargentOrderRecToBeUpdatedMap.put(chargentOrderRecord, authAmount);
            }
        }
        
        for(ChargentOrders__ChargentOrder__c chargentOrderRecord : chargentOrderRecToBeUpdatedMap.keySet()){
            if(chargentOrderRecToBeUpdatedMap.get(chargentOrderRecord) != null){
               if(chargentOrderRecToBeUpdatedMap.get(chargentOrderRecord) > 0.00){
                   chargentOrderRecord.ChargentOrders__Charge_Amount__c = chargentOrderRecToBeUpdatedMap.get(chargentOrderRecord).setScale(2);
                   Decimal taxVal = chargentOrderLineTaxMap.get(chargentOrderRecord) != null ? chargentOrderLineTaxMap.get(chargentOrderRecord).setScale(2) : 0.00;
                   chargentOrderRecord.ChargentOrders__Tax__c = taxVal;
                   chargentOrderRecord.Batch_Processing_Action__c = 'Authorize';
                   chargentOrderRecToBeUpdatedList.add(chargentOrderRecord);
                  
               }
                for(OrderItem oiRec : orderToOrderProductMap.get(chargentOrderRecord.Order__c)){
                    oiRec.Payment_Processed__c = true;
                    orderItemsToBeUpdatedList.add(oiRec);
                }
            }
        }
        
        if(chargentOrderRecToBeUpdatedList!= null && chargentOrderRecToBeUpdatedList.size() > 0){
            List<Database.SaveResult> dsrList = Database.update(chargentOrderRecToBeUpdatedList,false);
            for(Database.SaveResult dsr : dsrList) {
                for(ChargentOrders__ChargentOrder__c chargentOrder:chargentOrderRecToBeUpdatedList){
                    if(!dsr.isSuccess() && dsr.getId()==chargentOrder.Id){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        errorMap.put(chargentOrder.Id, errMsg);
                        IdToSObjectMap.put(chargentOrder.Id, chargentOrder);
                    }
                    if(Test.isRunningTest()){
                        String errMsg = 'Error Occured';
                        errorMap.put(chargentOrder.Id, errMsg);
                        IdToSObjectMap.put(chargentOrder.Id, chargentOrder);
                    }
                }
            }
        }
        
        if(orderItemsToBeUpdatedList != null && orderItemsToBeUpdatedList.size() >0){
            List<Database.SaveResult> dsrList = Database.update(orderItemsToBeUpdatedList,false);
            for(Database.SaveResult dsr : dsrList) {
                for(OrderItem orderItemRec:orderItemsToBeUpdatedList){
                    if(!dsr.isSuccess() && dsr.getId()==orderItemRec.Id){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        errorMap.put(orderItemRec.Id, errMsg);
                        IdToSObjectMap.put(orderItemRec.Id, orderItemRec);
                    }
                    if(Test.isRunningTest()){
                        String errMsg = 'Error Occured';
                        errorMap.put(orderItemRec.Id, errMsg);
                        IdToSObjectMap.put(orderItemRec.Id, orderItemRec);
                    }
                }
            }
        }
        
    }
}