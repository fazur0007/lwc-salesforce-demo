public class AsyncTriggerVerificationEmail implements Queueable {
    List<Id> lstUser {get;set;}

    public AsyncTriggerVerificationEmail(List<Id> userList)
    {       
        lstUser = userList;
    }
    public void execute(QueueableContext context) {
        List<User> lstUserToUpdate = new List<User>();
        for(User userObj : [select id,Exp_ID__c, Send_Mail_Verification_Email__c,Email_verification_network_Id__c,languagelocalekey from User where id=:lstUser]){
            system.debug('email triggered');
            if(userObj.Send_Mail_Verification_Email__c && String.isNotBlank(userObj.Email_verification_network_Id__c))
            {
                String emailTemplateName = CommunityUserManagementUtility.getEmailTemplateName(
                    CommunityUserManagementUtility.EVENT_TYPE_VERIFY_ACCOUNT,userObj.Exp_ID__c);
                System.debug ('Email Template Name: ' + emailTemplateName);
                
                if(!Test.isRunningTest())
                {
                    String emailTemplateId = '' + [select Id from EmailTemplate where DeveloperName = :emailTemplateName LIMIT 1].Id;
                    System.debug ('Email Template Name: ' + emailTemplateId);
                	System.UserManagement.sendAsyncEmailConfirmation(userObj.Id, emailTemplateId,userObj.Email_verification_network_Id__c, 
                                                                     '/s/emailconfirmationpage?userlocale='+userObj.languagelocalekey+'&usersfid='+userObj.Id);
                }
                userObj.Send_Mail_Verification_Email__c = false;
                lstUserToUpdate.Add(userObj);
            }
        }
        if(lstUserToUpdate.size()>0)
        {
            update lstUserToUpdate;
        }
    }
}