@isTest class LightningResetPasswordByAgentTest{
    @isTest public static void testDoResetPassword(){
        Id p = [select id from profile where name='Breville External Identity'].Id;
       
        Account ac = new Account(name ='Community User');
        insert ac; 
        
        Contact con = new Contact(LastName ='Community Contact',AccountId = ac.Id);
        insert con;  
                  
        User user = new User(
            alias = 'test123', 
            email='test123@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = p, 
            IsActive =true,
            ContactId = con.Id,
            timezonesidkey='America/Los_Angeles', 
            username='tester@noemail.com',
            Exp_ID__c ='Beanz'            
        );
        insert user;
        system.runAs(user) {
            LightningResetPasswordByAgent.doResetPassword(con.Id);
            LightningResetPasswordByAgent.doSendVerifyEmail(con.Id);
            user.Exp_ID__c = 'Breville';
            user.languagelocalekey ='fr_CA';
            update user;
            LightningResetPasswordByAgent.doResetPassword(con.Id);
            LightningResetPasswordByAgent.doSendVerifyEmail(con.Id);
            Contact con1 = new Contact(LastName ='Community Contact');
            insert con1;
            LightningResetPasswordByAgent.doResetPassword(con1.Id);
            LightningResetPasswordByAgent.doSendVerifyEmail(con1.Id);
        }
    }
}