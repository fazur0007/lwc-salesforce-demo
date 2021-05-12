/**
* This is the controller class for the productRegistration visual force page.
* This class takes the data from the visual force page and inserts if necessary
* an account, and a Asset object from the data supplied on the page.
*
* @author james@highondemand.com
* @version 1.0
* @since January 14, 2013
*/
public without sharing class ProductRegistrationControllerV3 {
    
    public String selectedSubCategory { get; set; }
    public Account acct { get; set; }
    public Case objCase { get; set;}    
    public String confirmEmail { get; set; }
    public String personBillingStreet2 { get; set; } 
    public Asset asset { get; set; }       
    public Boolean isSuccess {get; set;}
    public String fieldErrors; 
    public String URL {get; set;}
    public string code {get; set;}
    public List<SelectOption> productSubCategories{get;set;}
    public List<SelectOption> products{get;set;}  
    public String regionCode{get;set;}
    public String currencyCode;
    public String successMessage{get;set;}
    public String lang;
    public String language{ get;set;}
    public String titleMessage{get;set;}
    public Boolean recaptchaValidation{get;set;}
    private Map<Id, String> productIdToProductCodeMap;
    public String brand{get;set;}
    final private String defaultBrand = 'Breville';
    final private Set<String> plmStatusNotStartsWith = new Set<String>{'01%', '00%', '99%', '04%'};  
        public Account dummyAccount { get; set; }
    public string productCode { get; set; }    
    private string productCodeOrCategoryFilter;
    public string subCategoryforProductCode { get; set; }  
    public string productNameforProductCode { get; set; }  
    public string categoryInUrl { get; set; }
    public string offerSpeficUrlHeader { get; set; }
    public string offerSpeficUrlIncludeImage { get; set; }
    public string callfunc{get;set;}
    public Map<String, Id> productsMap{get;set;}
    public List<String> productsList{get;set;}
    public String selectedProduct{get;set;}
    public transient String Attachbody{get;set;}
    public transient String Attachname{get;set;}
    public transient String AttachType{get;set;}
    public String accountPreferredLanguage;
    public boolean showCountryError {get; set;}
    public String countryError {get;set;} 
    
    public boolean multipleProduct {get;set;}
    
    public boolean showTncLink {get;set;}
    public String TncLink {get;set;}
    public boolean showOfferPageHeader {get;set;}
    public String offerPageHeaderTnC_Link {get;set;}
    public String prodReg_Note {get;set;}
    public boolean showBanner {get;set;}
    public String banner {get;set;}
    public boolean isBoutiqueURL {get; set;}
    public boolean displayPopup {get; set;}
    public boolean receiptRequired {get; set;}   
    public Boolean continueWithoutOffer=false;
    
    public Boolean showShareWithPartner { get; set; }
    public String shareWithPartnerTitle { get; set; }
    public Boolean showDisclaimer {get; set;}
    public String disclaimer { get; set; }
    public String consentMessage { get; set; }
    public boolean showLangSec {get;set;}
    //public String phoneLabel {get;set;}
    //public String excludedCurrencies;
       
    public productRegistrationControllerV3() {
        
        showTncLink = false;
        showOfferPageHeader = false;
        multipleProduct = false;
        showCountryError = false;
        countryError = '';
        asset =  new Asset();
        offerPageHeaderTnC_Link = '';
        showBanner=false;
        banner='';
        receiptRequired=false; //Code change for SF-11:Set default value for variable
        isBoutiqueURL = False;
        showLangSec = False;
                
        /*changes to take brand in URL parameter*/
        brand = ApexPages.currentPage().getParameters().get('brand');
        if(brand == null || brand =='')
            brand = defaultBrand;
        
        URL = ApexPages.currentPage().getParameters().get('param');
        regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
        currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
        lang = ApexPages.currentPage().getParameters().get('language');
        showShareWithPartner = false;
        showDisclaimer = false;
        consentMessage = 'NewsLetterV2';

        /* SF-587: Changes to make Phone Number as required field*/
        /*excludedCurrencies = System.Label.Excluded_Currencies_for_required_Email_and_Phone;
        if(!excludedCurrencies.containsIgnoreCase(';'+ currencyCode +';')){
            phoneLabel = 'phone_number';
        }else{
            phoneLabel = 'PhoneV2';
        }*/

        productIdToProductCodeMap = new Map<Id, String>();
        
        //To fetch Language code based on the param passed.
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From Region_Specific__mdt Where EPParameter__c=:URL];
        if(lang != null && lang != ''){
            code = lang;
            if(lang.equalsIgnoreCase('fr')){
                if(URL == 'CA'){
                    code= 'fr_CA';
                   
                }
            }            
        }else{
            code = regionSpecific.LanguageCode__c;  
            lang = regionSpecific.LanguageCode__c;
        }
        accountPreferredLanguage = Utility.getLanguageFromLanguageCode(code);      
        
        objCase = new Case();
        objCase.Country__c = regionCode;
        
        //To have dynamic Labels  
        titleMessage = 'titleMessageProductRegistration_' + regionCode;
        //To display success message
        // Component.Apex.OutputText output;
        //output = new Component.Apex.OutputText();
        //output.expressions.value = '{!$Label.' + 'WarrantySuccessMessage_' + regionCode + '}';
        // output.expressions.value = '{!$Label.WarrantySuccessMessage}'+' '+'{!$Label.brand_'+brand.replaceAll(' ','_')+'}'+' '+'{!$Label.region_'+regionCode+'}'+'.';
        if(Test.isRunningTest())
            successMessage = '';
        else
            successMessage = '';
        
        acct= new Account();
        isSuccess = false;   
        dummyAccount = new Account();
        
        // get product/category specific details
        subCategoryforProductCode='';
        productNameforProductCode='';
        productCodeOrCategoryFilter = null;
        
        categoryInUrl = ApexPages.currentPage().getParameters().get('category');
        productCode = ApexPages.currentPage().getParameters().get('product');
        
        
        if(productCode != null && productCode !=''){
            isBoutiqueURL = True;
            if(URL == 'DE' || URL == 'CH'){
                showLangSec=True;
            }
        }
        
        
        if(categoryInUrl != null && categoryInUrl !='' && productCode != null && productCode !=''){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid URL'));
            productCodeOrCategoryFilter = 'Product_Sub_Family__c =\''+categoryInUrl.replace('_', ' ') +'\' AND ';
            if(productCode.contains(',')){
                productCode=productCode.replaceAll(',','\',\'');
                productCodeOrCategoryFilter = productCodeOrCategoryFilter + 'AX_Item_Number__c IN(\''+productCode+'\')';
                multipleProduct = true; 
            }else{
                multipleProduct = false;
                productCodeOrCategoryFilter = productCodeOrCategoryFilter + 'AX_Item_Number__c = \''+productCode+'\'';
            }
        }
        else{
            if(categoryInUrl != null && categoryInUrl !=''){
                productCodeOrCategoryFilter = 'Product_Sub_Family__c =\''+categoryInUrl.replace('_', ' ') +'\'';
            }
            else if(productCode != null && productCode !=''){
                if(productCode.contains(',')){
                    productCode=productCode.replaceAll(',','\',\'');
                    productCodeOrCategoryFilter = 'AX_Item_Number__c IN(\''+productCode+'\')';
                    multipleProduct = true; 
                }else{
                    multipleProduct = false;
                    productCodeOrCategoryFilter = 'AX_Item_Number__c = \''+productCode+'\'';
                }
                
            }
        }
        
        //To fetch product subcategories
        productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,productCodeOrCategoryFilter,lang);
        if((productCode != null && productCode !='') || (categoryInUrl != null && categoryInUrl !='')){
            if(productSubCategories ==null || productSubCategories.size()==0 ){ 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid URL'));
                isSuccess = true; 
            }
            else{
                for(selectoption selectedOption : productSubCategories){
                    subCategoryforProductCode= selectedOption.getValue();
                }
                selectedSubCategory =subCategoryforProductCode;
            }
        }
        
        //To fetch products
        fetchProducts();

        if(productCode != null && productCode !=''){
            if(products ==null || products.size()==0 ){
                //through error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid URL'));
                isSuccess = true;
            }else{
                for(selectoption selectedOption : products){
                    if(selectedOption.getValue() != '' && selectedOption.getValue() != null){
                        productNameforProductCode = selectedOption.getLabel();
                        //  selectedProduct = selectedOption.getValue();
                        asset.Product2Id  = selectedOption.getValue();
                        
                    }
                    if(selectedOption.getValue() != '' && selectedOption.getValue() != null && !productCode.contains(',')) {
                        selectedProduct = selectedOption.getValue();
                    }
                }
            }
            
        }
        offerSpeficUrlHeader = ApexPages.currentPage().getParameters().get('offer');
        offerSpeficUrlIncludeImage = ApexPages.currentPage().getParameters().get('IncludeIMage');
        checkOffer();
        
        
        //Implementation for smart search
        /*productsMap = Utility.fetchAllProducts(regionCode, brand,plmStatusNotStartsWith ,productCodeOrCategoryFilter,productIdToProductCodeMap,code);
productsList = new List<String>();
productsList.addAll(productsMap.keySet());
if((productCode != null && productCode !='') || (categoryInUrl != null && categoryInUrl !='')){
if(productsList.size()==1){
selectedProduct = productsList[0];
}
}*/
    }
    //SF-544 :Barista Pack -To change Language code based on the language selected.
    public  void checkLanguage(){
        if(language != null && language != ''){
            code = language;       
        }
        accountPreferredLanguage = Utility.getLanguageFromLanguageCode(code);       
        lang=language;
         //To fetch product subcategories
        productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,productCodeOrCategoryFilter,lang);
        if((productCode != null && productCode !='') || (categoryInUrl != null && categoryInUrl !='')){
            if(productSubCategories ==null || productSubCategories.size()==0 ){ 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid URL'));
                isSuccess = true; 
            }
            else{
                for(selectoption selectedOption : productSubCategories){
                    subCategoryforProductCode= selectedOption.getValue();
                }
                selectedSubCategory =subCategoryforProductCode;
            }
        }        
        //To fetch products
        fetchProducts();
    }
    
    //code for product reg note  <!--code change for SF1-336-->
    public void  setRegistrationNote(){
        Component.Apex.OutputText prodRegoutput;
        prodRegoutput = new Component.Apex.OutputText();
        prodRegoutput.expressions.value = '{!$Label.Product_Registration_Note_' + URL + '}';
        prodReg_Note = string.valueOf(prodRegoutput.value); 
    }
    //code for product reg note  <!--end of code change for SF1-336-->
    //
    /*public void fetchProductsBasedOnCountry(){
if(dummyAccount !=null && dummyAccount.BillingCountryCode !=null && dummyAccount.BillingCountryCode != '')
{
String selCountryCode = dummyAccount.BillingCountryCode;
regionCode = Utility.fetchRegionCodeFromCountry(selCountryCode);
currencyCode = Utility.fetchCurrencyCodeFromCountry(selCountryCode);
//productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,null);
fetchProducts();
if(regionCode == '')
{
regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
}
objCase.Country__c = regionCode;
Component.Apex.OutputText output;
output = new Component.Apex.OutputText();
//output.expressions.value = '{!$Label.' + 'WarrantySuccessMessage_' + regionCode + '}';
output.expressions.value = '{!$Label.WarrantySuccessMessage}'+' '+'{!$Label.brand_'+brand.replaceAll(' ','_')+'}'+' '+'{!$Label.region_'+regionCode+'}'+'.';
if(Test.isRunningTest())
successMessage = '';
else
successMessage = string.valueOf(output.value);
}
}*/
    
    /* Picklist of products related to product SubCategory from Product */
    public void fetchProducts(){
        products = Utility.fetchProducts(regionCode, selectedSubCategory, brand,plmStatusNotStartsWith, productCodeOrCategoryFilter, productIdToProductCodeMap, lang);
        checkOffer();
    }
    
    /**
* This method is the save method it validates all the fields. Queries for
* Accounts and creates asset objects.
*/
    
    public pagereference homePageRedirect(){
        list<Region_Specific__mdt> RegionSpecificHomePageURL = [SELECT HomePage_URL__c FROM Region_Specific__mdt 
                                                                WHERE EPParameter__c =: URL LIMIT 1];
        if(RegionSpecificHomePageURL != null && RegionSpecificHomePageURL.size() > 0 ){
            PageReference page = new PageReference(RegionSpecificHomePageURL[0].HomePage_URL__c);
            return page;
        }
        return null;        
    }
    
    /* Code changes for SF-11: display, close popup and continue without Receipt*/
    public void closePopup() {
        displayPopup = false;
    }
    
    public void showPopup() {
        displayPopup = true;
    }
    public void continueWithoutReceipt(){
        displayPopup = false;
        receiptRequired=false;
        continueWithoutOffer=true;
        asset.Offer_Code_Applied__c=null;
        registrationSave();
    }
    
    public  pagereference registrationSave(){
        //Recpatcha check
         String response = ApexPages.currentPage().getParameters().get('response');
            GoogleReCaptchaCtrl googleRecaptcha = new GoogleReCaptchaCtrl();
        /*if(!Test.isRunningTest()) {
recaptchaValidation = googleRecaptcha.validateRecaptchaResponse(response); 
if(!recaptchaValidation){
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Invalid_Captcha_Response));
return null;
}
}*/
        
        /* validate country*/
        
        if(!Utility.countryValidation(dummyAccount.BillingCountryCode, URL)){
            Component.Apex.OutputText countryError;
            countryError = new Component.Apex.OutputText();
            countryError.expressions.value = '{!$Label.InvalidCountry_' + URL + '}';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(countryError.value)));
            dummyAccount.BillingStateCode = null;
            return null;
        } 
        
        asset.Warranty_Product_Sub_Category__c = selectedSubCategory;
        asset.Channel__c = 'Web';
        asset.CustomerRegistrationDate__c = Date.today();
        asset.Status = 'Registered';
        /*if (asset.PurchaseDate == Null){
asset.PurchaseDate = system.today();
}*/
        if(AttachName !=null && AttachName !='' && AttachBody !=null && AttachBody != '' && AttachType !=null && AttachType !=''){           
            if(!(attachType=='image/jpeg' || attachType == 'image/png' || attachType == 'image/gif' || attachType == 'application/pdf')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.InvalidAttachmentV2));
                return null;
            }
        }
        
        fieldErrors ='';
        copyValues();
        checkFields();        
        if(fieldErrors != ''){
            createErrorMessage(Label.Following_Fields_are_Required + ' ' + fieldErrors + Label.Please_make_the_necessary_corrections);
            return null;
        }
        
        if(!Utility.validateEmail(acct.PersonEmail, confirmEmail)){
            return null;
        }
        if(!Utility.validatePostalCode(acct.BillingPostalCode, regionCode)){
            return null;
        }
        if(!Utility.validateBillingStreet(acct.BillingStreet)){
            return null;
        }
        
        if(!Utility.validatePurchaseDate(asset.PurchaseDate,regionCode)){
            return null;
        }
        
        try{           
            if(asset.Batch_Code__c == null || CaseTriggerHandler.isBatchCodeValid(asset.Batch_Code__c, Datetime.now(),asset.PurchaseDate)){
                
                Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
                if(existingaccount == null)
                    acct.AccountSource = 'Web';
                
                asset.Account_Email__c =acct.personEmail;
                asset.CurrencyIsoCode = currencyCode;
                asset.Where_did_you_purchase__c = objCase.Purchased_From__c;
                
                string ax_item_number ='';
                //String productID = productsMap.get(selectedProduct);
                asset.product2ID = selectedProduct;
                ax_item_number = [select AX_Item_Number__c FROM Product2 where ID =: asset.product2ID limit 1].AX_Item_Number__c;
                
                /*Boolean isSerialNumberRequired = [select Serial_Required_for_Registration__c from Product2 where id = :asset.product2ID limit 1].Serial_Required_for_Registration__c;
if(isSerialNumberRequired){
if(asset.SerialNumber == '' || asset.SerialNumber ==null ){
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Serail_Number_Required_V2));
return null;
}
}*/
                asset.Name = acct.FirstName + ' ' + acct.LastName + ' - ' + productIdToProductCodeMap.get(asset.Product2Id) ;
                
                if(asset.Batch_Code__c != null && asset.Batch_Code__c != '' && existingaccount != null && isDuplicateAsset(existingaccount.Id, ax_item_number, asset.Batch_Code__c)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Already_Registered_Product));
                    return null;
                }
                
                List<Offer__c> validOfferList = new List<Offer__c>();
                string op_exactOfferCode ='';
                string op_label='';
                
                if(string.isblank(asset.Offer_Code_Applied__c)) {
                    /* Section to auto generate offer code if the selcted product has applicable for offer */
                    List<Offer__c> OfferForProductList = OfferRedemptionUtility.getOfferForProduct(ax_item_number, currencyCode, asset, acct);
                    system.debug('OfferForProductList:'+OfferForProductList );
                    /* Code changes for SF-13: added validation for Boutique URL*/
                    List<Offer__c> applicableOffers = OfferRedemptionUtility.applicableOffersOnPage(OfferForProductList, isBoutiqueURL);
                    system.debug('applicableOffers :'+applicableOffers );
                    if(applicableOffers !=null  && applicableOffers.size()>0){
                        validOfferList.addAll(applicableOffers);
                    }
                    
                    if(validOfferList !=null  && validOfferList.size()>0 && !continueWithoutOffer){
                        for(Offer__c validOfferRecord : validOfferList){
                            if(validOfferRecord != Null){
                                if(validOfferRecord.RecordType.Name == 'Generate Offer Code'){
                                    asset.Offer_Code_Applied__c = OfferRedemptionUtility.GenerateOfferCodeFormat(validOfferRecord) +''+ (validOfferRecord.SequentialCounter__c+1);
                                    validOfferRecord.SequentialCounter__c =  validOfferRecord.SequentialCounter__c + 1;  
                                    update  validOfferRecord;
                                }
                                if(!String.isblank(asset.ExactofferCode__c)){
                                    asset.ExactOfferCode__c = asset.ExactOfferCode__c + ';' + validOfferRecord.OfferCode__c ;
                                }
                                else{
                                    asset.ExactOfferCode__c = validOfferRecord.OfferCode__c ;
                                }
                                asset.IsApprovalRequired__c = validOfferRecord.IsApprovalRequired__c;
                                asset.OfferWelcomeEmailContent__c  = validOfferRecord.Offer_Welcome_Message__c ;
                                op_exactOfferCode = op_exactOfferCode + '{!$Label.Offer_Welcome_Message_For_' + validOfferRecord.OfferCode__c +'}' + '</br></br>';
                                Component.Apex.OutputText output;
                                output = new Component.Apex.OutputText();
                                output.expressions.value = op_exactOfferCode;
                                if(asset.ExactOfferCode__c == 'UK_OFFER_01' || asset.ExactOfferCode__c == 'UK_WF_OFFER_02' || asset.ExactOfferCode__c == 'AYL'){
                                    List<String> fillers = new List<String>();
                                    fillers.add(brand);
                                    fillers.add(productIdToProductCodeMap.get(asset.Product2Id));
                                    successMessage = string.format(string.valueOf(output.value), fillers); 
                                }else{
                                    successMessage = string.valueOf(output.value);
                                }
                            }
                        }
                    }
                    /* End section to generate offer code */
                }
                else{
                    /* Below section to check if the ented offer code is valid for the selected product*/
                    List<Offer__c> isOfferCodeValidList ;
                    List<Offer__c> OfferForProductList ;
                    isOfferCodeValidList = OfferRedemptionUtility.isOfferCodeValid(ax_item_number, currencyCode, asset, acct);
                    if(isOfferCodeValidList !=null  && isOfferCodeValidList.size()>0){
                        validOfferList.addAll(isOfferCodeValidList);
                        
                        OfferForProductList = OfferRedemptionUtility.getOfferForProduct(ax_item_number, currencyCode, asset, acct);
                        
                        /* Code changes for SF-13: added validation for Boutique URL*/
                        List<Offer__c> applicableOffers = OfferRedemptionUtility.applicableOffersOnPage(OfferForProductList, isBoutiqueURL);
                        if(applicableOffers !=null  && applicableOffers.size()>0){
                            validOfferList.addAll(applicableOffers);
                        }
                        /* Code changes for SF-11: added validation to check if offers need to apply based on Receipt*/
                        if(validOfferList !=null  && validOfferList.size()>0 && !continueWithoutOffer){
                            receiptRequired=true;
                            for(Offer__c validOfferRecord : validOfferList) {
                                if(validOfferRecord != Null){
                                    //check if offer code is already been used
                                    list<Asset> assetsWithSameOfferCode = [select id,ExactOfferCode__c,Offer_Code_Applied__c From asset Where accountid=: acct.Id and Offer_Code_Applied__c=: asset.Offer_Code_Applied__c limit 1]; // and Product2id=: asset.product2Id
                                    
                                    if(assetsWithSameOfferCode !=  Null && assetsWithSameOfferCode.size() > 0){
                                        Component.Apex.OutputText output;
                                        output = new Component.Apex.OutputText();
                                        output.expressions.value = 'The Offer Code has been redeemed !';
                                        successMessage = string.valueOf(output.value);
                                    }else{
                                        if(!String.isblank(asset.ExactofferCode__c)){
                                            asset.ExactOfferCode__c = asset.ExactOfferCode__c + ';' + validOfferRecord.OfferCode__c ;
                                        }else{
                                            asset.ExactOfferCode__c  = validOfferRecord.OfferCode__c ;// Offercode that matched HBE7
                                        }
                                        asset.IsApprovalRequired__c = validOfferRecord.IsApprovalRequired__c;
                                        asset.OfferWelcomeEmailContent__c  = validOfferRecord.Offer_Welcome_Message__c ;
                                        op_exactOfferCode = op_exactOfferCode + '{!$Label.Offer_Welcome_Message_For_' + validOfferRecord.OfferCode__c +'}' + '</br></br>';
                                        Component.Apex.OutputText output;
                                        output = new Component.Apex.OutputText();
                                        output.expressions.value = op_exactOfferCode;
                                        if(asset.ExactOfferCode__c == 'UKE1' || asset.ExactOfferCode__c == 'UK_OFFER_01' || asset.ExactOfferCode__c == 'UK_WF_OFFER_02' || asset.ExactOfferCode__c == 'AYL'){
                                            List<String> fillers = new List<String>();
                                            fillers.add(brand);
                                            fillers.add(productIdToProductCodeMap.get(asset.Product2Id));
                                            successMessage = string.format(string.valueOf(output.value), fillers); 
                                        }else{
                                            if(!Test.isRunningTest())
                                                successMessage = string.valueOf(output.value);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(asset.Offer_Code_Applied__c != Null && asset.ExactOfferCode__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.InvalidOfferCode));  
                        return null;
                    }
                    /* End section */
                }
                /*Code changes for SF-666 customized message on Boutique URL when offer not applied*/
                if(isBoutiqueURL && successMessage==''){
                    system.debug('***In if offer not applied');
                    String message = '{!$Label.OfferNotAppliedBoutiqueURLMessage}';
                    Component.Apex.OutputText output;
                    output = new Component.Apex.OutputText();
                    output.expressions.value = message;
                    successMessage = string.valueOf(output.value);
                }
                /*end of code changes for SF-666*/
                /* Code changes for SF-11: check if receipt is uploaded if offer is applicable*/
                if(receiptRequired && ((AttachName==null || AttachName=='') && (AttachBody==null || AttachBody=='') && (AttachType==null || AttachType==''))){
                    showPopup();
                    asset.ExactOfferCode__c=null;
                    successMessage='';
                    return null;
                }
                /*end of code changes for SF-11*/
                
                
                upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2, currencyCode, accountPreferredLanguage);
                
                 
                
                asset.AccountId =acct.Id;
                asset.ContactId = [select PersonContactId FROM account where ID =: acct.Id limit 1].PersonContactId;
                /*List<Asset> assets = [select id from Asset WHERE Country_Code__c =:countryCode AND AX_Item_Number__c =:request.AX_Item_Number AND account =:account.id];  */
                
               
                
                Asset existingAsset = Utility.getMatchingAsset(asset, acct);
                if (existingAsset != null) {
                    asset.Id = existingAsset.Id;
                }
                
                List<User> lstUsers = [select id from user where email=:acct.personEmail];
                
                if(acct.Agreed_for_Opt_in__c && AutomatedCustomerPortalUserUtility.isBeanzUserToBeCreated(asset.ExactOfferCode__c) && lstUsers.size()==0)
                {                   
                        asset.Do_not_send_registration_email__c = true;
                }
                else if(!acct.Agreed_for_Opt_in__c && AutomatedCustomerPortalUserUtility.isBeanzUserToBeCreated(asset.ExactOfferCode__c)&& lstUsers.size()==0)
                {
                    asset.Include_User_Registration_Link__c = true;
                }
                
                upsert asset;
                
                if (acct.Agreed_for_Opt_in__c && AutomatedCustomerPortalUserUtility.isBeanzUserToBeCreated(asset.ExactOfferCode__c)) 
                {
                    EventBus.publish(new List<User_Registration__e>{
                            new User_Registration__e (
                                Account_ID__c = acct.Id, 
                                Source__c = 'Product Registration Offer',
                                ExpId__c = (String.isNotBlank(lang) ? (brand + lang.remove('_').toUpperCase()) : 'BrevilleENUS'),
                                RecordId__c=asset.Id)
                    });
                }
                
                if(AttachName !=null && AttachName !='' && AttachBody !=null && AttachBody != '' && AttachType !=null && AttachType !=''){             
                    Attachment attach = new Attachment(parentId = asset.Id, name = AttachName, 
                                                       ContentType = AttachType, 
                                                       Body = EncodingUtil.base64Decode(AttachBody)); 
                    insert attach;
                }
                isSuccess = true;

                callfunc='<script> onCompleteEvent(); </script>';
                
                /*if(validOfferRecord !=null && validOfferRecord.RecordType.Name == 'Generate Offer Code'){
validOfferRecord.SequentialCounter__c =  validOfferRecord.SequentialCounter__c + 1;  
update  validOfferRecord;
}*/
            }else{
                callfunc='<script> onBatchCodeErrorEvent(); </script>';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Invalid_Batch_Code));
            }
        }catch (Exception e){
            if(!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            showCountryError = false;
        }
        
        if(isSuccess){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
            showTncLink = false;
            showOfferPageHeader = false;
            showBanner = false;
            showShareWithPartner = false;
            showDisclaimer = false;
            showLangSec = false;
        }
        return null;
    } 
    
    public boolean isDuplicateAsset(String accountId, String ax_item_number, String batch_code){
        List<Asset> assetsList = [select id  from Asset WHERE AccountId =:accountId AND Batch_Code__c =:batch_code AND Product2.AX_Item_Number__c = :ax_item_number];
        if(assetsList != null && assetsList.size() > 0)
            return true;
        return false;
    }
    
    
    /**
* Creates an error messge based on the data sent in.
*/
    private void createErrorMessage(String err){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err));
    }
    
    
    /**
* Adds fields to the fielderror string passed in from the checkfields
* method.
*/
    public void addField(String label){
        if(fieldErrors == ''){
            fielderrors = fielderrors + label;
        }
        if(!fieldErrors.contains(label)){
            fieldErrors = fielderrors + ', ' + label;
        }
    }
    
    /**
* Copies values from the VF page dummyAccount to acct
*/
    public  void copyValues(){
        
        if(acct !=null && dummyAccount !=null){
            acct.FirstName = dummyAccount.FirstName;
            acct.LastName = dummyAccount.LastName;
            acct.personEmail = dummyAccount.personEmail;
            acct.Phone = dummyAccount.Phone;
            acct.BillingCountryCode = dummyAccount.BillingCountryCode;
            acct.BillingStreet = dummyAccount.BillingStreet;
            acct.BillingCity = dummyAccount.BillingCity;
            acct.BillingStateCode = dummyAccount.BillingStateCode;
            acct.BillingPostalCode = dummyAccount.BillingPostalCode;
            acct.ShippingCountryCode = dummyAccount.BillingCountryCode;
            acct.ShippingStreet = dummyAccount.BillingStreet;
            acct.ShippingCity = dummyAccount.BillingCity;
            acct.ShippingStateCode = dummyAccount.BillingStateCode;
            acct.ShippingPostalCode = dummyAccount.BillingPostalCode;
            acct.personBirthDate = dummyAccount.personBirthDate;
            acct.Gender__c = dummyAccount.Gender__c;
            acct.Agreed_for_Opt_in__c = dummyAccount.Agreed_for_Opt_in__c;
        }
        
    }
    
    /**
* Verifies all required fields have been populated on vf page.
*/
    
    public  void checkFields(){
        
        if (String.isBlank(asset.Warranty_Product_Sub_Category__c)) {
            addField(Label.Product_Sub_Category);
        }
        
        /*if (String.isBlank(asset.Product2Id)) {
addField(Label.Asset_Product);
}*/
        
        if(String.isBlank(objCase.Purchased_From__c)){
            addField(Label.Where_did_you_purchase_from);
        }
        
        if(asset.PurchaseDate == null){
            addfield(Label.Purchase_Date);            
        } 
        
        
        if(String.isBlank(acct.FirstName)){
            addfield(Label.First_Name);
        }
        
        if(String.isBlank(acct.LastName)){
            addfield(Label.Last_Name);
        }
        
        if(String.isBlank(acct.BillingStreet)){
            addField(Label.Street);
        }
        
        
        if(String.isBlank(acct.BillingCity)){
            addField(Label.City_Label);
        }
        
        if(String.isBlank(acct.BillingStateCode)){
            All_Literal__mdt countriesWithNoState = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName= 'StateCodeOptionalCountries'];
            //if(acct.BillingCountryCode != 'GB' && acct.BillingCountryCode != 'DE' && acct.BillingCountryCode != 'CZ' && acct.BillingCountryCode != 'AT' && acct.BillingCountryCode != 'BE' && acct.BillingCountryCode != 'LU' && acct.BillingCountryCode != 'NL' && acct.BillingCountryCode != 'CH')
            if(!(countriesWithNoState.Value__c.containsIgnoreCase(';'+ acct.BillingCountryCode +';')))
                addfield(Label.State);
        }
        
        if(String.isBlank(acct.BillingPostalCode)){
            addField(Label.Postal_Code);
        }
        
        if(String.isBlank(acct.BillingCountryCode)){ 
            addfield(Label.Country);
        }
        
        if(String.isBlank(acct.PersonEmail)){
            addfield(Label.Email);
        }
        
        if(String.isBlank(confirmEmail)){
            addfield(Label.confirmEmail);
        }   
        
        if(String.isBlank(selectedProduct)){
            addfield(Label.ProductV2);
        }
        /* SF-587: Changes to make Phone Number as required field*/
        /*if(String.isBlank(acct.Phone) && !excludedCurrencies.containsIgnoreCase(';'+ currencyCode +';')){
            addfield(Label.phone_number);
        }*/
        
        /*if(String.isBlank(asset.Batch_Code__c)){
addfield(Label.Product_Batch_Code_V2);
}*/ 
        /*if(String.isBlank(AttachBody)){
addfield(Label.UploadFieV2);
}*/
    }
    
    public void validateCountry(){
        if(Utility.countryValidation(dummyAccount.BillingCountryCode, URL)){
            dummyAccount.BillingStateCode = null;
            showCountryError = false;
            countryError = '';
        }else{
            dummyAccount.BillingStateCode = null;
            showCountryError = true;
            Component.Apex.OutputText cError;
            cError = new Component.Apex.OutputText();
            cError.expressions.value = '{!$Label.InvalidCountry_' + URL + '}';
            countryError = String.valueOf(cError.value);
        }
    }
    
    public void checkOffer(){    
        offerPageHeaderTnC_Link='';
        banner='';
        String ax_item_number = '';
        asset.Product2Id = selectedProduct;
        if(asset.Product2Id != Null){
            ax_item_number = [select AX_Item_Number__c FROM Product2 where ID =: asset.Product2Id limit 1].AX_Item_Number__c;
        }
        showTncLink = false;
        showOfferPageHeader = false;
        showBanner = false;
        showShareWithPartner = false;
        showDisclaimer = false;
        consentMessage = 'NewsLetterV2';
        
        if(ax_item_number != null && ax_item_number != '' && selectedSubCategory != null && selectedSubCategory != ''){
            List<Offer__c> validOfferList = OfferRedemptionUtility.getOfferForProduct(ax_item_number,currencyCode, asset.PurchaseDate);
            /* Code changes for SF-13: added validation for Boutique URL*/
            List<Offer__c> applicableOffers = OfferRedemptionUtility.applicableOffersOnPage(validOfferList, isBoutiqueURL);
            
            if(applicableOffers !=null  &&  applicableOffers.size() > 0 ){
                receiptRequired=true; //Code change for SF-11: if offer is applicable make recipt required true
                banner = '';
                for(Offer__c validOfferRecord : applicableOffers){
                    String PageHeader = '';
                    String TnC_Link ='';
                    String bannerImage = '';
                    if(validOfferRecord != null && validOfferRecord.TnC_Link__c != null && validOfferRecord.TnC_Link__c != ''){
                        showTncLink = true;
                        /****code change for SF-555: Support TnC in multiple languages****/
                        String TnC_Link_Value = '{!$Label.' + validOfferRecord.TnC_Link__c + '}';
                        //TnC_Link =  '<u><a href="'+validOfferRecord.TnC_Link__c+'" target="_blank">Click here for offer terms &amp; conditions</a></u></br>' ;
                        Component.Apex.OutputText output = new Component.Apex.OutputText();
                        output.expressions.value = TnC_Link_Value;
                        if(!Test.isRunningTest()) 
                            TnC_Link = string.valueOf(output.value);
                        /****end of code change for SF-555****/
                    }
                    if(validOfferRecord != null && validOfferRecord.PageHeader__c != null && validOfferRecord.PageHeader__c != ''){
                        showOfferPageHeader = true;
                        /****code change for SF-555 : Support Page Header in multiple languages****/
                        String PageHeader_Value = '{!$Label.' + validOfferRecord.PageHeader__c + '}';
                        //PageHeader = validOfferRecord.PageHeader__c ;
                        Component.Apex.OutputText output = new Component.Apex.OutputText();
                        output.expressions.value = PageHeader_Value;
                        if(!Test.isRunningTest()) 
                            PageHeader = string.valueOf(output.value);
                        /****end of code change for SF-555****/
                    }else{
                        showOfferPageHeader = false;
                    }
                    offerPageHeaderTnC_Link = offerPageHeaderTnC_Link + PageHeader + '</br>'+ TnC_Link + '</br>';
                    
                    /****changes for SF1-476 : Added Banner related changes****/
                    if(validOfferRecord != null && validOfferRecord.Banner_Link__c != null && validOfferRecord.Banner_Link__c != ''){
                        showBanner = true;
                        String bannerLink = '{!$Label.' + validOfferRecord.Banner_Link__c + '}';
                        String bannerImageTag = '<img src=' + bannerLink + ' style="margin-bottom:5px;width: 100%"/>';
                        Component.Apex.OutputText output = new Component.Apex.OutputText();
                        output.expressions.value = bannerImageTag;
                        if(!Test.isRunningTest()) 
                            bannerImage = string.valueOf(output.value);                        
                    }else{
                        showBanner = false;
                    }
                    banner = banner + bannerImage;
                    /****end of code change for SF1-476****/
                    
                    if(validOfferRecord != null && validOfferRecord.ShareWithPartner__c == true && String.isNotBlank(validOfferRecord.PartnerSharingTitle__c)){
                        showShareWithPartner = true;
                        shareWithPartnerTitle = getTextFromLabel(validOfferRecord.PartnerSharingTitle__c);
                        if (String.isNotBlank(validOfferRecord.Disclaimer__c)) {
                            showDisclaimer = true;
                            disclaimer = getTextFromLabel(validOfferRecord.Disclaimer__c);
                        }
                    }
                    
                    if (validOfferRecord != null && String.isNotBlank(validOfferRecord.ConsentMessage__c)) {
                       consentMessage = validOfferRecord.ConsentMessage__c;
                    }
                }
            }
        }
        
        if(offerSpeficUrlHeader!=null)
        {
            system.debug('offerSpeficUrlHeader:'+offerSpeficUrlHeader);
            showOfferPageHeader = true;
            offerPageHeaderTnC_Link = getTextFromLabel(offerSpeficUrlHeader+'_header');
            system.debug('offerPageHeaderTnC_Link :'+offerPageHeaderTnC_Link );
            if(offerSpeficUrlIncludeImage!=null && String.IsBlank(banner))
            {
                string bannerImage=''; 
                showBanner = true;
                String bannerLink =  '{!$Label.' + offerSpeficUrlHeader+'_ImageLink' + '}'; 
                String bannerImageTag = '<img src=' + bannerLink + ' style="margin-bottom:5px;width: 100%"/>';
                Component.Apex.OutputText output = new Component.Apex.OutputText();
                output.expressions.value = bannerImageTag;
                if(!Test.isRunningTest()) 
                    bannerImage = string.valueOf(output.value);
                banner = banner + bannerImage;  
            }
            consentMessage = offerSpeficUrlHeader+'_consent';
         }
    }
    
    private String getTextFromLabel(String labelName) {
        String text = '';
        if (String.isNotBlank(labelName)) {
            String title_Value = '{!$Label.' + labelName + '}';
            Component.Apex.OutputText output = new Component.Apex.OutputText();
            output.expressions.value = title_Value;
            if (!Test.isRunningTest()) {
                text = String.valueOf(output.value);
            }
        }
        return text;
    }
}