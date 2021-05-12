global class BatchForDeletingBulkShipment implements Database.batchable<SObject>,Schedulable{ 
   
   global void execute(SchedulableContext sc) {
      Database.executeBatch(new BatchForDeletingBulkShipment());
   }
   global List<Sobject> start(Database.BatchableContext BC) {
   		
   		list<SObject> bulkShipments = new list<SObject>();
        List<SObject> zmulti =  [SELECT Id FROM zkmulti__MCBulk_Shipment__c where CreatedDate < LAST_N_DAYS:30];
        if(zmulti != null && zmulti.size() > 0){
        	bulkShipments.addAll(zmulti);
        }
        List<SObject> zfedex =  [SELECT Id FROM zkfedex__BulkShipment__c where CreatedDate < LAST_N_DAYS:30];
        if(zfedex != null && zfedex.size() > 0){
        	bulkShipments.addAll(zfedex);
        }
        List<Sobject> zups =  [SELECT Id FROM zkups__BulkShipment__c where CreatedDate < LAST_N_DAYS:30];
        if(zups != null && zups.size() > 0){
        	bulkShipments.addAll(zups);
        }
        return bulkShipments;
      
    } 
    
    
   
   global void execute(Database.batchableContext info, List<SObject> scope){ 
       	 delete scope;
       	 DataBase.emptyRecycleBin(scope); 
   }
   		
   global void finish(Database.batchableContext info){
   		//do nothing.      
   } 
}