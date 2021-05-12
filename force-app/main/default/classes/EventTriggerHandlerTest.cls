@isTest
public class EventTriggerHandlerTest{
	
	static testMethod void setupSampleData(){
		Account accountRecord = new Account();
        accountRecord.Name = 'Test Name';
        accountRecord.ShippingStreet = 'Street';
        accountRecord.ShippingCity = 'Street';
        accountRecord.ShippingState = 'NY';
        accountRecord.ShippingPostalCode = '92501';
        accountRecord.ShippingCountry = 'USA';
        insert accountRecord;
        
        Site_Visit__c siteVisitRecord = new Site_Visit__c();
        siteVisitRecord.Account__c = accountRecord.Id;
        siteVisitRecord.Out_of_Stock_Models__c = '800BLXL';
		siteVisitRecord.Knowledge_Products__c = '800BLXL';
        siteVisitRecord.CurrencyIsoCode = 'USD';
        insert siteVisitRecord;
        
        Event eventRecord = new Event();
        eventRecord.WHatId = siteVisitRecord.Id;
        eventRecord.Subject = 'TEST Subject';
        eventRecord.DurationInMinutes = 10;
        eventRecord.ActivityDateTime = DateTime.now();
        insert eventRecord;
        
	}

}