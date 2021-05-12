public class UserTriggerHandler {

    @TestVisible private static boolean beforeTriggerRun = true;
    @TestVisible private static boolean afterTriggerRun = true;
    
    public static boolean runOnceBeforeTrigger(){
        if(beforeTriggerRun){
            beforeTriggerRun = false;
            return true;
        }else{
            return beforeTriggerRun;
        }
    }
    
    public static boolean runOnceAfterTrigger(){
        if(afterTriggerRun){
            afterTriggerRun = false;
            return true; 
        }else{
            return afterTriggerRun;
        }
    }
    
    public static void populateCustomCurrencyISOCode(List<User> userList, Map<Id,User> triggerOldMap){
        for(User user : userList){
            if(Trigger.isInsert || (Trigger.isUpdate && user.DefaultCurrencyIsoCode != triggerOldMap.get(user.Id).DefaultCurrencyIsoCode)){
                user.CurrencyISOCode__c = user.DefaultCurrencyIsoCode;
            }
        }
    }
    
    public static string GetExternalIdentityProfileId()
    {
        String brevilleExternalProfileId;
        List<Customer_Community_Settings__mdt> externalProfileName = [select Value__c from Customer_Community_Settings__mdt where Developername='Customer_Profile'];
        if(externalProfileName.size()>0)
        {
            List<Profile> lstProfiles = [select id from Profile where name=:externalProfileName[0].Value__c];
            if(lstProfiles.size()>0)
                brevilleExternalProfileId = lstProfiles[0].Id;
        }
        return brevilleExternalProfileId;
    }
    
    /* to get partner user profile from custom metadata */	
    public static string GetPartnerProfileId()	
    {	
        System.debug('enter in GetPartnerProfileId');	
        String brevilleProfileId;	
        List<Customer_Community_Settings__mdt> partnerName = [select Value__c from Customer_Community_Settings__mdt where Developername='Breville_Partner'];	
        System.debug('partnerName===='+partnerName);	
        if(partnerName.size()>0)	
        {	
            List<Profile> lstProfiles = [select id from Profile where name=:partnerName[0].Value__c];	
            System.debug('lstProfiles----'+lstProfiles);	
            if(lstProfiles.size()>0)	
                brevilleProfileId = lstProfiles[0].Id;	
        }	
        System.debug('brevilleProfileId----'+brevilleProfileId);	
        return brevilleProfileId;	
    }	
    /* assign new patner user to specific curency group based on currency */	
    public static void assignPartnerToGroup(List<User> users){ 	
        Id strPartnerProfile = GetPartnerProfileId();	
        List<Id> userListToCheck = new List<Id>();	
                        	
        for(User user: users){	
            if(user.ProfileId == strPartnerProfile ){	
                userListToCheck.add(user.Id);	
            }	
        }	
        if(userListToCheck.size() > 0){	
            updateUser(userListToCheck);	
        }               	
    }	
    // future method to upsert user	
    @future	
    public static void updateUser(List<Id> user) {	
        List<User> usrList = [select id,ProfileId,Name,CurrencyISOCode__c from User where Id=:user];	
        List<GroupMember> gmList=new List<GroupMember>();        	
        List<Currency_Group__mdt> CurrencyGroup = [select Currency__c,Group_Name__c from Currency_Group__mdt];	
       	
        Map<String, Currency_Group__mdt> currencyMDT = new Map<String, Currency_Group__mdt>();	
        List<String> groupName=new List<String>();	
        for(Currency_Group__mdt cur:CurrencyGroup){	
            currencyMDT.put(cur.Currency__c, cur);  	
            groupName.add(cur.Group_Name__c);	
        }	
        List<Group> grp=[SELECT Id, Name, DeveloperName, Type, OwnerId FROM Group where DeveloperName IN : groupName]; 	
        Map<String,Group> nameVsGroup=new Map<String, Group>();	
        for(Group gp:grp){	
         nameVsGroup.put(gp.DeveloperName,gp);   	
        }	
        for(User usr : usrList){	
            if(currencyMDT.containsKey(usr.CurrencyISOCode__c )){     	
                GroupMember gm= new GroupMember(); 	
                gm.GroupId = nameVsGroup.get(currencyMDT.get(usr.CurrencyISOCode__c).Group_Name__c).id;	
                gm.UserOrGroupId = usr.Id;	
                gmList.add(gm);	
            }            	
        }   	
            if(gmList.size() > 0){	
            insert gmList;	
            }	
        }               
    
    public static void assignToRegionSpecificPublicGroup(list<User> userList, Map<Id,User> triggerOldMap){
        
        //Internal User variables
        Map<Id, String> userIdToOldCurrencyMap = new Map<Id, String>();
        Map<Id, String> userIdToNewCurrencyMap = new Map<Id, String>();
        Set<String> internalUserCurrencyCodeSet = new Set<String>();        
        
        //External User variables
        Map<Id, String> externalUserIdToOldCurrencyMap = new Map<Id, String>();
        Map<Id, String> externalUserIdToNewCurrencyMap = new Map<Id, String>();
        Set<String> externalUserCurrencyCodeSet = new Set<String>();
        
        String strExternalIdenProfile = GetExternalIdentityProfileId();
        for(User user : userList){
            if(!user.IsPortalEnabled){
                if(Trigger.isInsert && user.DefaultCurrencyIsoCode != null){
                    userIdToNewCurrencyMap.put(user.Id, user.DefaultCurrencyIsoCode);
                    internalUserCurrencyCodeSet.add(user.DefaultCurrencyIsoCode);
                }else if(Trigger.isUpdate && user.DefaultCurrencyIsoCode != triggerOldMap.get(user.Id).DefaultCurrencyIsoCode){
                    if(user.DefaultCurrencyIsoCode != null){
                        userIdToNewCurrencyMap.put(user.Id, user.DefaultCurrencyIsoCode);
                        internalUserCurrencyCodeSet.add(user.DefaultCurrencyIsoCode);
                    }
                    if(triggerOldMap.get(user.Id).DefaultCurrencyIsoCode != null){
                        userIdToOldCurrencyMap.put(user.Id, triggerOldMap.get(user.Id).DefaultCurrencyIsoCode);
                        internalUserCurrencyCodeSet.add(triggerOldMap.get(user.Id).DefaultCurrencyIsoCode);
                    }
                }
            }else{
                if(String.IsNotBlank(strExternalIdenProfile) && user.ProfileId == strExternalIdenProfile)
                    continue;
                
                if(Trigger.isInsert && user.DefaultCurrencyIsoCode != null){
                    externalUserIdToNewCurrencyMap.put(user.Id, user.DefaultCurrencyIsoCode);
                    externalUserCurrencyCodeSet.add(user.DefaultCurrencyIsoCode);

                }else if(Trigger.isUpdate && user.DefaultCurrencyIsoCode != triggerOldMap.get(user.Id).DefaultCurrencyIsoCode){
                    if(user.DefaultCurrencyIsoCode != null){
                        externalUserIdToNewCurrencyMap.put(user.Id, user.DefaultCurrencyIsoCode);
                        externalUserCurrencyCodeSet.add(user.DefaultCurrencyIsoCode);
                    }
                    if(triggerOldMap.get(user.Id).DefaultCurrencyIsoCode != null){
                        externalUserIdToOldCurrencyMap.put(user.Id, triggerOldMap.get(user.Id).DefaultCurrencyIsoCode);
                        externalUserCurrencyCodeSet.add(triggerOldMap.get(user.Id).DefaultCurrencyIsoCode);
                    }
                    
                }
            }
        }
        
        if(internalUserCurrencyCodeSet != null && internalUserCurrencyCodeSet.size() > 0){
            System.enqueueJob(new AddRemoveUserToGroup(userIdToOldCurrencyMap, userIdToNewCurrencyMap, internalUserCurrencyCodeSet)); 
        }
        if(!Test.isRunningTest() && externalUserCurrencyCodeSet != null && externalUserCurrencyCodeSet.size() > 0){
            System.enqueueJob(new AddRemoveExternalUserToGroup(externalUserIdToOldCurrencyMap, externalUserIdToNewCurrencyMap, externalUserCurrencyCodeSet));
        }
    }
    
    public static void shareChildAccountWithParentUser(list<User> newUserRecord){
        
        map<Id,Id> parentAccountUserMap = new map<Id,Id>();
        map<Id,list<Account>> parentChildAccountMap = new map<id,list<Account>>();
        List<AccountShare> sharesToCreate = new List<AccountShare>();
        
        for(User userRecord : newUserRecord){
            if(userRecord.AccountId != NULL){
                parentAccountUserMap.put(userRecord.AccountId, userRecord.Id);
            }
        }
        if(parentAccountUserMap.size() > 0){
            for(Account accountRecords : [Select Id, ParentId from Account where ParentId IN: parentAccountUserMap.keySet()]){
                if(parentChildAccountMap.containsKey(accountRecords.ParentId)){
                    parentChildAccountMap.get(accountRecords.ParentId).add(accountRecords);
                }else{
                    parentChildAccountMap.put(accountRecords.ParentId, new list<Account>{accountRecords});
                }
            }
        }
        if(parentChildAccountMap.keySet() != null && parentChildAccountMap.size() > 0){
            for(User user : newUserRecord){
                for(Account childAccount : parentChildAccountMap.get(user.AccountId)){
                    sharesToCreate.add(Utility.createUserShare(childAccount.Id, user.Id));
                }
            }
        }
        if(sharesToCreate.size() > 0){
            Database.SaveResult[] srList = Database.insert(sharesToCreate, false);

            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    ErrorLog.logAdditionalErrorInfo('Successfully shared child account with parent user. Account ID: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        //ErrorLog.logErrorActivity(err, err.getStatusCode() + ': ' + err.getMessage() ,true, 'Error');
                    }
                }
            }
        }
    }
        
    public static void updateUserProfileToAccount(List<User> userList, Map<Id,User> triggerOldMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        list<User> sortedUserList = new list<User>();
        Id myBrvProfileId = GetExternalIdentityProfileId();
        
        if (triggerOldMap == null)
            return;
        
        for(User recUser : userList){
            User usrOldRec = triggerOldMap.get(recUser.Id);
            System.debug ('Profile ID: ' + myBrvProfileId); 
            System.debug ('User Profile ID: ' + recUser.ProfileId); 
            if(recUser.isPortalEnabled && usrOldRec != null && recUser.ProfileId != myBrvProfileId && 
                    (recUser.FirstName != usrOldRec.FirstName || recUser.LastName != usrOldRec.LastName)){
                accountIdSet.add(recUser.AccountId);
                sortedUserList.add(recUser);
            }
        }
        if (accountIdSet.IsEmpty())
            return;
        
        map<Id,Account> nameMap = new map<Id,Account>([Select Id, FirstName, Lastname, IsPersonAccount from Account 
                                                           where Id in :accountIdSet AND IsPersonAccount = true]);
        if (!Test.isRunningTest())
            System.enqueueJob(new UpdateUserProfileToAccount(sortedUserList, nameMap));

    }
    
    public static void emailVerificationProcess(List<User> userList,  Map<Id,User> triggerOldMap){
        List<Id> userListToTriggerEmail = new List<Id>();
        for(User userObj : userList){
            system.debug('email triggered:'+userObj.Send_Mail_Verification_Email__c + 'Test:' + userObj.Email_verification_network_Id__c);
             if(userObj.Send_Mail_Verification_Email__c&& String.isNotBlank(userObj.Email_verification_network_Id__c)){
                 //System.UserManagement.sendAsyncEmailConfirmation(userObj.Id, '',userObj.Email_verification_network_Id__c, 'https://abhisb-brevilleusa.cs78.force.com/reg/EmailConfirmationPage');
                 //system.debug('email triggered***************'+userObj.Id);
                 userListToTriggerEmail .Add(userObj.Id);
             }
        }
        if(userListToTriggerEmail .size()>0)
        {
            AsyncTriggerVerificationEmail obj = new AsyncTriggerVerificationEmail(userListToTriggerEmail );
            ID jobID = System.enqueueJob(obj);
            system.debug('jobID:'+jobID);
        }
        
    }

}