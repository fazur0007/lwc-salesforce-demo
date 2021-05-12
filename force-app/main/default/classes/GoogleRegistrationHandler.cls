/**
* @Author       : Fazurulla Ganganapalli (fazur.ganganapalli@breville.com)
* @Date         : 
* @Description  : This class GoogleRegistrationHandler is responsible for google login from AEM website.
* @Test Class   : GoogleRegistrationHandler_Test
* @log          :
* @Modification History :
* -------------------------------------------------------------------------------------------------------------------------------
* Developer            Date         Description                                                                 version
* -------------------------------------------------------------------------------------------------------------------------------
* Fazur G              04.10.2019    Newly created                                                                 V1.0

**/

global class GoogleRegistrationHandler implements Auth.RegistrationHandler{
    
    global boolean canCreateUser(Auth.UserData data) {
        //TODO: Check whether we want to allow creation of a user with this data
        //Set<String> s = new Set<String>{'usernamea', 'usernameb', 'usernamec'};
        if(string.isNotBlank(data.email)) {
            return true;
        }
        return false;
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        system.debug('Inside createuser');

        if(!canCreateUser(data)) {
            //Returning null or throwing an exception fails the SSO flow
            return null;
        }
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            System.debug('Registering Community user: ' + data.email);
            Id contactId;
            Account personAccount = createPersonAccount(data);         
            
            //List<User> lstUser = [select id from user where ContactId=:personAccountContactId];
            List<User> lstUser = [select id from user where email=:data.email];
            
            // Keeping it modular, we initialize the user in another method
            If(lstUser.size()>0)
            {
                String strExpId = 'BrevilleENUS';
                if(!Test.isRunningTest()) 
                    strExpId = site.getExperienceId();
                lstUser[0] = CommunityUserManagementUtility.FetchUserDefaults(lstUser[0],personAccount,strExpId,false);
                system.debug('User:'+lstUser[0]);
                return lstUser[0];
            }
            else
            {
                User u = createUser(data,personAccount);           
                system.debug('User:'+u);
                return u;
            }           
        } else {
            return null;
        }
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
       CommunityUserManagementUtility.SocialUpdateUser(userId,portalId,data);
    }
    
    /**
* Create a person account
* 
* @param data - Facebook provided context for the User
**/
    private Account createPersonAccount(Auth.UserData data) 
    {
        return CommunityUserManagementUtility.SocialGetAccountAttributes(data);		
    }
    
    /**
* Create and initialize the User but don't save it yet
* 
* @param data - the provided User context from FaceBook
* @param p - the Profile we are going to assign to this user
* 
* @return User that has been initialized but not Saved
**/
    private User createUser(Auth.UserData data,Account personAccount) 
    {
        return CommunityUserManagementUtility.SocialGetUserAttributes(data,personAccount);
    }
    
}