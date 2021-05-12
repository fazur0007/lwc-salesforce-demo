public with sharing class NewWorkOrderHelperClass {
	
	User currentUser;
	Boolean isPortalUser;
	Account serviceCenter;
	
	public NewWorkOrderHelperClass(ApexPages.StandardController controller){
		currentUser = [SELECT Id, IsPortalEnabled, AccountID, DefaultCurrencyIsoCode, Contact.Account.ShippingPostalCode, 
									Contact.Account.ShippingStateCode, Contact.Account.ShippingCountryCode, Contact.AccountId 
						FROM User 
						WHERE Id =: UserInfo.getUserId()];
		isPortalUser = currentUser.IsPortalEnabled;
		serviceCenter = new Account(
									ShippingPostalCode = currentUser.Contact.Account.ShippingPostalCode,
									ShippingStateCode = currentUser.Contact.Account.ShippingStateCode,
									ShippingCountryCode = currentUser.Contact.Account.ShippingCountryCode
									);
	}	
	
	public PageReference getRedirect(){
		Tax_Rate__c taxRate = TaxRateUtility.findAppropriateTaxRateRecord(currentUser.DefaultCurrencyIsoCode, new WorkOrder(), serviceCenter);
		Id workRecorRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Work Order').getRecordTypeId();
		PageReference newPage = new PageReference('/0WO/e?nooverride=1&RecordType=' +workRecorRecordTypeId);		
        return newPage.setRedirect(true);
	}
}