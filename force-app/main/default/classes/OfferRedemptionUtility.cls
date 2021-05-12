public without sharing class OfferRedemptionUtility {
    
    public static Offer__c isOfferCodeValid(String axItemNumber, String currencyCode, String offerCode){
        //Validation Logic
        String filterAXItemNumber = '%;' +axItemNumber +';%';   
        List<Offer__c> validOfferList = [SELECT id,OfferCode__c,TotalLengthofOfferCode__c,MatchOfferfromNCharacter__c,Offer_Welcome_Message__c, MultipleProducts__c, RecordType.Name, TnC_Link__c, PageHeader__c, Disclaimer__c, PartnerSharingTitle__c, ShareWithPartner__c
                                         from Offer__c WHERE Active__c = True AND MultipleProducts__c LIKE :filterAXItemNumber AND CurrencyIsoCode =: currencyCode and matchOfferCode__c = true limit 1 ];
        if(validOfferList !=null && validOfferList.size() > 0){
            // check if offer code is of 12 digits Offer__c
            if(offerCode.length() == validOfferList[0].TotalLengthofOfferCode__c)
            {
                // check if offer code from MatchOfferfromNCharacter__c is mached with the OfferCode__c from Offer__c object records
                if(validOfferList[0].MatchOfferfromNCharacter__c != Null & validOfferList[0].MatchOfferfromNCharacter__c > 0)
                {
                    string exactOfferCode = offerCode.mid(Integer.valueof(validOfferList[0].MatchOfferfromNCharacter__c)-1,validOfferList[0].OfferCode__c.length());
                    if(exactOfferCode == validOfferList[0].OfferCode__c)
                    {
                        return validOfferList[0];
                    }
                }
            }
        }
        return Null;
    }
    
    /*public static Offer__c isOfferCodeValid(String axItemNumber, String currencyCode, String offerCode, Date purchaseDate){
        //Validation Logic
        String filterAXItemNumber = '%;' +axItemNumber +';%';    
        List<Offer__c> validOfferList = [SELECT id, OfferCode__c, PurchaseStartDate__c, PurchaseEndDate__c,
                                         TotalLengthofOfferCode__c, MatchOfferfromNCharacter__c,
                                         Offer_Welcome_Message__c, MultipleProducts__c, RecordType.Name,
                                         TnC_Link__c, PageHeader__c
                                         from Offer__c
                                         WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode 
                                         AND matchOfferCode__c = true limit 1 ];
        if(validOfferList !=null && validOfferList.size() > 0){
            // check if offer code is of 12 digits Offer__c
            if(offerCode.length() == validOfferList[0].TotalLengthofOfferCode__c)
            {
                // check if offer code from MatchOfferfromNCharacter__c is mached with the OfferCode__c from Offer__c object records
                if(validOfferList[0].MatchOfferfromNCharacter__c != Null && validOfferList[0].MatchOfferfromNCharacter__c > 0)
                {
                    string exactOfferCode = offerCode.mid(Integer.valueof(validOfferList[0].MatchOfferfromNCharacter__c)-1,validOfferList[0].OfferCode__c.length());
                    if(exactOfferCode == validOfferList[0].OfferCode__c)
                    {
                        if(validOfferList[0].PurchaseStartDate__c != null && validOfferList[0].PurchaseEndDate__c != null && purchaseDate != null) {
                            if(!validPurchaseDateForApplyingOffer(validOfferList[0].PurchaseStartDate__c, validOfferList[0].PurchaseEndDate__c, purchaseDate))
                                return null;
                        }
                        return validOfferList[0];
                    }
                }
            }
        }
        return Null;
    }*/
    
    
    /*public static Offer__c isOfferCodeValid(String axItemNumber, String currencyCode, String offerCode, Date purchaseDate, String placeOfPurchase){
        //Validation Logic
        String filterAXItemNumber = '%;' +axItemNumber +';%';    
        List<Offer__c> validOfferList = [SELECT id, OfferCode__c, Purchased_From__c, PurchaseStartDate__c, PurchaseEndDate__c,
                                         TotalLengthofOfferCode__c, MatchOfferfromNCharacter__c,
                                         Offer_Welcome_Message__c, MultipleProducts__c, RecordType.Name,
                                         TnC_Link__c, PageHeader__c
                                         from Offer__c
                                         WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode 
                                         AND matchOfferCode__c = true limit 1 ];
        if(validOfferList !=null && validOfferList.size() > 0){
            // check if offer code is of 12 digits Offer__c
            if(offerCode.length() == validOfferList[0].TotalLengthofOfferCode__c)
            {
                // check if offer code from MatchOfferfromNCharacter__c is mached with the OfferCode__c from Offer__c object records
                if(validOfferList[0].MatchOfferfromNCharacter__c != Null && validOfferList[0].MatchOfferfromNCharacter__c > 0)
                {
                    string exactOfferCode = offerCode.mid(Integer.valueof(validOfferList[0].MatchOfferfromNCharacter__c)-1,validOfferList[0].OfferCode__c.length());
                    if(exactOfferCode == validOfferList[0].OfferCode__c)
                    {
                        if(validOfferList[0].PurchaseStartDate__c != null && validOfferList[0].PurchaseEndDate__c != null && purchaseDate != null) {
                            if(!validPurchaseDateForApplyingOffer(validOfferList[0].PurchaseStartDate__c, validOfferList[0].PurchaseEndDate__c, purchaseDate))
                                return null;
                        }
                        if(validOfferList[0].Purchased_From__c != null){
                            if(!validOfferList[0].Purchased_From__c.contains(placeOfPurchase)){
                                return null;
                            }
                        }
                        return validOfferList[0];
                    }
                }
            }
        }
        return Null;
    }
    */

    public static List<Offer__c> isOfferCodeValid(String axItemNumber, String currencyCode, Asset asset, Account acct){
        String offerCode = asset.Offer_Code_Applied__c;
        Date purchaseDate = asset.PurchaseDate;
        String placeOfPurchase = asset.Where_did_you_purchase__c;
        String batchCode = asset.Batch_Code__c;
        String countryCode=';'+acct.BillingCountryCode+';';
        
        List<Offer__c> allValidOffers = new List<Offer__c>();
        //Validation Logic
        String filterAXItemNumber = '%;' +axItemNumber +';%';   
        List<Offer__c> validOfferList = [SELECT id, OfferCode__c, Purchased_From__c, PurchaseStartDate__c, PurchaseEndDate__c,
                                         TotalLengthofOfferCode__c, MatchOfferfromNCharacter__c,
                                         Offer_Welcome_Message__c, MultipleProducts__c, RecordType.Name, Applicable_Countres__c,
                                         TnC_Link__c, PageHeader__c, Batch_Code_Start__c, Batch_Code_End__c,OnlyForBoutiqueURL__c,
                                         Disclaimer__c, PartnerSharingTitle__c, ShareWithPartner__c, IsApprovalRequired__c
                                         from Offer__c
                                         WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode 
                                         AND matchOfferCode__c = true ];
		
        if(validOfferList !=null && validOfferList.size() > 0){
            // check if offer code is of 12 digits Offer__c
            for(Offer__c validOffer : validOfferList){
                system.debug('validOffer>>>>'+validOffer);
                if(offerCode != null && offerCode.length() == validOffer.TotalLengthofOfferCode__c)
                {              
                    // check if offer code from MatchOfferfromNCharacter__c is mached with the OfferCode__c from Offer__c object records
                    if(validOffer.MatchOfferfromNCharacter__c != Null && validOffer.MatchOfferfromNCharacter__c > 0)
                    {
                        string exactOfferCode = offerCode.mid(Integer.valueof(validOffer.MatchOfferfromNCharacter__c)-1,validOffer.OfferCode__c.length());
						if(exactOfferCode == validOffer.OfferCode__c)
                        {
                            Boolean isOfferValid = true;
                            if(validOffer.PurchaseStartDate__c != null && validOffer.PurchaseEndDate__c != null) {
                                if(purchaseDate == null || !validPurchaseDateForApplyingOffer(validOffer.PurchaseStartDate__c, validOffer.PurchaseEndDate__c, purchaseDate))
                                    isOfferValid = false;
                            }
                            if(validOffer.Purchased_From__c != null&&validOffer.Purchased_From__c!=''){
                                if(placeOfPurchase== null || !validOffer.Purchased_From__c.contains(placeOfPurchase)){
                                     isOfferValid = false;
                                }
                            }
                            
                            if(validOffer.Batch_Code_Start__c != null && validOffer.Batch_Code_End__c != null) {                              
                                if(batchCode == null || !validBatchCodeDateForApplyingOffer(Integer.valueOf(validOffer.Batch_Code_Start__c), Integer.valueOf(validOffer.Batch_Code_End__c), Integer.valueOf(batchCode))) {
                                    isOfferValid = false;
                                }
                            }
                            /****code change for SF-556: added checking to validate with applicable Countries****/
                            if(validOffer.Applicable_Countres__c!=null&&validOffer.Applicable_Countres__c!=''){
                                if(!validOffer.Applicable_Countres__c.contains(countryCode)){
                                    isOfferValid=false;
                                }
                            }
                            /****End of code change for SF-556****/
                            if(isOfferValid)
                                allValidOffers.add(validOffer);
                        }
                        
                    }
                }
            }
            return allValidOffers;
        }
        return Null;
    }
    
    public static Boolean validBatchCodeDateForApplyingOffer(Integer batchCodeStartDate, Integer batchCodeEndDate, Integer batchCodeDate) {
        if(batchCodeStartDate <= batchCodeDate && batchCodeDate <= batchCodeEndDate) {
            return true;
        }
        return false;
    }

    public static Offer__c getOfferForProduct(String axItemNumber, String currencyCode){
        system.debug('axItemNumber:'+axItemNumber);
        system.debug('currencyCode:'+currencyCode);
        String filterAXItemNumber = '%;' +axItemNumber +';%';
        List<Offer__c> validOfferList = [SELECT id,RecordType.Name,OfferCode__c,SequentialCounter__c,Offer_Welcome_Message__c, MultipleProducts__c, TotalLengthofOfferCode__c, TnC_Link__c, PageHeader__c, Disclaimer__c, PartnerSharingTitle__c, ShareWithPartner__c
                                         from Offer__c WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode  
                                         AND matchOfferCode__c = false limit 1 ];      
        
        if(validOfferList !=null && validOfferList.size() >0)  
            return validOfferList[0];
        return null;
    }
    
    public static List<Offer__c> getOffersForProduct(String axItemNumber, String currencyCode){
        system.debug('axItemNumber:'+axItemNumber);
        system.debug('currencyCode:'+currencyCode);
        String filterAXItemNumber = '%;' +axItemNumber +';%';
        List<Offer__c> validOfferList = new List<Offer__c>();
        validOfferList = [SELECT id,RecordType.Name,OfferCode__c,SequentialCounter__c,Offer_Welcome_Message__c, MultipleProducts__c, TotalLengthofOfferCode__c, TnC_Link__c, PageHeader__c, Disclaimer__c, PartnerSharingTitle__c, ShareWithPartner__c
                                         from Offer__c WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode  
                                         AND matchOfferCode__c = false];              
        return validOfferList;
    }
    
  public static List<Offer__c> getOfferForProduct(String axItemNumber, String currencyCode, Date purchaseDate){        
        String filterAXItemNumber = '%;' +axItemNumber +';%';
         system.debug('axItemNumber:'+axItemNumber);
        system.debug('currencyCode:'+currencyCode);
        List<Offer__c> applicableOffers = new List<Offer__c>();
        List<Offer__c> validOfferList = [SELECT id,Banner_Link__c,RecordType.Name, OfferCode__c, PurchaseStartDate__c, PurchaseEndDate__c, 
                                         SequentialCounter__c,Offer_Welcome_Message__c, MultipleProducts__c, ConsentMessage__c,
                                         TotalLengthofOfferCode__c, TnC_Link__c, PageHeader__c,OnlyForBoutiqueURL__c,
                                         Disclaimer__c, PartnerSharingTitle__c, ShareWithPartner__c
                                         from Offer__c WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode  
                                         AND matchOfferCode__c = false];
        
        if(validOfferList !=null && validOfferList.size() >0) {
            for(Offer__c validOffer : validOfferList){
                if(validOffer.PurchaseStartDate__c != null && validOffer.PurchaseEndDate__c != null && purchaseDate != null) {
                    if(validPurchaseDateForApplyingOffer(validOffer.PurchaseStartDate__c, validOffer.PurchaseEndDate__c, purchaseDate)){
                        applicableOffers.add(validOffer);
                    }
                }
                else{
                    applicableOffers.add(validOffer);
                }
            }
            return applicableOffers;
        }
        return null;
    }
    
    /*public static Offer__c getOfferForProduct(String axItemNumber, String currencyCode, Date purchaseDate, String placeOfPurchase){        
        String filterAXItemNumber = '%;' +axItemNumber +';%';
        List<Offer__c> validOfferList = [SELECT id,RecordType.Name, Purchased_From__c, OfferCode__c, PurchaseStartDate__c, PurchaseEndDate__c, 
                                         SequentialCounter__c,Offer_Welcome_Message__c, MultipleProducts__c, 
                                         TotalLengthofOfferCode__c, TnC_Link__c, PageHeader__c 
                                         from Offer__c WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode  
                                         AND matchOfferCode__c = false limit 1 ];
        
        if(validOfferList !=null && validOfferList.size() >0) {
            if(validOfferList[0].PurchaseStartDate__c != null && validOfferList[0].PurchaseEndDate__c != null && purchaseDate != null) {
                if(!validPurchaseDateForApplyingOffer(validOfferList[0].PurchaseStartDate__c, validOfferList[0].PurchaseEndDate__c, purchaseDate))
                    return null;
            }
            if(validOfferList[0].Purchased_From__c != null){
                            if(!validOfferList[0].Purchased_From__c.contains(placeOfPurchase)){
                                return null;
                            }
                        }
            return validOfferList[0];
        }
        return null;
    }
  */
    
    public static List<Offer__c> getOfferForProduct(String axItemNumber, String currencyCode, Asset asset, Account acct){ 
        Date purchaseDate = asset.PurchaseDate;
        String placeOfPurchase = asset.Where_did_you_purchase__c;
        String batchCode = asset.Batch_Code__c;
    String countryCode = ';'+ acct.ShippingCountryCode +';';
        System.debug ('countryCode: ' + countryCode);
        List<Offer__c> applicableOfferList = new List<Offer__c>();
        String filterAXItemNumber = '%;' +axItemNumber +';%';
        system.debug('filterAXItemNumber :'+filterAXItemNumber );
                system.debug('currencyCode  :'+currencyCode  );
        List<Offer__c> validOfferList = [SELECT id,RecordType.Name, Purchased_From__c, OfferCode__c, PurchaseStartDate__c, PurchaseEndDate__c, 
                                         SequentialCounter__c,Offer_Welcome_Message__c, MultipleProducts__c, Applicable_Countres__c,
                                         TotalLengthofOfferCode__c, TnC_Link__c, PageHeader__c, Batch_Code_Start__c, Batch_Code_End__c, OnlyForBoutiqueURL__c,
                                         Disclaimer__c, PartnerSharingTitle__c, ShareWithPartner__c, IsApprovalRequired__c,Include_Chefsteps_Offer__c  
                                         from Offer__c WHERE Active__c = True 
                                         AND MultipleProducts__c LIKE :filterAXItemNumber 
                                         AND CurrencyIsoCode =: currencyCode  
                                         AND matchOfferCode__c = false];
        
    if(validOfferList !=null && validOfferList.size() >0) {
            for(Offer__c validOffer : validOfferList){
                
                if(validOffer.PurchaseStartDate__c != null && validOffer.PurchaseEndDate__c != null) {
                    if(purchaseDate == null || !validPurchaseDateForApplyingOffer(validOffer.PurchaseStartDate__c, validOffer.PurchaseEndDate__c, purchaseDate)){
                        continue;
                    }
                }
                if(validOffer.Purchased_From__c != null&&validOffer.Purchased_From__c!=''){
                    if(placeOfPurchase == null || !validOffer.Purchased_From__c.containsIgnoreCase(placeOfPurchase)){
                        continue;
                    }
                }
                if(validOffer.Batch_Code_Start__c != null && validOffer.Batch_Code_End__c != null) {                              
                    if(batchCode == null || !validBatchCodeDateForApplyingOffer(Integer.valueOf(validOffer.Batch_Code_Start__c), Integer.valueOf(validOffer.Batch_Code_End__c), Integer.valueOf(batchCode))){
                        continue;
                    }                    
                }
                /****code change for SF-556 : added checking to validate with applicable Countries****/
                if(validOffer.Applicable_Countres__c != null && validOffer.Applicable_Countres__c != '') {                              
                    if(!validOffer.Applicable_Countres__c.containsIgnoreCase(countryCode)){
                        continue;
                    }                    
                }
                /****End of code change for SF-556****/
                system.debug('validOffer:'+validOffer);
                applicableOfferList.add(validOffer);
            }
            if(applicableOfferList.size()>0) {
                return applicableOfferList;
            }
        }
        return null;
    }
    
    /* Code changes for SF-13: added validation for Boutique URL*/
    public static List<Offer__c> applicableOffersOnPage(List<Offer__c> validOfferList, Boolean isBoutiqueURL){
        List<Offer__c> applicableOffers = new List<Offer__c>();
        if(validOfferList != null && validOfferList.size() > 0){
            if(isBoutiqueURL){
                applicableOffers.addAll(validOfferList);
            }else{
                for(Offer__c validOfferRecord : validOfferList){
                    if(!validOfferRecord.OnlyForBoutiqueURL__c){
                        applicableOffers.add(validOfferRecord);
                    }
                }
            }
        return applicableOffers;
        }
        return Null;
    }
    
    public static Boolean validPurchaseDateForApplyingOffer(Date offerStartDate, Date offerEndDate, Date productPurchaseDate) {
        if(offerStartDate <= productPurchaseDate && productPurchaseDate <= offerEndDate) {
            return true;
        }
        return false;
    }
    
    public static string GenerateOfferCodeFormat(Offer__c cRecord){
        string generatedOfferCode = '';
        integer calcPaddingChars = Integer.valueOf(cRecord.TotalLengthofOfferCode__c);
        calcPaddingChars = calcPaddingChars - (cRecord.OfferCode__c.length() + (String.valueOf(cRecord.SequentialCounter__c+1).length())) ;
        
        generatedOfferCode = cRecord.OfferCode__c.rightPad(cRecord.OfferCode__c.length() + calcPaddingChars);
        generatedOfferCode = generatedOfferCode.Replace(' ','0');
        return generatedOfferCode;
    }
    
  //Please change method name accordingly
    public static void createOrderFromOfferOnAsset(Map<Id, List<Offer__c>> assetToOfferMap){
        list<Order> offerOrderListToInsert = new list<Order>();
        list<OrderItem> offerOrderItemListToInsert = new list<OrderItem>();
        Map<Id, Order> offerOrderIdToOrderInsertMap = new Map<Id, Order>();
        Map<id,String> offerOrderIdToShippingMethodMap = new Map<Id, string>();
        system.debug('assetToOfferMap>>>>'+assetToOfferMap);
        //GWP promtions - added Selected_Offer_Line_Item__c to the query 
        list<Asset> assetList = [SELECT Id, AccountId,Asset_code__c, ContactId, PurchaseDate, CreatedDate, Offer_Code_Applied__c, ExactOfferCode__c, Batch_Code__c,Selected_Offer_Line_Item__c, 
                                 Account.BillingCity, Account.BillingCountryCode, Account.BillingPostalCode, Account.BillingStateCode, Account.BillingStreet, 
                                 Account.ShippingCountryCode, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingStateCode, Account.ShippingStreet, Account.Name FROM Asset WHERE ID IN :assetToOfferMap.keySet()];
        
        Map<Id, Offer__c> idToOfferMap = new Map<Id, Offer__c>();
        Map<Id, Offer_Order__c> idToOfferOrderMap = new Map<Id, Offer_Order__c>();
        Map<Id, list<Offer_Order__c>> offerIdToListOfOfferOrderMap = new Map<Id, list<Offer_Order__c>>();
        Map<Id, list<Offer_Order_Items__c>> offerOrderIdToListOfOfferOrderLineItemMap = new Map<Id, list<Offer_Order_Items__c>>();
        Map<ID, Offer_Order__c> offerOrderIdToOfferOrderMap=  new Map<ID, Offer_Order__c>();
        Set<String> offerCurrency=new Set<String>();
        list<Offer_Order__c> listOfferOrder ;
        
        for(Id idAsset : assetToOfferMap.keyset()){
            for(Offer__c record : assetToOfferMap.get(idAsset)){
                idToOfferMap.put(record.Id, record);
            }
        }
        if(idToOfferMap != null&& idToOfferMap.size() > 0){
            for(Offer_Order__c record : [SELECT Id, ActivateOrderOnNDay__c, Offer__c, PriceBook__c,
                                         Offer__r.Brand__c, CurrencyIsoCode, Batch_Code_From__c, 
                                         Batch_Code_To__c, AX_Order_Account__c, Offer__r.OfferCode__c  
                                         FROM Offer_Order__c 
                                         WHERE Offer__c IN :idToOfferMap.keySet()]){
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
        system.debug('idToOfferOrderMap>>>>>'+idToOfferOrderMap);
        if(idToOfferOrderMap != null && idToOfferOrderMap.size() > 0){
            for(Offer_Order_Items__c record : [SELECT Id,Offer_Order__c, PriceBookEntryId__c, Quantity__c 
                                               FROM Offer_Order_Items__c WHERE Offer_Order__c IN: idToOfferOrderMap.keySet()]){
                                                   system.debug('record>>>>'+record);
                                                   if(!offerOrderIdToListOfOfferOrderLineItemMap.containsKey(record.Offer_Order__c)){
                                                       list<Offer_Order_Items__c> offerOrderItemList = new list<Offer_Order_Items__c>();
                                                       offerOrderItemList.add(record);
                                                       offerOrderIdToListOfOfferOrderLineItemMap.put(record.Offer_Order__c, offerOrderItemList);
                                                       continue;
                                                   }
                                                   offerOrderIdToListOfOfferOrderLineItemMap.get(record.Offer_Order__c).add(record);
                                               }
        }
        system.debug('assetList>>>>'+assetList);
        //GWP promtions
        Map<Id,Asset> mapAssetIdWithAsset = new Map<Id,Asset>();
        for(Asset assetRecord : assetList){
            //GWP promtions
            mapAssetIdWithAsset.put(assetRecord.Id,assetRecord);
            for(Offer__c listOffer : assetToOfferMap.get(assetRecord.Id)){
                
                Offer__c offerRecord = listOffer;
                
        //Map of Offer Order and its ID               
                if(offerIdToListOfOfferOrderMap!= Null && offerIdToListOfOfferOrderMap.size() >0 ){
                    if(offerIdToListOfOfferOrderMap.containsKey(offerRecord.Id)){
                        for(Offer_Order__c offorder :offerIdToListOfOfferOrderMap.get(offerRecord.Id)){
                            offerOrderIdToOfferOrderMap.put(offorder.Id ,offorder);
                        }
                    }
                }
                
                /* need to update logic to insert order, first insert order, then assign order id to order item*/
                if(offerOrderIdToOfferOrderMap != null && offerOrderIdToOfferOrderMap.size() > 0){
                    //iterate for offer orders   
                    for (Offer_Order__c offerOrder : offerOrderIdToOfferOrderMap.values()) {
                        Decimal assetBatchCode = (assetRecord.Batch_Code__c == Null) ? 0 : Decimal.valueOf(assetRecord.Batch_Code__c.left(4)); 
                        if((offerOrder.Batch_Code_From__c == null && offerOrder.Batch_Code_To__c == null) || 
                           (offerOrder.Batch_Code_From__c != null && offerOrder.Batch_Code_To__c != null && assetBatchCode >= offerOrder.Batch_Code_From__c 
                            && assetBatchCode <= offerOrder.Batch_Code_To__c)){
                                
                                Order orderRecord = new Order();
                                orderRecord.AccountId = assetRecord.AccountId;
                                orderRecord.BillToContactId = assetRecord.ContactId;
                                orderRecord.Status = 'Open';
                                orderRecord.Source__c = 'GWP';
                                orderRecord.Type = 'Sale';
                                orderRecord.Shipping_Method__c = '';
                                orderRecord.Brand__c = offerOrder.Offer__r.Brand__c;
                                orderRecord.EffectiveDate = Date.today();
                                //GWP promtions - Map the original asset to the GWP order
                                orderRecord.Asset__c = assetRecord.Id;
                                //orderRecord.Offer_Activation_Date__c = assetRecord.PurchaseDate.addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
                                orderRecord.Offer_Activation_Date__c = assetRecord.CreatedDate.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
                                DateTime dateTimeRecord;
                                if(assetRecord.PurchaseDate != null){
                                    dateTimeRecord = assetRecord.PurchaseDate;
                                }else{
                                    dateTimeRecord = assetRecord.CreatedDate;
                                }
                                if(dateTimeRecord.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c)) <= Date.TODAY()){
                                    orderRecord.Offer_Activation_Date__c = Date.TODAY().addDays(1);
                                }else{
                                    orderRecord.Offer_Activation_Date__c = dateTimeRecord.date().addDays(Integer.valueOf(offerOrder.ActivateOrderOnNDay__c));
                                }
                                
                                orderrecord.PriceBook2Id = offerOrder.PriceBook__c;
                                offerCurrency.add(offerOrder.CurrencyIsoCode);
                                orderrecord.CurrencyIsoCode = offerOrder.CurrencyIsoCode;
                                String region = Utility.regionBased(orderrecord.CurrencyIsoCode);
                                if(region != null){
                                    orderRecord.Country__c = region;
                                }
                                if(offerOrder.AX_Order_Account__c != null){
                                    orderrecord.AX_Order_Account__c = offerOrder.AX_Order_Account__c;
                                    orderrecord.OverrideAXAccNum__c = true;
                                }
                                orderRecord.AppliedOfferCode__c = assetRecord.Offer_Code_Applied__c;
                                orderRecord.ExactOfferCode__c = offerOrder.Offer__r.OfferCode__c;//assetRecord.ExactOfferCode__c;
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
                                
                                /*if(assetRecord.ExactOfferCode__c == 'UK_OFFER_01' || offerOrder.CurrencyIsoCode == 'GBP' || offerOrder.CurrencyIsoCode == 'EUR'){
orderRecord.Shipping_Method__c = 'FINISHED GOODS';
}*/ 
                                offerOrderIdToOrderInsertMap.put(offerOrder.Id, orderRecord);
                            }else{
                                offerOrderIdToOfferOrderMap.remove(offerOrder.Id);
                            }
                    }
                }
            }
        }
        //new code added
        String shippingMethod = '';
        List<Region_Specific__mdt> ShippingMethodData = [SELECT DeveloperName, Currency__c,DefaultShippingMethod__c 
                                                         FROM Region_Specific__mdt WHERE Currency__c =: offerCurrency ];
        Map<String,String> currencyShippingMethodMap=new Map<String,String>();   
        for(Region_Specific__mdt data:ShippingMethodData){
            currencyShippingMethodMap.put(data.Currency__c,data.DefaultShippingMethod__c);
        }
        for(Order ord:offerOrderIdToOrderInsertMap.values()){
            if(currencyShippingMethodMap.containsKey(ord.CurrencyIsoCode)){
                ord.Shipping_Method__c = currencyShippingMethodMap.get(ord.CurrencyIsoCode);
                
            }
        }
        try{
            if(offerOrderIdToOfferOrderMap != null && offerOrderIdToOfferOrderMap.size() > 0 ){
                insert offerOrderIdToOrderInsertMap.values();
                
                if(offerOrderIdToListOfOfferOrderLineItemMap != null && offerOrderIdToListOfOfferOrderLineItemMap.size() > 0 && offerOrderIdToOrderInsertMap != null 
                   && offerOrderIdToOrderInsertMap.size() > 0){
                       for(Id offerOrderId : offerOrderIdToOfferOrderMap.keySet()){
                           Order orderRecordToInsert = offerOrderIdToOrderInsertMap.get(offerOrderId);
                           Asset assetForCurrentOrder = mapAssetIdWithAsset.get(orderRecordToInsert.Asset__c);
                           for (Offer_Order_Items__c  offerItem: offerOrderIdToListOfOfferOrderLineItemMap.get(offerOrderId)){
                               //GWP promtions - If customer selected offer line item during prod reg then only add that product
                               Boolean insertCurrentOfferItem = true;
                               if(string.IsNotblank(assetForCurrentOrder.Selected_Offer_Line_Item__c) && assetForCurrentOrder.Selected_Offer_Line_Item__c!=offerItem.Id)
                               {
                                    insertCurrentOfferItem = false;
                               }
                               
                               if(insertCurrentOfferItem)
                               {
                                   OrderItem orderItemRecord = new OrderItem();
                                   orderItemRecord.OrderId = orderRecordToInsert.id;
                                   orderItemRecord.PriceBookEntryId = offerItem.PriceBookEntryId__c;
                                   orderItemRecord.Quantity = offerItem.Quantity__c;
                                   orderItemRecord.UnitPrice = 0;
                                   offerOrderItemListToInsert.add(orderItemRecord);
                               }
                           }
                       }
                   }  
            }
            try{
                insert offerOrderItemListToInsert;
                SubscriptionManagementUtility.createSubscriptionRecords(offerOrderIdToOrderInsertMap,mapAssetIdWithAsset);
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