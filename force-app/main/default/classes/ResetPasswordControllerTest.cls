@IsTest(SeeAllData = true)
public with sharing class ResetPasswordControllerTest {
    @IsTest
    static void getCurrentUserConfig() {
        User userRec = ResetPasswordController.getCurrentUserConfig();
        System.assert(userRec != null);
    }
    @IsTest
    static void getTranslationsByExpID() {
        Map<String,String> translationMap = ResetPasswordController.getTranslationsByExpID('BrevilleENUS');
        System.assert(translationMap != null);
    }
}