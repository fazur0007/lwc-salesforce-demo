/******************************************************************************************************************************
*  @ClassName      : SignUpForNewsLetterRest
*  @Description    : This class will expose REST endpoints for Signingup for NewsLetter.
*  @History        : Deepak T - Create Class.
Navneet Bhatia - Modified Class.
*******************************************************************************************************************************/
@RestResource(urlMapping = '/SignUpForNewsLetter/*')
global without sharing class SignUpForNewsLetterRest {

    global class RequestWrapper {
        global String firstName;
        global String brand;
        global String lastName;
        global String email;
        global Boolean hasSubscribed;
        global String Region;
        global String language;
        global String MarketingZipCode;
    }

    global class ResponseWrapper {
        public Boolean success;
        public String id;
        public list < String > errors;
    }

    private static String lang;

    private static ResponseWrapper verifyRequest(RequestWrapper request) {
        ResponseWrapper resp = new ResponseWrapper();
        resp.success = true;
        resp.id = '';
        if (Utility.fetchRegionCodeFromEPRegionAPI(request.region) == 'ERROR') {
            resp.success = false;
            resp.errors = new List < String > {
                System.Label.myBrevilleAPI_invalid_region
            };
            return resp;
        }
        if (request.hasSubscribed == null) {
            resp.success = false;
            resp.errors = new List < String > {
                System.Label.myBrevilleAPI_hasSubscribed_field_required
            };
            return resp;
        }
        if (request.email == null || request.email == '') {
            resp.success = false;
            resp.errors = new List < String > {
                System.Label.Email_field_required
            };
            return resp;
        }
        Boolean isValidEmail = Utility.isValidEmail(request.email);
        if (!isValidEmail) {
            resp.success = false;
            resp.errors = new List < String > {
                System.Label.myBrevilleAPI_invalid_email_address
            };
            return resp;
        }
        /*
        if(request.lastName==null || request.lastName==''){
            resp.success = false;
            resp.errors = new List<String>{System.Label.LastName_field_required};
            return resp;
        }
        */
        if (request.language == null || request.language == '') {
            resp.success = false;
            resp.errors = new List < String > {
                System.Label.required_field_language
            };
            return resp;
        }
        lang = Utility.getLanguageFromLanguageCode(request.language);
        if (lang == null) {
            resp.success = false;
            resp.errors = new List < String > {
                System.Label.invalid_language_code
            };
            return resp;
        }
        return resp;
    }

    //handling POST request.
    @HttpPost
    global static ResponseWrapper createNewCase(RequestWrapper request) {
        system.debug('wrapper details****' + JSON.serializePretty(request));
        ResponseWrapper resp = verifyRequest(request);
        if (resp.success == false) {
            return resp;
        }
        if (request.firstName == null) {
            request.firstName = '';
        }

        Account thisAccount = new Account();
        thisAccount.personEmail = request.email;
        //thisAccount.firstName = request.firstName;
        //thisAccount.lastName = request.lastName;
        thisAccount.PreferredLanguage__c = lang;
        //adding branding value logic


        //Check whether the Account with the particular 'email' exists.
        Account existingAccount = Utility.findExistingAccount(request.email);
        
        if (existingAccount != null)
        {
            if(request.lastName != null && string.IsNotBlank(request.lastName))
                thisAccount.lastName = request.lastName;
            if(request.firstName != null && string.IsNotBlank(request.firstName))
                thisAccount.firstName = request.firstName;
        }
        else
        {
            thisAccount.lastName = request.lastName;
            thisAccount.firstName = request.firstName;  
        }
        

        News_Letter_Configuration__mdt newsLetters = [Select Id, DeveloperName, Beanz_Brand__c, Breville_Brand__c From News_Letter_Configuration__mdt Where DeveloperName = 'SignUpForNewsLetterRest'];
        request.brand = request.brand == null || string.IsBlank(request.brand) ? 'Breville' : request.brand;
        if (existingAccount == null && (request.lastName == null || string.IsBlank(request.lastName)))
            thisAccount.LastName = request.brand.ContainsIgnoreCase('Beanz') ? newsLetters.Beanz_Brand__c : request.brand.ContainsIgnoreCase('App') ? newsLetters.App_Brand__c : newsLetters.Breville_Brand__c;
        String brandName = request.brand.ContainsIgnoreCase('Beanz') ? 'Beanz' : request.brand.ContainsIgnoreCase('App') ? 'App' : 'Breville';
        string marketingOptIn = existingAccount != null && String.IsNotBlank(existingAccount.Marketing_Opt_In__c)?existingAccount.Marketing_Opt_In__c:'';
        thisAccount.Marketing_Opt_In__c = marketingOptIn.ContainsIgnoreCase(brandName)?marketingOptIn:marketingOptIn+';'+brandName;
        //thisAccount.Marketing_Opt_In__c = (existingAccount != null && !existingAccount.Marketing_Opt_In__c.containsIgnoreCase(brandName)) ? existingAccount.Marketing_Opt_In__c + ';' + brandName : brandName;
        thisAccount.AccountSource = existingAccount == null ? 'Web' : null;
        thisAccount.Agreed_for_Opt_in__c = request.brand.ContainsIgnoreCase('Beanz') ? false : request.hasSubscribed;

        //code added for MarketingZipCode
        if (request.MarketingZipCode != null && string.IsNotBlank(request.MarketingZipCode)) {
            thisAccount.Marketing_Zip_Code__c = request.MarketingZipCode;
        }

        String currencyCode = Utility.fetchCurrencyCodeFromEPRegionAPI(request.Region);
        try {
            upsert Utility.createUpdateAccount(existingaccount, thisAccount, currencyCode);
        } catch (Exception e) {
            resp.success = false;
            resp.id = '';
            resp.errors = new List < String > {
                System.Label.myBrevilleAPI_Exception + ' ' + e.getMessage()
            };
            return resp;
        }
        resp.success = true;
        resp.id = thisAccount.id;
        resp.errors = new List < String > ();
        return resp;
    }

}