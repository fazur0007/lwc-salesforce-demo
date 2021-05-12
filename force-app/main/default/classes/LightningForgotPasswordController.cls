global without sharing class LightningForgotPasswordController {
    
    public LightningForgotPasswordController() {
        
    }
    
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl,string startUrl) {
        String errorMessage = '';
        string strExpId = getExperienceIdFromSite();
        Map<String,String> mapOfTranslations = getTranslationsByExpID(strExpId);
        
        system.debug('username:'+username);
        try 
        {
            if (String.isBlank(username))
                errorMessage =  mapOfTranslations.get('Please_enter_your_email');
            else {
                List<User> users = [SELECT Id, UserName,Exp_ID__c,Account_Id__c FROM User WHERE UserName =:username LIMIT 1];
                system.debug('users:'+users);
                if (users != null && users.size()> 0){ 
                    updateCurrentUserExpID(users[0], strExpId);                     
                    errorMessage =  redirect(users[0], strExpId, checkEmailUrl,startUrl);
                }
                else
                {
                    errorMessage = mapOfTranslations.get('User_not_found');
                }
            }
        }
        catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        return errorMessage;
    }
    public static String redirect(User user, String strExpId, String checkEmailUrl,String startUrl)
    {
        try 
        {
            String errorMessage;
            String emailTemplateName = CommunityUserManagementUtility.getEmailTemplateName(
                CommunityUserManagementUtility.EVENT_TYPE_RESET_PASSWORD, strExpId);
            boolean result = Site.forgotPassword(user.UserName, emailTemplateName);
            System.debug ('Forgot password Message: ' + result);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl+'?startURL='+startUrl);
            if(!Site.isValidUsername(user.UserName)) {
                errorMessage = Label.Site.invalid_email;
            }
            if(!Test.isRunningTest()) {
                aura.redirect(checkEmailRef);
            }
            return errorMessage;
        }
        catch (Exception ex) 
        {
            System.debug ('Exception Message: ' + ex.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) 
    {    
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
    public static String getExperienceIdFromSite()
    {
        return CommunityUserManagementUtility.getExperienceIdFromSite();
    }
    
    public static void updateCurrentUserExpID(User userRec, String strExpId)
    {
        Account CustAccount = [select id,Customer_Portal_User__c,Marketing_Opt_In__c from Account where id =: userRec.Account_Id__c];
        
        CustAccount = CommunityUserManagementUtility.FetchAccountDefaults(CustAccount,strExpId,false);
        update CustAccount;
        userRec = CommunityUserManagementUtility.FetchUserDefaults(userRec,CustAccount,strExpId,false);
        update userRec;
                
    }
    @AuraEnabled
    public static Map<String,String> getTranslationsByExpID(String expId)
    {
        System.debug ('Exp Id: ' + expId);
        return CommunityUserManagementUtility.getTranslationsbyExpID(expId);
    }
}