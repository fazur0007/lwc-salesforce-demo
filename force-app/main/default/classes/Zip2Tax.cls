public with sharing class Zip2Tax {
	
	//Method to fetch tax information using zip coes specifically for 
	public static Tax_Rate__c fetchTaxRateFromZipToTax(String zipcode, String currencyCode, Tax_Rate__c existingTaxRateRecord){
		
		Http httpProtocol = new Http();
		HttpRequest request = new HttpRequest();
		
		String endpoint = Utility.fetchAllLiteralValue('Zip2TaxEndPoint');
		if(endpoint != null){
			endpoint += zipcode;
		}
		
		request.setEndPoint(endpoint);
		request.setMethod('GET');
		HttpResponse response;
		if(!Test.isRunningTest()){
			try{
				response = httpProtocol.send(request); 		
			}catch(Exception ex){
				Errorlog.logErrorActivity(ex, 'Error while call out to Zip2Tax API for : '+ zipcode, true, 'Error');
			}
		}
		Zip2Tax.Zip2TaxBean beanObj = new Zip2Tax.Zip2TaxBean(); 
		//beanObj.parse(response.getBody());
		
		Tax_Rate__c taxRate;
		if(response != null){
			taxRate = convertZip2TaxBeanToTaxRateRecord(beanObj.parse(response.getBody()), currencyCode);
		}
		if(taxRate != null){
			if(existingTaxRateRecord != null){
				taxRate.Id = existingTaxRateRecord.Id;
			}
			taxRate.Name = zipcode;
			upsert taxRate;
		}
		return taxRate;
	}
	
	public static Tax_Rate__c convertZip2TaxBeanToTaxRateRecord(Zip2Tax.Zip2TaxBean zip2TaxBeanObject, String currencyCode){
		Tax_Rate__c taxRateRec = new Tax_Rate__c();
		
		//Set currency Code for the record
		taxRateRec.CurrencyIsoCode = currencyCode;
		taxRateRec.PricesInclusiveOfTaxes__c = false;
		list<Zip2Tax.Addresses> zip2TaxAddressesList= zip2TaxBeanObject.z2tLookup.addressInfo.addresses;
		if(zip2TaxAddressesList != null && zip2TaxAddressesList.size() > 0){
			Zip2Tax.Address zipToTaxAddress = zip2TaxAddressesList[0].address;
			
			//Sales Tax
			Zip2Tax.RateInfo salesTaxRateInfo = zipToTaxAddress.salesTax.rateInfo;
			//taxRateRec.Combined_Rate__c = Double.valueOf(salesTaxRateInfo.taxRate);
			taxRateRec.GST_Tax_Rate__c = 0;
			
			for(Zip2Tax.RateDetails rateDetails : salesTaxRateInfo.rateDetails){
				if(rateDetails.rateDetail.jurisdictionLevel.equalsIgnoreCase('State')){
					taxRateRec.Provincial_Tax_Rate__c = Double.valueOf(rateDetails.rateDetail.taxRate);
				}
				if(rateDetails.rateDetail.jurisdictionLevel.equalsIgnoreCase('County')){
					taxRateRec.County_Sales_Tax_Rate__c = Double.valueOf(rateDetails.rateDetail.taxRate);
				}
				if(rateDetails.rateDetail.jurisdictionLevel.equalsIgnoreCase('City')){
					taxRateRec.CitySalesTaxRate__c = Double.valueOf(rateDetails.rateDetail.taxRate);
				}				
			}
			taxRateRec.Combined_Rate__c = taxRateRec.Provincial_Tax_Rate__c + taxRateRec.County_Sales_Tax_Rate__c + taxRateRec.CitySalesTaxRate__c;
			
			//Use Tax
			Zip2Tax.RateInfo useTaxRateInfo = zipToTaxAddress.useTax.rateInfo;
			//taxRateRec.CombinedUseTaxRate__c = Double.valueOf(useTaxRateInfo.taxRate); 
			taxRateRec.Country_Use_Tax_Rate__c = 0;
			
			for(Zip2Tax.RateDetails rateDetails : useTaxRateInfo.rateDetails){
				if(rateDetails.rateDetail.jurisdictionLevel.equalsIgnoreCase('State')){
					taxRateRec.StateUseTaxRate__c = Double.valueOf(rateDetails.rateDetail.taxRate);
				}
				if(rateDetails.rateDetail.jurisdictionLevel.equalsIgnoreCase('County')){
					taxRateRec.CountyUseTaxRate__c = Double.valueOf(rateDetails.rateDetail.taxRate);
				}
				if(rateDetails.rateDetail.jurisdictionLevel.equalsIgnoreCase('City')){
					taxRateRec.City_Use_Tax_Rate__c = Double.valueOf(rateDetails.rateDetail.taxRate);
				}				
			}
			taxRateRec.CombinedUseTaxRate__c = taxRateRec.StateUseTaxRate__c + taxRateRec.CountyUseTaxRate__c + taxRateRec.City_Use_Tax_Rate__c; 
			
			return taxRateRec;
		}
		return null;
	}
	
	/*Start Bean Classes*/
	public class Z2tLookup {
		public ErrorInfo errorInfo;
		public AddressInfo addressInfo;
	}
	
	public class ErrorInfo {
		public String errorCode;	//0
		public String errorMessage;	//Success
		public String elapsedTime;	//00:00.60
		public String startTime;	//2016-08-28 09:49:37.5547
		public String endTime;	//2016-08-28 09:49:38.1557
		public String ServerName;	//CASPER06
		public String Version;	//1.0.5
		public Warnings[] warnings;
	}
	public class Warnings {
		public String warning;	//Login: Success (brevilla @ level 3)
	}
	public class AddressInfo {
		public String addressResolution;	//ZIP
		public Addresses[] addresses;
	}
	public class Addresses {
		public Address address;
	}
	public class Address {
		public String place;	//Ponte Vedra
		public String state;	//FL
		public String zipCode;	//32081
		public String county;	//Saint Johns
		public String Latitude;	//30.1736
		public String Longitude;	//-81.3956
		public SalesTax salesTax;
		public UseTax useTax;
		public Notes[] notes;
	}
	public class SalesTax {
		public RateInfo rateInfo; 
	}
	public class RateInfo {
		public String taxRate;	//6.5000
		public RateDetails[] rateDetails;
	}
	public class RateDetails {
		public RateDetail rateDetail;
	}
	public class RateDetail {
		public String jurisdictionLevel;	//State
		public String jurisdictionCode;	//
		public String taxRate;	//6.0000
		public String authorityName;	//State of FL
	}
	public class UseTax {
		public RateInfo rateInfo;
	}
	public class Notes {
		public NoteDetail noteDetail;
	}
	public class NoteDetail {
		public String jurisdiction;	//State of FL
		public String category;	//Special Rate
		public String note;	//Portion over $5000 is only taxed at the State Rate of 6%
	}
	
	public class Zip2TaxBean{
	
		public Z2tLookup Z2tLookup;
		
		public Zip2TaxBean parse(String json){
			return (Zip2TaxBean) System.JSON.deserialize(json, Zip2TaxBean.class);
		}
	}
    /*End Bean Classes*/
}