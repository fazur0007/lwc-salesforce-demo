public class LightningServiceContractRefundFlow_Cls{
    public LightningServiceContractRefundFlow_Cls() {
    
    }

    public class Assetwrapper {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String Product2_Ax_Item_Number{get; set;}
        @AuraEnabled public String Product2_Description { get; set;}
        @AuraEnabled public Boolean EW_Present { get; set;}
        @AuraEnabled public String Product_Extended_warranty_Warranty_Product_Name{ get; set;}
        @AuraEnabled public Boolean Trigger_Mulberry_Cancellation {get; set;}
        @AuraEnabled public Boolean isReturnFG {get; set;}
        @AuraEnabled public Boolean isReturnSC {get; set;}
        @AuraEnabled public String ProductId {get; set;}
        @AuraEnabled public String OrderId {get; set;}
        @AuraEnabled public String OrderNumber {get; set;}
        @AuraEnabled public Boolean isEWCancelled {get; set;}
    }

    @AuraEnabled public static Map <String, Object> getAssetDetails(String recordId) {
        Map <String, Object> result = new Map <String, Object> ();

        Case cse = [Select Id, Complaint_Code__c, Order__c, Order__r.Asset__c, AccountId, RA_Delivered__c, CurrencyIsoCode from Case Where Id =: recordId];
        
        if (cse.RA_Delivered__c) {
            result.put('isSuccess', false);
            result.put('error', 'Return has already been initiated.');
        } else if (!Label.FinalReturn.equalsIgnorecase(cse.Complaint_Code__c)) {
            result.put('isSuccess', false);
            result.put('error', 'The complaint code of case should be \'Final Return (Refund)\'');
        } else {
            List <Assetwrapper> assetwrapper = new List <Assetwrapper> ();
            List <Asset> lstAsset = new List <Asset> ();
            if (String.isNotBlank(cse.Order__c)) {
                if (String.isBlank(cse.Order__r.Asset__c)) {
                    lstAsset = [select id, name, Product2Id, Product2.Ax_Item_Number__c, Product2.Description, EW_Present__c, Product_Extended_warranty__r.Warranty_Product_Name__c, Trigger_Mulberry_Cancellation__c, ParentOrder__c, ParentOrder__r.OrderNumber, EW_Status__c
                        FROM Asset 
                        WHERE ParentOrder__c =: cse.Order__c 
                        AND CurrencyIsoCode = :cse.CurrencyIsoCode
                        AND Status != 'Returned'
                    ];
                } else {
                    lstAsset = [select id, name, Product2Id, Product2.Ax_Item_Number__c, Product2.Description, EW_Present__c, Product_Extended_warranty__r.Warranty_Product_Name__c, Trigger_Mulberry_Cancellation__c, ParentOrder__c, ParentOrder__r.OrderNumber, EW_Status__c
                        From Asset where id =: cse.Order__r.Asset__c
                        AND CurrencyIsoCode = :cse.CurrencyIsoCode
                        AND Status != 'Returned'
                    ];
                }
            } else {
                lstAsset = [select id, name, Product2Id, Product2.Ax_Item_Number__c, Product2.Description, EW_Present__c, Product_Extended_warranty__r.Warranty_Product_Name__c, Trigger_Mulberry_Cancellation__c, ParentOrder__c, ParentOrder__r.OrderNumber, EW_Status__c
                    From Asset where AccountId =: cse.AccountId
                    AND ParentOrder__c != null
                    AND CurrencyIsoCode = :cse.CurrencyIsoCode
                    AND Status != 'Returned'
                ];
            }

            if (lstAsset.size()> 0) {
                for (Asset ast: lstAsset) {
                    Assetwrapper objAssetwrapper = new Assetwrapper();
                    objAssetwrapper.Id = ast.Id;
                    objAssetwrapper.Name = ast.name;
                    objAssetwrapper.Product2_Ax_Item_Number = ast.Product2.Ax_Item_Number__c;
                    objAssetwrapper.Product2_Description = ast.Product2.Description;
                    objAssetwrapper.EW_Present = ast.EW_Present__c;
                    objAssetwrapper.Product_Extended_warranty_Warranty_Product_Name = ast.Product_Extended_warranty__r.Warranty_Product_Name__c;
                    objAssetwrapper.Trigger_Mulberry_Cancellation = ast.Trigger_Mulberry_Cancellation__c;
                    objAssetwrapper.isReturnFG = false;
                    objAssetwrapper.isReturnSC = false;
                    objAssetwrapper.ProductId = ast.Product2Id;
                    objAssetwrapper.OrderId = ast.ParentOrder__c;
                    objAssetwrapper.OrderNumber = ast.ParentOrder__r.OrderNumber;
                    objAssetwrapper.isEWCancelled = ast.EW_Status__c == 'Cancelled' ? true : false;
                    assetwrapper.Add(objAssetwrapper);
                }
            }
            result.put('assets', assetwrapper);
            result.put('isSuccess', true);
        }
        return result;
    }

    @AuraEnabled public static String doUpdateAssets(string recordId,String newAssetList) {      
        if(newAssetList != null){
            Map<String, Object> mapOfOject = (Map<String, Object>) JSON.deserializeUntyped(newAssetList);
            String assetId = String.valueOf(mapOfOject.get('Id'));
            
            system.debug('assetId:'+ assetId);
            System.debug('newAssetList: ' + newAssetList);
            Asset assetRecord = [SELECT Id, 
                                    Product2Id, 
                                    ParentOrder__c, 
                                    ParentOrder__r.OrderNumber, 
                                    ParentOrder__r.PricesInclusiveOfTaxes__c, 
                                    Order_Product__c,
                                    Order_Product__r.UnitPrice, 
                                    Order_Product__r.ListPrice, 
                                    Order_Product__r.Quantity, 
                                    Order_Product__r.Line_Item_Tax__c,
                                    Batch_Code__c,
                                    PurchaseDate,
                                    Extended_Warranty_Product__c,
                                    Product_Extended_warranty__c,
                                    Product_Extended_warranty__r.Parent_order_product__c, 
                                    Product_Extended_warranty__r.Parent_order_product__r.UnitPrice, 
                                    Product_Extended_warranty__r.Parent_order_product__r.Quantity, 
                                    Product_Extended_warranty__r.Parent_order_product__r.Line_Item_Tax__c,
                                    Product_Extended_warranty__r.Warranty_order_product__c, 
                                    Product_Extended_warranty__r.Warranty_order_product__r.UnitPrice, 
                                    Product_Extended_warranty__r.Warranty_order_product__r.Quantity, 
                                    Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c,
                                    EW_Status__c
                                FROM Asset Where Id =:assetId ];
            
            system.debug('recordId:'+ recordId);
            
            Boolean isOnlySCReturn = Boolean.valueOf(mapOfOject.get('isReturnSC'));
            
            Case caseRecord = new Case(Id = recordId, AssetId = assetId);
            
            Decimal refundAmount = 0.0;
            caseRecord.FG_Refund_Amount__c = 0.0;
            caseRecord.EW_Refund_Amount__c = 0.0;
            
            if (isOnlySCReturn) {
                caseRecord.Product__c = assetRecord.Extended_Warranty_Product__c;
                caseRecord.ExtendedWarranty__c = null;
                caseRecord.RA_Delivered__c = true;
                caseRecord.RA_Return_Date__c = Date.today();
            } else {
                caseRecord.Product__c = assetRecord.Product2Id;
                caseRecord.FG_Refund_Amount__c += assetRecord.Order_Product__r.UnitPrice;
                if (!assetRecord.ParentOrder__r.PricesInclusiveOfTaxes__c) {
                    caseRecord.FG_Refund_Amount__c += (assetRecord.Order_Product__r.Line_Item_Tax__c == null ? 0 : assetRecord.Order_Product__r.Line_Item_Tax__c / assetRecord.Order_Product__r.Quantity);
                }
            }
            
            if (String.isNotBlank(assetRecord.Extended_Warranty_Product__c) && assetRecord.EW_Status__c != 'Cancelled') {
                if (!isOnlySCReturn) {
                    caseRecord.ExtendedWarranty__c = assetRecord.Extended_Warranty_Product__c;
                }
                
                caseRecord.EW_Refund_Amount__c += assetRecord.Product_Extended_warranty__r.Warranty_order_product__r.UnitPrice;
                if (!assetRecord.ParentOrder__r.PricesInclusiveOfTaxes__c) {
                    caseRecord.EW_Refund_Amount__c += (assetRecord.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c == null ? 0 : assetRecord.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c / assetRecord.Product_Extended_warranty__r.Warranty_order_product__r.Quantity);
                }
            } else {
                caseRecord.ExtendedWarranty__c = null;
            }
            
            if (String.isNotBlank(assetRecord.ParentOrder__c)) {
                caseRecord.Order__c = assetRecord.ParentOrder__c;
            }
            caseRecord.Batch_Code__c = assetRecord.Batch_Code__c;
            caseRecord.Refund_Required__c = true;
            caseRecord.EW_Refund_Amount__c = caseRecord.EW_Refund_Amount__c.setScale(2);
            caseRecord.FG_Refund_Amount__c = caseRecord.FG_Refund_Amount__c.setScale(2);
            caseRecord.Refund_Amount__c = caseRecord.EW_Refund_Amount__c + caseRecord.FG_Refund_Amount__c;
            caseRecord.Purchase_Date__c = assetRecord.PurchaseDate;
            
            update caseRecord;
            
            return 'Success';
        }
        else
        {
            throw new AuraHandledException('Update failed');
        }
       
    }
}