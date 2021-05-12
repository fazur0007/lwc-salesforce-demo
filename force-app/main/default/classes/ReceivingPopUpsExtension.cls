public with sharing class ReceivingPopUpsExtension {
	private Receiving__c receivingRecordForQcAlert;
	public String batchCodeRange {get;set;}
	
	public ReceivingPopUpsExtension(ApexPages.StandardController stdController){
		if (!Test.isRunningTest()) {
			stdController.addFields(new list<String>{'CurrencyIsoCode'});
		}
        this.receivingRecordForQcAlert = (Receiving__c)stdController.getRecord();
        getQCLocations();
    }
    
    public List<QCLocation__c> getQCLocations(){
		if(receivingRecordForQcAlert.CurrencyISOCode != null){
			String regionFromUtility = Utility.regionBased(receivingRecordForQcAlert.CurrencyIsoCode);
			List<QCLocation__c> qcAlertListForRegions = [SELECT Id,ReturnLocation__c,ReturnLocation__r.Name,Region__c, IsActive__c, Batch_Code_From__c, Batch_Code_To__c
															FROM QCLocation__c 
															WHERE Region__c  =: regionFromUtility 
															AND IsActive__c = True 
															AND QCAlert__c =: receivingRecordForQcAlert.QC_Alert__c 
															AND Product__c =: receivingRecordForQcAlert.Received_Product__c
															AND Region__c = :Utility.regionBased(receivingRecordForQcAlert.CurrencyIsoCode)];
			if(qcAlertListForRegions != null && !qcAlertListForRegions.isEmpty()){
				batchCodeRange = qcAlertListForRegions[0].Batch_Code_From__c +' to ' +qcAlertListForRegions[0].Batch_Code_To__c;
				return qcAlertListForRegions;
			}
		}
		return new List<QCLocation__c>();
	}
}