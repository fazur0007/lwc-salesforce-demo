/*
* Functionality :
* Extenstion controller for QCalertPopup page to show the pop up message based on Batch code,complaint code and product 
* Revision History: 
*
* Version       Author            Date            Description 
*  1.0        Payal Yadav      09/05/2016        Initial Draft 
 */
public with sharing class CaseAlertPopup{
	private Case caseRecordForQcAlert;
	
	public CaseAlertPopup(ApexPages.StandardController stdController){
		if (!Test.isRunningTest()) {
			stdController.addFields(new list<String>{'CurrencyIsoCode'});
		}
        this.caseRecordForQcAlert = (Case)stdController.getRecord();
        getQCLocations();
    }
    
    public List<QCLocation__c> getQCLocations(){
		if(caseRecordForQcAlert.CurrencyISOCode != null){
			String regionFromUtility = Utility.regionBased(caseRecordForQcAlert.CurrencyIsoCode);
			List<QCLocation__c> qcAlertListForRegions = [SELECT Id,ReturnLocation__c,ReturnLocation__r.Name,Region__c, IsActive__c FROM QCLocation__c 
															WHERE Region__c  =: regionFromUtility 
															AND IsActive__c = True 
															AND QCAlert__c =: caseRecordForQcAlert.QC_Alert__c 
															AND Product__c =: caseRecordForQcAlert.Product__c];
			if(qcAlertListForRegions != null && !qcAlertListForRegions.isEmpty()){
				return qcAlertListForRegions;
			}
		}
		return new List<QCLocation__c>();
	}
}