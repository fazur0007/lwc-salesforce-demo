public without sharing class BILTProductRegistrations_Schedule implements Schedulable, Database.AllowsCallouts {
    
    private static final Map<String, String> COUNTRY_CURRENCY_CODES = new Map<String, String> {
        'United States' => 'USD',
        'Australia' => 'AUD',
        'Canada' => 'CAD',
        null => 'USD'
    };
    
    public static final Map<String, String> COUNTRY_CODES  {
        get {
            if (COUNTRY_CODES == null) {
                COUNTRY_CODES = new Map<String, String>();
                Schema.DescribeFieldResult fieldResult = Account.BillingCountrycode.getDescribe(); 
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
                for ( Schema.PicklistEntry f : ple ) { 
                    COUNTRY_CODES.put(f.getLabel(), f.getValue()); 
                }
            }
            return COUNTRY_CODES;
        }
        private set;
    }
    
    public static Map<String, Map<String, String>> COUNTRY_STATE_MAP {
        get {
            if (COUNTRY_STATE_MAP == null) { 
                COUNTRY_STATE_MAP = new Map<String, Map<String,String>>();
                Schema.sObjectField dependToken = Account.BillingStateCode;
                Schema.DescribeFieldResult depend = dependToken.getDescribe();
                Schema.sObjectField controlToken = depend.getController();

                Schema.DescribeFieldResult control = controlToken.getDescribe();
                List<Schema.PicklistEntry> controlEntries = control.getPicklistValues();

                String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
                
                for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
                    if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                        List<String> base64chars =
                                String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                        for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                            Object controlValue =
                                    (controlEntries == null
                                            ?   (Object) (index == 1)
                                            :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                                    );
                            Integer bitIndex = index / 6;
                            if (bitIndex > base64chars.size() - 1) {
                                break;
                            }
                            Integer bitShift = 5 - Math.mod(index, 6);
                            if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                                continue;
                            String countryCode = controlEntries[index].getValue();
                            if (!COUNTRY_STATE_MAP.containsKey(countryCode)) {
                                COUNTRY_STATE_MAP.put(countryCode, new Map<String, String>());
                            }
                            COUNTRY_STATE_MAP.get(countryCode).put(entry.getLabel(), entry.getValue());
                        }
                    }
                }
            }
            return COUNTRY_STATE_MAP;
        }
        private set;
    }
    
    private static final String DEFAULT_CURRENCYISOCODE = 'USD';
    private static final String ASSET_STATUS_REGISTERED = 'Registered';
    private static final String RECORD_TYPE_PERSON_ACCOUNT = 'Person Account';
    
    public void execute(SchedulableContext sc) {  
        fetchAndSaveProductRegistrations();
    }
    
    @future(callout=true)
    public static void fetchAndSaveProductRegistrations() {
        try {
            List<Error_Log__c> errorLogs = new List<Error_Log__c>();
            BILT.ProductRegistrationResponse response = BILTUtility.getProductRegistrations();
            if (response != null) {
                if (response.data != null && response.data.size() > 0) {
                    Set<String> modelNumbers = new Set<String>();
                    Set<String> brands = new Set<String>();
                    Set<String> currencyIsoCodes = new Set<String> { DEFAULT_CURRENCYISOCODE };
                    Map<String, BILT.UserInfo> emailUserInfoMap = new Map<String, BILT.UserInfo>();
                    Map<String, List<BILT.Registration>> emailRegistrationsMap = new Map<String, List<BILT.Registration>>();
                    
                    for (BILT.Data d : response.data) {
                        brands.add(d.manufacturerName);
                        modelNumbers.add(d.modelNumber + '%');
                        if (d.registrations != null && d.registrations.size() > 0) {
                            for (BILT.Registration reg : d.registrations) {
                                if (reg.notClassifiedAttributes != null && String.isNotBlank(reg.notClassifiedAttributes.COUNTRY)) {
                                    currencyIsoCodes.add(COUNTRY_CURRENCY_CODES.get(reg.notClassifiedAttributes.COUNTRY.toUpperCase()));
                                }
                                emailUserInfoMap.put(reg.attributes.user_info.email, reg.attributes.user_info);
                                if (!emailRegistrationsMap.containsKey(reg.attributes.user_info.email)) {
                                    emailRegistrationsMap.put(reg.attributes.user_info.email, new List<BILT.Registration> { reg });
                                } else {
                                    emailRegistrationsMap.get(reg.attributes.user_info.email).add(reg);
                                }
                            }
                        }
                    }
                    
                    if (emailUserInfoMap.size() > 0) {
                        Id personAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RECORD_TYPE_PERSON_ACCOUNT).getRecordTypeId();
                        Map<String, Product2> productMap = new Map<String, Product2>();
                        for (Product2 prod : [SELECT Id, Name, Description, 
                                                Brand__c, CurrencyIsoCode
                                              FROM Product2 
                                              WHERE Finished_Good__c = true
                                                AND Spare_Part__c = False 
                                                AND Accessory__c = False
                                                AND IsActive = true
                                                AND Product_Type__c = 'FG'
                                                AND CurrencyIsoCode = :currencyIsoCodes
                                                AND Brand__c = :brands
                                                AND Name LIKE :modelNumbers
                                              ORDER BY Description]) {
                            String modelNumber = prod.Name;
                            for (String mNumber : modelNumbers) {
                                mNumber = mNumber.removeEnd('%');
                                if (prod.Name.startsWith(mNumber)) {
                                    modelNumber = mNumber;
                                    break;
                                }
                            }
                            String key = prod.Brand__c + modelNumber + prod.CurrencyIsoCode;
                            if (!productMap.containsKey(key)) {
                                productMap.put(key, prod);
                            }
                        }
                        Map<String, Account> existingAccounts = Utility.findExistingAccount(emailUserInfoMap.keySet());
                        
                        Map<String, Account> accountsToUpsert = new Map<String, Account>();
                        List<Asset> assetsToInsert = new List<Asset>();
                        
                        for (BILT.Data d : response.data) {
                            if (d.registrations != null && d.registrations.size() > 0) {
                                for (BILT.Registration reg : d.registrations) {
                                    String currencyCode = DEFAULT_CURRENCYISOCODE;
                                    
                                    if (reg.attributes.user_info != null && String.isNotBlank(reg.attributes.user_info.COUNTRY)) {
                                        currencyCode = COUNTRY_CURRENCY_CODES.get(reg.attributes.user_info.COUNTRY);
                                    }
                                    System.debug(currencyCode);
                                    
                                    String productKey = d.manufacturerName + d.modelNumber + currencyCode;
                                    System.debug(productKey);
                                    Product2 foundProduct = productMap.get(productKey);
                                    System.debug(foundProduct);
                                    if (foundProduct != null) {
                                        String email = reg.attributes.user_info.email;
                                        String firstName = reg.attributes.user_info.firstName;
                                        String lastName = reg.attributes.user_info.lastName;
                                        email = email.toLowerCase();
                                        
                                        Account newAccount = new Account(
                                            FirstName = firstName,
                                            LastName = lastName,
                                            PersonEmail = email,
                                            CurrencyIsoCode = currencyCode,
                                            RecordTypeId = personAccountRtId
                                        );
                                        
                                        newAccount.Subscribe_to_our_newsletter__c = 'NO'.equalsIgnoreCase(reg.attributes.user_info.OPT_IN_MARKETINGEMAILS) ? false : true;
                                        newAccount.Phone = reg.attributes.user_info.PHONE;
                                        System.debug(reg);
                                        Boolean hasError = validateAndSetAddress(reg.attributes.user_info, newAccount);
                                        
                                        if (hasError) {
                                            String errorString = 'Record could not be created: ' + JSON.serialize(reg);
                                            errorLogs.add(ErrorLog.logErrorActivity('', errorString, 'BILT Product Registration Error', false, 'Error', ''));
                                            continue;
                                        }

                                        if (existingAccounts.containsKey(email)) {
                                            Account existingAccount = existingAccounts.get(email);
                                            newAccount.Id = existingAccount.Id;
                                        }
                                        System.debug('&&&' + newAccount);
                                        accountsToUpsert.put(email, newAccount);
                                        
                                        Asset newAsset = new Asset(
                                            Product2Id = foundProduct.Id,
                                            Name = firstName + ' ' + lastName + ' - ' + foundProduct.Name,
                                            Account_Email__c = email,
                                            CurrencyIsoCode = currencyCode,
                                            Status = ASSET_STATUS_REGISTERED,
                                            PurchaseDate = reg.purchaseDate.date(),
                                            CustomerRegistrationDate__c = reg.registered.date(),
                                            Channel__c = 'BILT',
                                            SerialNumber = reg.attributes.product_info.serialNum,
                                            Where_did_you_purchase__c = reg.attributes.product_info.placeOfPurchase
                                        );
                                        System.debug('***' + newAsset);
                                        assetsToInsert.add(newAsset);
                                    } else {
                                        String errorString = 'Record could not be created: ' + JSON.serialize(reg);
                                        errorLogs.add(ErrorLog.logErrorActivity('', errorString, 'BILT Product Registration Error', false, 'Error', ''));
                                        continue;
                                    }
                                }
                            }
                        }
                        if (accountsToUpsert.size() > 0) {
                            System.debug(accountsToUpsert);
                            upsert accountsToUpsert.values();
                            
                            for (Asset newAsset : assetsToInsert) {
                                if (accountsToUpsert.containsKey(newAsset.Account_Email__c)) {
                                    Account acc = accountsToUpsert.get(newAsset.Account_Email__c);
                                    newAsset.AccountId = acc.Id;
                                }
                            }
                            upsert assetsToInsert;
                        }
                        if (errorLogs.size() > 0) {
                            insert errorLogs;
                        }
                    }
                }
                
                if (response.context != null) {
                    System.enqueueJob(new BILTUtility.UpdateTimeStamp(String.valueOf(response.context.endTimestamp)));
                }
            }
        } catch(Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'BILT Product Registration Error', true);
        }
    }
    
    private static Boolean validateAndSetAddress(BILT.UserInfo userInfo, Account newAccount) {
        System.debug(userInfo.COUNTRY);
        if (String.isBlank(userInfo.COUNTRY) || !COUNTRY_CODES.containsKey(userInfo.COUNTRY)) {
            return true;
        }
        System.debug(userInfo.STATE);
        if (String.isNotBlank(userInfo.STATE)) {
            Map<String, String> stateMap = COUNTRY_STATE_MAP.get(COUNTRY_CODES.get(userInfo.COUNTRY));
            if (stateMap != null && stateMap.size() > 0) {
                Set<String> stateCodes = new Set<String> (stateMap.values());
                String state = userInfo.STATE;
                if (stateMap.containsKey(state)) {
                    state = stateMap.get(state);
                } else if (stateCodes.contains(state)) {
                    //do nothing
                } else {
                    return true;
                }
                newAccount.BillingStateCode = state;
                newAccount.ShippingStateCode = state;
            }
        }
        
        newAccount.Billing_Street_Line_1__c = userInfo.ADDRESS_LINE1;
        newAccount.Billing_Street_Line_2__c = userInfo.ADDRESS_LINE2;
        newAccount.BillingCountryCode = COUNTRY_CODES.get(userInfo.COUNTRY);
        newAccount.BillingCity = userInfo.CITY;
        newAccount.BillingPostalCode = userInfo.ZIP_CODE;
        
        newAccount.Shipping_Street_Line_1__c = userInfo.ADDRESS_LINE1;
        newAccount.Shipping_Street_Line_2__c = userInfo.ADDRESS_LINE2;
        newAccount.ShippingCountryCode = COUNTRY_CODES.get(userInfo.COUNTRY);
        newAccount.ShippingCity = userInfo.CITY;
        newAccount.ShippingPostalCode = userInfo.ZIP_CODE;
        
        return false;
    }
}