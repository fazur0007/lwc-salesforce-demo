public without sharing class ProductRegistrationLightningController {
    
     @AuraEnabled
     public static Account fetchAccountId () {
        Account currentUserAccount = new Account();
        User CurrentUser = [Select AccountId,Community_Email_Verified__c,email from User where id =: Userinfo.getUserid() limit 1][0];
        if(CurrentUser.Community_Email_Verified__c)
        {
            currentUserAccount = [select id,firstname,lastname,personemail,Phone,ShippingCity,Shipping_Street_Line_1__c,ShippingStreet,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingCountryCode,ShippingCountry from Account where Id=:CurrentUser.AccountId][0];
            if(currentUserAccount.lastname.equalsIgnoreCase('Breville Customer') || currentUserAccount.lastname.equalsIgnoreCase('Beanz Customer'))
                currentUserAccount.lastname = '';
        }
        else
        {
            currentUserAccount = [select id,personemail from Account where Id=:CurrentUser.AccountId][0];
        }

        return currentUserAccount;
    }
    
    @AuraEnabled
     public static string deleteAttachment(String attachmentId) {
        try
        {
         	delete [SELECT Id FROM ContentDocument WHERE Id=:attachmentId];
            return 'SUCCESS';
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static SummaryDetail getProductRegistrationSummaryDetails(String accId, String asstId) {
        SummaryDetail data = new SummaryDetail();
        data.accountdata = [SELECT Id, Name, Name__c, Phone, BillingCountry, BillingStreet, Billing_Street_Line_1__c, BillingCity, BillingState, BillingPostalCode, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, Shipping_Street_Line_1__c, Shipping_Street_Line_2__c FROM Account WHERE ID =: accId];
        data.assetData = [SELECT(Select Id, Name FROM Attachments Order By Createddate DESC Limit 1), Product2.Name, AccountId, Id, Name, Product2Id, ProductCode, ProductDescription, ProductFamily, PurchaseDate, SerialNumber FROM Asset WHERE Id =: asstId];
        return data;
    }

    public class SummaryDetail {
        @AuraEnabled public Account accountData {
            get;
            set;
        }
        @AuraEnabled public Asset assetData {
            get;
            set;
        }
    }


    public class ProductSummaryDetails {
        @AuraEnabled public String productName {
            get;
            set;
        }
        @AuraEnabled public String modelName {
            get;
            set;
        }
    }

    public class ResponseStatus {
        @AuraEnabled public String messsage {
            get;
            set;
        }
        @AuraEnabled public Boolean isSuccess {
            get;
            set;
        }
        @AuraEnabled public Boolean isOfferCodeApplied {
            get;
            set;
        }
        @AuraEnabled public String reasonForNoOffer {
            get;
            set;
        }
         @AuraEnabled public String assetOfferCode {
            get;
            set;
        }
    }
    
    
    
    /*
        calling this method on doinit From summary Registration page
    */
    @AuraEnabled
    public static ProductSummaryDetails getProductSummaryDetails(String assetRecordString) {
    
        Asset assetRecord = (Asset)JSON.deserialize(assetRecordString, Asset.class);
        ProductSummaryDetails data = new ProductSummaryDetails();
        Product2 product = [SELECT Id, Name, Product_Sub_Family__c FROM Product2 WHERE ID =: assetRecord.Product2Id];
        data.productName = product.Name;
        data.modelName = product.Product_Sub_Family__c;
        return data;
    }
    @AuraEnabled
    public static ResponseStatus submitClaim(String acctString, String assetString, String contentDocumentId,string offerCode) {
        Account acct = (Account)JSON.deserialize(acctString, Account.class);
        Asset asset = (Asset)JSON.deserialize(assetString, Asset.class);
        offerCode = getOfferCode(offerCode);
        ResponseStatus response = new ResponseStatus();
        response.isOfferCodeApplied = false;
        // Need to handle getting the accountId for Non Community users
        User loggedInuser;
        try {
            loggedInuser = [SELECT Id, Exp_ID__c, accountId, Account.BillingStreet, Account.BillingCity, Account.BillingCountryCode
                            FROM User WHERE Exp_ID__c != null and Id =: UserInfo.getUserId()];
        } catch(Exception ex) {
            response.messsage = 'No Exp Id Found for the logged in User';
            response.isSuccess = false;
            return response;
        }
        
        if (String.isBlank(loggedInuser.Account.BillingStreet) || String.isBlank (loggedInuser.Account.BillingCity) || 
            String.isBlank(loggedInuser.Account.BillingCountryCode))
        {
            acct.BillingStreet = acct.ShippingStreet;
            acct.BillingCity = acct.ShippingCity;
            acct.BillingCountryCode = acct.ShippingCountryCode;
            acct.BillingStateCode = acct.ShippingStateCode;
            acct.BillingPostalCode = acct.ShippingPostalCode;
        }
        String personAccountCountryCode;	
        if (String.isNotBlank(loggedInuser.Account.BillingCountryCode))	
        {	
            personAccountCountryCode = loggedInuser.Account.BillingCountryCode;	
        }
            
        String experienceId = loggedInuser.Exp_ID__c;
        System.debug('experienceId  '  +  experienceId);
        String brand;
        Map < String, String > configMap = CommunityUserManagementUtility.GetUserAttributesFromExpId(experienceId);
        brand = configMap.get('Brand');
        if (brand.equalsIgnoreCase('app')) {
            brand = 'breville';
        }
        System.debug('configMap  '  +  configMap);
        System.debug('brand  '  +  brand);

        String currencyCode = configMap.get('Currency');
        Boolean isSucess = false;
        Map < Id, String > productIdToProductCodeMap = new Map < Id, String > ();
        System.debug('asset.Batch_Code__c   '+  asset.Batch_Code__c);
        System.debug('asset.PurchaseDate   '+  asset.PurchaseDate);
        System.debug('asset:   '+  asset);
        

        try {
            if (String.isBlank (asset.Batch_Code__c) || CaseTriggerHandler.isBatchCodeValid(asset.Batch_Code__c, Datetime.now(), asset.PurchaseDate)) {
               System.debug('asset.Batch_Code__c   '+  asset.Batch_Code__c);
                string ax_item_number = '';
                ax_item_number = [select AX_Item_Number__c FROM Product2 where ID =: asset.product2ID limit 1].AX_Item_Number__c;
                System.debug('ax_item_number   ' +  ax_item_number);
                Asset existingAsset = Utility.getAssetForExistingAccount(loggedInuser.AccountId, asset);
                System.debug('existingAsset  ' +  existingAsset);
                if(existingAsset!=null && String.isNotBlank(existingAsset.ExactOfferCode__c)) {
                    response.messsage = 'Already_Registered_Product';
                    response.isSuccess = false;
                    return response;
                }
                List < Offer__c > validOfferList = new List < Offer__c > ();         
                if (string.isblank(asset.Offer_Code_Applied__c)) {                                     
                    List < Offer__c > OfferForProductList = OfferRedemptionUtility.getOfferForProduct(ax_item_number, currencyCode, asset, acct);
                    List < Offer__c > applicableOffers = OfferRedemptionUtility.applicableOffersOnPage(OfferForProductList, true);
                    system.debug('OfferForProductList:'+OfferForProductList);
                    system.debug('applicableOffers:'+applicableOffers);
                    if (applicableOffers != null && applicableOffers.size() > 0) {
                        validOfferList.addAll(applicableOffers);
                    }
                    system.debug('validOfferList:'+validOfferList.size());
                    if (validOfferList != null && validOfferList.size() > 0) {
                        for (Offer__c validOfferRecord: validOfferList) {
                            if (validOfferRecord != Null) {
                                system.debug('validOfferRecord.RecordType.Name>>>>'+validOfferRecord.RecordType.Name);
                                if (validOfferRecord.RecordType.Name == 'Generate Offer Code') {
                                    asset.Offer_Code_Applied__c = OfferRedemptionUtility.GenerateOfferCodeFormat(validOfferRecord) + '' + (validOfferRecord.SequentialCounter__c + 1);
                                    validOfferRecord.SequentialCounter__c = validOfferRecord.SequentialCounter__c + 1;
                                    update validOfferRecord;
                                }
                                //stateUrlParam
                                if(validOfferRecord.OfferCode__c.containsIgnoreCase(offerCode))
                                {
                                    if (String.isblank(asset.ExactofferCode__c)) {
                                        asset.ExactOfferCode__c = validOfferRecord.OfferCode__c;
                                    } else {
                                        asset.ExactOfferCode__c = asset.ExactOfferCode__c + ';' + validOfferRecord.OfferCode__c;                                        
                                    }
                                }
                                response.isOfferCodeApplied = true;
                                asset.IsApprovalRequired__c = validOfferRecord.IsApprovalRequired__c;
                                if (validOfferRecord.IsApprovalRequired__c)
                                    asset.Approval_Status__c = 'Submitted';
                                asset.OfferWelcomeEmailContent__c = validOfferRecord.Offer_Welcome_Message__c;
                                asset.Include_Chefsteps_Offer__c = validOfferRecord.Include_Chefsteps_Offer__c;
                            }
                        }
                    }
                    /* End section to generate offer code */
                }
                acct.Id = loggedInuser.AccountId;
                if (String.isNotBlank(loggedInuser.Account.BillingCountryCode))	
                    acct.BillingCountryCode = personAccountCountryCode;
                
                System.debug(JSON.Serialize(acct));
                
                update acct;
                system.debug('Value');

                if (existingAsset != null) {
                    asset.Id = existingAsset.Id;
                }
                asset.AccountId = loggedInuser.AccountId;
                String productName = [Select Name From Product2 Where id =: asset.product2ID].Name;
                asset.Name = acct.FirstName + ' ' + acct.LastName + ' - ' +  productName;
                asset.Channel__c = 'Web';
                asset.CustomerRegistrationDate__c = Date.today();
                asset.Status = 'Registered';
                if(String.isNotBlank(asset.Selected_Offer_Line_Item__c))
                {
                    List<Offer_Order_Items__c> lstOfferLineItems = [select id,Product__r.AX_Item_Number__c,Product__r.Description from Offer_Order_Items__c where Id=:asset.Selected_Offer_Line_Item__c];
                    if(lstOfferLineItems.size()>0)
                    {
                    	asset.Selected_gift_item_number__c = lstOfferLineItems[0].Product__r.AX_Item_Number__c;
                        asset.Selected_gift_item_name__c = lstOfferLineItems[0].Product__r.Description;
                    }
                }
                upsert asset;
                List<Asset> CurrAsset = [select id,Asset_code__c,ExactofferCode__c,PurchaseDate from Asset where id=:asset.Id];
                if(String.isBlank(CurrAsset[0].ExactofferCode__c))
                {
                    Offer__c allOffers = OfferRedemptionUtility.getOfferForProduct(ax_item_number,currencyCode);
                    List<Offer__c> OffersWithPurchaseDateFilter = OfferRedemptionUtility.getOfferForProduct(ax_item_number,currencyCode,CurrAsset[0].PurchaseDate);
                    if(allOffers!=null && OffersWithPurchaseDateFilter.size()<=0)
                        response.reasonForNoOffer = 'PurchaseDateMisMatch';
                }
                else
                	response.assetOfferCode = CurrAsset[0].Asset_code__c;

                system.debug('asset>>>>>'+asset.Id);
                system.debug('contentDocumentId>>>>>'+contentDocumentId);
                List<ContentDocumentLink> contentDocumentLink = cloneAndInsertContentDocumentLinkRecord(asset.id,contentDocumentId);
                if (contentDocumentLink != null && contentDocumentLink.size() > 0) {
                    response.messsage = 'Sucessfully Insert the asset : ' + asset.Id;
                    response.isSuccess = True;
                } else {
                    response.messsage = 'Error in uploading attachment  : ' + asset.Id;
                    response.isSuccess = false;
                }
            }
        } catch (Exception ex) {
            response.messsage = ex.getMessage();
            response.isSuccess = false;
        }

        return response;

    }


    public class Product {

        public String Name;
        public String Description;
        public String ProductId;
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> cloneAndInsertContentDocumentLinkRecord(String recordId, String documentObjectId){
        system.debug('Inside Method>>>'+documentObjectId);
        List<ContentDocumentLink> listOfContentDocumentLinkTobeInserted = new List<ContentDocumentLink>();
        List<ContentDocumentLink> listOfContentDocumentLinkTobeDeleted = new List<ContentDocumentLink>();
        for(ContentDocumentLink ContentDocumentLinkRecord : [SELECT Id,ContentDocumentId,Visibility,ShareType,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId=:documentObjectId]) {
            ContentDocumentLink clonedContentDocumentLinkRecord = ContentDocumentLinkRecord.clone();
            clonedContentDocumentLinkRecord.LinkedEntityId = recordId;
            clonedContentDocumentLinkRecord.ShareType = ContentDocumentLinkRecord.ShareType;
            listOfContentDocumentLinkTobeInserted.add(clonedContentDocumentLinkRecord);
            listOfContentDocumentLinkTobeDeleted.add(ContentDocumentLinkRecord);
        }
        if(listOfContentDocumentLinkTobeInserted.size() > 0)
            Database.insert(listOfContentDocumentLinkTobeInserted,false);
        if(listOfContentDocumentLinkTobeDeleted.size() > 0)
            Database.delete(listOfContentDocumentLinkTobeDeleted,false);
        return listOfContentDocumentLinkTobeInserted;
    }

    private static String getProductCategoryFilter (String offerCode)
    {
        String productCategoryFilter, productCode;
        offerCode = getOfferCode(offerCode);
        offerCode = offerCode + '%';
        
        List < Offer__c > lstOffers = [select id, MultipleProducts__c from Offer__c where OfferCode__c like :offerCode
            and Active__c = true
        ];

        if (lstOffers == null || lstOffers.isEmpty())
            return null;

        for (Offer__c ObjOffer: lstOffers)
        {
            if (String.IsNotBlank(ObjOffer.MultipleProducts__c))
            {
                String strMulProd = ObjOffer.MultipleProducts__c;
                strMulProd = strMulProd.replaceAll(';', '\',\'');
                strMulProd = strMulProd.removeEnd(',\'').removeStart('\',');
                
                if (String.isBlank(productCode))
                {
                    productCode = strMulProd;
                }
                else
                {
                    productCode = productCode + ',' + strMulProd;                    
                }
                system.debug('strMulProd:' + strMulProd);
            }
        }
        
        productCategoryFilter = 'AX_Item_Number__c IN(' + productCode + ')';
        system.debug('productCategoryFilter:' + productCategoryFilter);
        return productCategoryFilter;
    }

    static Set <String> plmStatusNotStartsWith = new Set<String> {'01%','00%','99%', '04%'};
        
    private static String getRegionCode (Map<String, String> userConfig)
    {
        string regionCode = Utility.fetchRegionCodeFromEPRegion(userConfig.get('Locale').right(2));
        system.debug('regionCode:' + regionCode);
        return regionCode;
    }
    
    private static Map<String, String >  getCurrentUserConfig() {
        User loggedInUser = [SELECT Id, Exp_ID__c, accountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        String experienceId;
        if (loggedInUser == null || String.isBlank(loggedInUser.Exp_ID__c))
       		experienceId = 'brevilleENAU';
		else         
        	experienceId = loggedInuser.Exp_ID__c;
        
        Map<String, String > configMap = CommunityUserManagementUtility.GetUserAttributesFromExpId(experienceId);
        System.debug('configMap:  '+configMap);
        return configMap;
    }
    
    @AuraEnabled
    public static List < ItemWrapper > getProductCategories(string offerCode) 
    {
        
        String productCategoryFilter = getProductCategoryFilter(offerCode);
        Map<String, String> userConfig = getCurrentUserConfig();
        List < ItemWrapper > productCategories = new List < ItemWrapper > ();

        List <SelectOption> options = Utility.fetchProductSubcategories(getRegionCode(userConfig), userConfig.get('Brand'), 
                                                                        plmStatusNotStartsWith, productCategoryFilter, userConfig.get('Locale'));
        System.debug('Product Category Options: '+options);

        for (SelectOption product: options) {
            ItemWrapper item = new ItemWrapper();
            item.value = product.getValue();
            item.label = product.getLabel();
            item.disabled = product.getDisabled();
            productCategories.add(item);
        }
        return productCategories;
    }
    
    @AuraEnabled
    public static List < ProductWrapper > getProducts(String category, String offerCode) 
    {

		String productCategoryFilter = getProductCategoryFilter(offerCode);
        Map<String, String> userConfig = getCurrentUserConfig();
        List <SelectOption> options = Utility.fetchProducts(getRegionCode(userConfig), category, userConfig.get('Brand'),
                                                            plmStatusNotStartsWith, productCategoryFilter, null, userConfig.get('Locale'));
        system.debug('Products Options: '+options);

        List < ProductWrapper > products = new List < ProductWrapper > ();
        for (SelectOption product: options) {
            ProductWrapper item = new ProductWrapper();
            item.value = product.getValue();
            item.label = product.getLabel();
            item.disabled = product.getDisabled();
            products.add(item);
        }
        return products;
    }

    public class ItemWrapper {
        @AuraEnabled
        public String value {
            get;
            set;
        }
        @AuraEnabled
        public String label {
            get;
            set;
        }
        @AuraEnabled
        public Boolean disabled {
            get;
            set;
        }
    }
    
    public class ProductWrapper {
        @AuraEnabled
        public String value {
            get;
            set;
        }
        @AuraEnabled
        public String label {
            get;
            set;
        }
        @AuraEnabled
        public Boolean disabled {
            get;
            set;
        }
    }
   
    @AuraEnabled 
    public static Map<String, String> getCountryList(string offerCode){        
        string applicableCountriesString;
        offerCode = getOfferCode(offerCode);

        Offer__c lstOffers = [select id,OfferCode__c,CurrencyIsoCode,Applicable_Countres__c from Offer__c 
                              where OfferCode__c like : offerCode+'%'
                              and Active__c = true
                              LIMIT 1];
        applicableCountriesString = lstOffers.Applicable_Countres__c;
        if (String.isBlank (applicableCountriesString))
        {
            Map<String, Region_Specific__mdt> mapOfRegionSpecific = Region_Specific__mdt.getAll();
            for(String regionName : mapOfRegionSpecific.keySet()){
                String currencyCode = mapOfRegionSpecific.get(regionName).Currency__c;
                if(currencyCode.equalsIgnoreCase(lstOffers.CurrencyIsoCode)){
                    applicableCountriesString = mapOfRegionSpecific.get(regionName).ValidCountries__c;
                }
            }
        }

        System.debug ('applicableCountriesString: ' + applicableCountriesString);
        Map<String, String> options = new Map<String, String>();
        Schema.sObjectType objType = Account.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('BillingCountryCode').getDescribe().getPickListValues();
        for (Schema.PicklistEntry v : values){
            System.debug ('Value: ' + v.getValue() + ' --- Label: ' + v.getLabel());
            if(applicableCountriesString.containsIgnoreCase(v.getValue())){
                options.put(v.getValue(), v.getLabel());    
            }
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getStateFieldValue(){
        Map<String, String> options = new Map<String, String>();
        Schema.sObjectType objType = Account.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('BillingStateCode').getDescribe().getPickListValues();
        for (Schema.PicklistEntry v : values){
            options.put(v.getValue(), v.getLabel());
        }
        system.debug('options>>>>>'+options);
        return options;
        
    }
    
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    private static String getOfferCode (String inputOfferCode)
    {
        if(inputOfferCode.equalsIgnoreCase('AustraliaMothersDay'))
            return 'AusMday2021';
        else
            return inputOfferCode;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> getGiftProducts(Asset currAsset,string selectedProduct,string offerCode) {
        system.debug('currAsset:'+currAsset);
        offerCode = getOfferCode(offerCode);
        List<Map<String, String>> items = new List<Map<String, String>>();
        Map<String,String> mapChooseOfferProducts = new Map<String,String>();
        List < Offer__c > validOfferList = new List < Offer__c > ();
        Product2 currProduct = [select id,Ax_Item_number__c from Product2 where id=:selectedProduct];
        
        Map<String, String> userConfig = getCurrentUserConfig();
        String currencyCode = userConfig.get('Currency');
        List<Offer__c> OfferForProductList = OfferRedemptionUtility.getOffersForProduct(currProduct.Ax_Item_number__c, currencyCode);
        List<Offer__c> filteredOfferForProductList = new List<Offer__c>();
        for(Offer__c objCurrOffer: OfferForProductList)
        {
            if(objCurrOffer.OfferCode__c.containsIgnoreCase(offerCode))
                filteredOfferForProductList.Add(objCurrOffer);
        }
        List <Offer__c> applicableOffers = OfferRedemptionUtility.applicableOffersOnPage(filteredOfferForProductList, true);
        system.debug('applicableOffers:'+applicableOffers);
        system.debug('OfferForProductList:'+OfferForProductList);
        if (applicableOffers != null && applicableOffers.size() > 0) {
            validOfferList.addAll(applicableOffers);
        }
        if (validOfferList != null && validOfferList.size() > 0) {
            List<Offer_Order_Items__c> lstOrderLineItems =  [select Id,Product__c,Product__r.Description from Offer_Order_Items__c 
                                                             where Offer_Order__r.Offer__c=:validOfferList];
            if(lstOrderLineItems.size()>0)
            {
                for(Offer_Order_Items__c ObjItem:lstOrderLineItems)
                {
                    mapChooseOfferProducts.put(ObjItem.Id,ObjItem.Product__r.Description);
                }
            }
        }
        system.debug('mapChooseOfferProducts:'+mapChooseOfferProducts);

        for (String mapKey : mapChooseOfferProducts.keySet()) {
            items.add(new Map<String, String>{'value' => mapKey, 'label' => mapChooseOfferProducts.get(mapKey)});
        }
        return items;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
   
    public class MyPickListInfo{
        public String validFor;
    }
    
    @AuraEnabled
    public static List<PicklistOption> getStates(String selectedCountry, String objectAPIName,
                                                String countryPicklistAPIName, String statePicklistAPIName){
        List<PicklistOption> stateList = new List<PicklistOption>();
        if(String.isBlank (selectedCountry)){
            return stateList;
        }
        Map<String,List<String>> valueMap = 
            DependentPicklistUtils.getFieldDependencies(
            objectAPIName,countryPicklistAPIName,statePicklistAPIName);
		system.debug('valueMap>>>>.'+valueMap);
        if(valueMap != null){
            for(String state: valueMap.get(selectedCountry)){
                stateList.add(new PicklistOption(state,state));
            }
        }
        return stateList;
    }
    
    @AuraEnabled
    public static List<PicklistOption> getStatesWithStateCodes(String selectedCountry, String objectAPIName,
                                                String countryPicklistAPIName, String statePicklistAPIName){
        List<PicklistOption> stateList = new List<PicklistOption>();
        if(String.isBlank (selectedCountry)){
            return stateList;
        }
                                                    
         Map<String,String> valueMap = DependentPicklistUtils.getStateCodesForCountry(objectAPIName,countryPicklistAPIName,statePicklistAPIName,selectedCountry);
         system.debug('valueMap>>>>.'+valueMap);
                                                    
       	if(valueMap != null){
            for(String state: valueMap.KeySet()){
                stateList.add(new PicklistOption(valueMap.get(state),state));
            }
        }                                                            
        return stateList;
    }
    
    public class PicklistOption {
     
        @AuraEnabled
        public String label { get; set; }
     
        @AuraEnabled
        public String value { get; set; }
     
        public PicklistOption( String label, String value ) {
            this.label = label;
            this.value = value;
        }
    }

}