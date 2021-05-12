/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProductRegistrationForPolyscienceTest {
	static testMethod void testMethodProductRegistrationForPolyscience(){
		Test.starttest();
	         PageReference pageRef = Page.ProductRegistrationForPolyscience;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        ProductRegistrationForPolyscience productRegistrationForPolyscienceObj = new ProductRegistrationForPolyscience();
		     	productRegistrationForPolyscienceObj.acct.FirstName = 'Joe';
		        productRegistrationForPolyscienceObj.acct.LastName = 'Bob';
		        productRegistrationForPolyscienceObj.acct.BillingStreet = '123 test st';
		        productRegistrationForPolyscienceObj.personBillingStreet2 = '123 test street 2';
		        productRegistrationForPolyscienceObj.acct.BillingCity = 'Denver';
		        productRegistrationForPolyscienceObj.acct.BillingState = 'CO';
		        productRegistrationForPolyscienceObj.acct.BillingPostalCode = '80002';
		        productRegistrationForPolyscienceObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        productRegistrationForPolyscienceObj.acct.BillingCountryCode = '440012';
		        productRegistrationForPolyscienceObj.acct.BillingStateCode = '440012';
		        productRegistrationForPolyscienceObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        productRegistrationForPolyscienceObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationForPolyscienceObj.asset.PurchaseDate = date.today();
		        productRegistrationForPolyscienceObj.asset.Batch_Code__c = '1620';
		        Product2 product = TestDataFactory.createProduct('Prod', false, true);
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        productRegistrationForPolyscienceObj.asset.AccountId = accountObj.Id;
		        productRegistrationForPolyscienceObj.asset.Product2Id = product.Id;
		        productRegistrationForPolyscienceObj.objCase.Batch_Code__c = null;
		        productRegistrationForPolyscienceObj.objCase.Purchased_From__c = 'test';
		        
		        
		        productRegistrationForPolyscienceObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationForPolyscienceObj.fetchProducts();
		        productRegistrationForPolyscienceObj.registrationSave();
		        
		        ProductRegistrationForPolyscience productRegistrationForPolyscienceObj1 = new ProductRegistrationForPolyscience();
		     	productRegistrationForPolyscienceObj1.acct.FirstName = null;
		        productRegistrationForPolyscienceObj1.acct.LastName = null;
		        productRegistrationForPolyscienceObj1.acct.BillingStreet = null;
		        productRegistrationForPolyscienceObj1.personBillingStreet2 = null;
		        productRegistrationForPolyscienceObj1.acct.BillingCity = null;
		        productRegistrationForPolyscienceObj1.acct.BillingState = null;
		        productRegistrationForPolyscienceObj1.acct.BillingPostalCode = null;
		        productRegistrationForPolyscienceObj1.acct.PersonEmail = null;
		        productRegistrationForPolyscienceObj1.acct.BillingCountryCode = null;
		        productRegistrationForPolyscienceObj1.acct.BillingStateCode = null;
		        productRegistrationForPolyscienceObj1.confirmEmail = null;
		        productRegistrationForPolyscienceObj1.selectedSubCategory = null;
		        productRegistrationForPolyscienceObj1.asset.PurchaseDate = null;
		        productRegistrationForPolyscienceObj1.asset.Batch_Code__c = null;
		        productRegistrationForPolyscienceObj1.asset.AccountId = null;
		        productRegistrationForPolyscienceObj1.asset.Product2Id = null;
		        productRegistrationForPolyscienceObj1.objCase.Batch_Code__c = null;
		        productRegistrationForPolyscienceObj1.objCase.Purchased_From__c =null;
		        
		        productRegistrationForPolyscienceObj1.registrationSave();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethodProductRegistrationControllerNegativeTest1(){
		Test.starttest();
	         PageReference pageRef = Page.ProductRegistrationForPolyscience;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Product2 product = TestDataFactory.createProduct('Prod', false, true);
		     Account accountObj = new Account();
		     accountObj.FirstName = 'Joe';
		     accountObj.LastName = 'Bob';
		        accountObj.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        //accountObj.BillingCountry = 'US';
		        accountObj.BillingCity = 'CHARLOTTETOWN';
		        //accountObj.BillingState = 'CO';
		        accountObj.BillingPostalCode = '8 002';
		        accountObj.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        accountObj.BillingCountryCode = 'US';
		        accountObj.BillingStateCode = 'CO';
		     insert accountObj;
	         
	         //Insert Asset
		        Asset assetObj = new Asset();
		        assetObj.Name = 'Ravi Verma';
		        assetObj.Batch_Code__c = '1620';
		        assetObj.PurchaseDate = Date.today();
		        assetObj.Product2Id = product.Id ;
		        assetObj.Warranty_In_Months__c = 15;
		        assetObj.AccountId = accountObj.Id;
		        insert assetObj;
	        
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         	
		        ProductRegistrationForPolyscience productRegistrationForPolyscienceObj = new ProductRegistrationForPolyscience();
		     	productRegistrationForPolyscienceObj.acct = accountObj;
		     	productRegistrationForPolyscienceObj.dummyAccount = accountObj;
		        productRegistrationForPolyscienceObj.personBillingStreet2 = '123 test street 2';
		        productRegistrationForPolyscienceObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        productRegistrationForPolyscienceObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationForPolyscienceObj.asset.PurchaseDate = Date.today();
		        productRegistrationForPolyscienceObj.asset.Batch_Code__c = null;
		        productRegistrationForPolyscienceObj.asset.AccountId = null;
		        productRegistrationForPolyscienceObj.asset.Product2Id = product.id;
		        productRegistrationForPolyscienceObj.objCase.Batch_Code__c = null;
		        productRegistrationForPolyscienceObj.objCase.Purchased_From__c ='Amazon';
		        
		        productRegistrationForPolyscienceObj.fetchProducts();
		        productRegistrationForPolyscienceObj.registrationSave();
		        
		        //When personalEmail!=confirmEmail
		        productRegistrationForPolyscienceObj.confirmEmail = 'raveena@persistent.co.in';
		        productRegistrationForPolyscienceObj.registrationSave();
		        
		        //BillingStreet
		        productRegistrationForPolyscienceObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        productRegistrationForPolyscienceObj.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)134 KENT ST. (CONF.COURT MALL)';
		        productRegistrationForPolyscienceObj.registrationSave();
		        
		        //Billing postal code
		        productRegistrationForPolyscienceObj.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        productRegistrationForPolyscienceObj.regionCode = 'CAN';
		        productRegistrationForPolyscienceObj.dummyAccount.BillingCountryCode = 'CAN';
		        productRegistrationForPolyscienceObj.dummyAccount.BillingStateCode = 'NL';
		        productRegistrationForPolyscienceObj.registrationSave();
		        
		        //PurchasedDate
		        productRegistrationForPolyscienceObj.regionCode = 'US';
		        productRegistrationForPolyscienceObj.dummyAccount.BillingCountryCode = 'US';
		        productRegistrationForPolyscienceObj.dummyAccount.BillingStateCode = 'CO';
		        productRegistrationForPolyscienceObj.asset.PurchaseDate = Date.today().addDays(1);
		        productRegistrationForPolyscienceObj.registrationSave();
		        
		        
		Test.stoptest();
		// Verify response received 
	   // System.assertEquals(true, success);
	}
}