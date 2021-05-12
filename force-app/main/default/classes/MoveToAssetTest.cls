@isTest
public with sharing class MoveToAssetTest {

	static testMethod void testMethodMoveToAsset(){
            
        //Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'test Account';
        insert objAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        insert objProd;   
        
        List<Warranty__c> warrantyList = new List<Warranty__c>();
		Warranty__c warrantyObj = new Warranty__c(Product_Date_Code__c='1320',Where_did_you_purchase__c='Amazon',How_did_you_hear_of_us__c='A Friend',
		Web_Purchase_Date__c= date.today(),Warranty_Product_Sub_Category__c='JC JUICER',Product_Category__c='Beverages',Warranty_Owner__c=objAcc.Id,Product__c=objProd.Id,
		Serial__c='12345',Other_Store_Name__c='test name',
		Warranty_Product__c='BBL420XL - Upgrade replacement to BBL410XL',Product_Name__c='test Product',Store_State__c='Washington');
		
		warrantyList.add(warrantyObj);
		insert warrantyList;
		
		Test.startTest();
	        MoveToAsset moveToAssetObj = new MoveToAsset();
	        Database.executeBatch(moveToAssetObj);
        Test.stopTest();
		
	}
}