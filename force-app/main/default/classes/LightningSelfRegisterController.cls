global  without sharing class LightningSelfRegisterController {
    
    public LightningSelfRegisterController() {      
    }
    
    @AuraEnabled
    public static String initialize()
    {
        return CommunityUserManagementUtility.getExperienceIdFromSite();
    }

    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @TestVisible
    private static Account createCustomerAccount(string email,Map<string,string> mapCommunitySettings)
    {
        Account userPersonalAccount = new Account();
        Boolean isCreate = true;
        String strExpId = initialize();
        userPersonalAccount.Email_External_ID__c = email;
        userPersonalAccount.PersonEmail = email;
        
        List<Account> lstAccount = [SELECT id,Customer_Portal_User__c, FirstName, LastName, Marketing_Opt_In__c FROM Account WHERE PersonEmail=:email];
        if(lstAccount.size()>0)      
        { 
            isCreate = false;
            userPersonalAccount = lstAccount[0];
        }
        
        userPersonalAccount = CommunityUserManagementUtility.FetchAccountDefaults(userPersonalAccount,strExpId,isCreate);
        
        if(lstAccount.size()>0)
            update userPersonalAccount;
        else
            insert userPersonalAccount;
        
        system.debug('userPersonalAccount:'+userPersonalAccount);
        return userPersonalAccount;
    }
    
    @TestVisible
    private static Map<String,String> getCommunitySettings()
    {
        Map<String,String> mapCommunitySettings = new Map<String,String>();        
        for(Customer_Community_Settings__mdt ObjSetting:[select id,DeveloperName,Value__c from Customer_Community_Settings__mdt])
        {
            mapCommunitySettings.put(ObjSetting.DeveloperName,ObjSetting.Value__c);
        }
        return mapCommunitySettings;
    }
    
    @TestVisible
    private static User populateCommunityUser(string email,Account userPersonalAccount,String password, String confirmPassword,Boolean includePassword,Map<string,string> mapCommunitySettings)
    {             
        String networkId = Network.getNetworkId();
        User newuser = new User();     
        Boolean isCreate = true;
        String strExpId = initialize();
        newuser.email = email;
        newuser = CommunityUserManagementUtility.FetchUserDefaults(newuser,userPersonalAccount,strExpId,isCreate);
        newuser.Email_verification_network_Id__c = networkId;
        newuser.Send_Mail_Verification_Email__c = true;
        system.debug('userPersonalAccount.Id:'+userPersonalAccount.Id);    
        return newuser;
    }
    
    @AuraEnabled
    public static void redirectOnSignUp(string username,string password)
    {
        PageReference page = Site.login(username, password, null);
        //page.setRedirect(true);
        //return page;
    }
    
    @AuraEnabled
    public static SignupResponse selfRegister(String firstname ,String lastname, String email, String password, String confirmPassword, 
                                              String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        Savepoint sp = null;
        Map<String,String> mapOfTranslations = CommunityUserManagementUtility.getTranslationsByExpID(initialize());
        Map<string,string> mapCommunitySettings = getCommunitySettings();
        try {
            sp = Database.setSavepoint();           
            if (email == null || String.isEmpty(email)) {
                //return Label.Site.email_is_required;
                SignupResponse objResponse = new SignupResponse();
                objResponse.message = mapOfTranslations.get('Email_address_is_required');
                objResponse.messageType = 'error';
                objResponse.messageTitle = 'Error';
                return objResponse;
            }
            
            //Populate user data
            List<User> lstExistingUser = [select id from user where email=:email];
            if(lstExistingUser.size()>0)
            {
                SignupResponse objResponse = new SignupResponse();
                objResponse.message = mapOfTranslations.get('User_already_exists');
                objResponse.messageType = 'error';
                objResponse.messageTitle = 'Error';
                return objResponse;
            }
            
            //Populate default data for account
            Account userPersonalAccount = createCustomerAccount(email,mapCommunitySettings);
            system.debug('userPersonalAccount:'+userPersonalAccount);
            
            
            User newuser = populateCommunityUser(email,userPersonalAccount,password,confirmPassword,includePassword,mapCommunitySettings);            
            newuser.CommunityNickname = email;
            //Validate password
            if (includePassword) {                    
                if(String.isNotBlank(confirmPassword))
                {
                    if (!isValidPassword(password, confirmPassword)) {
                        SignupResponse objResponse = new SignupResponse();
                        objResponse.message = Label.Site.passwords_dont_match;
                        objResponse.messageType = 'error';
                        objResponse.messageTitle = 'Error';
                        return objResponse;
                    }
                }
                confirmPassword = password;
                try
                {
                    validatePassword(newuser, password, confirmPassword);
                }
                catch (Exception ex) {
                    Database.rollback(sp);
                    String message = ex.getMessage();
                    system.debug('ex.getMessage():' + message);
                    //return ex.getMessage()+ex.getStackTraceString(); 
                    SignupResponse objResponse = new SignupResponse();
                    String errorMessage = CommunityUserManagementUtility.getErrorMessage(message, newuser.Exp_ID__c);
                    objResponse.message = errorMessage;
                    objResponse.messageType = 'error';
                    objResponse.messageTitle = 'Error';
                    objResponse.exceptionmessage = ex.getMessage();
                    return objResponse;
                }
            }
            else {
                password = null;
            }             
            
            String userId = Site.createPortalUser(newuser, userPersonalAccount.Id, password);
            SignupResponse objResponse = new SignupResponse();
            objResponse.message = mapOfTranslations.get('User_created_successfully'); 
            objResponse.messageType = 'confirm';
            objResponse.messageTitle = 'Success';
            objResponse.username = newuser.Username;
            objResponse.password = password;
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            system.debug('userId:'+userId + ',Network.getNetworkId():'+Network.getNetworkId());
            PageReference page = Site.login(newuser.username, password, startUrl);
            aura.redirect(page);
            return objResponse;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            system.debug('ex.getMessage():'+ex.getMessage());
            //return ex.getMessage()+ex.getStackTraceString(); 
            SignupResponse objResponse = new SignupResponse();
            objResponse.message =  mapOfTranslations.get('Unable_to_sign_up');
            objResponse.messageType = 'error';
            objResponse.messageTitle = 'Error';
            objResponse.exceptionmessage = ex.getMessage();
            return objResponse;
        }
    }
    
    
    public class SignupResponse
    {
        @AuraEnabled
        public string message {get;set;}
        @AuraEnabled
        public string messageType {get;set;}
        @AuraEnabled
        public string messageTitle {get;set;}
        @AuraEnabled
        public string exceptionmessage {get;set;}
        @AuraEnabled
        public string username {get;set;}
        @AuraEnabled
        public string password {get;set;}
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
            if (fieldSet != null) {
                for (Schema.FieldSetMember f : fieldSet.getFields()) {
                    Map<String, Object> fieldDetail = new Map<String, Object>();
                    fieldDetail.put('dbRequired', f.getDBRequired());
                    fieldDetail.put('fieldPath', f.getFieldPath());
                    fieldDetail.put('label', f.getLabel());
                    fieldDetail.put('required', f.getRequired());
                    fieldDetail.put('type', f.getType());
                    fieldDetail.put('value', '');   // client will populate
                    extraFields.add(fieldDetail);
                }
            }
        }
        Map<String, Object> fieldDetail = new Map<String, Object>();
        String expId = initialize();
        fieldDetail.put('experienceId', expId);
        fieldDetail.put('translations', getTranslationsbyExpID(expId));
        extraFields.add(fieldDetail);
        return extraFields;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    } 
    @AuraEnabled
    public static Map<String,String> getTranslationsByExpID(String expId)
    {
        System.debug ('LoginFormController getTranslationsbyExpID: ');
        return CommunityUserManagementUtility.getTranslationsbyExpID(expId);
    }
  
    @AuraEnabled global static User doGetCurrentUserConfig(String currentUserId){
        User currentUser = new User();
        currentUser.Id = currentUserId;
        currentUser.Community_Email_Verified__c = true;
        update currentUser;
        return [Select Id,UserName,Email,Name,Email_verification_network_Id__c,Exp_ID__c From User Where Id=:currentUserId Limit 1];
    }
    
    
}