public with sharing class TaxRateUtility {
    
    public static Tax_Rate__c findAppropriateTaxRateRecord(String currencyCode, sObject orderOrWorkOrder, Account serviceCentre){
    	
    	Tax_Rate__c taxRate;
    		
    	//Query Master Tax Data and fetch how tax data need to be retrieved.
    	list<MasterTaxData__mdt> masterTaxDataList = [SELECT DeveloperName, IsZip2TaxApplicable__c, AddressFieldOnOrder__c, AddressFieldOnWorkOrder__c, CacheDurationInDays__c 
    														FROM MasterTaxData__mdt
    														WHERE DeveloperName =: currencyCode];
    	if(masterTaxDataList != null && masterTaxDataList.size() > 0){
    		
    		MasterTaxData__mdt masterTaxDataRecord = masterTaxDataList[0];
    		//Order/Work Order field name whose value would be used as a filter e.g. zip/state/country
    		String addressFieldValue;
    		if(String.valueOf(orderOrWorkOrder.getSObjectType()).equalsIgnoreCase('Order')){
    			if(((String)orderOrWorkOrder.get(masterTaxDataRecord.AddressFieldOnOrder__c)) != null && ((String)orderOrWorkOrder.get(masterTaxDataRecord.AddressFieldOnOrder__c)) != ''){
    				addressFieldValue = (String)orderOrWorkOrder.get(masterTaxDataRecord.AddressFieldOnOrder__c);
    			}
    		}else{
    			if(((String)serviceCentre.get(masterTaxDataRecord.AddressFieldOnWorkOrder__c)) != null && ((String)serviceCentre.get(masterTaxDataRecord.AddressFieldOnWorkOrder__c)) !=''){
    				addressFieldValue = (String)serviceCentre.get(masterTaxDataRecord.AddressFieldOnWorkOrder__c);
    			}
    			//addressFieldValue = (String)orderOrWorkOrder.getSobject('ServiceCentre__r').get(masterTaxDataRecord.AddressFieldOnWorkOrder__c);
    		}
    		
    		//Check whether whether zip2tax is applicable or not, else query the respective 
    		if(masterTaxDataRecord.IsZip2TaxApplicable__c){
    			Integer cacheDays = Integer.valueOf(masterTaxDataRecord.CacheDurationInDays__c);
    			if(cacheDays == null){
    				cacheDays = 30;
    			}
    			taxRate = queryTaxRateRecord(addressFieldValue, currencyCode);
    			if(taxRate != null && taxRate.LastModifiedDate.addDays(cacheDays) > DateTime.now()){
    				return taxRate;
    			}else{
    				if(addressFieldValue != null && addressFieldValue != ''){
    					return Zip2Tax.fetchTaxRateFromZipToTax(addressFieldValue, currencyCode, taxRate);
    				}else{
    					return null;
    				}	
    			}
    			
    		}else{
    			if(addressFieldValue != null && addressFieldValue != ''){
    				taxRate = queryTaxRateRecord(addressFieldValue, currencyCode);
    			}
    		}
    	}														
    	
    	return taxRate;
    }
    
    public static Tax_Rate__c queryTaxRateRecord(String filterValue, String currencyCode){
    	list<Tax_Rate__c> taxRateRecords = [SELECT Id, Name, LastModifiedDate, CitySalesTaxRate__c, City_Use_Tax_Rate__c, Combined_Rate__c, CombinedUseTaxRate__c, GST_Tax_Rate__c,
    											Country_Use_Tax_Rate__c, CountyUseTaxRate__c, Provincial_Tax_Rate__c, SpecialSalesTaxRate__c, SpecialUseTaxRate__c, StateUseTaxRate__c,
    											County_Sales_Tax_Rate__c, PricesInclusiveOfTaxes__c
    											FROM Tax_Rate__c
    											WHERE Name =: filterValue 
    											AND CurrencyIsoCode =: currencyCode  ORDER BY LastModifiedDate DESC LIMIT 1];
    	if(taxRateRecords != null && taxRateRecords.size() > 0){
    		return taxRateRecords[0];
    	}
    	
    	return null;										
    }
    
}