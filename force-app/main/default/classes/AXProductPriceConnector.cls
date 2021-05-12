public with sharing class AXProductPriceConnector {
	
	public static list<OrderItem> calculatePrice(list<OrderItem> items , Account b2BAccount){		
		map<String, AXPriceUtility.PriceWrapper> idToPricewrapperMap = AXPriceUtility.getXmlResponse(items, b2BAccount);
		if(idToPricewrapperMap != null && idToPricewrapperMap.size() > 0){
			for(OrderItem orderItemRecord : items){
				if(orderItemRecord.Id != null ){
                    AXPriceUtility.PriceWrapper wrapper = idToPricewrapperMap.get(orderItemRecord.Id);
					if(wrapper.IsTaxExempt != null && wrapper.IsTaxExempt==1)
						orderItemRecord.Order.Tax_Exempt_Order__c = true;
					else
						orderItemRecord.Order.Tax_Exempt_Order__c = false;
					
					if(wrapper.SalesPrice != null){
						orderItemRecord.UnitPrice = wrapper.SalesPrice;
					}

					orderItemRecord.Description = wrapper.DiscDescription;
				}
			}
		}
		return 	items;
	}
	
	public static list<OrderItem> calculatePriceD365(list<OrderItem> items , Account b2bAccount){
		Map<String, D365APIUtility.TradeAgreementPriceResponse> itemNumberOrderItemMap = D365APIUtility.getTradeAgreementPrice(items,b2bAccount);
		if(itemNumberOrderItemMap != null && itemNumberOrderItemMap.size() > 0){
			for(OrderItem orderItemRecord : items) {
				if(orderItemRecord.AX_Item_Number__c != null ){
					D365APIUtility.TradeAgreementPriceResponse wrapper = itemNumberOrderItemMap.get(orderItemRecord.AX_Item_Number__c);
					if(wrapper.Price != null){
						orderItemRecord.UnitPrice = wrapper.Price;
					}
				}
			}
		}
		return 	items;
	}
	
	public static list<RMA_Product__c> calculatePriceForRMACase(list<RMA_Product__c> items){
		map<String, AXPriceUtility.PriceWrapper> idToPricewrapperMap = AXPriceUtility.getXmlResponse(items, null);
		
		if(idToPricewrapperMap != null && idToPricewrapperMap.size() > 0){
			for(RMA_Product__c orderItemRecord : items){
				if(orderItemRecord.Product__c != null && orderItemRecord.Product__r.Id != null ){
					AXPriceUtility.PriceWrapper wrapper = idToPricewrapperMap.get(orderItemRecord.Id);
					if(wrapper.SalesPrice != null){
						orderItemRecord.CalculatedUnitPrice__c = wrapper.SalesPrice;
					}
					
				}
			}
		}
		return 	items;
	}
	
	public static list<RMA_Product__c> calculatePriceForRMACaseD365(list<RMA_Product__c> items, Account b2BAccount){
		map<String, D365APIUtility.TradeAgreementPriceResponse> idToTradeAgreemnetPriceResponseMap = D365APIUtility.getTradeAgreementPrice(items, b2BAccount);
		if(idToTradeAgreemnetPriceResponseMap != null && idToTradeAgreemnetPriceResponseMap.size() > 0){
			for(RMA_Product__c rmaProductRecord : items){
				if(rmaProductRecord.Product__c != null && rmaProductRecord.Product__r.AX_Item_Number__c != null ){
					D365APIUtility.TradeAgreementPriceResponse wrapper = idToTradeAgreemnetPriceResponseMap.get(rmaProductRecord.Product__r.AX_Item_Number__c);
					if(wrapper.Price != null){
						rmaProductRecord.CalculatedUnitPrice__c = wrapper.Price;
					}
					
				}
			}
		}
		return 	items;
	}
	
}