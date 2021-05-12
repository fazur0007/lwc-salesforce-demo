/**
* This is the controller class for Marketing Opt In scenario
*
* @author deepak_tomar@persistent.com
* @version 1.0
* @since April 5, 2018
*/

public without sharing class MarketingOptInController {
    public String updateStatus {get; set;}
    public String languageCode {get; set;}
    
    public MarketingOptInController() {
        languageCode = 'en';
        updateStatus = 'none';
    }

    public void init() {
        try {
            String id = apexpages.currentpage().getparameters().get('p');
            String email = apexpages.currentpage().getparameters().get('q');
            
            
            String accountId = EncodingUtil.base64Decode(id).toString();
            String accountEmail = EncodingUtil.base64Decode(email).toString();

            System.debug('id ' + accountId + ' email ' + accountEmail);
            
            accountId = getAlternateIds(accountEmail, accountId);
                        
            system.debug('After method:' + accountId );
            Account acc = [SELECT Id, Subscribe_to_our_newsletter__c, PreferredLanguage__c, MkgOptEmailSent__c FROM Account WHERE Id =: accountId  AND PersonEmail =: accountEmail LIMIT 1];
            if(acc != null) {
                languageCode = Utility.getLanguageCodeFromLanguage(acc.PreferredLanguage__c);
                
                if(languageCode == NULL || languageCode == '') {
                   languageCode = 'en';
                }
                
                if(acc.Subscribe_to_our_newsletter__c == true) {
                    updateStatus = 'alreadyUpdated';
                    return;
                }

                Long mailSentDateMS = acc.MkgOptEmailSent__c.getTime();
                Long nowDateMS = DateTime.now().getTime();
                system.debug('mailSentDateMS ' + mailSentDateMS + ' nowDateMS ' + nowDateMS);
                Long diffHours = (nowDateMS - mailSentDateMS) / (3600000);
                system.debug('diffHours ' + diffHours);

                if(diffHours <= 14 * 24) {
                    acc.Subscribe_to_our_newsletter__c = true;
                    acc.MkgOptEmailSent__c = null;
                    updateStatus = 'updated';
                    update acc;
                } else {
                    updateStatus = 'expiredLink';
                }
            } else {
                updateStatus = 'wrongURL';
            }

        } catch(Exception e) {
            system.debug('stack trace:' + e.getStackTraceString());
            updateStatus = 'wrongURL';
        }
    }
    
    private static String getAlternateIds(String email, String oldId) {
        String result = oldId;
        List<Subscription_Account_Id_Mapping__mdt> mapping = [SELECT Email__c, Id1__c, Id2__c FROM Subscription_Account_Id_Mapping__mdt WHERE Email__c = :email LIMIT 1];
        if (String.isNotBlank(oldId) && mapping.size()>0 && oldId == mapping[0].Id1__c ) {
            result = mapping[0].Id2__c;
        }
        return result;
    }
}