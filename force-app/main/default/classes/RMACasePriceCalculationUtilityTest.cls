@isTest
public with sharing class RMACasePriceCalculationUtilityTest 
{ 
    static testMethod void testMethodRMACasePriceCalculationUtility(){
	 	
	 	List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
	 	
	 	 //Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        String axItemNo = 'ZBBL800BSS1BCA1';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo); 
        insert objProd;  
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
        insert caseObj;
        
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100, Product__c = objProd.Id);
        insert rmaObj;
        
        System.debug(caseObj.Id);
        Test.starttest();
	
		 // Set mock callout class
         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
         
         
         //Check success of response
         Test.setMock(HttpCalloutMock.class, new RMAPriceMockImpl(400));
	     RMACasePriceCalculationUtility.calculatePriceUtility(caseObj.Id);
	     
		Test.stoptest();
	
	}
    
}