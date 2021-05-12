/** 
* This is a utility class that contains functions that will be used
* in multiple classes.
* Version       Author                    Date            Description 
*  1.0        james@highondemand.com     December 20, 2012        Initial Draft 
*  2.0        Payal Yadav                08/10/2016               Initial Draft 
*/
public without sharing class Utility {
    
    public static AccountShare createUserShare(Id accountId, Id userOrGroupId){
        AccountShare share = new AccountShare();
        
        share.AccountAccessLevel = 'Edit';
        share.AccountId = accountId;
        share.RowCause = 'Manual';
        share.UserOrGroupId = userOrGroupId;
        share.OpportunityAccessLevel = 'Edit';
        
        return share;
    }
    
    /**
* Extract and return values from an Id field.
*
* @param objs List of any sObject type.
* @param fieldName Full API name of a field on the sObject type.
* @return A possibly empty set of ids, with null removed.
*/
    public static Set<Id> extractIds(sObject[] objs, String fieldName) {
        
        Set<Id> result = new Set<Id>();
        for (sObject obj : objs) {
            result.add((Id) obj.get(fieldName));
        }
        result.remove(null);
        return result;
    } 
    
    /**
* Extract and return values from an Id field.
*
* @param objects   List of any sObject type.
* @param fieldName Full API name of a field on the sObject type.
* @return A possibly empty set of ids, with null removed.
*/
    public static Set<String> extractStrings (List<sObject> objects, String fieldName) {
        Set<String> result = new Set<String>();
        for (sObject obj : objects) {
            result.add((String) obj.get(fieldName));
        }
        result.remove(null);
        return result;
    }
    
    /**
* Validates an incoming email using a regular expression.
*
* @param email        The email to be validated.
* @return                    If the email passes the match returns true else returns false.
*/
    public static boolean isValidEmail(String email){
        String emailRegex =  '^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if(!MyMatcher.matches()){
            return false;
        }else{
            return true;
        }
    }
    
    /*       
@isTest(SeeAllData=true)
static void testAll(){
TestObjects to = new TestObjects();
Account acct = to.getAccount(true);
Account[] accounts = new Account[0];
accounts.add(acct);
Utility.extractIds(accounts, 'id');
Utility.extractStrings(accounts, 'Name');
Utility.isValidEmail('james@highondemand.com');
}
*/       
    
    
    
    public static List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val) {
        
        List<selectOption> options = new List<selectOption>(); 
        if (first_val != null) { 
            
            options.add(new selectOption(first_val, first_val));
            
        }
        Schema.sObjectType sobject_type = object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pick_list_values) { 
            
            options.add(new selectOption(a.getValue(), a.getLabel())); 
            
        }
        return options; 
    }
    public static void sendTemplateEmail(list<User> userList,  String templateApiName,  Id whatId, 
                                         Boolean saveAsActivity, String orgwideIdByEmailAddress ) {
                                             //  templateId   must be ID of an Email template
                                             //  targetObjId must be a Contact, User, Lead Id -- also used in merge fields of template recipient.xxxx
                                             //  whatId    must be an SObject that is used in the merge fields of the template relatedTo.xxxx
                                             //  fromId    if non null, use current user, otherwise, use this ID (most likely an org wide no reply id)
                                             //  bcc      not permitted when using templates
                                             Id orgWideEmailId;
                                             Messaging.SingleEmailMessage[] singleEmailMessages = new list<Messaging.SingleEmailMessage>();
                                             if(orgwideIdByEmailAddress != null){
                                                 list<OrgWideEmailAddress>  emailAddressList = [select id, Address from OrgWideEmailAddress 
                                                                                                where Address =: orgwideIdByEmailAddress];
                                                 if(emailAddressList != null && emailAddressList.size() > 0 ){
                                                     orgWideEmailId = emailAddressList[0].id;
                                                 }
                                             }
                                             Id templateId;  
                                             try {
                                                 templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
                                             }
                                             catch (Exception e) {
                                                 System.debug('Error while fetching template Id: ' + e);
                                                 ErrorLog.logErrorActivity(e, 'Error while fetching template Id: Utility - sendTemplateEmail', true); 
                                             }
                                             for(User user : userList){
                                                 Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                                 email.setTargetObjectId(user.id);
                                                 email.setWhatId(whatId);
                                                 //email.setTreatTargetObjectAsRecipient(true);
                                                 email.setorgWideEmailAddressId(orgWideEmailId);
                                                 if(whatId != null){
                                                     email.setWhatId(whatId);
                                                 }
                                                 if(templateId  != null){
                                                     email.setTemplateId(templateId);
                                                 }
                                                 email.setSaveAsActivity(saveAsActivity);
                                                 singleEmailMessages.add(email);
                                             }
                                             try {
                                                 Messaging.sendEmail(singleEmailMessages);
                                                 return;
                                             }
                                             catch (EmailException e) {
                                                 System.debug('Error while sending email: ' + e);
                                                 ErrorLog.logErrorActivity(e, 'Error while sending email: Utility - sendTemplateEmail', true);                                                 
                                             }
                                             
                                             
                                         } 
    
    /*
Method Name  : currencyBasedRegions
Description  : This method is used in QCLocationTriggerHandler class on region basis the currency is set and by default it is returing USD currency for every QC loction
Created Date : 08/12/2016
*/
    public static String currencyBasedRegions(String region){
        if(region != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT DeveloperName, Currency__c FROM Region_Specific__mdt 
                                                                     WHERE DeveloperName =: region 
                                                                     AND Currency__c != NULL 
                                                                     LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Currency__c;
            }
        }
        return Label.Default_Currency;
    }
    
    public static String fetchCurrencyCodeFromEPRegion(String epRegionCode){
        if(epRegionCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, Currency__c FROM Region_Specific__mdt 
                                                                     WHERE EPParameter__c =: epRegionCode 
                                                                     AND Currency__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Currency__c;
            }
        }
        return Label.Default_Currency;
    }
    
    public static String fetchBusinessUnitEPRegion(String epRegionCode){
        if(epRegionCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, Business_Unit__c FROM Region_Specific__mdt 
                                                                     WHERE EPParameter__c =: epRegionCode 
                                                                     AND Business_Unit__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Business_Unit__c;
            }
        }
        return Label.Default_businessUnit;
    }
    
    public static String fetchBusinessUnitFromCurrencyCode(String currencyCode){
        if(currencyCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, Business_Unit__c FROM Region_Specific__mdt 
                                                                     WHERE Currency__c =: currencyCode 
                                                                     AND Business_Unit__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Business_Unit__c;
            }
        }
        return Label.Default_businessUnit;
    }
    
    public static String fetchRegionCodeFromEPRegion(String epRegionCode){
        if(epRegionCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, DeveloperName FROM Region_Specific__mdt WHERE EPParameter__c =: epRegionCode LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
                return RegionSpecificCurrencyCode[0].DeveloperName;
            }
        }
        return Label.Default_Region;
    }
    
    public static String regionBased(String  CurrencyIsoCode){
        if(CurrencyIsoCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT DeveloperName, Currency__c FROM Region_Specific__mdt WHERE Currency__c =: CurrencyIsoCode LIMIT 1];
            
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
                return RegionSpecificCurrencyCode[0].DeveloperName;
            }
        }
        return Label.Default_Region;
    }
    
    public static String fetchLanguageCodeFromCountryCode(String  CurrencyIsoCode){
        if(CurrencyIsoCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT LanguageCode__c, Currency__c FROM Region_Specific__mdt 
                                                                     WHERE Currency__c =: CurrencyIsoCode 
                                                                     AND LanguageCode__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
                return RegionSpecificCurrencyCode[0].LanguageCode__c;
            }
        }
        return Label.Default_LanguageCode;
    }
    
    public static boolean validateEmail(String personEmail, String confirmEmail){
        if(personEmail == confirmEmail){
            if(Utility.isValidEmail(personEmail)){
                return true;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Invalid_Email_Address));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Email_Dont_Match));
        }
        return false;
    }
    
    /*public static List<SelectOption> fetchProductSubcategories(String countryCode, String additionalCondition, List<String> classificationList){

List<SelectOption> subcategoriesList = new List<SelectOption>();
subcategoriesList.add(new SelectOption('', Label.Default_Picklist_Value));

//list<String> classificationList = new List<String>{'C', 'D', 'E', 'F', 'R', 'S'};
String query = 'SELECT Product_Sub_Family__c subCategory ' +
' FROM Product2 ' +
'  WHERE Finished_Good__c = true AND ' +
'  Product_Classification__c IN: classificationList ' + 
'  AND Country_Code__c = :countryCode ' + 
'  AND IsActive = true ' + 
'  AND Spare_Part__c = false ' + 
'  AND Product_Sub_Family__c != \'Service\' ';
if(additionalCondition != null && additionalCondition != ''){
query += ' AND ' + additionalCondition;
}                                         
query += '  GROUP BY Product_Sub_Family__c';

List<AggregateResult> subCategoryList = Database.query(query);
for (AggregateResult ar : subCategoryList){
if(ar != Null && ar.get('subCategory') != Null)
subcategoriesList.add(new SelectOption((string) ar.get('subCategory'), (string) ar.get('subCategory')));
}                                     
return subcategoriesList;
}*/
    
    /*Change in filter*/
    public static List<SelectOption> fetchProductSubcategories(String countryCode, String brand, String plmStatusNotStartsWith,  String additionalCondition){
        
        List<SelectOption> subcategoriesList = new List<SelectOption>();
        subcategoriesList.add(new SelectOption('', Label.Default_Picklist_Value));
        
        String query = 'SELECT Product_Sub_Family__c subCategory ' +
            ' FROM Product2 ' +
            '  WHERE Finished_Good__c = true ' +
            ' AND (NOT AX_Items_PLM_Status__c like :plmStatusNotStartsWith) '+
            ' AND Country_Code__c = :countryCode '+
            ' AND IsActive = true ' + 
            ' AND Spare_Part__c = false ' + 
            //' AND Serial_Required_for_Registration__c   = true  ' +
            ' AND Product_Sub_Family__c != \'Service\' ' + 
            ' AND Exclude_from_Sync__c = false ';
         
        if(brand != null && brand != '')
        {
            query +=  ' AND brand__c =:brand ';
        }
       
        if(additionalCondition != null && additionalCondition != ''){
            query += ' AND ' + additionalCondition;
        } 
     
        query += '  GROUP BY Product_Sub_Family__c';
        
        List<AggregateResult> subCategoryList = Database.query(query);
        for (AggregateResult ar : subCategoryList){
            if(ar != Null && ar.get('subCategory') != Null)
                subcategoriesList.add(new SelectOption((string) ar.get('subCategory'), (string) ar.get('subCategory')));
        }
        return subcategoriesList;
        
    }
    
    //returns map of all products instead of select option list. Only used for smart search
    public static Map<String, Id> fetchAllProducts(String countryCode, String brand, String plmStatusNotStartsWith,  String additionalCondition, map<Id, String> productIdToProductCodeMap){
        
        Map<String, Id> idToProductDescriptionMap = new Map<String, Id>();
        
        String query = 'SELECT Id, Name, Description, AX_Item_Number__c ' +
            ' FROM Product2 ' +
            '  WHERE Finished_Good__c = true ' +
            ' AND (NOT AX_Items_PLM_Status__c like :plmStatusNotStartsWith) '+
            ' AND Country_Code__c = :countryCode '+
            ' AND IsActive = true ' + 
            ' AND Spare_Part__c = false ' + 
            ' AND Accessory__c =false' +
            //' AND Serial_Required_for_Registration__c   = true  ' +
            ' AND Product_Sub_Family__c != \'Service\' ' + 
            ' AND Exclude_from_Sync__c = false ';
        if(brand != null && brand != '')
        {
            query +=  ' AND brand__c =:brand ';
        }
        
        if(additionalCondition != null && additionalCondition != ''){
            query += ' AND ' + additionalCondition;
        }                                         
        List<Product2> productList = Database.query(query);
        for (Product2 prod : productList){
            idToProductDescriptionMap.put(prod.Description + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
            if(productIdToProductCodeMap !=null)
                productIdToProductCodeMap.put(prod.Id, prod.Name); 
        }
        return idToProductDescriptionMap;
    }
    
    
    
    /*
public static List<SelectOption> fetchProducts(String countryCode, String selectedSubCategory, String additionalCondition, List<String> classificationList){

List<SelectOption> productList = new List<SelectOption>();
productList.add(new SelectOption('', Label.Default_Picklist_Value));

//list<String> classificationList = new List<String>{'C', 'D', 'E', 'F', 'R', 'S'}; 

String query = 'SELECT Id, Name, Description, US_SKU__c ' +
' FROM Product2 ' +
'  WHERE Product_Sub_Family__c =: selectedSubCategory ' + 
' AND Finished_Good__c = true  ' +
' AND Product_Classification__c IN: classificationList ' + 
' AND Country_Code__c =: countryCode  ' +
' AND IsActive = true  ' +
' AND Spare_Part__c = false ';
if(additionalCondition != null && additionalCondition != ''){
query += ' AND ' + additionalCondition;
}                                               
query += ' ORDER BY Name ASC';

if(selectedSubCategory != null && selectedSubCategory != ''){
for(Product2 product : Database.query(query)){
productList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
} 
}                           
return productList;
}
*/
    
    /* public static List<SelectOption> fetchProducts(String countryCode, String selectedSubCategory, String additionalCondition, List<String> classificationList, map<Id, String> productIdToProductCodeMap){

List<SelectOption> productList = new List<SelectOption>();
productList.add(new SelectOption('', Label.Default_Picklist_Value));

//list<String> classificationList = new List<String>{'C', 'D', 'E', 'F', 'R', 'S'}; 

String query = 'SELECT Id, Name, Description, US_SKU__c ' +
' FROM Product2 ' +
'  WHERE Product_Sub_Family__c =: selectedSubCategory ' + 
' AND Finished_Good__c = true  ' +
' AND Product_Classification__c IN: classificationList ' + 
' AND Country_Code__c =: countryCode  ' +
' AND IsActive = true  ' +
' AND Spare_Part__c = false ';
if(additionalCondition != null && additionalCondition != ''){
query += ' AND ' + additionalCondition;
}                                               
query += ' ORDER BY Name ASC';

if(selectedSubCategory != null && selectedSubCategory != ''){
for(Product2 product : Database.query(query)){
productList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
productIdToProductCodeMap.put(product.Id, product.Name);
} 
}                           
return productList;
}*/
    /*Change in filters*/
    public static List<SelectOption> fetchProducts(String countryCode, String selectedSubCategory, String brand, String plmStatusNotStartsWith, String additionalCondition, map<Id, String> productIdToProductCodeMap){
        
        List<SelectOption> productList = new List<SelectOption>();
        productList.add(new SelectOption('', Label.Default_Picklist_Value));
        String query = 'SELECT Id, Name, Description, US_SKU__c ' +
            ' FROM Product2 ' +
            '  WHERE Product_Sub_Family__c =: selectedSubCategory ' + 
            ' AND Finished_Good__c = true  ' +
            ' AND (NOT AX_Items_PLM_Status__c like :plmStatusNotStartsWith) '+
            ' AND Country_Code__c =: countryCode  ' +
            ' AND IsActive = true  ' +
            //' AND Serial_Required_for_Registration__c   = true  ' +
            ' AND Spare_Part__c = false ' + 
            ' AND Exclude_from_Sync__c = false ';
        
        if(brand != null && brand != '')
        {
            query +=  ' AND brand__c =:brand ';
        }
        if(additionalCondition != null && additionalCondition != ''){
            query += ' AND ' + additionalCondition;
        }                                               
        query += ' ORDER BY Name ASC';
        
        if(selectedSubCategory != null && selectedSubCategory != ''){
            for(Product2 product : Database.query(query)){
                productList.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                if(productIdToProductCodeMap !=null)
                    productIdToProductCodeMap.put(product.Id, product.Name);
            } 
        } 
        return productList;
    }
    
    
    public static List<SelectOption> fetchCaseTypes(String categoryValue){
        
        List<SelectOption> caseTypes = new List<SelectOption>();
        caseTypes.add(new SelectOption('', Label.Default_Picklist_Value));
        Set<String> caseTypeToIgnore = new Set<String>();
        for(All_Literal__mdt literalRec : [SELECT Value__c, Category__c FROM All_Literal__mdt WHERE Category__c =: categoryValue ]){
            caseTypeToIgnore.add(literalRec.Value__c);
        }
        
        for (Schema.PicklistEntry pe: Case.Type.getDescribe().getPicklistValues()) {
            if(!caseTypeToIgnore.contains(pe.getValue())){
                caseTypes.add(new selectOption(pe.getValue(), pe.getLabel()));
            }
        }
        
        return caseTypes;
    }
    
    public static List<SelectOption> fetchPurchasedFrom(String categoryValue){
        
        List<SelectOption> purchaseFrom = new List<SelectOption>();
        purchaseFrom.add(new SelectOption('', Label.Default_Picklist_Value));
        Set<String> purchasefrominclude = new Set<String>();
        
        for(All_Literal__mdt literalRec : [SELECT Value__c, Category__c FROM All_Literal__mdt WHERE Category__c =: categoryValue ]){
            purchasefrominclude.add(literalRec.Value__c);
        }
        
        for (Schema.PicklistEntry pe: Case.Purchased_From__c.getDescribe().getPicklistValues()) {
            if(!purchasefrominclude.contains(pe.getValue())){
                purchaseFrom.add(new selectOption(pe.getValue(), pe.getLabel()));
            }
        }
        
        return purchaseFrom;
    }
    //Validation rule for BillingStreet on Account
    public static Boolean validateBillingStreet(String strBillingStreet){
        if(strBillingStreet != null && strBillingStreet.length() > 30){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Address_Length_Error));
            return false;
        }
        return true;
    }
    
    //Validation rule for BillingPostalCode on Account
    public static Boolean validatePostalCode(String strPostalCode, String countryCode){
        if(strPostalCode != null && strPostalCode != '' && countryCode == 'CAN' && (strPostalCode.contains(' ') || strPostalCode.length() != 6)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Postal_Code_Error));
            return false;
        }
        return true;
    }
    
    /**
* Verifies that the Asset PurchaseDate should be less than
*  or equal to current date.
*/
    public static Boolean validatePurchaseDate(Date purchaseDate){ 
        
        if (purchaseDate !=null && purchaseDate > Date.today()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Purchase_Date_Error));
            return false;
        }
        return true;
    }
    
    public static String fetchAllLiteralValue(String allLiteralDeveloperName){
        list<All_Literal__mdt> literalRec = [SELECT Value__c, DeveloperName FROM All_Literal__mdt WHERE DeveloperName =: allLiteralDeveloperName ];
        if(literalRec != null && literalRec.size() > 0){
            return literalRec[0].Value__c;
        }
        return null;
    }
    
    /**
* Queries to find any existing accounts based on email address. Returns existing or null if none exist.
*/
    public static Account findExistingAccount(String email){
        List<Account> accounts = [SELECT Id, BillingStreet, Firstname, LastName,Marketing_Opt_In__c FROM Account WHERE PersonEmail =: email AND RecordType.Name = 'Person Account' LIMIT 1];
        if(accounts.size() > 0){
            return accounts[0];
        }
        return null;
    }
    
    public static Account findExistingAccountWithID(ID accID){
        List<Account> accounts = [SELECT Id, FirstName, LastName, Phone, BillingCountryCode FROM Account WHERE id =: accID AND RecordType.Name = 'Person Account' LIMIT 1];
        if(accounts.size() > 0){
            return accounts[0];
        }
        return null;
    }
    
    public static Id fetchRecordTypeId(String sobjectType, String developerName){
        return [SELECT Id FROM RecordType WHERE sObjectType =: sobjectType AND DeveloperName =: developerName AND IsActive = true].Id;
    }
    
    public static Account createUpdateAccount(Account existingAccount, Account accountToUpdateOrCreate, String personBillingStreet2, String currencyISOCode){
        
        if(existingAccount != null){
            accountToUpdateOrCreate.Id = existingAccount.Id;
        }
        
        accountToUpdateOrCreate.BillingStreet += personBillingStreet2 != null ? '\n '+personBillingStreet2 : '';
        accountToUpdateOrCreate.CurrencyIsoCode = currencyISOCode;
        
        accountToUpdateOrCreate.RecordTypeId = fetchRecordTypeId('Account', 'PersonAccount');
        return accountToUpdateOrCreate;
    }
    
    public static Account createUpdateAccount(Account existingAccount, Account accountToUpdateOrCreate, String personBillingStreet2, String currencyISOCode, String language){
        
        if(existingAccount != null){
            accountToUpdateOrCreate.Id = existingAccount.Id;
        }
        
        accountToUpdateOrCreate.BillingStreet += (personBillingStreet2 != null && personBillingStreet2.trim() != '') ? '\n '+personBillingStreet2 : '';
        accountToUpdateOrCreate.ShippingStreet += (personBillingStreet2 != null && personBillingStreet2.trim() != '') ? '\n '+personBillingStreet2 : '';
        accountToUpdateOrCreate.CurrencyIsoCode = currencyISOCode;
        accountToUpdateOrCreate.PreferredLanguage__c = language;
        
        accountToUpdateOrCreate.RecordTypeId = fetchRecordTypeId('Account', 'PersonAccount');
        return accountToUpdateOrCreate;
    }
    
    public static Account createUpdateAccount(Account existingAccount, Account accountToUpdateOrCreate, String currencyISOCode){
        
        if(existingAccount != null){
            accountToUpdateOrCreate.Id = existingAccount.Id;
        }
        
        accountToUpdateOrCreate.CurrencyIsoCode = currencyISOCode;
        
        accountToUpdateOrCreate.RecordTypeId = fetchRecordTypeId('Account', 'PersonAccount');
        return accountToUpdateOrCreate;
    }
    
    
    /*public static Product2 fetchProductIdFromProductMetadata(String regionCode, Boolean sparePart, String subCategory){
list<Product_Metadata__mdt> productMetadataList = [SELECT MasterLabel, Product_Id__c,SKU__c, Subcategory__c 
FROM Product_Metadata__mdt 
WHERE Country_Code__c=:regionCode 
AND Subcategory__c=:subCategory 
AND Is_Spare_Part__c=:sparePart];
if(productMetadataList != null && productMetadataList.size() > 0){
return new Product2(Id = productMetadataList[0].Product_Id__c, Product_Sub_Family__c = productMetadataList[0].Subcategory__c);
}  
return null;                        
}*/
    public static set<String> activeJobs = new set<String>{'Preparing','Processing'}; 
        public static boolean isBatchRunning (string className)
    {
        integer recordCount=[SELECT count() FROM AsyncApexJob where Status in :Utility.activeJobs and ApexClass.name=:className ];
        if(recordCount>0)
            return true;
        else
            return false; 
    }
    
    /*
public static Boolean validateLookupFilter(Id productId){
Product2 objProduct2 = new Product2();
if(productId != null)
objProduct2 = [select Id,Breville_US_Product__c from Product2 where Id =: productId];

list<RecordType> lstRecordType = new list<RecordType>();
set<string> setDeveloperName = new set<string>();

lstRecordType=[ SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case'];

if(lstRecordType.size() > 0 && lstRecordType != null){
for(RecordType objRecordType : lstRecordType){
setDeveloperName.add(objRecordType.DeveloperName);
}
} 
if(((setDeveloperName.contains(' New_Case') || setDeveloperName.contains(' Submitted_Case')) && objProduct2.Breville_US_Product__c == true)||
((setDeveloperName.contains(' PS_New_Case') || setDeveloperName.contains(' PS_Submitted_Case')) && objProduct2.PolySci_Product__c == true)||
((setDeveloperName.contains(' CAN_New_Case') || setDeveloperName.contains(' Submitted_Case')) && objProduct2.Breville_CAN_Product__c == true)){
return true;
}else{
if(blnEnglish == true)
return false;
}
return false;
}*/
    
    public static Map<String,Case> createCaseMap(Set<String> caseNumberSet){
        Map<String,Case> caseNumberToCaseIdMap = new Map<String,Case>();
        
        list<Case> caseRecordList = [select Id, CaseNumber, AccountId, Status, Account.FirstName, Account.LastName, Account.PersonEmail, Account.Phone,
                                     Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry
                                     from Case Where CaseNumber IN: caseNumberSet];
        if(caseRecordList != null && caseRecordList.size()>0){
            for(Case caseRecord : caseRecordList){
                caseNumberToCaseIdMap.put(caseRecord.CaseNumber, caseRecord);
            }
        }
        return caseNumberToCaseIdMap;
    }
    public static map<Id, Set<Id>> getPartnerUserIdByAccountId(set<Id> serviceCentreAccountIds){
        map<Id,Set<Id>> partnerUserIdByAccountId = new map<Id, Set<Id>>();
        
        for(User user : [SELECT Id, AccountId 
                         FROM User 
                         WHERE IsPortalEnabled =true
                         AND IsActive = true
                         AND AccountId IN:serviceCentreAccountIds]){
                             if(partnerUserIdByAccountId.containsKey(user.AccountId)){                  
                                 partnerUserIdByAccountId.get(user.AccountId).add(user.Id);
                             }else{
                                 partnerUserIdByAccountId.put(user.AccountId, new Set<Id>{user.Id});
                             }
                         }
        return partnerUserIdByAccountId;
    }
    
    public static Map<String, Id> createRegionToPricebookMap(set<String> regionSet){
        Map<String, Id> regionToPricebookMap = new Map<String, Id>();
        list<Pricebook2> pricebookList = [SELECT Id, region__c FROM PriceBook2 where Type__c = 'Work Order' AND Subtype__c = 'Flat Service Charge' AND region__c IN :regionSet];
        if(pricebookList != null && pricebookList.size()>0){
            for(Pricebook2 pricebookRecord : priceBookList){
                if(pricebookRecord.region__c != null && pricebookRecord.region__c != '')
                    regionToPricebookMap.put(pricebookRecord.region__c, pricebookRecord.Id);
            }
        }
        return regionToPricebookMap;
    }
    public static map<String, map<String, Id>> createRegionToWholesalePricebookMap(set<String> regionSet, set<String> brandSet){
        map<String, map<String, Id>> regionToBRANDToPricebookIdMap = new map<String, map<String, Id>>();
        list<Pricebook2> pricebookList = [SELECT Id, region__c, Brand__c  FROM PriceBook2 where Type__c = 'Wholesale' AND region__c IN :regionSet AND Brand__c IN :brandSet];
        if(pricebookList != null && pricebookList.size()>0){
            for(Pricebook2 pricebookRecord : priceBookList){
                if(pricebookRecord.region__c != null && pricebookRecord.region__c != ''){
                    if(regionToBRANDToPricebookIdMap.containsKey(pricebookRecord.region__c)){
                        if(pricebookRecord.Brand__c != null && pricebookRecord.Brand__c != '' && 
                           !regionToBRANDToPricebookIdMap.get(pricebookRecord.region__c).containsKey(pricebookRecord.Brand__c)){
                               regionToBRANDToPricebookIdMap.get(pricebookRecord.region__c).put(pricebookRecord.Brand__c, pricebookRecord.Id);
                           }
                    }else if(pricebookRecord.Brand__c != null && pricebookRecord.Brand__c != '' && pricebookRecord.region__c != null && pricebookRecord.region__c != ''){
                        map<String, Id> brandToPriceBookIdMap = new map<String, Id>();
                        brandToPriceBookIdMap.put(pricebookRecord.Brand__c, pricebookRecord.Id);
                        regionToBRANDToPricebookIdMap.put(pricebookRecord.region__c, brandToPriceBookIdMap);
                    }
                }
            }
        }
        return regionToBRANDToPricebookIdMap;
    }
    
    /*
public static Map<Id, Pricebook2> createProductToPricebookMap(){
Map<Id, Pricebook2> productToPriceBookMap = new Map<Id, Pricebook2>();
list<PricebookEntry> priceBookEntryList = [SELECT Id, UnitPrice, ServiceCharge__c,
InspectionCharge__c, FreightCharge__c, LaborCharge__c FROM PricebookEntry WHERE IsActive = true];
if(priceBookEntryList != null && priceBookEntryList.size()>0){
for(PriceBookEntry pricebookEntryRecord : priceBookEntryList){
productToPriceBookMap.put(pricebookEntryRecord.Product2Id,pricebookEntryRecord);
}
}
return   productToPriceBookMap;                        
}*/
    
    //create Account record
    public static Account createAccountRecord(String firstName, String lastName,  String email){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = lastName;
        record.firstName = firstName;
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = email;
        record.TerritoryAssigned__c = false;
        insert record;
        return record;
    }
    public static Contact createContactRecord(Id accountId, String firstname,String lastname, String email){
        Contact record = new Contact(AccountId=accountId, firstname=firstname, lastname=lastname, Email=email);
        
        insert record;
        return record;
    }
    
    public static User createUserRecord(String profileName, String CurrencyISOCode, String email){
        Profile profile = [SELECT Id, Name FROM Profile where Name =: profileName LIMIT 1];
        //UserRole userRole = [SELECT Id, Name FROM UserRole where Name =: roleName LIMIT 1];
        User userRecord = new User();
        userRecord.UserName = 'TestUser' + String.valueOf(Datetime.now().getTime()) + '_' + UserInfo.getOrganizationId() + '@breville.com.test';
        userRecord.profileId = profile.Id;
        userRecord.Alias = 'a';
        //userRecord.CommunityNickname = 'b';
        userRecord.Email = email;
        userRecord.CurrencyIsoCode = CurrencyISOCode;
        userRecord.LastName = 'test';
        userRecord.TimeZoneSidKey = 'GMT';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.EmailEncodingKey = 'ISO-8859-1';
        userRecord.LanguageLocaleKey = 'en_US';
        
        return userRecord;
    }
    
    
    
    //update User, will be called from registration handler
    public static User updateUser(User userRecord, String firstname, String lastname, String email){
        userRecord.Email = email;
        userRecord.LastName = lastName;
        userRecord.FirstName = firstName;
        
        update userRecord;
        return userRecord;
    }
    /*
//cretae user from facebook / google login
public static User createUserFromAuthProvider(String firstname, String lastname, String email){
Account accountRecord = createAccountRecord(firstName,lastName, email);
Account acc = [select PersonContactId from Account where id =:accountRecord.Id];
//Contact contactRecord = createContactRecord(accountRecord.Id, firstname, lastName, email);
//TODO: Customize the username and profile. Also check that the username doesn't already exist and
//possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
//String profileName, String roleName, String curerncyISOCode, Boolean insertRecord
User userRecord = createUserRecord('My Breville Community', 'USD', email);          
userRecord.username = email;
userRecord.email = email;
userRecord.lastName = lastName;
userRecord.firstName = firstName;
userRecord.CommunityNickname = firstName.subString(0,1) +lastName.subString(0,1)+ System.now().getTime()/1000;
String alias = email;
if (alias.length() > 8){
alias = alias.substring(0, 8);
}
userRecord.Alias = alias;
userRecord.Languagelocalekey = UserInfo.getLocale();
userRecord.Localesidkey = UserInfo.getLocale();
userRecord.EmailEncodingKey = 'UTF-8';
userRecord.TimeZoneSidKey = 'America/Los_Angeles';
userRecord.ContactId = acc.PersonContactId;

insert userRecord;
return userRecord;
}*/
    
    //return cloned attachment
    public static Attachment cloneAttachmentFromWorkOrder(Map<Id, Attachment> workOrderIdToAttachmentMap, Id workOrderId){
        if(workOrderIdToAttachmentMap.get(workOrderId) != null)
            return workOrderIdToAttachmentMap.get(workOrderId).clone(false, false, false, false);
        return null;  
    }
    public static Attachment cloneAttachmentFromCase(Map<Id, Attachment> caseIdToAttachmentMap, Id caseId){
        if(caseIdToAttachmentMap.get(caseId) != null)
            return caseIdToAttachmentMap.get(caseId).clone(false, false, false, false);
        return null;  
    }
    
    /*
public static Case createCaseFromSupport(String contactId, String accountId, String caseType, String description, Id caserecordTypeId){
Case caseRecord = new Case(Description=description, recordTypeId=caserecordTypeId, type=caseType, ContactId= contactId, accountID=accountId);
return caseRecord;
}

public static Case createCaseFromSupport(Account acc , String caseType, String description, Id caserecordTypeId){
Case caseRecord = new Case(Description=description, recordTypeId=caserecordTypeId, type=caseType, ContactId= acc.PersonContactId, accountID=acc.Id);
return caseRecord;
}

public static Account createAccountFromSupport(String firstName, String lastName, String phone, String country, Id accountRecordTypeId){
Account accountRecord = new Account(firstname=firstName, lastname=lastName, phone=phone); //recordTypeId=accountRecordTypeId
return accountRecord;
}*/
    
    public static String fetchCurrencyCodeFromCountry(String epRegionCode){
        if(epRegionCode != null){
            list<Country_Region_Setting__mdt> RegionSpecificCurrencyCode = [SELECT Currency__c, Region_Code__c FROM Country_Region_Setting__mdt WHERE Parameter__c =: epRegionCode LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Currency__c;
            }
        }
        return Label.Default_Currency;
    }
    
    public static String fetchRegionCodeFromCountry(String epRegionCode){
        if(epRegionCode != null){
            list<Country_Region_Setting__mdt> RegionSpecificCurrencyCode = [SELECT Parameter__c, Region_Code__c FROM Country_Region_Setting__mdt WHERE Parameter__c =: epRegionCode LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
                return RegionSpecificCurrencyCode[0].Region_Code__c;
            }
        }
        return '';
    }
    
    /**
* Create Auto Box Order from Case.
*/
    public static void createBoxOrderRecordFromCase(Id caseId){
        
        Case caseRecord = [select AccountId,  ContactId, Product__r.Service_Return_Box__c, Product__r.Brand__c, Product__c, Account.BillingCity, Account.BillingPostalCode,
                           Account.BillingStateCode,Account.BillingStreet,Account.ShippingCountryCode, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingStateCode, 
                           Account.ShippingStreet,Account.BillingCountryCode, Status, Id, CurrencyIsoCode, Account.Name, Account.IsTaxExempted__c, Account.VendAccount__c 
                           From Case where id =: caseId];
        
        if(caseRecord != null){
            if(caseRecord.AccountId != null &&
               caseRecord.Account.BillingCity != null && caseRecord.Account.BillingCity != '' &&
               caseRecord.Account.BillingCountryCode != null && caseRecord.Account.BillingCountryCode != '' &&
               caseRecord.Account.BillingPostalCode != null && caseRecord.Account.BillingPostalCode != '' &&
               ((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR') || 
                (caseRecord.Account.BillingStateCode != null && caseRecord.Account.BillingStateCode != '')) &&
               caseRecord.Account.BillingStreet != null && caseRecord.Account.BillingStreet != '' &&
               caseRecord.Account.ShippingCountryCode != null && caseRecord.Account.ShippingCountryCode != '' &&
               caseRecord.Account.ShippingCity != null && caseRecord.Account.ShippingCity != '' &&
               caseRecord.Account.ShippingPostalCode != null && caseRecord.Account.ShippingPostalCode != '' &&
               ((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR') || 
                (caseRecord.Account.ShippingStateCode != null && caseRecord.Account.ShippingStateCode != ''))){ 
                    
                    Order orderRecord = createOrder(caseRecord);
                }
        }
    }   
    public static map<String,String> getOrderFieldMappingForCase(){
        map<String,String> orderFieldMap = new  map<String,String>();
        orderFieldMap.put('AccountId','AccountId');
        orderFieldMap.put('BillToContactId','ContactId');
        orderFieldMap.put('BillingCity','Account.BillingCity');
        orderFieldMap.put('BillingCountryCode','Account.BillingCountryCode');
        orderFieldMap.put('BillingPostalCode','Account.BillingPostalCode');
        orderFieldMap.put('BillingStateCode','Account.BillingStateCode');
        orderFieldMap.put('BillingStreet','Account.BillingStreet');
        orderFieldMap.put('ShippingCountryCode','Account.ShippingCountryCode');
        orderFieldMap.put('ShippingCity','Account.ShippingCity');
        orderFieldMap.put('ShippingPostalCode','Account.ShippingPostalCode');
        orderFieldMap.put('ShippingStateCode','Account.ShippingStateCode');
        orderFieldMap.put('ShippingStreet','Account.ShippingStreet');
        orderFieldMap.put('Status','Status');
        orderFieldMap.put('Case__c','Id');
        orderFieldMap.put('CurrencyIsoCode','CurrencyIsoCode');
        orderFieldMap.put('Ship_To_Name__c','Account.Name');
        orderFieldMap.put('Tax_Exempt_Order__c','Account.IsTaxExempted__c');
        orderFieldMap.put('AX_Order_Account__c', 'Account.VendAccount__c');
        return orderFieldMap;
    }
    
    public static Order createOrder(Case caseRecord){
        Order orderRecord = new Order();
        list<OrderItem> OrderItemList = new list<OrderItem>();
        map<String,String> OrderFieldMapping = getOrderFieldMappingForCase();
        String caseField = '';
        String region = regionBased(caseRecord.CurrencyIsoCode);
        String shippingMethod = '';
        List<Region_Specific__mdt> ShippingMethodData = [SELECT DeveloperName, Currency__c,DefaultShippingMethod__c 
                                                         FROM Region_Specific__mdt WHERE Currency__c =: caseRecord.CurrencyIsoCode LIMIT 1];
        if(ShippingMethodData != null && ShippingMethodData.size() > 0){
            shippingMethod = ShippingMethodData[0].DefaultShippingMethod__c;
        }                            
        for(String orderField : OrderFieldMapping.keySet()){
            caseField = OrderFieldMapping.get(orderField);
            if(!caseField.contains('.')){
                orderRecord.put(orderField,caseRecord.get(caseField));
            }else{
                String[] referenceFields = caseField.split('\\.');
                orderRecord.put(orderField,caseRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        orderRecord.put('EffectiveDate',Date.today());
        orderRecord.put('Type','Accommodation');
        orderRecord.status='Open';
        orderRecord.Brand__c = caseRecord.Product__r.Brand__c;
        orderRecord.Shipping_Method__c = shippingMethod;
        String currencyCode = (String) caseRecord.get('CurrencyIsoCode');
        
        TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(orderRecord);
        
        Boolean isB2BOrder = false;
        if(orderRecord != null && orderRecord.AccountId != null){
            
            Account orderAccount = [SELECT Id, RecordTypeId  FROM Account WHERE Id =: orderRecord.AccountId];
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            if(orderAccount.RecordTypeId != personAccountRecordTypeId){
                isB2BOrder = true;
            }
        }
        List<Pricebook2> pricebookList = [SELECT Id, Brand__c, Region__c, Type__c FROM Pricebook2 WHERE Region__c =: region AND Brand__c =: caseRecord.Product__r.Brand__c 
                                          AND Type__c = 'Accommodation'];
        
        if(pricebookList != null && pricebookList.size() > 0){
            orderRecord.PriceBook2Id = pricebookList[0].Id;
        }
        
        if(orderRecord.PriceBook2Id == null){
            if(!System.isBatch()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Required pricebook not available.'));
            }
            Error_Log__c error = new Error_Log__c(Error_Message__c = 'Required pricebook not available.',
                                                            Operation__c = 'Utility - ' +
                                                                                    'Error in createOrder()',
                                                            Record_Id__c = caseRecord.Id,
                                                            Trace_Log__c = 'Required pricebook not available.',
                                                            Type__c = 'Error'
                    );
            insert error;
            return null;
        }
        
        if(region != null){
            orderRecord.Country__c = region;
        }  
        
        try{
            insert orderRecord;
        }catch(System.DmlException ex){
            if(!System.isBatch()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0)));
            }
            Error_Log__c error = new Error_Log__c(Error_Message__c = ex.getDmlMessage(0),
                                                            Operation__c = 'Utility - ' +
                                                                                    'Error in createOrder()',
                                                            Record_Id__c = caseRecord.Id,
                                                            Trace_Log__c = ex.getDmlMessage(0),
                                                            Type__c = 'Error'
                    );
            insert error;
            return null;
        }        
        if(caseRecord.Product__r.Service_Return_Box__c != null){
            
            List<PricebookEntry> priceBookEntry = [select id, Product2id, PriceBook2Id
                                                   From PricebookEntry where Product2id =: caseRecord.Product__r.Service_Return_Box__c 
                                                   AND PriceBook2Id =: orderRecord.PriceBook2Id];
            if(priceBookEntry != null && priceBookEntry.size() > 0){
                OrderItem orderItemRecord = new OrderItem();
                orderItemRecord.OrderId = orderRecord.id;
                orderItemRecord.PriceBookEntryId = priceBookEntry[0].id;
                orderItemRecord.Quantity = 1;
                orderItemRecord.UnitPrice = 0;
                OrderItemList.add(orderItemRecord);
            }
        }
        
        if(OrderItemList != null && OrderItemList.size() > 0){
            try{
                insert OrderItemList;
                list<Order> orderToActivateList = [SELECT Id, Status FROM Order WHERE Id =: orderRecord.Id];
                if(orderToActivateList != null && orderToActivateList.size() > 0){
                    orderToActivateList[0].status = 'Order Pending';
                    OrderTriggerHandler.beforeTriggerRun = false;
                    OrderTriggerHandler.afterTriggerRun = false;
                    OrderTriggerHandler.runPopulateAXAccountNumber = false;
                    update orderToActivateList[0];
                }
            }catch(System.DmlException ex){
                if(!System.isBatch()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0)));
                }
                Error_Log__c error = new Error_Log__c(Error_Message__c = ex.getDmlMessage(0),
                                                            Operation__c = 'Utility - ' +
                                                                                    'Error in createOrder()',
                                                            Record_Id__c = caseRecord.Id,
                                                            Trace_Log__c = ex.getDmlMessage(0),
                                                            Type__c = 'Error'
                    );
            insert error;
                return null;
            }
        }  
        return orderRecord;
    }
    
    public static List<Account> fetchAccountDetailsFromRegion(String region){
        list<String> accIds = new list<String>();
        if(region != null){
            list<Region_Specific__mdt> RegionSpecificCorporateOffices = [SELECT DeveloperName, CorporateOfficeId__c FROM Region_Specific__mdt 
                                                                         WHERE DeveloperName =: region AND CorporateOfficeId__c != '' LIMIT 1];
            if(RegionSpecificCorporateOffices != null && RegionSpecificCorporateOffices.size() > 0 ){
                accIds= (RegionSpecificCorporateOffices[0].CorporateOfficeId__c).split('\\,');
            }else{
                return null;
            }
        }else{
            return null;
        }
        List<Account> acctList = [select id, name, ShippingCity, ShippingCountryCode, ShippingPostalCode, 
                                  ShippingStateCode, ShippingStreet from Account where id IN :accIds];
        return acctList;
    }
    
    public static boolean validatePurchaseDate(Date purchaseDate, String regionCode){
        Date regionDate= Date.today();
        if(regionCode != null){
            regionDate = convertDateToRegionSpecific(DateTime.now(),regionCode);
        }
        if (purchaseDate !=null && purchaseDate > regionDate) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.Purchase_Date_Error));
            return false;
        }
        return true;
    }
    
    public static Date convertDateToRegionSpecific(DateTime dateIn, String regionCode){
        String timeZoneCode;
        list<Region_Specific__mdt> RegionSpecificTimeZoneCode = [SELECT TimeZoneCode__c  FROM Region_Specific__mdt 
                                                                 WHERE EPParameter__c =: regionCode  LIMIT 1];
        if(RegionSpecificTimeZoneCode != null && RegionSpecificTimeZoneCode.size() > 0 ){
            timeZoneCode = RegionSpecificTimeZoneCode[0].TimeZoneCode__c;
        }
        if(timeZoneCode!=null && timeZoneCode!=''){
            return Date.valueOf(dateIn.format('yyyy-MM-dd',timeZoneCode)); 
        }else{
            return Date.valueOf(dateIn.format('yyyy-MM-dd')); 
        }
    }
    public static boolean countryValidation(String countryCode, String EPParam){
        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c, ValidCountries__c From Region_Specific__mdt Where EPParameter__c=:EPParam];
      if(regionSpecific != null && regionSpecific.ValidCountries__c.contains(';' +countryCode +';')){
              return true;
        }else{
            return false;
        }
    }
    
    public static String fetchCurrencyCodeFromEPRegionAPI(String epRegionCode){
        if(epRegionCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, Currency__c FROM Region_Specific__mdt 
                                                                     WHERE EPParameter__c =: epRegionCode 
                                                                     AND Currency__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Currency__c;
            }
        }
        return 'ERROR';
    }
    
    public static String fetchBusinessUnitEPRegionAPI(String epRegionCode){
        if(epRegionCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, Business_Unit__c FROM Region_Specific__mdt 
                                                                     WHERE EPParameter__c =: epRegionCode 
                                                                     AND Business_Unit__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Business_Unit__c;
            }
        }
        return 'ERROR';
    }
    
    public static String fetchRegionCodeFromEPRegionAPI(String epRegionCode){
        if(epRegionCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, DeveloperName FROM Region_Specific__mdt WHERE EPParameter__c =: epRegionCode LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
                return RegionSpecificCurrencyCode[0].DeveloperName;
            }
        }
        return 'ERROR';
    }
    
    public static boolean isDuplicateAsset(String accountId, String ax_item_number, String batch_code){
        List<Asset> assetsList = [select id  from Asset WHERE AccountId =:accountId AND Batch_Code__c =:batch_code AND Product2.AX_Item_Number__c = :ax_item_number];
        if(assetsList != null && assetsList.size() > 0)
            return true;
        return false;
    }
    
    public static List<SelectOption> getBusinessUnits() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(System.Label.Select2, System.Label.Select2));
        
        list<Region_Specific__mdt> regionSpecificName = [SELECT DeveloperName FROM Region_Specific__mdt];
        for(Region_Specific__mdt record: regionSpecificName){
            options.add(new SelectOption(record.DeveloperName, record.DeveloperName));
        }
        return options;
    }
    
    public static String getLanguageFromLanguageCode(String language){
        if(language.equalsIgnoreCase('fr') || language.equalsIgnoreCase('fr_CA') || language.equalsIgnoreCase('fr_CH')){
            return 'French';
        }else if(language.equalsIgnoreCase('de') || language.equalsIgnoreCase('de_CH')){
            return 'German';
        }else if(language.equalsIgnoreCase('it')){
            return 'Italian';
        }else if(language.toLowerCase().startsWith('en')){
            return 'English';
        }else if(language.equalsIgnoreCase('nl')){
            return 'Dutch';
        }else if(language.equalsIgnoreCase('es') || language.equalsIgnoreCase('es_MX')){
            return 'Spanish';
        }else if(language.equalsIgnoreCase('pt') || language.equalsIgnoreCase('pt_PT')){
            return 'Portuguese';
        }else{
            return null;
        }
    }
    
    public static String getLanguageCodeFromLanguage(String language){
        if(language == 'French'){
            return 'fr';
        }else if(language == 'English'){
            return 'en';
        }else if(language =='Italian'){
            return 'it';
        }else if(language == 'German'){
            return 'de';
        }else if(language == 'Spanish'){
            return 'es';
        }else if(language == 'Dutch'){
            return 'nl';
        }else if(language == 'Portuguese'){
            return 'pt';
        }else{
            return null;
        }
    }
    
    public static String fetchBusinessUnitFromCountryCode(String countryCode){
        if(countryCode != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, Business_Unit__c FROM Region_Specific__mdt 
                                                                     WHERE developerName =: countryCode 
                                                                     AND Business_Unit__c != NULL LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0 ){
                return RegionSpecificCurrencyCode[0].Business_Unit__c;
            }
        }
        return Label.Default_businessUnit;
    }  
    
    /*W-000167 Product Category Translation*/
    /**** Changes for SF1-258 : 
    1.Added new logic with multiple brands and exclude Plm status starts with 00,99,04
    2.Added new logic of query suggested by Aaron****/
    public static List<SelectOption> fetchProductSubcategories(String countryCode, String brand, Set<String> plmStatusNotStartsWith,  String additionalCondition, String language){
        Map<String, String> langToFieldMap = new Map<String, String>{'en' => 'ProdCatEN__c','fr' => 'ProdCatFR__c','it' => 'ProdCatIT__c',
                                                                    'es' => 'ProdCatES__c','nl' => 'ProdCatNL__c','pt' => 'ProdCatPT__c',
                                                                    'de' =>'ProdCatDE__c','es_MX' => 'ProdCatES__c',
                                                                    'fr_CH' => 'ProdCatFR__c','de_CH' =>'ProdCatDE__c'};
        
        Set<String> brandSet = SelectBrands(countryCode, brand);
        
        List<SelectOption> subcategoriesList = new List<SelectOption>();
        Set<SelectOption> subcategoriesListSet = new Set<SelectOption>();  
        //subcategoriesList.add(new SelectOption('', Label.Default_Picklist_Value));
        
        String prodTranslationField = langToFieldMap.get(language.startsWith('en') ? 'en' : language);
        String query = 'SELECT ' + prodTranslationField +' prodTranslation FROM Product2 WHERE'+ 
                        ' Finished_Good__c = true' + 
                        ' AND (AX_Items_PLM_Status__c != Null OR AX_Items_PLM_Status__c != \'\')'+
                        ' AND (NOT AX_Items_PLM_Status__c Like :plmStatusNotStartsWith)' +
                        ' AND Country_Code__c = :countryCode' +
                        ' AND IsActive = true'+
                        ' AND Accessory__c = false'+
                        ' AND Marketing_Item__c = false'+
                        ' AND Exclude_from_Sync__c = false';
                        //' AND '+ prodTranslationField +' != \'\'';
        
        if(brand != null && brand != '')
        {
            query +=  ' AND brand__c IN :brandSet ';
        }
        
        if(additionalCondition != null && additionalCondition != ''){
            query += ' AND ' + additionalCondition;
        }                                         
        query += 'group by '+ prodTranslationField;
        
        if(prodTranslationField != Null && prodTranslationField != ''){
            List<AggregateResult> subCategoryList = Database.query(query);
            System.debug('===subCategoryList==' + subCategoryList.size());
            
            for (AggregateResult ar : subCategoryList){ 
                if(ar != Null && ar.get('prodTranslation') != Null){
                    SelectOption so = null;
                    so = new SelectOption((string) ar.get('prodTranslation'), (string) ar.get('prodTranslation'));                
                    subcategoriesListSet.add(so); 
                }
            }
            
            subcategoriesList.addAll(subcategoriesListSet);
            //System.debug('===subcategoriesList===' + subcategoriesList.size());
            //List<SelectOption> sortedsubcategoriesList = new List<SelectOption>();
            //sortedsubcategoriesList.add(new SelectOption('', System.Label.Default_Picklist_Value));
            //sortedsubcategoriesList.addAll(sortSelectOptions(subcategoriesList));
            //System.debug('===sortedsubcategoriesList===' + sortedsubcategoriesList.size());
            //return sortedsubcategoriesList;
        }
        return subcategoriesList;
    }
    
    public static List<SelectOption> fetchProducts(String countryCode, String selectedSubCategory, String brand, Set<String> plmStatusNotStartsWith, String additionalCondition, map<Id, String> productIdToProductCodeMap, String language){
        /**** Added new logic for SF1-258 ****/
        Map<String, String> langToFieldMap = new Map<String, String>{'en' => 'ProdCatEN__c','fr' => 'ProdCatFR__c','de' =>'ProdCatDE__c',
                                                                    'it' => 'ProdCatIT__c','es' => 'ProdCatES__c','nl' => 'ProdCatNL__c',
                                                                    'pt' => 'ProdCatPT__c','es_MX' => 'ProdCatES__c',
                                                                    'fr_CH' => 'ProdCatFR__c','de_CH' =>'ProdCatDE__c'};       
        Set<String> brandSet = SelectBrands(countryCode, brand);
        
        List<SelectOption> productList = new List<SelectOption>();
        
        String prodTranslationField = langToFieldMap.get(language.startsWith('en') ? 'en' : language);

        String query = 'SELECT Id, Name, Description, US_SKU__c, Description_LP__c, Description_LP2__c, DescriptionEN__c, DescriptionFR__c, DescriptionDE__c, DescriptionIT__c, DescriptionES__c, DescriptionNL__c, Remanufactured__c'+
                        ' FROM Product2'+ 
                        ' WHERE '+ prodTranslationField +' like :selectedSubCategory'+
                        ' AND Finished_Good__c = true' + 
                        ' AND (AX_Items_PLM_Status__c != Null OR AX_Items_PLM_Status__c != \'\')'+
                        ' AND (NOT AX_Items_PLM_Status__c Like :plmStatusNotStartsWith)' +
                        ' AND Country_Code__c = :countryCode' +
                        ' AND IsActive = true'+
                        ' AND Accessory__c = false'+
                        ' AND Marketing_Item__c = false'+
                        ' AND Exclude_from_Sync__c = false';
              
        if(brand != null && brand != '')
        {
            query +=  ' AND brand__c IN :brandSet ';
        }
        if(additionalCondition != null && additionalCondition != ''){
            query += ' AND ' + additionalCondition;
        }                                             
        query += ' ORDER BY Name ASC';
      
        if(prodTranslationField != Null && prodTranslationField != '' && selectedSubCategory != null && selectedSubCategory != ''){
            String remanufactured = '';
            
            for(Product2 product : Database.query(query)){
                remanufactured = product.Remanufactured__c ? System.Label.Remanufactured : '';

                if(countryCode == 'CAN' && language.toLowerCase() == 'fr') {
                    if(product.Description_LP2__c != null && product.Description_LP2__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP2__c));
                    }else{
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                    }
                }else if(language.startsWith('en')){
                    if(product.DescriptionEN__c != null && product.DescriptionEN__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.DescriptionEN__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language.toLowerCase() == 'fr' || language.toLowerCase() == 'fr_CH'){
                    if(product.DescriptionFR__c != null && product.DescriptionFR__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.DescriptionFR__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language.toLowerCase() == 'de' || language.toLowerCase() == 'de_CH'){
                    if(product.DescriptionDE__c != null && product.DescriptionDE__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.DescriptionDE__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language.toLowerCase() == 'it'){
                    if(product.DescriptionIT__c != null && product.DescriptionIT__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.DescriptionIT__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language.toLowerCase() == 'es' || language.toLowerCase() == 'es_MX'){
                    if(product.DescriptionES__c != null && product.DescriptionES__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.DescriptionES__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                        }
                    }            
                }else if(language.toLowerCase() == 'nl'){
                    if(product.DescriptionNL__c != null && product.DescriptionNL__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.DescriptionNL__c));
                    }else{
                        if(product.Description_LP__c != null && product.Description_LP__c != ''){
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                        }else{
                            productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                        }
                    }            
                }else{
                    if(product.Description_LP__c != null && product.Description_LP__c != ''){
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description_LP__c));
                    }else{
                        productList.add(new SelectOption(product.Id, remanufactured + product.Name + ' - ' + product.Description));
                    }
                }
                
                if(productIdToProductCodeMap !=null) {
                    productIdToProductCodeMap.put(product.Id, product.Name);
                }
            } 
        }
        return productList;
    }
    
    /*Code changes for SF-520: Configured valid brands with respect to Regions*/
    public static Set<String> SelectBrands(String countryCode, String brand){
        Set<String> brandSet = new Set<String>();
        List<String> brandList = new List<String>();  
                
        if(countryCode != null && (brand == 'Breville' || brand == 'Sage')){            
            list<Region_Specific__mdt> RegionSpecificValidBrands = [SELECT EPParameter__c, DeveloperName, Valid_Brands__c FROM Region_Specific__mdt
                                                                     WHERE DeveloperName =: countryCode LIMIT 1];
            if(RegionSpecificValidBrands != null && RegionSpecificValidBrands.size() > 0){
                String validBrands = RegionSpecificValidBrands[0].Valid_Brands__c;
                if(validBrands != Null && validBrands != ''){
                    if(validBrands.contains(',')){
                        brandList = validBrands.split(',');
                    }else{
                        brandList.add(validBrands);
                    }
                }                
            }
        }
        brandList.add(brand);
        brandSet.addAll(brandList);
        return brandSet;
    }
    /*End of Code changes for SF-520*/
    
    public static Map<String, Id> fetchAllProducts(String countryCode, String brand, String plmStatusNotStartsWith,  String additionalCondition, map<Id, String> productIdToProductCodeMap, String language){
        
        Map<String, Id> idToProductDescriptionMap = new Map<String, Id>();
        
        String query = 'SELECT Id, Name, Description, AX_Item_Number__c, Description_LP__c, Description_LP2__c ' +
            ' FROM Product2 ' +
            '  WHERE Finished_Good__c = true ' +
            ' AND (NOT AX_Items_PLM_Status__c like :plmStatusNotStartsWith) '+
            ' AND Country_Code__c = :countryCode '+
            ' AND IsActive = true ' + 
            ' AND Spare_Part__c = false ' + 
            ' AND Accessory__c =false' +
            //' AND Serial_Required_for_Registration__c   = true  ' +
            ' AND Product_Sub_Family__c != \'Service\' ' + 
            ' AND Exclude_from_Sync__c = false ';
        if(brand != null && brand != '')
        {
            query +=  ' AND brand__c =:brand ';
        }
        
        if(additionalCondition != null && additionalCondition != ''){
            query += ' AND ' + additionalCondition;
        }                                         
        List<Product2> productList = Database.query(query);
        for (Product2 prod : productList){
            
            if(countryCode == 'USA' || countryCode == 'NZ' || countryCode == 'AU' || countryCode == 'UK') {
                if(prod.Description_LP__c !=null && prod.Description_LP__c != ''){
                    idToProductDescriptionMap.put(prod.Description_LP__c + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                }else{
                    idToProductDescriptionMap.put(prod.Description + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                }
            }else if(countryCode == 'CAN') {
                if(language.toLowerCase() == 'fr'){
                    if(prod.Description_LP2__c != null && prod.Description_LP2__c != ''){
                        idToProductDescriptionMap.put(prod.Description_LP2__c + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                    }else{
                        idToProductDescriptionMap.put(prod.Description + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                    }
                }else{
                    if(prod.Description_LP__c != null && prod.Description_LP__c != ''){
                        idToProductDescriptionMap.put(prod.Description_LP__c + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                    }else{
                        idToProductDescriptionMap.put(prod.Description + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                    }
                }
            }else if(countryCode == 'DE') {
                if(language.toLowerCase() == 'de'){
                    if(prod.Description_LP__c != null && prod.Description_LP__c != ''){
                        idToProductDescriptionMap.put(prod.Description_LP__c + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                    }else{
                        idToProductDescriptionMap.put(prod.Description + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
                    }
                }
            }else{
                idToProductDescriptionMap.put(prod.Description + ' | ' +prod.Name + ' | '+ prod.AX_Item_Number__c, prod.id);
            }
            
            
            if(productIdToProductCodeMap != null)
                productIdToProductCodeMap.put(prod.Id, prod.Name); 
        }
        return idToProductDescriptionMap;
    }
    
    public static String fetchEPParameterFromCountry(String country){
        if(country != null){
            list<Region_Specific__mdt> RegionSpecificCurrencyCode = [SELECT EPParameter__c, DeveloperName FROM Region_Specific__mdt WHERE DeveloperName =: country LIMIT 1];
            if(RegionSpecificCurrencyCode != null && RegionSpecificCurrencyCode.size() > 0){
                return RegionSpecificCurrencyCode[0].EPParameter__c;
            }
        }
        return 'US';
    }
    
    public static List<SelectOption> sortSelectOptions(List<SelectOption> sortingList) {
        for (Integer i =0; i < sortingList.size(); i++) {
            for (Integer j = i; j > 0; j--) {
                if (sortingList[j-1].getLabel() > sortingList[j].getLabel()){
                    SelectOption temp = sortingList[j];
                    sortingList[j] = sortingList[j-1];
                    sortingList[j-1] = temp;
                }
            }
        }
        return sortingList;
    }
    
    public static D365Setting__c D365Setting {
        get {
            if (D365Setting == null) {
                D365Setting = D365Setting__c.getOrgDefaults();
            }
            return D365Setting;
        }
        private set;
    }

    public static Boolean isD365Enabled(SObject record) {
        String currencyVal= (String)record.get('CurrencyIsoCode');
        Datetime createdDate = (Datetime) record.get('CreatedDate');
        Id recordId = (Id) record.get('Id');
        if (D365Setting != null 
            && String.isNotBlank(D365Setting.ValidCurrencies__c) 
            && D365Setting.ValidCurrencies__c.contains(currencyVal)) {
            D365Mapping__mdt mapping = D365Map.get(currencyVal);
            if (mapping != null) {
                if (recordId == null || mapping.ActivatedDate__c == null || mapping.ActivatedDate__c <= createdDate) {
                    return true;
                }
            }
        }
        return false;
    }
    
    public static Boolean isProductionOrg() {
        Organization org = [select IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        return !org.IsSandbox;
    }
    
    public static Map <String, D365Mapping__mdt> D365Map {
        get {
            if (D365Map == null) {
                D365Map = new Map <String, D365Mapping__mdt> ();
                for (D365Mapping__mdt mapping : [SELECT Id, BusinessUnit__c, Label, DefaultWarehouseId__c, ActivatedDate__c FROM D365Mapping__mdt]) {
                    D365Map.put(mapping.Label, mapping);
                }
            }
            return D365Map;
        }
        private set;
    }
    
    public static Asset getMatchingAsset(Asset assetRecord, Account accountRecord) {
        Asset foundAsset;
        if (assetRecord != null && accountRecord != null) {
            for (Asset existingAssetRecord : [SELECT Id, Batch_Code__c, Product2Id, PurchaseDate FROM Asset 
                                  WHERE AccountId = :accountRecord.Id
                                  AND IsAutoRegistered__c = true
                                  AND CustomerRegistrationDate__c = null]) {
                if (assetRecord.Product2Id == existingAssetRecord.Product2Id && assetRecord.PurchaseDate == existingAssetRecord.PurchaseDate) {
                    foundAsset = existingAssetRecord;
                    if (assetRecord.Batch_Code__c == existingAssetRecord.Batch_Code__c) {
                        break;
                    }
                }
            }
        }
        return foundAsset; 
    }
    
    public static Map<String, Account> findExistingAccount(Set<String> emails) {
        Map<String, Account> accountsByEmail = new Map<String, Account>();
        for (Account acc : [SELECT Id, BillingStreet, Firstname, LastName, Marketing_Opt_In__c, PersonEmail 
                            FROM Account 
                            WHERE PersonEmail =: emails AND RecordType.Name = 'Person Account']) {
            accountsByEmail.put(acc.PersonEmail, acc);
        }
        return accountsByEmail;
    }
    
    public static InventorySetting__c INVENTORY_SETTING {
        get {
            if (INVENTORY_SETTING == null) {
                INVENTORY_SETTING = InventorySetting__c.getOrgDefaults();
                if (Test.isRunningTest() && INVENTORY_SETTING == null) {
                    INVENTORY_SETTING = new InventorySetting__c(AXAccounts__c = 'CUS20577');
                }
            }
            return INVENTORY_SETTING;
        }
        private set;
    }
    
    public static Boolean isAvailableToSell(Order orderObj, Product2 productObj) {
        Boolean result = false;
        if (productObj.Available_To_Sell__c || 
            (orderObj.Type == 'Accommodation' 
            && String.isNotBlank(orderObj.AX_Order_Account__c) 
            && INVENTORY_SETTING.AXAccounts__c.contains(orderObj.AX_Order_Account__c)
            && productObj.AX_Reserved_Inventory__c > 0)) {
            result = true;
        } 
        return result;
    }
    public static Asset getAssetForExistingAccount(String accountId, Asset assetRecord)
    {        
        Asset foundAsset;
        List<Asset> lstAsset = [select id,Batch_Code__c, Product2Id, PurchaseDate, CustomerRegistrationDate__c, 
                                IsAutoRegistered__c,Asset_Code__c,ExactOfferCode__c FROM Asset WHERE 
                                AccountId = :accountId AND Product2Id=:assetRecord.Product2Id];
        if(lstAsset.size()>0)
        {
            Boolean isMatchFound = false;
            for(Asset objAsset:lstAsset)
            {
                if(String.IsNotBlank(objAsset.Batch_Code__c) && String.IsNotBlank(assetRecord.Batch_Code__c) && objAsset.Batch_Code__c == assetRecord.Batch_Code__c)
                {
                    foundAsset = objAsset;
                    break;
                }
                if(objAsset.PurchaseDate!=null && assetRecord.PurchaseDate!=null && objAsset.PurchaseDate == assetRecord.PurchaseDate)
                {
                    foundAsset = objAsset;
                    break;
                }
            }                       
        }
        return foundAsset;                 
     }


    
}