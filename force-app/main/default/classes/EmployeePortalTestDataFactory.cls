public with sharing class EmployeePortalTestDataFactory {
	public static List<EmployeePortalSettings__c> createCustomSettings(){
    	List<EmployeePortalSettings__c>  allSettings = new List<EmployeePortalSettings__c>();
    	EmployeePortalSettings__c settings = new EmployeePortalSettings__c();
    	settings.Name = 'accountOwnerId';
    	settings.Value__c =  '005E00000085UOu';
		allSettings.add(settings);
		
		settings = new EmployeePortalSettings__c();
    	settings.Name = 'communityProfileName';
    	settings.Value__c =  'Employee Portal Community';
		allSettings.add(settings);
		
		settings = new EmployeePortalSettings__c();
    	settings.Name = 'allowedDomains';
    	settings.Value__c =  'brevilleusa.com';
		allSettings.add(settings);
		
		settings = new EmployeePortalSettings__c();
    	settings.Name = 'restrictDomain';
    	settings.Value__c =  '1';
		allSettings.add(settings);
		
		return allSettings;
    }
    
    public static Account createAccountRecord(String email){
        Account acct = new Account();
        acct.FirstName = 'TestFName';
    	acct.LastName = 'TESTLNAME';
    	acct.personEmail = email;
    	acct.Phone = '99865656565';
    	acct.BillingCountryCode = 'US';
    	acct.BillingStreet = 'Central Avenue';
    	acct.BillingCity = 'SEATTLE';
    	acct.BillingStateCode = 'WA';
    	acct.BillingPostalCode = '98104';
    	return acct;
    }
    
}