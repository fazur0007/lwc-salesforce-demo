public without sharing class WebToCaseForPolyScience {
    public Account acct { get; set; }
    public String selectedSubCategory { get; set; }
    public Warranty__c warranty { get; set; }
    public Case objCase { get; set;}
    public Boolean isSuccess { get; set; }
    public String personBillingStreet2 { get; set; }
    private String fieldErrors;
    public String comments{ get; set;}
    public String confirmEmail { get; set; }
    public string code {get; set;}
    public String URL {get; set;}
    private static Map<String,String> mapCountryState = new Map<String,String>();
    public list<Selectoption> stateOptions {get; set;}
    public List<SelectOption> productSubCategories{get;set;}
    public List<SelectOption> products{get;set;}
    public List<SelectOption> CaseTypes{get;set;}
    public List<SelectOption> PurchasedFrom{get;set;}
    public String footerContent{get;set;}
    public Boolean recaptchaValidation{get;set;}
    String additionalCondition;
    private static Map<String, CountryStateSetting__c> countries = CountryStateSetting__c.getAll();
    private static Map<String, ProductSubCategory__c> productsubCateg = ProductSubCategory__c.getAll();
    String regionCode;
    String currencyCode;
    String successMessage;
    final private String brand = 'PolyScience';
    final private String plmStatusNotStartsWith = '01%';
    public Account dummyAccount { get; set; }

    public WebToCaseForPolyScience()
    { 
    	dummyAccount = new Account();
    	URL = ApexPages.currentPage().getParameters().get('param');
    	regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
    	currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
    	String lang = ApexPages.currentPage().getParameters().get('language');
    	
    	objCase = new Case();
    	objCase.Country__c = regionCode;
    	
    	if(lang != null && lang != ''){
    		code = lang;
    	}else{
    		code = Label.Default_LanguageCode;
    	}
        //To have dynamic Labels  
        footerContent = 'ContactUSWebToCase_' + Utility.fetchRegionCodeFromEPRegion(URL);
        
		Component.Apex.OutputText output;
		output = new Component.Apex.OutputText();
		output.expressions.value = '{!$Label.' + 'SuccessMessage_' + regionCode + '}';
		successMessage = string.valueOf(output.value);
        //productSubCategories = Utility.fetchProductSubcategories(regionCode, additionalCondition = 'PolySci_Product__c = true' , new List<String>{'C', 'D', 'F', 'R', 'S'});
        productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,null);
        fetchProducts();
    	CaseTypes = Utility.fetchCaseTypes('Case Type to Ignore Polyscience');
    	PurchasedFrom = Utility.fetchPurchasedFrom('Purchase From To Include');
    	 acct = new Account();
        isSuccess = false; 
        objCase = new Case();
        fieldErrors = '';
       
    } 
    /* Picklist of products related to product SubCategory from Product */
    
    public void fetchProducts(){
    	//products = Utility.fetchProducts(regionCode, selectedSubCategory, additionalCondition = 'PolySci_Product__c = true' , new List<String>{'C', 'D', 'F', 'R', 'S'});
    	products = Utility.fetchProducts(regionCode, selectedSubCategory, brand,plmStatusNotStartsWith, null, null);
    }
    
   /* public List<SelectOption> whereDidYouPurchaseFrom
	{
		get
			{
			List<SelectOption> options = new List<SelectOption>();
			 options.add(new SelectOption('', '-- None --'));
			Schema.DescribeFieldResult fieldResult = Case.Purchased_From__c.getDescribe();
			List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();		
			return options;  
			}
	}*/
     /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates Case objects.
     */
    public pageReference registrationSave() 
    {
    	//Recpatcha check
    	/*String response = ApexPages.currentPage().getParameters().get('response');
        GoogleReCaptchaCtrl googleRecaptcha = new GoogleReCaptchaCtrl();
        recaptchaValidation = googleRecaptcha.validateRecaptchaResponse(response);
        if(!recaptchaValidation){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid captcha response, please try again'));
            return null;
        }*/
    	objCase.Product_Sub_Category__c = selectedSubCategory;
        fieldErrors ='';
        copyValues();
        checkFields();
        setRequiredFields();
        
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
        if(!Utility.validatePurchaseDate(objCase.Purchase_Date__c)){
            return null;
        } 
        
		try{
		//	if(objCase.Batch_Code__c == null || CaseTriggerHandler.isBatchCodeValid(objCase.Batch_Code__c, Datetime.now(), objCase.Purchase_Date__c)){
				Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
				if(existingaccount == null)
				{
					acct.AccountSource = 'Web';
				}
          		upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2, currencyCode);
          		Account acc = [select PersonContactId from Account where id =:acct.Id];
	            objCase.RecordTypeId = Utility.fetchRecordTypeId('Case', 'New_Case');
	            objCase.CurrencyIsoCode = currencyCode;
	            objCase.Origin = 'Web Inquiry';
	            objCase.AccountId = acct.Id;
	            objCase.ContactId = acc.PersonContactId;
	            objCase.Complaint_Code__c = 'Questions & Feedback';
	            objCase.Description =  comments;
	            if(comments != Null){
	         		objCase.Subject =  comments.left(30);
	            }
	            //Utility.validateLookupFilter(objCase.Product__c);
	            Database.DMLOptions dmlOpts = new Database.DMLOptions();
			 	dmlOpts.assignmentRuleHeader.useDefaultRule= true;
			 	objCase.setOptions(dmlOpts);
	            insert objCase;
	            isSuccess = true;
	      
     //   }
     //   else{
	 //           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Batch_Code_Error_Message));
	//        }
        	
        }catch (Exception e){
            if(!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        
		if(isSuccess){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
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
     * Queries for accounts based on email inputted in vf page.
     */
   private Account[] queryOnEmail()
    {
        return [SELECT Id
                FROM Account
                WHERE PersonEmail = :acct.PersonEmail];
    }
     
     /**
     * Adds fields to the fielderror string passed in from the checkfields
     * method.
     */
    private void addField(String label)
    {
        if(fieldErrors == '')
        {
            fielderrors = fielderrors + label;
        }
        if(!fieldErrors.contains(label))
        {
            fieldErrors = fielderrors + ', ' + label;
        }
    }    
    /**
     * Verifies all required fields have been populated on vf page.
     */
    public void checkFields()
    {
        
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
            addfield(Label.CommentsPs);
        }   
    }
   
    /**
    * Verifies required field depending upon the Inquiry Type
    **/
    public void setRequiredFields()
    {
        
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
             if(String.isBlank(acct.BillingStreet)){
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
             }
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
        	acct.personBirthDate = dummyAccount.personBirthDate;
        	acct.Gender__c = dummyAccount.Gender__c;
        	acct.Subscribe_to_our_newsletter__c = dummyAccount.Subscribe_to_our_newsletter__c;
        }
    
    }

}