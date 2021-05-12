public without sharing class PreChatOfflineController{
	public Account acct { get; set; }
	public Case objCase { get; set;}
	public String brand{get;set;}
	public Boolean isSuccess{get;set;}
    public String caseMessageInfo{get;set;}
	public String URL;
    public string code {get; set;}
	final private String defaultBrand = 'Breville';
	public String lang;
    public string pageURL;
    public string siteURL;
	String regionCode;
	String currencyCode;
	public List<SelectOption> CaseTypes;
	public Boolean dohaveCaseNo{get;set;}
	public Boolean taskCreated;
	public String description {get; set;}
	public String timeOfDay {get; set;}
	public String preference {get; set;}
    public Boolean caseCreated{get; set;} 
	public String accountPreferredLanguage;
    
    public PreChatOfflineController(){ 
        caseCreated = false;
		try{
			pageURL = ApexPages.currentPage().getUrl();
			if(pageURL == null)
				pageURL = '';
            siteURL = Site.getBaseUrl();
            if(siteURL == null)
                siteURL = '';
			      		     
			/*changes to take brand in URL parameter*/
			brand = ApexPages.currentPage().getParameters().get('brand');
			if(brand == null || brand =='')
				brand = defaultBrand;
			    
			URL = ApexPages.currentPage().getParameters().get('param');
			regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
			currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
			
            lang = ApexPages.currentPage().getParameters().get('language');
        
        //To fetch Language code based on the param passed.
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From Region_Specific__mdt Where EPParameter__c=:URL];
        
     /*   if(lang != null && lang != ''){
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
        
        */
        
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
            
			acct = new Account();
			objCase = new Case();
			objCase.Country__c = regionCode;
				
				
			CaseTypes = Utility.fetchCaseTypes('Case Type To Ignore');
			  	
			dohaveCaseNo=false;
			isSuccess = false;
			taskCreated = false;
			 
		}Catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
		}
	}
    
    
	public pageReference savecase(){
		system.debug('inside savecase');
		if(checkFieldsResult()){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.please_fill_required_fields));
			return null;
		}
		try{
			Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
			system.debug('existingaccount'+existingaccount);
				     
			if(existingaccount == null){
				system.debug('ac not exist');
				acct.AccountSource = 'Chat';
			}
			acct.PreferredLanguage__c = accountPreferredLanguage;
			upsert Utility.createUpdateAccount(existingaccount, acct, currencyCode);
			system.debug('created ac'+acct.Id);
			
			Account acc = [select PersonContactId from Account where id =:acct.Id];
			
			objCase.RecordTypeId = Utility.fetchRecordTypeId('Case', 'New_Case');
			objCase.Origin = 'Chat Inquiry';
			objCase.AccountId = acct.Id;
			objCase.ContactId = acc.PersonContactId;
            objCase.web_to_case_url__c = siteURL+pageURL.replace('/apex/','');
			//objCase.Complaint_Code__c = 'Questions & Feedback';
			objCase.CurrencyIsoCode = currencyCode;
			objCase.Country__c = regionCode;
			objCase.Description = description;
			if(description.length() > 30){
				objCase.Subject = 'Chat - ' +description.subString(0,31);
			}else{
				objCase.Subject = 'Chat - ' +description;
			}
			if(preference == 'Response by Phone'){
				objCase.Time_of_Day__c = timeOfDay;
			}
			objCase.Response_Preference__c = preference;
			System.debug('objCase.Country__c :' + objCase.Country__c);
			/*to store the URL from where the case was created*/
            if(URL == 'UK' || URL == 'DE'){
                objCase.brand__c = 'Sage';
            }else{
                objCase.brand__c = brand;
            }
			
			  
			/*to set OnwerId as System*/
			list<All_Literal__mdt> literalRec = [select Value__c from ALL_Literal__mdt where DeveloperName = 'CustomUserId'];
			if(literalRec != null && literalRec.size() > 0){
				objCase.ownerId = literalRec[0].Value__c;
			}
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.useDefaultRule= true;
			objCase.setOptions(dmlOpts);
			
			try{
				insert objCase;
				system.debug('case id'+objCase.id);
				/*Task taskToSave = new Task();
		        taskToSave.WhatId = objCase.Id;
		        taskToSave.Subject = 'Offline Chat';
		        taskToSave.Description = 'Please follow Up via ' +preference;
		        taskToSave.ownerId = objCase.OwnerId;
		        taskToSave.ActivityDate = Date.Today();
		        taskToSave.Time_of_Day__c = timeOfDay;
		        try{
		        	insert taskToSave;
		        }catch(System.DmlException ex){
		             Error_Log__c error = ErrorLog.logErrorActivity(ex.getMessage(),
	                 'error while creating task for case owner', 
	                 'PreChatOfflineController-SaveCase method',false, 'PreChatOfflineControllerError');
	                 insert error;
             	 }
		        isSuccess = true;
		        taskCreated = true;*/
			}catch(Exception e){
				Error_Log__c error = ErrorLog.logErrorActivity(e.getMessage(),
	                 'error while creating Case', 
	                 'PreChatOfflineController-SaveCase method',false, 'PreChatOfflineControllerError');
	            insert error;
			}
			
			      
			/*Appending case number to success Message  - start*/
			string caseNumber = [select casenumber from case where id =:objCase.id limit 1][0].caseNumber;
			if(caseNumber != null && caseNumber != ''){
                caseMessageInfo= Label.We_have_created_case + ' '+caseNumber + ' ' + Label.respond_soon;
			}
			/*Appending case number to success Message  - end*/
			isSuccess = true;
				                        
		}catch (Exception e){
			if(!ApexPages.hasMessages())
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
			Error_Log__c error = ErrorLog.logErrorActivity(e.getMessage(),
                 'error while inserting or updating account', 
                 'PreChatOfflineController-SaveCase method',false, 'PreChatOfflineControllerError');
            insert error;
		}
			        
		if(isSuccess){
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'We have notified agent about your case.'));
			 caseCreated = true;
            if(caseMessageInfo != null)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, caseMessageInfo));
		}
		return null;
	}
    
   
	/**
	* Verifies all required fields have been populated on vf page.
	*/
	public boolean checkFieldsResult(){
		
		if(String.isBlank(acct.FirstName)){
			return true;
		}
		
		if(String.isBlank(acct.LastName)){
			return true;
		}
		        
		if(String.isBlank(acct.PersonEmail)){
			return true;
		}
			               
		
		return false;
	}
}