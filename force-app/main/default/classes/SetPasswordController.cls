/*
 * @Dev : Fazurulla Ganganapalli
 * @Purpose : External user will reset his/her password using this controller
 * Example code for Breville
 * Comments provide general guidance on how you could use the expid ID to perform a redirect after the change password process
 * This controller does not include error handling, error messaging, or unit tests, these items should be added. 
 */
public class SetPasswordController {
    public String newPassword {get;set;}
    public String verifyNewPassword {get;set;}
    public boolean showpassword {get;set;}
    public String dynamicLogo  {get;set;}
    
    public boolean hidePasswordIcon {get;set;}
    public boolean hideConfirmPasswordIcon {get;set;}
    
    public string passwordPlaceHolder {get;set;}
    public string confirmPasswordPlaceHolder {get;set;}
    public string passwordLabel {get;set;}
    public string confirmPasswordLabel {get;set;}
    public string saveNewPassword {get;set;}
    public string errorMessage {get;set;}
    public Boolean showError {get;set;}
    public string Min_6_characters_1_number {get;set;}
    public string passwordStrengthLabel {get;set;}
    public User usr {get;set;}
    
    //css properties 
    public string saveNewPasswordCss {get;set;}
    public string cssForBriefText {get;set;}
    
    public SetPasswordController() {
        showpassword = false;
        showError = false;
        dynamicLogo  = '';
    }
    public void doInitActions(){        
        showError = false;
        usr = [Select Id,Name,LanguageLocaleKey,Exp_ID__c,FirstName, LastName, EMail, Username,Number_of_Promo_codes_sent__c,Send_Promo_Code__c From User Where Id =: UserInfo.getUserId()];
        String expId = String.isNotBlank(usr.Exp_ID__c) ? usr.Exp_ID__c : 'brevilleENUS';
        expId.removeEnd('signup');
        tranlsationUtil(expId.right(4).toUpperCase());
        appConfiguration(expId);
    }
    public void appConfiguration(String experience){
        if(experience.containsIgnoreCase('app')){
            dynamicLogo  = 'app';
            saveNewPasswordCss  = 'sfdc_button_app';
            passwordStrengthLabel = 'PasswordStreStyle_app';
            cssForBriefText = 'PasswordStreStyle_app';
        }else if(experience.containsIgnoreCase('beanz')){
            passwordLabel = '';
            confirmPasswordLabel = '';
            dynamicLogo = 'beanz';
            saveNewPasswordCss  = 'sfdc_button_beanz';
            passwordStrengthLabel = 'PasswordStreStyle_beanz';
            cssForBriefText = 'PasswordStreStyle_beanz'; 
        }else{
            if (experience.containsIgnoreCase('sage'))
                dynamicLogo = 'Sage';
            else
                dynamicLogo = 'Breville';
            saveNewPasswordCss  = 'sfdc_button_breville';
            passwordStrengthLabel = 'PasswordStreStyle_breville';
            cssForBriefText = 'PasswordStreStyle_breville'; 
        } 
    }
    public void tranlsationUtil(String expId){
        Map<String, String>  transMap = CommunityUserManagementUtility.getTranslationsbyExpID(expId); 
        if(transMap.size() > 0){
            confirmPasswordLabel  = transMap.get('setPasswordconfirmPasswordLabel');
            confirmPasswordPlaceHolder  = transMap.get('SetPasswordconfirmPasswordPlaceHolder');
            passwordLabel  = transMap.get('setPasswordpasswordLabel');
            passwordPlaceHolder = transMap.get('SetPasswordpasswordPlaceHolder');
            saveNewPassword   = transMap.get('setPasswordsaveNewPassword');
            Min_6_characters_1_number = transMap.get('Min_6_characters_1_number');
        } 
    }
    
    public PageReference setPassword() { 
        try {
            showError = false;
            PageReference ref =  Site.ChangePassword(newPassword, verifyNewPassword, null);
            for (ApexPages.Message msg : ApexPages.getMessages())
            {
                System.debug ('Message: ' + msg.getSeverity() + ' ' + msg.getSummary());
                if (msg.getSeverity() == ApexPages.Severity.FATAL || msg.getSeverity() == ApexPages.Severity.ERROR)
                {
                    errorMessage = msg.getSummary();//CommunityUserManagementUtility.getErrorMessage(msg.getSummary(), usr.Exp_ID__c);
                    showError = true;
                    return null;
                }
            }
            if(usr.Number_of_Promo_codes_sent__c==null)
                usr.Number_of_Promo_codes_sent__c=0;
            User currUser = new User();
            currUser.Id = UserInfo.getUserId();
            currUser.Community_Email_Verified__c = true;
            currUser.Send_Mail_Verification_Email__c = false;
            if(usr.Number_of_Promo_codes_sent__c==0)
                currUser.Send_Promo_Code__c = true;
            update currUser;
           
            ref = new PageReference(Site.getBaseSecureUrl() + '/s/passwordresetsuccess');
            ref.setRedirectCode(301);
            ref.setRedirect(true);
            return ref;
        }catch (Exception ex) {
            errorMessage = ex.getMessage();
            showError = true;
            System.debug('setPasswordController::setPassword::Error Message: ' + errorMessage);
            return null;
        }
    }
}