public without sharing class WebToCaseBeanzController
{


    public Account acct { get; set; }
    public String selectedVendor { get; set; }
    public Case objCase { get; set;}
    public Boolean isSuccess{get;set;}
    public Boolean isAttachmentSuccesfullyUploaded {get;set;}
    public transient  Boolean isAttach{get;set;}
    public String personBillingStreet2 { get; set; }
    public String fieldErrors;
    public String comments{ get; set;}
    public String confirmEmail { get; set; }
    public string languageCode { get; set; }
    public String URL {get; set;}
    public Attachment objAttach {get;set;}
    private Case objCaseToInsert;
    public transient Blob Attachbody{get;set;}
    public transient String Attachname{get;set;}
    public String footerContent{get;set;}
    public List<SelectOption> vendors{get;set;}
    public List<SelectOption> roasters{get;set;}
    public Boolean recaptchaValidation{get;set;}
    String regionCode;
    String currencyCode;
    String successMessage;
    String caseMessageInfo;
    public Account dummyAccount { get; set; }
    public String brand{get;set;}
    final private String defaultBrand = 'beanz';
    final private String plmStatusNotStartsWith = '01%';
    public string pageURL{get;set;}
    public string siteURL{get;set;}
    public String lang;
    public boolean showCountryError {get; set;}
    public String countryError {get;set;}
    public String accountPreferredLanguage;
    
    public String googleSiteKey           {get;set;}
    private String googleSecretKey           {get;set;}
    private String googleRecaptchaVerifyEndpoint   {get;set;}
    private Decimal googleRecaptchaMinScore   {get;set;}
    
    public String selectedRoaster {get; set;}
    public WebToCaseBeanzController()
    {

        showCountryError = false;
        countryError = '';

        pageURL = ApexPages.currentPage().getUrl();
        if (pageURL == null)
            pageURL = '';

        siteURL = Site.getBaseUrl();
        if (siteURL == null)
            siteURL = '';

        /*changes to take brand in URL parameter*/
        brand = ApexPages.currentPage().getParameters().get('brand');
        if (String.isNotBlank(brand))
            brand = defaultBrand;

        String countryCode = ApexPages.currentPage().getParameters().get('param');
        URL = countryCode;
        regionCode = Utility.fetchRegionCodeFromEPRegion(countryCode);
        currencyCode = Utility.fetchCurrencyCodeFromEPRegion(countryCode);

        lang = ApexPages.currentPage().getParameters().get('language');

        objCase = new Case();
        objCase.Country__c = regionCode;

        //To fetch Language code based on the param passed.
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From
            Region_Specific__mdt Where EPParameter__c =: countryCode
        ];

        if (String.isNotBlank(lang))
        {
            languageCode = lang;
            /*    if(lang.equalsIgnoreCase('fr')){
                    if(URL == 'CA'){
                        code= 'fr_CA';
                    }
                }     */
        }
        else
        {
            languageCode = regionSpecific.LanguageCode__c;
        }
        accountPreferredLanguage = Utility.getLanguageFromLanguageCode(languageCode);

        //To have dynamic Labels  
        footerContent = 'ContactUSWebToCase_' + Utility.fetchRegionCodeFromEPRegion(countryCode);
        vendors = fetchVendors(regionCode, brand, plmStatusNotStartsWith, null, lang);
        fetchRoasters();
        //CaseTypes = Utility.fetchCaseTypes('Case Type To Ignore');

        acct = new Account();
        isSuccess = false;
        isAttachmentSuccesfullyUploaded = false;
        fieldErrors = '';

        objAttach = new Attachment();
        isAttach = true;

        dummyAccount = new Account();
        dummyAccount.BillingCountryCode = countryCode;

        //read site key, secret and endpoint from Custom metadata
        for (All_Literal__mdt appliteral: [Select Id,DeveloperName,Value__c from All_Literal__mdt 
                        where DeveloperName IN ('GoogleReCaptchaEndPointBeanz', 'GoogleSecretkeyBeanz','GoogleSitekeyBeanz','Google_Recaptcha_Min_Score_Beanz')
            ])
        {
            if (appliteral.DeveloperName == 'GoogleSitekeyBeanz')
            {
                googleSiteKey = appliteral.Value__c;
            }
            else if (appliteral.DeveloperName == 'GoogleSecretkeyBeanz')
            {
                googleSecretKey = appliteral.Value__c;
            }
            else if (appliteral.DeveloperName == 'GoogleReCaptchaEndPointBeanz')
            {
                googleRecaptchaVerifyEndpoint = appliteral.Value__c;
            }
            else if (appliteral.DeveloperName == 'Google_Recaptcha_Min_Score_Beanz')
            {
                googleRecaptchaMinScore = Decimal.valueOf(appliteral.Value__c);
            }
        }
    }

    public void viewSuccessMessage()
    {
        Component.Apex.OutputText output;
        output = new Component.Apex.OutputText();
        //output.expressions.value = '{!$Label.' + 'SuccessMessage_' + regionCode + '}';
        output.expressions.value = '{!$Label.SuccessMessage}' + ' ' + '{!$Label.brand_' + brand.replaceAll(' ', '_') + '}' + ' ' + '{!$Label.region_' + regionCode + '}' + '. ' + '{!$Label.in_touch_message}';
        if (Test.isRunningTest())
            successMessage = '';
        else
            successMessage = string.valueOf(output.value);
    }

    public static List < SelectOption > fetchVendors(String regionCode, String brand, String plmStatusNotStartsWith, String additionalCondition, String language)
    {
        List < SelectOption > vendorList = new List < SelectOption > ();
        Set < SelectOption > vendorSet = new Set < SelectOption > ();

        String query = 'SELECT Vendor_Name__c, Name ' +
            ' FROM Product2 ' +
            ' WHERE Finished_Good__c = false ' +
            ' AND (NOT AX_Items_PLM_Status__c like :plmStatusNotStartsWith) ' +
            ' AND Country_Code__c = :regionCode ' +
            ' AND IsActive = true ' +
            ' AND Spare_Part__c = false ' +
            //            ' AND Product_Sub_Family__c != \'Service\' ' + 
            ' AND Exclude_from_Sync__c = false ';
        if (String.isNotBlank(brand))
        {
            query += ' AND brand__c =:brand ';
        }

        if (String.isNotBlank(additionalCondition))
        {
            query += ' AND ' + additionalCondition;
        }
        query += ' GROUP BY Vendor_Name__c, Name ORDER BY Vendor_Name__c, Name';

        List < AggregateResult > subCategoryList = Database.query(query);
        for (AggregateResult ar: subCategoryList)
        {
            System.debug(LoggingLevel.DEBUG, ar);
            if (ar != Null && ar.get('Vendor_Name__c') != Null)
            {
                SelectOption so = null;
                so = new SelectOption((string) ar.get('Vendor_Name__c'), (string) ar.get('Vendor_Name__c'));
                vendorSet.add(so);
            }
        }
        vendorList.addAll(vendorSet);
        System.debug('Vendor Set size: ' + vendorSet.size());
        System.debug('Vendor List size: ' + vendorList.size());
        List < SelectOption > sortedVendorList = new List < SelectOption > ();
        sortedVendorList.add(new SelectOption('', System.Label.Default_Picklist_Value));
        sortedVendorList.addAll(vendorList);

        return sortedVendorList;
    }

    /* Picklist of products related to product SubCategory from Product */
    public void fetchRoasters()
    {
        List < SelectOption > roasterList = new List < SelectOption > ();
        roasterList.add(new SelectOption('', Label.Default_Picklist_Value));

        String query = 'SELECT Id, Name, Description, US_SKU__c, Description_LP__c, Description_LP2__c, DescriptionEN__c, ' +
            ' DescriptionFR__c, DescriptionDE__c, DescriptionIT__c, DescriptionES__c, DescriptionNL__c, Remanufactured__c' +
            ' FROM Product2 ' +
            ' WHERE brand__c = :brand ' +
            ' AND Vendor_Name__c = :selectedVendor ' +
            ' AND Finished_Good__c = false ' +
            ' AND (NOT AX_Items_PLM_Status__c like :plmStatusNotStartsWith) ' +
            ' AND Country_Code__c =: regionCode  ' +
            ' AND IsActive = true  ' +
            ' AND Spare_Part__c = false ' +
            ' AND Exclude_from_Sync__c = false ';

        query += ' ORDER BY Name ASC';

        if (String.isNotBlank(selectedVendor))
        {
            System.debug('query ::::: ' + query);
            for (Product2 product: Database.query(query))
            {
                roasterList.add(new SelectOption(product.Id, product.Description));
                /*
                String language = languageCode.toLowerCase().left(2);
                if(regionCode == 'CAN' && language == 'fr') {
                    if(String.isNotBlank (product.Description_LP2__c)){
                        roasterList.add(new SelectOption(product.Id, product.Description + ' - ' + product.Description_LP2__c));
                    }else{
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                    }
                }
                else if(language == 'en'){
                    if(String.isNotBlank (product.DescriptionEN__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.DescriptionEN__c));
                    }else{
                        if(String.isNotBlank (product.Description_LP__c)){
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language == 'fr'){
                    if(String.isNotBlank (product.DescriptionFR__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.DescriptionFR__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language == 'de'){
                    if(String.isNotBlank (product.DescriptionDE__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.DescriptionDE__c));
                    }else{
                        if(String.isNotBlank (product.Description_LP__c)){
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language == 'it'){
                    if(String.isNotBlank (product.DescriptionIT__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.DescriptionIT__c));
                    }else{
                        if(String.isNotBlank (product.Description_LP__c)){
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language == 'es'){
                    if(String.isNotBlank (product.DescriptionES__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.DescriptionES__c));
                    }else{
                        if(String.isNotBlank (product.Description_LP__c)){
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language == 'nl'){
                    if(String.isNotBlank (product.DescriptionNL__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.DescriptionNL__c));
                    }else{
                        if(String.isNotBlank (product.Description_LP__c)){
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                        }
                    }            
                }else{
                    if(String.isNotBlank (product.Description_LP__c)){
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description_LP__c));
                    }else{
                        roasterList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                    }
                }

                if(productIdToProductCodeMap !=null) {
                    productIdToProductCodeMap.put(product.Id, product.Name);
                }
                */
            }
        }
        Roasters = roasterList;
    }

    /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates Case objects.
     */
    public pageReference registrationSave()
    {
        if (!Utility.countryValidation(dummyAccount.BillingCountryCode, URL))
        {
            Component.Apex.OutputText cError = getInvalidCountryError();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(cError.value)));
            return null;
        }
        savecase(false);
        return null;
    }

    private Component.Apex.OutputText getInvalidCountryError()
    {
        dummyAccount.BillingStateCode = null;
        Component.Apex.OutputText cError;
        cError = new Component.Apex.OutputText();
        cError.expressions.value = '{!$Label.InvalidCountry_' + URL + '}';
        return cError;
    }

    public pageReference registrationSaveAndAddAttachment()
    {
        if (!Utility.countryValidation(dummyAccount.BillingCountryCode, URL))
        {
            Component.Apex.OutputText cError = getInvalidCountryError();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(cError.value)));
            isAttach = true;
            return null;
        }
        savecase(true);
        return null;
    }

    public PageReference savecase(boolean haveAttachment)
    {
        //Recpatcha check
        String response = ApexPages.currentPage().getParameters().get('response');
        if (!Test.isRunningTest())
        {
            recaptchaValidation = validateRecaptchaResponse(response);
            if (!recaptchaValidation)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Invalid_Captcha_Response));
                return null;
            }
        }
        //        objCase.Product_Sub_Category__c = selectedSubCategory;
        fieldErrors = '';
        copyValues();
        checkFields();
        //        setRequiredFields();

        if (fieldErrors != '')
        {
            isAttach = true;
            createErrorMessage(Label.Following_Fields_are_Required + ' ' + fieldErrors + Label.Please_make_the_necessary_corrections);
            return null;
        }

        if (!Utility.validateEmail(acct.PersonEmail, confirmEmail))
        {
            isAttach = true;
            //createErrorMessage('Email ');
            return null;
        }

        if (!Utility.validatePurchaseDate(objCase.Purchase_Date__c, URL))
        {
            return null;
        }

        try
        {
            Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
            if (existingaccount == null)
            {
                acct.AccountSource = 'Web';
            }
            upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2, currencyCode, accountPreferredLanguage);
            Account acc = [select PersonContactId from Account where id =: acct.Id];

            objCase.RecordTypeId = Utility.fetchRecordTypeId('Case', 'New_Case');
            objCase.Origin = 'Web Inquiry';
            objCase.AccountId = acct.Id;
            objCase.ContactId = acc.PersonContactId;
            objCase.Description = comments;
            objCase.CurrencyIsoCode = currencyCode;
            objCase.Country__c = regionCode;
            objCase.web_to_case_url__c = siteURL + pageURL.replace('/apex/', '');

            objCase.brand__c = brand;
            if (brand.equalsIgnoreCase('beanz'))
                objCase.Purchased_From__c = brand;
            /*to set OnwerId as System*/
            list < All_Literal__mdt > literalRec = [select Value__c from ALL_Literal__mdt where DeveloperName = 'CustomUserId'];
            if (literalRec != null && literalRec.size() > 0)
                objCase.ownerId = literalRec[0].Value__c;

            if (String.isNotEmpty(comments))
            {
                if (comments.length() > 255)
                    objCase.Subject = comments.left(255);
                else
                    objCase.Subject = comments;
            }
            //Utility.validateLookupFilter(objCase.Product__c);
            objCase.Product__c = selectedRoaster;
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            objCase.setOptions(dmlOpts);
            insert objCase;
            System.debug(LoggingLevel.DEBUG, 'Case Object: ' + objCase.Id);
            /*Appending case number to success Message  - start*/
            String caseNumber = [select casenumber from
                case where id =: objCase.id limit 1
            ][0].caseNumber;
            if (String.isNotBlank(caseNumber))
                caseMessageInfo = Label.case_number_info + ' ' + caseNumber + '. ' + Label.case_number_future_reference;
            /*Appending case number to success Message  - end*/
            isSuccess = true;
            if (haveAttachment)
            {
                isAttach = false;
            }
        }
        catch (Exception e)
        {
            if (!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            showCountryError = false;
        }

        if (isSuccess)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
            if (caseMessageInfo != null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, caseMessageInfo));
        }
        return null;
    }

    /**
     * Creates an error messge based on the data sent in.
     */
    private void createErrorMessage(String err)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err));
    }

    /**
     * Adds fields to the fielderror string passed in from the checkfields
     * method.
     */
    private void addField(String label)
    {
        if (fieldErrors == '')
        {
            fielderrors = fielderrors + label;
        }
        if (!fieldErrors.contains(label))
        {
            fieldErrors = fielderrors + ', ' + label;
        }
    }

    /**
     * Copies values from the VF page dummyAccount to acct
     */
    public void copyValues()
    {

        if (acct != null && dummyAccount != null)
        {
            acct.FirstName = dummyAccount.FirstName;
            acct.LastName = dummyAccount.LastName;
            acct.personEmail = dummyAccount.personEmail;
            acct.Phone = dummyAccount.Phone;
            /*            acct.BillingCountryCode = dummyAccount.BillingCountryCode;
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
            */
            acct.Agreed_for_Opt_in__c = dummyAccount.Agreed_for_Opt_in__c;
        }

    }

    /**
     * Verifies all required fields have been populated on vf page.
     */
    public void checkFields()
    {
        if (String.isBlank(acct.FirstName))
        {
            addfield(Label.First_Name);
        }

        if (String.isBlank(acct.LastName))
        {
            addfield(Label.Last_Name);
        }

        if (String.isBlank(acct.PersonEmail))
        {
            addfield(Label.Email);
        }

        if (String.isBlank(confirmEmail))
        {
            addfield(Label.confirmEmail);
        }
        if (String.isBlank(comments))
        {
            addfield(Label.Comments_Label);
        }
    }

    public void Upload()
    {

        try
        {
            if (Attachbody != null && Attachname != null)
            {
                objAttach = new Attachment();
                objAttach.Body = Attachbody;
                objAttach.Name = Attachname;
                objAttach.ParentId = objCase.id;

                if (!Test.isRunningTest())
                {
                    insert objAttach;
                }
                objAttach = null;
                isAttachmentSuccesfullyUploaded = true;
                isAttach = true;
                if (isAttachmentSuccesfullyUploaded)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Attachment_is_Missing));
            }
        }
        catch (Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }


    }

    public void validateCountry()
    {
        if (Utility.countryValidation(dummyAccount.BillingCountryCode, URL))
        {
            dummyAccount.BillingStateCode = null;
            showCountryError = false;
            countryError = '';
        }
        else
        {
            showCountryError = true;
            Component.Apex.OutputText cError = getInvalidCountryError();
            countryError = String.valueOf(cError.value);
        }
    }
    public Boolean validateRecaptchaResponse(String response)
    {
        Boolean success = false;
        HttpRequest req = new HttpRequest();
        //Set HTTPRequest Method
        req.setMethod('POST');
        String endpoint = googleRecaptchaVerifyEndpoint + '?secret=' +
            googleSecretKey +
            '&response=' + response;
        req.setEndpoint(endpoint);

        //req.se
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
        //Set the HTTPRequest body  
        //req.setBody(body);   
        Http http = new Http();
        //Execute web service call here    
        HTTPResponse res = http.send(req);
        Map < String, Object > responseParsedObject = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('responseParsedObject:' + responseParsedObject );
        system.debug('googleRecaptchaMinScore:'+googleRecaptchaMinScore);
        Decimal score = (Decimal) responseParsedObject.get('score');
        if(score != null && score > googleRecaptchaMinScore){
            success = (Boolean) responseParsedObject.get('success');
        }        
        return success;

    }
}