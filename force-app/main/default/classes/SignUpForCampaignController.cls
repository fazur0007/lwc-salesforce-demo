public without sharing class SignUpForCampaignController {
    
    public string code {get; set;}
    public Account dummyAccount { get; set; } 
    public Account acct { get; set; } 
    public String URL {get; set;}
    public boolean isSuccess {get;set;}
    public String regionCode{get;set;}
    public boolean showEmailError {get; set;}
    public String requiredFieldError {get;set;} 
    public boolean showfirstNameError {get; set;}
    public String heading {get;set;}
    public String successMessage {get;set;}
    public String CampaignSubscriptionMessage {get;set;}
    public String firstNameError {get;set;} 
    public boolean showlastNameError {get; set;}
    public String lastNameError {get;set;} 
    public String currencyCode;
    public String lang;
    public String accountPreferredLanguage;
    public String camp;
    public String brand{get;set;}
    final private String defaultBrand = 'Breville';
    public List<Campaign> campaignList;
    public List<Campaign_Setting__mdt> campaignMdt;
    public String campaignName ;
    public String policyURL {get;set;}
    public boolean isShowpolicyURL {get;set;}
    public boolean isInvalidURL {get;set;}
    
    public SignUpForCampaignController(){
        dummyAccount = new Account();
        acct= new Account();
        showEmailError = false;
        showFirstNameError =false;
        showLastNameError = false;
        requiredFieldError = '';
        isSuccess =false;
        isInvalidURL = False;
        isShowpolicyURL=false;
        
        URL = ApexPages.currentPage().getParameters().get('param');
        regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
        currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
        lang = ApexPages.currentPage().getParameters().get('language');
        camp = ApexPages.currentPage().getParameters().get('campaign');
        campaignName = ApexPages.currentPage().getParameters().get('campaignName');
        
        /* changes for displaying brand name in CheckBox field based on Country */
        if(URL == 'DE' || URL =='CH' || URL =='UK'){
            brand = 'Sage';
            policyURL = Label.Privacy_Policy_Link_Sage;      
        }else{
            brand = defaultBrand;
            policyURL = Label.Privacy_Policy_Link_Breville;
        }
            
        
        if(camp != null && camp != ''){
            campaignMdt = [select Heading__c, successMessage__c, CampaignSubscriptionMessage__c from Campaign_Setting__mdt where developerName=:camp and Country__c=:regionCode limit 1];
        
	        if(campaignMdt !=null && campaignMdt.size()>0){
	            if(campaignMdt[0].Heading__c != null && campaignMdt[0].Heading__c != ''){
	                heading = campaignMdt[0].Heading__c;
	            }else{
	                heading = Label.Join_our_community;
	            }
	            if(campaignMdt[0].successMessage__c != null && campaignMdt[0].successMessage__c != ''){
	                successMessage = campaignMdt[0].successMessage__c;
	            }else{
	                successMessage = Label.campaign_success;
	            }
	            if(campaignMdt[0].CampaignSubscriptionMessage__c != null && campaignMdt[0].CampaignSubscriptionMessage__c != ''){
	                CampaignSubscriptionMessage = campaignMdt[0].CampaignSubscriptionMessage__c;
	            }else{
	                if(brand == 'Breville') {
	                    CampaignSubscriptionMessage =  Label.Air_Microsite_Breville ;
	                }else{
	                    CampaignSubscriptionMessage =  Label.Air_Microsite_Sage ;
	                }
	            }
            }else{
                heading = Label.Join_our_community;
                successMessage = Label.campaign_success;
        
                if(brand == 'Breville') {
                    CampaignSubscriptionMessage =  Label.Air_Microsite_Breville ;
                }else{
                    CampaignSubscriptionMessage =  Label.Air_Microsite_Sage ;
                }
            }
        }else if(campaignName != null && campaignName != ''){
            campaignList = [select Id , Name from Campaign where Name=:campaignName and CurrencyIsoCode=:currencyCode and IsActive = true  limit 1];

			if(campaignList!=null&&campaignList.size()>0){
	            heading = Label.campaign_heading;
	            successMessage = Label.campaign_success;
	            CampaignSubscriptionMessage =  Label.campaign_subscription_message ;
	            isShowpolicyURL = true;
	            
	            //Create dynamic policy link, replacing <regionCode> and <lang>.
	            policyURL = policyURL.replace('<regionCode>', (URL == 'DE') ? 'eu' : URL.toLowerCase()); 
	            policyURL = policyURL.replace('<lang>', lang); 
	        }else{
	                isInvalidURL = true; //for showing error and rerender page
	        }  
        }else{
            isInvalidURL = true; //for showing error and rerender page
        }
        
        //To fetch Language code based on the param passed.
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From Region_Specific__mdt Where EPParameter__c=:URL];
        
        /*if(lang != null && lang != ''){
            if(lang.equalsIgnoreCase('fr')){
                code = lang;
                if(URL == 'CA'){
                    code= 'fr_CA';
                }
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
        }*/
        
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
    }
    
    public  pagereference subscriptionSave(){
        resetRequiredFields();
        checkRequiredFields();
        if(showEmailError==true||showfirstNameError==true||showLastNameError==true){
            requiredFieldError = Label.Please_enter_a_value;
            return null;
        }else{
            acct.PersonEmail = dummyAccount.personEmail;
            acct.firstName = dummyAccount.FirstName;
            acct.LastName = dummyAccount.LastName;
            Account existingaccount = Utility.findExistingAccount(acct.PersonEmail);
            if(existingaccount==null){
                acct.Agreed_for_Opt_in__c = true;
                acct.AccountSource = 'Web';
            }else{
                Account acc= [select id, Agreed_for_Opt_in__c,  Subscribe_to_our_newsletter__c, Campaign_Subscription__c from Account where id =:existingAccount.Id limit 1 ];
                if(acc.Subscribe_to_our_newsletter__c==false && acc.Agreed_for_Opt_in__c==false){
                    acct.Agreed_for_Opt_in__c = true;
                }
                acct.Campaign_Subscription__c = acc.Campaign_Subscription__c;
            }
            
            acct.PreferredLanguage__c= accountPreferredLanguage;
            if(camp !=null && camp != ''){
                if(String.isNotBlank(acct.Campaign_Subscription__c)) {
                    if(!acct.Campaign_Subscription__c.containsIgnoreCase(camp)) {
                        acct.Campaign_Subscription__c+= ';'+camp;
                    }
                }else {
                    acct.Campaign_Subscription__c= camp;
                }                
            }
            try{
                if(camp != null && camp!= ''){
                    upsert Utility.createUpdateAccount(existingaccount, acct, currencyCode);
                }else if(campaignList !=null && campaignList.size()>0){
                    successMessage = Label.campaign_success;
                    upsert Utility.createUpdateAccount(existingaccount, acct, currencyCode);
                    List<Account> acctRec = [select Id , PersonContactId from Account where Id =: acct.Id];
                    List<CampaignMember> campmemberList = [select Id ,ContactId ,CampaignId from CampaignMember where CampaignId =: campaignList[0].Id and ContactId=:acctRec[0].PersonContactId  ];
                    if(campmemberList == null || campmemberList.size() == 0 ){
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = campaignList[0].Id ; 
                        campMem.ContactId = acctRec[0].PersonContactId  ;
                        campMem.Status ='Sent';
                        insert campMem;
                    }
                }
                
                isSuccess = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
                dummyAccount.personEmail = ''; 
                
            }catch (Exception e){
                isSuccess = true;
                if(!ApexPages.hasMessages()){
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
                }
            }           
            return null;
        }       
    }
    
    public void checkRequiredFields(){
        if(dummyAccount.personEmail == null || dummyAccount.PersonEmail == ''){
            showEmailError = true;
        }
        if(dummyAccount.firstName == null || dummyAccount.firstName == ''){
            showfirstNameError = true;
        }
        if(dummyAccount.lastName == null || dummyAccount.lastName == ''){
            showlastNameError = true;
        }        
    }
    
    public void resetRequiredFields(){
        showEmailError = false;
        showfirstNameError = false;
        showlastNameError = false;
    }   
}