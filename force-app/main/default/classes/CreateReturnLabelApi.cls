global without sharing class CreateReturnLabelApi {
    WebService static void createLabel(Id caseRecId){
    	Case caseRec = [select id,RMAStatus__c,Return_Shipment_Type__c, CurrencyIsoCode, Total_Quantity_RMA_Products__c from Case where id =:caseRecId ];
  		map<String,Decimal> parcelsLimitByCurrencyCode = new map<String,Decimal>();
        for(Region_Specific__mdt region : [SELECT RMA_Quantity__c,Currency__c FROM Region_Specific__mdt]){
            parcelsLimitByCurrencyCode.put(region.Currency__c,region.RMA_Quantity__c);
        }
		if(caseRec.RMAStatus__c == 'RMA Approved'){
			if((caseRec.Return_Shipment_Type__c == 'Single Parcel' || caseRec.Return_Shipment_Type__c== 'Multiple Parcels') 
				&&  parcelsLimitByCurrencyCode.containsKey(caseRec.CurrencyIsoCode)
                && caseRec.Total_Quantity_RMA_Products__c <= parcelsLimitByCurrencyCode.get(caseRec.CurrencyIsoCode)){
                    caseRec.RMAStatus__c = 'Scheduled For Label Generation'; 
                }else{
                    caseRec.RMAStatus__c = 'RMA Team Notified'; 
                }
            }
		update caseRec;
  	}
}