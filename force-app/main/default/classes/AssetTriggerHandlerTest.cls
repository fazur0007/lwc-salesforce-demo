@isTest
public with sharing class AssetTriggerHandlerTest {

    static testMethod void testMethodAssetTriggerHandler(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
                                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true); 
        insert objProd;  
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
         
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1620';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 15;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        insert assetObj;
        
        //insert offer 
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+objProd.AX_Item_Number__c+';';
      //  offerRecord.Product__c =objProd.Id ;
        offerRecord.OfferCode__c = 'HBE7';
        offerRecord.MatchOfferfromNCharacter__c = 1;
        insert offerRecord; 
        
         //insert offer order
        Offer_Order__c offerOrderRecord = new Offer_Order__c();
        offerOrderRecord.ActivateOrderOnNDay__c = 0;
        offerOrderRecord.Offer__c = offerRecord.id;
       // offerOrderRecord.TriggerDeliveryEmailAfterNDay__c = 1;
        insert offerOrderRecord; 
        
        //insert offer order items
        Offer_Order_Items__c offerOrderItemsRecord = new Offer_Order_Items__c();
        offerOrderItemsRecord.Offer_Order__c = offerOrderRecord.id;
        offerOrderItemsRecord.Product__c = objProd.Id ;
        offerOrderItemsRecord.Quantity__c = 2;
        insert offerOrderItemsRecord; 
        
        list<Asset> assetList = [SELECT Id, Warranty_In_Months__c FROM Asset WHERE Id = :assetObj.id];        
        System.assertEquals(assetList[0].Warranty_In_Months__c, 15);
        
        //Insert Case
        Case caseObj = NEW Case();
        caseObj.Batch_Code__c ='1620';
        caseObj.Purchased_From__c = 'Amazon India';
        caseObj.AssetId = null;
        caseObj.Warranty_Based_on_Batch_Code__c = 'True';
        caseObj.Product__c = objProd.Id;
        caseObj.Warranty_Based_on_Registration_Date__c =' True';
        caseObj.Warranty_Based_on_Purchase_Date__c = 'True';
        caseObj.Purchase_Date__c =  date.today();
        caseObj.Warranty_Expiration_Date__c =  date.today();
        caseObj.Extended_Warranty_Expiration_Date__c = date.today();
        insert caseObj;
        
        caseObj.AssetId = assetObj.Id;
        update caseObj;
        
        assetObj.Warranty_In_Months__c = 13;
        update assetObj;
        
    }
        
    static testMethod void testMethod1(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15); 
        insert objProd;  
        
        Product2 objProd1 = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
                                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true); 
        insert objProd1;  
        
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+objProd.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'HBE7';
        offerRecord.MatchOfferfromNCharacter__c = 1;
        insert offerRecord; 
        
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1620';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 15;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        insert assetObj;
        
        //Insert Case
        Case caseObj = NEW Case();
        caseObj.Batch_Code__c ='1620';
        caseObj.Purchased_From__c = 'Amazon India';
        caseObj.AssetId = assetObj.Id;
        caseObj.Warranty_Based_on_Batch_Code__c = 'True';
        caseObj.Product__c = objProd1.Id;
        caseObj.Warranty_Based_on_Registration_Date__c =' True';
        caseObj.Warranty_Based_on_Purchase_Date__c = 'True';
        caseObj.Purchase_Date__c =  date.today();
        caseObj.Warranty_Expiration_Date__c =  date.today();
        caseObj.Extended_Warranty_Expiration_Date__c = date.today();
        insert caseObj;
        
        caseObj.AssetId = assetObj.Id;
        update caseObj;
        
        assetObj.Warranty_In_Months__c = 13;
        update assetObj;
        
        // Update Asset Record
        Asset  assetObj1 = [SELECT Warranty_In_Months__c FROM Asset WHERE id=:assetObj.Id LIMIT 1];
        assetObj1.Warranty_In_Months__c = 13;
        update assetObj1;
        
        //list<Case> caseList = [SELECT Id, Warranty__c FROM Case WHERE Id = :caseObj.Id];
        //System.assertEquals(caseList[0].Warranty__c, 'In Warranty');
        
    }
                
    static testMethod void testMethod2(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15); 
        insert objProd;  
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+objProd.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'HBE7';
        offerRecord.MatchOfferfromNCharacter__c = 1;
        offerRecord.Active__c = true;
        insert offerRecord;  
        
        //insert offer order
        Offer_Order__c offerOrderRecord = new Offer_Order__c();
        offerOrderRecord.ActivateOrderOnNDay__c = 0;
        offerOrderRecord.Offer__c = offerRecord.id;
       // offerOrderRecord.TriggerDeliveryEmailAfterNDay__c = 1;
        insert offerOrderRecord; 
        
        //insert offer order items
        Offer_Order_Items__c offerOrderItemsRecord = new Offer_Order_Items__c();
        offerOrderItemsRecord.Offer_Order__c = offerOrderRecord.id;
        offerOrderItemsRecord.Product__c = objProd.Id ;
        offerOrderItemsRecord.Quantity__c = 2;
        insert offerOrderItemsRecord; 
            
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1620';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = null;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        insert assetObj;
        
        // Verify ASSET is created 
        Integer i = [SELECT COUNT() FROM Asset];
        System.assertEquals(i, 1); 
    }
   
    static testMethod void testMethod3(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15); 
        insert objProd;  
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
           
        try{   
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+objProd.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'HBE7';
        offerRecord.MatchOfferfromNCharacter__c = 1;
        insert offerRecord; 
        
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1720';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = null;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        insert assetObj;
    
       // Verify ASSET is created 
        Integer i = [SELECT COUNT() FROM Asset];
        System.assertEquals(i, 1); 
        
        }catch(Exception e){
            System.debug('Error while inserting Asset: ' + e );
        }
        
        
    }
        
    static testMethod void testMethod4(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15); 
        insert objProd;  
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+objProd.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'HBE7';
        offerRecord.MatchOfferfromNCharacter__c = 1;
        insert offerRecord; 
          
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1620';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 15;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        insert assetObj;
        
        // Verify ASSET is created 
        Integer i = [SELECT COUNT() FROM Asset];
        System.assertEquals(i, 1); 
        
        //Insert Case
        Case caseObj = NEW Case();
        caseObj.Batch_Code__c ='1620';
        caseObj.Purchased_From__c = 'Amazon India';
        caseObj.AssetId = assetObj.Id;
        caseObj.Warranty_Based_on_Batch_Code__c = 'True';
        //caseObj.Product__c = objProd.Id;
        caseObj.Warranty_Based_on_Registration_Date__c =' True';
        caseObj.Warranty_Based_on_Purchase_Date__c = 'True';
        caseObj.Purchase_Date__c =  date.today();
        caseObj.Warranty_Expiration_Date__c =  date.today();
        caseObj.Extended_Warranty_Expiration_Date__c = date.today();
        insert caseObj;
      
        caseObj.AssetId = assetObj.Id;
        update caseObj;
        
        try{
        assetObj.Batch_Code__c = '1720';
        assetObj.Warranty_In_Months__c = 13;
        update assetObj;
        }catch(Exception e){
            System.debug('Error while updating Asset- Batch Code and Warranty in months: ' + e );
        }
        
    }
    
    /*static testMethod void testMethod5(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
                                       Serialized_Item__c = true, brand__c = 'Sage'); 
        insert objProd;  
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
          
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1620';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 15;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        assetObj.SerialNumber = '10ABCDEF190300001';
        insert assetObj;
        
        // Verify ASSET is created 
        Integer i = [SELECT COUNT() FROM Asset];
        System.assertEquals(i, 1); 
                
        try{
            assetObj.SerialNumber = '190300001ABC0000';
            update assetObj;
        }catch(Exception e){}
        
        String serialNum = [SELECT Id, SerialNumber FROM Asset].SerialNumber;
        System.assertEquals('190300001ABC0000', serialNum);         
    }*/
    
    static testMethod void testMethod6(){
            
        //Insert Product2
        Product2 objProd = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
                                       Serialized_Item__c = true, brand__c = 'Sage'); 
        insert objProd;  
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;  
          
        //Insert Asset
        Asset assetObj = new Asset();
        assetObj.Name = 'Ravi Verma';
        assetObj.Batch_Code__c = '1620';
        assetObj.PurchaseDate = date.today();
        assetObj.Product2Id = objProd.Id ;
        assetObj.Warranty_In_Months__c = 15;
        assetObj.AccountId = objAcc.Id;
        assetObj.ExactOfferCode__c ='HBE7';
        assetObj.SerialNumber = '190300001ABC';
        insert assetObj;
        
        // Verify ASSET is created 
        Integer i = [SELECT COUNT() FROM Asset];
        System.assertEquals(i, 1); 
                
        try{
            assetObj.SerialNumber = '10ABCDEF190300001';
            update assetObj;
        }catch(Exception e){
            System.debug('Error while updating Asset- Serial Number: ' + e );
        }
        
        String serialNum = [SELECT Id, SerialNumber FROM Asset].SerialNumber;
        System.assertEquals('10ABCDEF190300001', serialNum);         
    }
}