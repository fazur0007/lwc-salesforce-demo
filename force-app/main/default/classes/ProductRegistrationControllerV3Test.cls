@isTest
global  with sharing class ProductRegistrationControllerV3Test 
{
    static testMethod void testMethodProductRegistrationControllerPositiveTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  

        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('product','SCG820BTR');
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
		productRegistrationControllerObj.dummyAccount.Phone='1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
       	productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
                
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
        
    }
    
    static testMethod void testMethodProductRegistrationControllerPositiveTestForMultipleProductCode(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  

        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('product','SCG820BTR,SCG820BSS');
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
       	productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
                
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }

    static testMethod void testMethodProductRegistrationControllerPositiveTestWithCategory(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  

        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('category', 'Compact Ovens');
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
       	productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
                
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodProductRegistrationControllerPositiveTestWithCategoryAndProductCode(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  

        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('product','SCG820BTR,SCG820BSS');
        pageRef.getParameters().put('category', 'Compact Ovens');
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
       	productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
                
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodProductRegistrationControllerDuplicateAssetTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('product', 'SCG820BTR');
        pageRef.getParameters().put('category', 'Compact Ovens');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        
        productRegistrationControllerObj.registrationSave();
        PageReference p = productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(null, p);
    }
    
    static testMethod void testMethodProductRegistrationControllerMissingFieldsTest(){
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('language', 'en_US');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.registrationSave();
        Test.stoptest();
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodProductRegistrationControllerValidateCountryTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'Uk';
        productRegistrationControllerObj.registrationSave();
        productRegistrationControllerObj.validateCountry();
        Test.stoptest();
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodProductRegistrationControllerHomePageRedirectTest(){
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'CA');
        pageRef.getParameters().put('language', 'fr' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        PageReference p = productRegistrationControllerObj.homePageRedirect();
        Test.stoptest();
        System.assertEquals('https://www.breville.com/', p.getUrl());
    }
    
    static testMethod void testMethodProductRegistrationControllerInvalidBatchCodeTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1760';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';     
        
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(false,productRegistrationControllerObj.isSuccess);
        
    }

    static testMethod void testMethodProductRegistrationControllerAttachmentTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();        
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.AttachName = 'abcd.jpeg';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'image/jpeg';
        
        
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
        
    }
    
    static testMethod void testMethodProductRegistrationControllerInvalidAttachmentTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'fr' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720'; 
		productRegistrationControllerObj.asset.PurchaseDate = date.today();     
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.AttachName = 'abcd.txt';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'text/plain';
        
        
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
        
    }
    
    /*static testMethod void testMethodProductRegistrationControllerInvalidProductTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'fr' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
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
        // productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        Asset testAsset = new Asset();
        testAsset.Batch_Code__c = '1720';
        testAsset.PurchaseDate = system.today();
        productRegistrationControllerObj.asset = testAsset;
        Product2 product4 = TestDataFactory.createProduct('Prod4', false, true);
        //Insert Product4;
        
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        
        
        
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
        
    }*/
    
    static testMethod void testMethodProductRegistrationControllerSerialNumberTest(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, 
                                        Brand__c='Breville', Serial_Required_for_Registration__c = true); 
        insert product;  
        Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en' );
        pageRef.getParameters().put('brand', 'Breville');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';       
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        
        
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
        
    }
    
    static testMethod void testMethodPrdRegCtrlWithoutOfferCodeAppliedWithReceipt(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
        productRegistrationControllerObj.AttachName = 'abcd.jpeg';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'image/jpeg';
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = false;
        offerRecord.OfferCodeStart__c =1;
        offerRecord.OfferCodeEnd__c = 100;
        offerRecord.SequentialCounter__c = 1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        offerRecord.TnC_Link__c = 'TestingLink';//Added for CheckOffer()
        offerRecord.Offer_Welcome_Message__c='Congratulations..!!';
        offerRecord.PageHeader__c = 'TestingHeader';
        offerRecord.Banner_Link__c = 'test_banner_link';
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        insert offerRecord; 
        system.debug('--Get offer--'+offerRecord);
        
        productRegistrationControllerObj.checkOffer(); 
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'UK_OFFER_01');
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
        
    static testMethod void testMethodPrdRegCtrlWithoutOfferCodeAppliedWithoutReceipt(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
       // productRegistrationControllerObj.asset.Offer_Code_Applied__c = '';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = false;
        offerRecord.OfferCodeStart__c =1;
        offerRecord.OfferCodeEnd__c = 100;
        offerRecord.SequentialCounter__c = 1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        offerRecord.TnC_Link__c = 'TestingLink';//Added for CheckOffer()
        offerRecord.Offer_Welcome_Message__c='Congratulations..!!';
        offerRecord.PageHeader__c = 'TestingHeader';
        offerRecord.Banner_Link__c = 'test_banner_link';
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        insert offerRecord; 
        system.debug('--Get offer--'+offerRecord);
        
        productRegistrationControllerObj.checkOffer(); 
        productRegistrationControllerObj.registrationSave();
        Test.stoptest();
        // Verify response received 
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodPrdRegCtrlWithoutOfferCodeAppliedContinueWithoutReceipt(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
       // productRegistrationControllerObj.asset.Offer_Code_Applied__c = '';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = false;
        offerRecord.OfferCodeStart__c =1;
        offerRecord.OfferCodeEnd__c = 100;
        offerRecord.SequentialCounter__c = 1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        offerRecord.TnC_Link__c = 'TestingLink';//Added for CheckOffer()
        offerRecord.Offer_Welcome_Message__c='Congratulations..!!';
        offerRecord.PageHeader__c = 'TestingHeader';
        offerRecord.Banner_Link__c = 'test_banner_link';
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        insert offerRecord; 
        system.debug('--Get offer--'+offerRecord);
        
        productRegistrationControllerObj.checkOffer(); 
        productRegistrationControllerObj.registrationSave();
        productRegistrationControllerObj.continueWithoutReceipt();
        Test.stoptest();
        // Verify response received 
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodPrdRegCtrlWithOfferCodeAppliedWithReceipt(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.Offer_Code_Applied__c = 'USAOFFER20';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
        productRegistrationControllerObj.AttachName = 'abcd.jpeg';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'image/jpeg';
        productRegistrationControllerObj.continueWithoutOffer= False;
        //insert offer-1
        List<Offer__c> offerRecordList = new List<Offer__c>();
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'USAOFFER20';        
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = True;
        offerRecord.MatchOfferfromNCharacter__c =1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        offerRecordList.add(offerRecord);
        
        //insert offer-2
        Offer__c offerRecord1 = new Offer__c();
        offerRecord1.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord1.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord1.CurrencyIsoCode = 'USD';
        offerRecord1.Active__c = True ;
        offerRecord1.MatchOfferCode__c = false;
        offerRecord1.OfferCodeStart__c =1;
        offerRecord1.OfferCodeEnd__c = 100;
        offerRecord1.SequentialCounter__c = 1;
        offerRecord1.TotalLengthofOfferCode__c = 10;
        offerRecord1.PurchaseStartDate__c = Date.today();
        offerRecord1.PurchaseEndDate__c = Date.today() + 365;
        Id recordTypeId1 = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord1.RecordTypeId = recordTypeId1;
        offerRecordList.add(offerRecord1);
        
        insert offerRecordList; 
        
        productRegistrationControllerObj.checkOffer();
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'USAOFFER20;UK_OFFER_01');
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodPrdRegCtrlWithOfferCodeAppliedWithReceiptAttachedLater(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.Offer_Code_Applied__c = 'USAOFFER20';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
        
        productRegistrationControllerObj.continueWithoutOffer= False;
        //insert offer-1
        List<Offer__c> offerRecordList = new List<Offer__c>();
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'USAOFFER20';        
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = True;
        offerRecord.MatchOfferfromNCharacter__c =1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        offerRecordList.add(offerRecord);
        
        //insert offer-2
        Offer__c offerRecord1 = new Offer__c();
        offerRecord1.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord1.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord1.CurrencyIsoCode = 'USD';
        offerRecord1.Active__c = True ;
        offerRecord1.MatchOfferCode__c = false;
        offerRecord1.OfferCodeStart__c =1;
        offerRecord1.OfferCodeEnd__c = 100;
        offerRecord1.SequentialCounter__c = 1;
        offerRecord1.TotalLengthofOfferCode__c = 10;
        offerRecord1.PurchaseStartDate__c = Date.today();
        offerRecord1.PurchaseEndDate__c = Date.today() + 365;
        Id recordTypeId1 = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord1.RecordTypeId = recordTypeId1;
        offerRecordList.add(offerRecord1);
        
        insert offerRecordList; 
        
        productRegistrationControllerObj.checkOffer();
        PageReference returnPageRef=productRegistrationControllerObj.registrationSave();
        if(returnPageRef==null){
            productRegistrationControllerObj.closePopup();
            productRegistrationControllerObj.AttachName = 'abcd.jpeg';
            productRegistrationControllerObj.AttachBody = 'XAWEC';
            productRegistrationControllerObj.AttachType = 'image/jpeg';
            productRegistrationControllerObj.registrationSave();
        }
        
        Test.stoptest();
        // Verify response received 
        System.assertEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'USAOFFER20;UK_OFFER_01');
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodPrdRegCtrlWithOfferCodeAppliedWithoutReceipt(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.Offer_Code_Applied__c = 'USAOFFER20';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';
        productRegistrationControllerObj.continueWithoutOffer= False;
        //insert offer-1
        List<Offer__c> offerRecordList = new List<Offer__c>();
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'USAOFFER20';        
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = True;
        offerRecord.MatchOfferfromNCharacter__c =1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        offerRecordList.add(offerRecord);
        
        //insert offer-2
        Offer__c offerRecord1 = new Offer__c();
        offerRecord1.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord1.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord1.CurrencyIsoCode = 'USD';
        offerRecord1.Active__c = True ;
        offerRecord1.MatchOfferCode__c = false;
        offerRecord1.OfferCodeStart__c =1;
        offerRecord1.OfferCodeEnd__c = 100;
        offerRecord1.SequentialCounter__c = 1;
        offerRecord1.TotalLengthofOfferCode__c = 10;
        offerRecord1.PurchaseStartDate__c = Date.today();
        offerRecord1.PurchaseEndDate__c = Date.today() + 365;
        Id recordTypeId1 = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord1.RecordTypeId = recordTypeId1;
        offerRecordList.add(offerRecord1);
        
        insert offerRecordList; 
        
        productRegistrationControllerObj.checkOffer();
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
    }
    
    
	static testMethod void testMethodPrdRegCtrlInvalidOfferCode(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, Brand__c='Breville'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'en-US' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'US';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.asset.Offer_Code_Applied__c = 'USAOFFER20';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'USD';

        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertEquals(false, productRegistrationControllerObj.isSuccess);
    }
    
        
    /*static testMethod void testProductRegistrationControllerURL(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, 
                                        Brand__c='Breville', Serial_Required_for_Registration__c = true); 
        insert product;  */
        
        /*  List<Asset> asstlst= new List<Asset>();
asstlst.id=
asstlst.ExactOfferCode__c=
asstlst.Offer_Code_Applied__c=
asstlst.accountid=: acct.Id*/
        
       /* Test.starttest();
        PageReference pageRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'fr' );
        pageRef.getParameters().put('brand', 'Breville');
        pageRef.getParameters().put('category', 'Compact Ovens');	
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'AB';
        productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.Batch_Code__c = '1720';
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.ExactOfferCode__c ='UKE1';
        productRegistrationControllerObj.asset.Offer_Code_Applied__c = '123456HBE789';
        //productRegistrationControllerObj.asset.Offer_Code_Applied__c=: asset.Offer_Code_Applied__c;
        Account acc=new account();
        productRegistrationControllerObj.asset.accountid = acc.id;
        productRegistrationControllerObj.asset.Product2id = product.Id;
        Product2 product6 = TestDataFactory.createProduct('Prod6', false, true);
        //Insert product6;
        
        productRegistrationControllerObj.selectedProduct = product.Id;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        
        
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
        
    }*/
    
    static testMethod void testMethodfetchBusinessUnitFromCountryCode(){
         Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, 
                                        Brand__c='Breville', Serial_Required_for_Registration__c = true); 
        insert product;  
	
                   Product2 producttest = new Product2(Name= '.505-238',Description = '28L ALL SS TANK IN SS CASE  PACKAGED 1', SKU__c='.505-238',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber1',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, 
                                        Brand__c='Breville', Serial_Required_for_Registration__c = true , Product_Sub_Family__c = 'Beverage Accessories'); 
        insert producttest; 
         
         Test.starttest();
 
         Utility.getPickValues(new Case(),'Type',null);
         Utility.fetchBusinessUnitFromCountryCode('AUS');
         Utility.getLanguageCodeFromLanguage('French');
          Utility.getLanguageCodeFromLanguage('Italian');
         Utility.getLanguageCodeFromLanguage('German');
          Utility.getLanguageCodeFromLanguage('Spanish');
          Utility.getLanguageCodeFromLanguage('Dutch');
          Utility.getLanguageCodeFromLanguage('Portuguese');
         Utility.getLanguageFromLanguageCode('nl');
             Utility.getLanguageFromLanguageCode('es');
             Utility.getLanguageFromLanguageCode('pt');
         Utility.fetchRegionCodeFromEPRegionAPI('AU');
         Utility.fetchBusinessUnitEPRegionAPI('AU');
         Utility.fetchCurrencyCodeFromEPRegionAPI('AU');
         Utility.fetchAccountDetailsFromRegion('AUS');
         Utility.getOrderFieldMappingForCase();
         Utility.getBusinessUnits() ;
         Utility.fetchEPParameterFromCountry('USA');
         Utility.fetchRegionCodeFromCountry('AU');
         Utility.fetchCurrencyCodeFromCountry('AU');
     User userObj = Utility.createUserRecord('Accounting Admin', 'USD', 'test@gmail.com');
         //Utility.updateUser(userObj, 'FirstName', 'test', 'test@gmail.com');
          Utility.createAccountRecord('FirstName', 'test', 'test@gmail.com');
          Account accountObj= TestDataFactory.createAccountRecord('Joe', true);
         Utility.createContactRecord(accountObj.Id, 'FirstName','test', 'test@gmail.com');
         Utility.currencyBasedRegions('USA');
         Utility.fetchBusinessUnitEPRegion('AU');
          Utility.fetchBusinessUnitFromCurrencyCode('USD');
         Utility.regionBased('USD');
          Utility.fetchLanguageCodeFromCountryCode('USD');
          Utility.createUserShare(accountObj.Id, userObj.Id);
          Utility.fetchAllLiteralValue('Product_Registration');
         Utility.findExistingAccountWithID(accountObj.ID);
         
        Case lstCase = TestDataFactory.createCase(accountObj.Id, 'Phone', 'Open', 'Test RMA EUR', 'USD', false);
        lstCase.AccountId=accountObj.Id;
        lstCase.Purchase_Invoice_No__c='12345';
        insert lstCase;
         
         Set<String> plmStatusNotStartsWith = new Set<String>{'01%', '00%', '99%','04%'};
         Utility.createBoxOrderRecordFromCase(lstCase.Id);
        // Utility.createOrder(lstCase);
         Utility.fetchAccountDetailsFromRegion('USA');
         Utility.getOrderFieldMappingForCase();
          Utility.fetchPurchasedFrom('PublicGroup');
         Utility.fetchCaseTypes('PublicGroup');
          Utility.fetchProductSubcategories('USA', 'Breville',plmStatusNotStartsWith ,'AX_Item_Number__c =\'TestAXNumber\' ','en_GB');
        map<Id, String> mapBlanck = new map<Id, String>();
          Utility.fetchAllProducts('USA', 'Breville','01%',  '', mapBlanck, 'en_GB');
         Utility.fetchProductSubcategories('USA', 'Breville',plmStatusNotStartsWith ,'AX_Item_Number__c =\'TestAXNumber1\' ','en');
        map<Id, String> mapBlanck1 = new map<Id, String>();
          Utility.fetchAllProducts('USA', 'Breville','01%',  '', mapBlanck1, 'en_GB');
         
        Test.stoptest();
    }
    
    /*static testMethod void testProductRegistrationControllerErrorURL(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, 
                                        Brand__c='Breville', Serial_Required_for_Registration__c = true); 
        insert product;  
        
        Test.starttest();
        PageReference pageerrorRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageerrorRef);
        pageerrorRef.getParameters().put('param', 'US');
        pageerrorRef.getParameters().put('language', 'fr' );
        pageerrorRef.getParameters().put('brand', 'Breville');
        pageerrorRef.getParameters().put('category', 'Compact Ovens');	
        ProductRegistrationControllerV3 productRegistrationControllererrorObj = new ProductRegistrationControllerV3();
        productRegistrationControllererrorObj.dummyAccount.FirstName = '';
        productRegistrationControllererrorObj.dummyAccount.LastName = '';
        productRegistrationControllererrorObj.dummyAccount.BillingStreet = '';
        productRegistrationControllererrorObj.personBillingStreet2 = '';
        productRegistrationControllererrorObj.dummyAccount.BillingCity = '';
        productRegistrationControllererrorObj.dummyAccount.BillingPostalCode = '';
        productRegistrationControllererrorObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllererrorObj.dummyAccount.BillingCountryCode = '';
        productRegistrationControllererrorObj.dummyAccount.BillingStateCode = '';
        productRegistrationControllererrorObj.confirmEmail = 'test@example.com';
        productRegistrationControllererrorObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllererrorObj.asset.Batch_Code__c = '';
        productRegistrationControllererrorObj.objCase.Purchased_From__c = '';
        productRegistrationControllererrorObj.asset.ExactOfferCode__c ='UKE1';
        //productRegistrationControllererrorObj.asset.Offer_Code_Applied__c = '123456HBE789';
        //productRegistrationControllerObj.asset.Offer_Code_Applied__c=: asset.Offer_Code_Applied__c;
        Account acc=new account();
        productRegistrationControllererrorObj.asset.accountid = acc.id ;
         Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'HBE7';
        offerRecord.MatchOfferfromNCharacter__c = 7;
        offerRecord.TotalLengthofOfferCode__c = 12;
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'USD';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = true;
        offerRecord.PurchaseStartDate__c = Date.today();
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        offerRecord.Batch_Code_Start__c = 1705;
        offerRecord.Batch_Code_End__c = 2019;
        offerRecord.TnC_Link__c = 'TestingLink';
        offerRecord.PageHeader__c = 'TestingHeader';
        insert offerRecord; 
        system.debug('--offer--'+offerRecord);
        
        // productRegistrationControllerObj.asset.AccountId = accountObj.Id;
        productRegistrationControllererrorObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllererrorObj.asset.ExactOfferCode__c ='HBE7';
        //productRegistrationControllererrorObj.asset.Offer_Code_Applied__c ='123456HBE789';
        productRegistrationControllererrorObj.asset.CurrencyIsoCode = 'USD';
        productRegistrationControllererrorObj.asset.Product2id = product.Id;
        
        Product2 product6 = TestDataFactory.createProduct('Prod6', false, true);
        //Insert product6;
        
        productRegistrationControllererrorObj.objCase.Purchased_From__c = 'test';
        
        //productRegistrationControllererrorObj.checkFields();
        productRegistrationControllererrorObj.registrationSave();
        
        Test.stoptest();
        //System.assertEquals(true, productRegistrationControllererrorObj.isSuccess);
        
    }*/

    static testMethod void testMethodsetRegistrationNote(){
        Test.startTest();
        
        PageReference pageerrorRef = Page.productRegistrationWeb;
        Test.setCurrentPage(pageerrorRef);
        pageerrorRef.getParameters().put('param', 'US');
        pageerrorRef.getParameters().put('language', 'en' );
        pageerrorRef.getParameters().put('brand', 'Breville');
        pageerrorRef.getParameters().put('category', 'Compact Ovens');
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.setRegistrationNote();
        
        Test.stopTest();
    }
    
    static testMethod void testMethodWithInvalidOfferApplicableCountries(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='DE',Exclude_from_Sync__c = false, Brand__c='Sage'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'DE');
        pageRef.getParameters().put('language', 'de' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'LU';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        //productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1920';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'Amazon';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'EUR';
        productRegistrationControllerObj.AttachName = 'abcd.jpeg';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'image/jpeg';
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'EUR';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = false;
        offerRecord.OfferCodeStart__c =1;
        offerRecord.OfferCodeEnd__c = 100;
        offerRecord.SequentialCounter__c = 1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.TnC_Link__c = 'TestingLink';//Added for CheckOffer()
        offerRecord.Offer_Welcome_Message__c='Congratulations..!!';
        offerRecord.PageHeader__c = 'TestingHeader';
        offerRecord.Banner_Link__c = 'test_banner_link';
        offerRecord.Applicable_Countres__c= ';AT;BE;DE;NL;FR;';
        //offerRecord.Batch_Code_Start__c = 1920;
        //offerRecord.Batch_Code_End__c = 1922;
        
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        insert offerRecord; 
        system.debug('--Get offer--'+offerRecord);
        
        productRegistrationControllerObj.checkOffer(); 
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertNotEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'UK_OFFER_01');
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodWithInvalidOfferPurchaseDate(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='DE',Exclude_from_Sync__c = false, Brand__c='Sage'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'DE');
        pageRef.getParameters().put('language', 'de' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'LU';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        //productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1920';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'Amazon';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'EUR';
        productRegistrationControllerObj.AttachName = 'abcd.jpeg';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'image/jpeg';
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'EUR';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = false;
        offerRecord.OfferCodeStart__c =1;
        offerRecord.OfferCodeEnd__c = 100;
        offerRecord.SequentialCounter__c = 1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.PurchaseStartDate__c = Date.today() + 1;
        offerRecord.PurchaseEndDate__c = Date.today() + 365;
        offerRecord.TnC_Link__c = 'TestingLink';//Added for CheckOffer()
        offerRecord.Offer_Welcome_Message__c='Congratulations..!!';
        offerRecord.PageHeader__c = 'TestingHeader';
        offerRecord.Banner_Link__c = 'test_banner_link';
        
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        insert offerRecord; 
        system.debug('--Get offer--'+offerRecord);
        
        productRegistrationControllerObj.checkOffer(); 
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertNotEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'UK_OFFER_01');
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    static testMethod void testMethodWithInvalidOfferPurchasePlace(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='DE',Exclude_from_Sync__c = false, Brand__c='Sage'); 
        insert product;  
        
        Test.starttest();
        PageReference pageRef = Page.productRegistration;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('param', 'DE');
        pageRef.getParameters().put('language', 'de' );
		pageRef.getParameters().put('brand', 'Breville');
        
        //Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
        //GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
        //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
        pageRef.getParameters().put('product', product.AX_Item_Number__c);
        
        ProductRegistrationControllerV3 productRegistrationControllerObj = new ProductRegistrationControllerV3();
        productRegistrationControllerObj.dummyAccount.FirstName = 'Joe';
        productRegistrationControllerObj.dummyAccount.LastName = 'Bob';
        productRegistrationControllerObj.dummyAccount.BillingStreet = '123 test st';
        productRegistrationControllerObj.personBillingStreet2 = '123 test street 2';
        productRegistrationControllerObj.dummyAccount.BillingCity = 'Denver';
        productRegistrationControllerObj.dummyAccount.BillingPostalCode = '80002';
        productRegistrationControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        productRegistrationControllerObj.dummyAccount.BillingCountryCode = 'LU';
        productRegistrationControllerObj.dummyAccount.Phone = '1234567890';
        //productRegistrationControllerObj.dummyAccount.BillingStateCode = 'CA';
        productRegistrationControllerObj.confirmEmail = 'test@example.com';
        productRegistrationControllerObj.selectedSubCategory = 'I dont see my product';
        productRegistrationControllerObj.asset.PurchaseDate = date.today();
        productRegistrationControllerObj.asset.Batch_Code__c = '1920';
        productRegistrationControllerObj.asset.Product2Id = product.Id; 
       	productRegistrationControllerObj.selectedProduct = product.Id; 
        productRegistrationControllerObj.objCase.Batch_Code__c = null;
        productRegistrationControllerObj.objCase.Purchased_From__c = 'test';
        productRegistrationControllerObj.asset.CurrencyIsoCode = 'EUR';
        productRegistrationControllerObj.AttachName = 'abcd.jpeg';
        productRegistrationControllerObj.AttachBody = 'XAWEC';
        productRegistrationControllerObj.AttachType = 'image/jpeg';
        
        //insert offer
        Offer__c offerRecord = new Offer__c();
        offerRecord.MultipleProducts__c =  ';'+product.AX_Item_Number__c+';';
        offerRecord.OfferCode__c = 'UK_OFFER_01';        
        //offerRecord.RecordtypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Generate Offer Code').getRecordTypeId();
        offerRecord.CurrencyIsoCode = 'EUR';
        offerRecord.Active__c = True ;
        offerRecord.MatchOfferCode__c = false;
        offerRecord.OfferCodeStart__c =1;
        offerRecord.OfferCodeEnd__c = 100;
        offerRecord.SequentialCounter__c = 1;
        offerRecord.TotalLengthofOfferCode__c = 10;
        offerRecord.TnC_Link__c = 'TestingLink';//Added for CheckOffer()
        offerRecord.Offer_Welcome_Message__c='Congratulations..!!';
        offerRecord.PageHeader__c = 'TestingHeader';
        offerRecord.Banner_Link__c = 'test_banner_link';
        offerRecord.Purchased_From__c='Amazon';
        
        Id recordTypeId = Schema.SObjectType.Offer__c.getRecordTypeInfosByName().get('Normal Offer').getRecordTypeId();
        offerRecord.RecordTypeId = recordTypeId;
        insert offerRecord; 
        system.debug('--Get offer--'+offerRecord);
        
        productRegistrationControllerObj.checkOffer(); 
        productRegistrationControllerObj.registrationSave();
        
        Test.stoptest();
        // Verify response received 
        System.assertNotEquals(productRegistrationControllerObj.asset.ExactOfferCode__c, 'UK_OFFER_01');
        System.assertEquals(true, productRegistrationControllerObj.isSuccess);
    }
    
    
}