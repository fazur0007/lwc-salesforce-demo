/**
* This is the controller class for the productRegistration visual force page.
* This class takes the data from the visual force page and inserts if necessary
* an account, and a Asset object from the data supplied on the page.
*
* @author james@highondemand.com
* @version 1.0
* @since January 14, 2013
*/
public without sharing class ProductRegistrationController {
    
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
    public String successMessage;
    public String lang;
    public String titleMessage{get;set;}
    public Boolean recaptchaValidation{get;set;}
    private Map<Id, String> productIdToProductCodeMap;
    public String brand{get;set;}
    final private String defaultBrand = 'Breville';
    final private String plmStatusNotStartsWith = '01%';
    public Account dummyAccount { get; set; }    
    public string productCode { get; set; }    
    private string productCodeOrCategoryFilter;
    public string subCategoryforProductCode { get; set; }  
    public string productNameforProductCode { get; set; }  
    public string categoryInUrl { get; set; }
    public String accountPreferredLanguage;
    
    public boolean showCountryError {get; set;}
    public String countryError {get;set;} 
    
    public boolean multipleProduct {get;set;}
    
    public boolean showTncLink {get;set;}
    public String TncLink {get;set;}
    public String axItemNo {get; set;}
    public String footerContent {get; set;}
    
    public boolean showOfferPageHeader {get;set;}
    public String offerPageHeader  {get;set;}
    
    public String selectedProduct {get;set;}
    
    public productRegistrationController() {
        showTncLink = false;
        showOfferPageHeader = false;
        multipleProduct = false;
        showCountryError = false;
        countryError = '';
        asset =  new Asset();
        
        /*changes to take brand in URL parameter*/
        brand = ApexPages.currentPage().getParameters().get('brand');
        if(brand == null || brand =='')
            brand = defaultBrand;
        
        URL = ApexPages.currentPage().getParameters().get('param');
        regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
        currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
        lang = ApexPages.currentPage().getParameters().get('language');
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
            
        }
        accountPreferredLanguage = Utility.getLanguageFromLanguageCode(code);
        
        objCase = new Case();
        objCase.Country__c = regionCode;
        
        //To have dynamic Labels  
        titleMessage = 'titleMessageProductRegistration_' +regionCode;
        footerContent = 'ContactUSWebToCase_' +regionCode;
        
        //To display success message
        Component.Apex.OutputText output;
        output = new Component.Apex.OutputText();
        //output.expressions.value = '{!$Label.' + 'WarrantySuccessMessage_' + regionCode + '}';
        output.expressions.value = '{!$Label.WarrantySuccessMessage}'+' '+'{!$Label.brand_'+brand.replaceAll(' ','_')+'}'+' '+'{!$Label.region_'+regionCode+'}'+'.';
        if(Test.isRunningTest())
            successMessage = '';
        else
            successMessage = string.valueOf(output.value);
        
        acct = new Account();
        isSuccess = false;   
        dummyAccount = new Account();
        
        // get product/category specific details
        subCategoryforProductCode='';
        productNameforProductCode='';
        productCodeOrCategoryFilter = null;
        
        categoryInUrl = ApexPages.currentPage().getParameters().get('category');
        productCode = ApexPages.currentPage().getParameters().get('product');
        
        if(categoryInUrl != null && categoryInUrl !='' && productCode != null && productCode !=''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid URL'));
            isSuccess = true; 
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
        productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,productCodeOrCategoryFilter, lang);
        if((productCode != null && productCode !='') || (categoryInUrl != null && categoryInUrl !='')){
            if(productSubCategories ==null || productSubCategories.size()==1 ){ 
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
            if(products ==null || products.size()==1 ){
                //through error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid URL'));
                isSuccess = true; 
            }else{
                for(selectoption selectedOption : products){
                    if(selectedOption.getValue() != '' && selectedOption.getValue() != null){
                        productNameforProductCode =selectedOption.getLabel();
                        asset.Product2Id  = selectedOption.getValue();
                    }
                    if(selectedOption.getValue() != '' && selectedOption.getValue() != null && !productCode.contains(',')) {
                       selectedProduct = selectedOption.getValue();
        			   }
                }
            }
        }
        checkOffer();
    }
    
    /*public void fetchProductsBasedOnCountry(){
if(dummyAccount !=null && dummyAccount.BillingCountryCode !=null && dummyAccount.BillingCountryCode != '')
{
String selCountryCode = dummyAccount.BillingCountryCode;
regionCode = Utility.fetchRegionCodeFromCountry(selCountryCode);
currencyCode = Utility.fetchCurrencyCodeFromCountry(selCountryCode);
productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,null);
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
        asset.Product2Id = null;
        products = Utility.fetchProducts(regionCode, selectedSubCategory, brand,plmStatusNotStartsWith, productCodeOrCategoryFilter, productIdToProductCodeMap, lang);
        checkOffer();
    }
    
    /**
* This method is the save method it validates all the fields. Queries for
* Accounts and creates asset objects.
*/
    public  pagereference registrationSave(){
        
        //Recpatcha check
        String response = ApexPages.currentPage().getParameters().get('response');
        GoogleReCaptchaCtrl googleRecaptcha = new GoogleReCaptchaCtrl();
        /*if (!Test.isRunningTest()) {
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
        /*if (asset.PurchaseDate == Null){
asset.PurchaseDate = system.today();
}*/
        
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
        
        if(!Utility.validatePurchaseDate(asset.PurchaseDate,URL)){
            return null;
        }
        
        
        try{
            if(asset.Batch_Code__c == null || CaseTriggerHandler.isBatchCodeValid(asset.Batch_Code__c, Datetime.now(),asset.PurchaseDate)){
                Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
                if(existingaccount == null)
                    acct.AccountSource = 'Web';
                
                asset.Account_Email__c =acct.personEmail;
                asset.CurrencyIsoCode = currencyCode;
                asset.Name = acct.FirstName + ' ' + acct.LastName + ' - ' + productIdToProductCodeMap.get(asset.Product2Id) ;
                asset.Where_did_you_purchase__c = objCase.Purchased_From__c;
                
                string ax_item_number ='';
                
                if(asset.Product2Id != Null){
                    ax_item_number = [select AX_Item_Number__c FROM Product2 where ID =: asset.Product2Id limit 1].AX_Item_Number__c;
                }
                
                
                if(asset.Batch_Code__c != null && asset.Batch_Code__c != '' && existingaccount != null && Utility.isDuplicateAsset(existingaccount.Id, ax_item_number, asset.Batch_Code__c)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Already_Registered_Product));
                    return null;
                }
                
                Offer__c validOfferRecord;
                if(string.isblank(asset.Offer_Code_Applied__c))  {
                    /* Section to auto generate offer code if the selcted product has applicable for offer */
                    validOfferRecord= OfferRedemptionUtility.getOfferForProduct(ax_item_number,currencyCode, asset);
                    if(validOfferRecord != Null){
                        if(validOfferRecord.RecordType.Name == 'Generate Offer Code'){
                            asset.Offer_Code_Applied__c = OfferRedemptionUtility.GenerateOfferCodeFormat(validOfferRecord) +''+ (validOfferRecord.SequentialCounter__c+1);
                            validOfferRecord.SequentialCounter__c =  validOfferRecord.SequentialCounter__c + 1;  
                            update  validOfferRecord;
                        }
                        asset.ExactOfferCode__c   = validOfferRecord.OfferCode__c; 
                        asset.OfferWelcomeEmailContent__c  = validOfferRecord.Offer_Welcome_Message__c ;
                        Component.Apex.OutputText output;
                        output = new Component.Apex.OutputText();
                        output.expressions.value = '{!$Label.Offer_Welcome_Message_For_' + asset.ExactOfferCode__c +'}';
                        if(asset.ExactOfferCode__c == 'UK_OFFER_01' || asset.ExactOfferCode__c == 'UK_WF_OFFER_02' || asset.ExactOfferCode__c == 'AYL'){
                            List<String> fillers = new List<String>();
                            fillers.add(brand);
                            fillers.add(productIdToProductCodeMap.get(asset.Product2Id));
                            successMessage = string.format(string.valueOf(output.value), fillers); 
                        }else{
                            successMessage = string.valueOf(output.value);
                        }
                    }
                    
                    /* End section to generate offer code */
                }
                else{
                    /* Below section to check if the ented offer code is valid for the selected product*/
                    validOfferRecord= OfferRedemptionUtility.isOfferCodeValid(ax_item_number, currencyCode, asset);
                    
                    if(validOfferRecord != Null)
                    {
                        //check if offer code is already been used
                        list<Asset> assetsWithSameOfferCode = [select id,ExactOfferCode__c,Offer_Code_Applied__c From asset Where accountid=: acct.Id and Offer_Code_Applied__c=: asset.Offer_Code_Applied__c limit 1]; // and Product2id=: asset.product2Id
                        
                        if(assetsWithSameOfferCode !=  Null && assetsWithSameOfferCode.size() > 0){
                            Component.Apex.OutputText output;
                            output = new Component.Apex.OutputText();
                            output.expressions.value = 'The Offer Code has been redeemed !';
                            successMessage = string.valueOf(output.value);
                        }else{
                            asset.ExactOfferCode__c  = validOfferRecord.OfferCode__c ;// Offercode that matched HBE7
                            asset.OfferWelcomeEmailContent__c  = validOfferRecord.Offer_Welcome_Message__c;
                            
                            Component.Apex.OutputText output;
                            output = new Component.Apex.OutputText();
                            output.expressions.value = '{!$Label.Offer_Welcome_Message_For_' + asset.ExactOfferCode__c +'}';
                            
                            if(asset.ExactOfferCode__c == 'UKE1' || asset.ExactOfferCode__c == 'UK_OFFER_01' || asset.ExactOfferCode__c == 'UK_WF_OFFER_02' ||  asset.ExactOfferCode__c == 'AYL'){
                                List<String> fillers = new List<String>();
                                fillers.add(brand);
                                fillers.add(productIdToProductCodeMap.get(asset.Product2Id));
                                successMessage = string.format(string.valueOf(output.value), fillers); 
                            }else{
                                successMessage = string.valueOf(output.value);
                            }
                            
                        }
                    }
                    if(asset.Offer_Code_Applied__c != Null && asset.ExactOfferCode__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.InvalidOfferCode));  
                        return null;
                    }
                    /* End section */
                }
                
                upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2, currencyCode, accountPreferredLanguage);
                asset.AccountId =acct.Id;
                asset.ContactId = [select PersonContactId FROM account where ID =: acct.Id limit 1].PersonContactId;
                insert asset;
                isSuccess = true;
                /*if(validOfferRecord !=null && validOfferRecord.RecordType.Name == 'Generate Offer Code'){
validOfferRecord.SequentialCounter__c =  validOfferRecord.SequentialCounter__c + 1;  
update  validOfferRecord;
}*/
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Batch_Code_Error_Message));
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
        }
        return null;
        
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
        
        if(String.isBlank(selectedProduct)){
            addfield(Label.Asset_Product);
        }
        
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
        
        /*if(String.isBlank(asset.Batch_Code__c)){
          addfield(Label.Product_Batch_Code);
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
        String ax_item_number = '';
        asset.Product2Id = selectedProduct;
        if(asset.Product2Id != Null){
            ax_item_number = [select AX_Item_Number__c FROM Product2 where ID =: asset.Product2Id limit 1].AX_Item_Number__c;
        }
        if(ax_item_number != null && ax_item_number != '' && selectedSubCategory != null && selectedSubCategory != ''){
            Offer__c validOfferRecord = OfferRedemptionUtility.getOfferForProduct(ax_item_number,currencyCode, asset.PurchaseDate);
            if(validOfferRecord != null && validOfferRecord.TnC_Link__c != null && validOfferRecord.TnC_Link__c != ''){
                showTncLink = true;
                TncLink = validOfferRecord.TnC_Link__c;
            }else{
                showTncLink = false;
            }
            if(validOfferRecord != null && validOfferRecord.PageHeader__c != null && validOfferRecord.PageHeader__c != ''){
                showOfferPageHeader = true;
                offerPageHeader = validOfferRecord.PageHeader__c;
            }else{
                showOfferPageHeader = false;
            }
        }else{
            showTncLink = false;
            showOfferPageHeader = false;
        }
    }
}