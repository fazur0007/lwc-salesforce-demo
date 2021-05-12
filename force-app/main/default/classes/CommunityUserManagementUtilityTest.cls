@IsTest
global class CommunityUserManagementUtilityTest {

    @isTest
    static void testGetErrorMessage () {
        CommunityUserManagementUtility.getErrorMessage('Password', 'beanzENUS');
    }
    
    @isTest
    static void testGetErrorMessageforFrench () {
        CommunityUserManagementUtility.getErrorMessage('Passwords', 'brevilleFRCA');
    }
    
    @isTest
    static void testGetExperienceIdFromSite () {
        CommunityUserManagementUtility.getExperienceIdFromSite();
    }
    
    @isTest
    static void testTranslationsForITCH () {
        CommunityUserManagementUtility.getTranslationsbyExpID('sageITCH');
    }
    
    @isTest
    static void testTranslationsForDECH () {
        CommunityUserManagementUtility.getTranslationsbyExpID('sageDECH');
    }
    
    @isTest
    static void testTranslationsForFRCH () {
        CommunityUserManagementUtility.getTranslationsbyExpID('sageFRCH');
    }
    
    @isTest
    static void testTranslationsForENEU () {
        CommunityUserManagementUtility.getTranslationsbyExpID('sageENEU');
    }
    
    @isTest
    static void testGetErrorMessageforFrenchSpecificError () {
        CommunityUserManagementUtility.getErrorMessage('The passwords do not match.', 'brevilleFRCA');
    }
    
    @isTest
    static void testGetEmailTemplateNameForResetPassword () {
        CommunityUserManagementUtility.getEmailTemplateName(
            CommunityUserManagementUtility.EVENT_TYPE_RESET_PASSWORD, 'brevilleFRCA');
    }
    
    @isTest
    static void testGetEmailTemplateNameForVerifyEmail () {
        CommunityUserManagementUtility.getEmailTemplateName(
            CommunityUserManagementUtility.EVENT_TYPE_VERIFY_ACCOUNT, 'brevilleFRCA');
    }
    
    @isTest
    static void testGetEmailTemplateNameforApp () {
        CommunityUserManagementUtility.getEmailTemplateName(
            CommunityUserManagementUtility.EVENT_TYPE_VERIFY_ACCOUNT, 'AppENUS');
    }
}