/*
 * Functionality :
 * Trigger handler to check the QcAler raised for product based on batch code,complaint code and region
 * Revision History: 
 *
 * Version       Author            Date            Description 
 *  1.0        Payal Yadav      08/10/2016        Initial Draft 
 */
public without sharing class CaseTriggerHandler {

    public static boolean beforeTriggerRun = true;
    public static boolean afterTriggerRun = true;
    public static Boolean runCaseTrigger = true;
    public static boolean runOnceBeforeTrigger() {
        if (beforeTriggerRun) {
            beforeTriggerRun = false;
            return true;
        }
        else {
            return beforeTriggerRun;
        }
    }

    public static boolean runOnceAfterTrigger() {
        if (afterTriggerRun) {
            afterTriggerRun = false;
            return true;
        }
        else {
            return afterTriggerRun;
        }
    }

    public static void QCAlertFieldUpdate(List <Case> triggerNewcaseList, map < Id, Case > triggerOldMap, Boolean isInsert) {
        Set < Id > caseProductIdSet = new Set < Id > ();
        Set <String> caseBatchCodeIdSet = new Set <String> ();
        Set <String> caseComplaintCodeIdSet = new Set <String> ();
        set <String> caseRegioncurrency = new Set <String> ();
        List <Case> caseList = new list <Case> ();
        Map < Id, list < QCLocation__c >> qcLocationsByProduct = new Map < Id, list < QCLocation__c >> ();
        Map < Id, QCAlert__c > batchCodeIdToQCAlertMap = new Map < Id, QCAlert__c > ();
        Map < Id, list < QCAlert__c >> complaintCodeIdToQCAlertMap = new Map < Id, list < QCAlert__c >> ();


        for (Case caseRecord: triggerNewcaseList) {

            if (isInsert || caseRecord.Product__c != triggerOldMap.get(caseRecord.Id).Product__c ||
                caseRecord.Batch_Code__c != triggerOldMap.get(caseRecord.Id).Batch_Code__c ||
                caseRecord.Complaint_Code__c != triggerOldMap.get(caseRecord.Id).Complaint_Code__c) {

                caseRecord.QC_Alert__c = null;
                caseList.add(caseRecord);
                if (caseRecord.Product__c != null) {
                    caseProductIdSet.add(caseRecord.Product__c);
                }
                //added BatchCode  into caseBatchCodeIdSet
                if (caseRecord.Batch_Code__c != null) {
                    caseBatchCodeIdSet.add(caseRecord.Batch_Code__c);
                }
                if (caseRecord.Complaint_Code__c != null) {
                    caseComplaintCodeIdSet.add(caseRecord.Complaint_Code__c);
                }
                if (caseRecord.currencyIsoCode != null) {
                    caseRegioncurrency.add(Utility.regionBased(caseRecord.CurrencyIsoCode));
                }
            }
        }

        String complaintCodeIDforMultiselect = '';
        if (caseComplaintCodeIdSet.size() > 0) {

            for (String compaintCode: caseComplaintCodeIdSet) {
                complaintCodeIDforMultiselect += '\'' + compaintCode + '\',';
            }
            complaintCodeIDforMultiselect = complaintCodeIDforMultiselect.substring(0, complaintCodeIDforMultiselect.length() - 1);
            system.debug('complaintCodeIDforMultiselect + +'+ complaintCodeIDforMultiselect);
        }
        String query = 'SELECT Id, Product__c,QCAlert__c,Batch_Code_From__c,Batch_Code_To__c,QCAlert__r.Complaint_Code__c,Region__c,StartDate__c FROM QCLocation__c' +
            ' WHERE IsActive__c = true' +
            ' AND Product__c IN: caseProductIdSet' +
            ' AND Region__c IN: caseRegioncurrency' +
            ' AND QCAlert__r.Channel__c includes (\'Call Center\')' +
            ' AND StartDate__c <= TODAY ';

        if (complaintCodeIDforMultiselect != null && complaintCodeIDforMultiselect.trim().length() > 0) {
            query += ' AND ( QCAlert__r.Complaint_Code__c includes(' + complaintCodeIDforMultiselect + ') OR Batch_Code_From__c != null )';
        }
        else {
            query += ' AND Batch_Code_From__c != null ';
        }
        system.debug('query + +'+ query);
        //get all QC Locations where IsActive is true,Product, complaint and batch code is present in Case product Id set
        if (caseProductIdSet != null && caseProductIdSet.size() > 0) {
            for (QCLocation__c qcLocationRecord: Database.query(query)) {

                if (!qcLocationsByProduct.containsKey(qcLocationRecord.Product__c)) {
                    qcLocationsByProduct.put(qcLocationRecord.Product__c, new list < QCLocation__c > ());
                }
                qcLocationsByProduct.get(qcLocationRecord.Product__c).add(qcLocationRecord);
            }
            if (qcLocationsByProduct != null && !qcLocationsByProduct.isEmpty()) {
                //updated ShowQCAlertPopup__c field of Case to true if Case product is present in activeQCLocationProductIdSet
                for (Case caseRecord: caseList) {
                    String caseRegion = Utility.regionBased(caseRecord.CurrencyIsoCode);
                    if (qcLocationsByProduct.containsKey(caseRecord.Product__c)) {
                        for (QCLocation__c qcLocationData: qcLocationsByProduct.get(caseRecord.Product__c)) {
                            Integer qcBatchCodeFromConversion = 0;
                            Integer qcBatchCodeToConversion = 0;
                            Integer caseBatchCodeConversion = 0;

                            if (qcLocationData.Batch_Code_From__c != null && qcLocationData.Batch_Code_From__c != '') {
                                qcBatchCodeFromConversion = Integer.valueof(qcLocationData.Batch_Code_From__c);
                            }
                            if (qcLocationData.Batch_Code_To__c != null && qcLocationData.Batch_Code_To__c != '') {
                                qcBatchCodeToConversion = Integer.valueof(qcLocationData.Batch_Code_To__c);
                            }
                            if (caseRecord.Batch_Code__c != null && caseRecord.Batch_Code__c != '') {
                                caseBatchCodeConversion = Integer.valueof(caseRecord.Batch_Code__c);
                            }

                            if (caseRecord.Batch_Code__c != null && qcLocationData.Region__c != null && caseRecord.Complaint_Code__c != null &&
                                qcBatchCodeFromConversion != null && qcBatchCodeToConversion != null &&
                                qcBatchCodeFromConversion <= caseBatchCodeConversion && caseBatchCodeConversion <= qcBatchCodeToConversion &&
                                qcLocationData.QCAlert__r.Complaint_Code__c.contains(caseRecord.Complaint_Code__c) &&
                                qcLocationData.Region__c == caseRegion) {
                                caseRecord.QC_Alert__c = qcLocationData.QCAlert__c;
                                  system.debug('caseRecord.QC_Alert__c + +'+ caseRecord.QC_Alert__c);  
                                break;
                            }
                            if (caseRecord.Complaint_Code__c != null && qcLocationData.QCAlert__r.Complaint_Code__c != null && qcLocationData.Batch_Code_From__c == null &&
                                qcLocationData.Batch_Code_To__c == null && qcLocationData.QCAlert__r.Complaint_Code__c.contains(caseRecord.Complaint_Code__c) && qcLocationData.Region__c == caseRegion) {

                                caseRecord.QC_Alert__c = qcLocationData.QCAlert__c;
                                     system.debug('caseRecord.QC_Alert__c + +'+ caseRecord.QC_Alert__c);  
                            }

                        }
                    }

                }
            }
        }
    }


    public static void populateContactForChatTypeCase(List <Case> caseList) {
        set < Id > accountIds = new set < Id > ();

        for (Case caseRecord: caseList) {
            if (caseRecord.Origin != null && caseRecord.Origin.equalsIgnoreCase('Chat')) {
                accountIds.add(caseRecord.AccountId);
            }
        }
        if (!accountIds.isEmpty()) {
            map < Id, Account > accountById = new map < Id, Account > ([SELECT Id, PersonContactId FROM Account where Id IN: accountIds]);
            if (accountById != null && !accountById.isEmpty()) {
                for (Case caseRecord: caseList) {
                    if (caseRecord.Origin != null && caseRecord.Origin.equalsIgnoreCase('Chat') && caseRecord.ContactId == null &&
                        accountById.containsKey(caseRecord.AccountId)) {
                        caseRecord.ContactId = accountById.get(caseRecord.AccountId).PersonContactId;
                    }
                }
            }
        }

    }

    /*Start - Warranty Validation Section*/

    //Method to validate Warranty
    public static void validateWarranty(List <Case> caseList, Map < Id, Case > triggerOldMap) {
        //List to hold the cases which are of 'Support & Service' Type and have product associated to them
        list <Case> serviceCasesWithProducts = new list <Case> ();
        list <Case> casesWhereProductRemoved = new list <Case> ();
        Set < Id > productIdSet = new Set < Id > ();
        Set < Id > accountIdSet = new Set < Id > ();
        Map < Id, list < Asset >> accountIdToAssetMap = new Map < Id, list < Asset >> ();
        Map < Id, Integer > productIdToWarrantyInMonthsMap = new Map < Id, Integer > ();
        Map < Id, Integer > productIdToExtendedWarrantyMap = new Map < Id, Integer > ();
        Set < Id > alwaysInWarrantyProductSet = new Set < Id > ();
        Set < Id > notASparePartProductID = new Set < Id > ();
        //Date todaysDate = Date.today();

        //Iterate over the cases and create account Id and Product Id set
        for (Case caseRecord: caseList) {
            Boolean isAssetAlreadyPresent = Label.FinalReturn.equalsIgnoreCase(caseRecord.Complaint_Code__c) && caseRecord.AssetId != null;
            if ((Trigger.isInsert) ||
                (Trigger.isUpdate &&
                    (caseRecord.Product__c != triggerOldMap.get(caseRecord.Id).Product__c ||
                        caseRecord.Batch_Code__c != triggerOldMap.get(caseRecord.Id).Batch_Code__c ||
                        caseRecord.Purchase_Date__c != triggerOldMap.get(caseRecord.Id).Purchase_Date__c ||
                        caseRecord.AssetId != triggerOldMap.get(caseRecord.Id).AssetId ||
                        caseRecord.Type != triggerOldMap.get(caseRecord.Id).Type))) {
                if (!isAssetAlreadyPresent) {
                caseRecord.AssetId = null;
                }
                
                if (caseRecord.Product__c != null && caseRecord.Type != null && caseRecord.Type.equalsIgnoreCase(Label.Support_Service_Case)) {
                    caseRecord.Warranty__c = 'Out of Warranty';
                    Datetime caseCreatedDateTime;
                    if (Trigger.isInsert) {
                        caseCreatedDateTime = Datetime.now();
                    } else {
                        caseCreatedDateTime = caseRecord.CreatedDate;
                    }
                    //validate the batch code or else add error to the case
                    if (isBatchCodeValid(caseRecord.Batch_Code__c, caseCreatedDateTime, caseRecord.Purchase_Date__c)) {
                        serviceCasesWithProducts.add(caseRecord);
                        productIdSet.add(caseRecord.Product__c);
                        if (caseRecord.AccountId != null) {
                            accountIdSet.add(caseRecord.AccountId);
                        }
                    }
                    else {
                        caseRecord.Batch_Code__c.addError(Label.Invalid_Batch_Code);
                    }
                }
                else if (Trigger.isUpdate && caseRecord.Product__c == null && triggerOldMap.get(caseRecord.Id).Product__c != null &&
                    caseRecord.Type != null && caseRecord.Type.equalsIgnoreCase(Label.Support_Service_Case)) {

                    caseRecord.Warranty__c = 'Out of Warranty';
                    casesWhereProductRemoved.add(caseRecord);
                }
            }
        }

        if (serviceCasesWithProducts != null && serviceCasesWithProducts.size() > 0) {

            //creating a map of product id and its current warranty period 
            for (Product2 productRecord: [SELECT Id, Warranty_In_Months__c, Spare_Part__c, Remanufactured__c, Always_in_Warranty__c, Extended_Warranty_in_months__c
                    FROM Product2
                    WHERE Id IN: productIdSet
                ]) {
                if (productRecord.Warranty_In_Months__c != null) {
                    productIdToWarrantyInMonthsMap.put(productRecord.Id, Integer.valueOf(productRecord.Warranty_In_Months__c));
                }
                if (productRecord.Extended_Warranty_in_months__c != null) {
                    productIdToExtendedWarrantyMap.put(productRecord.Id, Integer.valueOf(productRecord.Extended_Warranty_in_months__c));
                }
                if (productRecord.Always_in_Warranty__c) {
                    alwaysInWarrantyProductSet.add(productRecord.Id);
                }
                if (!productRecord.Spare_Part__c) { // && !productRecord.Remanufactured__c){
                    notASparePartProductID.add(productRecord.Id);
                }
            }

            //Query Registration record if Account set is not empty
            if (productIdSet != null && productIdSet.size() > 0 && accountIdSet != null && accountIdSet.size() > 0) {

                for (Asset assetRecord: [SELECT Id, AccountId, Product2Id, Batch_Code__c, PurchaseDate, Warranty_In_Months__c, CreatedDate
                        FROM Asset
                        WHERE AccountId IN: accountIdSet
                        AND Product2Id IN: productIdSet
                    ]) {
                    if (accountIdToAssetMap.containsKey(assetRecord.AccountId)) {
                        accountIdToAssetMap.get(assetRecord.AccountId).add(assetRecord);
                    }
                    else {
                        accountIdToAssetMap.put(assetRecord.AccountId, new list < Asset > {
                            assetRecord
                        });
                    }
                }
            }
        }

        //Iterate over the valid cases and check for their assests
        for (Case caseRecord: serviceCasesWithProducts) {

            Boolean isAssetAlreadyPresent = Label.FinalReturn.equalsIgnoreCase(caseRecord.Complaint_Code__c) && caseRecord.AssetId != null;
            //check whether product associated to case is not a spare part
            if (notASparePartProductID.contains(caseRecord.Product__c)) {

                //Check whether if product belongs to the category, where it is always in warranty irrespective of the warranty period
                if (alwaysInWarrantyProductSet.contains(caseRecord.Product__c)) {

                    //Since these products would always be in warranty, set warranty status to 'In Warranty'
                    caseRecord.Warranty__c = 'In Warranty';
                    updateWarrantyFieldStatus(caseRecord, 'True');
                }
                else {

                    Integer extendedWarranty = 0;
                    //update default value to 'N/A'
                    updateWarrantyFieldStatus(caseRecord, 'N/A');

                    Date caseCreatedDate;
                    if (caseRecord.createdDate != null) {
                        caseCreatedDate = caseRecord.createdDate.date();
                    }
                    else {
                        caseCreatedDate = Date.today();
                    }

                    if (productIdToExtendedWarrantyMap.containsKey(caseRecord.Product__c)) {
                        extendedWarranty = productIdToExtendedWarrantyMap.get(caseRecord.Product__c);
                    }

                    //If there are asset records for that account
                    if (accountIdToAssetMap.containsKey(caseRecord.AccountId)) {

                        //regiteredoroduct record to be saved on this record
                        Asset macthingRegisteredProduct;
                        Boolean assetFoundWithMatchingBatchCode = false;

                        for (Asset registeredProduct: accountIdToAssetMap.get(caseRecord.AccountId)) {
                            if (isAssetAlreadyPresent && registeredProduct.Id == caseRecord.AssetId) {
                                macthingRegisteredProduct = registeredProduct;
                                if (registeredProduct.Batch_Code__c != null && caseRecord.Batch_Code__c != null && registeredProduct.Batch_Code__c.equals(caseRecord.Batch_Code__c)) {
                                    assetFoundWithMatchingBatchCode = true;
                                }
                                break;
                            }
                            //match the product on case and on asset
                            if (registeredProduct.Product2Id != null && registeredProduct.Product2Id == caseRecord.Product__c) {
                                macthingRegisteredProduct = registeredProduct;
                                if (registeredProduct.Batch_Code__c != null && caseRecord.Batch_Code__c != null && registeredProduct.Batch_Code__c.equals(caseRecord.Batch_Code__c)) {
                                    assetFoundWithMatchingBatchCode = true;
                                    break;
                                }
                            }
                        }

                        //associate asset record to case
                        caseRecord.AssetId = macthingRegisteredProduct.Id;
                        //Check whether any asset was found or not
                        if (macthingRegisteredProduct != null && macthingRegisteredProduct.Batch_Code__c != null && macthingRegisteredProduct.Batch_Code__c != '' &&
                            macthingRegisteredProduct.Batch_Code__c.length() >= 4 && macthingRegisteredProduct.Batch_Code__c.left(4).isNumeric()) {
                            Date batchCodeDate;
                            if (caseRecord.Batch_Code__c != null) {
                                batchCodeDate = getBatchCodeDate(caseRecord.Batch_Code__c);
                            }
                            else if (macthingRegisteredProduct.Batch_Code__c != null) {
                                batchCodeDate = getBatchCodeDate(macthingRegisteredProduct.Batch_Code__c);
                            }

                            if (productIdToWarrantyInMonthsMap.containsKey(caseRecord.Product__c)) {
                                updateCaseWhenRegisteredAssetFound(macthingRegisteredProduct, caseRecord, productIdToWarrantyInMonthsMap.get(caseRecord.Product__c),
                                    batchCodeDate, extendedWarranty);
                            }
                            else {
                                updateCaseWhenRegisteredAssetFound(macthingRegisteredProduct, caseRecord, null, batchCodeDate, extendedWarranty);
                            }

                        }
                        else if (caseRecord.Purchase_Date__c != null && productIdToWarrantyInMonthsMap.containsKey(caseRecord.Product__c)) {
                            //No Asset with same product found
                            updateCaseWhenNoAssetFound(caseRecord, caseCreatedDate, productIdToWarrantyInMonthsMap.get(caseRecord.Product__c), extendedWarranty, isAssetAlreadyPresent);
                        }
                    }
                    else {
                        if (productIdToWarrantyInMonthsMap.containsKey(caseRecord.Product__c)) {
                            updateCaseWhenNoAssetFound(caseRecord, caseCreatedDate, productIdToWarrantyInMonthsMap.get(caseRecord.Product__c), extendedWarranty, isAssetAlreadyPresent);
                        }
                    }
                }
            }
        }

        //Iterate over the cases where product was removed
        if (casesWhereProductRemoved != null && casesWhereProductRemoved.size() > 0) {
            for (Case caseRecord: casesWhereProductRemoved) {
                updateWarrantyFieldStatus(caseRecord, null);
            }
        }
    }
  
    //Changes for SF-741 prevent firing case assignment rules for API only users.
    public static void preventCaseAssignmentRule(List <Case> caseList){
        Database.DMLOptions dmo = new Database.DMLOptions();
        List<User> currentUser = new List<User>();
        dmo.assignmentRuleHeader.useDefaultRule = false;
        String currentUserId=UserInfo.getUserId();
        currentUser =[select id,FirstName,LastName,Profile.Name from User where Id=:currentUserId];
        if(currentUser.size() > 0 && currentUser[0].Profile!= null && currentUser[0].Profile.Name=='Partner Integration User'){
            for(Case caseRecord:caseList){
                caseRecord.setOptions(dmo);
            }
        }
    }
    
    public static void updateCaseWhenNoAssetFound(Case caseRecord, Date caseCreatedDate, Integer warrantyPeriod, Integer extendedWarrantyPeriod, Boolean isAssetAlreadyPresent) {

        // 1. Validate warranty based on batch code
        if (caseRecord.Batch_Code__c != null) {
            caseRecord.Warranty_Based_on_Batch_Code__c =
                String.valueOf(checkInWarrantyStatus(getBatchCodeDate(caseRecord.Batch_Code__c), caseCreatedDate, warrantyPeriod)).capitalize();
        }

        //2. if warranty is not validated or not applicable based on batch code, proceed to purchase date
        if ((!caseRecord.Warranty_Based_on_Batch_Code__c.equalsIgnoreCase('True')) && caseRecord.Purchase_Date__c != null) {
            caseRecord.Warranty_Based_on_Purchase_Date__c =
                String.valueOf(checkInWarrantyStatus(caseRecord.Purchase_Date__c, caseCreatedDate, warrantyPeriod)).capitalize();
        }

        if (caseRecord.Warranty_Based_on_Batch_Code__c == 'True' || caseRecord.Warranty_Based_on_Purchase_Date__c == 'True') {
            caseRecord.Warranty__c = 'In Warranty';
        }

        if (caseRecord.Purchase_Date__c != null && warrantyPeriod != null) {
            caseRecord.Warranty_Expiration_Date__c = caseRecord.Purchase_Date__c.addMonths(warrantyPeriod);
            caseRecord.Extended_Warranty_Expiration_Date__c = caseRecord.Purchase_Date__c.addMonths(warrantyPeriod).addMonths(extendedWarrantyPeriod);
        }
        if (!isAssetAlreadyPresent) {
            caseRecord.AssetId = null;
        }
    }

    public static void updateCaseWhenNoAssetFound(Case caseRecord, Date caseCreatedDate, Integer warrantyPeriod, Integer extendedWarrantyPeriod) {

        updateCaseWhenNoAssetFound(caseRecord, caseCreatedDate, warrantyPeriod, extendedWarrantyPeriod, false);
    }

    public static Case updateCaseWhenRegisteredAssetFound(Asset registeredProduct, Case caseRecord, Integer currentWarrantyPeriodOnProduct, Date batchCodeDate,
        Integer extendedWarrantyPeriod) {

        Integer warrantyPeriod;
        Date caseCreatedDate;
        if (caseRecord.createdDate != null) {
            caseCreatedDate = caseRecord.createdDate.date();
        }
        else {
            caseCreatedDate = Date.today();
        }

        //check warranty period on Asset, if not present, use the one present at Product
        if (registeredProduct.Warranty_In_Months__c != null) {

            //fetching warranty period from asset record 
            warrantyPeriod = Integer.valueOf(registeredProduct.Warranty_In_Months__c);
        }
        else if (currentWarrantyPeriodOnProduct != null) {

            //fetching warranty period from product record
            warrantyPeriod = currentWarrantyPeriodOnProduct;
        }

        if (warrantyPeriod != null) {

            Date purchaseDate = registeredProduct.PurchaseDate;

            // 1. Validate warranty based on batch code
            if (batchCodeDate != null) {
                caseRecord.Warranty_Based_on_Batch_Code__c = String.valueOf(checkInWarrantyStatus(batchCodeDate, caseCreatedDate, warrantyPeriod)).capitalize();
                if (caseRecord.Warranty_Based_on_Batch_Code__c != null && caseRecord.Warranty_Based_on_Batch_Code__c == 'True') {
                    caseRecord.Warranty__c = 'In Warranty';
                }
            }
            // 2. if warranty is not validated or not applicable based on batch code, proceed to registration date
            if (!caseRecord.Warranty_Based_on_Batch_Code__c.equalsIgnoreCase('True')) {
                if (registeredProduct.PurchaseDate != null) {
                    caseRecord.Warranty_Based_on_Registration_Date__c =
                        String.valueOf(checkInWarrantyStatus(registeredProduct.PurchaseDate, caseCreatedDate, warrantyPeriod)).capitalize();
                }
                // 3. If warranty is not validated or not applicable based on registration date, proceed to purchase date
                if (caseRecord.Purchase_Date__c != null) {
                    caseRecord.Warranty_Based_on_Purchase_Date__c =
                        String.valueOf(checkInWarrantyStatus(caseRecord.Purchase_Date__c, caseCreatedDate, warrantyPeriod)).capitalize();
                }
            }

            if (caseRecord.Warranty_Based_on_Batch_Code__c == 'True' || caseRecord.Warranty_Based_on_Registration_Date__c == 'True' ||
                caseRecord.Warranty_Based_on_Purchase_Date__c == 'True') {
                caseRecord.Warranty__c = 'In Warranty';
            }

            if (caseRecord.Purchase_Date__c != null && caseRecord.Purchase_Date__c > registeredProduct.PurchaseDate) {
                purchaseDate = caseRecord.Purchase_Date__c;
            }

            if (purchaseDate != null && warrantyPeriod != null) {
                caseRecord.Warranty_Expiration_Date__c = purchaseDate.addMonths(warrantyPeriod);
                if (extendedWarrantyPeriod != null) {
                    caseRecord.Extended_Warranty_Expiration_Date__c = purchaseDate.addMonths(warrantyPeriod).addMonths(extendedWarrantyPeriod);
                }
                else {
                    caseRecord.Extended_Warranty_Expiration_Date__c = caseRecord.Warranty_Expiration_Date__c;
                }
            }
        }
        return caseRecord;
    }

    /*This method will convert the batch code passed in parameter to date*/
    public static date getBatchCodeDate(String batchCodeStr) {
        Date batchCodeDate;

        Date yearStartDate;
        //
        System.debug(batchCodestr);
        //
        String batchCode = batchCodeStr.left(4);

        String lastTwoDigitOfYear = batchCode.left(2);
        String yearValue = '20' + lastTwoDigitOfYear;

        Integer year = Integer.valueOf(yearValue);
        Integer week = Integer.valueOf(batchCode.right(2));

        yearStartDate = date.newinstance(year, 1, 1);
        batchCodeDate = (yearStartDate.addDays(week * 7)).addDays(-1);

        return batchCodeDate;
    }

    /*This method will validate the batch code, whether it is valid or not*/
    public static boolean isBatchCodeValid(String batchCode, Datetime recordCreatedDate, Date purchaseDate) {
        //check if batch code is null or not
        if (batchCode != null) {
            //fetch first 4 digit of batch code
            String batchCodeFirst4Digit = batchCode.left(4);
            //check first 4 digit is numeric or not
            if (batchCodeFirst4Digit.isNumeric()) {
                //last two digit should be greater than 0 and less than  53
                if (Integer.valueOF(batchCodeFirst4Digit.right(2)) > 0 && Integer.valueOf(batchCodeFirst4Digit.right(2)) <= 52) {
                    Date batchCodeDate = getBatchCodeDate(batchCodeFirst4Digit);
                    //Compare batch code date to created Date
                    if (batchCodeDate > recordCreatedDate.date()) {
                        return false;
                    }
                    else {
                        if (purchaseDate != null && purchaseDate < batchCodeDate) {
                            return false;
                        }
                        return true;
                    }
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
        }
        return true;
    }

    //This method will return true if product is in warranty, else will return false for out of warranty date
    //ComapreToDate can be batchdate/Registration Date/Purchase Date 
    public static boolean checkInWarrantyStatus(Date compareToDate, Date caseCreatedDate, Integer warrantyPeriodInMonth) {

        Date warrantyEndDate = compareToDate.addMonths(warrantyPeriodInMonth);

        if (warrantyEndDate >= caseCreatedDate) {
            return true;
        }
        else {
            return false;
        }
    }

    public static void updateWarrantyFieldStatus(Case caseRecord, String status) {
        caseRecord.Warranty_Based_on_Batch_Code__c = status;
        caseRecord.Warranty_Based_on_Registration_Date__c = status;
        caseRecord.Warranty_Based_on_Purchase_Date__c = status;
    }

    /*End - Warranty Validation Section*/

    /*Start - Migrated from CaseInsertUpdateHandler */
    //Method to get and update the Currency field on Case
    public static void getCaseCurrencyCode(List <Case> lstCase) {
        for (Case objCase: lstCase) {
            if (objCase.Origin == 'Email CAN' || objCase.Origin == 'Email CAN Lid Gasket') {
                objCase.CurrencyIsoCode = 'CAD';
            }
        } // end of for loop
    }

    /*This method will update the case record if warranty status is changed from 'out of warranty' to 'In Warranty'
public static void updateCaseIfWarrantyStatusChanged(List<Case> caseList, Map<Id,Case> triggerOldMap){
for(Case caseRec : caseList){
if(caseRec.Warranty__c != null && caseRec.Warranty__c != '' && caseRec.Warranty__c.equalsIgnoreCase('In Warranty') && 
triggerOldMap.get(caseRec.Id).Warranty__c != null && triggerOldMap.get(caseRec.Id).Warranty__c != '' && 
triggerOldMap.get(caseRec.Id).Warranty__c.equalsIgnoreCase('Out of Warranty')){
caseRec.WarrantyOutofWarrantyToInWarranty__c = true;
}
if(caseRec.WarrantyOutofWarrantyToInWarranty__c && caseRec.Warranty__c != null && caseRec.Warranty__c != '' && caseRec.Warranty__c.equalsIgnoreCase('In Warranty')){
caseRec.WarrantyOutofWarrantyToInWarranty__c = true;
}else{
caseRec.WarrantyOutofWarrantyToInWarranty__c = false;
}
}
}
*/

    public static void checkForAdvanceShippingRAReturned(List <Case> caseList, Map < Id, Case > triggerOldMap) {

        try {
            set < Id > caseIdsForRADelivered = new set < Id > ();
            list < Order > advanceShippingOrders = new list < Order > ();
            map < Id, String > caseIdToCaseTrackingNumber = new Map < Id, String > ();
            for (Case caseRec: caseList) {
                if ((caseRec.RA_Delivered__c && !triggerOldMap.get(caseRec.Id).RA_Delivered__c) ||
                    (caseRec.RA_Tracking_Status__c != null && caseRec.RA_Tracking_Status__c != triggerOldMap.get(caseRec.Id).RA_Tracking_Status__c &&
                        String.valueOf(caseRec.RA_Tracking_Status__c).containsIgnoreCase('in transit'))) {
                    caseIdsForRADelivered.add(caseRec.Id);
                    caseIdToCaseTrackingNumber.put(caseRec.Id, caseRec.RA_Tracking__c);
                }
            }
            if (!caseIdsForRADelivered.isEmpty()) {

                for (Order orderRec: [SELECT Id, AdvanceShippingStatus__c, CC_Authorization_ID__c, Type, Case_RA_Tracking__c, Case__c FROM Order
                        WHERE Case__c IN: caseIdsForRADelivered
                    ]) {

                    orderRec.Return_Product_Received__c = true;
                    if (caseIdToCaseTrackingNumber.containsKey(orderRec.Case__c)) {
                        orderRec.Case_RA_Tracking__c = caseIdToCaseTrackingNumber.get(orderRec.Case__c);
                    }
                    if (orderRec.Type == 'Accommodation' && orderRec.CC_Authorization_ID__c != null && orderRec.AdvanceShippingStatus__c != 'Received-Voided') {

                        orderRec.AdvanceShippingStatus__c = 'Received-Voided';
                    }

                    advanceShippingOrders.add(orderRec);


                }
            }
            Database.SaveResult[] results = Database.update(advanceShippingOrders, false);
            list < Error_Log__c > errorLogs = new list < Error_Log__c > ();
            for (Integer i = 0; i < advanceShippingOrders.size(); i++) {
                if (!results[i].isSuccess()) {

                    String msg = '';

                    msg += results[i].errors[0].getMessage();

                    Error_Log__c error = ErrorLog.logErrorActivity('Error while udating order status to auto void',
                        msg,
                        'CaseTriggerHanlder-checkForAdvanceShippingRAReturned', false, 'Tracking Error',
                        String.valueOf(advanceShippingOrders[i].get('Id')), String.valueOf(advanceShippingOrders[i].get('Id')), null);
                    errorLogs.add(error);
                }
            }
            insert errorLogs;
        }
        catch (Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'Error loading Payment tracking data -CaseTriggerHandler', true, 'Advance Shipping Auto Void on Receive');
        }

    }
    /*
public static void checkForRMAApproval(List<Case> caseList, Map<Id,Case> triggerOldMap){

map<String,Decimal> parcelsLimitByCurrencyCode = new map<String,Decimal>();

for(Region_Specific__mdt region : [SELECT RMA_Quantity__c,Currency__c FROM Region_Specific__mdt]){
parcelsLimitByCurrencyCode.put(region.Currency__c,region.RMA_Quantity__c);
}

for(Case caseRec : caseList){

if(caseRec.RMAStatus__c == 'RMA Approved' && caseRec.RMAStatus__c != triggerOldMap.get(caseRec.Id).RMAStatus__c){

if((caseRec.Return_Shipment_Type__c == 'Single Parcel' 
|| caseRec.Return_Shipment_Type__c== 'Multiple Parcels') &&  parcelsLimitByCurrencyCode.containsKey(caseRec.CurrencyIsoCode)
&& caseRec.Total_Quantity_RMA_Products__c <= parcelsLimitByCurrencyCode.get(caseRec.CurrencyIsoCode
) && caseRec.CreateReturnLabel__c){

caseRec.RMAStatus__c = 'Scheduled For Label Generation'; 

}else{
caseRec.RMAStatus__c = 'RMA Team Notified'; 
}
}
}


}*/
    /*End - Migrated from CaseInsertUpdateHandler */

    /* ----------------------Start-----------------------------------
sharing method for Case Sharing */

    public static void shareRMAWithServiceCentre(list <Case> newcaseRecords, map < Id, Case > oldmap, Boolean isInsert) {

        list <Case> casesneedtoShare = new list <Case> ();
        List < Id > shareIdsToDelete = new List < Id > ();
        set < Id > serviceCentreAccountIds = new set < Id > ();
        ID caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        List < CaseShare > sharesToCreate = new List < CaseShare > ();

        for (Case caseRecords: newcaseRecords) {
            if (caseRecords.RecordTypeID == caseRecordTypeId) {

                if (isInsert && caseRecords.AccountId != NULL) {
                    casesneedtoShare.add(caseRecords);
                    serviceCentreAccountIds.add(caseRecords.AccountId);

                }
                else if (oldmap != null && ((oldmap.get(caseRecords.id).AccountId != caseRecords.AccountId) || (oldmap.get(caseRecords.id).OwnerId != caseRecords.OwnerId))) {

                    //add to delete list to delete share records
                    shareIdsToDelete.add(caseRecords.id);
                    if (caseRecords.AccountId != NULL) {
                        casesneedtoShare.add(caseRecords);
                        serviceCentreAccountIds.add(caseRecords.AccountId);
                    }
                }
            }

            if (!casesneedtoShare.isEmpty()) {

                map < Id, Set < Id >> partnerUserIdByAccountId = Utility.getPartnerUserIdByAccountId(serviceCentreAccountIds);

                for (Case caseRecordsofsharing: casesneedtoShare) {
                    if (partnerUserIdByAccountId.containsKey(caseRecordsofsharing.AccountId)) {
                        for (Id userId: partnerUserIdByAccountId.get(caseRecordsofsharing.AccountId)) {
                            sharesToCreate.add(createCaseShare(caseRecordsofsharing.Id, userId));
                        }
                    }
                }

            }
        }
        if (!shareIdsToDelete.isEmpty()) {
            delete[SELECT Id FROM CaseShare WHERE CaseId IN: shareIdsToDelete AND RowCause = 'Manual'];
        }
        if (!sharesToCreate.isEmpty()) {
            Database.insert(sharesToCreate, false);
        }
    }

    public static void populateOldRMAForLegacyRecords(list <Case> newcaseRecords) {

        set <String> caseNumbers = new set <String> ();
        map < String, Case > caseByCaseNumbers = new map < String, Case > ();
        for (Case newcaseRecord: newcaseRecords) {
            if (newcaseRecord.OldRMACaseNumber__c != null && newcaseRecord.OldRMACaseNumber__c != '') {
                caseNumbers.add(newcaseRecord.OldRMACaseNumber__c);
            }
        }
        if (caseNumbers.size() > 0) {

            for (Case caseRec: [select Id, CaseNumber, RTV__C from Case where CaseNumber IN: CaseNumbers]) {

                caseByCaseNumbers.put(caseRec.CaseNumber, caseRec);
            }

            for (Case newcaseRecord: newcaseRecords) {
                if (caseByCaseNumbers.containsKey(newcaseRecord.OldRMACaseNumber__c)) {

                    newcaseRecord.New_Old_RMA_Case__c = caseByCaseNumbers.get(newcaseRecord.OldRMACaseNumber__c).id;
                    //newcaseRecord.RTV__C = caseByCaseNumbers.get(newcaseRecord.OldRMACaseNumber__c).RTV__C;


                }
            }

        }



    }
    public static void populateNewRMAForLegacyRecords(list <Case> newcaseRecords) {

        map < Id, Case > casesNeedtoBeUpdated = new map < Id, Case > ();

        for (Case newcaseRecord: newcaseRecords) {

            if (!casesNeedtoBeUpdated.containsKey(newcaseRecord.New_Old_RMA_Case__c)) {

                casesNeedtoBeUpdated.put(newcaseRecord.New_Old_RMA_Case__c,
                    new Case(Id = newcaseRecord.New_Old_RMA_Case__c,
                        New_Old_RMA_Case__c = newcaseRecord.id
                    )
                );

            }
        }

        Database.update(casesNeedtoBeUpdated.values(), false);

    }

    /** Method name : createCaseShare
     * Arguments : Id caseId - Record id of the case record which needs to be shared
     * Id userOrGroupId - Record id of user or public group with which the case record needs to be shared
     * String caseAccessLevel - Record sharing access level - Read, Edit, All
     * Return type : CaseShare
     * Description : Creates Case share record as per the parameters passed to the method
     **/
    public static CaseShare createCaseShare(Id caseId, Id userOrGroupId) {
        CaseShare share = new CaseShare();
        share.CaseId = caseId;
        share.UserOrGroupId = userOrGroupId;
        share.CaseAccessLevel = 'Edit';
        share.RowCause = 'Manual';
        return share;
    }

    public static void updaterepeatRepairFailure(list <Case> caseList, map < Id, Case > triggerOldMap) {
        set < Id > repeatRprRecords = new set < Id > ();
        for (Case caseRec: caseList) {
            if (caseRec.RepeatRepairFailure__c && !triggerOldMap.get(caseRec.Id).RepeatRepairFailure__c) {
                repeatRprRecords.add(caseRec.Id);
            }
        }

        if (!repeatRprRecords.isEmpty()) {
            list < WorkOrder > workOrderList = [select id, Status, IsChargeBack__c, RecordType.Name, SendtoPartners__c from WorkOrder
                where CaseId IN: repeatRprRecords
                and RecordType.Name = 'Work Order'
            ];
            list < WorkOrder > claimList = [select id, Status, IsChargeBack__c, RecordType.Name, SendtoPartners__c from WorkOrder
                where WorkOrder__c IN: workOrderList
                and RecordType.Name = 'Claim'
            ];
            workOrderList.addAll(claimList);
            if (workOrderList != null && workOrderList.size() > 0) {

                for (WorkOrder workorderRec: workOrderList) {

                    if (workorderRec.RecordType.Name == 'Work Order') {
                        workorderRec.Status = 'Repeat Workorder';
                        workorderRec.SendtoPartners__c = null;
                    }
                    else if (workorderRec.RecordType.Name == 'Claim') {
                        workorderRec.IsChargeBack__c = true;
                    }
                }
                update workOrderList;
            }
        }
    }

    /* to populate last status change date on case*/
    public static void populateLastStatusChageDate(list <Case> caseList, map < Id, Case > triggerOldMap) {

        Integer daysForFirstNotification = ApplicationLiterals.CASEAUTOCLOSEDISPOSITION_DaysForFirstNotification;
        if (caseList != null && caseList.size() > 0) {
            /*Changes for W-000279
- Auto-Close email should be triggered if Status is 'Waiting on consumer' OR 'Waiting on return'
*/
            for (Case caseRecord: caseList) {
                if (caseRecord.Status == 'Waiting on consumer' || caseRecord.Status == 'Waiting on return') {
                    if ((triggerOldMap != null && triggerOldMap.get(caseRecord.Id).Status != caseRecord.Status) || triggerOldMap == null) {
                        caseRecord.CaseAutoCloseCheckDate__c = Date.today().addDays(daysForFirstNotification);
                    }
                }
                else if (caseRecord.Status != 'Waiting on consumer' && caseRecord.Status != 'Waiting on return' && caseRecord.Status != 'Soft Closed') {
                    caseRecord.CaseAutoCloseCheckDate__c = null;
                }
                //Added by tapan to copy case reason to closed reason
                if (caseRecord.Reason != null && triggerOldMap.get(caseRecord.Id).Reason != caseRecord.Reason) {
                    caseRecord.Closed_Reason__c = caseRecord.Reason;
                }
            }
        }
    }

    public static void populateSubjectOnChatCases(list <Case> caseList) {
        for (Case caseRecord: caseList) {
            if (caseRecord.Origin != null && caseRecord.Origin == 'Chat' && caseRecord.Subject == null && caseRecord.Description != null && caseRecord.Description != '') {
                if (caseRecord.Description.length() > 30) {
                    caseRecord.Subject = 'Chat - ' + caseRecord.Description.subString(0, 31);
                }
                else {
                    caseRecord.Subject = 'Chat - ' + caseRecord.Description;
                }
            }
        }
    }

    public static void populateCountOnQCLocation(list <Case> caseList, Map < Id, Case > oldMap) {
        set < Id > returnLocationIds = new set < Id > ();
        set < Id > productIds = new set < Id > ();
        list <Case> consideredCases = new list <Case> ();
        map < Id, list < QCLocation__c >> returnLocationToQCLocationsMap = new map < Id, list < QCLocation__c >> ();
        map < Id, list < QCLocation__c >> qcAlertToQCLocationsMap = new map < Id, list < QCLocation__c >> ();
        list < QCAlert__c > qcAlertsToUpdate = new list < QCAlert__c > ();
        list < QCLocation__c > qcLocationsToUpdate = new list < QCLocation__c > ();

        for (Case record: caseList) {
            if (record.RA_Delivered__c && !oldMap.get(record.Id).RA_Delivered__c && record.ReturnLocation__c != null) {
                returnLocationIds.add(record.ReturnLocation__c);
                productIds.add(record.Product__c);
                consideredCases.add(record);
                System.debug('consideredCases ::::: '+ consideredCases);
            }
            System.debug('consideredCases ::::: '+ consideredCases);
        }

        for (QCLocation__c record: [SELECT Id, ReturnLocation__c, QCAlert__c, Count__c, Quantity__c, QCAlert__r.Status__c, QCAlert__r.Complaint_Code__c, Product__c,
                Batch_Code_From__c, Batch_Code_To__c FROM QCLocation__c
                WHERE ReturnLocation__c IN: returnLocationIds AND Product__c IN: productIds
            ]) {
            if (returnLocationToQCLocationsMap.containsKey(record.ReturnLocation__c)) {
                returnLocationToQCLocationsMap.get(record.ReturnLocation__c).add(record);
            }
            else {
                returnLocationToQCLocationsMap.put(record.ReturnLocation__c, new list < QCLocation__c > {
                    record
                });
            }
            qcAlertToQCLocationsMap.put(record.QCAlert__c, new list < QCLocation__c > ());
            System.debug('qcAlertToQCLocationsMap ::::: '+ qcAlertToQCLocationsMap);
        }

        for (Case record: consideredCases) {
            if (returnLocationToQCLocationsMap != null && returnLocationToQCLocationsMap.containsKey(record.ReturnLocation__c)) {
                for (QCLocation__c qcl: returnLocationToQCLocationsMap.get(record.ReturnLocation__c)) {
                    list <string> complainsCodes = qcl.QCAlert__r.Complaint_Code__c.split('\\;');
                    Integer qcBatchCodeFromConversion = 0;
                    Integer qcBatchCodeToConversion = 0;
                    Integer caseBatchCodeConversion = 0;

                    if (qcl.Batch_Code_From__c != null && qcl.Batch_Code_From__c != '') {
                        qcBatchCodeFromConversion = Integer.valueof(qcl.Batch_Code_From__c);
                    }
                    System.debug('qcBatchCodeFromConversion ::::: '+ qcBatchCodeFromConversion);
                    if (qcl.Batch_Code_To__c != null && qcl.Batch_Code_To__c != '') {
                        qcBatchCodeToConversion = Integer.valueof(qcl.Batch_Code_To__c);
                    }
                    System.debug('qcBatchCodeToConversion ::::: '+ qcBatchCodeToConversion);
                    if (record.Batch_Code__c != null && record.Batch_Code__c != '') {
                        caseBatchCodeConversion = Integer.valueof(record.Batch_Code__c);
                    }
                    System.debug('caseBatchCodeConversion ::::: '+ caseBatchCodeConversion);
                    if (record.Product__c == qcl.Product__c && record.ReturnLocation__c == qcl.ReturnLocation__c && complainsCodes.contains(record.Complaint_Code__c)) {
                        if ((caseBatchCodeConversion != 0 && qcBatchCodeFromConversion != 0 && qcBatchCodeToConversion != 0 && qcBatchCodeFromConversion <= caseBatchCodeConversion &&
                                caseBatchCodeConversion <= qcBatchCodeToConversion) || (qcBatchCodeFromConversion == 0 && qcBatchCodeToConversion == 0)) {
                            if (qcl.Count__c != null) {
                                qcl.Count__c += 1;
                            }
                            else {
                                qcl.Count__c = 1;
                            }
                        }
                    }
                }
                qcLocationsToUpdate.addAll(returnLocationToQCLocationsMap.get(record.ReturnLocation__c));
            }
        }

        try {
            Database.update(qcLocationsToUpdate);
            for (QCLocation__c record: [SELECT Id, ReturnLocation__c, QCAlert__c, Count__c, Quantity__c, QCAlert__r.Status__c FROM QCLocation__c WHERE QCAlert__c IN: qcAlertToQCLocationsMap.keySet()]) {
                qcAlertToQCLocationsMap.get(record.QCAlert__c).add(record);
            }
            for (Id qcAlertId: qcAlertToQCLocationsMap.keySet()) {
                Integer qcCount = 0;
                for (QCLocation__c record: qcAlertToQCLocationsMap.get(qcAlertId)) {
                    Decimal recordCount = record.Count__c != null ? record.Count__c : 0;
                    if (recordCount >= record.Quantity__c) {
                        qcCount++;
                    }
                }
                String qcStatus = qcAlertToQCLocationsMap.get(qcAlertId)[0].QCAlert__r.Status__c;
                if (qcCount == qcAlertToQCLocationsMap.get(qcAlertId).size()) {
                    if (qcStatus == 'Open') {
                        qcAlertsToUpdate.add(new QCALert__c(Id = qcAlertId, Status__c = 'Closed'));
                    }
                }
            }
            Database.update(qcAlertsToUpdate);
        }
        catch (Exception ex) {
            ErrorLog.LogErrorActivity(ex, 'Error from  populateCountOnQCLocation-CaseTriggerHandler', true, 'unable to update QCAlert/QCLocations: ' + ex.getMessage());
        }
    }

    public static void setReceivingCompleteOnDIF(list <Case> caseList, Map<Id, Case> oldCases) {
        for (Case caseRecord: caseList) {
            Case oldRecord = oldCases.get(caseRecord.Id);
            if (Utility.isD365Enabled(caseRecord) 
                && caseRecord.RMA_Type__c == 'Destroy in Field'
                && caseRecord.RMAStatus__c == 'RMA Approved'
                && caseRecord.RMAStatus__c != oldRecord.RMAStatus__c) {
                caseRecord.ReceivingComplete__c = true;
                caseRecord.Receiving_Completed_Date__c = Date.today();
            } 
        }
    }

    // Functionality: Create Receiving for DIF flow
    public static void createReceiving(List <Case> caseList, Map<Id,Case> oldCases) {
        List < Receiving__c > receivingList = new List < Receiving__c > ();

        Set<Id> filteredCases = new Set<Id>();
        for (Case caseObj : caseList) {
            Case oldCase = oldCases.get(caseObj.Id);
            if (caseObj.RMAStatus__c == 'RMA Approved' &&
                caseObj.RMA_type__c == 'Destroy in Field' && 
                oldCase.RMAStatus__c != caseObj.RMAStatus__c) {
                filteredCases.add(caseObj.Id);
            }
        }

        if (filteredCases.size() > 0) {
            List <RMA_Product__c> productList = [SELECT Id, Name, Case__c, Product__c, Quantity__c, Price__c, Case__r.Account_Name__c,Case__r.Account_Number__c, Case__r.RTV__c, CurrencyIsoCode FROM RMA_Product__c
                WHERE Case__c IN: filteredCases ];

            for (RMA_Product__c product: productList) {
                Integer prodQty = (Integer) product.Quantity__c;
                for (Integer i = 0; i < prodQty; i++) {

                    Receiving__c receiving = new Receiving__c();
                    receiving.Case__c = product.Case__c;
                    receiving.Cust_Name__c = product.Case__r.Account_Name__c;
                    receiving.Cust_Acct_ID__c = product.Case__r.Account_Number__c;
                    receiving.Received_Product__c = product.Product__c;
                    receiving.RTV__c = product.Case__r.RTV__c;
                    receiving.RMAProduct__c = product.Id;
                    receiving.CurrencyIsoCode = product.CurrencyIsoCode;
                    receiving.Received_Date__c = Date.today();
                    receiving.Warranty__c = 'In Warranty';
                    receiving.RMACalculatedUnitPrice__c = product.Price__c;
                    receiving.IsPriceCalculated__c = true;

                    receivingList.add(receiving);
                }
            }


            if (receivingList.size() > 0) {
                try {
                    Database.insert(receivingList);
                }
                catch (Exception ex) {
                    System.debug('Error occured: ' + ex);
                }
            }
        }
    }

    private static Map <String, String> returnTypeMap = new Map <String, String> {
        'Goods to be return (First quality)' => 'Good Stock Return',
        'Goods to be return (Defective return)' => 'Faulty Stock Return'
    };

    public static void validateReturnLocation(List <Case> newcaseRecords, Map <Id, Case> oldRecords) {
        if (newcaseRecords != null && newcaseRecords.size() > 0) {
            List <Case> rmaCases = new List <Case> ();
            Set <String> regions = new Set <String> ();

            ID rmaCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();

            for (Case caseRecord: newcaseRecords) {
                
                D365Mapping__mdt mapping = Utility.D365Map.get(caseRecord.CurrencyIsoCode);
                
                if (Utility.isD365Enabled(caseRecord)) { 
                    if (caseRecord.RecordTypeId == rmaCaseRecordTypeId && caseRecord.RMA_Type__c == 'Destroy in Field') {
                        if (String.isNotBlank(caseRecord.ReturnLocation__c)) {
                            caseRecord.ReturnLocation__c.addError('Return location is not needed for Destroy in Field RMA type');
                        }
                        continue;
                    }
                    else if (caseRecord.ReturnLocation__c == null && (caseRecord.RecordTypeId == rmaCaseRecordTypeId || caseRecord.Complaint_Code__c == 'Final Return (Refund)')) {
                        caseRecord.ReturnLocation__c.addError('Return location cannot be empty.');
                        continue;
                    }
                }

                Case oldRecord = oldRecords == null ? null : oldRecords.get(caseRecord.Id);

                if ((oldRecord == null || (oldRecord != null && (caseRecord.RMA_Type__c != oldRecord.RMA_Type__c || caseRecord.ReturnLocation__c != oldRecord.ReturnLocation__c))) &&
                    String.isNotBlank(caseRecord.RMA_Type__c) &&
                    Utility.isD365Enabled(caseRecord)) {
                    rmaCases.add(caseRecord);
                    regions.add(mapping.BusinessUnit__c);
                }
            }

            if (rmaCases.size() > 0) {
                Map <String, Map <Id, Account>> returnLocationsByRegionAndType = new Map <String, Map < Id, Account>> ();
                Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
                for (Account acc: [SELECT Id, Name, Stock_Return_Type__c, DataAreaID__c FROM Account WHERE RecordTypeId = :businessRecordTypeId AND Type = 'Return Center']) {
                    if (!regions.contains(acc.DataAreaID__c) || acc.Stock_Return_Type__c == null) {
                        continue;
                    }
                    List <String> rTypes = acc.Stock_Return_Type__c.split(';');
                    for (String returnType: rTypes) {
                        String key = acc.DataAreaID__c + '-' + returnType;
                        if (returnLocationsByRegionAndType.containsKey(key)) {
                            returnLocationsByRegionAndType.get(key).put(acc.Id, acc);
                        }
                        else {
                            returnLocationsByRegionAndType.put(key, new Map <Id, Account> {
                                acc.Id => acc
                            });
                        }
                    }
                }
                for (Case caseRecord: rmaCases) {
                    
                    D365Mapping__mdt mapping = Utility.D365Map.get(caseRecord.CurrencyIsoCode);
                    
                    String key = mapping.BusinessUnit__c + '-' + returnTypeMap.get(caseRecord.RMA_Type__c);
                    Map <Id, Account> returnLocations = returnLocationsByRegionAndType.get(key);
                    if (returnLocations != null && returnLocations.size() > 0) {
                        List <String> validLocations = new List <String> ();
                        for (Account acc: returnLocations.values()) {
                            validLocations.add(acc.Name);
                        }
                        if (!returnLocations.containsKey(caseRecord.ReturnLocation__c)) {
                            caseRecord.ReturnLocation__c.addError('Invalid return location for the region and RMA type. Please select one of the following locations: ' + String.join(validLocations, ', '));
                        }
                    }
                    else {
                        caseRecord.ReturnLocation__c.addError('A matching return location for this region was not found.');
                    }
                }
            }
        }
    }
    
    public static void markReceivingComplete(List<Case> newCaseRecords, Map<Id, Case> oldRecords) {
        if (newcaseRecords != null && newcaseRecords.size() > 0) {
            Set<Id> filteredCaseIds = new Set<Id>();
            for (Case caseRecord : newCaseRecords) {
                Case oldRecord = oldRecords.get(caseRecord.Id);
                if (caseRecord.RMA_Type__c != 'Destroy in Field' && caseRecord.ReceivingComplete__c && oldRecord.ReceivingComplete__c == false) {
                    filteredCaseIds.add(caseRecord.Id);
                }
            }
            if (filteredCaseIds.size() > 0) {
                for (Case caseRecord : [SELECT Id, (SELECT Id FROM Receiving__r WHERE Sent_to_AX__c = null LIMIT 1) FROM Case WHERE Id IN :filteredCaseIds]) {
                    if (caseRecord.Receiving__r.size() > 0) {
                        filteredCaseIds.remove(caseRecord.Id);
                    }
                }
                if (filteredCaseIds.size() > 0) {
                    System.enqueueJob(new D365APIUtility.ProcessRMA(filteredCaseIds, D365APIUtility.Action.CompleteRMA));
                }
            }
        }
    }
    
    public static void processedRADelivered(List<Case> caseRecords, Map<Id, Case> oldCases) {
        if (caseRecords.size()> 0) {
            List<Case> filteredCases = new List<Case>();
            Set<Id> assetIds = new Set<Id> ();
            Set<Id> productIds = new Set<Id>();
            for (Case caseRecord : caseRecords) {
                Case oldCase = oldCases.get(caseRecord.Id);
                if (Utility.isD365Enabled(caseRecord) 
                    && Label.FinalReturn.equalsIgnoreCase(caseRecord.Complaint_Code__c) 
                    && caseRecord.RA_Delivered__c 
                    && caseRecord.AssetID != null
                    && caseRecord.Product__c != null
                    && caseRecord.RA_Delivered__c != oldCase.RA_Delivered__c) {
                    filteredCases.add(caseRecord);
                    assetIds.add(caseRecord.AssetId);
                    productIds.add(caseRecord.Product__c);
                } 
            }
            if (filteredCases.size()> 0) {
                Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, Product_Type__c FROM Product2 WHERE Id =:productIds]);
                List<Asset> assetsToUpdate = new List<Asset>();
                for (Case caseRecord : filteredCases) {
                    if (String.isNotBlank(caseRecord.AssetId)) {
                        Asset assetRecord = new Asset(Id = caseRecord.AssetId);
                        String productType = products.get(caseRecord.Product__c).Product_Type__c;
                        
                        if (String.isNotBlank(caseRecord.ExtendedWarranty__c) 
                            || 'EXTWTY'.equalsIgnoreCase(productType)) {
                            assetRecord.EW_Status__c = 'Cancelled';
                            assetRecord.EW_Cancellation_Date__c = Date.today();
                            assetRecord.Trigger_Mulberry_Cancellation__c = true;
                        }
                        if (!'EXTWTY'.equalsIgnoreCase(productType)) {
                            assetRecord.Status = 'Returned';
                        }
                        
                        assetsToUpdate.add(assetRecord);
                    }
                }
                if (assetsToUpdate.size()> 0) {
                    update assetsToUpdate;
                }
            }
        }
    }
}