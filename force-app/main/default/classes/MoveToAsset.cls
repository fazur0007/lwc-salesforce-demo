global class MoveToAsset implements Database.Batchable <Warranty__c> {

    global MoveToAsset(){}

    global List<Warranty__c> start(Database.BatchableContext BC) {
        return [Select Name, Warranty_Owner__c,Product__c,Product_Date_Code__c, Where_did_you_purchase__c, Serial__c, Product_Name__c,
        How_did_you_hear_of_us__c, Other_Store_Name__c,Store_State__c,Warranty_Product__c,
        Warranty_Product_Sub_Category__c,Product_Category__c,Web_Purchase_Date__c From Warranty__c];
    }

    global void execute(Database.BatchableContext BC, List<Warranty__c> scope) {
       List<Asset> asst = new List<Asset>();
       for(Warranty__c war : scope){
           asst.add(
               new Asset(
                   AccountId = war.Warranty_Owner__c,
                    Name = war.Name,
                   Product2Id = war.Product__c,
                    Batch_Code__c = war.Product_Date_Code__c,
                    Where_did_you_purchase__c = war.Where_did_you_purchase__c,
                    SerialNumber = war.Serial__c,
                   Product_Name_If_Other__c = war.Product_Name__c,
                   How_did_you_hear_about_us__c = war.How_did_you_hear_of_us__c,
                    Other_Store_Name__c = war.Other_Store_Name__c,
                   Store_State__c = war.Store_State__c,
                   Warranty_Product__c = war.Warranty_Product__c,
                  Warranty_Product_Sub_Category__c = war.Warranty_Product_Sub_Category__c,
                   Product_Category__c = war.Product_Category__c,
                   PurchaseDate = war.Web_Purchase_Date__c
                    )
           );
       }
       Database.insert(asst, false);
       delete scope;
    }

    global void finish(Database.BatchableContext BC) {}
}