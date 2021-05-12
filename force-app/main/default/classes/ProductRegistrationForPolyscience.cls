/**
 * This is the controller class for the ProductRegistrationForPolyscience and ProductRegistrationForPolyscienceFrame visual force page.
 * This class takes the data from the visual force page and inserts if necessary
 * an account, and a Asset object from the data supplied on the page.
 *
 * @author james@highondemand.com
 * @version 1.0
 * @since January 14, 2013
 */
public without sharing class ProductRegistrationForPolyscience {

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
    final private String brand = 'Polyscience';
    final private String plmStatusNotStartsWith = '01%';
    
    public Account dummyAccount { get; set; }   
    
    public ProductRegistrationForPolyscience() {
    	
    	URL = ApexPages.currentPage().getParameters().get('param');
    	regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
    	currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
        lang = ApexPages.currentPage().getParameters().get('language');
        productIdToProductCodeMap = new Map<Id, String>();
    	
    	if(lang != null && lang != ''){
    		code = lang;
    	}else{
    		code = Label.Default_LanguageCode;
    	}
    	
    	objCase = new Case();
    	objCase.Country__c = regionCode;
    	
        //To have dynamic Labels  
        titleMessage = 'titleMessageProductRegistration_' + regionCode;
        
        //To display success message
        Component.Apex.OutputText output;
		output = new Component.Apex.OutputText();
		output.expressions.value = '{!$Label.' + 'WarrantySuccessMessage_' + regionCode + '}';
		successMessage = string.valueOf(output.value);
        
        //To fetch product subcategories
        //productSubCategories = Utility.fetchProductSubcategories(regionCode, 'PolySci_Product__c = true', new List<String>{'C', 'D', 'F', 'R', 'S'});
        productSubCategories = Utility.fetchProductSubcategories(regionCode, brand,plmStatusNotStartsWith ,null);        
        
        //To fetch products
        fetchProducts();

        acct = new Account();
        asset =  new Asset();
        isSuccess = false;   
        
        dummyAccount = new Account();             
    }

/* Picklist of products related to product SubCategory from Product */
    public void fetchProducts(){
    	//products = Utility.fetchProducts(regionCode, selectedSubCategory, null, new List<String>{'C', 'D', 'E', 'F', 'R', 'S'}, productIdToProductCodeMap);
    	products = Utility.fetchProducts(regionCode, selectedSubCategory, brand,plmStatusNotStartsWith, null, productIdToProductCodeMap);
    }
    
    /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates asset objects.
     */
    public  pagereference registrationSave() 
    { 		
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
    	asset.Warranty_Product_Sub_Category__c = selectedSubCategory;
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
        
        if(!Utility.validatePurchaseDate(asset.PurchaseDate)){
            return null;
        } 
        
		try{
			//if(objCase.Batch_Code__c == null || CaseTriggerHandler.isBatchCodeValid(asset.Batch_Code__c, Datetime.now(),asset.PurchaseDate)){
				Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
          		upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2, currencyCode);
          		
          		asset.AccountId =acct.Id;
           		asset.Name = acct.FirstName + ' ' + acct.LastName + ' - ' + productIdToProductCodeMap.get(asset.Product2Id) ;
            	asset.Where_did_you_purchase__c = objCase.Purchased_From__c;
            	insert asset;
            	isSuccess = true;
            	
	    //    }else{
	     //       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Batch_Code_Error_Message));
	     //   }
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
    private void createErrorMessage(String err){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err));
    }
    

    /**
     * Adds fields to the fielderror string passed in from the checkfields
     * method.
     */
    public    void addField(String label){
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
        	acct.personBirthDate = dummyAccount.personBirthDate;
        	acct.Gender__c = dummyAccount.Gender__c;
        	acct.Subscribe_to_our_newsletter__c = dummyAccount.Subscribe_to_our_newsletter__c;
        }
    
    }

    /**
     * Verifies all required fields have been populated on vf page.
     */
    public  void checkFields(){
    
        if (String.isBlank(asset.Warranty_Product_Sub_Category__c)) {
            addField(Label.Product_Sub_Category);
        }

        if (String.isBlank(asset.Product2Id)) {
            addField(Label.Asset_Product);
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
    
    }
   
       }