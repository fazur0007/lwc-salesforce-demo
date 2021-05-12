/* 
* TaxRate is the Trigger on Order which will run on before insert/update
*
* Functionality :
* 1)The trigger will run when the order ShippingPostalCode value
*   match with Tax_Rate__c object.
*
* 2)AutoPopulate US_tax_rate__c, GST_TaxRate__c, Provincial_Tax_Rate__c 
*   when shipping postal code match with Tax_Rate__c.
*
* Revision History: 
*rectypeCanOrder
* Version       Author             Date           Description 
*  1.0        Yogesh Sharma       08/27/2015     Initial Draft 
*  1.1        Yogesh Sharma       09/10/2015     Removed filter criteria on Order
*  1.2        Yogesh Sharma       05/12/2016     Added Filter criteria if record 
*                                                type is canada then match the value with shipping state
*/
public class TaxRate {
    //Method will get called before insert/update of Order record
    public void filterOrders(Order orderRecord){
    	
    	String metadataByCurrency = 'TaxEnforedStateCodes_' +orderRecord.CurrencyIsoCode;
    	list<All_Literal__mdt> literalMetadataList = [SELECT DeveloperName, Value__c FROM All_Literal__mdt where DeveloperName= :metadataByCurrency AND 
    										CurrencyISOCode__c = :orderRecord.CurrencyIsoCode LIMIT 1];
    	
    	if(literalMetadataList != null && literalMetadataList.size() > 0 && !literalMetadataList[0].Value__c.containsIgnoreCase(';' +orderRecord.ShippingStateCode +';')){
    		orderRecord.TaxExemptDueToStateCode__c = true;
    	}else{
    		orderRecord.TaxExemptDueToStateCode__c = false;
    	}
    	
    	/* if tax exemption is true, Tax will be zero. */
    	if(orderRecord.Tax_Exempt_Order__c || orderRecord.TaxExemptDueToStateCode__c){
    		orderRecord.GST_Tax_Rate__c = 0;
    		orderRecord.CitySalesTaxRate__c = 0;
    		orderRecord.CountySalesTaxRate__c = 0;
    		orderRecord.Provincial_Tax_Rate__c = 0;
    		orderRecord.SpecialSalesTaxRate__c = 0;
    		orderRecord.Sales_Tax_Rate__c = 0;
    	}else{
    		Tax_Rate__c taxRateRecord = TaxRateUtility.findAppropriateTaxRateRecord(orderRecord.CurrencyIsoCode,orderRecord, null);
	      	if(taxRateRecord != null){
	      		orderRecord.PricesInclusiveOfTaxes__c = taxRateRecord.PricesInclusiveOfTaxes__c;
	  			if(taxRateRecord.GST_Tax_Rate__c != null)
	  				orderRecord.GST_Tax_Rate__c = taxRateRecord.GST_Tax_Rate__c;
	  			else
	  				orderRecord.GST_Tax_Rate__c = 0;
	  		 
				if(taxRateRecord.CitySalesTaxRate__c != null)
	  				orderRecord.CitySalesTaxRate__c = taxRateRecord.CitySalesTaxRate__c;
	  			else
	  				orderRecord.CitySalesTaxRate__c = 0;
				
				if(taxRateRecord.County_Sales_Tax_Rate__c != null)
	  				orderRecord.CountySalesTaxRate__c = taxRateRecord.County_Sales_Tax_Rate__c;
	  			else
	  				orderRecord.CountySalesTaxRate__c = 0;
				
				if(taxRateRecord.Provincial_Tax_Rate__c != null)
	  				orderRecord.Provincial_Tax_Rate__c = taxRateRecord.Provincial_Tax_Rate__c;
	  			else
	  				orderRecord.Provincial_Tax_Rate__c = 0;
				
				if(taxRateRecord.SpecialSalesTaxRate__c != null)
	  				orderRecord.SpecialSalesTaxRate__c = taxRateRecord.SpecialSalesTaxRate__c;
	  			else
	  				orderRecord.SpecialSalesTaxRate__c = 0;
				
				if(taxRateRecord.Combined_Rate__c != null)
	  				orderRecord.Sales_Tax_Rate__c = taxRateRecord.Combined_Rate__c;
	  			else
	  				orderRecord.Sales_Tax_Rate__c = 0;
					
	      	}
    	}
		
    }//End filterOrders


   //Auto populate the US TaxRate on Order as per matching postal Code on Tax Rate.
    //**********************************************************************WORK ORDER*****************************
    
    public void filterWorkOrders(WorkOrder workOrder, Account serviceCentre){
    	
    	String metadataByCurrency = 'TaxEnforedStateCodes_' +workOrder.CurrencyIsoCode;
    	list<All_Literal__mdt> literalMetadataList = [SELECT DeveloperName, Value__c FROM All_Literal__mdt where DeveloperName= :metadataByCurrency AND 
    										CurrencyISOCode__c = :workOrder.CurrencyIsoCode LIMIT 1];
    										
    	
    	if(literalMetadataList != null && literalMetadataList.size() > 0 && !literalMetadataList[0].Value__c.containsIgnoreCase(';' +serviceCentre.BillingStateCode +';')){
    		workOrder.ExemptTaxDueToStateCode__c = true;
    	}else{
    		workOrder.ExemptTaxDueToStateCode__c = false;
    	}
    	
    	if(workOrder.ExemptTaxDueToStateCode__c){
    		workOrder.Country_Sales_Tax_Rate__c = 0;
    		workOrder.Country_Use_Tax_Rate__c = 0;
    		workOrder.City_Use_Tax_Rate__c = 0;
    		workOrder.City_Sales_Tax_Rate__c = 0;
    		workOrder.County_Sales_Tax_Rate__c = 0;
    		workOrder.County_Use_Tax_Rate__c = 0;
    		workOrder.Provincial_Sales_Tax_Rate__c = 0;
    		workOrder.StateUseTaxRate__c = 0;
    		workOrder.SpecialSalesTaxRate__c = 0;
    		workOrder.SpecialUseTaxRate__c = 0;
    		workOrder.SalesTaxRate__c = 0;
    		workOrder.UsedServiceTaxRate__c = 0;
    	}else{
	    	Tax_Rate__c taxRateRecord;
	    	/* if tax rate is calculated from trigger, it will be directly assigned to workorder (only in case of ASC work orders) */
	    	
    		/* for Call centre Workorders, tax rate will be calculated here */
    		taxRateRecord = TaxRateUtility.findAppropriateTaxRateRecord(workOrder.CurrencyIsoCode,workOrder, serviceCentre);
	
	      	if(taxRateRecord != null){
	      		
	      		workOrder.PricesInclusiveOfTaxes__c = taxRateRecord.PricesInclusiveOfTaxes__c;
	      		if(taxRateRecord.GST_Tax_Rate__c != null)
	  				workOrder.Country_Sales_Tax_Rate__c = taxRateRecord.GST_Tax_Rate__c;
	  			else
	  				workOrder.Country_Sales_Tax_Rate__c = 0;
	  				
	  			if(taxRateRecord.GST_Tax_Rate__c != null)
	  				workOrder.Country_Use_Tax_Rate__c = taxRateRecord.GST_Tax_Rate__c;
	  			else
	  				workOrder.Country_Use_Tax_Rate__c = 0;
	
				if(taxRateRecord.City_Use_Tax_Rate__c != null)
	  				workOrder.City_Use_Tax_Rate__c = taxRateRecord.City_Use_Tax_Rate__c;
	  			else
	  				workOrder.City_Use_Tax_Rate__c = 0;
				
				if(taxRateRecord.CitySalesTaxRate__c != null)
	  				workOrder.City_Sales_Tax_Rate__c = taxRateRecord.CitySalesTaxRate__c;
	  			else
	  				workOrder.City_Sales_Tax_Rate__c = 0;
				
				if(taxRateRecord.County_Sales_Tax_Rate__c != null)
	  				workOrder.County_Sales_Tax_Rate__c = taxRateRecord.County_Sales_Tax_Rate__c;
	  			else
	  				workOrder.County_Sales_Tax_Rate__c = 0;
				
				if(taxRateRecord.CountyUseTaxRate__c != null)
	  				workOrder.County_Use_Tax_Rate__c = taxRateRecord.CountyUseTaxRate__c;
	  			else
	  				workOrder.County_Use_Tax_Rate__c = 0;
				
				if(taxRateRecord.Provincial_Tax_Rate__c != null)
	  				workOrder.Provincial_Sales_Tax_Rate__c = taxRateRecord.Provincial_Tax_Rate__c;
	  			else
	  				workOrder.Provincial_Sales_Tax_Rate__c = 0;
				
				if(taxRateRecord.StateUseTaxRate__c != null)
	  				workOrder.StateUseTaxRate__c = taxRateRecord.StateUseTaxRate__c;
	  			else
	  				workOrder.StateUseTaxRate__c = 0;
				
				if(taxRateRecord.SpecialSalesTaxRate__c != null)
	  				workOrder.SpecialSalesTaxRate__c = taxRateRecord.SpecialSalesTaxRate__c;
	  			else
	  				workOrder.SpecialSalesTaxRate__c = 0;
				
				if(taxRateRecord.SpecialUseTaxRate__c != null)
	  				workOrder.SpecialUseTaxRate__c = taxRateRecord.SpecialUseTaxRate__c;
	  			else
	  				workOrder.SpecialUseTaxRate__c = 0;
				
				if(taxRateRecord.Combined_Rate__c != null)
	  				workOrder.SalesTaxRate__c = taxRateRecord.Combined_Rate__c;
	  			else
	  				workOrder.SalesTaxRate__c = 0;
				
				if(taxRateRecord.CombinedUseTaxRate__c != null)
	  				workOrder.UsedServiceTaxRate__c = taxRateRecord.CombinedUseTaxRate__c;
	  			else
	  				workOrder.UsedServiceTaxRate__c = 0;
	      	}
    	}
    }//End
    
}//End TaxRate