global without sharing class LightningLoginFormController {
    
    public LightningLoginFormController() {
        
    }
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl) 
    {
        string strExpId = getExperienceIdFromSite();
        try
        {
            List<User> lstUser = [select id,Account_Id__c from User where username=:username];
            if(lstUser.size()>0)
            {
                Account CustAccount = [select id,Customer_Portal_User__c,Marketing_Opt_In__c from Account where id=:lstUser[0].Account_Id__c];
                
                CustAccount = CommunityUserManagementUtility.FetchAccountDefaults(CustAccount,strExpId,false);
                update CustAccount;
                lstUser[0] = CommunityUserManagementUtility.FetchUserDefaults(lstUser[0],CustAccount,strExpId,false);
                update lstUser[0];
            }
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, ex.getMessage());            
            return getLoginErrorMessage(strExpId);            
        }
    }
    
    public static string getLoginErrorMessage(String expId)
    {
        String errorMessage;
        Map<String, String> translations = getTranslationsByExpID(expId);
        for (String keyName:translations.keySet())
        {
            if (keyName.equalsIgnoreCase('Login_Failed_Error'))
                errorMessage = translations.get(keyName);
        }
        return errorMessage; 
    }

    @AuraEnabled
    public static Map<String,String> getTranslationsByExpID(String expId)
    {
        System.debug ('LoginFormController getTranslationsbyExpID: ');
        return CommunityUserManagementUtility.getTranslationsbyExpID(expId);
    }

    @AuraEnabled
    public static String getExperienceIdFromSite()
    {
        return CommunityUserManagementUtility.getExperienceIdFromSite();
    }

    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }
    
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }
    
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
    
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
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
}