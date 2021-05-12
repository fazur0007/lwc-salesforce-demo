@isTest
public class OneTimeUtilitiesTest{
	
	@testSetup
	static void setupSampleData(){
		
		Product2 productRecord = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
        		 										Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true);
        productRecord.AX_Item_Number__c = 'SES990BSS2G1UK1';
        insert productRecord;
        
        Product2 productRecord2 = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
        		 										Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true);
        productRecord2.AX_Item_Number__c = 'BDC450BSS1BCA1';
        insert productRecord2;
        
        Account accountRecord = new Account();
        accountRecord.firstName = 'Nikhil';
        accountRecord.lastName = 'Palekar';
        accountRecord.personEmail = 'nikhil_palekar@example.com';
        insert accountRecord;
        
        Asset assetRecord = new Asset();
        assetRecord.Name = 'Test Name 1';
        assetRecord.Batch_Code__c = '1711';
        assetRecord.PurchaseDate = date.today();
        assetRecord.Product2Id = productRecord.Id ;
        assetRecord.Warranty_In_Months__c = 15;
        assetRecord.AccountId = accountRecord.Id;
        insert assetRecord;
        
        Asset assetRecord2 = new Asset();
        assetRecord2.Name = 'Test Name 1';
        assetRecord2.Batch_Code__c = '1712';
        assetRecord2.PurchaseDate = date.today();
        assetRecord2.Product2Id = productRecord2.Id ;
        assetRecord2.Warranty_In_Months__c = 15;
        assetRecord2.AccountId = accountRecord.Id;
        insert assetRecord2;
        
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+productRecord.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';
        offerRecord.MatchOfferfromNCharacter__c = 1;
        offerRecord.Active__c = true;
        offerRecord.CurrencyIsoCode = 'GBP';
        insert offerRecord;
        
        Offer__c offerRecord2 = new Offer__c();
        offerRecord2.MultipleProducts__c =  ';'+productRecord2.AX_Item_Number__c+';';
        offerRecord2.OfferCode__c = 'OSUBS1';
        offerRecord2.MatchOfferfromNCharacter__c = 1;
        offerRecord2.Active__c = true;
        offerRecord2.CurrencyIsoCode = 'CAD';
        offerRecord2.OfferCodeStart__c = 1;
        offerRecord2.OfferCodeEnd__c = 3000;
        offerRecord2.SequentialCounter__c = 60;
        insert offerRecord2;
        
        Offer_Order__c offerOrderRecord = new Offer_Order__c();
        offerOrderRecord.ActivateOrderOnNDay__c = 0;
        offerOrderRecord.Offer__c = offerRecord.id;
        insert offerOrderRecord; 
        
        Offer_Order_Items__c offerOrderItemsRecord = new Offer_Order_Items__c();
        offerOrderItemsRecord.Offer_Order__c = offerOrderRecord.id;
        offerOrderItemsRecord.Product__c = productRecord.Id ;
        offerOrderItemsRecord.Quantity__c = 2;
        insert offerOrderItemsRecord;
        
	}
	
	static testMethod void testMethod1(){
		Test.startTest();
		OneTimeUtilities.generateOfferCodesForCanada('BDC450BSS1BCA1', null);
		OneTimeUtilities.createOfferOrdersForAlreadyRegisteredAssets('UK_OFFER_01', 'SES990BSS2G1UK1', 'GBP', null);
		Test.stopTest();
	}
	static testMethod void testMethod2(){
		Test.startTest();
		OneTimeUtilities.generateOfferCodesForCanada('BDC450BSS1BCA1', 'TESTID');
		OneTimeUtilities.createOfferOrdersForAlreadyRegisteredAssets('UK_OFFER_01', 'SES990BSS2G1UK1', 'GBP', 'TESTID');
		Test.stopTest();
	}
}