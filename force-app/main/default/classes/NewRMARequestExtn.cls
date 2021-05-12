public with sharing class NewRMARequestExtn { 
	
	public Case newRMACase				{get;set;}
	private Boolean isPortalUser;
	
    public NewRMARequestExtn(ApexPages.StandardController stdController) {
    	
        this.newRMACase = (Case)stdController.getRecord();
        User currentUser = getCurentUser();
        isPortalUser = currentUser.IsPortalEnabled;
        if(currentUser.IsPortalEnabled){
        	newRMACase.AccountId = currentUser.AccountId;
        	newRMACase.ContactId = currentUser.ContactId;
        	
        }
        
        newRMACase.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get(ApplicationLiterals.RMA_CASE_RECORD_TYPE).getRecordTypeId();
    	if(isPortalUser){
    		newRMACase.Origin = ApplicationLiterals.RMA_CASE_ORIGIN;
    	}
    	
    	newRMACase.Type = ApplicationLiterals.RMA_CASE_TYPE;
        prePopulateRMABasicInfromation();
        
        
        
    }
    public void prePopulateRMABasicInfromation(){ 
    	//Set record type id
    	system.debug('###'+newRMACase.AccountId);
    	if(newRMACase.AccountId != null ){
    		list<Account> acctList = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode,
									      	 BillingCountryCode, ShippingStreet, ShippingCity, ShippingState,
									      	 ShippingPostalCode, ShippingCountryCode,CurrencyISOCode
									      	 FROM Account WHERE Id=:newRMACase.AccountId];
									      	 
			if(acctList != null && !acctList.isEmpty()){
				newRMACase.CurrencyISOCode = acctList[0].CurrencyISOCode;
				newRMACase.Pickup_Address_1__c = acctList[0].ShippingStreet != null?acctList[0].ShippingStreet:acctList[0].BillingStreet;
				newRMACase.Pickup_City__c = acctList[0].ShippingCity != null?acctList[0].ShippingCity:acctList[0].BillingCity;
				newRMACase.Pickup_Postal_Code__c = acctList[0].ShippingPostalCode != null?acctList[0].ShippingPostalCode:acctList[0].BillingPostalCode;
				newRMACase.Pickup_State__c = acctList[0].ShippingState != null?acctList[0].ShippingState:acctList[0].BillingState;
				newRMACase.Pickup_Country__c = acctList[0].ShippingCountryCode != null?acctList[0].ShippingCountryCode:acctList[0].BillingCountryCode;
				//newRMACase.Pickup_Address_1__c = acctList[0].BillingCountry;
				
			}
			
    	}
    	if(newRMACase.ContactId != null ){
    		list<Contact> conList = [SELECT Name, Phone, Email
									      	 FROM Contact WHERE Id=:newRMACase.ContactId];
			if(conList != null && !conList.isEmpty()){
				newRMACase.Consignee_Contact_Name__c = conList[0].Name;
				newRMACase.Consignee_Email__c = conList[0].Email;
				newRMACase.Consignee_Phone__c = conList[0].Phone;
				
			}
    	}else if(newRMACase.AccountId != null){
    		list<Contact> conList = [SELECT Name, Phone, Email
									      	 FROM Contact WHERE AccountId =:newRMACase.AccountId ];
			if(conList != null && !conList.isEmpty()){
				newRMACase.ContactId = conList[0].Id;
				newRMACase.Consignee_Contact_Name__c = conList[0].Name;
				newRMACase.Consignee_Email__c = conList[0].Email;
				newRMACase.Consignee_Phone__c = conList[0].Phone;
				
			}
    	}
    }
    private User getCurentUser(){
    	return [SELECT IsPortalEnabled,AccountId,contact.Account.CurrencyIsoCode,ContactId FROM User WHERE Id =:UserInfo.getUserId()];
    } 
    public PageReference cancel(){
	    PageReference pageRef;
	    if(isPortalUser)
	    	 pageRef = Page.RMARequest;
	   	else
	   		pageRef = new PageReference('/500/');
	    pageRef.setredirect(false);       
	    return pageRef; 
    } 
}