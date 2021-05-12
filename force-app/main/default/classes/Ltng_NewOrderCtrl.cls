/*
 * @Dev : Fazurulla & Abhishek
 * @Date : 01/02/2020
 * @Ltng_NewOrderCtrl : This controller is responsible for handling new order creation process
 *
 */
public class Ltng_NewOrderCtrl {
    public class Pricebookentrywrapper {
        @AuraEnabled public PricebookEntry pberecord  { get; set;}
        @AuraEnabled public Decimal promotionalPrice { get; set;}
        @AuraEnabled public String promotionalPricewithCurrency { get; set;}
        @AuraEnabled public Boolean selected {get; set;}
        @AuraEnabled public Integer quantity {get; set;}
        @AuraEnabled public Decimal unitPrice { get; set;}
        @AuraEnabled public String qtyErrorMessage { get; set;}
        @AuraEnabled public String promotionAppliedMessage { get; set;}
        @AuraEnabled public Boolean isPromotionApplied {get; set;}
        @AuraEnabled public Boolean isAvailableToSell { get; set; }
    }
    public class ProductRelatedList {
        
        @AuraEnabled public List<Map<String, String>> relatedProducts { get; set;}
        @AuraEnabled public List<String> grindTypeList { get; set;}
        
        @AuraEnabled public Integer quantity {get; set;} 
        @AuraEnabled public Decimal unitPrice { get; set;}
        
        @AuraEnabled public Integer relatedProductQuantity {get; set;}
        @AuraEnabled public Decimal relatedProductUnitPrice {get; set;} 
        @AuraEnabled public String  selectedRelatedProduct{get; set;} 
        @AuraEnabled public String  selectedGrindType {get; set;} 
        
        @AuraEnabled public String  PricebookEntryId {get; set;} 
        @AuraEnabled public String  Product2Id  {get; set;} 
        @AuraEnabled public String productRecName { get; set;}
        
        @AuraEnabled public Boolean Available_To_Sell {get; set;} 
    }

    @AuraEnabled
    public static List < ProductRelatedList > doGetProductsandRelatedProducts(List<String> listOfProductsIds,String orderId) {
        List < Order > ordValues = [select Id, PriceBook2Id, CurrencyIsoCode, OrderCustomerType__c, Type, AX_Order_Account__c from Order where Id =: orderId];
        system.debug('********'+listOfProductsIds);
        
        List<product2 > listOfProducts = [SELECT Id,AX_Item_Number__c,Description,Name,MAP__c,Quantity_Available__c,Serviceable__c,Service_Charge__c,Spare_Parts_Use_Internal__c,Spare_Parts_Use_External__c,Available_To_Sell__c,Grind__c,AX_Reserved_Inventory__c,
                                          (Select Id,Name,MasterProduct__c,Type__c,Product__c from RelatedProducts1__r),
                                          (select Id,Name,Product__c,Type__c from RelatedProducts__r) 
                                          FROM product2 WHERE ID IN : listOfProductsIds]; 
        
        List < PricebookEntry > priceBookEntList = [Select id, unitprice, product2Id,product2.AX_Item_Number__c,product2.Grind__c,
                                                    product2.Name,product2.Quantity_Available__c,product2.Serviceable__c,product2.Service_Charge__c,product2.Spare_Parts_Use_External__c,
                                                    product2.Available_To_Sell__c,
                                                    Product2.AX_Reserved_Inventory__c
                                                    From PricebookEntry where product2Id  IN : listOfProductsIds AND Pricebook2Id =: ordValues[0].PriceBook2Id and product2.Product_Type__c!='EXTWTY'];
        
        List<RelatedProducts__c> listOfRelatedProducts = [Select Id,Product__r.Name,Product__r.MAP__c,Product__r.Description,MasterProduct__c,Type__c,Product__c from RelatedProducts__c where MasterProduct__c IN : listOfProductsIds and Product__r.serviceContractUseType__c='New'];    
        Map<String, List<Map<String, String>>> mapOfProducts = new Map<String, List<Map<String, String>>>();
        Map<String, Decimal> mapOfUnitPrice = new Map<String,Decimal>();
        for(RelatedProducts__c relatedProductRec : listOfRelatedProducts) {
            if(mapOfProducts.containsKey(relatedProductRec.MasterProduct__c)) {
                List<Map<String, String>> listOfReleatedProductNames = mapOfProducts.get(relatedProductRec.MasterProduct__c);
                listOfReleatedProductNames.add(new Map<String, String>{'value' => relatedProductRec.Product__c, 'label' => relatedProductRec.Product__r.Description + ' - ' + relatedProductRec.Product__r.MAP__c});
                mapOfProducts.put(relatedProductRec.MasterProduct__c, listOfReleatedProductNames);
            } else {
                List<Map<String, String>> listOfReleatedProductNames = new  List<Map<String, String>>();
                listOfReleatedProductNames.add(new Map<String, String>{'value' => relatedProductRec.Product__c, 'label' => relatedProductRec.Product__r.Description + ' - ' + relatedProductRec.Product__r.MAP__c});
                mapOfProducts.put(relatedProductRec.MasterProduct__c, listOfReleatedProductNames);
            }
            mapOfUnitPrice.put(relatedProductRec.MasterProduct__c,50.00);
        }
        system.debug(JSON.serializePretty(mapOfProducts));
        
        
        List < ProductRelatedList > productWrapper = new List < ProductRelatedList > ();
        for(PricebookEntry product2Record : priceBookEntList){
            
            ProductRelatedList productReletedRec = new ProductRelatedList ();
            
            productReletedRec.productRecName = product2Record.product2.Name;
            if(mapOfProducts.containsKey(product2Record.product2Id)){
                productReletedRec.relatedProducts = mapOfProducts.get(product2Record.product2Id);
            }
            productReletedRec.PricebookEntryId = product2Record.Id;
            productReletedRec.Product2Id = product2Record.Product2Id;
            productReletedRec.Available_To_Sell = Utility.isAvailableToSell(ordValues[0], product2Record.Product2);
            productReletedRec.selectedRelatedProduct = '';
            productReletedRec.quantity = 0;
            productReletedRec.selectedGrindType = '';
            productReletedRec.grindTypeList = product2Record.product2.Grind__c != null ? product2Record.product2.Grind__c.split(';') : new List<String>();
            if(mapOfUnitPrice.containsKey(product2Record.product2Id)){
                productReletedRec.relatedProductUnitPrice = mapOfUnitPrice.get(product2Record.product2Id);
            }
            productReletedRec.relatedProductQuantity = 0;
            productReletedRec.unitPrice = product2Record.unitprice;
            productWrapper.add(productReletedRec);
        }
        return productWrapper;
    }
    /*
    public static List<Map<String, String>>  doGetRelatedProducts(List<RelatedProducts__c> relatedProductsList ){
        List<Map<String, String>> listOfReleatedProductNames = new List<Map<String, String>>();
        for(RelatedProducts__c relatedProductRec : relatedProductsList){
            listOfReleatedProductNames.add(new Map<String, String>{'value' => relatedProductRec.Id, 'label' => relatedProductRec.Name});
        }
        return listOfReleatedProductNames;
    }
    */
    @AuraEnabled
    public static Map < String, Object > loadInit(String recordId) {
        Map < String, Object > mapOfObjects = new Map < String, Object > ();
        String orderType;
        String brand;
        Case caseRec;
        String returnURL;
        boolean showBrandSelection;
        Boolean showSampleOrder;
        Boolean isNOTServicable;
        boolean accomodationNOTAvailable;
        String idParam = null;
        String accountId = null;
        String objectType = null;
        Boolean isAUSB2COrder;
        Boolean isWorkOrderPresent = false;
        String currecnyCode;
        Boolean isPortalUser;
        User currentUser;
        String region;
        String profile;
        Boolean isPersonAccount;
        
        //Id serviceOrderId;
        String selectedDeliveryOption;
        Boolean isEmpPortalUser;
        if (String.isNotBlank(recordId)) {
            idParam = recordId;
        }
        currentUser = [SELECT id, IsPortalEnabled, AccountID, DefaultCurrencyIsoCode, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        isPortalUser = currentUser.IsPortalEnabled;
        profile = currentUser.Profile.Name;
        
        orderType = '';
        brand = '';
        isNOTServicable = true;
        accomodationNOTAvailable = true;
        showSampleOrder = false;
        showBrandSelection = true;
        isAUSB2COrder = false;
        //String excludedCurrencies = System.Label.Excluded_Currencies_for_required_Email_and_Phone;

        if (!(idParam != null && idParam != '')) {
            idParam = currentUser.AccountID;
        }
        if (idParam != null && idParam != '') {
            objectType = Id.valueOf(idParam).getSObjectType().getDescribe().getName();
        }
 
        list < All_Literal__mdt > brandSelection = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName = 'HideBrandSelectionForB2CAUS'];
        if (objectType == 'Case') {
            List<Order> caseInOrderList = [SELECT Id, Case__c FROM Order where Case__c= : idParam limit 1];
            
            Case caseObj = [Select Id, CurrencyIsoCode, AccountId, Account.RecordType.DeveloperName, Account.PersonEmail, Account.Phone, Account.Business_Email__c, Account.CurrencyIsoCode From Case Where Id =: idParam Limit 1];
                        
            /* SF-746: Changes to make Phone and Email mandatory*/          
            /*if(caseObj != Null && caseObj.AccountId != Null && caseObj.Account.RecordType.DeveloperName == 'PersonAccount' 
            && (String.isBlank(caseObj.Account.PersonEmail) || String.isBlank(caseObj.Account.Phone)) && !excludedCurrencies.containsIgnoreCase(';'+caseObj.Account.CurrencyIsoCode+';')){
                throw new AuraHandledException(System.Label.Email_and_Phone_Number_Required);
            }*/
            if (String.isNotBlank(caseObj.CurrencyIsoCode)) {
                currecnyCode = caseObj.CurrencyIsoCode;
            }
            region = Utility.regionBased(currecnyCode);
            
            list < Case > caseList = [SELECT id, Product__c, Product__r.Serviceable__c, Warranty__c, AccountId, Account.RecordTypeId, Account.RecordType.DeveloperName,
                                      Service_Center__c, ReturnLocation__c
                                      FROM Case WHERE Id =: idParam
                                     ];
            if (caseList != null && caseList.size() > 0) {
                if (caseList[0].Product__c != null && caseList[0].Product__r.Serviceable__c && caseList[0].Service_Center__c != null) {
                    isNOTServicable = false;
                }
                list < All_Literal__mdt > literalRecList = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName = 'AllowAccommodationWithoutReturnCenter'];
                if ((caseList[0].ReturnLocation__c != null && caseList[0].Warranty__c != null && caseList[0].Warranty__c != '' &&
                     (caseList[0].Warranty__c.equalsIgnoreCase('In Warranty') || caseList[0].Warranty__c.equalsIgnoreCase('Extended Warranty'))) ||
                    (literalRecList != null && literalRecList.size() > 0 && Boolean.valueOf(literalRecList[0].Value__c))) {
                        accomodationNOTAvailable = false;
                    }
                if (caseList[0].AccountId != null && caseList[0].Account.RecordTypeId != null && caseList[0].Account.RecordType.DeveloperName != null &&
                    caseList[0].Account.RecordType.DeveloperName != '' && caseList[0].Account.RecordType.DeveloperName.equalsIgnoreCase('Business_Account') && !isPortalUser) {
                        showSampleOrder = true;
                    }
                else if (brandSelection[0].Value__c.equalsIgnoreCase('Yes') && caseList[0].AccountId != null && caseList[0].Account.RecordTypeId != null &&
                         caseList[0].Account.RecordType.DeveloperName != null && caseList[0].Account.RecordType.DeveloperName != '' &&
                         caseList[0].Account.RecordType.DeveloperName.equalsIgnoreCase('PersonAccount')) {
                             /* to hide brands for B2c order for AUS */
                             if (currecnyCode != null && currecnyCode != '' && currecnyCode == 'AUD') {
                                 isAUSB2COrder = true;
                                 
                             }
                         }
                list < WorkOrder > workOrderList = [select id from WorkOrder where Case.id =: caseList[0].id];
                if (workOrderList != null && workOrderList.size() > 0) {
                    isWorkOrderPresent = true;
                }
                else {
                    isWorkOrderPresent = false;
                }
            }
            
        }
        else if (objectType == 'Account') {
            Account accountObj = [Select Id, CurrencyIsoCode,IsPersonAccount,PersonEmail, Phone, Business_Email__c, RecordType.DeveloperName From Account Where Id =: idParam Limit 1];
            
            isPersonAccount = (accountObj.IsPersonAccount == null || accountObj.IsPersonAccount == false) ? false : true;

            /* SF-746: Changes to make Phone and Email mandatory*/           
            /*if(accountObj != Null && accountObj.RecordType.DeveloperName == 'PersonAccount' && (String.isBlank(accountObj.PersonEmail) || String.isBlank(accountObj.Phone)) 
            && !excludedCurrencies.containsIgnoreCase(';'+ accountObj.CurrencyIsoCode +';')){
                throw new AuraHandledException(System.Label.Email_and_Phone_Number_Required);
            }*/
            
            if (String.isNotBlank(accountObj.CurrencyIsoCode)) {
                currecnyCode = accountObj.CurrencyIsoCode;
            }
            region = Utility.regionBased(currecnyCode);
            
            list < Account > accountList = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Account WHERE Id =: idParam];
            if (accountList != null && accountList.size() > 0 && accountList[0].RecordTypeId != null && accountList[0].RecordType.DeveloperName != null &&
                    accountList[0].RecordType.DeveloperName != '' && accountList[0].RecordType.DeveloperName.equalsIgnoreCase('Business_Account') && !isPortalUser) {
                        showSampleOrder = true;
                }
            else if (brandSelection[0].Value__c.equalsIgnoreCase('Yes') && accountList != null && accountList.size() > 0 && accountList[0].RecordTypeId != null &&
                     accountList[0].RecordType.DeveloperName != null && accountList[0].RecordType.DeveloperName != '' &&
                     accountList[0].RecordType.DeveloperName.equalsIgnoreCase('PersonAccount')) {
                         /* to hide brands for B2c order for AUS */
                         if (currecnyCode != null && currecnyCode != '' && currecnyCode == 'AUD') {
                             isAUSB2COrder = true;
                         }
                }
            
        }
        //CHecking it is B2B account OR AUS B2C Order
        if (showSampleOrder || isAUSB2COrder) {
            if (currecnyCode != null && currecnyCode != '') {
                if (!(currecnyCode.equalsIgnoreCase('USD') || currecnyCode.equalsIgnoreCase('CAD'))) {
                    if (currecnyCode.equalsIgnoreCase('GBP') || currecnyCode.equalsIgnoreCase('EUR') || currecnyCode.equalsIgnoreCase('CHF')) {
                        brand = 'Sage';
                    }
                    else {
                        brand = 'Breville';
                    }
                    //showBrandSelection = false;
                }
            }
        }
        isEmpPortalUser = isPortalUser && (profile == 'Employee Portal Community');
        mapOfObjects.put('isPortalUser', isPortalUser);
        mapOfObjects.put('region', region);
        mapOfObjects.put('isPersonAccount', isPersonAccount); 
        mapOfObjects.put('profile', profile);
        mapOfObjects.put('objectType', objectType);
        mapOfObjects.put('accomodationNOTAvailable', accomodationNOTAvailable);
        mapOfObjects.put('showSampleOrder', showSampleOrder);
        mapOfObjects.put('showBrandSelection', showBrandSelection);
        mapOfObjects.put('orderType', orderType);
        mapOfObjects.put('brand', brand);
        mapOfObjects.put('isNOTServicable', isNOTServicable);
        mapOfObjects.put('isAUSB2COrder', isAUSB2COrder);
        mapOfObjects.put('isWorkOrderPresent', isWorkOrderPresent);
        mapOfObjects.put('currecnyCode', currecnyCode);
        mapOfObjects.put('currentUser', currentUser);
        mapOfObjects.put('selectedDeliveryOption', String.isNotBlank(selectedDeliveryOption) ? selectedDeliveryOption : '');
        mapOfObjects.put('isEmpPortalUser', isEmpPortalUser);
        
        return mapOfObjects;
    }
    
    
    @AuraEnabled
    public static Map < String, String > getBrands(Boolean showBrandSelection, String region) {
        try
        {
            system.debug(showBrandSelection+'********'+region);
            return Ltng_OrganizationUtil_Cls.getBrands(showBrandSelection,region);
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map < String, String > getOrderTypes(Boolean isPortalUser, String region, String profile, String objectType, boolean accomodationNOTAvailable, Boolean showSampleOrder) {
        try
        {
            return Ltng_OrganizationUtil_Cls.getOrderTypes(isPortalUser,region,profile,objectType,accomodationNOTAvailable,showSampleOrder);
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String save(String idParam, String brand, String orderType, String currecnyCode, String objectType, Boolean isPortalUser, String region, boolean isEmpPortalUser, String selectedDeliveryOption,String shimentMethod) {
        if ((brand != null && brand != '' && orderType != null && orderType != '')) {
            if (orderType == 'Work Order') {
                system.debug('starting in orderType ::' + orderType);
                Case caseRecord = getCase(Ltng_OrganizationUtil_Cls.getWorkOrderFieldMappingForCase(), '', idParam);
                if (caseRecord != null) {
                    if (caseRecord.Service_Center__c == null) {
                        throw new AuraHandledException('Please assign Service Center to the Case');
                    }
                    WorkOrder workorder = createWorkOrder(caseRecord, brand, currecnyCode, orderType);
                    if (workorder != null) {
                        return workorder.Id;
                    }else{
                        if (!Test.isRunningTest()) {
                            throw new AuraHandledException('Error while creating WorkOrder');
                        }
                    }
                }
            }
            else if (orderType == 'Sale' || orderType == 'Sample' || orderType == 'Accommodation' || orderType == 'Employee Sale' ||
                     orderType == 'Repair Replacement' || orderType == 'Retail Employee Sales' || orderType == 'Partner & Associate Sales' ||
                     orderType == 'Retail Event Sales' || orderType == 'Holiday Promo' || orderType == 'Specialty Roaster' || orderType == 'Event Sales Coffee') {
                         system.debug('starting in orderType sale ::' + orderType);
                         if (objectType == 'Account') {
                             system.debug('starting in objectType  sale ::' + objectType);
                             Account accountRecord = getAccount(Ltng_OrganizationUtil_Cls.getOrderFieldMappingForAccount(), idParam);
                             if (accountRecord != null) {
                                 if (accountRecord.BillingCity != null && accountRecord.BillingCity != '' &&
                                     accountRecord.BillingCountryCode != null && accountRecord.BillingCountryCode != '' &&
                                     ((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR' ||
                                       accountRecord.CurrencyIsoCode == 'CHF') ||
                                      (accountRecord.BillingStateCode != null && accountRecord.BillingStateCode != '')) &&
                                     (((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR') &&
                                       accountRecord.BillingCountryCode == 'IE') ||
                                      (accountRecord.BillingPostalCode != null && accountRecord.BillingPostalCode != '')) &&
                                     accountRecord.BillingStreet != null && accountRecord.BillingStreet != '' &&
                                     accountRecord.ShippingCountryCode != null && accountRecord.ShippingCountryCode != '' &&
                                     accountRecord.ShippingCity != null && accountRecord.ShippingCity != '' &&
                                     ((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR' ||
                                       accountRecord.CurrencyIsoCode == 'CHF') ||
                                      (accountRecord.ShippingStateCode != null && accountRecord.ShippingStateCode != '')) &&
                                     accountRecord.ShippingStreet != null && accountRecord.ShippingStreet != '' &&
                                     (((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR') &&
                                       accountRecord.ShippingCountryCode == 'IE') ||
                                      (accountRecord.ShippingPostalCode != null && accountRecord.ShippingPostalCode != ''))) {
                                          system.debug('inner loop');
                                          Order orderRecord = createOrderAccount(accountRecord, orderType, brand, isPortalUser, region, isEmpPortalUser, selectedDeliveryOption,shimentMethod);
                                          if (orderRecord != null) {
                                              return orderRecord.id;
                                          }
                                          
                                      }
                                 else {
                                     throw new AuraHandledException('Please enter complete Billing and Shipping Address');
                                 }
                             }
                         }
                         else {
                             Case caseRecord = getCase(Ltng_OrganizationUtil_Cls.getOrderFieldMappingForCase(),
                                                       ' Service_Center__c, Service_Center__r.Type, Priority, QC_Alert__c, QC_Alert__r.RecordTypeId, QC_Alert__r.RecordType.DeveloperName, ', idParam);
                             if (caseRecord != null) {
                                 if (caseRecord.AccountId != null &&
                                     caseRecord.Account.BillingCity != null && caseRecord.Account.BillingCity != '' &&
                                     caseRecord.Account.BillingCountryCode != null && caseRecord.Account.BillingCountryCode != '' &&
                                     ((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR' || caseRecord.CurrencyIsoCode == 'CHF') ||
                                      (caseRecord.Account.BillingStateCode != null && caseRecord.Account.BillingStateCode != '')) &&
                                     (((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR') && caseRecord.Account.BillingCountryCode == 'IE') ||
                                      (caseRecord.Account.BillingPostalCode != null && caseRecord.Account.BillingPostalCode != '')) &&
                                     caseRecord.Account.BillingStreet != null && caseRecord.Account.BillingStreet != '' &&
                                     caseRecord.Account.ShippingCountryCode != null && caseRecord.Account.ShippingCountryCode != '' &&
                                     caseRecord.Account.ShippingCity != null && caseRecord.Account.ShippingCity != '' &&
                                     ((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR' || caseRecord.CurrencyIsoCode == 'CHF') ||
                                      (caseRecord.Account.ShippingStateCode != null && caseRecord.Account.ShippingStateCode != '')) &&
                                     (((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR') && caseRecord.Account.ShippingCountryCode == 'IE') ||
                                      (caseRecord.Account.ShippingPostalCode != null && caseRecord.Account.ShippingPostalCode != ''))) {
                                          Order orderRecord = createOrder(caseRecord, orderType, brand, isPortalUser, region);
                                          if (orderRecord != null) {
                                              return orderRecord.id;
                                          }
                                          
                                      }
                                 else {
                                     throw new AuraHandledException('Please enter complete Billing and Shipping Address');
                                 }
                             }
                         }
                     }
        }
        else {
            throw new AuraHandledException('Please Select \'Brand\' and \'Type\' to proceed');
        }
        return null;
    }
    
    public static Case getCase(map < String, String > fieldMapping, String extraFields, String idParam) {
        
        List < String > caseFields = fieldMapping.values();
        String soql = '' +
            ' select ' + extraFields + String.join(caseFields, ',') +
            ' from Case' +
            ' where id =:idParam';
        list < Case > caseList = Database.query(soql);
        if (caseList != null && caseList.size() > 0) {
            return caseList[0];
        }
        return null;
    }
    public static Account getAccount(map < String, String > fieldMapping, String idParam) {
        
        List < String > accountFields = fieldMapping.values();
        String soql = '' +
            ' select ' + String.join(accountFields, ',') +
            ' from Account' +
            ' where id =:idParam';
        list < Account > accountList = Database.query(soql);
        if (accountList != null && accountList.size() > 0) {
            return accountList[0];
        }
        return null;
    }
    
    public static WorkOrder createWorkOrder(Case caseRecord, String brand, String currecnyCode, String orderType) {
        WorkOrder workorder = new WorkOrder();
        map < String, String > workOrderFieldMapping = Ltng_OrganizationUtil_Cls.getWorkOrderFieldMappingForCase();
        String caseField = '';
        for (String workOrderField: workOrderFieldMapping.keySet()) {
            caseField = workOrderFieldMapping.get(workOrderField);
            if (!caseField.contains('.')) {
                workorder.put(workOrderField, caseRecord.get(caseField));
            }
            else {
                String[] referenceFields = caseField.split('\\.');
                workorder.put(workOrderField, caseRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        //,City,Country,CountryCode,PostalCode,State,StateCode,Street
        list < Account > workOrderAccount = [select id, FirstName, LastName, PersonEmail, Phone from Account where id =: workorder.AccountId];
        if (workOrderAccount != null && workOrderAccount.size() > 0) {
            workorder.FirstName__c = workOrderAccount[0].FirstName;
            workorder.LastName__c = workOrderAccount[0].LastName;
            workorder.Email__c = workOrderAccount[0].PersonEmail;
            workorder.Phone__c = workOrderAccount[0].Phone;
        }
        //checkServicePriceForWorkOrder(workorder);
        
        workorder.Brand__c = brand;
        
        RecordType recordTypeWorkOrder = [SELECT ID FROM RecordType WHERE Name = 'Work Order'
                                          AND sobjecttype = 'WorkOrder'
                                          LIMIT 1
                                         ][0];
        workOrder.RecordTypeId = recordTypeWorkOrder.Id;
        list < MasterTaxData__mdt > masterTaxDataList = [SELECT DeveloperName, IsZip2TaxApplicable__c, AddressFieldOnOrder__c, AddressFieldOnWorkOrder__c, TaxOnASC__c,
                                                         CacheDurationInDays__c FROM MasterTaxData__mdt WHERE DeveloperName =: currecnyCode
                                                        ];
        system.debug('workorder********'+workorder);
        if (masterTaxDataList != null && masterTaxDataList.size() > 0) {
            MasterTaxData__mdt masterTaxDataRecord = masterTaxDataList[0];
            if (masterTaxDataRecord.TaxOnASC__c) {
                try {
                    list < Account > accountList = [SELECT Id, BillingPostalCode, BillingStateCode, BillingCountryCode FROM Account WHERE Id =: workOrder.ServiceCentre__c];
                    if (accountList != null && accountList.size() > 0) {
                        TaxRate taxRateRecord = new TaxRate();
                        taxRateRecord.filterWorkOrders(workOrder, accountList[0]);
                    }
                    insert workorder;
                    system.debug('workorder insert ********'+workorder.Id);
                    return workorder;
                }
                catch (System.DmlException ex) {
                    System.debug(ex.getDmlMessage(0));
                    throw new AuraHandledException(ex.getDmlMessage(0));
                }
            }
            else {
                try {
                    list < Account > accountList = [SELECT Id, BillingPostalCode, BillingStateCode, BillingCountryCode FROM Account WHERE Id =: workOrder.AccountId];
                    if (accountList != null && accountList.size() > 0) {
                        TaxRate taxRateRecord = new TaxRate();
                        taxRateRecord.filterWorkOrders(workOrder, accountList[0]);
                    }
                    
                    insert workorder;
                    system.debug('workorder insert else ********'+workorder.Id);
                    return workorder;
                }
                catch (System.DmlException ex) {
                    if (!Test.isRunningTest()) {
                        throw new AuraHandledException(ex.getDmlMessage(0));
                    }
                }
            }
        }
        return null;
    }
    public static Order createOrder(Case caseRecord, String orderType, String brand, Boolean isPortalUser, String region) {
        Order orderRecord = new Order();
        map < String, String > OrderFieldMapping = Ltng_OrganizationUtil_Cls.getOrderFieldMappingForCase();
        String caseField = '';
        for (String orderField: OrderFieldMapping.keySet()) {
            caseField = OrderFieldMapping.get(orderField);
            if (!caseField.contains('.')) {
                orderRecord.put(orderField, caseRecord.get(caseField));
            }
            else {
                String[] referenceFields = caseField.split('\\.');
                orderRecord.put(orderField, caseRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        //QC_Alert__c, QC_Alert__r.RecordTypeId, QC_Alert__r.RecordType.DeveloperName,
        if (caseRecord.Priority != null && caseRecord.Priority.equalsIgnoreCase('Recall') && caseRecord.QC_Alert__c != null && caseRecord.QC_Alert__r.RecordTypeId != null &&
            caseRecord.QC_Alert__r.RecordType.DeveloperName != null && caseRecord.QC_Alert__r.RecordType.DeveloperName.equalsIgnoreCase('Recall')) {
                orderRecord.Recall_Fasttrack__c = true;
            }
        orderRecord.put('EffectiveDate', Date.today());
        orderRecord.put('Type', orderType);
        orderRecord.status = 'Open';
        orderRecord.Brand__c = brand;
        
        String currencyCode = (String) caseRecord.get('CurrencyIsoCode');
        
        TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(orderRecord);
        
        checkPriceBookForOrder(orderRecord, isPortalUser, orderType, region, brand);
        
        if (orderRecord.PriceBook2Id == null) {
            throw new AuraHandledException('Required pricebook not available.');
        }
        if (orderType != null && orderType != null && orderType.equalsIgnoreCase('Repair Replacement')) {
            list < WorkOrder > workOrderList = [SELECT Id FROM WorkOrder WHERE Status = 'Unrepairable'
                                                AND CaseId =: caseRecord.Id
                                               ];
            if (workOrderList != null && workOrderList.size() > 0) {
                orderRecord.ServiceOrder__c = workOrderList[0].Id;
            }
        }
        
        if (region != null) {
            orderRecord.Country__c = region;
        }
        try {
            insert orderRecord;
        }
        catch (System.DmlException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return orderRecord;
    }
    public static Order createOrderAccount(Account accountRecord, String orderType, String brand, Boolean isPortalUser, String region, Boolean isEmpPortalUser, String selectedDeliveryOption,String shimentMethod) {
        Order orderRecord = new Order();
        map < String, String > OrderFieldMapping = Ltng_OrganizationUtil_Cls.getOrderFieldMappingForAccount();
        String accountField = '';
        for (String orderField: OrderFieldMapping.keySet()) {
            accountField = OrderFieldMapping.get(orderField);
            if (!accountField.contains('.')) {
                orderRecord.put(orderField, accountRecord.get(accountField));
            }
            else {
                String[] referenceFields = accountField.split('\\.');
                orderRecord.put(orderField, accountRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        orderRecord.put('EffectiveDate', Date.today());
        orderRecord.put('Type', orderType); 
        //orderRecord.put('Shipping_Method__c', shimentMethod);
        orderRecord.status = 'Open';
        orderRecord.Brand__c = brand;
        String currencyCode = (String) accountRecord.get('CurrencyIsoCode');
        
        TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(orderRecord);
        
        checkPriceBookForOrder(orderRecord, isPortalUser, orderType, region, brand);
        
        if (orderRecord.PriceBook2Id == null) {
            throw new AuraHandledException('Required pricebook not available.');
        }
        
        if (region != null) {
            orderRecord.Country__c = region;
        }
        try {
            insert orderRecord;
        }
        catch (System.DmlException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return orderRecord;
    }
    public static void checkPriceBookForOrder(Order orderRecord, Boolean isPortalUser, String orderType, String region, String brand) {
        /* assingning pricebook of Account on User in case of ASC orders else assigning default pricebook */
        String typeOfOrder = '';
        Boolean isB2BOrder = false;
        
        if (orderRecord != null && orderRecord.AccountId != null) {
            Account orderAccount = [SELECT Id, RecordTypeId FROM Account WHERE Id =: orderRecord.AccountId];
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            if (orderAccount.RecordTypeId != personAccountRecordTypeId) {
                isB2BOrder = true;
            }
        }
        if (isPortalUser) {
            orderRecord.CreatedFromPortal__c = true;
            if (orderType.equalsIgnoreCase('Sample')) {
                typeOfOrder = 'Sample';
            }
            else if (orderType.equalsIgnoreCase('Employee Sale')) {
                typeOfOrder = 'Employee Sale';
            }
            else if (orderType.equalsIgnoreCase('Specialty Roaster')) {
                typeOfOrder = 'Specialty Roaster';
            }
            else {
                typeOfOrder = 'Wholesale';
            }
        }
        else {
            if (isB2BOrder) {
                if (orderType.equalsIgnoreCase('Sample')) {
                    typeOfOrder = 'Sample';
                }
                else {
                    typeOfOrder = 'Wholesale';
                }
            }
            else {
                typeOfOrder = orderType;
            }
        }
        if (orderType.equalsIgnoreCase('Repair Replacement')) {
            typeOfOrder = 'Accommodation';
        }
        system.debug('typeOfOrder:'+typeOfOrder);
        if (typeOfOrder != null && typeOfOrder != '') {
            List < Pricebook2 > pricebookList = [SELECT Id, Brand__c, Region__c, Type__c FROM Pricebook2
                                                 WHERE Region__c =: region AND Brand__c =: brand AND Type__c =: typeOfOrder
                                                ];
            for (Pricebook2 p: pricebookList) {}
            if (pricebookList != null && pricebookList.size() > 0) {
                orderRecord.PriceBook2Id = pricebookList[0].Id;
            }
        }
        
    }
    
    @AuraEnabled
    public static String orderTypeChange(String orderType, Boolean isWorkOrderPresent) {
        if (orderType == 'Work Order') {
            if (isWorkOrderPresent) {
                //return 'Work Order already present for this case.';
                throw new AuraHandledException('Work Order already present for this case.');
            }
        }
        return null;
    }
    
    public static Order copyBrevilleOfficeAddressAsShipping(Order orderRecord, Account accRecord) {
        if (orderRecord != null || accRecord != null) {
            orderRecord.ShippingStreet = accRecord.ShippingStreet;
            orderRecord.ShippingCity = accRecord.ShippingCity;
            orderRecord.ShippingStateCode = accRecord.ShippingStateCode;
            orderRecord.ShippingPostalCode = accRecord.ShippingPostalCode;
            orderRecord.ShippingCountryCode = accRecord.ShippingCountryCode;
        }
        return orderRecord;
    }
    @AuraEnabled public static Order getOrderConfig(String orderId) {
        return [select Id, PriceBook2Id, CurrencyIsoCode, OrderCustomerType__c, Type,Brand__c from Order where Id =: orderId limit 1];
    }
    @AuraEnabled public static List < Pricebookentrywrapper > getPriceBooks(String orderId) {
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        system.debug('*******orderId******'+orderId);
        List < Order > ordValues = [select Id, PriceBook2Id, CurrencyIsoCode, OrderCustomerType__c, Type, AX_Order_Account__c from Order where Id =: orderId limit 1];
        system.debug('*******ordValues ******'+ordValues);
        //String currencycode =ordValues[0].CurrencyIsoCode; 
        productWrapper = getPriceBookEntryList(ordValues);
        return productWrapper;
    }
    public static List < Pricebookentrywrapper > getPriceBookEntryList(List < Order > ordValues) {
        system.debug('*******CurrencyIsoCode******'+ordValues[0].CurrencyIsoCode);
        Map < string, list < Offer_Product__c >> offerProductMap = Ltng_OrganizationUtil_Cls.getOfferProducts(ordValues[0].CurrencyIsoCode);
        system.debug('******offerProductMap *******'+offerProductMap);
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        system.debug('*************'+ordValues[0].PriceBook2Id);
        List < PricebookEntry > priceBookEntList = [SELECT Id, Pricebook2Id, Product2Id, Product2.AX_Item_Number__c,
                                                    Product2.Description, Product2.Name, Product2.MAP__c,
                                                    Product2.Quantity_Available__c, Product2.Serviceable__c,
                                                    Product2.Service_Charge__c, Product2.Substitution_Number__c,
                                                    Product2.Spare_Parts_Use_Internal__c, Product2.Spare_Parts_Use_External__c,
                                                    Product2.Available_Date__c, Product2.AlternativeProduct__c,Product2.AlternativeProduct__r.Name, Product2.Available_To_Sell__c,
                                                    Product2.AX_Reserved_Inventory__c,
                                                    UnitPrice FROM PricebookEntry where Pricebook2Id =: ordValues[0].PriceBook2Id and 
                                                    Product2.Product_Type__c not In ('SC','MRD') AND Product2.IsActive = true and Product2.AX_Item_Number__c != null order by Product2.Name
                                                   ];
        system.debug('*************'+priceBookEntList.size());
        
        if (priceBookEntList.size() > 0) {
            Boolean showPromotionalPriceforB2COrder = calcPPriceforB2COrder(ordValues[0]);
            productWrapper = createProductWrapper(ordValues[0], priceBookEntList, showPromotionalPriceforB2COrder, offerProductMap);
        }
        return productWrapper;
    }
    
    public static List < Pricebookentrywrapper > createProductWrapper(Order orderObj, List < PricebookEntry > priceBookEntList, Boolean showPromotionalPriceforB2COrder, Map < string, list < Offer_Product__c >> offerProductMap) {
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        for (PricebookEntry pberecord: priceBookEntList) {
            Pricebookentrywrapper objPricebookentrywrapper = new Pricebookentrywrapper();
            objPricebookentrywrapper.pberecord = pberecord;
            objPricebookentrywrapper.selected = false;
            objPricebookentrywrapper.qtyErrorMessage = '';
            objPricebookentrywrapper.promotionAppliedMessage = '';
            objPricebookentrywrapper.unitPrice = pberecord.UnitPrice;
            if (pberecord.Product2Id != null) {
                objPricebookentrywrapper.isAvailableToSell = Utility.isAvailableToSell(orderObj, pberecord.Product2);
            }
            if (showPromotionalPriceforB2COrder) {
                if (pberecord.Product2Id != null) {
                    if (offerProductMap != null && offerProductMap.containsKey(pberecord.Product2Id)) {
                        Offer_Product__c[] ofp = offerProductMap.get(pberecord.Product2Id);
                        
                        if (ofp.size() > 0) {
                            objPricebookentrywrapper.promotionalPricewithCurrency = ofp[0].CurrencyIsoCode + ' ' + String.valueOf(ofp[0].Promotional_Pricing__c);
                            objPricebookentrywrapper.promotionalPrice = ofp[0].Promotional_Pricing__c;
                        }
                        else {
                            objPricebookentrywrapper.promotionalPrice = null;
                        }
                        
                    }
                }
                if (objPricebookentrywrapper.promotionalPrice != null && pberecord.Product2.Quantity_Available__c > 0) {
                    objPricebookentrywrapper.unitPrice = objPricebookentrywrapper.promotionalPrice;
                    objPricebookentrywrapper.isPromotionApplied = true;
                }
                else
                {
                    objPricebookentrywrapper.isPromotionApplied = false;                    
                }
                
            }
            productWrapper.Add(objPricebookentrywrapper);
        }
        return productWrapper;
    }
    public static Boolean calcPPriceforB2COrder(Order ordValues) {
        if (ordValues.OrderCustomerType__c == 'B2C' && ordValues.Type == 'Sale') {
            return true;
        }
        else {
            return false;
        }
    }
    @AuraEnabled
    public static List < OrderItem > doSave(String orderId, String selectedOrderProducts) {
        try{
            return Ltng_OrganizationUtil_Cls.addOrderProductToOrderAndCheckDuplicates(orderId, selectedOrderProducts);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List < OrderItem > doSaveRelatedProducts(String orderId, String selectedOrderProducts) {
        List < OrderItem > orderItmList = new list < OrderItem > ();
        List < OrderItem > listOfOrderItems = new list < OrderItem > ();
        List<Id> selectedRelatedProducts = new List<Id>();
        Set<Id> SetSelectedProducts = new Set<Id>();
        Map<Id,Id> mapProductIdWithWarrantyId = new Map<Id,Id>();
        Map<Id,Id> mapProductIdWithOPId = new Map<Id,Id>();
        Map<Id,Id> mapWarrantyIdWithOPId = new Map<Id,Id>();
        List<OrderItem> lstOIToUpdate = new List<OrderItem>();
        try{
            list < object > inputObjectList = (list < object > ) JSON.deserializeUntyped(selectedOrderProducts);
            List<Order> lstOrder = [select PriceBook2Id from Order where Id=:orderId];
            if (inputObjectList != null) {
                for (object record: inputObjectList) {
                    Map < string, object > eachRecordMap = (map < string, object > ) record;
                    if(String.isNotBlank((string) eachRecordMap.get('selectedRelatedProduct')) && (string) eachRecordMap.get('selectedRelatedProduct') != '--None--'){
                        system.debug('&&&&&&&&&&&&'+Double.valueOf(eachRecordMap.get('relatedProductQuantity')));
                        selectedRelatedProducts.Add((Id)eachRecordMap.get('selectedRelatedProduct'));
                    }
                    Id strProdId = (Id) eachRecordMap.get('Product2Id');
                    if(!SetSelectedProducts.contains(strProdId))
                        SetSelectedProducts.Add((Id) eachRecordMap.get('Product2Id'));
                }
                Map<Id,Double> mapSelectedProductWithPrice = new Map<Id,Double>();
                Map<Id,Id> mapSelectedProductWithPBEId = new Map<Id,Id>();
                if(selectedRelatedProducts.size()>0)
                {
                    for(PricebookEntry ObjPBE: [select Id,UnitPrice,Product2Id,Product2.Ax_Item_Number__c from PricebookEntry where Pricebook2Id=:lstOrder[0].PriceBook2Id and Product2Id=:selectedRelatedProducts ])
                    {
                        mapSelectedProductWithPrice.put(ObjPBE.Product2Id,ObjPBE.UnitPrice);
                        mapSelectedProductWithPBEId.put(ObjPBE.Product2Id,ObjPBE.Id);
                    }
                }

                Map<Id,OrderItem> mapProductIdOrderItem = new Map<Id,OrderItem>();
                for(OrderItem ObjCurrOI:[select orderId,PricebookEntryId,Product2Id,Available_To_Sell__c,UnitPrice,Quantity from OrderItem where OrderId=:orderId and Product2Id=:SetSelectedProducts])
                {
                    mapProductIdOrderItem.put(ObjCurrOI.Product2Id,ObjCurrOI);
                }
                system.debug('mapProductIdOrderItem:'+mapProductIdOrderItem);
                for (object record: inputObjectList) {
                    Map < string, object > eachRecordMap = (map < string, object > ) record;
                    system.debug('******'+eachRecordMap);
                    Id idCurrentProduct = (string) eachRecordMap.get('Product2Id');
                    if(mapProductIdOrderItem.ContainsKey(idCurrentProduct))
                    {
                        OrderItem currOrderItem = (OrderItem)mapProductIdOrderItem.get(idCurrentProduct);
                        currOrderItem.Quantity = currOrderItem.Quantity + Double.valueOf(eachRecordMap.get('quantity'));
                        lstOIToUpdate.Add(currOrderItem);
                    }
                    else
                    {
                        OrderItem orderItm = new OrderItem();
                        orderItm.orderId = String.isNotBlank(orderId) ? orderId : Null;
                        orderItm.Grind_Type__c = (string) eachRecordMap.get('selectedGrindType') != null ? (string) eachRecordMap.get('selectedGrindType') : null;
                        orderItm.PricebookEntryId = (string) eachRecordMap.get('PricebookEntryId') != null ? (string) eachRecordMap.get('PricebookEntryId') : null;
                        orderItm.Product2Id = (string) eachRecordMap.get('Product2Id') != null ? (string) eachRecordMap.get('Product2Id') : null;
                        orderItm.Available_To_Sell__c = (Boolean) eachRecordMap.get('Available_To_Sell') != null ? (Boolean) eachRecordMap.get('Available_To_Sell') : null;
                        orderItm.UnitPrice = Double.valueOf(eachRecordMap.get('unitPrice')) != null ? Double.valueOf(eachRecordMap.get('unitPrice')) : null;
                        orderItm.Quantity = Double.valueOf(eachRecordMap.get('quantity')) != null ? Double.valueOf(eachRecordMap.get('quantity')) : null;
                        orderItmList.add(orderItm);
                    }
                    
                    if(String.isNotBlank((string) eachRecordMap.get('selectedRelatedProduct')) && (string) eachRecordMap.get('selectedRelatedProduct') != '--None--'){
                        system.debug('&&&&&&&&&&&&'+Double.valueOf(eachRecordMap.get('relatedProductQuantity')));
                        OrderItem orderItmRec = new OrderItem();
                        orderItmRec.orderId = String.isNotBlank(orderId) ? orderId : Null;
                        orderItmRec.Grind_Type__c = (string) eachRecordMap.get('selectedGrindType') != null ? (string) eachRecordMap.get('selectedGrindType') : null;
                        orderItmRec.PricebookEntryId = mapSelectedProductWithPBEId.get((string)eachRecordMap.get('selectedRelatedProduct'));
                        orderItmRec.Product2Id = (string) eachRecordMap.get('selectedRelatedProduct') != null ? (string) eachRecordMap.get('selectedRelatedProduct') : null;
                        orderItmRec.UnitPrice = mapSelectedProductWithPrice.get((string)eachRecordMap.get('selectedRelatedProduct'));
                        orderItmRec.Quantity = Double.valueOf(eachRecordMap.get('relatedProductQuantity')) != null ? Double.valueOf(eachRecordMap.get('relatedProductQuantity')) : null;
                        listOfOrderItems.add(orderItmRec);
                        mapProductIdWithWarrantyId.put(idCurrentProduct,orderItmRec.Product2Id);
                    }
                    
                }
            }
            system.debug('mapProductIdWithWarrantyId:'+mapProductIdWithWarrantyId);
            if (orderItmList.size() > 0) {
                insert orderItmList;
                system.debug('********inserted record **********'+orderItmList);
                for(OrderItem ObjOrderItem:orderItmList)
                {
                    mapProductIdWithOPId.put(ObjOrderItem.Product2Id,ObjOrderItem.Id);
                }
            }
            system.debug('mapProductIdWithOPId:'+mapProductIdWithOPId);
            system.debug('lstOIToUpdate:'+lstOIToUpdate);
            if(lstOIToUpdate.size()>0)
            {
                update lstOIToUpdate;
                orderItmList.addAll(lstOIToUpdate);
                for(OrderItem ObjOrderItem:lstOIToUpdate)
                {
                    mapProductIdWithOPId.put(ObjOrderItem.Product2Id,ObjOrderItem.Id);
                }
            }
            system.debug('mapProductIdWithOPId:'+mapProductIdWithOPId);
            if (listOfOrderItems.size() > 0) {
                insert listOfOrderItems;
                orderItmList.addAll(listOfOrderItems);
                List<ProductExtended_warranty__c> lstWarrantyMappings = new List<ProductExtended_warranty__c>();
                for(OrderItem ObjOrderItem:listOfOrderItems)
                {
                    mapWarrantyIdWithOPId.put(ObjOrderItem.Product2Id,ObjOrderItem.Id);
                }
                
                system.debug('mapWarrantyIdWithOPId:'+mapWarrantyIdWithOPId);
                for(Id idCurrentProduct:mapProductIdWithWarrantyId.KeySet())
                {
                    Id idCurrentWarrantyProduct = mapProductIdWithWarrantyId.get(idCurrentProduct);
                    ProductExtended_warranty__c objWarrantyMapping = new ProductExtended_warranty__c();
                    objWarrantyMapping.Order__c = orderId;
                    objWarrantyMapping.Parent_order_product__c = mapProductIdWithOPId.get(idCurrentProduct);
                    objWarrantyMapping.Warranty_order_product__c = mapWarrantyIdWithOPId.get(idCurrentWarrantyProduct);
                    lstWarrantyMappings.add(objWarrantyMapping);
                }
                system.debug('lstWarrantyMappings:'+lstWarrantyMappings);
                if(lstWarrantyMappings.size()>0)
                    insert lstWarrantyMappings;
                system.debug('********inserted record listOfOrderItems**********'+listOfOrderItems);
            }
            
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return orderItmList;
    }
    
    @AuraEnabled
    public static List < String > doGetOrderItem(String orderId) {
        try{
            return Ltng_OrganizationUtil_Cls.doGetOrderItem(orderId);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled public static List < Pricebookentrywrapper > doSearch(String orderId, String searchText, String filters) {
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        List < Order > ordValues = [select Id, PriceBook2Id, CurrencyIsoCode, OrderCustomerType__c, Type, AX_Order_Account__c from Order where Id =: orderId];
        Map < string, list < Offer_Product__c >> offerProductMap = Ltng_OrganizationUtil_Cls.getOfferProducts(ordValues[0].CurrencyIsoCode);
        productWrapper = getPriceBookEntryList(ordValues, searchText, filters);
        return productWrapper;
    }
    public static List < Pricebookentrywrapper > getPriceBookEntryList(List < Order > ordValues, String searchText, String filters) {
        Map < string, list < Offer_Product__c >> offerProductMap = Ltng_OrganizationUtil_Cls.getOfferProducts(ordValues[0].CurrencyIsoCode);
        String searchByValue = '%' + searchText + '%';
        String skipPicklistValue = 'SC';
        Set<String> setOfSkipPicklistValue = new Set<String>{'SC','MRD'};
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        String query = 'SELECT Id, Pricebook2Id, Product2Id,Product2.AX_Item_Number__c ,Product2.Description,Product2.Name,Product2.MAP__c,Product2.Quantity_Available__c,' +
            ' Product2.Serviceable__c , Product2.Service_Charge__c,Product2.Substitution_Number__c,Product2.Spare_Parts_Use_Internal__c,Product2.Spare_Parts_Use_External__c,Product2.Available_Date__c,Product2.AlternativeProduct__r.Name,Product2.AlternativeProduct__c,Product2.AX_Reserved_Inventory__c,' +
            ' Product2.Available_To_Sell__c,Product2.Product_Type__c, UnitPrice, Product2.Quantity_Available_for_B2B__c, Product2.Quantity_Available_for_B2C__c' +
            ' FROM PricebookEntry where Pricebook2Id = ' + '\'' + ordValues[0].PriceBook2Id + '\' and Product2.IsActive= true AND Product2.Product_Type__c NOT IN :setOfSkipPicklistValue AND Product2.AX_Item_Number__c != null AND Product2.' +
            filters + ' like ' + '\'' + searchByValue + '\' order by Product2.Name ';
        List < PricebookEntry > priceBookEntList = Database.query(query);
        if (priceBookEntList.size() > 0) {
            Boolean showPromotionalPriceforB2COrder = calcPPriceforB2COrder(ordValues[0]);
            productWrapper = createProductWrapper(ordValues[0], priceBookEntList, showPromotionalPriceforB2COrder, offerProductMap);
        }
        return productWrapper;
    }
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        try{
            return Ltng_OrganizationUtil_Cls.getDependentMap(objDetail,contrfieldApiName,depfieldApiName);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}