/**
* @Author       : Fazurulla Ganganapalli (fazur.ganganapalli@breville.com)
* @Date         : 
* @Description  : This class FacebookRegistrationHandler is responsible for FaceBook login from AEM website.
* @Test Class   : FacebookRegistrationHandler_Test
* @log          :
* @Modification History :
* -------------------------------------------------------------------------------------------------------------------------------
* Developer            Date         Description                                                                 version
* -------------------------------------------------------------------------------------------------------------------------------
* Fazur G              04.10.2019    Newly created                                                                 V1.0

**/
global class FacebookRegistrationHandler implements Auth.RegistrationHandler {
    
    
    /**
    * Let anyone register as long as the required fields are supplied
    * 
    * We require email, lastName, firstName
    * 
    * @data - the user's info from the Auth Provider
    **/
    global boolean canCreateUser(Auth.UserData data) {
        system.debug('User Info ::' + JSON.serializePretty(data));
        System.debug('canCreateUser was called for ' + (data != null ? data.email : 'null'));
        Boolean retVal = (data != null && string.IsNotBlank(data.email));
        
        System.debug('data.username=' + data.username);
        System.debug('data.email=' + data.email);
        System.debug('data.lastName=' + data.lastName);
        System.debug('data.firstName=' + data.firstName);
        
        return retVal;
    }
    
    /**
    * Create the User - A required method to implement the Handler Interface
    * 
    * @param portalId  - Id of the Community
    * @param data - Auth Provider user data describing the User to create
    * 
    * @return User that has been initialized
    **/
    global User createUser(Id portalId, Auth.UserData data) {
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
    
    /**
    * Update the user
    * @param portalId  - Id of the Community
    * @param data - Auth Provider user data describing the User to create
    **/
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
      CommunityUserManagementUtility.SocialUpdateUser(userId,portalId,data);
    }
    
    /**
    * Create a person account
    * 
    * @param data - Facebook provided context for the User
    **/
    public Account createPersonAccount(Auth.UserData data) {
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