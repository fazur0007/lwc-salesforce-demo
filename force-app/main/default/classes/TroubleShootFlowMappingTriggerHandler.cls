public without sharing class TroubleShootFlowMappingTriggerHandler {
    
    private static boolean beforeTriggerRun = true;
    //private static boolean afterTriggerRun = true;
    
    public static boolean runOnceBeforeTrigger(){
        if(beforeTriggerRun){
            beforeTriggerRun = false;
            return true;
        }else{
            return beforeTriggerRun;
        }
    }
    
    public static void populateProductId(list<Trouble_Shoot_Flow_Mapping__c> troubleshootRecords){
    
    	for(Trouble_Shoot_Flow_Mapping__c troubleshootRecord : troubleshootRecords){
    		troubleshootRecord.Unique_Field__c = '';
    		if(troubleshootRecord.Product__c != null){
    			troubleshootRecord.Unique_Field__c += troubleshootRecord.Product__c;
    		}
    		if(troubleshootRecord.Product_Category__c != null && troubleshootRecord.Product_Category__c != ''){
    			troubleshootRecord.Unique_Field__c += troubleshootRecord.Product_Category__c;
    		}
    		if(troubleshootRecord.Product_Sub_Category__c != null && troubleshootRecord.Product_Sub_Category__c != ''){
    			troubleshootRecord.Unique_Field__c += troubleshootRecord.Product_Sub_Category__c;
    		}
    		if(troubleshootRecord.Flow_Name__c != null && troubleshootRecord.Flow_Name__c != ''){
    			troubleshootRecord.Unique_Field__c += troubleshootRecord.Flow_Name__c;
    		}
    		if(troubleshootRecord.Complaint_Code__c != null && troubleshootRecord.Complaint_Code__c != ''){
    			troubleshootRecord.Unique_Field__c += troubleshootRecord.Complaint_Code__c;
    		}
    	}
    }
}