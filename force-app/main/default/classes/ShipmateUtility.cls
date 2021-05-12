public without sharing class ShipmateUtility {

    
    public static zkups__BulkShipment__c createUPSBulkShipmate(zkups__UPSShipmatePreference__c shipmatePref,Boolean isInsert) {
        
        zkups__BulkShipment__c bulkShipment = new zkups__BulkShipment__c (
                                        zkups__ShipmatePreference__c = shipmatePref.Id
                                        );
        if (isInsert ) {
            insert bulkShipment;
        }
        return bulkShipment;
    }
    public static zkfedex__BulkShipment__c createFedExBulkShipmate(zkfedex__ShipmatePreference__c shipmatePref,Boolean isInsert) {
        
        zkfedex__BulkShipment__c  bulkShipment = new zkfedex__BulkShipment__c  (
                                        zkfedex__ShipmatePreference__c  = shipmatePref.Id
                                        );
        if (isInsert ) {
            insert bulkShipment;
        }
        return bulkShipment;
    }
    //UPS related Code
    public static zkmulti__MCBulk_Shipment__c createMCBulkShipmate(zkmulti__MCShipmate_Preference__c shipmatePref,Boolean isInsert) {
        
        zkmulti__MCBulk_Shipment__c bulkShipment = new zkmulti__MCBulk_Shipment__c (
                                                    zkmulti__Shipmate_Preference__c = shipmatePref.Id
                                                );
        if (isInsert ) {
            insert bulkShipment;
        }
        return bulkShipment;
    }
    
    public static String processUPSBulkShipment(Id bulkShipmentId,Boolean isAsync){
        String batchId;
        if(isAsync){
            batchId = zkups.BulkShipmentInterface.processBulkShipment(bulkShipmentId);
        }else{
            batchId = zkups.BulkShipmentInterface.processBulkShipmentSynchronous(bulkShipmentId);
        }
        return batchId;
    }
    public static String processFedExBulkShipment(Id bulkShipmentId,Boolean isAsync){
        String batchId;
        if(isAsync){
            batchId = zkfedex.BulkShipmentInterface.processBulkShipment(bulkShipmentId);
        }else{
            batchId = zkfedex.BulkShipmentInterface.processBulkShipmentSynchronous(bulkShipmentId);
        }
        return batchId;
        
    }
    
    public static String processMCBulkShipment(Id bulkShipmentId,Boolean isAsync){
        String batchId;
        //try {
        if(isAsync){
            batchId = zkmulti.BulkShipmentInterface.asynchronousProcessBulkShipment(bulkShipmentId);
        }else{
            batchId = zkmulti.BulkShipmentInterface.synchronousProcessBulkShipment(bulkShipmentId);
        }
        /*}catch(Exception e) {
        	System.debug('Exception :::::' +e.getMessage());
        }*/
        return batchId;
    }
    
    public static zkups__UPSShipmatePreference__c getUPSShipmentPreference(Id shipmatePreferenceId){
        
        List<zkups__UPSShipmatePreference__c> shipmatePreferences = 
                                            
                                        [SELECT zkups__CompanyName__c, zkups__SenderNameDefault__c,zkups__ShippingIsResidential__c,
                                                zkups__ShippingCountry__c, zkups__SenderEMailDefault__c, zkups__SenderPhoneDefault__c,
                                                zkups__ShippingState__c, zkups__ShippingStreet__c, zkups__ShippingPostalCode__c,
                                                zkups__ShippingCity__c,zkups__LabelImageTypeDefault__c
                                            FROM zkups__UPSShipmatePreference__c 
                                            WHERE Id =:shipmatePreferenceId LIMIT 1 ];
                                               
        if(shipmatePreferences != null && shipmatePreferences.size() > 0 ){
            return shipmatePreferences[0];
        }
        
        return null;
    }
    public static zkfedex__ShipmatePreference__c getFedExShipmentPreference(Id shipmatePreferenceId){
        
       
  
        List<zkfedex__ShipmatePreference__c> shipmatePreferences = 
                                            
                                        [SELECT zkfedex__CompanyName__c, zkfedex__SenderNameDefault__c,zkfedex__ShippingIsResidential__c,
                                                zkfedex__ShippingCountry__c, zkfedex__SenderEMailDefault__c, zkfedex__SenderPhoneDefault__c,
                                                zkfedex__ShippingState__c, zkfedex__ShippingStreet__c, zkfedex__ShippingPostalCode__c,
                                                zkfedex__ShippingCity__c,zkfedex__LabelImageTypeDefault__c,zkfedex__FedExAccountNumber__c,
                                                zkfedex__BillingCountry__c,zkfedex__DropoffTypeDefault__c
                                            FROM zkfedex__ShipmatePreference__c 
                                            WHERE Id =:shipmatePreferenceId LIMIT 1 ];
                                               
        if(shipmatePreferences != null && shipmatePreferences.size() > 0 ){
            return shipmatePreferences[0];
        }
        
        return null;
    }
    
    public static map<Id,zkfedex__ShipmatePreference__c> getFedExShipmentPreferences(set<Id> shipmatePreferenceIds){
        
        map<Id,zkfedex__ShipmatePreference__c> shipmatePreferencesById = new map<Id,zkfedex__ShipmatePreference__c>(
                                     
                                        [SELECT zkfedex__CompanyName__c, zkfedex__SenderNameDefault__c,zkfedex__ShippingIsResidential__c,
                                                zkfedex__ShippingCountry__c, zkfedex__SenderEMailDefault__c, zkfedex__SenderPhoneDefault__c,
                                                zkfedex__ShippingState__c, zkfedex__ShippingStreet__c, zkfedex__ShippingPostalCode__c,
                                                zkfedex__ShippingCity__c,zkfedex__LabelImageTypeDefault__c,zkfedex__FedExAccountNumber__c,
                                                zkfedex__BillingCountry__c,zkfedex__DropoffTypeDefault__c
                                            FROM zkfedex__ShipmatePreference__c 
                                            WHERE Id IN :shipmatePreferenceIds ]);
        return shipmatePreferencesById;
    }
    public static map<Id,zkups__UPSShipmatePreference__c> getUPSShipmentPreferences(set<Id> shipmatePreferenceIds){
        
        map<Id,zkups__UPSShipmatePreference__c> shipmatePreferencesById = new map<Id,zkups__UPSShipmatePreference__c>(
                                     
                                        [SELECT zkups__CompanyName__c, zkups__SenderNameDefault__c,
                                                zkups__ShippingIsResidential__c, zkups__ShippingCity__c,
                                                zkups__ShippingCountry__c, zkups__SenderEMailDefault__c, zkups__SenderPhoneDefault__c,
                                                zkups__ShippingState__c, zkups__ShippingStreet__c, zkups__ShippingPostalCode__c,
                                                zkups__LabelImageTypeDefault__c
                                            FROM zkups__UPSShipmatePreference__c 
                                            WHERE Id IN :shipmatePreferenceIds ]);
        return shipmatePreferencesById;
    }
    
    public static zkmulti__MCShipmate_Preference__c getMCShipmentPreference(Id shipmatePreferenceId){
        
        List<zkmulti__MCShipmate_Preference__c> shipmatePreferences = 
                                        
                                        [SELECT Id, Name,zkmulti__Carrier__c, zkmulti__Label_Image_Type_Default__c, zkmulti__AccountNumber__c,
                                                    zkmulti__Billing_City__c, zkmulti__Billing_Country__c, zkmulti__Billing_State__c, 
                                                    zkmulti__Billing_Street__c, zkmulti__Billing_Zip_Postal_Code__c, zkmulti__Company_Name__c,
                                                    zkmulti__Sender_Email_Default__c, zkmulti__Sender_Name_Default__c, 
                                                    zkmulti__Sender_Phone_Default__c, zkmulti__Shipping_City__c, zkmulti__Shipping_Country__c,
                                                    zkmulti__Shipping_Is_Residential__c, 
                                                    zkmulti__Shipping_State__c, zkmulti__Shipping_Street__c, 
                                                    zkmulti__Shipping_Zip_Postal_Code__c, zkmulti__Currency_Default__c
                                            FROM zkmulti__MCShipmate_Preference__c 
                                            WHERE Id =:shipmatePreferenceId LIMIT 1 ];
                                                               
        if(shipmatePreferences != null && shipmatePreferences.size() > 0 ){
            return shipmatePreferences[0];
        }
        
        return null;
    }
    
    public static map<Id,zkmulti__MCShipmate_Preference__c> getMCShipmentPreferences(set<Id> shipmatePreferenceIds){
        
        map<Id,zkmulti__MCShipmate_Preference__c> shipmatePreferencesById = new map<Id,zkmulti__MCShipmate_Preference__c>(
                                    
                                    [SELECT Id, Name,zkmulti__Carrier__c, zkmulti__Label_Image_Type_Default__c, 
                                            zkmulti__Billing_City__c, zkmulti__Billing_Country__c, zkmulti__Billing_State__c, 
                                            zkmulti__Billing_Street__c, zkmulti__Billing_Zip_Postal_Code__c, zkmulti__Company_Name__c,
                                            zkmulti__Sender_Email_Default__c, zkmulti__Sender_Name_Default__c, 
                                            zkmulti__Sender_Phone_Default__c, zkmulti__Shipping_City__c, zkmulti__Shipping_Country__c,
                                            zkmulti__Shipping_Is_Residential__c, zkmulti__AccountNumber__c,
                                            zkmulti__Shipping_State__c, zkmulti__Shipping_Street__c, 
                                            zkmulti__Shipping_Zip_Postal_Code__c, zkmulti__Currency_Default__c
                                        FROM zkmulti__MCShipmate_Preference__c 
                                        WHERE Id IN :shipmatePreferenceIds]);
                                                               
                                                               
                                                               
        return shipmatePreferencesById;
        
    }
    
    
    public static ShipmentSetting__c getShipmentSetting(Id returnLocationId){
        list<ShipmentSetting__c> shipmentSettings = [   SELECT id, DimensionUnits__c,ShipmateApp__c, PackagingType__c, PaymentType__c,
                                                            ReturnLocation__c, ReturnType__c, Billing_Account_Number__c,
                                                            ServiceType__c,ShipmatePreference__c,UPSShipmatePreference__c,FedExShipmatePreference__c,
                                                            WeightUnits__c,ShippingCarrier__c,SortDimension__c,DropoffType__c, IsAccountAddress__c
                                                        FROM ShipmentSetting__c
                                                        WHERE ReturnLocation__c =:returnLocationId];
        if(shipmentSettings != null && shipmentSettings.size() > 0){
            return shipmentSettings[0];
        }
        return null;
    }
    public static map<Id,ShipmentSetting__c> getShipmentSettings(Id returnLocationId){
        map<Id,ShipmentSetting__c> shipmentSettings = new map<Id,ShipmentSetting__c> ([SELECT id, DimensionUnits__c,ShipmateApp__c, PackagingType__c, 
                                                                                       PaymentType__c, ReturnLocation__c, ReturnType__c,
                                                                                       Billing_Account_Number__c, ServiceType__c,ShipmatePreference__c,
                                                                                       UPSShipmatePreference__c,FedExShipmatePreference__c,
                                                            						   WeightUnits__c,ShippingCarrier__c,SortDimension__c,
                                                                                       DropoffType__c,IsAccountAddress__c
                                                        							FROM ShipmentSetting__c
                                                        							WHERE ReturnLocation__c =:returnLocationId]);
        if(shipmentSettings != null && !shipmentSettings.isEmpty() ){
            return shipmentSettings;
        }
        return null;
    }
    
   public static map<String,ShipmentSetting__c> getShpmntStngsByRtrnLocIds(set<Id> returnLocationIds){
        map<String,ShipmentSetting__c> shipmentSettingsByReturnLocId = new map<String,ShipmentSetting__c>();
         
        for(ShipmentSetting__c shipmentSetting : [SELECT id, DimensionUnits__c,ReturnAddress__c,ShipmateApp__c, PackagingType__c, 
                                                            PaymentType__c, ReturnLocation__c, ReturnLocation__r.Residential_Address__c, 
                                                            ReturnLocation__r.ShippingCity, ReturnLocation__r.BusinessName__c, 
                                                            ReturnLocation__r.ShippingCountryCode, ReturnLocation__r.Business_Email__c,
                                                            ReturnLocation__r.Name, ReturnLocation__r.Phone, Billing_Account_Number__c,
                                                            ReturnLocation__r.AccountStateFormula__c, ReturnLocation__r.ShippingStreet,
                                                            ReturnLocation__r.ShippingPostalCode, ReturnType__c,
                                                            ServiceType__c,ShipmatePreference__c,UPSShipmatePreference__c,
                                                            FedExShipmatePreference__c,WeightUnits__c,DropoffType__c, IsAccountAddress__c,
                                                            ShippingCarrier__c,SortDimension__c
                                                    FROM ShipmentSetting__c
                                                    WHERE ReturnLocation__c IN :returnLocationIds]){
                                                        
                shipmentSettingsByReturnLocId.put(shipmentSetting.ReturnLocation__c,shipmentSetting);
        }
        
        return shipmentSettingsByReturnLocId;
    }
    
    public static map<String,ShipmentSetting__c> getShipmentSettings(set<String> returnLocationAdds){
        map<String,ShipmentSetting__c> shipmentSettingsByReturnLocId = new map<String,ShipmentSetting__c>();
         
        for(ShipmentSetting__c shipmentSetting : [SELECT id, DimensionUnits__c,ReturnAddress__c,ShipmateApp__c, PackagingType__c, 
                                                            PaymentType__c, ReturnLocation__c, ReturnLocation__r.Residential_Address__c, 
                                                            ReturnLocation__r.ShippingCity, ReturnLocation__r.BusinessName__c, 
                                                            ReturnLocation__r.ShippingCountryCode, ReturnLocation__r.Business_Email__c,
                                                            ReturnLocation__r.Name, ReturnLocation__r.Phone, Billing_Account_Number__c,
                                                            ReturnLocation__r.AccountStateFormula__c, ReturnLocation__r.ShippingStreet,
                                                            ReturnLocation__r.ShippingPostalCode, ReturnType__c,
                                                            ServiceType__c,ShipmatePreference__c,UPSShipmatePreference__c,
                                                            FedExShipmatePreference__c,WeightUnits__c,DropoffType__c, IsAccountAddress__c,
                                                            ShippingCarrier__c,SortDimension__c
                                                    FROM ShipmentSetting__c
                                                    WHERE ReturnAddress__c IN :returnLocationAdds]){
                                                        
                shipmentSettingsByReturnLocId.put(shipmentSetting.ReturnAddress__c,shipmentSetting);
        }
        
        return shipmentSettingsByReturnLocId;
    }
    
    public static Case getCaseDetails(Id caseId){
        
        Case currentCase = [SELECT  Customer_City__c, 
                                   Customer_Country__c, Customer_Email__c, Customer_Name__c,
                                   Customer_Phone__c, Customer_State__c, Customer_Billing_Address_Line1__c,
                                   Customer_Zip__c,Residential_Address__c,AccountId,ContactId
                                FROM Case
                                WHERE Id = :caseId];
        return currentCase;
    }
    
    //get customAddressSourceField
    public static zkups__CustomAddressSource__c getUPSCustomAddressSource(String sourceObject){
        
        List<zkups__CustomAddressSource__c> customAddressSourceList = [ SELECT Id 
                                                                            FROM zkups__CustomAddressSource__c 
                                                                            WHERE zkups__CustomAddressSourceObject__c =: sourceObject
                                                                            LIMIT 1];
                                                                            
        if(customAddressSourceList != null && !customAddressSourceList.isEmpty()){
            return customAddressSourceList[0];
        }
        
        return null;
        
    }
    
    public static zkfedex__CustomAddressSource__c getFedExCustomAddressSource(String sourceObject){
        
        List<zkfedex__CustomAddressSource__c> customAddressSourceList = [ SELECT Id 
                                                                            FROM zkfedex__CustomAddressSource__c 
                                                                            WHERE zkfedex__CustomAddressSourceObject__c =: sourceObject
                                                                            LIMIT 1];
                                                                            
        if(customAddressSourceList != null && !customAddressSourceList.isEmpty()){
            return customAddressSourceList[0];
        }
        
        return null;
        
    }
    
    
    public static zkmulti__MCCustom_Address_Source__c getMCCustomAddressSource(String sourceObject){
        
        List<zkmulti__MCCustom_Address_Source__c> customAddressSourceList = [ SELECT Id 
                                                                                FROM zkmulti__MCCustom_Address_Source__c 
                                                                                WHERE zkmulti__Custom_Address_Source_Object__c =: sourceObject
                                                                                LIMIT 1];
                                                                                
        if(customAddressSourceList != null && !customAddressSourceList.isEmpty()){
            return customAddressSourceList[0];
        }
        
        return null;
        
    }
    
    public static zkups__QueuedShipment__c createUPSQueuedShipment(
                                    zkups__UPSShipmatePreference__c UPSShipmatePreference,
                                    String workingObject,Id workingobjectId,Case currentCase,ShipmentSetting__c setting,
                                    Id bulkShipmentId,Boolean isReturnLabel,
                                    Boolean isInsert,String returnDescription,Id  customAddressSourceId, String serviceType) {
        

        
        if ( customAddressSourceId != null) {
            String serviceTypeForCarrier = serviceType;
            if(serviceTypeForCarrier == null || (serviceTypeForCarrier != null && serviceTypeForCarrier == '')){
                serviceTypeForCarrier = setting.ServiceType__c;
            }
            // 2. zkups__QueuedShipment__c object
            
            zkups__QueuedShipment__c queuedShipment = new zkups__QueuedShipment__c (
                            
                            zkups__BulkShipment__c = bulkShipmentId,
                            zkups__LabelImageType__c = UPSShipmatePreference.zkups__LabelImageTypeDefault__c,
                            zkups__ServiceType__c =  serviceTypeForCarrier,                //'Domestic: UPS Ground',
                            zkups__PackagingType__c = setting.PackagingType__c,             //'Your Packaging',
                            zkups__WeightDimensionUnits__c =  setting.DimensionUnits__c,    //'LB / IN',
                            //zkups__EmailNotifyOnExceptionAlso__c = true,
                            //zkups__EmailRecipient1__c = 'tapan_badajena@persistent.com',
                            zkups__PaymentType__c = setting.PaymentType__c, //'SENDER',
                            zkups__CustomAddressSource__c = customAddressSourceId,
                            zkups__CustomAddressSourceRecordId__c = workingobjectId,
                            zkups__Account__c = currentCase.AccountId,
                            zkups__Contact__c = currentCase.ContactId,
                            Case__c = currentCase.Id,
                            zkups__FirstReferenceType__c = 'Return Authorization Number',
                            zkups__FirstReferenceValue__c = currentCase.CaseNumber
        
            );
            if(workingObject == 'WorkOrder'){
                queuedShipment.WorkOrder__c = workingobjectId;
            }
            
            //sender info
            if(setting.IsAccountAddress__c){
              //if(currentCase.ReturnLabelFor__c == 'Service Center'){
              if(workingObject == 'WorkOrder'){
                queuedShipment.zkups__SenderIsResidential__c =currentCase.Service_Center__r.Residential_Address__c;
                queuedShipment.zkups__SenderCity__c = currentCase.Service_Center__r.ShippingCity;
                queuedShipment.zkups__SenderCompany__c = currentCase.Service_Center__r.BusinessName__c;
                queuedShipment.zkups__SenderCountry__c = currentCase.Service_Center__r.ShippingCountryCode;
                queuedShipment.zkups__SenderEmail__c = currentCase.Service_Center__r.Business_Email__c;
                queuedShipment.zkups__SenderName__c = currentCase.Service_Center__r.Name;
                queuedShipment.zkups__SenderPhone__c = currentCase.Service_Center__r.Phone;
                queuedShipment.zkups__SenderState__c = currentCase.Service_Center__r.AccountStateFormula__c;
                queuedShipment.zkups__SenderStreet__c = currentCase.Service_Center__r.ShippingStreet;
                queuedShipment.zkups__SenderPostalCode__c = currentCase.Service_Center__r.ShippingPostalCode;
                
              }else if(workingObject == 'Case'){
              //else if(currentCase.ReturnLabelFor__c == 'Return Location'){
                
                queuedShipment.zkups__SenderIsResidential__c =currentCase.ReturnLocation__r.Residential_Address__c;
                queuedShipment.zkups__SenderCity__c = currentCase.ReturnLocation__r.ShippingCity;
                queuedShipment.zkups__SenderCompany__c = currentCase.ReturnLocation__r.BusinessName__c;
                queuedShipment.zkups__SenderCountry__c = currentCase.ReturnLocation__r.ShippingCountryCode;
                queuedShipment.zkups__SenderEmail__c = currentCase.ReturnLocation__r.Business_Email__c;
                queuedShipment.zkups__SenderName__c = currentCase.ReturnLocation__r.Name;
                queuedShipment.zkups__SenderPhone__c = currentCase.ReturnLocation__r.Phone;
                queuedShipment.zkups__SenderState__c = currentCase.ReturnLocation__r.AccountStateFormula__c;
                queuedShipment.zkups__SenderStreet__c = currentCase.ReturnLocation__r.ShippingStreet;
                queuedShipment.zkups__SenderPostalCode__c = currentCase.ReturnLocation__r.ShippingPostalCode;
              }
              
            }else{
              queuedShipment.zkups__SenderName__c = UPSShipmatePreference.zkups__CompanyName__c;
              queuedShipment.zkups__SenderIsResidential__c = UPSShipmatePreference.zkups__ShippingIsResidential__c;
              queuedShipment.zkups__SenderCity__c = UPSShipmatePreference.zkups__ShippingCity__c;
              queuedShipment.zkups__SenderCompany__c = UPSShipmatePreference.zkups__CompanyName__c;
              queuedShipment.zkups__SenderCountry__c = UPSShipmatePreference.zkups__ShippingCountry__c;
              queuedShipment.zkups__SenderEmail__c = UPSShipmatePreference.zkups__SenderEMailDefault__c;
              queuedShipment.zkups__SenderPhone__c = UPSShipmatePreference.zkups__SenderPhoneDefault__c;
              queuedShipment.zkups__SenderState__c = UPSShipmatePreference.zkups__ShippingState__c;
              queuedShipment.zkups__SenderStreet__c = UPSShipmatePreference.zkups__ShippingStreet__c;
              queuedShipment.zkups__SenderPostalCode__c = UPSShipmatePreference.zkups__ShippingPostalCode__c;
          }
          
            String recepientEmail = null;
            
            
            if(currentCase.RecordType.Name == 'RMA'){
                    
                    queuedShipment.zkups__RecipientCity__c = currentCase.Pickup_City__c;
                    queuedShipment.zkups__RecipientCompany__c = currentCase.Company_Name__c;
                    queuedShipment.zkups__RecipientCountry__c = currentCase.Pickup_Country__c;
                    queuedShipment.zkups__RecipientEmail__c = currentCase.Consignee_Email__c;
                    queuedShipment.zkups__RecipientName__c = currentCase.Consignee_Contact_Name__c;
                    queuedShipment.zkups__RecipientPhone__c = currentCase.Consignee_Phone__c;
                    queuedShipment.zkups__RecipientState__c = currentCase.Pickup_State__c;
                    queuedShipment.zkups__RecipientStreet__c = currentCase.Pickup_Address_1__c+(currentCase.Pickup_Address_2__c != null
                                                                ? ' '+currentCase.Pickup_Address_2__c: '');
                    queuedShipment.zkups__RecipientPostalCode__c = currentCase.Pickup_Postal_Code__c;
                    recepientEmail = currentCase.Consignee_Email__c;
                    
             }else{
                    queuedShipment.zkups__RecipientIsResidential__c = currentCase.Residential_Address__c;
                    queuedShipment.zkups__RecipientCity__c = currentCase.Customer_Ship_City__c;
                    queuedShipment.zkups__RecipientCompany__c = currentCase.Company_Name__c;
                    queuedShipment.zkups__RecipientCountry__c = currentCase.Customer_Ship_Country__c;
                    queuedShipment.zkups__RecipientEmail__c = currentCase.Customer_Email__c;
                    queuedShipment.zkups__RecipientName__c = currentCase.Customer_Name__c;
                    queuedShipment.zkups__RecipientPhone__c = currentCase.Customer_Phone__c;
                    queuedShipment.zkups__RecipientState__c = currentCase.Customer_Ship_State__c;
                    queuedShipment.zkups__RecipientStreet__c = currentCase.Customer_Ship_Address__c;
                    queuedShipment.zkups__RecipientPostalCode__c = currentCase.Customer_Ship_Zip__c;
                    recepientEmail = currentCase.Customer_Email__c;
            }
            
            
            if(isReturnLabel){
                queuedShipment.zkups__ReturnShipment__c = true;
                queuedShipment.zkups__ReturnType__c = setting.ReturnType__c;
                queuedShipment.zkups__ReturnDescription__c = returnDescription;
                queuedShipment.zkups__EmailRecipient2__c  = recepientEmail;
            }
            
            
            if(isInsert){
                insert queuedShipment; 
            }    
            return queuedShipment;
        
       
        }else {
                throw new BrevilleCustomException(' ' +System.Label.InvalidCustomAddressSource +' ');
         }               
            
    }
    
    
    public static zkfedex__QueuedShipment__c createFedExQueuedShipment(
                                    zkfedex__ShipmatePreference__c  ShipmatePreference,
                                    String workingObject,Id workingobjectId,Case currentCase,ShipmentSetting__c setting,
                                    Id bulkShipmentId,Boolean isReturnLabel,
                                    Boolean isInsert,String returnDescription,Id  customAddressSourceId, String serviceType) {
        

        
        if ( customAddressSourceId != null) {
            String serviceTypeForCarrier = serviceType;
            if(serviceTypeForCarrier == null || (serviceTypeForCarrier != null && serviceTypeForCarrier == '')){
                serviceTypeForCarrier = setting.ServiceType__c;
            }
            // 2. zkups__QueuedShipment__c object
            
            zkfedex__QueuedShipment__c queuedShipment = new zkfedex__QueuedShipment__c (
                            
                            zkfedex__BulkShipment__c  = bulkShipmentId,
                            zkfedex__ShipDate__c = Date.today(),
                            zkfedex__LabelImageType__c  = ShipmatePreference.zkfedex__LabelImageTypeDefault__c,
                            zkfedex__DropoffType__c = setting.DropoffType__c,
                            zkfedex__ServiceType__c  =  serviceTypeForCarrier,                //'Domestic: UPS Ground',
                            zkfedex__PackagingType__c  = setting.PackagingType__c,             //'Your Packaging',
                            zkfedex__WeightDimensionUnits__c  =  setting.DimensionUnits__c,    //'LB / IN',
                            //zkups__EmailNotifyOnExceptionAlso__c = true,
                            //zkups__EmailRecipient1__c = 'tapan_badajena@persistent.com',
                            zkfedex__PaymentType__c = setting.PaymentType__c,
                            zkfedex__DutiesPaymentType__c  = setting.PaymentType__c, //'SENDER',
                            // set duties
              zkfedex__DutiesPayorAccount__c = ShipmatePreference.zkfedex__FedExAccountNumber__c, // intl info
              zkfedex__DutiesPayorAccountCountry__c = ShipmatePreference.zkfedex__BillingCountry__c,
                            zkfedex__CustomAddressSource__c = customAddressSourceId,
                            zkfedex__CustomAddressSourceRecordId__c = workingobjectId,
                            zkfedex__Account__c = currentCase.AccountId,
                            zkfedex__Contact__c = currentCase.ContactId,
                            Case__c = currentCase.Id,
                            //zkups__FirstReferenceType__c = 'Return Authorization Number',
                            zkfedex__ReferenceRmaNumber__c = currentCase.CaseNumber
        
            );
            if(workingObject == 'WorkOrder'){
                queuedShipment.WorkOrder__c = workingobjectId;
            }
            //sender info
            if(setting.IsAccountAddress__c){
              //if(currentCase.ReturnLabelFor__c == 'Service Center'){
              if(workingObject == 'WorkOrder'){
                queuedShipment.zkfedex__SenderIsResidential__c =currentCase.Service_Center__r.Residential_Address__c;
                queuedShipment.zkfedex__SenderCity__c = currentCase.Service_Center__r.ShippingCity;
                queuedShipment.zkfedex__SenderCompany__c = currentCase.Service_Center__r.BusinessName__c;
                queuedShipment.zkfedex__SenderCountry__c = currentCase.Service_Center__r.ShippingCountryCode;
                queuedShipment.zkfedex__SenderEmail__c = currentCase.Service_Center__r.Business_Email__c;
                queuedShipment.zkfedex__SenderName__c = currentCase.Service_Center__r.Name;
                queuedShipment.zkfedex__SenderPhone__c = currentCase.Service_Center__r.Phone;
                queuedShipment.zkfedex__SenderState__c = currentCase.Service_Center__r.AccountStateFormula__c;
                queuedShipment.zkfedex__SenderStreet__c = currentCase.Service_Center__r.ShippingStreet;
                queuedShipment.zkfedex__SenderPostalCode__c = currentCase.Service_Center__r.ShippingPostalCode;
                
              }else if(workingObject == 'Case'){
              //else if(currentCase.ReturnLabelFor__c == 'Return Location'){
                
                queuedShipment.zkfedex__SenderIsResidential__c =currentCase.ReturnLocation__r.Residential_Address__c;
                queuedShipment.zkfedex__SenderCity__c = currentCase.ReturnLocation__r.ShippingCity;
                queuedShipment.zkfedex__SenderCompany__c = currentCase.ReturnLocation__r.BusinessName__c;
                queuedShipment.zkfedex__SenderCountry__c = currentCase.ReturnLocation__r.ShippingCountryCode;
                queuedShipment.zkfedex__SenderEmail__c = currentCase.ReturnLocation__r.Business_Email__c;
                queuedShipment.zkfedex__SenderName__c = currentCase.ReturnLocation__r.Name;
                queuedShipment.zkfedex__SenderPhone__c = currentCase.ReturnLocation__r.Phone;
                queuedShipment.zkfedex__SenderState__c = currentCase.ReturnLocation__r.AccountStateFormula__c;
                queuedShipment.zkfedex__SenderStreet__c = currentCase.ReturnLocation__r.ShippingStreet;
                queuedShipment.zkfedex__SenderPostalCode__c = currentCase.ReturnLocation__r.ShippingPostalCode;
              }
              
            }else{
              queuedShipment.zkfedex__SenderName__c = ShipmatePreference.zkfedex__CompanyName__c;
              queuedShipment.zkfedex__SenderIsResidential__c = ShipmatePreference.zkfedex__ShippingIsResidential__c;
              queuedShipment.zkfedex__SenderCity__c = ShipmatePreference.zkfedex__ShippingCity__c;
              queuedShipment.zkfedex__SenderCompany__c = ShipmatePreference.zkfedex__CompanyName__c;
              queuedShipment.zkfedex__SenderCountry__c = ShipmatePreference.zkfedex__ShippingCountry__c;
              queuedShipment.zkfedex__SenderEmail__c = ShipmatePreference.zkfedex__SenderEMailDefault__c;
              queuedShipment.zkfedex__SenderPhone__c = ShipmatePreference.zkfedex__SenderPhoneDefault__c;
              queuedShipment.zkfedex__SenderState__c = ShipmatePreference.zkfedex__ShippingState__c;
              queuedShipment.zkfedex__SenderStreet__c = ShipmatePreference.zkfedex__ShippingStreet__c;
              queuedShipment.zkfedex__SenderPostalCode__c = ShipmatePreference.zkfedex__ShippingPostalCode__c;
          }
          
            String recepientEmail = null;
            
            
  
            if(currentCase.RecordType.Name == 'RMA'){
                    
                    queuedShipment.zkfedex__RecipientCity__c = currentCase.Pickup_City__c;
                    queuedShipment.zkfedex__RecipientCompany__c = currentCase.Company_Name__c;
                    queuedShipment.zkfedex__RecipientCountry__c = currentCase.Pickup_Country__c;
                    queuedShipment.zkfedex__RecipientEmail__c = currentCase.Consignee_Email__c;
                    queuedShipment.zkfedex__RecipientName__c = currentCase.Consignee_Contact_Name__c;
                    queuedShipment.zkfedex__RecipientPhone__c = currentCase.Consignee_Phone__c;
                    queuedShipment.zkfedex__RecipientState__c = currentCase.Pickup_State__c;
                    queuedShipment.zkfedex__RecipientStreet__c = currentCase.Pickup_Address_1__c+(currentCase.Pickup_Address_2__c != null
                                                                ? ' '+currentCase.Pickup_Address_2__c: '');
                    queuedShipment.zkfedex__RecipientPostalCode__c = currentCase.Pickup_Postal_Code__c;
                    recepientEmail = currentCase.Consignee_Email__c;
                    
             }else{
                    queuedShipment.zkfedex__RecipientIsResidential__c = currentCase.Residential_Address__c;
                    queuedShipment.zkfedex__RecipientCity__c = currentCase.Customer_Ship_City__c;
                    queuedShipment.zkfedex__RecipientCompany__c = currentCase.Company_Name__c;
                    queuedShipment.zkfedex__RecipientCountry__c = currentCase.Customer_Ship_Country__c;
                    queuedShipment.zkfedex__RecipientEmail__c = currentCase.Customer_Email__c;
                    queuedShipment.zkfedex__RecipientName__c = currentCase.Customer_Name__c;
                    queuedShipment.zkfedex__RecipientPhone__c = currentCase.Customer_Phone__c;
                    queuedShipment.zkfedex__RecipientState__c = currentCase.Customer_Ship_State__c;
                    queuedShipment.zkfedex__RecipientStreet__c = currentCase.Customer_Ship_Address__c;
                    queuedShipment.zkfedex__RecipientPostalCode__c = currentCase.Customer_Ship_Zip__c;
                    recepientEmail = currentCase.Customer_Email__c;
                    
            }
            
            
            if(isReturnLabel){
                queuedShipment.zkfedex__ReturnShipment__c = true;
                //queuedShipment.zkups__ReturnType__c = setting.ReturnType__c;
                //queuedShipment.zkups__ReturnDescription__c = returnDescription;
                queuedShipment.zkfedex__EmailRecipient3__c  = recepientEmail;
            }
            
            
            if(isInsert){
                insert queuedShipment; 
            }    
            return queuedShipment;
        
       
        }else {
                throw new BrevilleCustomException(' ' +System.Label.InvalidCustomAddressSource +' ');
         }               
            
    }
    
    //Changes for W-000234
    public static zkmulti__MCShipment__c createMCShipment(zkmulti__MCShipmate_Preference__c shipmatePreference, String workingObject,
                                                                    Id workingobjectId, Case currentCase,ShipmentSetting__c setting,Id bulkShipmentId,
                                                                    Boolean isReturnLabel, Boolean isInsert,String returnDescription,
                                                                    Id  customAddressSourceId, String serviceType, String referenceNumber) {                
        if (customAddressSourceId != null) {
            String serviceTypeForCarrier = serviceType;
            if(serviceTypeForCarrier == null || (serviceTypeForCarrier != null && serviceTypeForCarrier == '')){
                serviceTypeForCarrier = setting.ServiceType__c;
            }
            // 2. zkups__QueuedShipment__c object
            
            zkmulti__MCShipment__c mcShipment = new zkmulti__MCShipment__c (
                            							zkmulti__Shipmate_Preference__c = shipmatePreference.Id,
                                                        zkmulti__Bulk_Shipment__c  = bulkShipmentId,
                                                        zkmulti__Carrier__c = shipmatePreference.zkmulti__Carrier__c,
                                                        //zkmulti__Carrier__c = 'DHL Express',
                                                        zkmulti__Currency__c = currentCase.currencyISOCode,
                                                        zkmulti__Label_Image_Type__c = shipmatePreference.zkmulti__Label_Image_Type_Default__c,
                                                        zkmulti__Service_Type__c  =  serviceTypeForCarrier,
                                                        //zkmulti__Service_Type__c = 'domestic_express',                //'Domestic: UPS Ground'
                                                       zkmulti__Package_Type__c  = setting.PackagingType__c,               //'Your Packaging',
                                                       // zkmulti__Package_Type__c = 'YOUR_PACKAGING',
                                                        zkmulti__Weight_Units__c =  setting.WeightUnits__c, //'LB / IN',
                                                        zkmulti__Dimension_Units__c = setting.DimensionUnits__c, //'IN', 
                                                        //zkmulti__Payment_Type__c  = setting.PaymentType__c, //'SENDER',
                                                        zkmulti__Payment_Type__c = 'shipper',
                                                        //zkmulti__Custom_Address_Source__c = customAddressSourceId,
                                                        //zkmulti__Custom_Address_Source_Record_ID__c = workingobjectId,
                                                        zkmulti__Recipient_Account__c = currentCase.AccountId,
                                                        zkmulti__Recipient_Contact__c = currentCase.ContactId,
                                                        zkmulti__DropoffType__c = setting.DropoffType__c,
                                                        Case__c = currentCase.Id,
                                                        zkmulti__Ship_Date__c = Date.today().addDays(1)
                                                    );

            if(mcShipment.zkmulti__Carrier__c == 'UPS' 
            	|| mcShipment.zkmulti__Carrier__c == 'StarTrack (Australia Post)'
            	|| mcShipment.zkmulti__Carrier__c == 'FedEx'
            	|| mcShipment.zkmulti__Carrier__c == 'Post Haste'){
            	mcShipment.zkmulti__Payment_Type__c = 'SENDER';
            	mcShipment.zkmulti__Billing_Account_Number__c  = shipmatePreference.zkmulti__AccountNumber__c;
            	mcShipment.zkmulti__Billing_Country__c = shipmatePreference.zkmulti__Billing_Country__c;
            }
            
            if(mcShipment.zkmulti__Carrier__c == 'Canada Post'){
                mcShipment.zkmulti__Payment_Type__c  = setting.PaymentType__c;
                mcShipment.zkmulti__Billing_Account_Number__c = setting.Billing_Account_Number__c;
                mcShipment.zkmulti__Reference1_Type__c = 'Reference 1';
            }
            /* Changes for BEC-5002 to allow shipping label ceation on Saturdays */
            if(mcShipment.zkmulti__Carrier__c == 'FedEx'){
                Date dt = mcShipment.zkmulti__Ship_Date__c;
                Integer yr = dt.year();
				Integer mnth = dt.month();
				Integer dy = dt.day();
                DateTime zkmultiShipDate = DateTime.newInstance(yr, mnth, dy, 0, 0, 0);
                String dayOfWeekShipDate  = zkmultiShipDate.format('EEEE');
                if(dayOfWeekShipDate.equalsignorecase('Sunday')){
                    mcShipment.zkmulti__Ship_Date__c = mcShipment.zkmulti__Ship_Date__c.addDays(1);
                }
            }
            mcShipment.zkmulti__Reference1_Value__c= currentCase.CaseNumber;
			mcShipment.zkmulti__Reference5_Value__c = currentCase.CaseNumber;
            
            if(workingObject == 'WorkOrder'){
                mcShipment.WorkOrder__c = workingobjectId;
                mcShipment.zkmulti__Reference1_Value__c = referenceNumber;
            }
            
            //sender info
            if(setting.IsAccountAddress__c){
            	
            	//if(currentCase.ReturnLabelFor__c == 'Service Center')
            	if(workingObject == 'WorkOrder'){
	        		mcShipment.zkmulti__Sender_Address_is_Residential__c =currentCase.Service_Center__r.Residential_Address__c;
					mcShipment.zkmulti__Sender_City__c = currentCase.Service_Center__r.ShippingCity;
					//mcShipment.zkmulti__Sender_Company__c = currentCase.Service_Center__r.BusinessName__c;
					mcShipment.zkmulti__Sender_Company__c = String.isNotBlank(currentCase.Service_Center__r.Name__c)
                        									? currentCase.Service_Center__r.Name__c
                                                            : currentCase.Service_Center__r.BusinessName__c;
					mcShipment.zkmulti__Sender_Country__c = currentCase.Service_Center__r.ShippingCountryCode;
					mcShipment.zkmulti__Sender_Email__c = currentCase.Service_Center__r.Business_Email__c;
					//mcShipment.zkmulti__Sender_Name__c = currentCase.Service_Center__r.Name;
                    mcShipment.zkmulti__Sender_Name__c = String.isNotBlank(currentCase.Service_Center__r.Name__c)
                        								 ? currentCase.Service_Center__r.Name__c
                                                         : currentCase.Service_Center__r.Name;
					mcShipment.zkmulti__Sender_Phone__c = currentCase.Service_Center__r.Phone;
					mcShipment.zkmulti__Sender_State_Province__c = currentCase.Service_Center__r.AccountStateFormula__c;
					mcShipment.zkmulti__Sender_Street__c = currentCase.Service_Center__r.ShippingStreet;
					mcShipment.zkmulti__Sender_Zip_Postal_Code__c = currentCase.Service_Center__r.ShippingPostalCode;
	        		
			    }else if(workingObject == 'Case'){
            		//else if(currentCase.ReturnLabelFor__c == 'Return Location')
			    	mcShipment.zkmulti__Sender_Address_is_Residential__c =currentCase.ReturnLocation__r.Residential_Address__c;
					mcShipment.zkmulti__Sender_City__c = currentCase.ReturnLocation__r.ShippingCity;
					//mcShipment.zkmulti__Sender_Company__c = currentCase.ReturnLocation__r.BusinessName__c;
					mcShipment.zkmulti__Sender_Company__c = String.isNotBlank(currentCase.ReturnLocation__r.Name__c)
                        									? currentCase.ReturnLocation__r.Name__c
                        									: currentCase.ReturnLocation__r.BusinessName__c;
					mcShipment.zkmulti__Sender_Country__c = currentCase.ReturnLocation__r.ShippingCountryCode;
					mcShipment.zkmulti__Sender_Email__c = currentCase.ReturnLocation__r.Business_Email__c;
					//mcShipment.zkmulti__Sender_Name__c = currentCase.ReturnLocation__r.Name;
                    mcShipment.zkmulti__Sender_Name__c = String.isNotBlank(currentCase.ReturnLocation__r.Name__c) 
                        									? currentCase.ReturnLocation__r.Name__c 
                        									: currentCase.ReturnLocation__r.Name;
					mcShipment.zkmulti__Sender_Phone__c = currentCase.ReturnLocation__r.Phone;
					mcShipment.zkmulti__Sender_State_Province__c = currentCase.ReturnLocation__r.AccountStateFormula__c;
					mcShipment.zkmulti__Sender_Street__c = currentCase.ReturnLocation__r.ShippingStreet;
					mcShipment.zkmulti__Sender_Zip_Postal_Code__c = currentCase.ReturnLocation__r.ShippingPostalCode;
			    }
            	
            }else{
                if(workingObject == 'WorkOrder'){
                    mcShipment.zkmulti__Sender_Address_is_Residential__c =shipmatePreference.zkmulti__Shipping_Is_Residential__c;
                    mcShipment.zkmulti__Sender_City__c = shipmatePreference.zkmulti__Shipping_City__c;
                    //mcShipment.zkmulti__Sender_Company__c = shipmatePreference.zkmulti__Company_Name__c;
                    mcShipment.zkmulti__Sender_Company__c = String.isNotBlank(currentCase.Service_Center__r.Name__c)
                        									? currentCase.Service_Center__r.Name__c
                                                            : currentCase.Service_Center__r.BusinessName__c;
                    mcShipment.zkmulti__Sender_Country__c = shipmatePreference.zkmulti__Shipping_Country__c;
                    mcShipment.zkmulti__Sender_Email__c = shipmatePreference.zkmulti__Sender_Email_Default__c;
                    //mcShipment.zkmulti__Sender_Name__c = shipmatePreference.zkmulti__Sender_Name_Default__c;
                    mcShipment.zkmulti__Sender_Name__c = String.isNotBlank(currentCase.Service_Center__r.Name__c)
                        								 ? currentCase.Service_Center__r.Name__c
                                                         : currentCase.Service_Center__r.Name;
                    mcShipment.zkmulti__Sender_Phone__c = shipmatePreference.zkmulti__Sender_Phone_Default__c;
                    mcShipment.zkmulti__Sender_State_Province__c = shipmatePreference.zkmulti__Shipping_State__c;
                    mcShipment.zkmulti__Sender_Street__c = shipmatePreference.zkmulti__Shipping_Street__c;
                    mcShipment.zkmulti__Sender_Zip_Postal_Code__c = shipmatePreference.zkmulti__Shipping_Zip_Postal_Code__c;
                    
                }else if(workingObject == 'Case'){
                    mcShipment.zkmulti__Sender_Address_is_Residential__c =shipmatePreference.zkmulti__Shipping_Is_Residential__c;
                    mcShipment.zkmulti__Sender_City__c = shipmatePreference.zkmulti__Shipping_City__c;
                    mcShipment.zkmulti__Sender_Company__c = shipmatePreference.zkmulti__Company_Name__c;
                    mcShipment.zkmulti__Sender_Country__c = shipmatePreference.zkmulti__Shipping_Country__c;
                    mcShipment.zkmulti__Sender_Email__c = shipmatePreference.zkmulti__Sender_Email_Default__c;
                    mcShipment.zkmulti__Sender_Name__c = shipmatePreference.zkmulti__Sender_Name_Default__c;
                    mcShipment.zkmulti__Sender_Phone__c = shipmatePreference.zkmulti__Sender_Phone_Default__c;
                    mcShipment.zkmulti__Sender_State_Province__c = shipmatePreference.zkmulti__Shipping_State__c;
                    mcShipment.zkmulti__Sender_Street__c = shipmatePreference.zkmulti__Shipping_Street__c;
                    mcShipment.zkmulti__Sender_Zip_Postal_Code__c = shipmatePreference.zkmulti__Shipping_Zip_Postal_Code__c;
                }
	        }
                
            if(currentCase.RecordType.Name == 'RMA'){
                    // you can set it from custom address source or from case directly
                    mcShipment.zkmulti__Recipient_City__c = currentCase.Pickup_City__c;
					mcShipment.zkmulti__Recipient_Company__c = currentCase.Company_Name__c;
					mcShipment.zkmulti__Recipient_Country__c = currentCase.Pickup_Country__c;
					mcShipment.zkmulti__Recipient_Email__c = currentCase.Consignee_Email__c;
					mcShipment.zkmulti__Recipient_Name__c = currentCase.Consignee_Contact_Name__c;
					mcShipment.zkmulti__Recipient_Phone__c = currentCase.Consignee_Phone__c;
					mcShipment.zkmulti__Recipient_State_Province__c = currentCase.Pickup_State__c;
					mcShipment.zkmulti__Recipient_Street__c = currentCase.Pickup_Address_1__c+(currentCase.Pickup_Address_2__c != null
																		? ' '+currentCase.Pickup_Address_2__c : '');
					mcShipment.zkmulti__Recipient_Zip_Postal_Code__c = currentCase.Pickup_Postal_Code__c;
                    
             }else{
                    // you can set it from custom address source or from case directly
                    mcShipment.zkmulti__Recipient_Address_is_Residential__c = currentCase.Residential_Address__c;
					mcShipment.zkmulti__Recipient_City__c = currentCase.Customer_Ship_City__c;
					mcShipment.zkmulti__Recipient_Company__c = currentCase.Company_Name__c;
					mcShipment.zkmulti__Recipient_Country__c = currentCase.Customer_Ship_Country__c;
					mcShipment.zkmulti__Recipient_Email__c = currentCase.Customer_Email__c;
					mcShipment.zkmulti__Recipient_Name__c = currentCase.Customer_Name__c;
					mcShipment.zkmulti__Recipient_Phone__c = currentCase.Customer_Phone__c;
					mcShipment.zkmulti__Recipient_State_Province__c = currentCase.Customer_Ship_State__c;
					mcShipment.zkmulti__Recipient_Street__c = currentCase.Customer_Ship_Address__c;
					mcShipment.zkmulti__Recipient_Zip_Postal_Code__c = currentCase.Customer_Ship_Zip__c;
                    
                           
             }
             mcShipment.zkmulti__Return_Shipment__c  = isReturnLabel;
            if(isInsert){
                insert mcShipment; 
            }    
            return mcShipment;
        
       
        }else {
                throw new BrevilleCustomException(' ' +System.Label.InvalidCustomAddressSource +' ');
         }               
            
    }
    
    public static zkmulti__MCPackage__c createMCPackage(Id shipmentId,ShipmentSetting__c setting,
                                                                     Decimal declaredValue,DimensionBean dimension,Boolean isInsert) {
        

        zkmulti__MCPackage__c mcPackage = new zkmulti__MCPackage__c( 
                                                            zkmulti__Height__c =dimension.height, 
                                                            zkmulti__Length__c = dimension.length, 
                                                            zkmulti__Width__c = dimension.width, 
                                                            zkmulti__Weight__c = dimension.weight, //.setScale(2), 
                                                            zkmulti__Weight_Units__c = setting.WeightUnits__c, 
                                                            zkmulti__Dimension_Units__c = setting.DimensionUnits__c,
                                                            zkmulti__Packaging_Type__c = setting.PackagingType__c, 
                                                            zkmulti__Shipment__c = shipmentId,
                                                            zkmulti__DeclaredValue__c = 0
                                                     );
        
        if (isInsert ) {
            insert mcPackage;
        }
        return mcPackage;
    }
    
    
    
    public static zkups__QueuedPackage__c createUPSQueuedPackage(Id queuedShipmentId, Decimal declaredValue,DimensionBean dimension, Boolean isInsert) {
        
        zkups__QueuedPackage__c queuedPackage = new zkups__QueuedPackage__c (
                    zkups__DeclaredValue__c = declaredValue,
                    zkups__Weight__c = dimension.weight,
                    zkups__Height__c = dimension.height,
                    zkups__Width__c = dimension.width,
                    zkups__Length__c = dimension.length,
                    zkups__QueuedShipment__c = queuedShipmentId         
                );
        if (isInsert ) {
            insert queuedPackage;
        }
        return queuedPackage;
    }
    
    public static zkfedex__QueuedPackage__c createFedExQueuedPackage(Id queuedShipmentId, Decimal declaredValue,DimensionBean dimension, Boolean isInsert) {
        
        zkfedex__QueuedPackage__c queuedPackage = new zkfedex__QueuedPackage__c (
                    zkfedex__DeclaredValue__c = declaredValue,
                    zkfedex__Weight__c = dimension.weight,
                    zkfedex__Height__c = dimension.height,
                    zkfedex__Width__c = dimension.width,
                    zkfedex__Length__c = dimension.length,
                    zkfedex__QueuedShipment__c = queuedShipmentId         
                );
        if (isInsert ) {
            insert queuedPackage;
        }
        return queuedPackage;
    }
    
    public static zkmulti__MCCustoms_Item__c createMCCustomsItem(Id mcShipmentId,ShipmentSetting__c setting,Decimal quantity, 
                                                        Decimal declaredValue,String currencyISOCode,
                                                        Boolean isInsert, String countryOfManufacture, String description) {
        

        zkmulti__MCCustoms_Item__c mcCustomItem = new zkmulti__MCCustoms_Item__c(
                                                                zkmulti__Weight__c = 1, 
                                                                zkmulti__Weight_Units__c =  setting.WeightUnits__c, 
                                                                zkmulti__UnitPrice__c  = declaredValue,
                                                                zkmulti__Country_of_Manufacture__c = countryOfManufacture, 
                                                                zkmulti__Quantity__c = quantity, 
                                                                zkmulti__Value__c = declaredValue, 
                                                                zkmulti__Value_Currency__c = currencyISOCode, 
                                                                zkmulti__Description__c = description, 
                                                                zkmulti__Shipment__c = mcShipmentId
															);
        if (isInsert ) {
            insert mcCustomItem;
        }
        return mcCustomItem;
    }
    
    /*public static zkmulti__MCQueued_Customs_Item__c createMCCustomsItem(Id queuedShipmentId,ShipmentSetting__c setting,Decimal quantity, 
                                                        Decimal declaredValue,String currencyISOCode,Boolean isInsert, String billingCountryCode) {
        

        zkmulti__MCQueued_Customs_Item__c queuedPackageItem = new zkmulti__MCQueued_Customs_Item__c(
                                                                zkmulti__Weight__c = 1, 
                                                                zkmulti__Weight_Units__c =  setting.WeightUnits__c, 
                                                                //zkmulti__Country_of_Manufacture__c = 'US', 
                                                                //zkmulti__Harmonized_Code__c = '1234567', 
                                                                zkmulti__Quantity__c = quantity, 
                                                                zkmulti__Value__c = declaredValue, 
                                                                zkmulti__Value_Currency__c = currencyISOCode, 
                                                                zkmulti__Description__c = 'Description', 
                                                                zkmulti__Queued_Shipment__c = queuedShipmentId,
                                                                zkmulti__Country_of_Manufacture__c = billingCountryCode
                                                            );
        
        if (isInsert ) {
            insert queuedPackageItem;
        }
        return queuedPackageItem;
    }*/
    
    public class DimensionBean{
        public Decimal length               {get;set;}
        public Decimal width                {get;set;}
        public Decimal height               {get;set;}
        public Decimal weight               {get;set;}
        public String dimension             {get;set;}
        public String dimensionUnits        {get;set;}
        public String weightUnits           {get;set;}
        public ShipmentSetting__c shipmateSet ;
        
        public DimensionBean(Decimal length,Decimal width,Decimal height,Decimal weight,ShipmentSetting__c shipmateSet,
                                                                            String dimensionUnits, String weightUnits){
            this.length = length;
            this.width = width;
            this.height = height;
            this.weight = weight;
            this.dimensionUnits = dimensionUnits;
            this.weightUnits = weightUnits;
            this.shipmateSet = shipmateSet;
           
        }
        
        public void checkForUnitConversion(){
            
            //check for dimension units
            Decimal conversionRate = null;
            if(shipmateSet.DimensionUnits__c != null && dimensionUnits != null && !shipmateSet.DimensionUnits__c.equalsignorecase(dimensionUnits) ){
                
                if( dimensionUnits.contains('CM')  && shipmateSet.DimensionUnits__c.contains('IN') ){
                    //convert CM To IN
                    conversionRate = ApplicationLiterals.CM_TO_IN_CRATE;
                }else if(dimensionUnits.contains('IN')  && shipmateSet.DimensionUnits__c.contains('CM')){
                    //convert IN To CM
                    conversionRate = ApplicationLiterals.IN_TO_CM_CRATE;
                }
                if(conversionRate != null){
                    this.length = this.length != null ? (this.length * conversionRate ).setscale(1):this.length;
                    this.width = this.width != null ? (this.width * conversionRate ).setscale(1):this.width;
                    this.height = this.height != null ? (this.height *conversionRate ).setscale(1):this.height; 
                }
                
                //roundTheValues(); 
            }
            conversionRate = null;
            if(shipmateSet.WeightUnits__c != null && weightUnits != null && !shipmateSet.WeightUnits__c.equalsignorecase(weightUnits) ){
                
                if( weightUnits.contains('LB')  && shipmateSet.WeightUnits__c.contains('KG') ){
                    //convert LB To KG
                    conversionRate = ApplicationLiterals.LB_TO_KG_CRATE;
                }else if(weightUnits.contains('KG')  && shipmateSet.WeightUnits__c.contains('LB')){
                    //convert KG To LB
                    conversionRate = ApplicationLiterals.KG_TO_LB_CRATE;
                }
                if(conversionRate != null){
                    this.weight = this.weight != null ? (this.weight * conversionRate ).setscale(1):this.weight;
                }
                
            }
            //roundTheValues(); 
        }
        public DimensionBean(String dimension,Decimal weight,ShipmentSetting__c shipmateSet,String dimensionUnits, String weightUnits){
            this.dimension = dimension;
            this.weight = weight;
            this.shipmateSet = shipmateSet;
            this.dimensionUnits = dimensionUnits;
            this.weightUnits = weightUnits;
            convertDeimensionFromString();
        }
        public DimensionBean(){

        }
        private void convertDeimensionFromString(){
            if(dimension != null && dimension != ''){
                String[] dimensionList;
                if(dimension.contains('X')){
                    dimensionList = dimension.trim().split('X');
                }else if(dimension.contains('x')){
                    dimensionList = dimension.trim().split('x');
                }
                if(dimensionList != null && dimensionList.size() > 2){
                    this.length = convertDimensionToDecimalValue(dimensionList[0].trim());
                    this.width = convertDimensionToDecimalValue(dimensionList[1].trim());
                    this.height = convertDimensionToDecimalValue(dimensionList[2].trim());
                    
                }
                
            }
        }
        private void roundTheValues(){
            length = length != null ? length.round() : 0;
            width = width != null ? width.round() : 0;
            height = height != null ? height.round() : 0;
            weight = weight != null ? weight.round()  : 0;
            
            
        }
        private Decimal convertDimensionToDecimalValue(String singleDimentsionStr){
            Decimal decimalValue = 0.0;
            if( singleDimentsionStr.contains(' ')){
                String[] lengthParts = singleDimentsionStr.split(' ');
                if(lengthParts != null && lengthParts.size() > 0){
                    decimalValue = Decimal.valueOf(lengthParts[0].trim());
                    decimalValue += convertPartstoDecimal(lengthParts[1].trim());
                }
            }else{
                    decimalValue = Decimal.valueOf(singleDimentsionStr);
            }
            return decimalValue;
       }
       
       private Decimal convertPartstoDecimal(String decimalParts){
            Decimal decimalValue = 0.0;
            if(decimalParts != null && decimalParts.contains('/')){
                String[] numeratorAndDenominator = decimalParts.split('/');
                decimalValue = Decimal.valueOf(numeratorAndDenominator[0].trim())/Decimal.valueOf(numeratorAndDenominator[1].trim());
            }
            return decimalValue;
        }
        public void sortTheDimension(){
            
            if(shipmateSet.SortDimension__c){
                list<Decimal> decimalForSort = new List<Decimal>{this.length,this.width,this.height};
                decimalForSort.sort();
                this.length = decimalForSort[2];
                this.width = decimalForSort[1];
                this.height = decimalForSort[0];
            }
        }       
   }    
}