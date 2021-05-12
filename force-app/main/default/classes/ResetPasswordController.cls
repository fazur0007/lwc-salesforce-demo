global without sharing class ResetPasswordController {
    @AuraEnabled 
    global static User getCurrentUserConfig(){
        return CommunityUserManagementUtility.getCurrentUserConfig();
    }

    @AuraEnabled
    public static Map<String,String> getTranslationsByExpID(String expId)
    {
        return CommunityUserManagementUtility.getTranslationsbyExpID(expId);
    }
}