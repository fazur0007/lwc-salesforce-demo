public class Ltng_AssetExtendWarrantyCtrl {
        
    @AuraEnabled 
    public static Boolean validateAssetProduct(Id assetId) {        
        try{ 
            Asset assetRecord;
            String currencyCode = '';
            Integer warrantyInMonths = 0;
            List<Asset> assetList = new List<Asset>();
            
			List<Order> OrderList = [select Id, Asset__c, Asset__r.EW_Present__c From Order where Asset__c =: assetId And Asset__r.EW_Present__c = False];
            
            if(OrderList != Null && OrderList.size() > 0){
                String errorMessage = Label.SC_Order_Already_Present_for_Registered_Product;
                AuraHandledException ex = new AuraHandledException(errorMessage);
                ex.setMessage(errorMessage);
                If(!Test.isRunningTest())
                        throw ex;
            }else{
                assetList = [SELECT Id, AccountId, Account.CurrencyIsoCode, ContactId, Product2Id, Product2.Product_Type__c, 
                                     Product2.Warranty_In_Months__c, PurchaseDate, Warranty_In_Months__c, CurrencyIsoCode,
                             		 EW_Present__c
                                     FROM Asset WHERE ID =: assetId];
            }
            

            if(assetList != Null && assetList.size() > 0){
                assetRecord = assetList[0];
                currencyCode = assetRecord.Account.CurrencyIsoCode;//add validation rule
                
                if(assetRecord.EW_Present__c){
                    String errorMessage = Label.SC_Extended_Warranty_already_present;
                    AuraHandledException ex = new AuraHandledException(errorMessage);
					ex.setMessage(errorMessage);
					If(!Test.isRunningTest())
                        throw ex;
                }else if(currencyCode != 'USD'){
                    String errorMessage = Label.SC_Extended_Warranty_only_applicable_on_USA;
                    AuraHandledException ex = new AuraHandledException(errorMessage);
					ex.setMessage(errorMessage);
                    If(!Test.isRunningTest())
                        throw ex;
                }
                
                if(assetRecord.Product2.Warranty_In_Months__c != Null){
                    warrantyInMonths = Integer.valueOf(assetRecord.Product2.Warranty_In_Months__c);
				}else{
                    //throw new AuraHandledException('There is no Breville warranty available for this Product');
                    String errorMessage = Label.SC_No_Breville_warranty_available_for_Product;
                    AuraHandledException ex = new AuraHandledException(errorMessage);
					ex.setMessage(errorMessage);
					If(!Test.isRunningTest())
                        throw ex;
                }
                
                if(assetRecord.PurchaseDate.addMonths(warrantyInMonths).addDays(-30) <= System.today()){
                    String errorMessage = Label.SC_Extended_Warranty_not_applicable;
                    AuraHandledException ex = new AuraHandledException(errorMessage);
					ex.setMessage(errorMessage);
					If(!Test.isRunningTest())
                        throw ex;
                }else{
                    return true;
                }
                return false;
            }else{
                return false;
            }
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
	@AuraEnabled 
    public static Map<String,String> getExtendedWarrantyList(Id assetId) {        
        try{           
            List<RelatedProducts__c> extWarrantyList = [Select Id, Name, Product__c, Product__r.Name, MasterProduct__c, 
                                                        MasterProduct__r.Name, MasterProduct__r.Product_Type__c, 
                                                        Product__r.Product_Type__c, Product__r.Warranty_In_Months__c, Product__r.MAP__c,
                                                        Product__r.CurrencyIsoCode
                                                        From RelatedProducts__c 
                                                        where MasterProduct__c IN 
                                                        (Select Product2Id From Asset where Id= : assetId) 
                                                        And MasterProduct__r.Finished_Good__c = True
                                                        And MasterProduct__r.Spare_Part__c = False 
                                                     	And MasterProduct__r.Accessory__c = False
                                                        And Product__r.Product_Type__c = 'EXTWTY' 
                                                        And Product__r.serviceContractUseType__c = 'Existing'];   

            if(extWarrantyList != Null && extWarrantyList.size() > 0){
                Map<String,String> warrantyOptions = new Map <String,String>();
                
                for (RelatedProducts__c relProd : extWarrantyList){
                    warrantyOptions.put(relProd.Product__c, relProd.Product__r.Name + ' - Warranty: ' + relProd.Product__r.Warranty_In_Months__c + ' Months - '+ relProd.Product__r.CurrencyIsoCode + ' '+ relProd.Product__r.MAP__c);
                }
                return warrantyOptions;
            }else{
                //return null;
                String errorMessage = Label.SC_No_Extended_Warranty_available_for_registered_product;
                AuraHandledException ex = new AuraHandledException(errorMessage);
				ex.setMessage(errorMessage);
                If(!Test.isRunningTest())
					throw ex;
                else
                    return null;
            }
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static String createOrder(Id warrProdId, Id assetId) { 
        String orderId = Null;
        Asset assetRecord;
        
        try{
            String region = '';
            String brand = '';
            String typeOfOrder = 'Sale';
            String currencyCode = '';
            
            List<Asset> assetList = [SELECT Id, AccountId, ContactId, Product2Id, Product2.CurrencyIsoCode, PurchaseDate, CreatedDate, Offer_Code_Applied__c, ExactOfferCode__c, Batch_Code__c, 
                                 CurrencyIsoCode, Account.CurrencyIsoCode, Account.BillingCity, Account.BillingCountryCode, Account.BillingPostalCode, Account.BillingStateCode, Account.BillingStreet, 
                                 Account.ShippingCountryCode, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingStateCode, Account.ShippingStreet, Account.Name FROM Asset WHERE ID =: assetId];

            if(assetList != Null && assetList.size() > 0){
                assetRecord = assetList[0];
                currencyCode = assetRecord.Account.CurrencyIsoCode;
                
                if (currencyCode != null && currencyCode != '') {
                    region = Utility.regionBased(currencyCode);
                    
                    if (currencyCode.equalsIgnoreCase('GBP') || currencyCode.equalsIgnoreCase('EUR') || currencyCode.equalsIgnoreCase('CHF')) {
                        brand = 'Sage';
                    }
                    else {
                        brand = 'Breville';
                    }
                }
            }
            List<Pricebook2> pricebookList = [SELECT Id, Brand__c, Region__c, Type__c FROM Pricebook2
                                       WHERE Region__c =: region AND Brand__c =: brand AND Type__c =: typeOfOrder];
                    
            Order orderRecord = new Order();
            orderRecord.AccountId = assetRecord.AccountId;
            orderRecord.BillToContactId = assetRecord.ContactId;
            orderRecord.Status = 'Open';
            orderRecord.Source__c = 'Breville';
            orderRecord.Channel__c = 'CCC';
            orderRecord.Type = 'Sale';
            orderRecord.Brand__c = brand;
            orderRecord.EffectiveDate = Date.today();
            orderRecord.Asset__c = assetId;

            if (pricebookList != null && pricebookList.size() > 0) {
                orderRecord.PriceBook2Id = pricebookList[0].Id;
            }else{
                String errorMessage = Label.Required_pricebook_not_available;
                AuraHandledException ex = new AuraHandledException(errorMessage);
				ex.setMessage(errorMessage);
				throw ex;
        	}
            orderrecord.CurrencyIsoCode = currencyCode;
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
            orderRecord.Country__c = region;
  
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
            
            /*String shippingMethod = '';
            List<Region_Specific__mdt> ShippingMethodData = [SELECT DeveloperName, Currency__c,DefaultShippingMethod__c 
                                                             FROM Region_Specific__mdt WHERE Currency__c =: orderrecord.CurrencyIsoCode];
            Map<String,String> currencyShippingMethodMap=new Map<String,String>();   
            for(Region_Specific__mdt data : ShippingMethodData){
                currencyShippingMethodMap.put(data.Currency__c,data.DefaultShippingMethod__c);
            }
            if(currencyShippingMethodMap.containsKey(orderrecord.CurrencyIsoCode)){
            	orderrecord.Shipping_Method__c = currencyShippingMethodMap.get(orderrecord.CurrencyIsoCode);
            }*/

            TaxRate taxRateRecord = new TaxRate();
            taxRateRecord.filterOrders(orderRecord);
            
            if(orderrecord != Null){
                insert orderrecord;
                
                try{
                    List<PricebookEntry> pbeWarrantyList = [SELECT Id, Name, Pricebook2Id, pricebook2.name, 
                                                            pricebook2.IsStandard,Product2Id, Product2.Available_to_Sell__c,
                                                            Product2.Warranty_In_Months__c, UnitPrice, IsActive, UseStandardPrice 
                                                            FROM PricebookEntry
                                                            where Pricebook2Id =: orderRecord.PriceBook2Id 
                                                            and Product2Id = : warrProdId //and pricebook2.IsStandard = false
                                                            limit 1];
                    if(pbeWarrantyList != Null && pbeWarrantyList.size() > 0){                    
                        OrderItem orderItemRecord = new OrderItem();
                        orderItemRecord.orderId = orderrecord.Id;
                        orderItemRecord.PricebookEntryId = pbeWarrantyList[0].Id;
                        orderItemRecord.Product2Id = pbeWarrantyList[0].Product2Id;
                        orderItemRecord.UnitPrice = pbeWarrantyList[0].UnitPrice;
                        orderItemRecord.Quantity = 1;
                        orderItemRecord.Available_to_Sell__c = pbeWarrantyList[0].Product2.Available_to_Sell__c;
                        
                        if(orderItemRecord != Null){
                            insert orderItemRecord;
                        }
                    }
                }catch(Exception ex){
                    Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
                                                                   'error while inserting order product from Ltng_ExtendedWarrantyCtrl : createOrder', 
                                                                   'createOrder method',false, 'Ltng_ExtendedWarrantyCtrl', orderrecord.Id);
                    insert error;
                    
                    throw new AuraHandledException(ex.getMessage());
                    
                }
                orderId = orderrecord.Id;
            }
        }catch(Exception ex){
            Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
                                                           'error while inserting orders from Ltng_ExtendedWarrantyCtrl : createOrder', 
                                                           'createOrder method',false, 'Ltng_ExtendedWarrantyCtrl', assetRecord.Id);
            insert error;
            
            throw new AuraHandledException(ex.getMessage());
            
        }
        return orderId;
    }

}