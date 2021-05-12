/*
 * Test Classes: CommunityUserManagementUtilityTest, GoogleRegistrationHandler_Test, LightningSelfRegisterControllerTest
 * 
 */
public class CommunityUserManagementUtility {
    
    public static final String EVENT_TYPE_RESET_PASSWORD = 'ResetPassword';
    public static final String EVENT_TYPE_VERIFY_ACCOUNT = 'VerifyEmail';
    
    public static String getErrorMessage (String message, String experienceId) {
        
        String defaultErrorMessage, errorMessage;
        
        Map<String, String> translationsMap = getTranslationsbyExpID(experienceId, 'Password Error');
        defaultErrorMessage = translationsMap.get('Password Error Default');
        errorMessage = translationsMap.get(message);
        if (String.isBlank(errorMessage))
        {
            if (String.isBlank(defaultErrorMessage))
                return message;
            else
                return defaultErrorMessage;
        }
        else
            return errorMessage;
    }
    
    public static String getEmailTemplateName (String eventType, String strExpId) {
        String configName;

        strExpId = strExpId.removeEndIgnoreCase('signup');
        
        if (eventType.equalsIgnoreCase(EVENT_TYPE_RESET_PASSWORD))
            configName = 'ResetEmail_' + strExpId;
        else if (eventType.equalsIgnoreCase(EVENT_TYPE_VERIFY_ACCOUNT))
            configName = 'VerifyEmailTemplateName_' + strExpId;
        System.debug ('configName: ' + configName);    
        for (Customer_Community_Settings__mdt config: 
             [Select Id, DeveloperName, MasterLabel, Value__c FROM Customer_Community_Settings__mdt])
        {
            if (config.DeveloperName.equalsIgnoreCase(configName))
                return config.Value__c;
        }
        return null;
    }

    public static List<Community_Login_Translations__mdt> 
            getTranslationsConfig(String prefix, String suffix, String substring){
        String searchPattern;
        if (String.isNotBlank(prefix))
            searchPattern = prefix + '%';
        
        if (String.isNotBlank(suffix))
            searchPattern = '%' + suffix;

        if (String.isNotBlank(substring))
            searchPattern = '%' + substring + '%';
        
        if (String.isBlank(searchPattern))
            return [SELECT id, DeveloperName, MasterLabel, ENCA__c, FRCA__c, ENUS__c, ENGB__c, DEEU__c,
                ESEU__c, FREU__c, ITEU__c, NLEU__c, PTEU__c, ITCH__c, FRCH__c, DECH__c, ENEU__c, ESMX__c,
                ENAU__c, ENNZ__c,
                Name__c FROM Community_Login_Translations__mdt];
        else
            return [SELECT id, DeveloperName, MasterLabel, ENCA__c, FRCA__c, ENUS__c, ENGB__c, DEEU__c,
                ESEU__c, FREU__c, ITEU__c, NLEU__c, PTEU__c, ITCH__c, FRCH__c, DECH__c, ENEU__c, ESMX__c,
                ENAU__c, ENNZ__c,
                Name__c FROM Community_Login_Translations__mdt WHERE MasterLabel like :searchPattern];
    }

    public static Map<String,String> getTranslationsbyExpID(String experienceId, String searchPattern){
        System.debug ('getTranslationsByExpID: ' + experienceId);
        experienceId = String.isNotBlank(experienceId) ? experienceId : 'brevilleENUS';
        experienceId = experienceId.removeEndIgnoreCase('signup');
        String language = experienceId.right(4);
        Map<String,String> mapOfTranslations = new Map<String,String>();
        for(Community_Login_Translations__mdt clt : getTranslationsConfig(searchPattern, null, null))
        {
            String value = '';
            String defaultValue = '';
            switch on language {
                when 'FRCA' {
                    value = clt.FRCA__c;
                }
                when 'ENCA' {
                    value = clt.ENCA__c;
                }
                when 'ESEU' {
                    value = clt.ESEU__c;
                }
                when 'NLEU' {
                    value = clt.NLEU__c;
                }
                when 'PTEU' {
                    value = clt.PTEU__c;
                }
                when 'ESMX' {
                    value = clt.ESMX__c;
                } 
                when 'ENGB', 'ENEU' {
                    value = clt.ENGB__c;
                    if (language.equalsIgnoreCase('ENEU') && (clt.DeveloperName.equalsIgnoreCase('Breville_Company_URL') || 
                        clt.DeveloperName.equalsIgnoreCase('policyUrl') || 
                        clt.DeveloperName.equalsIgnoreCase('termsandconditionsUrl') ||
                        clt.DeveloperName.equalsIgnoreCase('Timezone') ||
                        clt.DeveloperName.equalsIgnoreCase('Locale') ||
                        clt.DeveloperName.equalsIgnoreCase('Currency_Code')))
                        value = clt.ENEU__c;

                }
                when 'DEEU', 'DECH' {
                    value = clt.DEEU__c;
                    if (language.equalsIgnoreCase('DECH') && (
                        clt.DeveloperName.equalsIgnoreCase('Breville_Company_URL') || 
                        clt.DeveloperName.equalsIgnoreCase('policyUrl') || 
                        clt.DeveloperName.equalsIgnoreCase('termsandconditionsUrl') ||
                        clt.DeveloperName.equalsIgnoreCase('Currency_Code')))
                        value = clt.DECH__c;
                }
                when 'FREU', 'FRCH' {
                    value = clt.FREU__c;
                    if (language.equalsIgnoreCase('FRCH') && (
                        clt.DeveloperName.equalsIgnoreCase('Breville_Company_URL') || 
                        clt.DeveloperName.equalsIgnoreCase('policyUrl') || 
                        clt.DeveloperName.equalsIgnoreCase('termsandconditionsUrl') ||
                        clt.DeveloperName.equalsIgnoreCase('Currency_Code')))
                        value = clt.FRCH__c;
                }
                when 'ITEU', 'ITCH' {
                    value = clt.ITEU__c;
                    if (language.equalsIgnoreCase('ITCH') && (
                        clt.DeveloperName.equalsIgnoreCase('Breville_Company_URL') || 
                        clt.DeveloperName.equalsIgnoreCase('policyUrl') || 
                        clt.DeveloperName.equalsIgnoreCase('termsandconditionsUrl') ||
                        clt.DeveloperName.equalsIgnoreCase('Currency_Code')))
                        value = clt.ITCH__c;
                }
                when 'ENAU', 'ENNZ' {
                    value = clt.ENUS__c;
                    if (clt.DeveloperName.equalsIgnoreCase('Breville_Company_URL') || 
                        clt.DeveloperName.equalsIgnoreCase('policyUrl') || 
                        clt.DeveloperName.equalsIgnoreCase('termsandconditionsUrl') ||
                        clt.DeveloperName.equalsIgnoreCase('Timezone') ||
                        clt.DeveloperName.equalsIgnoreCase('Locale') ||
                        clt.DeveloperName.equalsIgnoreCase('Currency_Code'))
                    {
                        if (language.equalsIgnoreCase('ENAU'))
                            value = clt.ENAU__c;
                        else
                            value = clt.ENNZ__c;
                    }
                }
                when else {
                    value = clt.ENUS__c;
                }
            }
            defaultValue = clt.ENUS__c;
            if (String.isBlank(value))
                value = defaultValue;
            if (String.isNotBlank(searchPattern) && String.isNotBlank(clt.Name__c))
                mapOfTranslations.put(clt.Name__c, value);
            else 
                mapOfTranslations.put(clt.DeveloperName, value);
        }
        System.debug ('GetTranslationsByExpID Map Size: ' + mapOfTranslations.size());
        return mapOfTranslations;
    }

    public static Map<String,String> getTranslationsbyExpID(String experienceId){
        return getTranslationsbyExpID (experienceId, null);
    }
 
    public static User getCurrentUserConfig(){
        System.debug ('Debug UserInfo:========= ' + UserInfo.getUserId() + '|' + UserInfo.getUserEmail() + '|' + UserInfo.getLanguage());
        return [Select Id,UserName,LanguageLocaleKey, Account.Automated_Portal_User_Created_From__c, Email,Name,Email_verification_network_Id__c,Exp_ID__c From User Where Id=:UserInfo.getUserId() Limit 1];
    }
    
    public static Account FetchAccountDefaults(Account CustAccount,string experienceId, Boolean isCreate)
    {
        Map<string,string> communitySettings = getCommunitySettings();
        Map<string,string> mapResult = GetUserAttributesFromExpId(experienceId);
        string strBrand;        
        strBrand = mapResult.get('Brand');        
        if(isCreate)
        {   
            CustAccount.CurrencyIsoCode = mapResult.get('Currency');
            CustAccount.RecordTypeId = [select id from recordtype where sobjecttype='Account' and Name='Person Account'].Id;
            if(String.isBlank(CustAccount.LastName))
            {
                if (strBrand.equalsIgnoreCase('beanz'))
                    CustAccount.LastName = communitySettings.get('Beanz_Customer_Default_Last_Name');                
                else
                    CustAccount.LastName = communitySettings.get('Person_Account_Last_Name');                                                  
            } 
        }
        /*else
        {
            Id commAdminId = [select Id,AdminId from site where name='Breville_Customer_Community'].AdminId;
            CustAccount.OwnerId = commAdminId;
            system.debug('commAdminId:'+commAdminId);
        }*/
        
        Id commAdminId = [select Id,AdminId from site where name='Breville_Customer_Community'].AdminId;
        CustAccount.OwnerId = commAdminId;
        
        if(String.isNotBlank(CustAccount.Customer_Portal_User__c))
        {
            system.debug('CustAccount.Customer_Portal_User__c:'+CustAccount.Customer_Portal_User__c);
            if(!CustAccount.Customer_Portal_User__c.containsIgnoreCase(mapResult.get('CustomerPortalUser')))
                CustAccount.Customer_Portal_User__c = CustAccount.Customer_Portal_User__c + ';' + mapResult.get('CustomerPortalUser');
        }
        else
            CustAccount.Customer_Portal_User__c = mapResult.get('CustomerPortalUser');
        
        if(string.isNotBlank(CustAccount.Marketing_Opt_In__c))
        {
            system.debug('CustAccount.Marketing_Opt_In__c:'+CustAccount.Marketing_Opt_In__c);
            if(!CustAccount.Marketing_Opt_In__c.containsIgnoreCase(strBrand))
                CustAccount.Marketing_Opt_In__c = CustAccount.Marketing_Opt_In__c + ';' + strBrand;
        }
        else
            CustAccount.Marketing_Opt_In__c = strBrand;
        system.debug('CustAccount.Marketing_Opt_In__c:'+CustAccount.Marketing_Opt_In__c);
        return CustAccount;
    }
    
    public static User FetchUserDefaults(User CommUser,Account userPersonalAccount,string experienceId, Boolean isCreate)
    {
        Map<string,string> communitySettings = getCommunitySettings();
        Map<string,string> mapResult = GetUserAttributesFromExpId(experienceId);
        CommUser.Exp_ID__c = mapResult.get('Expid');
        CommUser.LanguageLocaleKey = mapResult.get('Locale');
        CommUser.localesidkey = mapResult.get('Locale');
        CommUser.CurrencyIsoCode = mapResult.get('Currency');
        CommUser.DefaultCurrencyIsoCode = mapResult.get('Currency');
        CommUser.CurrencyIsoCode__c = mapResult.get('Currency');
        
        if(isCreate)
        {      
            CommUser.Account_ID__c = userPersonalAccount.Id;
            CommUser.ContactId = [select id,PersonContactId from account where id=:userPersonalAccount.Id].PersonContactId;
            CommUser.profileId = [select id,name from profile where name=:communitySettings.get('Customer_Profile')].Id;

			CommUser.FirstName = userPersonalAccount.FirstName;
            CommUser.LastName = userPersonalAccount.LastName;
            
            if(String.isBlank(CommUser.LastName))
            {
                if (mapResult.get('Brand').equalsIgnoreCase('beanz'))
                    CommUser.LastName = communitySettings.get('Beanz_Customer_Default_Last_Name');                
                else
                    CommUser.LastName = communitySettings.get('Person_Account_Last_Name');                                                  
            }

            if(communitySettings.get('User_Prefix')!=null  && string.Isnotblank(communitySettings.get('User_Prefix')))
            {
                CommUser.username = CommUser.email + communitySettings.get('User_Prefix');
            }
            else
            {
                CommUser.username = CommUser.email;
            }            
            String alias = 'br' + Integer.valueof((Math.random()*1000000));        
            //Alias must be 8 characters or less
            if (alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            CommUser.alias = alias;                
            CommUser.emailEncodingKey = 'UTF-8';
            CommUser.timeZoneSidKey = mapResult.get('Timezone');
            CommUser.profileId = [select id,name from profile where name=:communitySettings.get('Customer_Profile')].Id;
            CommUser.Email_verification_network_Id__c=Network.getNetworkId();
        }
        return CommUser;
    }
    
    public static Map<string,string> GetUserAttributesFromExpId(string experienceId)
    {
        Map<string,string> mapResult = new Map<string,string>();        
        string strExpId,strBrand,tempLocale,Locale,CustomerPortalUser,strCurrency,timezone;
        strExpId = experienceId.remove('signup');
        system.debug('strExpId:'+strExpId);
        mapResult.put('Expid',strExpId);
        strBrand = strExpId.substring(0, strExpId.length()-4);
        system.debug('strBrand:'+strBrand);
        mapResult.put('Brand',strBrand);

        Map<String,String> configMap = getTranslationsByExpId(strExpId);
        Locale = configMap.get('Locale');
        system.debug('Locale:'+Locale);
        mapResult.put('Locale',Locale);

        CustomerPortalUser = strBrand.toUpperCase() + strExpId.right(2).toUpperCase();
        system.debug('CustomerPortalUser:'+CustomerPortalUser);
        mapResult.put('CustomerPortalUser',CustomerPortalUser);
        strCurrency = configMap.get('Currency_Code');
        mapResult.put('Currency', strCurrency);
        mapResult.put('Timezone', configMap.get('Timezone'));

        system.debug('mapResult:'+mapResult);
        return mapResult;
    }
    
    private static Map<String,String> getCommunitySettings()
    {
        Map<String,String> mapCommunitySettings = new Map<String,String>();        
        for(Customer_Community_Settings__mdt ObjSetting:[select id,DeveloperName,Value__c from Customer_Community_Settings__mdt])
        {
            mapCommunitySettings.put(ObjSetting.DeveloperName,ObjSetting.Value__c);
        }
        return mapCommunitySettings;
    }
    
    public Static User SocialGetUserAttributes(Auth.UserData data,Account personAccount)
    {
        Boolean isCreate = true;
        String strExpId = 'BrevilleENUS';
        
        User u = new User();
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        if(!Test.isRunningTest())
            strExpId = Site.getExperienceId();
        
        u = FetchUserDefaults(u,personAccount,strExpId,isCreate);
        u.Email_verification_network_Id__c=data.attributeMap.get('sfdc_networkid');
        u.Community_Email_Verified__c = true;
        return u;
    }
    
    public Static Account SocialGetAccountAttributes(Auth.UserData data)
    {
        Boolean isCreate = true;
        String strExpId = 'BrevilleENUS';
        
        if(!Test.IsRunningTest())
            strExpId = site.getExperienceId();
        List<Account> lstAccount = [select id, FirstName, LastName, PersonContactId,Customer_Portal_User__c,Marketing_Opt_In__c from Account where (Email_External_ID__c=:data.email or personemail=:data.email)];
        if(lstAccount.size()>0)
        {
            isCreate = false;  
            lstAccount[0] = FetchAccountDefaults(lstAccount[0],strExpId,isCreate);
            lstAccount[0].Email_External_ID__c = data.email;
            update lstAccount[0];
            return lstAccount[0];
        }
        else
        {
            Account newAccount = new Account();
            newAccount.PersonEmail = data.email;
            newAccount.LastName = data.lastName;
            newAccount.FirstName = data.firstName;
            newAccount.Email_External_ID__c = data.email;
            newAccount = FetchAccountDefaults(newAccount,strExpId,isCreate);
            insert newAccount;
            Account FetchAccount = [select id,PersonContactId, FirstName, LastName from account where id=:newAccount.Id];
            return FetchAccount;
        }       
    }
    
    public static void SocialUpdateUser(Id userId, Id portalId, Auth.UserData data)
    {
        system.debug('Inside updateuser');
        String strExpId = 'BrevilleENUS';
        User u =  [select id,Account_Id__c from user where id=:userId];
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        u.Community_Email_Verified__c = true;
        u.Email_verification_network_Id__c = data.attributeMap.get('sfdc_networkid');
        
        if(!Test.isRunningTest()) 
            strExpId = site.getExperienceId();
        u = FetchUserDefaults(u,null,strExpId,false);
        update(u);
        Account CustAccount = [select id,Customer_Portal_User__c,Marketing_Opt_In__c from Account where id=:u.Account_Id__c];
        
        CustAccount = FetchAccountDefaults(CustAccount,strExpId,false);
        update CustAccount;
    }

    public static string getExperienceIdFromSite() 
    {
        string expId = 'BrevilleENUS';
        if(!Test.isRunningTest()) {
            expId = site.getExperienceId();
        }        
        return expId;
    } 
}