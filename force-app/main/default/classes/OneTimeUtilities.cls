/*
	CreatedBy: Nikhil Palekar
	This class will be used to create offers and generated offer codes for existing Asset records.
*/


public class OneTimeUtilities{
    
    /* will generate offer codes for CA region */
    public static void generateOfferCodesForCanada(String axItemNumber, String assetIds){
    	
    	list<String> assetIdsList = new list<String>();
    	if(assetIds != null && assetIds != ''){
    		assetIdsList = assetIds.split(',');
    		
    	}
    	list<Asset> assetList = new list<Asset>();
    	if(assetIds != null && assetIds != ''){
    		assetList = [SELECT Id, Product2Id, Product2.AX_Item_Number__c, Account.PersonEmail FROM Asset WHERE ExactOfferCode__c = null 
    								AND Offer_Code_Applied__c = null AND AccountId != null AND Product2Id != null 
    								AND Product2.AX_Item_Number__c = :axItemNumber AND Account.PersonEmail !=  null AND Id IN :assetIdsList];
    	}else{
    		assetList = [SELECT Id, Product2Id, Product2.AX_Item_Number__c, Account.PersonEmail FROM Asset WHERE ExactOfferCode__c = null 
    								AND Offer_Code_Applied__c = null AND AccountId != null AND Product2Id != null 
    								AND Product2.AX_Item_Number__c = :axItemNumber AND Account.PersonEmail !=  null];
    	}

    	for(Asset asset : assetList){
    		Offer__c validOfferRecord = OfferRedemptionUtility.getOfferForProduct(asset.Product2.AX_Item_Number__c,'CAD');
    		if(validOfferRecord != Null){
    			try{
	                if(validOfferRecord.RecordType.Name == 'Generate Offer Code'){
	                    asset.Offer_Code_Applied__c = OfferRedemptionUtility.GenerateOfferCodeFormat(validOfferRecord) +''+ (validOfferRecord.SequentialCounter__c+1);
	                    validOfferRecord.SequentialCounter__c =  validOfferRecord.SequentialCounter__c + 1;  
	            		update  validOfferRecord;
	                }
	                asset.ExactOfferCode__c   = validOfferRecord.OfferCode__c; 
	                asset.OfferWelcomeEmailContent__c  = validOfferRecord.Offer_Welcome_Message__c ;
	                asset.Account_Email__c = asset.Account.PersonEmail;
	                update asset;
    			}catch(Exception e){
    				Error_Log__c error = ErrorLog.logErrorActivity(e.getMessage(),
                                                               'error while updating offer/asser from OneTimeUtilities : generateOfferCodesForCanada ' +asset.id, 
                                                               'Utility-createOrder method',false, 'OfferOrderUtilityError');
					insert error;
    			}
            }
    	}
    }
    
    /* will create offer orders for US and UK region */
    public static void createOfferOrdersForAlreadyRegisteredAssets(String offerCode, String axItemNumber, String currencyCode, String assetIds){
    	
    	list<String> assetIdsList = new list<String>();
    	if(assetIds != null && assetIds != ''){
    		assetIdsList = assetIds.split(',');
    		
    	}
    	list<Asset> assetList = new list<Asset>();
    	if(assetIds != null && assetIds != ''){
    		assetList = [SELECT Id, Product2Id, Product2.AX_Item_Number__c, Account.PersonEmail FROM Asset WHERE ExactOfferCode__c = null 
    								AND Offer_Code_Applied__c = null AND AccountId != null AND Product2Id != null 
    								AND Product2.AX_Item_Number__c = :axItemNumber AND Id IN :assetIdsList];
    	}else{
    		assetList = [SELECT Id, Product2Id, Product2.AX_Item_Number__c, Account.PersonEmail FROM Asset WHERE ExactOfferCode__c = null 
    								AND Offer_Code_Applied__c = null AND AccountId != null AND Product2Id != null 
    								AND Product2.AX_Item_Number__c = :axItemNumber];
    	}
    	
    	String filterAXItemNumber = '%;' +axItemNumber +';%';							
    	Offer__c validOfferRecord = [SELECT Id, OfferCode__c,TotalLengthofOfferCode__c,MatchOfferfromNCharacter__c,Offer_Welcome_Message__c, MultipleProducts__c, RecordType.Name, 
						             SequentialCounter__c FROM Offer__c WHERE Active__c = True AND MultipleProducts__c LIKE :filterAXItemNumber AND CurrencyIsoCode =: currencyCode 
						             AND OfferCode__c = :offerCode limit 1];
    	
    	list<Asset> assetOfferList = new list<Asset>();
    	if(validOfferRecord != Null){
    		for(Asset asset : assetList){
                asset.ExactOfferCode__c   = validOfferRecord.OfferCode__c; 
                asset.OfferWelcomeEmailContent__c  = validOfferRecord.Offer_Welcome_Message__c ;
                asset.Account_Email__c = asset.Account.PersonEmail;
                try{
                	update asset;
                }catch(Exception e){
                	Error_Log__c error = ErrorLog.logErrorActivity(e.getMessage(),
                                                               'error while updating asse from OneTimeUtilities : createOfferOrdersForAlreadyRegisteredAssets ' +asset.id, 
                                                               'Utility-createOrder method',false, 'OfferOrderUtilityError');
					insert error;
                }
                assetOfferList.add(asset);
            }
    	}
    	createOfferOrders(assetOfferList);
    }
    
    /* copied from AssetTriggerHandler */
    public static void createOfferOrders(List<Asset> newAssetList){
        list<String> offerCodes = new list<String>();
        Map<String,Offer__c> offerCodeToOfferMap = new Map<String,Offer__c>();
        Map<Id, Offer__c> assetToOfferMap = new Map<Id, Offer__c>(); 
        for(Asset record : newAssetList){
            if(record.ExactOfferCode__c != null && record.ExactOfferCode__c != ''){
                offerCodes.add(record.ExactOfferCode__c);
            }
        }
        list<Offer__c> offersList = [Select Id, OfferCode__c, Brand__c FROM Offer__c WHERE OfferCode__c IN :offerCodes AND Active__c = true];
        for(Offer__c record : offersList){
            offerCodeToOfferMap.put(record.OfferCode__c, record);
        }
        if(offerCodeToOfferMap != null && offerCodeToOfferMap.size() > 0){
            for(Asset record : newAssetList){
                if(offerCodeToOfferMap.containsKey(record.ExactOfferCode__c) && offerCodeToOfferMap.get(record.ExactOfferCode__c) != null){
                    assetToOfferMap.put(record.Id, offerCodeToOfferMap.get(record.ExactOfferCode__c));
                }
            }
        }
        if(assetToOfferMap != null && assetToOfferMap.size() > 0){
        	createOrderFromOfferOnAsset(assetToOfferMap);
        }
    }
    
    /*copied from OfferRedemptionUtility, made little change. If activation date is less than today, populate activation date as a day after today*/
	public static void createOrderFromOfferOnAsset(Map<Id, Offer__c> assetToOfferMap){
        list<Order> offerOrderListToInsert = new list<Order>();
        list<OrderItem> offerOrderItemListToInsert = new list<OrderItem>();
        Map<Id, Order> offerOrderIdToOrderInsertMap = new Map<Id, Order>();
        Map<id,String> offerOrderIdToShippingMethodMap = new Map<Id, string>();
        list<Asset> assetList = [SELECT Id, AccountId, ContactId, PurchaseDate, CreatedDate, Offer_Code_Applied__c, ExactOfferCode__c, 
                                 Account.BillingCity, Account.BillingCountryCode, Account.BillingPostalCode, Account.BillingStateCode, Account.BillingStreet, 
                                 Account.ShippingCountryCode, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingStateCode, Account.ShippingStreet, Account.Name FROM Asset WHERE ID IN :assetToOfferMap.keySet()];
        
        Map<Id, Offer__c> idToOfferMap = new Map<Id, Offer__c>();
        Map<Id, Offer_Order__c> idToOfferOrderMap = new Map<Id, Offer_Order__c>();
        Map<Id, list<Offer_Order__c>> offerIdToListOfOfferOrderMap = new Map<Id, list<Offer_Order__c>>();
        Map<Id, list<Offer_Order_Items__c>> offerOrderIdToListOfOfferOrderLineItemMap = new Map<Id, list<Offer_Order_Items__c>>();
        
        for(Offer__c record : assetToOfferMap.values()){
            idToOfferMap.put(record.Id, record);
        }
        
        if(idToOfferMap != null&& idToOfferMap.size() > 0){
            for(Offer_Order__c record : [SELECT Id, ActivateOrderOnNDay__c, Offer__c, PriceBook__c,
                                            Offer__r.Brand__c, CurrencyIsoCode FROM Offer_Order__c WHERE Offer__c IN :idToOfferMap.keySet()]){
                idToOfferOrderMap.put(record.Id, record);
                if(!offerIdToListOfOfferOrderMap.containsKey(record.Offer__c)){
                    list<Offer_Order__c> offerOrderList = new list<Offer_Order__c>();
                    offerOrderList.add(record);
                    offerIdToListOfOfferOrderMap.put(record.Offer__c, offerOrderList);
                    continue;
                }
                offerIdToListOfOfferOrderMap.get(record.Offer__c).add(record);
            }
        }
        if(idToOfferOrderMap != null && idToOfferOrderMap.size() > 0){
            for(Offer_Order_Items__c record : [SELECT Id,Offer_Order__c, PriceBookEntryId__c, Quantity__c 
                                                    FROM Offer_Order_Items__c WHERE Offer_Order__c IN: idToOfferOrderMap.keySet()]){
                if(!offerOrderIdToListOfOfferOrderLineItemMap.containsKey(record.Offer_Order__c)){
                    list<Offer_Order_Items__c> offerOrderItemList = new list<Offer_Order_Items__c>();
                    offerOrderItemList.add(record);
                    offerOrderIdToListOfOfferOrderLineItemMap.put(record.Offer_Order__c, offerOrderItemList);
                    continue;
                }
                offerOrderIdToListOfOfferOrderLineItemMap.get(record.Offer_Order__c).add(record);
            }
        }
        
        for(Asset assetRecord : assetList){
            Offer__c offerRecord = assetToOfferMap.get(assetRecord.Id);
            //Map of Offer Order and its ID
            Map<ID, Offer_Order__c> offerOrderIdToOfferOrderMap;
            if(offerIdToListOfOfferOrderMap!= Null && offerIdToListOfOfferOrderMap.size() >0 ){
                 offerOrderIdToOfferOrderMap = new Map<ID, Offer_Order__c>(offerIdToListOfOfferOrderMap.get(offerRecord.Id));
            }
            
            
            /* need to update logic to insert order, first insert order, then assign order id to order item*/
            if(offerOrderIdToOfferOrderMap != null && offerOrderIdToOfferOrderMap.size() > 0){
                //iterate for offer orders   
                 for (Offer_Order__c offerOrder : offerOrderIdToOfferOrderMap.values()) {
                    
                    Order orderRecord = new Order();
                    orderRecord.AccountId = assetRecord.AccountId;
                    orderRecord.BillToContactId = assetRecord.ContactId;
                    orderRecord.Status = 'Open';
                    orderRecord.Source__c = 'GWP';
                    orderRecord.Type = 'Sale';
                    orderRecord.Shipping_Method__c = '';
                    orderRecord.Brand__c = offerOrder.Offer__r.Brand__c;
                    orderRecord.EffectiveDate = Date.today();
                    //orderRecord.Offer_Activation_Date__c = assetRecord.PurchaseDate.addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
                    if(assetRecord.CreatedDate.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c)) < Date.TODAY()){
                    	orderRecord.Offer_Activation_Date__c = Date.TODAY().addDays(1);
                    }else{
                    	orderRecord.Offer_Activation_Date__c = assetRecord.CreatedDate.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
                    }
                    orderrecord.PriceBook2Id = offerOrder.PriceBook__c;
                    orderrecord.CurrencyIsoCode = offerOrder.CurrencyIsoCode;
                    orderRecord.AppliedOfferCode__c = assetRecord.Offer_Code_Applied__c;
                    orderRecord.ExactOfferCode__c = assetRecord.ExactOfferCode__c;
                     
                    orderRecord.BillingCity = assetRecord.Account.BillingCity;
                    orderRecord.BillingCountryCode = assetRecord.Account.BillingCountryCode;
                    orderRecord.BillingPostalCode = assetRecord.Account.BillingPostalCode;
                    orderRecord.BillingStateCode = assetRecord.Account.BillingStateCode;
                    orderRecord.BillingStreet = assetRecord.Account.BillingStreet;
                    orderRecord.ShippingCountryCode = assetRecord.Account.ShippingCountryCode;
                    orderRecord.ShippingCity = assetRecord.Account.ShippingCity;
                    orderRecord.ShippingPostalCode = assetRecord.Account.ShippingPostalCode;
                    orderRecord.ShippingStateCode = assetRecord.Account.ShippingStateCode;
                    orderRecord.ShippingStreet = assetRecord.Account.ShippingStreet;
                    orderRecord.Ship_To_Name__c = assetRecord.Account.Name;
                    
                     if((orderRecord.ShippingCountryCode == null || orderRecord.ShippingCountryCode == '')
                     		&& (orderRecord.ShippingCity == null || orderRecord.ShippingCity == '') && (orderRecord.ShippingPostalCode == null || orderRecord.ShippingPostalCode == '')
                     		&& (orderRecord.ShippingStateCode == null || orderRecord.ShippingStateCode == '')
                     		&& (orderRecord.ShippingStreet == null || orderRecord.ShippingStreet == '')){
                         orderRecord.ShippingCountryCode = assetRecord.Account.BillingCountryCode;
                         orderRecord.ShippingCity = assetRecord.Account.BillingCity;
                         orderRecord.ShippingPostalCode = assetRecord.Account.BillingPostalCode;
                         orderRecord.ShippingStateCode = assetRecord.Account.BillingStateCode;
                         orderRecord.ShippingStreet = assetRecord.Account.BillingStreet;
                     }
                     
                    
                    //new code added
                    String shippingMethod = '';
                    List<Region_Specific__mdt> ShippingMethodData = [SELECT DeveloperName, Currency__c,DefaultShippingMethod__c 
                                                FROM Region_Specific__mdt WHERE Currency__c =: offerOrder.CurrencyIsoCode LIMIT 1];
                    if(ShippingMethodData != null && ShippingMethodData.size() > 0){
                      shippingMethod = ShippingMethodData[0].DefaultShippingMethod__c;
                    }
                    orderRecord.Shipping_Method__c = shippingMethod;
                    /*if(assetRecord.ExactOfferCode__c == 'UK_OFFER_01' || offerOrder.CurrencyIsoCode == 'GBP' || offerOrder.CurrencyIsoCode == 'EUR'){
                    	orderRecord.Shipping_Method__c = 'FINISHED GOODS';
                    }*/
                    
                    offerOrderIdToOrderInsertMap.put(offerOrder.Id, orderRecord);
                 }
             }
             
             try{
                insert offerOrderIdToOrderInsertMap.values();
                                
                if(offerOrderIdToOfferOrderMap != null && offerOrderIdToOfferOrderMap.size() > 0 && offerOrderIdToListOfOfferOrderLineItemMap != null 
                    && offerOrderIdToListOfOfferOrderLineItemMap.size() > 0 && offerOrderIdToOrderInsertMap != null && offerOrderIdToOrderInsertMap.size() > 0){
                    
                    for(Id offerOrderId : offerOrderIdToOfferOrderMap.keySet()){
                    
                        Order orderRecordToInsert = offerOrderIdToOrderInsertMap.get(offerOrderId);
                        for (Offer_Order_Items__c  offerItem: offerOrderIdToListOfOfferOrderLineItemMap.get(offerOrderId)){
                    
                            OrderItem orderItemRecord = new OrderItem();
                            orderItemRecord.OrderId = orderRecordToInsert.id;
                            orderItemRecord.PriceBookEntryId = offerItem.PriceBookEntryId__c;
                            orderItemRecord.Quantity = offerItem.Quantity__c;
                            orderItemRecord.UnitPrice = 0;
                            offerOrderItemListToInsert.add(orderItemRecord);
                        }
                    }
                    
                 }
                 
                 try{
                    insert offerOrderItemListToInsert;
                 }catch(Exception ex){
                    Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
                                                               'error while inserting orders from OfferRedemptionUtility : CreateOrderWhenAssetRecordCreatedUpdatedNew', 
                                                               'Utility-createOrder method',false, 'OfferOrderUtilityError');
                    insert error;                                                            
                 }
                
             }catch(Exception e){
                Error_Log__c error = ErrorLog.logErrorActivity(e.getMessage(),
                                                               'error while inserting orders items from OfferRedemptionUtility : CreateOrderWhenAssetRecordCreatedUpdatedNew', 
                                                               'Utility-createOrder method',false, 'OfferOrderUtilityError');
                insert error;
             }
        }

    }
    
}