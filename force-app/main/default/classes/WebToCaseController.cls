public without sharing class WebToCaseController{
  
    public Account acct { get; set; }
    public String selectedSubCategory { get; set; }
    public Case objCase { get; set;}
    public Boolean isSuccess{get;set;}
    public Boolean isAttachmentSuccesfullyUploaded {get;set;}
    public transient  Boolean isAttach{get;set;}
    public String personBillingStreet2 { get; set; }
    public String fieldErrors;
    public String comments{ get; set;}
    public String confirmEmail { get; set; }
    public string code {get; set;}
    public String URL {get; set;}
    public Attachment objAttach {get;set;}
    private Case objCaseToInsert;
    public transient Blob Attachbody{get;set;}
    public transient String Attachname{get;set;}
    public String footerContent{get;set;}
    public List<SelectOption> productSubCategories{get;set;}
    public List<SelectOption> products{get;set;}
    public List<SelectOption> CaseTypes{get;set;}
    public Boolean recaptchaValidation{get;set;}
    String regionCode;
    String currencyCode;
    String successMessage;
    String caseMessageInfo;
    public Account dummyAccount { get; set; }
    public String brand{get;set;}
    final private String defaultBrand = 'Breville';
    final private String plmStatusNotStartsWith = '01%';
    public string pageURL{get;set;}
    public string siteURL{get;set;}
    
    public boolean showCountryError {get; set;}
    public String countryError {get;set;}
    public String accountPreferredLanguage;

    public WebToCaseController(){
    System.debug('webtocasecontroller is invoked');
        
        showCountryError = false;
        countryError = '';
         
        pageURL = ApexPages.currentPage().getUrl();
        if(pageURL == null)
            pageURL = '';
      
        siteURL = Site.getCurrentSiteUrl();
        if(siteURL == null)
            siteURL = '';
      
        /*changes to take brand in URL parameter*/
        brand = ApexPages.currentPage().getParameters().get('brand');
        if(brand == null || brand =='')
            brand = defaultBrand;
          
        URL = ApexPages.currentPage().getParameters().get('param');
        regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
        currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
        
        String lang = ApexPages.currentPage().getParameters().get('language');
        
        objCase = new Case();
        objCase.Country__c = regionCode;
        
        //To fetch Language code based on the param passed.
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From Region_Specific__mdt Where EPParameter__c=:URL];
        
        if(lang != null && lang != ''){
            if(lang.equalsIgnoreCase('fr')){
                code = lang;
                accountPreferredLanguage = 'French';
            }else if(lang.equalsIgnoreCase('de')){
                code = lang;
                accountPreferredLanguage = 'German';
            }else{
                code = regionSpecific.LanguageCode__c;
                accountPreferredLanguage = 'English';
            }
        }else{
            code = Label.Default_LanguageCode;
            accountPreferredLanguage = 'English';
        }
              
        //To have dynamic Labels  
        footerContent = 'ContactUSWebToCase_' + Utility.fetchRegionCodeFromEPRegion(URL);
        
        if(brand == 'Polyscience'){
            footerContent = footerContent +'_' +brand;
        }

        Component.Apex.OutputText output;
            output = new Component.Apex.OutputText();
            //output.expressions.value = '{!$Label.' + 'SuccessMessage_' + regionCode + '}';
            output.expressions.value = '{!$Label.SuccessMessage}' +' '+'{!$Label.brand_'+brand.replaceAll(' ','_')+'}'+' '+'{!$Label.region_'+regionCode+'}'+'. '+ '{!$Label.in_touch_message}';
            if(Test.isRunningTest())
                successMessage = '';
            else
                successMessage = string.valueOf(output.value);
                
        // productSubCategories = Utility.fetchProductSubcategories(regionCode, null, new List<String>{'C', 'D', 'E', 'F', 'R', 'S'});
        productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,null);
        System.debug('productSubCategories' + productSubCategories);
        fetchProducts();
        CaseTypes = Utility.fetchCaseTypes('Case Type To Ignore');
      
      
        acct = new Account();
        isSuccess = false; 
        isAttachmentSuccesfullyUploaded = false;
        fieldErrors = '';
        
        objAttach = new Attachment();
        isAttach = true;
        
        dummyAccount = new Account();
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
            //output.expressions.value = '{!$Label.' + 'SuccessMessage_' + regionCode + '}';
            output.expressions.value = '{!$Label.SuccessMessage}' +' '+'{!$Label.brand_'+brand.replaceAll(' ','_')+'}'+' '+'{!$Label.region_'+regionCode+'}'+'. '+ '{!$Label.in_touch_message}';
            if(Test.isRunningTest())
                successMessage = '';
            else
                successMessage = string.valueOf(output.value);
        }
   }*/
   
    /* Picklist of products related to product SubCategory from Product */
    public void fetchProducts(){
      //products = Utility.fetchProducts(regionCode, selectedSubCategory, null, new List<String>{'C', 'D', 'E', 'F', 'R', 'S'});
      products = Utility.fetchProducts(regionCode, selectedSubCategory, brand,plmStatusNotStartsWith, null, null);
    }
    
     /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates Case objects.
     */
    public pageReference registrationSave(){
        if(!Utility.countryValidation(dummyAccount.BillingCountryCode, URL)){
            Component.Apex.OutputText countryError;
            countryError = new Component.Apex.OutputText();
            countryError.expressions.value = '{!$Label.InvalidCountry_' + URL + '}';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(countryError.value)));
            dummyAccount.BillingStateCode = null;
            return null;
        }
        savecase(false);
        return null;
    }
    
    public pageReference registrationSaveAndAddAttachment(){
        if(!Utility.countryValidation(dummyAccount.BillingCountryCode, URL)){
            Component.Apex.OutputText countryError;
            countryError = new Component.Apex.OutputText();
            countryError.expressions.value = '{!$Label.InvalidCountry_' + URL + '}';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(countryError.value)));
            dummyAccount.BillingStateCode = null;
            isAttach = true;
            return null;
        }
        savecase(true);
        return null;
    }
    
    public pageReference savecase(boolean haveAttachment){
      //Recpatcha check
      String response = ApexPages.currentPage().getParameters().get('response');
        GoogleReCaptchaCtrl googleRecaptcha = new GoogleReCaptchaCtrl();
        if (!Test.isRunningTest()) {
          recaptchaValidation = googleRecaptcha.validateRecaptchaResponse(response);
          if(!recaptchaValidation){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Invalid_Captcha_Response));
              return null;
          }
        }
      objCase.Product_Sub_Category__c = selectedSubCategory;
        fieldErrors ='';
        copyValues();
        checkFields();
        setRequiredFields();
        
        if(fieldErrors != ''){
            isAttach = true;
            createErrorMessage(Label.Following_Fields_are_Required + ' ' + fieldErrors + Label.Please_make_the_necessary_corrections);
            return null;
        }
        
        if(!Utility.validateEmail(acct.PersonEmail, confirmEmail)){
          isAttach = true;
            return null;
        }
        if(!Utility.validatePostalCode(acct.BillingPostalCode, regionCode)){
          isAttach = true;
            return null;
        }
        if(!Utility.validateBillingStreet(acct.BillingStreet)){
          isAttach = true;
            return null;
        }
        
        if(!Utility.validatePurchaseDate(objCase.Purchase_Date__c, URL)){
            return null;
        } 
        
    try{
        if(objCase.Batch_Code__c == null || CaseTriggerHandler.isBatchCodeValid(objCase.Batch_Code__c, Datetime.now(), objCase.Purchase_Date__c)){
            Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
            if(existingaccount == null)
            {
              acct.AccountSource = 'Web';
            }
            upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2, currencyCode, accountPreferredLanguage);
              Account acc = [select PersonContactId from Account where id =:acct.Id];
              
              objCase.RecordTypeId = Utility.fetchRecordTypeId('Case', 'New_Case');
              objCase.Origin = 'Web Inquiry';
              objCase.AccountId = acct.Id;
              objCase.ContactId = acc.PersonContactId;
              //objCase.Complaint_Code__c = 'Questions & Feedback';
              objCase.Description =  comments;
              objCase.CurrencyIsoCode = currencyCode;
              objCase.Country__c = regionCode;
              /*to store the URL from where the case was created*/
              objCase.web_to_case_url__c = siteURL+pageURL.replace('/apex/','');
              
              objCase.brand__c = brand;
              /*to set OnwerId as System*/
              list<All_Literal__mdt> literalRec = [select Value__c from ALL_Literal__mdt where DeveloperName = 'CustomUserId'];
              if(literalRec != null && literalRec.size() > 0)
                objCase.ownerId = literalRec[0].Value__c;
              
              if(comments != Null){
               objCase.Subject =  comments.left(30);
              }
              //Utility.validateLookupFilter(objCase.Product__c);
              Database.DMLOptions dmlOpts = new Database.DMLOptions();
              dmlOpts.assignmentRuleHeader.useDefaultRule= true;
              objCase.setOptions(dmlOpts);
              insert objCase;
              /*Appending case number to success Message  - start*/
              string caseNumber = [select casenumber from case where id =:objCase.id limit 1][0].caseNumber;
              if(caseNumber != null && caseNumber != '')
                caseMessageInfo= Label.case_number_info + ' '+caseNumber+'. ' +Label.case_number_future_reference;
              /*Appending case number to success Message  - end*/
              isSuccess = true;
              if(haveAttachment){
                isAttach = false;
              }
          }else{
        isAttach = true;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Batch_Code_Error_Message));
          }
        }catch (Exception e){
            if(!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
                showCountryError = false;
        }
        
    if(isSuccess){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
          if(caseMessageInfo != null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, caseMessageInfo));
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
    private void addField(String label){
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
    
        if(acct !=null && dummyAccount !=null)
        {
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
          if(dummyAccount.Subscribe_to_our_newsletter__c){
          acct.Subscribe_to_our_newsletter__c = dummyAccount.Subscribe_to_our_newsletter__c;
          }
        }
    
    }

    /**
     * Verifies all required fields have been populated on vf page.
     */
    public void checkFields(){
        if(String.isBlank(acct.FirstName)){
            addfield(Label.First_Name);
        }

        if(String.isBlank(acct.LastName)){
            addfield(Label.Last_Name);
        }
        
        if(String.isBlank(acct.PersonEmail)){
            addfield(Label.Email);
        }

        if(String.isBlank(confirmEmail)){
            addfield(Label.confirmEmail);
        }
        
        if(String.isBlank(acct.BillingCountryCode)){ 
            addfield(Label.Country);
        }
        
        if(String.isBlank(objCase.Type)){
            addfield(Label.Inquiry_Type);
        }
        
        if(String.isBlank(comments)){
            addfield(Label.Comments_Label);
        }
        
        if(String.isBlank(acct.BillingStateCode)){
        	All_Literal__mdt countriesWithNoState = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName= 'StateCodeOptionalCountries'];
            //if(acct.BillingCountryCode != 'GB' && acct.BillingCountryCode != 'DE' && acct.BillingCountryCode != 'CZ' && acct.BillingCountryCode != 'AT')
            if(!(countriesWithNoState.Value__c.containsIgnoreCase(';'+ acct.BillingCountryCode +';')))    
                addfield(Label.State);
        }
       
        if(String.isBlank(acct.BillingStreet)){ 
            addfield(Label.Street);
        }
        
        if(String.isBlank(acct.BillingCity)){ 
            addfield(Label.City_Label);
        }
        
        if(String.isBlank(acct.BillingPostalCode)){ 
            addfield(Label.Postal_Code);
        }
    }
   
    /**
    * Verifies required field depending upon the Inquiry Type
    **/
    public void setRequiredFields(){
        if(objCase.Type == 'Support & Service' ){
             if(String.isBlank(objCase.Product_Sub_Category__c)){
                addField(Label.Breville_product);
             }
             if(String.isBlank(objCase.Purchased_From__c)){
                addField(Label.Where_did_you_purchase_from);
             }
             if(objCase.Purchase_Date__c == null){
                addField(Label.Date_of_Purchase);
             }
         }
         
         if(objCase.Type == 'Distribution Inquiry'){
            if(String.isBlank(acct.Phone)){
                addField(Label.Phone);
             }
            /* if(String.isBlank(acct.BillingStreet)){
                addField(Label.Street);
             }
             if(String.isBlank(acct.BillingCity)){
                addField(Label.City_Label);
             }
             if(String.isBlank(acct.BillingStateCode)){
                addField(Label.State);
             }
             if(String.isBlank(acct.BillingPostalCode)){
                addField(Label.Postal_Code);
             }*/
         }
         
         if(objCase.Type == 'Order Issue'){
             if(String.isBlank(objCase.Original_PO_CASE_del__c)){
                addField(Label.Order_Number);
             }
             if(String.isBlank(objCase.Product_Sub_Category__c)){
                addField(Label.Breville_product);
             }
         }
    }
    public void Upload(){
    
        try{
            if(Attachbody != null && Attachname != null){
              if (!Test.isRunningTest()) {
                objAttach = new Attachment();
                objAttach.Body = Attachbody;
                objAttach.Name = Attachname;
                objAttach.ParentId = objCase.id;
                insert objAttach;
              }
                objAttach = null;  
                isAttachmentSuccesfullyUploaded = true;
            isAttach = true;
            if(isAttachmentSuccesfullyUploaded){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,  successMessage));
            }         
            }else{
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Attachment is Missing'));
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
       
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
    
    
          
}