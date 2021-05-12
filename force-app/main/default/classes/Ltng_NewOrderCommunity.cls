/*
 * @Dev : Bhavin
 * @Date : 21/12/2020
 * @Ltng_NewOrderCtrl : This controller is responsible for handling new order creation process in partner community
 *
 */
public class Ltng_NewOrderCommunity {
    
        
    public class NewOrderException extends Exception{}
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

    @AuraEnabled
    public static Map<string, string> getBrands(string cur){
        Map<String, string> mapOfObjects = new Map<String,string>();
        try {
            
            
                if(cur == 'USD' || cur == 'CAD' ||cur == 'AUD' || cur == 'NZD'){
                    mapOfObjects.put('Breville','Breville');
                }else if(cur == 'GBP' || cur == 'EUR' || cur == 'CHF'){
                    mapOfObjects.put('Sage','Sage');
                }
                
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return mapOfObjects;
    }

    @AuraEnabled
    public static Map < String, String > getOrderTypes() {
        try
        { 
            return  new Map<string,string>{'orderType' =>'Sale'};
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static Map<string, object> doInit(){
        Map < String, Object > mapOfObjects = new Map < String, Object > ();
        String region = '';
        Boolean isEmpPortalUser = false;
        String objectType = '';
        String profile = '';

        try {
            string cur = '';

            User u = [SELECT id, IsPortalEnabled, AccountID, DefaultCurrencyIsoCode, Profile.Name FROM User where id = : UserInfo.getUserId() ];
            
            System.debug('u---->'+ u);
            profile = u.Profile.Name;
            if(u.IsPortalEnabled && !string.isBlank(u.AccountID)){
                System.debug('inside if---->');
                Account accountObj = [Select Id, CurrencyIsoCode,IsPersonAccount,PersonEmail, Phone, Business_Email__c, RecordType.DeveloperName, Finished_Good_Pricebook__c From Account Where Id =: u.AccountId Limit 1];
                System.debug('accountObj---->'+ accountObj);
                cur = accountObj.CurrencyIsoCode;
                mapOfObjects.put('accountRecord',accountObj);
                mapOfObjects.put('currency',cur);
                if(! accountObj.IsPersonAccount){
                    if(string.isBlank(accountObj.Business_Email__c) && string.isBlank(accountObj.Phone)){
                       System.debug('inside if---##->');
                        //throw new AuraHandledException('Please enter Email and Phone Number to create Order');
                        string errorMessage = 'Please enter Email and Phone Number to create Order';
                        AuraHandledException ahe =  new AuraHandledException(errorMessage);
                        ahe.setMessage(errorMessage);
                        throw ahe;
                    }
                }

                region = Utility.regionBased(cur);
                mapOfObjects.put('region', region);
    
                isEmpPortalUser = u.IsPortalEnabled && (u.profile.Name == 'Employee Portal Community');
                mapOfObjects.put('isEmpPortalUser',isEmpPortalUser);
                mapOfObjects.put('isPortalUser',u.IsPortalEnabled);
    
                objectType = Id.valueOf(accountObj.Id).getSObjectType().getDescribe().getName();
                mapOfObjects.put('objectType',objectType);
            }    
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('mapOfObjects---->'+ mapOfObjects);
        return mapOfObjects;
    }

    @AuraEnabled
    public static String save(
            String idParam,
            String brand,
            String orderType,
            String currecnyCode,
            String objectType,
            Boolean isPortalUser,
            String region,
            boolean isEmpPortalUser,
            String selectedDeliveryOption,
            String sCenterId,
            String serviceType,
            String shimentMethod,
            String ordRefNum
    ) {
        if ((brand != null && brand != '' && orderType != null && orderType != '')) {
           
         if (orderType == 'Sale' ) {
                         system.debug('starting in orderType sale ::' + objectType);
                         if (objectType == 'Account') {
                             system.debug('starting in objectType  sale ::' + objectType);
                             Account accountRecord = getAccount(Ltng_OrganizationUtil_Cls.getOrderFieldMappingForAccount(), idParam);
                             if (accountRecord != null) {
                                 if (accountRecord.isPersonAccount == false ||
									(accountRecord.BillingCity != null && accountRecord.BillingCity != '' &&
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
                                      (accountRecord.ShippingPostalCode != null && accountRecord.ShippingPostalCode != '')))) {
                                          system.debug('inner loop');
                                          Order orderRecord = createOrderAccount(accountRecord, orderType, brand, isPortalUser, region, isEmpPortalUser, selectedDeliveryOption,shimentMethod,ordRefNum);
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

    @AuraEnabled
    public static List<Order> getOrderRecordDetails( String orderRecordId){
        try {
            List<Order> listOfOrderDetails =
                [ SELECT Id,
                    Brand__c,
                    Type
                FROM Order
                WHERE Id =: orderRecordId
            ];
            if(listOfOrderDetails.size() > 0 ) {
                return listOfOrderDetails;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled 
    public static List < Pricebookentrywrapper > getPriceBooks(String orderId, List<Id> selectedFinishGoodProdID) {
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        //Getting BOM list to retrive selective finished good spare parts price book entry.
        List<Id> bomList = getBillOFMaterials(selectedFinishGoodProdID);

        system.debug('*******orderId******'+orderId);
        List < Order > ordValues = [select Id, PriceBook2Id, CurrencyIsoCode, OrderCustomerType__c, Type, AX_Order_Account__c from Order where Id =: orderId limit 1];
        system.debug('*******ordValues ******'+ordValues);
        //String currencycode =ordValues[0].CurrencyIsoCode; 
        productWrapper = getPriceBookEntryList(ordValues,bomList);
         system.debug('*******productWrapper ******'+productWrapper);
        return productWrapper;
    }
    @AuraEnabled
    public static List < Pricebookentrywrapper > getStandardPriceBooks(String orderId) {
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        List < Order > ordList =
            [SELECT Id,
             	PriceBook2Id,
                CurrencyIsoCode,
                OrderCustomerType__c,
                Type,
                AX_Order_Account__c
             FROM Order
             WHERE Id =: orderId limit 1
      	];
        System.debug('ordList--->'+ ordList);
        Map < string, list < Offer_Product__c >> offerProductMap =
            Ltng_OrganizationUtil_Cls.getOfferProducts(ordList[0].CurrencyIsoCode);
        List < PricebookEntry > priceBookEntList =
            [SELECT Id, Pricebook2Id, Product2Id, Product2.AX_Item_Number__c,
             Product2.Description, Product2.Name, Product2.MAP__c,
             Product2.Quantity_Available__c, Product2.Serviceable__c,
             Product2.Service_Charge__c, Product2.Substitution_Number__c,
             Product2.Spare_Parts_Use_Internal__c, Product2.Spare_Parts_Use_External__c,
             Product2.Available_Date__c, Product2.AlternativeProduct__c,Product2.AlternativeProduct__r.Name, Product2.Available_To_Sell__c,
             Product2.AX_Reserved_Inventory__c,
             UnitPrice FROM PricebookEntry where Pricebook2Id =: ordList[0].PriceBook2Id and Product2.IsActive = true and Product2.AX_Item_Number__c != null order by Product2.Name
            ];
        system.debug('*************'+priceBookEntList.size());
        if (priceBookEntList.size() > 0) {
            Boolean showPromotionalPriceforB2COrder = calcPPriceforB2COrder(ordList[0]);
            productWrapper = createProductWrapper(ordList[0], priceBookEntList, showPromotionalPriceforB2COrder, offerProductMap);
        }
        return productWrapper;
    }

    @AuraEnabled
    public static List<Pricebookentrywrapper> getFinishGoodProducts(Account acnt){
        List<Pricebookentrywrapper> pricebookEntryWrapper = new List<Pricebookentrywrapper>();
        system.debug('---inside getFinishGoodProducts--->');
        try {
            if(!string.isBlank(acnt.Finished_Good_Pricebook__c)){
                system.debug('---getFinishGoodProducts--->'+ acnt.Finished_Good_Pricebook__c);
                List < PricebookEntry > priceBookEntList = [SELECT Id, Pricebook2Id, Product2Id, Product2.AX_Item_Number__c,
                                                        Product2.Description, Product2.Name, Product2.MAP__c,
                                                        Product2.Quantity_Available__c, Product2.Serviceable__c,
                                                        Product2.Service_Charge__c, Product2.Substitution_Number__c,
                                                        Product2.Spare_Parts_Use_Internal__c, Product2.Spare_Parts_Use_External__c,
                                                        Product2.Available_Date__c, Product2.AlternativeProduct__c,Product2.AlternativeProduct__r.Name, Product2.Available_To_Sell__c,
                                                        Product2.AX_Reserved_Inventory__c,
                                                        UnitPrice FROM PricebookEntry where Pricebook2Id =: acnt.Finished_Good_Pricebook__c and 
                                                        Product2.Product_Type__c not In ('SC','MRD') AND Product2.IsActive = true and Product2.AX_Item_Number__c != null order by Product2.Name
                                                        ];

                for (PricebookEntry pberecord: priceBookEntList) {
                    Pricebookentrywrapper objPricebookentrywrapper = new Pricebookentrywrapper();
                    objPricebookentrywrapper.pberecord = pberecord;
                    objPricebookentrywrapper.selected = false;
                    
                    pricebookEntryWrapper.Add(objPricebookentrywrapper);
                    system.debug('---pricebookEntryWrapper--->'+ pricebookEntryWrapper);
                }
            }else{
                throw new NewOrderException('No finished good price book linked');
            }
            

        } catch (NewOrderException e) {
            throw new AuraHandledException(e.getMessage());
        }
        return pricebookEntryWrapper;
    }
    public static Order createOrderAccount(Account accountRecord, String orderType, String brand, Boolean isPortalUser, String region, Boolean isEmpPortalUser, String selectedDeliveryOption,String shimentMethod, string ordRefNum) {
        Order orderRecord = new Order();
        User u = [SELECT id, IsPortalEnabled, ContactId, AccountID, DefaultCurrencyIsoCode, Profile.Name FROM User where id = : UserInfo.getUserId() ];
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
        orderRecord.put('BillToContactId',u.ContactId);
        //orderRecord.put('Shipping_Method__c', shimentMethod);
        orderRecord.status = 'Open';
        orderRecord.Brand__c = brand;
        system.debug('ordRefNum : '+ordRefNum);
        if(!string.isBlank(ordRefNum))
            orderRecord.OrderReferenceNumber = ordRefNum;
        
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
    public static Account getAccount(map < String, String > fieldMapping, String idParam) {
        
        List < String > accountFields = fieldMapping.values();
        String soql = '' +
            ' select isPersonAccount,' + String.join(accountFields, ',') +
            ' from Account' +
            ' where id =:idParam';
        list < Account > accountList = Database.query(soql);
        if (accountList != null && accountList.size() > 0) {
            return accountList[0];
        }
        return null;
    }
    public static List < Pricebookentrywrapper > getPriceBookEntryList(List < Order > ordValues, List<id> bomIds) {
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
                                                    UnitPrice FROM PricebookEntry where Pricebook2Id =: ordValues[0].PriceBook2Id and Product2Id in :bomIds and Product2.Spare_Part__c = true and
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
    public static void checkPriceBookForOrder(Order orderRecord, Boolean isPortalUser, String orderType, String region, String brand) {
        /* assingning pricebook of Account on User in case of ASC orders else assigning default pricebook */
        String typeOfOrder = '';
        Boolean isB2BOrder = false;
        Account orderAccount ;
        if (orderRecord != null && orderRecord.AccountId != null) {
             orderAccount = [SELECT Id, RecordTypeId,paymentExemptParts__c FROM Account WHERE Id =: orderRecord.AccountId];
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
        if (orderType.equalsIgnoreCase('Repair Replacement') || orderAccount.paymentExemptParts__c ==  true) {
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

    public static Boolean calcPPriceforB2COrder(Order ordValues) {
        if (ordValues.OrderCustomerType__c == 'B2C' && ordValues.Type == 'Sale') {
            return true;
        }
        else {
            return false;
        }
    }

    public static List<Id> getBillOFMaterials(List<Id> selectedFinishGoodProdID){
        List<Id> sparePartsID = new List<Id>();
        
        if(selectedFinishGoodProdID.size() > 0){
            for(BillOfMaterial__c bom : [SELECT Id, Parts__c FROM BillOfMaterial__c WHERE isActive__c = true AND PrimaryProduct__c in :selectedFinishGoodProdID]){
                sparePartsID.add(bom.Parts__c);
            }
        }
        
        return sparePartsID;
    }

    @AuraEnabled
    public static List<Pricebookentrywrapper> doSearchFinishedGoodProds(Id pricebookId, string searchText, string filter){
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        try {
            String searchByValue = '%' + searchText + '%';
            String skipPicklistValue = 'SC';
            Set<String> setOfSkipPicklistValue = new Set<String>{'SC','MRD'};
            
            String query = 'SELECT Id, Pricebook2Id, Product2Id,Product2.AX_Item_Number__c ,Product2.Description,Product2.Name,Product2.MAP__c,Product2.Quantity_Available__c,' +
                ' Product2.Serviceable__c , Product2.Service_Charge__c,Product2.Substitution_Number__c,Product2.Spare_Parts_Use_Internal__c,Product2.Spare_Parts_Use_External__c,Product2.Available_Date__c,Product2.AlternativeProduct__r.Name,Product2.AlternativeProduct__c,Product2.AX_Reserved_Inventory__c,' +
                ' Product2.Available_To_Sell__c,Product2.Product_Type__c, UnitPrice, Product2.Quantity_Available_for_B2B__c, Product2.Quantity_Available_for_B2C__c' +
                ' FROM PricebookEntry where Pricebook2Id = ' + '\'' + pricebookId + '\' and Product2.IsActive= true AND Product2.Product_Type__c NOT IN :setOfSkipPicklistValue AND Product2.AX_Item_Number__c != null AND Product2.' +
                filter + ' like ' + '\'' + searchByValue + '\' order by Product2.Name ';
            List < PricebookEntry > priceBookEntList = Database.query(query);
            if (priceBookEntList.size() > 0) {
                for (PricebookEntry pberecord: priceBookEntList) {
                    Pricebookentrywrapper objPricebookentrywrapper = new Pricebookentrywrapper();
                    objPricebookentrywrapper.pberecord = pberecord;
                    objPricebookentrywrapper.selected = false;
                    
                    productWrapper.Add(objPricebookentrywrapper);
                }
            }
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return productWrapper;
    }

    @AuraEnabled
    public static List < String > doGetOrderItem(String orderId) {
        try{
            return Ltng_OrganizationUtil_Cls.doGetOrderItem(orderId);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
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
    public static List < Pricebookentrywrapper > doSearch(
        String orderId,
        String searchText,
        String filters,
        List<id> selectedFinishGoodProdID,
        Boolean isAssociatedWithFinishedGoods
    ) {
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();
        List < Order > ordValues = [select Id, PriceBook2Id, CurrencyIsoCode, OrderCustomerType__c, Type, AX_Order_Account__c from Order where Id =: orderId];
        Map < string, list < Offer_Product__c >> offerProductMap = Ltng_OrganizationUtil_Cls.getOfferProducts(ordValues[0].CurrencyIsoCode);
        productWrapper = getPriceBookEntryList(ordValues, searchText, filters,selectedFinishGoodProdID, isAssociatedWithFinishedGoods);
        return productWrapper;
    }

    public static List < Pricebookentrywrapper > getPriceBookEntryList(
        List < Order > ordValues,
        String searchText,
        String filters,
        List<id> selectedFinishGoodProdID,
        Boolean isAssociatedWithFinishedGoods
    ) {
        Map < string, list < Offer_Product__c >> offerProductMap = Ltng_OrganizationUtil_Cls.getOfferProducts(ordValues[0].CurrencyIsoCode);
        List<Id> bomList = getBillOFMaterials(selectedFinishGoodProdID);
        String searchByValue = '%' + searchText + '%';
        String skipPicklistValue = 'SC';
        Set<String> setOfSkipPicklistValue = new Set<String>{'SC','MRD'};
        List < Pricebookentrywrapper > productWrapper = new List < Pricebookentrywrapper > ();

        if(isAssociatedWithFinishedGoods == false) {
        	String query = 'SELECT Id, Pricebook2Id, Product2Id,Product2.AX_Item_Number__c ,Product2.Description,Product2.Name,Product2.MAP__c,Product2.Quantity_Available__c,' +
                ' Product2.Serviceable__c , Product2.Service_Charge__c,Product2.Substitution_Number__c,Product2.Spare_Parts_Use_Internal__c,Product2.Spare_Parts_Use_External__c,Product2.Available_Date__c,Product2.AlternativeProduct__r.Name,Product2.AlternativeProduct__c,Product2.AX_Reserved_Inventory__c,' +
                ' Product2.Available_To_Sell__c,Product2.Product_Type__c, UnitPrice, Product2.Quantity_Available_for_B2B__c, Product2.Quantity_Available_for_B2C__c' +
                ' FROM PricebookEntry where Pricebook2Id = ' + '\'' + ordValues[0].PriceBook2Id +
				'\' and Product2.IsActive= true AND Product2.AX_Item_Number__c != null AND Product2.' +
                filters + ' like ' + '\'' + searchByValue + '\' order by Product2.Name ';
        	List < PricebookEntry > priceBookEntList = Database.query(query);
            if (priceBookEntList.size() > 0) {
                Boolean showPromotionalPriceforB2COrder = calcPPriceforB2COrder(ordValues[0]);
                productWrapper = createProductWrapper(ordValues[0], priceBookEntList, showPromotionalPriceforB2COrder, offerProductMap);
            }
        } else if (isAssociatedWithFinishedGoods == true) {
            String query = 'SELECT Id, Pricebook2Id, Product2Id,Product2.AX_Item_Number__c ,Product2.Description,Product2.Name,Product2.MAP__c,Product2.Quantity_Available__c,' +
                ' Product2.Serviceable__c , Product2.Service_Charge__c,Product2.Substitution_Number__c,Product2.Spare_Parts_Use_Internal__c,Product2.Spare_Parts_Use_External__c,Product2.Available_Date__c,Product2.AlternativeProduct__r.Name,Product2.AlternativeProduct__c,Product2.AX_Reserved_Inventory__c,' +
                ' Product2.Available_To_Sell__c,Product2.Product_Type__c, UnitPrice, Product2.Quantity_Available_for_B2B__c, Product2.Quantity_Available_for_B2C__c' +
                ' FROM PricebookEntry where Pricebook2Id = ' + '\'' + ordValues[0].PriceBook2Id + '\' and Product2Id in :bomList and Product2.IsActive= true AND Product2.Product_Type__c NOT IN :setOfSkipPicklistValue AND Product2.AX_Item_Number__c != null AND Product2.' +
                filters + ' like ' + '\'' + searchByValue + '\' order by Product2.Name ';
            List < PricebookEntry > priceBookEntList = Database.query(query);
            if (priceBookEntList.size() > 0) {
                Boolean showPromotionalPriceforB2COrder = calcPPriceforB2COrder(ordValues[0]);
                productWrapper = createProductWrapper(ordValues[0], priceBookEntList, showPromotionalPriceforB2COrder, offerProductMap);
            }
        }
        return productWrapper;
    }
}