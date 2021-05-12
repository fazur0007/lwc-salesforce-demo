public without sharing class Org_QuickActionHandler { 
    @AuraEnabled
    public static WorkOrder getConfigData(String workOrderId){
        return [Select Id,Status From WorkOrder Where Id =:workOrderId Limit 1];
    }
    @AuraEnabled
    public static String createClaim(String workOrderId){
       return ClaimUtility.createClaim(workOrderId);
    }
    
    @AuraEnabled
    public static Map <String,Object> getCaseConfigData(String recordId){
        Case cse = [Select Id,Type,Warranty__c,WarrantyOutofWarrantyToInWarranty__c,PriceCalculationRequired__c,IsRMAReleased__c From Case Where Id =:recordId Limit 1];
        if(cse != Null ){
            return new Map <String,Object> {
                'Id' => cse.Id,
                'Type' => String.isNotBlank(cse.Type) ? cse.Type : '',
                'Warranty__c' => String.isNotBlank(cse.Warranty__c) ? cse.Warranty__c : '',
                'WarrantyOutofWarrantyToInWarranty__c' => cse.WarrantyOutofWarrantyToInWarranty__c,
                'PriceCalculationRequired__c' => cse.PriceCalculationRequired__c,
                'IsRMAReleased__c' => cse.IsRMAReleased__c   
            };
        }else{
            throw new AuraHandledException('Error Occured');
        }
    }
    @AuraEnabled
    public static String updateCaseExtendWarranty(String recordId){
        try{
            update new Case (
                Id = recordId,
                WarrantyOutofWarrantyToInWarranty__c = true
            );
        return 'Success';
        }Catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled 
    public static String calculatePriceUtility(String recordId){
        try{
            RMACasePriceCalculationUtility.calculatePriceUtility(recordId);
            return 'Success';
        } Catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String updateCaseRelease(String recordId){
        try{
            update new Case (
                Id = recordId,
                IsRMAReleased__c = true
            );
        return 'Success';
        }Catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createReturnLabel(String recordId){
        try{
            Case cse = [Select Id,Type,Warranty__c,WarrantyOutofWarrantyToInWarranty__c,PriceCalculationRequired__c,
                    IsRMAReleased__c,Return_Shipment_Type__c,RMAStatus__c, RMA_Type__c
                    From Case Where Id =:recordId Limit 1];
            if(cse != Null ){
                if (cse.Return_Shipment_Type__c != 'Single Parcel' && cse.Return_Shipment_Type__c != 'Multiple Parcels') {
                    return 'Only applicable for Single and Multiple Parcels Shipment Type.';
                } else if (cse.RMAStatus__c != 'RMA Approved') {
                    return 'Only applicable for RMA Approved records.';
                } if (cse.RMA_Type__c == 'Destroy in Field') {
                    return 'Not applicable for Destroy in Field RMA Type';
                } else {
                    CreateReturnLabelApi.createLabel(cse.Id);
                    return 'Success';
                }
            }else{
                throw new AuraHandledException('Error occured, please reachout admin for help');
            }
        } Catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Result getAccountData(String recordId){
        Account acc = [SELECT CurrencyIsoCode,Id,Shipping_Street_Line_1__c,Shipping_Street_Line_2__c,ShippingState,ShippingCity,ShippingPostalCode,ShippingCountry FROM Account
            WHERE Id = :recordId];
        Result r = new Result();
        r.accountRecord = acc;
        r.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA').getRecordTypeId();
        return r;
    }
    
    public class Result {
        @AuraEnabled public Account accountRecord { get; set; }
        @AuraEnabled public String recordTypeId { get; set; }
    }   
}