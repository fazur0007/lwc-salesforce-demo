global class BatchTriggerMulberryWarrantyCancellation implements Database.Batchable<Sobject>,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<Case> lstCase = [select id,AssetId,Asset.Trigger_Mulberry_Cancellation__c from case where RA_Delivered__c=true and AssetId!='' and Asset.Trigger_Mulberry_Cancellation__c=true];
        system.debug('Total record count:'+lstCase.size());
        return Database.getQueryLocator([select id,AssetId,Asset.Trigger_Mulberry_Cancellation__c from case where RA_Delivered__c=true and AssetId!='' and Asset.Trigger_Mulberry_Cancellation__c=true]);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
        system.debug('Test inside execute');
        for(Case currCase:scope)
        {
            MulberryAPIHelper.CancelWarranty(currCase.Id);
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Test inside final');
    }

}