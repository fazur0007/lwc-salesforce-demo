public class LightningResetPasswordByAgent {
    @AuraEnabled
    public static Map<String,Object> doResetPassword(String recordId)
    {
        List<User> listOfUsers = [SELECT Id,ContactId,Contact.AccountId,Exp_ID__c,languagelocalekey,Name,UserName,Email FROM 
                                  User Where (Contact.AccountId =:recordId OR ContactId =:recordId) AND User.Profile.Name='Breville External Identity' Limit 1];
        if(listOfUsers != null && listOfUsers.size() > 0)
        {
            User userObj = listOfUsers[0];
            String emailTemplateName = CommunityUserManagementUtility.getEmailTemplateName(
                CommunityUserManagementUtility.EVENT_TYPE_RESET_PASSWORD, userObj.Exp_ID__c);
            System.debug ('UserObj: ' + userObj);
            System.debug ('Email tempalte Config Name: ' + emailTemplateName); 
            ResetPasswordResult result = System.resetPasswordWithEmailTemplate(userObj.Id, true, emailTemplateName);
            System.debug ('Reset Password Result: ' + result);
            
            return new Map<String,Object>
            {
                'Result' => 'Success',
                    'UserDetails' => userObj
            };            
        }
        else
        {
            return new Map<String,Object>
            {
                'Result' => 'Error',
                    'UserDetails' => 'User does not exist or not a Breville External Identity user'
            };
        } 
        
    }
    @AuraEnabled
    public static Map<String,Object> doSendVerifyEmail(String recordId)
    {
        List<User> listOfUsers = [SELECT Id,ContactId,Contact.AccountId,Exp_ID__c,languagelocalekey,Name,UserName,Email,Send_Mail_Verification_Email__c FROM 
                                  User Where (Contact.AccountId =:recordId OR ContactId =:recordId) AND User.Profile.Name='Breville External Identity' Limit 1];
        if(listOfUsers != null && listOfUsers.size() > 0)
        {
            for(User userObj : listOfUsers)
            {
                userObj.Send_Mail_Verification_Email__c = true;
         	}
            update listOfUsers;
            return new Map<String,Object>
            {
                   'Result' => 'Success',
                       'UserDetails' => listOfUsers[0]
            };
         }
         else
         {
             return new Map<String,Object>
             {
                 'Result' => 'Error',
                     'UserDetails' => 'User does not exist or not a Breville External Identity user'
             };
         } 
    }
}