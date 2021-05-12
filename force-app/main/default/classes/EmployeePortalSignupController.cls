public without sharing class EmployeePortalSignupController {
    public Account acct { get; set; }   
    public String confirmEmail { get; set; }
    public String personBillingStreet2 { get; set; }   
    public Boolean isSuccess {get; set;}
    public String fieldErrors; 
    public String successMessage;
    public Boolean recaptchaValidation{get;set;}
    
    public Account dummyAccount { get; set; } 
    public String URL {get; set;}
    public string code {get; set;} 
    public String communityProfileName {get; set;}
    public String accountOwnerId {get;set;}
    public String allowedDomains {get;set;}
    public boolean restrictDomain {get;set;}
    
    public EmployeePortalSignupController() {
    	
    	Map<String, EmployeePortalSettings__c> settings = EmployeePortalSettings__c.getAll();
    	communityProfileName = settings.get('communityProfileName').Value__c;
    	accountOwnerId = settings.get('accountOwnerId').Value__c;
    	allowedDomains = settings.get('allowedDomains').Value__c;
    	String restrict = settings.get('restrictDomain').Value__c;
    	if(restrict.equals('1')){
    		restrictDomain = true;
    	}else{
    		restrictDomain = false;
    	}
        //To display success message
        Component.Apex.OutputText output;
		output = new Component.Apex.OutputText();
		output.expressions.value = '{!$Label.emp_portal_reg_success}';
		if(Test.isRunningTest())
			successMessage = '';
		else
			successMessage = string.valueOf(output.value);
		
        acct = new Account();
        isSuccess = false;   
        dummyAccount = new Account();
    }
    
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
    	fieldErrors ='';
        copyValues();  //probably not needed.
        checkFields(); 
        
        if(fieldErrors != ''){
            createErrorMessage(Label.Following_Fields_are_Required + ' ' + fieldErrors + Label.Please_make_the_necessary_corrections);
            return null;
        }
        if(restrictDomain && !validateDomain()){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.invalidDomain));
        	return null;
        }
        if(!Utility.validateEmail(acct.PersonEmail, confirmEmail)){
            return null;
        }
        if(!Utility.validatePostalCode(acct.BillingPostalCode, Utility.fetchRegionCodeFromCountry(acct.BillingCountryCode))){
            return null;
        }
        if(!Utility.validateBillingStreet(acct.BillingStreet)){
            return null;
        }
      	createUserAccRecords();
		if(isSuccess){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
        }
        return null;
    } 
    
    private boolean validateDomain(){
    	for(String key : allowedDomains.split(',')){
			if(acct.PersonEmail.contains(key.trim())){
				return true;
			}
		}
		return false;
    }
    
    private void createUserAccRecords(){
    	Id userId;
    	try{
    		Profile profileRecord = [SELECT Id FROM profile WHERE name=:communityProfileName];
        	List<User> userList = [SELECT Id,UserName,FirstName,LastName,Email FROM User WHERE email = :acct.PersonEmail and profileId=:profileRecord.id];
        	if(userList != null && userList.size() > 0){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.email_exists_emp_portal));
				return;
			}else{
				Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
				if(existingaccount == null)
					acct.AccountSource = 'Employee Portal';
				acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
				acct.OwnerId = accountOwnerId;
          		upsert Utility.createUpdateAccount(existingaccount, acct, personBillingStreet2,Utility.fetchCurrencyCodeFromCountry(acct.BillingCountryCode));
          		
          		User userRecord = new User();
          		userRecord.username = acct.PersonEmail+'.emp';
          		userRecord.email = acct.PersonEmail;
		        userRecord.lastName = acct.lastName;
		        userRecord.firstName = acct.firstName;
		        userRecord.CommunityNickname = acct.firstname.subString(0,1) +acct.lastname.subString(0,1)+ System.now().getTime()/1000;
		        userRecord.contactId = acct.Id;
		        userId = Site.createExternalUser(userRecord, acct.Id, '');
		        
		        if(userId != null){
		        	isSuccess = true;
		        }
		        else{
		        	isSuccess = false;
		        }
			}
        }catch (Exception e){
            if(!ApexPages.hasMessages())
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
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
        	acct.ShippingCountryCode = dummyAccount.BillingCountryCode;
        	acct.ShippingStreet = dummyAccount.BillingStreet;
        	acct.ShippingCity = dummyAccount.BillingCity;
        	acct.ShippingStateCode = dummyAccount.BillingStateCode;
        	acct.ShippingPostalCode = dummyAccount.BillingPostalCode;
        }
    }

    /**
     * Verifies all required fields have been populated on vf page.
     */
    public  void checkFields(){
      
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
        	if(acct.BillingCountryCode != 'GB')
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
    public  pagereference openLoginPage() 
    {
    	return new PageReference(Network.getLoginUrl(Network.getNetworkId()));
    }
}