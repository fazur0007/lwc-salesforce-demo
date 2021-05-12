public class LightningCreateReturnLabelCaseCtrl {
    @AuraEnabled
    public static Map < String, Object > initLoadConfig(String workingObjectId) {
        Map < String, Object > initConfigMap = new Map < String, Object > ();
        initConfigMap.put('isSuccess', false);
        initConfigMap.put('isValid', false);
        initConfigMap.put('isCreateLabelIntiate', false);
        initConfigMap.put('createBoxOrder', false);
        Case cse = [Select Id, ReturnLabelFor__c, RA_Tracking__c ,ReturnLocation__c,CaseNumber  From Case Where Id =:workingObjectId Limit 1];
        if(cse != Null ){
            initConfigMap.put('RA_Tracking', String.isNotBlank(cse.RA_Tracking__c) ? cse.RA_Tracking__c : '');
            initConfigMap.put('ReturnLocation', (cse.ReturnLocation__c != Null ? cse.ReturnLocation__c : Null));
            
            Boolean hasWorkOrder = false;
            Integer workOrderCount = [SELECT count() FROM WorkOrder WHERE CaseId =:cse.id AND Status != 'Repeat Workorder'];
            if(workOrderCount > 0){
                hasWorkOrder = true;
            }
            initConfigMap.put('hasWorkOrder', hasWorkOrder);
        }

        initConfigMap.put('Case', [Select Id, ReturnLabelFor__c, RA_Tracking__c ,ReturnLocation__c,CaseNumber  From Case Where Id =:workingObjectId Limit 1]);
        return initConfigMap;
    }
     @AuraEnabled
    public static Map < String, Object > initiateCreateOutboundShipmate(String workingObjectId, String caseRecordId, String returnLabelFor, Boolean isValid) {
        Map < String, Object > initConfigMap = new Map < String, Object > ();
        try {

            ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
            ShipmentSetting__c shipmateSet  = new ShipmentSetting__c();
            initConfigMap.put('isReturn', false);
            initConfigMap.put('isCreateLabelIntiate', true);
            Case caseRecord = getCaseDetails(caseRecordId, returnLabelFor);
            initConfigMap.put('caseRecord', caseRecord);
            Id locationId = null;
            if (returnLabelFor == 'Service Center') {
                locationId = caseRecord.Service_Center__c;
            }
            else if (returnLabelFor == 'Return Location') {
                locationId = caseRecord.ReturnLocation__c;
            }
            initConfigMap.put('locationId', locationId);
            String errorMessage = validateCaseBeforShipment(locationId, caseRecord);
            initConfigMap.put('errorMessage', errorMessage);
            
            map < Id, ShipmentSetting__c > shipmateSetById = ShipmateUtility.getShipmentSettings(locationId);
            initConfigMap.put('shipmateSetById', shipmateSetById);
            //shipmateSet = ShipmateUtility.getShipmentSetting(locationId);
            if (shipmateSetById != null && !shipmateSetById.isEmpty()) {
                if (shipmateSetById.size() == 1) {
                    shipmateSet = shipmateSetById.values().get(0);
                    //Adding option for user to select shipping method
                    shipmentSetting.ShippingCarrier__c = shipmateSet.ShippingCarrier__c;
                    shipmentSetting.ServiceType__c = shipmateSet.ServiceType__c;
                    shipmentSetting.ShipmateApp__c = shipmateSet.ShipmateApp__c;
                    shipmentSetting.ShipmatePreference__c = shipmateSet.ShipmatePreference__c;
                    getDimension(caseRecord, shipmateSet, initConfigMap);
                    initConfigMap.put('shippingCarriersSize', 0);
                }
                else {
                    //multiple option found show  option to users
                    isValid = false;
                    initConfigMap.put('isValid', false);
                    initConfigMap.put('selectedShippingCarrier', '');
                                       
                    List < Map < String, String >> shippingCarriers = new List < Map < String, String >> ();
                    /*shippingCarriers.add(new Map < String, String > {
                        'value' => '',
                        'label' => '--None--'
                    });*/
                    for (ShipmentSetting__c setting: shipmateSetById.values()) {
                        shippingCarriers.add(new Map < String, String > {
                            'value' => setting.id,
                            'label' => setting.ShippingCarrier__c
                        });
                    }
                    initConfigMap.put('shippingCarriers', shippingCarriers);
                    initConfigMap.put('shippingCarriersSize', shippingCarriers.size());
                    //work around to initiate with any one shipping
                    //shipmateSet = shipmateSetById.values().get(0);
                    getDimension(caseRecord, shipmateSet, initConfigMap);
                }

            }
            else {
                String errorMessage1 = Label.No_Shipping_Preference_found;
                AuraHandledException ex = new AuraHandledException(errorMessage1);
                ex.setMessage(errorMessage1);
                If(!Test.isRunningTest())
                    throw ex;
                //initConfigMap.put('No_Shipping_Preference_found', System.Label.No_Shipping_Preference_found);
            }
            initConfigMap.put('shipmateSet', shipmateSetById.values().get(0));
            initConfigMap.put('shipmentSetting', shipmentSetting);
        }
        catch (Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateOutboundShipmate ', true,
                ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);
            throw new AuraHandledException(ex.getMessage());
        }
        return initConfigMap;
    }
    @AuraEnabled
    public static Map < String, Object > initiateCreateReturnShipmate(String workingObjectId, String caseRecordId, String returnLabelFor, Boolean isValid) {
        Map < String, Object > initConfigMap = new Map < String, Object > ();
        try {
            ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
            ShipmentSetting__c shipmateSet = new ShipmentSetting__c();
            initConfigMap.put('isReturn', true);
            initConfigMap.put('isCreateLabelIntiate', true);
            Case caseRecord = getCaseDetails(caseRecordId, returnLabelFor);
            initConfigMap.put('caseRecord', caseRecord);
            Id locationId = null;
            if (returnLabelFor == 'Service Center') {
                locationId = String.isNotBlank(caseRecord.Service_Center__c) ? caseRecord.Service_Center__c : Null;
            }
            else if (returnLabelFor == 'Return Location') {
                locationId = String.isNotBlank(caseRecord.ReturnLocation__c) ? caseRecord.ReturnLocation__c : Null;
            }
            initConfigMap.put('locationId', locationId);
            String errorMessage = validateCaseBeforShipment(locationId, caseRecord);
            initConfigMap.put('errorMessage', errorMessage);

            map < Id, ShipmentSetting__c > shipmateSetById = ShipmateUtility.getShipmentSettings(locationId);
            initConfigMap.put('shipmateSetById', shipmateSetById);
            if (shipmateSetById != null && !shipmateSetById.isEmpty()) {
                if (shipmateSetById.size() == 1) {
                    shipmateSet = shipmateSetById.values().get(0);
                    system.debug(shipmateSet.ShippingCarrier__c + '**********' + shipmateSet);
                    shipmentSetting.ShippingCarrier__c = shipmateSet.ShippingCarrier__c;
                    shipmentSetting.ServiceType__c = shipmateSet.ServiceType__c;
                    shipmentSetting.ShipmateApp__c = shipmateSet.ShipmateApp__c;
                    shipmentSetting.ShipmatePreference__c = shipmateSet.ShipmatePreference__c;

                    getDimension(caseRecord, shipmateSet, initConfigMap);
                    initConfigMap.put('shippingCarriersSize', 0);

                }
                else {
                    isValid = false;
                    initConfigMap.put('isValid', false);
                    String selectedShippingCarrier = '';
                    initConfigMap.put('selectedShippingCarrier', '');
                    List < Map < String, String >> shippingCarriers = new List < Map < String, String >> ();
                    /*shippingCarriers.add(new Map < String, String > {
                        'value' => '',
                        'label' => '--None--'
                    });*/
                    for (ShipmentSetting__c setting: shipmateSetById.values()) {
                        shippingCarriers.add(new Map < String, String > {
                            'value' => setting.id,
                            'label' => setting.ShippingCarrier__c
                        });
                    }
                    initConfigMap.put('shippingCarriers', shippingCarriers);
                    initConfigMap.put('shippingCarriersSize', shippingCarriers.size());
                    getDimension(caseRecord, shipmateSet, initConfigMap);
                }
            }
            else {
                String errorMessage1 = Label.No_Shipping_Preference_found;
                AuraHandledException ex = new AuraHandledException(errorMessage1);
                ex.setMessage(errorMessage1);
                If(!Test.isRunningTest())
                    throw ex;
                //throw new AuraHandledException(System.Label.No_Shipping_Preference_found);
                //initConfigMap.put('No_Shipping_Preference_found', System.Label.No_Shipping_Preference_found);
            }
            initConfigMap.put('shipmateSet', shipmateSetById.values().get(0));
            initConfigMap.put('shipmentSetting', shipmentSetting);
        }
        catch (Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateReturnShipmate ', true,
                ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);
            throw new AuraHandledException(ex.getMessage());
        }
        return initConfigMap;
    }
    public static void getDimension(Case caseRecord, ShipmentSetting__c shipmateSet, Map < String, Object > initConfigMap) {
        if (caseRecord.Product__r.Length__c != null && caseRecord.Product__r.Width__c != null && caseRecord.Product__r.Height__c != null) {
            ShipmateUtility.DimensionBean dimension = new ShipmateUtility.DimensionBean(
                caseRecord.Product__r.Length__c, caseRecord.Product__r.Width__c,
                caseRecord.Product__r.Height__c, caseRecord.Product__r.Weight__c, shipmateSet,
                caseRecord.Product__r.DimensionUnits__c, caseRecord.Product__r.WeightUnits__c
            );
            initConfigMap.put('dimension', JSON.serialize(dimension));
            system.debug('dimension*******' + dimension);
        }
        else if (caseRecord.Product__r.Dimensions__c != null && caseRecord.Product__r.Dimensions__c != '') {
            ShipmateUtility.DimensionBean dimension = new ShipmateUtility.DimensionBean(caseRecord.Product__r.Dimensions__c, caseRecord.Product__r.Weight__c, shipmateSet,
                caseRecord.Product__r.DimensionUnits__c, caseRecord.Product__r.WeightUnits__c);
            initConfigMap.put('dimension', JSON.serialize(dimension));
            system.debug('dimension*******' + dimension);
        }

    }
    public static String validateCaseBeforShipment(Id locationId, Case caseRecord) {
        String errorMessage = System.Label.PleaseSelect + ' ';
        Boolean isValid = true;
        if (locationId == null) {
            errorMessage += System.Label.ServiceCenter + ' ';
            isValid = false;
        }
        if (caseRecord.Product__c == null) {
            errorMessage += (!isValid ? ', ' : '') + System.Label.ProductLabel;
            isValid = false;
        }
        if (!isValid) {
            return errorMessage + '.';
        }
        else {
            return '';
        }
    }
    public static Case getCaseDetails(String caseRecordId, String returnLabelFor) {
        String referenceField = 'Service_Center__r.';
        if (returnLabelFor == 'Service Center') {
            referenceField = 'Service_Center__r.';
        }
        else if (returnLabelFor == 'Return Location') {
            referenceField = 'ReturnLocation__r.';
        }
        String queryStrng = 'SELECT  Id, Account.BillingCountryCode, Customer_Ship_City__c,Product__r.Dimensions__c,' +
            'Product__r.Weight__c,currencyISOCode,Company_Name__c,' +
            'Product__r.Country_of_Manufacture__c,Product__r.Description,' +
            'Product__r.Width__c,Product__c, Product__r.Name,Product__r.Height__c,Product__r.Length__c,' +
            'Product__r.DimensionUnits__c,Product__r.WeightUnits__c,Product__r.Service_Return_Box__c,' +
            'Product__r.Landed_Cost__c,Customer_Ship_Country__c, Customer_Email__c, Customer_Name__c,' +
            'Customer_Phone__c, Customer_Ship_State__c, Customer_Ship_Address__c,' +
            'Customer_Ship_Zip__c,Residential_Address__c,AccountId,ContactId,CaseNumber,' +
            'RecordType.Name,ReturnLabelFor__c,ReturnLocation__c,Service_Center__c,' +
            referenceField + 'ShippingCountryCode,' + referenceField + 'ShippingStateCode,' + referenceField + 'ShippingCity,' +
            referenceField + 'ShippingState,' + +referenceField + 'ShippingCountry,' +
            referenceField + 'ShippingStreet,' + referenceField + 'ShippingPostalCode,' + referenceField + 'Business_Email__c,' +
            referenceField + 'Phone,' + referenceField + 'Residential_Address__c,' + referenceField + 'AccountStateFormula__c,' +
            referenceField + 'Company_Name__c,' + referenceField + 'Name,' + referenceField + 'BusinessName__c,' + referenceField + 'Name__c' +
            ' FROM Case WHERE  Id =:caseRecordId LIMIT 1';

        Case currentCase = Database.query(queryStrng);

        return currentCase;
    }
    @AuraEnabled
    public static Map < String, Object > createReturnShipmate(
        String workingObjectId,
        String caseRecordId,
        String locationId,
        ShipmentSetting__c shipmentSetting,
        ShipmentSetting__c shipmateSet,
        boolean createBoxOrder,
        String workingObject,
        Boolean isReturn,
        String returnDescriptionCls,
        String returnLabelFor,
        String refNumber,

        String selectedShippingCarrier,
        String selectedServiceType,
        Decimal Landed_Cost,
        Decimal dimension_weight,
        Decimal dimension_length,
        Decimal dimension_width,
        Decimal dimension_height
    ) {
        Map < String, Object > initConfigMap = new Map < String, Object > ();
        try {
            Case caseRecord = getCaseDetails(caseRecordId, returnLabelFor); //[Select Id, Product__r.Service_Return_Box__c, Service_Center__c,currencyISOCode,AccountId,ContactId From Case Where Id =: caseRecordId Limit 1];
            initConfigMap.put('caseRecord', caseRecord);
            Boolean isSuccess=false;
            if (locationId != null) {
                system.debug('locationId *****' + locationId);
                //shipmateSet = ShipmateUtility.getShipmentSetting(caseRecord.Service_Center__c);
                system.debug('shipmateSet *****' + shipmateSet != null);
                if (shipmateSet != null) {
                    system.debug(shipmentSetting.ServiceType__c + 'service type *****shipmateSet *****' + shipmateSet.ShipmateApp__c);
                    String serviceType = shipmentSetting.ServiceType__c;
                    if (createBoxOrder && caseRecord.Product__r.Service_Return_Box__c != null) {
                        Utility.createBoxOrderRecordFromCase(caseRecord.Id);
                    }
                    if (shipmateSet.ShipmateApp__c == ApplicationLiterals.SHIPMATE_APP_NAME) {
                        system.debug('shipmateSet.ShipmateApp__c *****' + shipmateSet.ShipmateApp__c);
                        processUPSShiping(workingObjectId, workingObject, caseRecord, isReturn, returnDescriptionCls, shipmateSet, initConfigMap, serviceType,
                            selectedShippingCarrier,
                            selectedServiceType,
                            Landed_Cost,
                            dimension_weight,
                            dimension_length,
                            dimension_width,
                            dimension_height
                        );
                        isSuccess=true;
                        system.debug('Printt 1'+initConfigMap.get('isSuccess'));
                    }
                    else if (shipmateSet.ShipmateApp__c == ApplicationLiterals.MULTI_CARRIER_NAME) {
                        system.debug('shipmateSet.ShipmateApp__c *****' + shipmateSet.ShipmateApp__c);
                        processMCShiping(workingObjectId, workingObject, caseRecord,
                            isReturn, returnDescriptionCls, shipmateSet,
                            initConfigMap, serviceType, returnLabelFor, refNumber,
                            selectedShippingCarrier,
                            selectedServiceType,
                            Landed_Cost,
                            dimension_weight,
                            dimension_length,
                            dimension_width,
                            dimension_height
                        );
                        isSuccess = true;
                    }
                    else if (shipmateSet.ShipmateApp__c == 'FedEx') {
                        processFedExShiping(workingObjectId, workingObject, caseRecord, isReturn, returnDescriptionCls, shipmateSet, initConfigMap, serviceType,
                            selectedShippingCarrier,
                            selectedServiceType,
                            Landed_Cost,
                            dimension_weight,
                            dimension_length,
                            dimension_width,
                            dimension_height
                        );
                        isSuccess = true;
                    }
                    initConfigMap.put('isSuccess', isSuccess);
                }
                else {
                    //throw new AuraHandledException(System.Label.No_Shipping_Preference_found);
                    initConfigMap.put('No_Shipping_Preference_found', System.Label.No_Shipping_Preference_found);
                }
            }
            else {
                throw new AuraHandledException(System.Label.PleaseSelectServiceCenter);
            }
        }
        catch (Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateOutboundShipmate ', true,
                ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);
        }
        system.debug('Printt 2'+initConfigMap.get('isSuccess'));
        return initConfigMap;
    }
    public static void processUPSShiping(String workingObjectId, String workingObject, Case caseRecord, Boolean isReturn,
        String returnDescriptionCls, ShipmentSetting__c shipmateSet, Map < String, Object > initConfigMap,
        String serviceType,
        String selectedShippingCarrier,
        String selectedServiceType,
        Decimal Landed_Cost,
        Decimal dimension_weight,
        Decimal dimension_length,
        Decimal dimension_width,
        Decimal dimension_height
    ) {
        //getShipment Preference
        Id bulkShipmentId = null;
        id queuedShipmentId = null;
        system.debug('in processUPSShiping method to test bulkShipmentId');
        zkups__UPSShipmatePreference__c shipmatePref = ShipmateUtility.getUPSShipmentPreference(shipmateSet.UPSShipmatePreference__c);
        ShipmateUtility.DimensionBean dimension = new ShipmateUtility.DimensionBean(
            dimension_length,
            dimension_width,
            dimension_height,
            dimension_weight,
            shipmateSet,
            caseRecord.Product__r.DimensionUnits__c,
            caseRecord.Product__r.WeightUnits__c
        );
        if (shipmatePref != null) {
            //create bulkShipment
            dimension.checkForUnitConversion();
            dimension.sortTheDimension();
            zkups__BulkShipment__c bulkShipment = ShipmateUtility.createUPSBulkShipmate(shipmatePref, true);
            system.debug('bulkShipment****' + JSON.serialize(bulkShipment));
            bulkShipmentId = bulkShipment.Id;
            //create queued shipmate record
            zkups__CustomAddressSource__c customAddressSource = ShipmateUtility.getUPSCustomAddressSource(workingObject);

            zkups__QueuedShipment__c queuedShipment = ShipmateUtility.createUPSQueuedShipment(shipmatePref, workingObject,
                workingObjectId, caseRecord, shipmateSet, bulkShipment.Id,
                isReturn, true, returnDescriptionCls, customAddressSource.Id, serviceType);
            queuedShipmentId = queuedShipment.Id;
            system.debug('queuedShipmentId' + JSON.serialize(queuedShipment));
            //Create Queue package


            zkups__QueuedPackage__c queuedPackage = ShipmateUtility.createUPSQueuedPackage(queuedShipment.Id, caseRecord.Product__r.Landed_Cost__c,
                dimension, true);
            system.debug('queuedPackage' + JSON.serialize(queuedPackage));
            initConfigMap.put('bulkShipmentId', String.isNotBlank(bulkShipmentId) ? bulkShipmentId : '');
            initConfigMap.put('queuedShipmentId', String.isNotBlank(queuedShipmentId) ? queuedShipmentId : '');
        }

    }
    public static void processFedExShiping(String workingObjectId, String workingObject, Case caseRecord, Boolean isReturn,
        String returnDescriptionCls, ShipmentSetting__c shipmateSet, Map < String, Object > initConfigMap,
        String serviceType,
        String selectedShippingCarrier,
        String selectedServiceType,
        Decimal Landed_Cost,
        Decimal dimension_weight,
        Decimal dimension_length,
        Decimal dimension_width,
        Decimal dimension_height
    ) {
        ShipmateUtility.DimensionBean dimension = new ShipmateUtility.DimensionBean(
            dimension_length,
            dimension_width,
            dimension_height,
            dimension_weight,
            shipmateSet,
            caseRecord.Product__r.DimensionUnits__c,
            caseRecord.Product__r.WeightUnits__c
        );
        //getShipment Preference
        Id bulkShipmentId = null;
        id queuedShipmentId = null;
        zkfedex__ShipmatePreference__c shipmatePref = ShipmateUtility.getFedExShipmentPreference(shipmateSet.FedExShipmatePreference__c);
        if (shipmatePref != null) {
            //create bulkShipment
            dimension.checkForUnitConversion();
            dimension.sortTheDimension();
            zkfedex__BulkShipment__c bulkShipment = ShipmateUtility.createFedExBulkShipmate(shipmatePref, true);
            bulkShipmentId = bulkShipment.Id;
            //create queued shipmate record
            zkfedex__CustomAddressSource__c customAddressSource = ShipmateUtility.getFedExCustomAddressSource(workingObject);
            zkfedex__QueuedShipment__c queuedShipment = ShipmateUtility.createFedExQueuedShipment(shipmatePref, workingObject,
                workingObjectId, caseRecord, shipmateSet, bulkShipment.Id,
                isReturn, true, returnDescriptionCls, customAddressSource.Id, serviceType);
            queuedShipmentId = queuedShipment.Id;
            //Create Queue package
            zkfedex__QueuedPackage__c queuedPackage = ShipmateUtility.createFedExQueuedPackage(queuedShipment.Id, caseRecord.Product__r.Landed_Cost__c,
                dimension, true);
            initConfigMap.put('bulkShipmentId', String.isNotBlank(bulkShipmentId) ? bulkShipmentId : '');
            initConfigMap.put('queuedShipmentId', String.isNotBlank(queuedShipmentId) ? queuedShipmentId : '');
        }
    }
    public static void processMCShiping(String workingObjectId, String workingObject, Case caseRecord, Boolean isReturn,
        String returnDescriptionCls, ShipmentSetting__c shipmateSet, Map < String, Object > initConfigMap,
        String serviceType, String returnLabelFor, String refNumber,
        String selectedShippingCarrier,
        String selectedServiceType,
        Decimal Landed_Cost,
        Decimal dimension_weight,
        Decimal dimension_length,
        Decimal dimension_width,
        Decimal dimension_height
    ) {
        ShipmateUtility.DimensionBean dimension = new ShipmateUtility.DimensionBean(
            dimension_length,
            dimension_width,
            dimension_height,
            dimension_weight,
            shipmateSet,
            caseRecord.Product__r.DimensionUnits__c,
            caseRecord.Product__r.WeightUnits__c
        );
        //getShipment Preference
        Id bulkShipmentId = null;
        id queuedShipmentId = null;
        //getShipment Preference
        zkmulti__MCShipmate_Preference__c shipmatePref = ShipmateUtility.getMCShipmentPreference(shipmateSet.ShipmatePreference__c);
        system.debug(shipmateSet + '***shipmatePref *****' + shipmatePref);
        if (shipmatePref != null) {
            //create bulkShipment
            dimension.checkForUnitConversion();
            dimension.sortTheDimension();
            zkmulti__MCBulk_Shipment__c bulkShipment = ShipmateUtility.createMCBulkShipmate(shipmatePref, true);
            bulkShipmentId = bulkShipment.Id;
            system.debug('***bulkShipment ***' + bulkShipment);
            //create queued shipmate record
            zkmulti__MCCustom_Address_Source__c customAddressSource = ShipmateUtility.getMCCustomAddressSource(workingObject);

            zkmulti__MCShipment__c mcShipment = ShipmateUtility.createMCShipment(shipmatePref, workingObject, workingObjectId,
                caseRecord, shipmateSet, bulkShipment.Id,
                isReturn, true, returnDescriptionCls,
                customAddressSource.Id, serviceType, refNumber);
            queuedShipmentId = mcShipment.Id;
            system.debug('***mcShipment***' + mcShipment);
            if (mcShipment.zkmulti__Carrier__c == 'UPS') {
                zkmulti__MCShipment_Special_Services__c shipmentSS = new zkmulti__MCShipment_Special_Services__c(
                    zkmulti__Shipment__c = mcShipment.Id,
                    zkmulti__IntlReturnCustomsReturnType__c = '9', // 9 - Print Return Label
                    zkmulti__IntlReturnCustomsReturnDescription__c = 'Description'
                );
                insert shipmentSS;
            }

            //Create Queue package
            zkmulti__MCPackage__c mcPackage = ShipmateUtility.createMCPackage(mcShipment.Id, shipmateSet,
                caseRecord.Product__r.Landed_Cost__c, dimension, true);


            /*W-000236 Changes*/
            if (!(mcShipment.zkmulti__Sender_Country__c == mcShipment.zkmulti__Recipient_Country__c)) {
                zkmulti__MCCustoms_Item__c mcCustomItems = new zkmulti__MCCustoms_Item__c();
                if (returnLabelFor == 'Return Location') {

                    mcCustomItems = ShipmateUtility.createMCCustomsItem(mcShipment.Id, shipmateSet, 1, caseRecord.Product__r.Landed_Cost__c,
                        caseRecord.currencyISOCode, true, caseRecord.Product__r.Country_of_Manufacture__c,
                        caseRecord.Product__r.Description);
                }
                else {
                    mcCustomItems = ShipmateUtility.createMCCustomsItem(mcShipment.Id, shipmateSet, 1,
                        caseRecord.Product__r.Landed_Cost__c, caseRecord.currencyISOCode, true,
                        caseRecord.Product__r.Country_of_Manufacture__c,
                        caseRecord.Product__r.Description);
                }
                initConfigMap.put('zkmulti__MCCustoms_Item', mcCustomItems);
            }
            initConfigMap.put('bulkShipmentId', String.isNotBlank(bulkShipmentId) ? bulkShipmentId : '');
            initConfigMap.put('queuedShipmentId', String.isNotBlank(queuedShipmentId) ? queuedShipmentId : '');
        }
    }
    @AuraEnabled
    public static Case getCaseRecord(String caseRecordId, String returnLabelFor) {
        return getCaseDetails(caseRecordId, returnLabelFor);
    }
    @AuraEnabled
    public static Map < String, Object > setShipmentSettingFromCarrier(String caseRecordId, 
        String returnLabelFor, 
        String selectedShippingCarrier, 
        String locationId, 
        ShipmentSetting__c shipmateSet,
        ShipmentSetting__c shipmentSetting
    ) {
        map < Id, ShipmentSetting__c > shipmateSetById = ShipmateUtility.getShipmentSettings(locationId);
        System.debug('===shipmateSetById===' + shipmateSetById);
        Map < String, Object > initConfigMap = new Map < String, Object > ();
        Case caseRecord = getCaseDetails(caseRecordId, returnLabelFor);
        if (selectedShippingCarrier != null && selectedShippingCarrier != '' && shipmateSetById.containsKey(selectedShippingCarrier)) {
            
            shipmateSet = shipmateSetById.get(selectedShippingCarrier);
            System.debug('===shipmateSet===' + shipmateSet);
            shipmentSetting.ShippingCarrier__c = shipmateSet.ShippingCarrier__c;
            shipmentSetting.ServiceType__c = shipmateSet.ServiceType__c;
            getDimension(caseRecord, shipmateSet, initConfigMap);
            
            initConfigMap.put('isValid', true);
            initConfigMap.put('shipmateSet', shipmateSet);
            initConfigMap.put('shipmentSetting', shipmentSetting);
            initConfigMap.put('caseRecord', caseRecord);
        }
        else {
            initConfigMap.put('isValid', false);
        }
        return initConfigMap;
    }
    @AuraEnabled
    public static Map < String, Object > processBulkShipment(
        String workingObjectId,
        String caseRecordId,
        String bulkShipmentId,
        ShipmentSetting__c shipmateSet,
        Boolean isSuccess,
        String returnLabelFor
    ) {
        system.debug('workingObjectId***'+workingObjectId);
        system.debug('caseRecordId***'+caseRecordId);
        system.debug('bulkShipmentId***'+bulkShipmentId);
        system.debug('shipmateSet**'+shipmateSet);
        system.debug('isSuccess***'+isSuccess);
        system.debug('returnLabelFor***'+returnLabelFor);
        Map < String, Object > mapOfObjects = new Map < String, Object > ();
        try {
            Case caseRecord = getCaseDetails(caseRecordId, returnLabelFor);
            mapOfObjects.put('caseRecord', caseRecord);
            if (!isSuccess && bulkShipmentId != null) {
                mapOfObjects.put('bulkShipmentIdError', bulkShipmentId);
                return null;
            }
            if (shipmateSet.ShipmateApp__c == ApplicationLiterals.SHIPMATE_APP_NAME) {
                String batchId = ShipmateUtility.processUPSBulkShipment(bulkShipmentId, false);
                List < zkups__QueuedShipmentStatus__c > successList = new List < zkups__QueuedShipmentStatus__c > ();
                List < zkups__QueuedShipmentStatus__c > errorsList = new List < zkups__QueuedShipmentStatus__c > ();

                for (zkups__QueuedShipmentStatus__c queuedStatus: [SELECT zkups__StatusMessage__c, zkups__Shipment__c,
                        zkups__QueuedShipment__r.WorkOrder__c, zkups__Status__c
                        FROM zkups__QueuedShipmentStatus__c
                        WHERE zkups__BatchId__c =: batchId
                        LIMIT 5
                    ]) {
                    if (queuedStatus.zkups__Status__c == ApplicationLiterals.SHIPMATE_STATUS_ERROR) {
                        errorsList.add(queuedStatus);
                    }
                    else if (queuedStatus.zkups__Status__c == ApplicationLiterals.SHIPMATE_SUCCESS) {
                        successList.add(queuedStatus);
                    }
                }
                if (!errorsList.isEmpty()) {

                    String errorMessage = '';
                    for (zkups__QueuedShipmentStatus__c err: errorsList) {
                        errorMessage = errorMessage + err.zkups__StatusMessage__c;
                    }
                    mapOfObjects.put('errorMessage', 'Validation Error: ' + errorMessage);
                    isSuccess = false;
                    getDimension(caseRecord, shipmateSet, mapOfObjects);
                    mapOfObjects.put('isSuccess', isSuccess);
                }
                else if (!successList.isEmpty()) {
                    mapOfObjects.put('ShipmentRecordCreatedSuccessfully', System.Label.ShipmentRecordCreatedSuccessfully);
                }
                else {
                    isSuccess = false;
                    mapOfObjects.put('isSuccess', isSuccess);
                    mapOfObjects.put('errorMessageContactAdmin', 'Unknown Error : Please contact System Adminstrator');
                    Error_Log__c error = ErrorLog.logErrorActivity('processUPSBulkShipment',
                        'No queued Shipment Status record found',
                        'CreateReturnLabelCtrl -processBulkShipment', true,
                        ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);
                    getDimension(caseRecord, shipmateSet, mapOfObjects);
                }

            }
            else if (shipmateSet.ShipmateApp__c == 'FedEx') {
                String batchId = ShipmateUtility.processFedExBulkShipment(bulkShipmentId, false);
                List < zkfedex__QueuedShipmentStatus__c > successList = new List < zkfedex__QueuedShipmentStatus__c > ();
                List < zkfedex__QueuedShipmentStatus__c > errorsList = new List < zkfedex__QueuedShipmentStatus__c > ();
                for (zkfedex__QueuedShipmentStatus__c queuedStatus: [SELECT zkfedex__StatusMessage__c, zkfedex__Shipment__c,
                        zkfedex__QueuedShipment__r.WorkOrder__c, zkfedex__Status__c
                        FROM zkfedex__QueuedShipmentStatus__c
                        WHERE zkfedex__BatchId__c =: batchId
                        LIMIT 5
                    ]) {
                    if (queuedStatus.zkfedex__Status__c == ApplicationLiterals.SHIPMATE_STATUS_ERROR) {
                        errorsList.add(queuedStatus);
                    }
                    else if (queuedStatus.zkfedex__Status__c == ApplicationLiterals.SHIPMATE_SUCCESS) {
                        successList.add(queuedStatus);
                    }
                }
                if (!errorsList.isEmpty()) {
                    String errorMessage = '';
                    for (zkfedex__QueuedShipmentStatus__c err: errorsList) {
                        errorMessage = errorMessage + err.zkfedex__StatusMessage__c;
                    }
                    mapOfObjects.put('errorMessage', 'Validation Error: ' + errorMessage);
                    getDimension(caseRecord, shipmateSet, mapOfObjects);
                    isSuccess = false;
                    mapOfObjects.put('isSuccess', isSuccess);
                }
                else if (!successList.isEmpty()) {
                    mapOfObjects.put('ShipmentRecordCreatedSuccessfully', System.Label.ShipmentRecordCreatedSuccessfully);
                }
                else {
                    getDimension(caseRecord, shipmateSet, mapOfObjects);
                    isSuccess = false;
                    mapOfObjects.put('isSuccess', isSuccess);
                    mapOfObjects.put('errorMessageContactAdmin', 'Unknown Error : Please contact System Adminstrator');
                    Error_Log__c error = ErrorLog.logErrorActivity('processFedExBulkShipment',
                        'No queued Shipment Status record found',
                        'CreateReturnLabelCtrl -processBulkShipment', true,
                        ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);

                }
            }
            else if (shipmateSet.ShipmateApp__c == ApplicationLiterals.MULTI_CARRIER_NAME) {
                system.debug('i am in multicarrier');
                String batchId = ShipmateUtility.processMCBulkShipment(bulkShipmentId, false);
                system.debug('batchId*****'+batchId);
                /*List<zkmulti__MCQueued_Shipment_Status__c> successList = new List<zkmulti__MCQueued_Shipment_Status__c>();
                   List<zkmulti__MCQueued_Shipment_Status__c> errorsList =  new List<zkmulti__MCQueued_Shipment_Status__c>();
                  for(zkmulti__MCQueued_Shipment_Status__c queuedStatus : [SELECT zkmulti__Status_Message__c,zkmulti__Queued_Shipment__r.WorkOrder__c,
                                                  zkmulti__Shipment__c,zkmulti__Status__c
                                                      FROM zkmulti__MCQueued_Shipment_Status__c
                                                      WHERE zkmulti__BatchId__c = :batchId  
                                                    LIMIT 5]){*/
                /*List<zkmulti__MCBulk_Shipment_Status__c> successList = new List<zkmulti__MCBulk_Shipment_Status__c>();
                       List<zkmulti__MCBulk_Shipment_Status__c> errorsList =  new List<zkmulti__MCBulk_Shipment_Status__c>();
                       List<zkmulti__MCBulk_Shipment_Status__c> bulkShipmentStatusList = [SELECT zkmulti__Status_Message__c, zkmulti__Status__c, zkmulti__Bulk_Shipment__c
                                            FROM zkmulti__MCBulk_Shipment_Status__c
                                            WHERE zkmulti__BatchId__c = :batchId LIMIT 5];*/
                List < zkmulti__Shipment_Status__c > successList = new List < zkmulti__Shipment_Status__c > ();
                List < zkmulti__Shipment_Status__c > errorsList = new List < zkmulti__Shipment_Status__c > ();
                
                List < zkmulti__Shipment_Status__c > bulkShipmentStatusList = [SELECT zkmulti__Status_Message__c, zkmulti__Status__c, zkmulti__Bulk_Shipment__c
                    FROM zkmulti__Shipment_Status__c
                    WHERE zkmulti__Batch_Id__c =: batchId LIMIT 5
                ];
                system.debug('bulkShipmentStatusList*****'+bulkShipmentStatusList);
                for (zkmulti__Shipment_Status__c queuedStatus: bulkShipmentStatusList) {
                    if (queuedStatus.zkmulti__Status__c == ApplicationLiterals.SHIPMATE_STATUS_ERROR) {
                        errorsList.add(queuedStatus);
                    }
                    else if (queuedStatus.zkmulti__Status__c == ApplicationLiterals.SHIPMATE_SUCCESS) {
                        successList.add(queuedStatus);
                    }
                }
                system.debug('errorsList*****'+errorsList);
                system.debug('successList*****'+successList);
                
                if (!errorsList.isEmpty()) {
                    String errorMessage = '';
                    for (zkmulti__Shipment_Status__c err: errorsList) {
                        errorMessage = errorMessage + err.zkmulti__Status_Message__c;
                    }
                    mapOfObjects.put('errorMessage', 'Validation Error: ' + errorMessage);
                    isSuccess = false;
                    mapOfObjects.put('isSuccess', isSuccess);
                    getDimension(caseRecord, shipmateSet, mapOfObjects);
                }else if (!successList.isEmpty()) {
                    mapOfObjects.put('ShipmentRecordCreatedSuccessfully', System.Label.ShipmentRecordCreatedSuccessfully);
                }else {
                    getDimension(caseRecord, shipmateSet, mapOfObjects);
                    isSuccess = false;
                    mapOfObjects.put('isSuccess', isSuccess);
                    mapOfObjects.put('errorMessageContactAdmin', 'Unknown Error : Please contact System Adminstrator');
                    Error_Log__c error = ErrorLog.logErrorActivity('processMultiCarrierShipment',
                        'No Shipment Status record found',
                        'CreateReturnLabelCtrl -processBulkShipment', true,
                        ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);
                }
            }
       }
        catch (Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateOutboundShipmate ', true,
                ApplicationLiterals.RMA_SHIPPING_ERROR, workingObjectId, caseRecordId, null);
            throw new AuraHandledException(ex.getMessage());
        } 
        return mapOfObjects;
    }
}