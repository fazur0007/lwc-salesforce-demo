/**
 * This is the controller for the WebToCaseForFastSlowCooker VisualForce page.
 * It takes necessary data from the page, validates it, and saves to Account (if new),
 * and Case for the product code "BPR600XL".
 *
 * Revision History:
 *
 * Version           Author          Last Modified Date (MM/DD/YYYY)          Description
 *  1.0        Dnyanesh Chandratre          10/19/2015                       Initial Draft
 **/

public without sharing class WebToCaseForFastSlowCookerController {

    public static final String COOKER_SKU_USA = 'BPR600XL';
    public static final String COOKER_SKU_CANADA = 'BREBPR600XL';
    public static final String ITEM_1_USA = 'BPR600XL/05';
    public static final String ITEM_1_CANADA = 'BPBPR60005.1';

    public Account acct { get; set; }
    public Account dummyAccount { get; set; }
    public Case objCase { get; set;}
    
    public Boolean isSuccess{get;set;}
    public String personBillingStreet2 { get; set; }
    public String fieldErrors;
    public String confirmEmail { get; set; }
    public string code {get; set;}
    public String URL {get; set;}
    public string whereDidYouPurchase {get; set;}
    private Case objCaseToInsert;
    public String footerInformation{get;set;}
	String regionCode;
    String currencyCode;
    public String tooltip{get;set;}
    
    public WebToCaseForFastSlowCookerController(){ 
		acct = new Account();
		dummyAccount = new Account();
		isSuccess = false; 
		objCase = new Case();  
		fieldErrors = '';
		URL = ApexPages.currentPage().getParameters().get('param');
		regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
		currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
		String lang = ApexPages.currentPage().getParameters().get('language');
		if(lang != null && lang != ''){
			code=lang;
		}else{
			code=System.Label.Default_LanguageCode;
        }
        footerInformation = 'FooterInformation_'+Utility.fetchRegionCodeFromEPRegion(URL);
        tooltip='images/ProductBatchCode_' +lang +'.jpg';
    } 

     /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates Case objects.
     */
    public pageReference registrationSave(){
        List<Product2> lstProducts;
        String queryString = 'SELECT Id,'
                           + '       Product_Sub_Family__c'
                          + '  FROM Product2';
        if(regionCode == 'USA') {
            queryString += ' WHERE AX_Item_Number__c = \'' + COOKER_SKU_USA + '\'';
            queryString += ' AND Breville_US_Product__c = true';
        } else if(regionCode == 'CAN') {
            queryString += ' WHERE AX_Item_Number__c = \'' + COOKER_SKU_CANADA + '\'';
            queryString += ' AND Breville_CAN_Product__c = true';
        }		
        queryString += ' LIMIT 1';

        lstProducts = Database.query(queryString);
        if(!lstProducts.isEmpty()) {
            objCase.Product__c = lstProducts[0].Id;
            objCase.Product_Sub_Category__c = lstProducts[0].Product_Sub_Family__c;
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
         if(!Utility.validatePurchaseDate(objCase.Purchase_Date__c)){
            return null;
        } 
        
        
		try{
			if(objCase.Batch_Code__c == null || CaseTriggerHandler.isBatchCodeValid(objCase.Batch_Code__c, Datetime.now(), objCase.Purchase_Date__c)){
          	Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
          	
          	/* updated code for recall bug START*/
          	if(existingaccount != null){
          		existingaccount.BillingStreet = acct.BillingStreet;
          		existingaccount.FirstName = acct.FirstName;
          		existingaccount.LastName = acct.LastName;
          		existingaccount.Phone = acct.Phone;
          		existingaccount.BillingCountryCode = acct.BillingCountryCode;
          		existingaccount.BillingStreet = acct.BillingStreet;
          		existingaccount.BillingCity = acct.BillingCity;
          		existingaccount.BillingStateCode = acct.BillingStateCode;
          		existingaccount.BillingPostalCode = acct.BillingPostalCode;
          		existingaccount.BillingStreet += personBillingStreet2 != null ? '\n' +personBillingStreet2 : '';
				update existingaccount;
          	}else{
          		acct.AccountSource = 'Web';
          		acct.BillingStreet += personBillingStreet2 != null ? ', '+personBillingStreet2 : '';
        		acct.CurrencyIsoCode = currencyCode;
        		acct.RecordTypeId = Utility.fetchRecordTypeId('Account', 'PersonAccount');
    			acct.Id = null;
				insert acct;
          	}
          	/* updated code for recall bug END*/
            Account acc; 
            if(acct != null && acct.Id != null){  
           		acc = [select Id, PersonContactId from Account where id =:acct.Id];
            }else{
            	acc = [select Id, PersonContactId from Account where Id = :existingaccount.Id];
            }	
            objCase.RecordTypeId = Utility.fetchRecordTypeId('Case', 'New_Case');
            objCase.CurrencyIsoCode = currencyCode;
	        objCase.Origin = 'Web Inquiry';
           	objCase.AccountId = acc.Id;
	        objCase.ContactId = acc.PersonContactId;
            objCase.Complaint_Code__c = 'Recall';
           
            objCase.Sub_Complaint_Code__c = 'BPR600';
            objCase.Item_1_Qty__c = 1;
            objCase.Order_Type__c = 'Accommodation';
            objCase.Order_Exception_Approved__c = true;
            objCase.Country__c = regionCode;
            if(regionCode == 'USA') {
            objCase.Submit_Order__c = false;
            } else if(regionCode == 'CAN') {
                 objCase.Submit_Order__c = true;
			}
            queryString = 'SELECT Id,'
                        + '       Product_Sub_Family__c'
                        + '  FROM Product2';
            if(regionCode == 'USA') {
                queryString += ' WHERE AX_Item_Number__c = \'' + ITEM_1_USA + '\'';
                queryString += ' AND Breville_US_Product__c = true';
            } else if(regionCode == 'CAN') {
                queryString += ' WHERE AX_Item_Number__c = \'' + ITEM_1_CANADA + '\'';
                queryString += ' AND Breville_CAN_Product__c = true';
            }

            queryString += ' LIMIT 1';

            lstProducts = Database.query(queryString);
            if(!lstProducts.isEmpty()) {
                objCase.Item_1__c = lstProducts[0].Id;
            }
            //Utility.validateLookupFilter(objCase.Product__c);
            
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule= true;
            objCase.setOptions(dmlOpts);
            
            insert objCase;
            isSuccess = true;
                
       }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Batch_Code_Error_Message));
            }
        }
        catch (Exception e) {
            if(!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }

        if(isSuccess){
			ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Info, Label.Thanks_For_Request));
        }
        return null; // Added for testing form submission
    }
     /**
     * Creates an error messge based on the data sent in.
     */
    private void createErrorMessage(String err){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err));
    }

     /**
     * Verifies a string is valid and is not null or an empty string.
     */
    private Boolean isValid(String value){
        if(value == null || value == ''){
            return false;
        }
        return true;
    }

    private void addField(String label){
        if(fieldErrors == ''){
            fielderrors = fielderrors + label;
        }
        if(!fieldErrors.contains(label)){
            fieldErrors = fielderrors + ', ' + label;
        }
    }
    
    /**
     * Verifies all required fields have been populated on vf page.
     */
    public void checkFields(){
    	if(!isValid(acct.FirstName)){
        	addfield(Label.First_Name);
		}
        if(!isValid(acct.LastName)){
            addfield(Label.Last_Name);
        }
        if(!isValid(acct.PersonEmail)){
            addfield(Label.Email);
        }
        if(!isValid(confirmEmail)){
            addfield(Label.confirmEmail);
        }
        if(String.isBlank(acct.BillingStreet)){ 
            addfield(Label.Street);
        }
        if(String.isBlank(acct.BillingCity)){ 
            addfield(Label.City_Label);
        }
        if(String.isBlank(acct.BillingCountryCode)){ 
            addfield(Label.Country);
        }
        if(String.isBlank(acct.BillingStateCode)){ 
            addfield(Label.State);
        }
        if(String.isBlank(acct.BillingPostalCode)){ 
            addfield(Label.Postal_Code);
        }
        if(!isValid(objCase.Batch_Code__c)){
            addfield(Label.Product_Batch_Code);
        }
    }

    public void Upload(){
        if(isSuccess){
            String successMessage;
            Component.Apex.OutputText output;
			output = new Component.Apex.OutputText();
			output.expressions.value = '{!$Label.' + 'Thank_you_inquiry_' + Utility.fetchRegionCodeFromEPRegion(URL) + '}';
			successMessage = string.valueOf(output.value);
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
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
        }
    
    }
}