/**
* This is the controller class for Creating an account/Mybreville user from marketing cloud emails
*
* @author abhishek.namburi@breville.com.au
* @version 1.0
* @since November 12, 2020
*/
public without sharing class CreateAccountMarketingCloudController {
    public String updateStatus {get; set;}
    public String languageCode {get; set;}
    
    public CreateAccountMarketingCloudController() {
        languageCode = 'en';
        updateStatus = 'none';
    }
    
    public void init() {
        try {
            String id = apexpages.currentpage().getparameters().get('p');
            String source = apexpages.currentpage().getparameters().get('q');
            String brandencoded = apexpages.currentpage().getparameters().get('r');
            
            
            String sourceRecordId = EncodingUtil.base64Decode(id).toString();
            String usersource = EncodingUtil.base64Decode(source).toString();
            String brand = EncodingUtil.base64Decode(brandencoded).toString();
            string curAccountId;
            System.debug('id ' + sourceRecordId + ' email ' + usersource);
            
            if(usersource.equalsIgnoreCase('productregistration'))
                usersource = 'Post Product Registration Offer';
            
            if(usersource.equalsIgnoreCase('Post product purchase'))
            {
                curAccountId = [select id,AccountId from order where id=:sourceRecordId].AccountId;
            }
            else
                curAccountId = sourceRecordId;
            
            
            Account acc = [SELECT Id, Subscribe_to_our_newsletter__c, PreferredLanguage__c, MkgOptEmailSent__c,Customer_Portal_User__c FROM Account WHERE Id =:curAccountId LIMIT 1];
            if(acc != null) 
            {
                languageCode = Utility.getLanguageCodeFromLanguage(acc.PreferredLanguage__c);
                
                if(languageCode == NULL || languageCode == '') {
                    languageCode = 'en';
                }
                
                if(string.isNotBlank(acc.Customer_Portal_User__c))
                {
                    updateStatus = 'alreadyUpdated';
                    return;
                }
                
                EventBus.publish(new List<User_Registration__e>{
                            new User_Registration__e (
                                Account_ID__c = acc.Id, 
                                //Source__c = 'Post Product Registration Offer',
                                Source__c = usersource,
                                ExpId__c = 'brevilleENUS',
                                RecordId__c=sourceRecordId)
                    });
                updateStatus = 'updated';
            } 
            else 
            {
                updateStatus = 'wrongURL';
            }
            
        } 
        catch(Exception e) 
        {
            updateStatus = 'wrongURL';
        }
    }
}