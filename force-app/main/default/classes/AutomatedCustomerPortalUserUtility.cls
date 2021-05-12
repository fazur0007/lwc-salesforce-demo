public class AutomatedCustomerPortalUserUtility {
    public static String getNetworkID(String networkName) {
        List < Network > listOfNetWorks = [select id, name from Network Where Name =: networkName Limit 1];
        return listOfNetWorks != null && listOfNetWorks.size() > 0 ? listOfNetWorks.get(0).Id : Null;
    }
    public static Map < String, String > getCommunitySettings() {
        Map < String, String > mapCommunitySettings = new Map < String, String > ();
        for (Customer_Community_Settings__mdt ObjSetting: [select id, DeveloperName, Value__c from Customer_Community_Settings__mdt]) {
            mapCommunitySettings.put(ObjSetting.DeveloperName, ObjSetting.Value__c);
        }
        return mapCommunitySettings;
    }
    public static Account getAccountDetails(Set < String > setOfIDS) {
        return [SELECT Id, FirstName, LastName,
                PersonEmail, AccountSource, PreferredLanguage__c,
                Residential_Address__c, Agreed_for_Opt_in__c, Email_External_ID__c, PersonContact_SafeID__c
                FROM Account Where ID IN: setOfIDS
               ];
    }
    public static void userwithBrevilleExternalProfile(List < user > userWithBrevilleExternalIdentityProfile,  Map < String, User_Registration__e> mapOfAccountWithEvent,string RecordId)
    {        
        Account CustAccount = [select id, Customer_Portal_User__c, Marketing_Opt_In__c, PersonEmail, Email_External_ID__c from Account where Id =: userWithBrevilleExternalIdentityProfile.get(0).Account_Id__c];
        CustAccount = CommunityUserManagementUtility.FetchAccountDefaults(CustAccount, mapOfAccountWithEvent.get(CustAccount.Id).ExpId__c, false);
        string entrysource = mapOfAccountWithEvent.get(CustAccount.Id).Source__c;
        CustAccount = setWebOrdernumber(CustAccount,entrysource,RecordId);
        update CustAccount;
        
        userWithBrevilleExternalIdentityProfile[0] = CommunityUserManagementUtility.FetchUserDefaults(userWithBrevilleExternalIdentityProfile[0], CustAccount, mapOfAccountWithEvent.get(CustAccount.Id).ExpId__c, false);
        //Send promo code only for eligible users
        if(checkEligibilityForBeanzPromo(entrysource,RecordId))
            setUserDefaultForBeanzPromo(userWithBrevilleExternalIdentityProfile[0],entrysource,RecordId,false);        
        update userWithBrevilleExternalIdentityProfile[0];
    }
    
    /*public static void updateSourceOrderNumberOnContact(Id AccountId,string strSource,string strRecordId)
    {
        if(strSource.equalsIgnoreCase('Product purchase') || strSource.equalsIgnoreCase('Post product purchase'))
        {
            List<Contact> con = [select id from contact where accountid=:AccountId];
            if(con.size()>0)
            {
                List<Order> currOrder = [select id,WebSiteOrderId__c from order where Id=:strRecordId];
                //con[0].Source_order_number__c = currOrder.WebSiteOrderId__c;
                if(currOrder.size()>0)
                	update con[0];
            }
        }
        
    }*/
    
    public static void createUpdateUserwithPlatformEvent(Account userPersonalAccount, Map < String, User_Registration__e> mapOfAccountWithEvent,String RecordId) {
        Map < string, string > communitySettings = getCommunitySettings();
        String userName = (communitySettings.get('User_Prefix') != null && String.IsNotBlank(communitySettings.get('User_Prefix'))) ? userPersonalAccount.PersonEmail + communitySettings.get('User_Prefix') : userPersonalAccount.PersonEmail;
        List <User> userWithBrevilleExternalIdentityProfile = [SELECT Id, UserName, Account_Id__c FROM User WHERE UserName =: userName and Profile.Name =: communitySettings.get('Customer_Profile')];
        if (userWithBrevilleExternalIdentityProfile.size() > 0) {
            userwithBrevilleExternalProfile(userWithBrevilleExternalIdentityProfile,mapOfAccountWithEvent,RecordId);
        } 
        else 
        {
            List <User> userWithoutBrevilleExternalIdentityProfile = [SELECT Id, UserName, Account_Id__c FROM User WHERE UserName =: userName and Profile.Name !=: communitySettings.get('Customer_Profile')];
            if (userWithoutBrevilleExternalIdentityProfile.size() == 0) {
                Account CustAccount = [select Id, Customer_Portal_User__c, Marketing_Opt_In__c, PersonEmail, Email_External_ID__c from Account where Id =: userPersonalAccount.Id];
                CustAccount = CommunityUserManagementUtility.FetchAccountDefaults(CustAccount, mapOfAccountWithEvent.get(CustAccount.Id).ExpId__c, false);
                string entrysource = mapOfAccountWithEvent.get(CustAccount.Id).Source__c;
                CustAccount.Automated_Portal_User_Created_From__c=entrysource;
                //CustAccount.Source_order_number__c = RecordId;
                CustAccount = setWebOrdernumber(CustAccount,entrysource,RecordId);
                update CustAccount;
                //updateSourceOrderNumberOnContact(CustAccount.Id,entrysource,RecordId);
                User newuser = new User();
                Boolean isCreate = true;
                newuser.email = String.isNotBlank(CustAccount.PersonEmail) ? CustAccount.PersonEmail : CustAccount.Email_External_ID__c;
                newuser = CommunityUserManagementUtility.FetchUserDefaults(newuser, CustAccount, mapOfAccountWithEvent.get(CustAccount.Id).ExpId__c, true);
                newuser.FirstName = userPersonalAccount.FirstName;
                newuser.LastName  = userPersonalAccount.LastName;
                newuser.Email_verification_network_Id__c = getNetworkID('Breville Customer Community');
                newuser.Send_Mail_Verification_Email__c = false;
                Boolean isEligibleForBeanzOffer = checkEligibilityForBeanzPromo(entrysource,RecordId);
                if(isEligibleForBeanzOffer)
                    setUserDefaultForBeanzPromo(newuser,entrysource,RecordId,true);
                
                system.debug('CustAccount.Id:' + CustAccount.Id);
                insert newuser;                
                system.debug('newuser:'+newuser);
                ResetPasswordResult result = System.resetPasswordWithEmailTemplate(newuser.Id, true, getEmailTempalteName(entrysource,isEligibleForBeanzOffer));
            }
        }
    }
    
    public static string getEmailTempalteName(string entrysource,Boolean isEligibleForOffer)
    {
        string emailTemplateName;
        if(entrysource.equalsIgnoreCase('Post Product Registration Offer'))
            emailTemplateName = 'ResetPasswordEmail_BrevilleUS_ProductRegistration_withoutconsent';
        else if (isEligibleForOffer && entrysource.equalsIgnoreCase('Product purchase') )
            emailTemplateName = 'ResetPasswordEmail_BrevilleUS_ProductPurchase';
        else if (isEligibleForOffer &&  entrysource.equalsIgnoreCase('Post product purchase'))
            emailTemplateName = 'ResetPasswordEmail_BrevilleUS_ProductPostPurchase';
        else if (!isEligibleForOffer && entrysource.equalsIgnoreCase('Product purchase'))
            emailTemplateName = 'ResetPasswordEmail_BrevilleUS_ProductPurchase_AnySKU';
        else if (!isEligibleForOffer &&  entrysource.equalsIgnoreCase('Post product purchase'))
            emailTemplateName = 'ResetPasswordEmail_BrevilleUS_ProductPostPurchase_AnySKU';
        else
            emailTemplateName = 'ResetPasswordEmail_BrevilleUS_ProductRegistration';
        return emailTemplateName;
    }
    
    public static Account setWebOrdernumber(Account custAccount,string strSource,string strRecordId)
   	{
        if(strSource.equalsIgnoreCase('Product purchase') || strSource.equalsIgnoreCase('Post product purchase'))
        {
            List<Order> lstOrders = [select id,WebSiteOrderId__c from order where id=:strRecordId];
            if(lstOrders.size()>0)
            	custAccount.Source_order_number__c = lstOrders[0].WebSiteOrderId__c;
        }
        return custAccount;
    }
    
    public static void setUserDefaultForBeanzPromo(User newuser,string strSource,string strRecordId,Boolean isNewRecord)
    {

        newuser.Promo_Code_Record_Id__c = strRecordId;
        newuser.Number_of_Promo_codes_sent__c = 0;
        newuser.Promo_code_for__c = 'Beanz free bag';
        if(!isNewRecord)
        	newuser.Send_Promo_Code__c = true;
        if(strSource.equalsIgnoreCase('Product purchase') || strSource.equalsIgnoreCase('Post product purchase'))
        {
            newuser.Promo_code_for__c = 'Beanz free bag - Product purchase';
            //newuser.Web_Order_Number_Source__c = [select id,WebSiteOrderId__c from order where id=:strRecordId].WebSiteOrderId__c;
        }      
    }
    
    public static Boolean checkEligibilityForBeanzPromo(string strSource,string strRecordId)
    {
        Boolean isEligible = false;
        if(strSource.equalsIgnoreCase('Product Registration Offer')||strSource.equalsIgnoreCase('Post Product Registration Offer'))
        {
            isEligible = true;
        }
        else if(strSource.equalsIgnoreCase('Product purchase')||strSource.equalsIgnoreCase('Post product purchase'))
        {
            List<Order> objOrder = [select id,IsEligibleForPromo__c from Order where id=:strRecordId];
            if(objOrder.size()>0 && objOrder[0].IsEligibleForPromo__c)
                isEligible = true;
            else
            {
                Marketing_Promotion_Setting__mdt settingRecord = [select id,Value__c from Marketing_Promotion_Setting__mdt where developername='Products_Eligible_for_Beanz_Free_bag'];
                List<String> lstProducts = settingRecord.Value__c.Split(';');
                List<OrderItem> lstOrderItems = [select id,Ax_Item_number__c from OrderItem where OrderId=:strRecordId and Ax_Item_number__c=:lstProducts];
                if(lstOrderItems.size()>0)
                    isEligible = true;
            }
        }
        system.debug('strSource:'+strSource);
        system.debug('isEligible:'+isEligible);
        return isEligible;
    }
    
    public static void createUpdateUserPlatformEvent(Map < String, User_Registration__e> mapOfAccountWithEvent,string RecordId) {
        system.debug('mapOfAccountWithEvent:'+mapOfAccountWithEvent);
        Account userPersonalAccount = getAccountDetails(mapOfAccountWithEvent.keySet());
        createUpdateUserwithPlatformEvent(userPersonalAccount, mapOfAccountWithEvent,RecordId);
    }
    
    public static Boolean isBeanzUserToBeCreated(String exactOfferCode) {
        
        Boolean result = false;
        if (String.isNotBlank(exactOfferCode)) {
            String beanzOfferCodes = Utility.fetchAllLiteralValue('BeanzOfferCodes');
            Set<String> appliedOfferCodes = new Set<String> (exactOfferCode.split(';'));
            
            if (String.isNotBlank(beanzOfferCodes)) {
                Set<String> offerCodes = new Set<String>(beanzOfferCodes.split(';'));
                offerCodes.retainAll(appliedOfferCodes);
                if (offerCodes.size() > 0) {
                    result = true;
                }
            }
        }
        return result;
    }
}