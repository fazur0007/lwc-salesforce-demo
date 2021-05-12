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
global  with sharing class ProductRegistrationControllerTest 
{
	static testMethod void testMethodProductRegistrationControllerPositiveTest(){
		Test.starttest();
	         PageReference pageRef = Page.productRegistration;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         pageRef.getParameters().put('product', 'TEST_AX' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        ProductRegistrationController productRegistrationControllerObj = new ProductRegistrationController();
		     	productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
		        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
		        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
		        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
		        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
		        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
		        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
		        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
		        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
		        productRegistrationControllerObj.confirmEmail = 'test@example.com';
		        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationControllerObj.asset.PurchaseDate = date.today();
		        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
		        
		       // Product2 product = TestDataFactory.createProduct('Prod', false, true);
		       	//Insert Product2
        		Product2 product = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
        												Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TEST_AX'); 
        		insert product;  
        		 productRegistrationControllerObj.selectedProduct = product.Id;
		        //Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        
		        //insert offer
		        Offer__c offerRecord = new Offer__c();
		        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
		        offerRecord.OfferCode__c = 'HBE7';
		        offerRecord.MatchOfferfromNCharacter__c = 7;
		        offerRecord.TotalLengthofOfferCode__c = 12;
		        offerRecord.MultipleProducts__c = ';TEST_AX;';
		        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
		       // offerRecord.CurrencyIsoCode = 'USD';
		        offerRecord.Active__c = True ;
		        offerRecord.MatchOfferCode__c = true;
		        insert offerRecord; 
		        system.debug('--offer--'+offerRecord);
		        
		       // productRegistrationControllerObj.asset.AccountId = accountObj.Id;
		        productRegistrationControllerObj.asset.Product2Id = product.Id;
		        productRegistrationControllerObj.objCase.Batch_Code__c = null;
		        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
		        productRegistrationControllerObj.asset.ExactOfferCode__c ='HBE7';
		        productRegistrationControllerObj.asset.Offer_Code_Applied__c ='123456HBE789';
		       // productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
				
        
		        productRegistrationControllerObj.registrationSave();
		        productRegistrationControllerObj.validateCountry();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	static testMethod void testMethodPrdRegCtrlOfferCodeGenSeq(){
		Test.starttest();
	         PageReference pageRef = Page.productRegistration;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'de' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        ProductRegistrationController productRegistrationControllerObj = new ProductRegistrationController(); 
        		productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
		        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
		        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
		        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
		        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
		        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
		        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
		        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
		        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
		        productRegistrationControllerObj.confirmEmail = 'test@example.com';
		        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationControllerObj.asset.PurchaseDate = date.today();
		        productRegistrationControllerObj.asset.ExactOfferCode__c= 'UK_OFFER_01';
		        
		       // Product2 product = TestDataFactory.createProduct('Prod', false, true);
		       	//Insert Product2
        		Product2 product = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
        												Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TEST_AX'); 
        		insert product;  
        		productRegistrationControllerObj.selectedProduct = product.Id;
		        //Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        
		        //insert offer
		        Offer__c offerRecord = new Offer__c();
		        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
		        offerRecord.OfferCode__c = 'UK_OFFER_01';
		        offerRecord.MultipleProducts__c = ';TEST_AX;';
		        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
		       // offerRecord.CurrencyIsoCode = 'USD';
		        offerRecord.Active__c = True ;
		        offerRecord.MatchOfferCode__c = false;
		        offerRecord.OfferCodeStart__c =1;
		        offerRecord.OfferCodeEnd__c = 100;
		        offerRecord.SequentialCounter__c = 1;
		        offerRecord.TotalLengthofOfferCode__c = 10;
		        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
		        offerRecord.RecordTypeId = recordTypeId;
		        insert offerRecord; 
		        system.debug('--offer--'+offerRecord);
		        
		       // productRegistrationControllerObj.asset.AccountId = accountObj.Id;
		        productRegistrationControllerObj.asset.Product2Id = product.Id;
		        productRegistrationControllerObj.objCase.Batch_Code__c = null;
		        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
		       // productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
				
        
		        productRegistrationControllerObj.registrationSave();
		        productRegistrationControllerObj.validateCountry();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'UK_OFFER_01');
	}
	
	static testMethod void testMethodPrdRegCtrlNegativeTestInValidCountry(){
		Test.starttest();
	         PageReference pageRef = Page.productRegistration;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         //pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        ProductRegistrationController productRegistrationControllerObj = new ProductRegistrationController();
		        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationControllerObj.asset.PurchaseDate = date.today();
		        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
		        
		       // Product2 product = TestDataFactory.createProduct('Prod', false, true);
		       	//Insert Product2
        		Product2 product = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
        												Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TEST_AX'); 
        		insert product;  
        		 productRegistrationControllerObj.selectedProduct = product.Id;
		        //Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        
		        productRegistrationControllerObj.registrationSave();
		        productRegistrationControllerObj.validateCountry();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(productRegistrationControllerObj.asset.Id, null);
	}
	
	static testMethod void testMethodPrdRegCtrlNegativeTestRequiredField(){
		Test.starttest();
	         PageReference pageRef = Page.productRegistration;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        ProductRegistrationController productRegistrationControllerObj = new ProductRegistrationController();
		        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
		        productRegistrationControllerObj.asset.PurchaseDate = date.today();
		        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
		        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
		        
		       // Product2 product = TestDataFactory.createProduct('Prod', false, true);
		       	//Insert Product2
        		Product2 product = new Product2(Name= '28L ALL SS TANK IN SS CASE  PACKAGED',SKU__c='.505-239',Warranty_In_Months__c=15,
        												Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TEST_AX'); 
        		insert product;  
        		 productRegistrationControllerObj.selectedProduct = product.Id;
		        //Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        
		        productRegistrationControllerObj.registrationSave();
		        productRegistrationControllerObj.validateCountry();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(productRegistrationControllerObj.asset.Id, null);
	}
	
	static testMethod void testMethodProductRegistrationControllerNegativeTest(){
		Test.starttest();
	         PageReference pageRef = Page.productRegistration;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        ProductRegistrationController productRegistrationControllerObj1 = new ProductRegistrationController();
		     	productRegistrationControllerObj1.acct.FirstName = null;
		        productRegistrationControllerObj1.acct.LastName = null;
		        productRegistrationControllerObj1.acct.BillingStreet = null;
		        productRegistrationControllerObj1.personBillingStreet2 = null;
		        productRegistrationControllerObj1.acct.BillingCity = null;
		        productRegistrationControllerObj1.acct.BillingState = null;
		        productRegistrationControllerObj1.acct.BillingPostalCode = null;
		        productRegistrationControllerObj1.acct.PersonEmail = null;
		        productRegistrationControllerObj1.acct.BillingCountryCode = null;
		        productRegistrationControllerObj1.acct.BillingStateCode = null;
		        productRegistrationControllerObj1.confirmEmail = null;
		        productRegistrationControllerObj1.selectedSubCategory = null;
		        productRegistrationControllerObj1.asset.PurchaseDate = null;
		        productRegistrationControllerObj1.asset.Batch_Code__c = '1620';
		        productRegistrationControllerObj1.asset.AccountId = null;
		        productRegistrationControllerObj1.asset.Product2Id = null;
		        productRegistrationControllerObj1.objCase.Batch_Code__c = null;
		        productRegistrationControllerObj1.objCase.Purchased_From__c =null;
		        
		        productRegistrationControllerObj1.registrationSave();
		        productRegistrationControllerObj1.validateCountry();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethodProductRegistrationControllerNegativeTest1(){
		Test.starttest();
	         PageReference pageRef = Page.productRegistration;
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
		      /*  Asset assetObj = new Asset();
		        assetObj.Name = 'Ravi Verma';
		        assetObj.Batch_Code__c = '1620';
		        assetObj.PurchaseDate = Date.today();
		        assetObj.Product2Id = product.Id ;
		        assetObj.Warranty_In_Months__c = 15;
		        assetObj.AccountId = accountObj.Id;
		        insert assetObj;*/
	        
			          
		        //Insert Asset
		        Asset assetObj = new Asset();
		        assetObj.Name = 'Ravi Verma';
		        assetObj.Batch_Code__c = '1620';
		        assetObj.PurchaseDate = date.today();
		        assetObj.Product2Id = product.Id ;
		        assetObj.Warranty_In_Months__c = 15;
		        assetObj.AccountId = accountObj.Id;
		        assetObj.ExactOfferCode__c ='HBE7';
		        insert assetObj;
		        
		        //insert offer 
		        Offer__c offerRecord = new Offer__c();
		        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
		        offerRecord.OfferCode__c = 'HBE7';
		        offerRecord.MatchOfferfromNCharacter__c = 1;
		        insert offerRecord; 
		        
		         //insert offer order
		        Offer_Order__c offerOrderRecord = new Offer_Order__c();
		        offerOrderRecord.ActivateOrderOnNDay__c = 0;
		        offerOrderRecord.Offer__c = offerRecord.id;
		        //offerOrderRecord.TriggerDeliveryEmailAfterNDay__c = 1;
		        insert offerOrderRecord; 
		        
		        //insert offer order items
		        Offer_Order_Items__c offerOrderItemsRecord = new Offer_Order_Items__c();
		        offerOrderItemsRecord.Offer_Order__c = offerOrderRecord.id;
		        offerOrderItemsRecord.Product__c = product.Id ;
		        offerOrderItemsRecord.Quantity__c = 2;
		        insert offerOrderItemsRecord; 
		        
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         	
		        ProductRegistrationController productRegistrationControllerObj1 = new ProductRegistrationController();
		     	productRegistrationControllerObj1.acct = accountObj;
		     	productRegistrationControllerObj1.dummyAccount = accountObj;
		        productRegistrationControllerObj1.personBillingStreet2 = '123 test street 2';
		        productRegistrationControllerObj1.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        productRegistrationControllerObj1.selectedSubCategory = 'I dont see my product';
		        productRegistrationControllerObj1.asset.PurchaseDate = Date.today();
		        productRegistrationControllerObj1.asset.Batch_Code__c = null;
		        productRegistrationControllerObj1.asset.AccountId = null;
		        productRegistrationControllerObj1.asset.Product2Id = product.id;
		        productRegistrationControllerObj1.objCase.Batch_Code__c = null;
		        productRegistrationControllerObj1.objCase.Purchased_From__c ='Amazon';
		        
		        productRegistrationControllerObj1.fetchProducts();
		        productRegistrationControllerObj1.registrationSave();
		        
		        //When personalEmail!=confirmEmail
		        productRegistrationControllerObj1.confirmEmail = 'raveena@persistent.co.in';
		        productRegistrationControllerObj1.registrationSave();
		        
		        //BillingStreet
		        productRegistrationControllerObj1.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        productRegistrationControllerObj1.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)134 KENT ST. (CONF.COURT MALL)';
		        productRegistrationControllerObj1.registrationSave();
		        
		        //Billing postal code
		        productRegistrationControllerObj1.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        productRegistrationControllerObj1.regionCode = 'CAN';
		        productRegistrationControllerObj1.dummyAccount.BillingCountryCode = 'CAN';
		        productRegistrationControllerObj1.dummyAccount.BillingStateCode = 'NL';
		        productRegistrationControllerObj1.registrationSave();
		        
		        //PurchasedDate
		        productRegistrationControllerObj1.regionCode = 'US';
		        productRegistrationControllerObj1.dummyAccount.BillingCountryCode = 'US';
		        productRegistrationControllerObj1.dummyAccount.BillingStateCode = 'CO';
		        productRegistrationControllerObj1.asset.PurchaseDate = Date.today().addDays(1);
		        productRegistrationControllerObj1.registrationSave();
		        
		        
		Test.stoptest();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('The following required field(s) are required and missing')) {
                 b = true;
            }
        }
        system.assert(b);
	}
     
}