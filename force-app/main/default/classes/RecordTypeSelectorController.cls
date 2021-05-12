public class RecordTypeSelectorController { 
    @AuraEnabled
    public static WorkOrder getConfigData(String workOrderId){
        return [Select Id,Status From WorkOrder Where Id =:workOrderId Limit 1];
    }
    @AuraEnabled
    public static String createClaim(String workOrderId){
       return ClaimUtility.createClaim(workOrderId);
    }
}