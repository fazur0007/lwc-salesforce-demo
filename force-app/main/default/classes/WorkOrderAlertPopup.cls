public without sharing class WorkOrderAlertPopup{
	public boolean showAlert 					{get;set;}
	private WorkOrder workOrderRecordForQcAlert;
	
	public WorkOrderAlertPopup(ApexPages.StandardController stdController){
		showAlert = false;
		if (!Test.isRunningTest()) {
			stdController.addFields(new list<String>{'CurrencyIsoCode'});
			stdController.addFields(new list<String>{'Product__c'});
		}
        this.workOrderRecordForQcAlert = (WorkOrder)stdController.getRecord();
        list<WorkOrder> worOrderlist = [SELECT Id, CaseId, Case.QC_Alert__C from WorkOrder where Id =: workOrderRecordForQcAlert.Id];
        if(worOrderlist!= null && worOrderlist.size() > 0 && worOrderlist[0].CaseId != null &&  worOrderlist[0].Case.QC_Alert__C != null){
        	showAlert = true;
        }
        getQCLocations();
    }
    
    public List<QCLocation__c> getQCLocations(){
		if(workOrderRecordForQcAlert.CurrencyISOCode != null){
			String regionFromUtility = Utility.regionBased(workOrderRecordForQcAlert.CurrencyIsoCode);
			List<QCLocation__c> qcAlertListForRegions = [SELECT Id,ReturnLocation__c,ReturnLocation__r.Name,Region__c, IsActive__c FROM QCLocation__c 
															WHERE Region__c  =: regionFromUtility 
															AND IsActive__c = True 
															AND QCAlert__c =: workOrderRecordForQcAlert.Case.QC_Alert__c 
															AND Product__c =: workOrderRecordForQcAlert.Product__c];
			if(qcAlertListForRegions != null && !qcAlertListForRegions.isEmpty()){
				return qcAlertListForRegions;
			}
		}
		return new List<QCLocation__c>();
	}
}