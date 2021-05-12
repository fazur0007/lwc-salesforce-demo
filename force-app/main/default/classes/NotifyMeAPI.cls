/******************************************************************************************************************************
*  @ClassName      : NotifyMeAPI
*  @Description    : This class will expose REST endpoints for Product Notification.
*  @History        : Navneet Bhatia - Create Class.
*******************************************************************************************************************************/

@RestResource(urlMapping='/NotifyMe/*')
global without sharing class NotifyMeAPI {
    
    global class RequestWrapper{
        global String email;
        global String AX_Item_Number;
        global String Region;
        global String firstName;
        global String lastName;
        global String language;
        global String PDPUrl;
        global Boolean SubscribeToNewsletter;
    } 
    
    
    global class ResponseWrapper {           
        public Boolean success;
        public String id;
        public list<String> errors;
    }
    
    private static Boolean isduplicateProductPreference = false;
    private static String lang;
    private static Product2 productIdFromAXItemNumber = new Product2();
    
    private static ResponseWrapper verifyRequest(RequestWrapper request){
        ResponseWrapper resp = new ResponseWrapper();
        resp.success = true;
        resp.id = '';
        if(Utility.fetchRegionCodeFromEPRegionAPI(request.region) == 'ERROR'){
            resp.success = false;
            resp.errors = new List<String>{System.Label.myBrevilleAPI_invalid_region};
                return resp;
        }
        if(request.email==null || request.email==''){
            resp.success = false;
            resp.errors = new List<String>{System.Label.Email_field_required};
                return resp;
        }
        if(request.AX_Item_Number == null || request.AX_Item_Number == ''){
            resp.success = false;
            resp.errors = new List<String>{System.Label.myBrevilleAPI_AXItemNumber_required};
                return resp;
        }
        Boolean isValidEmail = Utility.isValidEmail(request.email);
        if(!isValidEmail){
            resp.success = false;
            resp.errors = new List<String>{System.Label.myBrevilleAPI_invalid_email_address};
                return resp;
        }
        if(request.lastName==null || request.lastName==''){
            resp.success = false;
            resp.errors = new List<String>{System.Label.LastName_field_required};
                return resp;
        }
        if(request.language==null || request.language==''){
            resp.success = false;
            resp.errors = new List<String>{System.Label.required_field_language};
                return resp;
        }
        lang = Utility.getLanguageFromLanguageCode(request.language);
        if(lang == null){
            resp.success = false;
            resp.errors = new List<String>{System.Label.invalid_language_code};
                return resp;
        }
        if(request.PDPUrl==null || request.PDPUrl==''){
            resp.success = false;
            resp.errors = new List<String>{System.Label.PDPUrl_field_required};
                return resp;
        }
        //Verify Product Details sent in request
        if(checkIfProductExists(request)==false){
            resp.success = false;
            resp.errors = new List<String>{System.Label.myBrevilleAPI_invalid_product};
                return resp;
        }
        
        //verify if product Preference already exists
        isduplicateProductPreference = isProductPreferenceDuplicate(request);
        if(isduplicateProductPreference){
            resp.success = false;
            resp.errors = new List<String>{System.Label.myBrevilleAPI_productPreference_exists};
                return resp;
        }
        if(request.SubscribeToNewsletter==null ){
            resp.success = false;
            resp.errors = new List<String>{System.Label.myBrevilleAPI_hasSubscribed_field_required};
                return resp;
        }
        return resp;
    }
    
    //Method to check if the product with given details exists or not
    private static boolean checkIfProductExists(RequestWrapper request){
        List<Product2> products = [SELECT Id FROM Product2 WHERE AX_Unique_ID__c =:Utility.fetchBusinessUnitEPRegionAPI(request.region)+''+request.AX_Item_Number];
        if(products != null && products.size()>0){
            productIdFromAXItemNumber = products[0];
            return true;
        }else{
            return false;
        }
    }
    
    //Method to check if product preference already exists
    private static boolean isProductPreferenceDuplicate(RequestWrapper request){
        String countryCode = Utility.fetchRegionCodeFromEPRegionAPI(request.region);
        List<Product_Preference__c> productPref = [SELECT Id FROM Product_Preference__c WHERE Country_Code__c =:countryCode  AND email__c= :request.email AND AX_Item_Number__c =:request.AX_Item_Number AND email_sent__c=null];
        if(productPref !=null && productPref.size()>0){
            return true;
        }else{
            return false;
        }
    }
    
    @HttpPost
    global static ResponseWrapper doPost(RequestWrapper request) {
        //Verify the request parameters
        ResponseWrapper resp = verifyRequest(request);
       
        if(request.firstName==null){
            request.firstName= '';
        }
        Account acct = new Account();
        acct.personEmail = request.email;
        acct.firstName = request.firstName;
        acct.lastName = request.lastName;
        acct.PreferredLanguage__c = lang;
        acct.Agreed_for_Opt_in__c = request.SubscribeToNewsletter;
        
        String currencyCode = Utility.fetchCurrencyCodeFromEPRegionAPI(request.Region);
        
        Account existingaccount = Utility.findExistingAccount(request.email);
        if(existingaccount == null) {
            acct.AccountSource = 'Web';
    	}
        try{
            acct =  Utility.createUpdateAccount(existingaccount, acct, currencyCode);
            upsert acct;
        }catch(Exception e){
            resp.success = false;
            resp.id = '';
            resp.errors = new List<String>{System.Label.myBrevilleAPI_Exception + ' ' + e.getMessage()};
                return resp;
        }
         if(resp.success==false){
            if(isduplicateProductPreference){
                resp.success = true;
            }
            return resp;
        }
        Product_Preference__c productPref = new Product_Preference__c();
        productPref.ProductID__c = productIdFromAXItemNumber.id;
        productPref.Channel__c = 'Ecomm';
        productPref.Country_code__c = Utility.fetchRegionCodeFromEPRegionAPI(request.region);
        productPref.CurrencyIsoCode = Utility.fetchCurrencyCodeFromEPRegionAPI(request.region);
        productPref.Account__c = acct.id;
        productPref.email_sent__c =null;
        productPref.PDPUrl__c = request.PDPUrl;
        try{
            insert productPref;
        }catch( Exception e ) {
            resp.success = false;
            resp.id = '';
            resp.errors = new List<String>{System.Label.myBrevilleAPI_Exception + ' ' + e.getMessage()};
                return resp;
        }
        resp.success = true;
        resp.id = productPref.id;
        resp.errors = null;
        return resp;
    }
    
}