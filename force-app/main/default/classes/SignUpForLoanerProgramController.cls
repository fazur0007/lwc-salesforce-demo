/**
* This is the controller class for the SignUpForLoanerProgram visual force page.
* This class takes the data from the visual force page for Loaner program
*
* @author -Monali Jagtap 
* @since November 1, 2019
*/
public without sharing class SignUpForLoanerProgramController {
    
    
    public string code {get; set;}
    public Account dummyAccount { get; set; } 
    public Account acct { get; set; } 
    public String URL {get; set;}
    public boolean isSuccess {get;set;}
    public String regionCode{get;set;}
    public boolean showEmailError {get; set;}
    public boolean showCountryError {get; set;}
    public boolean isProgramActive {get; set;}
    public String requiredFieldError {get;set;} 
    public String validFieldError {get;set;} 
    public boolean showfirstNameError {get; set;}
    public String heading {get;set;}
    public String successMessage {get;set;}
    public String firstNameError {get;set;} 
    public boolean showlastNameError {get; set;}
    public String lastNameError {get;set;} 
    public String currencyCode;
    public String lang;
    public String accountPreferredLanguage;
    List<Loaner_Program__c> lp;
    public String program;
    public String invalidUrl{get;set;}
    public String brand{get;set;}
    final private String defaultBrand = 'Breville';
    public String personBillingStreet2 { get; set; } 
    public boolean showstreetError {get; set;}
    public boolean showcityError {get; set;}
    public boolean showzipError {get; set;}
    public boolean showphoneError {get; set;}
    public boolean showstateError {get; set;}
    public boolean validstateError {get; set;}
    String BillingStreet2; 
    
    public SignUpForLoanerProgramController(){
        dummyAccount = new Account();
        dummyAccount.BillingCountryCode = 'US';
        acct= new Account();
        showEmailError = false;
        showFirstNameError =false;
        showLastNameError = false;
        showCountryError = false;
        showstreetError = false;
        showcityError = false;
        showzipError = false;
        showphoneError = false;
        showstateError = false;
        validstateError = false;
        requiredFieldError = '';
        validFieldError = '' ;
        isSuccess =false;
      
        
        
        
        URL = ApexPages.currentPage().getParameters().get('param');
        if(URL == null || URL == ''){
            URL='US'; 
            isProgramActive=false;    
        }
        
        regionCode = Utility.fetchRegionCodeFromEPRegion(URL);
        currencyCode = Utility.fetchCurrencyCodeFromEPRegion(URL);
        lang = ApexPages.currentPage().getParameters().get('language');
        program = ApexPages.currentPage().getParameters().get('pgm');
        
        //List<Loaner_Pgrm_Setting__mdt> loanerPrgmMdt;
        if(program == null || program == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.InvalidURL));
        }else{
            // loanerPrgmMdt = [select Heading__c, successMessage__c from Loaner_Pgrm_Setting__mdt where developerName=:program and Country__c=:regionCode limit 1];
            lp=[Select Heading__c, SuccessMessage__c,ProgramName__c,Active__c from Loaner_Program__c where ProgramName__c=:program];
            if(lp.size()>0){
                isProgramActive=lp[0].Active__c;
                heading = lp[0].Heading__c;
                successMessage = lp[0].SuccessMessage__c;
                Component.Apex.OutputText output = new Component.Apex.OutputText();
                output.expressions.value = '{!$Label.' + successMessage + '}';
                successMessage = string.valueOf(output.value);
            }
            else{
                isProgramActive=false;    
            }
            invalidUrl= Label.InvalidURL;
            
        }
        
        //To fetch Language code based on the param passed.
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From Region_Specific__mdt Where EPParameter__c=:URL];
        
        if(lang != null && lang != ''){
            if(lang.equalsIgnoreCase('en')){
                code = lang;
                accountPreferredLanguage = 'English';
            }    
            else{
                code = regionSpecific.LanguageCode__c;
                accountPreferredLanguage = 'English';
            }
        }else{
            code = Label.Default_LanguageCode;
            accountPreferredLanguage = 'English';
        }
        
        
        
    }
    
    public  pagereference subscriptionSave(){
        resetRequiredFields();
        checkRequiredFields();
        BillingStreet2 = (personBillingStreet2 != null && personBillingStreet2.trim() != '') ? '\n '+personBillingStreet2 : '';
        System.debug('BillingStreet2 = '+BillingStreet2);
        
        if(showEmailError==true||showfirstNameError==true||showLastNameError==true||showCountryError==true||validstateError==true
           ||showstreetError ==true|| showcityError ==true||showzipError ==true||showphoneError ==true||showstateError==true){
               if(validstateError==true){
                   validFieldError = 'Control Freak program is not available in your state';
               }else{
                   requiredFieldError = 'Please enter a value'; 
               }
               return null;  
           }else{
               
               Account existingaccount = Utility.findExistingAccount(dummyAccount.personEmail);
               Loaner_Program__c loanerPgm=lp[0];
               
               List<Loaner_Nomination__c> existingNomination=[Select Id,Email__c,Loaner_Program__c from Loaner_Nomination__c where Email__c=:dummyAccount.personEmail and Loaner_Program__c=:loanerPgm.Id];
               
               if(existingaccount==null && existingNomination.size()==0){
                   createUpdateAccountAndLoanerPgm(dummyAccount,existingaccount,lp[0]); 
                   
               }
               else If(existingaccount!=null && existingNomination.size()==0){
                   createUpdateAccountAndLoanerPgm(dummyAccount,existingaccount,lp[0]);
                   
               }else{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Email_Exist_Loaner_Prgm));
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
        if(dummyAccount.BillingCountryCode == null || dummyAccount.BillingCountryCode == ''){
            showCountryError = true;
        }
        if(dummyAccount.BillingStreet == null || dummyAccount.BillingStreet == ''){
            showstreetError = true;
        }
        if(dummyAccount.BillingCity == null || dummyAccount.BillingCity == ''){
            showcityError = true;
        }
        if(dummyAccount.BillingPostalCode == null || dummyAccount.BillingPostalCode == ''){
            showzipError = true;
        }
        if(dummyAccount.BillingStateCode == null || dummyAccount.BillingStateCode == ''){
            showstateError = true;
        }
        if(dummyAccount.Phone == null || dummyAccount.Phone == ''){
            showphoneError= true;
        }
        System.debug('dummyAccount.BillingStateCode '+dummyAccount.BillingStateCode);
        if(dummyAccount.BillingStateCode == 'HI'|| dummyAccount.BillingStateCode == 'AK' || dummyAccount.BillingStateCode == 'PR'){
            validstateError = true;
            System.debug('validstateError '+validstateError);
        }
    }
    
    public void resetRequiredFields(){
        showEmailError = false;
        showfirstNameError = false;
        showlastNameError = false;
        showCountryError = false;
        showstreetError = false;
        showcityError = false;
        showzipError= false;
        showphoneError = false;
        showstateError= false;
        validstateError = false;
    }
    
    public void createUpdateAccountAndLoanerPgm(Account dummyAccount,Account existingAccountDetails,Loaner_Program__c lp){
        Account newAcc ;
        
        if(existingAccountDetails!=null){
            newAcc = existingAccountDetails;
        }else{
            newAcc=new Account();
        }
        
        newAcc.FirstName=dummyAccount.FirstName;
        newAcc.LastName=dummyAccount.LastName;
        newAcc.PersonEmail=dummyAccount.personEmail;
        newAcc.Agreed_for_Opt_in__c=true;
        newAcc.Phone = dummyAccount.Phone;
        newAcc.BillingCountryCode = dummyAccount.BillingCountryCode;
        newAcc.BillingStreet = dummyAccount.BillingStreet + BillingStreet2;
        newAcc.BillingCity = dummyAccount.BillingCity;
        newAcc.BillingStateCode = dummyAccount.BillingStateCode;
        newAcc.BillingPostalCode = dummyAccount.BillingPostalCode;
        newAcc.ShippingCountryCode = dummyAccount.BillingCountryCode;
        newAcc.ShippingStreet = dummyAccount.BillingStreet + BillingStreet2; 
        newAcc.ShippingCity = dummyAccount.BillingCity;
        newAcc.ShippingStateCode = dummyAccount.BillingStateCode;
        newAcc.ShippingPostalCode = dummyAccount.BillingPostalCode;
        newAcc.PreferredLanguage__c= accountPreferredLanguage;
        
        try{
            upsert newAcc;
        } catch(Exception accInsertExcp){
            if(!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, accInsertExcp.getMessage()));
        }
        
        Loaner_Nomination__c loanerNom=new Loaner_Nomination__c();
        loanerNom.Account__c=newAcc.Id;
        loanerNom.Loaner_Program__c=lp.Id;
        loanerNom.Status__c='Nomination Applied';
        loanerNom.Country_Code__c = dummyAccount.BillingCountryCode;
        loanerNom.Street__c = dummyAccount.BillingStreet + BillingStreet2; 
        loanerNom.City__c = dummyAccount.BillingCity;
        loanerNom.State_Code__c = dummyAccount.BillingStateCode;
        loanerNom.Postal_Code__c = dummyAccount.BillingPostalCode;
        
        try{
            insert loanerNom;
        } catch(Exception loanerNomInsertExcp){
            if(!ApexPages.hasMessages())
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, loanerNomInsertExcp.getMessage()));
        }
        isSuccess = true;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, successMessage));
        dummyAccount.personEmail = '';
        
        
    }  
    
}