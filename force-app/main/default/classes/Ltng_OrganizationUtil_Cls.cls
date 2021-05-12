global class Ltng_OrganizationUtil_Cls{
    public static List < String > doGetOrderItem(String orderId) {        
        List < String > existingorderItmList = new list < String > ();
        for (OrderItem orderItmObj: [Select Product2Id from OrderItem where OrderId =: orderId]) {
            existingorderItmList.add(orderItmObj.Product2Id);
        }
        return existingorderItmList;
    }
    public static map < String, String > getWorkOrderFieldMappingForCase() {
        map < String, String > orderFieldMap = new map < String, String > ();
        orderFieldMap.put('AccountId', 'AccountId');
        orderFieldMap.put('ContactId', 'ContactId');
        orderFieldMap.put('City', 'Account.BillingCity');
        orderFieldMap.put('CountryCode', 'Account.BillingCountryCode');
        orderFieldMap.put('PostalCode', 'Account.BillingPostalCode');
        orderFieldMap.put('StateCode', 'Account.BillingStateCode');
        orderFieldMap.put('Street', 'Account.BillingStreet');
        orderFieldMap.put('ServiceCentre__c', 'Service_Center__c');
        orderFieldMap.put('ServicePricebook__c', 'Service_Center__r.ServicePriceBook__c');
        orderFieldMap.put('Product__c', 'Product__c');
        orderFieldMap.put('Description', 'Description');
        orderFieldMap.put('Subject', 'Subject');
        orderFieldMap.put('ComplaintCode__c', 'Complaint_Code__c');
        orderFieldMap.put('Sub_Complaint_Code__c', 'Sub_Complaint_Code__c');
        orderFieldMap.put('Secondary_Sub_Complaint_Code__c', 'Secondary_Sub_Complaint_Code__c');

        orderFieldMap.put('CaseId', 'Id');
        orderFieldMap.put('CaseNumber__c', 'CaseNumber');
        orderFieldMap.put('CurrencyIsoCode', 'CurrencyIsoCode');
        orderFieldMap.put('AssetId', 'AssetId');
        orderFieldMap.put('PurchaseDate__c', 'Purchase_Date__c');
        orderFieldMap.put('Serial__c', 'Serial__c');
        orderFieldMap.put('BatchCode__c', 'Batch_Code__c');
        return orderFieldMap;
    }
    public static map < String, String > getOrderFieldMappingForAccount() {
        map < String, String > orderFieldMap = new map < String, String > ();
        orderFieldMap.put('AccountId', 'Id');
        orderFieldMap.put('BillToContactId', 'PersonContactId');
        orderFieldMap.put('BillingCity', 'BillingCity');
        orderFieldMap.put('BillingCountryCode', 'BillingCountryCode');
        orderFieldMap.put('BillingPostalCode', 'BillingPostalCode');
        orderFieldMap.put('BillingStateCode', 'BillingStateCode');
        orderFieldMap.put('BillingStreet', 'BillingStreet');
        orderFieldMap.put('ShippingCountryCode', 'ShippingCountryCode');
        orderFieldMap.put('ShippingCity', 'ShippingCity');
        orderFieldMap.put('ShippingPostalCode', 'ShippingPostalCode');
        orderFieldMap.put('ShippingStateCode', 'ShippingStateCode');
        orderFieldMap.put('ShippingStreet', 'ShippingStreet');
        orderFieldMap.put('CurrencyIsoCode', 'CurrencyIsoCode');
        orderFieldMap.put('Ship_To_Name__c', 'Name');
        orderFieldMap.put('Tax_Exempt_Order__c', 'IsTaxExempted__c');
        orderFieldMap.put('AX_Order_Account__c', 'VendAccount__c');

        return orderFieldMap;
    }
    public static List < OrderItem > addOrderProductToOrderAndCheckDuplicates(String orderId, String selectedOrderProducts) {
        List < OrderItem > orderItmList = new list < OrderItem > ();
        list < object > inputObjectList = (list < object > ) JSON.deserializeUntyped(selectedOrderProducts);
        if (inputObjectList != null) {
            for (object record: inputObjectList) {
                Map < string, object > eachRecordMap = (map < string, object > ) record;
                Map < string, object > pbRecordMap = (map < string, object > ) eachRecordMap.get('pberecord');
                Map < string, object > Product2Map = (map < string, object > ) pbRecordMap.get('Product2');

                OrderItem orderItm = new OrderItem();
                orderItm.orderId = String.isNotBlank(orderId) ? orderId : Null;
                orderItm.PricebookEntryId = (string) pbRecordMap.get('Id') != null ? (string) pbRecordMap.get('Id') : null;
                orderItm.Product2Id = (string) pbRecordMap.get('Product2Id') != null ? (string) pbRecordMap.get('Product2Id') : null;
                orderItm.Available_To_Sell__c = (Boolean) Product2Map.get('Available_To_Sell__c') != null ? (Boolean) Product2Map.get('Available_To_Sell__c') : null;
                orderItm.UnitPrice = (Decimal) pbRecordMap.get('UnitPrice') != null ? (Decimal) pbRecordMap.get('UnitPrice') : null;
                orderItm.Quantity = Double.valueOf(eachRecordMap.get('quantity')) != null ? Double.valueOf(eachRecordMap.get('quantity')) : null;
                orderItmList.add(orderItm);
            }
        }
        if (orderItmList.size() > 0) {
            insert orderItmList;
            return orderItmList;
        }
        else {
            return null;
        }
    }
    public static Map < String, String > getBrands(Boolean showBrandSelection, String region) {
        Map < String, String > options = new Map < String, String > ();
        if (showBrandSelection) {
            Set < String > brandSet = new Set < String > ();
            for (Pricebook2 pricebook: [SELECT Id, Brand__c, Region__c FROM Pricebook2 WHERE Region__c =: region AND Brand__c != NULL]) {
                if (!brandSet.contains(pricebook.Brand__c)) {
                    options.put(pricebook.Brand__c, pricebook.Brand__c);
                    brandSet.add(pricebook.Brand__c);
                }
            }
            return options;
        }
        else {
            return null;
        }
    }
    public static map < String, String > getOrderFieldMappingForCase() {
        map < String, String > orderFieldMap = new map < String, String > ();
        orderFieldMap.put('AccountId', 'AccountId');
        orderFieldMap.put('BillToContactId', 'ContactId');
        orderFieldMap.put('BillingCity', 'Account.BillingCity');
        orderFieldMap.put('BillingCountryCode', 'Account.BillingCountryCode');
        orderFieldMap.put('BillingPostalCode', 'Account.BillingPostalCode');
        orderFieldMap.put('BillingStateCode', 'Account.BillingStateCode');
        orderFieldMap.put('BillingStreet', 'Account.BillingStreet');
        orderFieldMap.put('ShippingCountryCode', 'Account.ShippingCountryCode');
        orderFieldMap.put('ShippingCity', 'Account.ShippingCity');
        orderFieldMap.put('ShippingPostalCode', 'Account.ShippingPostalCode');
        orderFieldMap.put('ShippingStateCode', 'Account.ShippingStateCode');
        orderFieldMap.put('ShippingStreet', 'Account.ShippingStreet');
        orderFieldMap.put('Status', 'Status');
        orderFieldMap.put('Case__c', 'Id');
        orderFieldMap.put('CurrencyIsoCode', 'CurrencyIsoCode');
        orderFieldMap.put('Ship_To_Name__c', 'Account.Name');
        orderFieldMap.put('Tax_Exempt_Order__c', 'Account.IsTaxExempted__c');
        orderFieldMap.put('AX_Order_Account__c', 'Account.VendAccount__c');
        orderFieldMap.put('Return_Product_Received__c', 'RA_Delivered__c');
        return orderFieldMap;
    }
    public static Map < String, String > getOrderTypes(Boolean isPortalUser, String region, String profile, String objectType, boolean accomodationNOTAvailable, Boolean showSampleOrder) {
        //Boolean showSampleOrder = false;
        Map < String, String > options = new Map < String, String > ();
        if (isPortalUser && profile == 'Employee Portal Community') {
            options.put('Employee Sale', 'Internal Employee Sale');
        }
        else if (isPortalUser && profile == 'Specialty Roaster Community') {
            options.put('Specialty Roaster', 'Specialty Roaster');
        }
        else {
            options.put('Sale', 'Sale');
        }
        if (!isPortalUser) {
            if (objectType == 'Case') {
                //Below options should only be available when 'New Order' is clicked from Case screen
                options.put('Accommodation', 'Accommodation');
                options.put('Repair Replacement', 'Repair Replacement');
                options.put('Work Order', 'Work Order');
            }
            if (objectType == 'Account') {
                options.put('Employee Sale', 'Internal Employee Sale');
                if (region == 'AUS' || region == 'NZ') {
                    options.put('Retail Employee Sales', 'Retail Employee Sales');
                    options.put('Partner & Associate Sales', 'Partner & Associate Sales');
                    options.put('Retail Event Sales', 'Retail Event Sales');
                }
                if (region == 'AUS') {
                    options.put('Holiday Promo', 'Holiday Promo');
                    options.put('Event Sales Coffee', 'Event Sales Coffee');
                }
            }
        }
        if (showSampleOrder) {
            options.put('Sample', 'Sample');
        }
        return options;
    }
    public static Map < string, list < Offer_Product__c >> getOfferProducts(String currencycode) {
        Map < string, list < Offer_Product__c >> offerProductMap = new Map < string, list < Offer_Product__c >> ();
        Datetime dt = Datetime.now();
        String currentdt = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        String sql = 'SELECT Id,Promotion__r.Name, Promotion__r.Promotion_Name__c,CurrencyIsoCode,Promotional_Pricing__c,isActive__c,Product__c,Promotion__r.isActive__c,Promotion__r.Start_Date_Time__c,Promotion__r.End_Date_Time__c FROM Offer_Product__c where isActive__c=true and Promotion__r.Start_Date_Time__c <= ' + currentdt + ' and Promotion__r.End_Date_Time__c >=' + currentdt + ' and Promotion__r.isActive__c=true and CurrencyIsoCode= \'' + currencycode + '\'';

        Offer_Product__c[] ofp = Database.query(sql);

        for (Offer_Product__c offProduct: ofp) {
            if (offerProductMap.containsKey(offProduct.Product__c)) {
                offerProductMap.get(offProduct.Product__c).add(offProduct); //offerProductMap.get(offProduct.Product__c).add(offProduct); 
            }
            else {
                offerProductMap.put(offProduct.Product__c, new List < Offer_Product__c > {
                    offProduct
                });
            }
        }
        return offerProductMap;
    }
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType == null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
}