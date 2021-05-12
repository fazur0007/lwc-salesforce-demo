@isTest
private class WebToCaseForFastSlowCookerControllerTest {
    
    static RecordType personAccount, newCase, newCaseCAN;
    static Account acct;
    static Product2 childProduct, objProduct,objProduct1;
    static User objUser;
    public static List<SelectOption> result;
    static PageReference pageRef, pageRef2, pageRef3, pageRef4, pageRef5, pageRef6, pageRef7, pageRef8, pageRef9;
    
    private static void testData_for_WebToCaseForFastSlowCookerControllerTest()
    {   
        //Create an BatchCodeValidationRequired__c Record
        BatchCodeValidationRequired__c objBatch = new BatchCodeValidationRequired__c();
        objBatch.Name = 'BatchValidationRule';
        objBatch.IsRuleCheck__c = true;
        insert objBatch; 
        /*
        CountryStateSetting__c States = new CountryStateSetting__c();
        States.Name = 'USA';
        States.States__c = 'CO';
        insert States;
        
        CountryStateSetting__c States2 = new CountryStateSetting__c();
        States2.Name = 'CAN';
        States2.States__c = 'CO';
        insert States2;
        */
        ProductSubCategory__c ProdCatg = new ProductSubCategory__c();
        ProdCatg.Name = 'SLOW COOKERS';
        ProdCatg.CategoryNameFrench__c = 'Mijoteuses';
        insert ProdCatg;
        
        ProductSubCategory__c ProdCatg1 = new ProductSubCategory__c();
        ProdCatg1.Name = 'Color';
        ProdCatg1.CategoryNameFrench__c = 'Color';
        insert ProdCatg1;
        
        personAccount = [SELECT Id
                         FROM RecordType
                         WHERE sObjectType = 'Account' 
                         AND Name = 'Person Account' 
                         AND IsActive = true limit 1];
                         
        // Create an Account Record                      
        acct = new Account();
        acct.RecordTypeId = personAccount.Id;
        acct.BillingPostalCode = '111111';
        acct.BillingStreet = 'new Street';
        acct.BillingCountryCode = 'US';
        acct.BillingStateCode ='GA';
        acct.FirstName = 'test1';
        acct.lastName = 'Test';
        acct.PersonEmail = 'm@test.org';
        acct.BillingStateCode = 'AZ';
        insert acct;
        
        // Create a Product Record
        objProduct = new Product2();
        objProduct.SKU__c = 'COOKER_SKU_USA';
        objProduct.Name = 'Fast Slow Cooker';
        objProduct.Family = 'MISC';
        objProduct.Product_Sub_Family__c = 'PRESSURE COOKERS';
        objProduct.Serial_Required_for_Registration__c = true;
        objProduct.Finished_Good__c = true;
        objproduct.Product_Classification__c = 'S';
        objProduct.Country_Code__c = 'USA';
        objProduct.Spare_Part__c = false;
        objProduct.Breville_US_Product__c = true;
        objProduct.IsActive = true;
        //objProduct.Product_Sub_Family__c = 'WOKS';
        insert objProduct;
        
        objProduct1 = new Product2();
        objProduct1.SKU__c = 'BREBPR600XL';
        objProduct1.Name = 'Fast Slow Cooker';
        objProduct1.Family = 'MISC';
        objProduct1.Product_Sub_Family__c = 'PRESSURE COOKERS';
        objProduct1.Serial_Required_for_Registration__c = true;
        objProduct1.Finished_Good__c = true;
        objProduct1.Product_Classification__c = 'S';
        objProduct1.Country_Code__c = 'CAN';
        objProduct1.Spare_Part__c = false;
        objProduct1.Breville_CAN_Product__c = true;
        objProduct1.IsActive = true;
        insert objProduct1;
        
        objUser = [Select id, FirstName FROM User WHERE UserType = 'Guest' limit 1];
    }
    
    //TestMethod for creating a New Account
    static testMethod void forNewAccount()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forNewAccount*********************************');
        //objWTC2.getstate();
        //objWTC2.setstate('CO');
        //objWTC2.enableEnglish();
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.PersonEmail = 'm@test.org';
        objWTC2.confirmEmail = 'm@test.org';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = 'New Street';
        objWTC2.acct.BillingCountryCode = 'US';
        objWTC2.acct.BillingStateCode = 'CO';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        //List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        //List<SelectOption> whereDoyouPurchaseFrom = objWTC2.whereDidYouPurchaseFrom;
        //objWTC2.state = 'CO';
        objWTC2.objCase.Batch_Code__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        //objWTC2.Attachbody = Blob.valueOf('testsdf');
        //objWTC2.Attachname = 'FILE NAME';
        objWTC2.Upload();
        //objWTC2.getIsSuccess();
        }
        
        pageRef2 = Page.WebToCaseForFastSlowCooker;
        pageRef2.getParameters().put('param','CA');
        Test.setCurrentPage(pageRef2);
        
        WebToCaseForFastSlowCookerController objWTC = new WebToCaseForFastSlowCookerController();
        system.debug('forNewAccount*********************************');
        //objWTC.getstate();
        //objWTC.setstate('AB');
        //objWTC.enableFrench();
        objWTC.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC.personBillingStreet2 = 'New Street';
        objWTC.acct.FirstName = 'Joe';
        objWTC.acct.LastName = 'Bob';
        objWTC.acct.RecordTypeId = personAccount.Id;
        objWTC.acct.BillingPostalCode = '111111';
        objWTC.acct.PersonEmail = 'm@test.org';
        objWTC.confirmEmail = 'm@test.org';
        objWTC.acct.BillingStreet = 'New Street';
        //List<selectOption> country = objWTC.getCountriesSelectList();
        //objWTC.country = 'CAN';
        //List<selectOption> stateOption = objWTC.getStateOptions2();
        objWTC.acct.BillingCountryCode = 'CA';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        objWTC.acct.BillingStateCode = 'MB';
        //objWTC.state = 'MB';
        objWTC.acct.BillingCountryCode = 'INDIA';
        objWTC.acct.ShippingCountryCode = 'INDIA';
        objWTC.acct.BillingCity = 'testCity';
        objWTC.objCase.Batch_Code__c = '1234';
        //objWTC.objCase.Original_PO_CASE_del__c = '1234';
        objWTC.registrationSave();
        //objWTC.registrationSaveAndAddAttachment();
        //objWTC.Attachbody = Blob.valueOf('testsdf');
        //objWTC.Attachname = 'FILE NAME';
        objWTC.Upload();
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','fr');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forNewAccount*********************************');
        //objWTC.setstate('MB');
        //objWTC1.enableEnglish();
        objWTC1.personBillingStreet2 = 'New Street';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = 'Joe';
        objWTC1.acct.LastName = 'bob';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.PersonEmail = 'a@test.org';
        objWTC1.acct.BillingStreet = 'New Street';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.confirmEmail = 'a@test.org';
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingStateCode = 'MB';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = 'MB';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '1234';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        //objWTC1.Attachbody = Blob.valueOf('testsdf');
        //objWTC1.Attachname = 'FILE NAME';
        objWTC1.Upload();
        }
        Test.stopTest();
    }
    
    static testMethod void forNullURL()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forNullURL*********************************');
        //objWTC2.getstate();
        //objWTC2.setstate('CO');
        //objWTC2.enableEnglish();
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.PersonEmail = 'm@test.org';
        objWTC2.confirmEmail = 'm@test.org';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = 'New Street';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        //List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        objWTC2.acct.BillingCountryCode = 'US';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        objWTC2.acct.BillingStateCode = 'CO';
        //objWTC2.state = 'CO';
        objWTC2.objCase.Batch_Code__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        Test.stopTest();
    }
    
    static testMethod void forExistingAccount()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forExistingAccount*********************************');
        //objWTC1.setstate('MB');
        //objWTC1.enableFrench();
        objWTC1.personBillingStreet2 = 'New Street';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = acct.FirstName;
        objWTC1.acct.LastName = acct.LastName;
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.PersonEmail = acct.PersonEmail;
        objWTC1.acct.BillingStreet = 'New Street';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.confirmEmail = acct.PersonEmail;
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingStateCode = 'MB';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = 'MB';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '1234';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        }
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forExistingAccount*********************************');
        //objWTC2.setstate('MB');
        //objWTC2.enableEnglish();
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = acct.FirstName;
        objWTC2.acct.LastName = acct.LastName;
        objWTC2.acct.PersonEmail = acct.PersonEmail;
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingStreet = 'New Street';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.confirmEmail = acct.PersonEmail;
        objWTC2.acct.BillingCountryCode = 'CA';
        objWTC2.acct.BillingStateCode = 'MB';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'CAN';
        //List<selectOption> stateOption = objWTC2.getStateOptions2();
        //objWTC2.state = 'MB';
        objWTC2.acct.ShippingCountryCode = 'INDIA';
        objWTC2.objCase.Batch_Code__c = '1234';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
 
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forExistingAccount*********************************');
        //objWTC2.getstate();
        //objWTC2.setstate('NY');
        //objWTC2.enableEnglish();
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.acct.FirstName = acct.FirstName;
        objWTC2.acct.LastName = acct.LastName;
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.PersonEmail = acct.PersonEmail;
        objWTC2.confirmEmail = acct.PersonEmail;
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = 'New Street';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        //List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        objWTC2.acct.BillingCountryCode = 'US';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        //objWTC2.state = 'NY';
        objWTC2.acct.BillingStateCode = 'NY';
        objWTC2.objCase.Batch_Code__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        Test.stopTest();
    }
    
    static testMethod void forDifferentEmail()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','fr');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidEmail*********************************');
        //objWTC1.setstate('MB');
        //objWTC1.enableFrench();
        objWTC1.personBillingStreet2 = 'New Street';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = 'Joe';
        objWTC1.acct.LastName = 'Bob';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.acct.PersonEmail = 'm';
        objWTC1.confirmEmail = 'd';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = 'MB';
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingStateCode = 'MB';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.BillingStreet = 'New Street';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '1234';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        }
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidEmail*********************************');
        //objWTC2.setstate('MB');
        //objWTC2.enableEnglish();
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.PersonEmail = 'b';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.confirmEmail = 'e';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'CAN';
        //List<selectOption> stateOption = objWTC2.getStateOptions2();
        //objWTC2.state = 'MB';
        objWTC2.acct.BillingCountryCode = 'CA';
        objWTC2.acct.BillingStateCode = 'MB';
        objWTC2.acct.BillingStreet = 'New Street';
        objWTC2.acct.ShippingCountryCode = 'INDIA';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.objCase.Batch_Code__c = '1234';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
         //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidEmail*********************************');
        //objWTC2.getstate();
        //objWTC2.setstate('NY');
        //objWTC2.enableEnglish();
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.PersonEmail = 'm';
        objWTC2.confirmEmail = 'd';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = 'New Street';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        //List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        objWTC2.acct.BillingCountryCode = 'US';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        //objWTC2.state = 'NY';
        objWTC2.acct.BillingStateCode = 'NY';
        objWTC2.objCase.Batch_Code__c = '1234';
        // objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        Test.stopTest();
    }
    
    static testMethod void forInvalidEmail()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidEmail*********************************');
        //objWTC1.setstate('MB');
        //objWTC1.enableFrench();
        objWTC1.personBillingStreet2 = 'New Street';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = 'Joe';
        objWTC1.acct.LastName = 'Bob';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.acct.PersonEmail = 'm';
        objWTC1.confirmEmail = 'm';
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingStateCode = 'MB';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = 'MB';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.BillingStreet = 'New Street';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '1234';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        }
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidEmail*********************************');
        //objWTC2.setstate('MB');
        //objWTC2.enableEnglish();
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.PersonEmail = 'b';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.confirmEmail = '';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'CAN';
        //List<selectOption> stateOption = objWTC2.getStateOptions2();
        //objWTC2.state = 'MB';
        objWTC2.acct.BillingCountryCode = 'CA';
        objWTC2.acct.BillingStateCode = 'MB';
        objWTC2.acct.BillingStreet = 'New Street';
        objWTC2.acct.ShippingCountryCode = 'INDIA';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.objCase.Batch_Code__c = '1234';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
         //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidEmail*********************************');
        //objWTC2.getstate();
        //objWTC2.setstate('NY');
        //objWTC2.enableEnglish();
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.PersonEmail = 'm';
        objWTC2.confirmEmail = 'm';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = 'New Street';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        //List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        objWTC2.acct.BillingCountryCode = 'US';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        //objWTC2.state = 'NY';
        objWTC2.acct.BillingStateCode = 'NY';
        objWTC2.objCase.Batch_Code__c = '1234';
         //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        Test.stopTest();
    }
    
    static testMethod void forInvalidData()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidData*********************************');
        //objWTC1.setstate(NULL);
        //objWTC1.enableFrench();
        objWTC1.personBillingStreet2 = '';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = '';
        objWTC1.acct.LastName = '';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.acct.PersonEmail = '';
        objWTC1.confirmEmail = '';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = '';
        objWTC1.acct.BillingCountryCode = '';
        objWTC1.acct.BillingPostalCode = '';
        objWTC1.acct.BillingStreet = '';
        objWTC1.acct.ShippingCountryCode = '';
        objWTC1.acct.BillingCity = '';
        objWTC1.objCase.Batch_Code__c = '';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        
        system.assert(ApexPages.hasMessages());
        
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidData*********************************');
        //objWTC2.setstate(NULL);
        //objWTC2.enableEnglish();
        objWTC2.personBillingStreet2 = '=';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = '';
        objWTC2.acct.LastName = '';
        objWTC2.acct.PersonEmail = '';
        objWTC2.acct.BillingPostalCode = '';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.confirmEmail = '';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = '';
        objWTC2.acct.BillingCountryCode = '';
        objWTC2.acct.BillingStreet = '';
        objWTC2.acct.ShippingCountry = '';
        objWTC2.acct.BillingCity = '';
        objWTC2.objCase.Batch_Code__c = '';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        
        system.assert(ApexPages.hasMessages());
        
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC3 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidData*********************************');
        //objWTC3.getstate();
        //objWTC3.setstate(Null);
        //objWTC3.enableEnglish();
        objWTC3.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC3.personBillingStreet2 = '';
        objWTC3.objCase = new Case();
        objWTC3.acct.FirstName = '';
        objWTC3.acct.LastName = '';
        objWTC3.acct.RecordTypeId = personAccount.Id;
        objWTC3.acct.PersonEmail = '';
        objWTC3.confirmEmail = '';
        objWTC3.acct.BillingPostalCode = '';
        objWTC3.acct.BillingCity = '';
        objWTC3.acct.BillingStreet = '';
        //List<selectOption> country3 = objWTC3.getCountriesSelectList();
        //objWTC3.country = '';
        objWTC3.acct.BillingCountryCode = '';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        objWTC3.objCase.Batch_Code__c = '';
       // objWTC3.objCase.Original_PO_CASE_del__c = '1234';
        objWTC3.registrationSave();
        //objWTC3.registrationSaveAndAddAttachment();
         Test.stopTest();
         
         system.assert(ApexPages.hasMessages());
    }
    
    static testMethod void forInvalidBatchCode()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidBatchCode*********************************');
        //objWTC1.setstate('MB');
        //objWTC1.enableFrench();
        objWTC1.personBillingStreet2 = 'New Street';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = 'Joe';
        objWTC1.acct.LastName = 'Bob';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.acct.PersonEmail = 'b@test.org';
        objWTC1.confirmEmail = 'b@test.org';
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingStateCode = 'MB';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = 'MB';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.BillingStreet = 'New Street';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '12988';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        }
        
        system.assert(ApexPages.hasMessages());
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidBatchCode*********************************');
        //objWTC2.setstate('CO');
        //objWTC2.enableEnglish();
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.PersonEmail = 'b@test.org';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.confirmEmail = 'b@test.org';
        objWTC2.acct.BillingCountryCode = 'CA';
        objWTC2.acct.BillingStateCode = 'CO';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'CAN';
        //List<selectOption> stateOption = objWTC2.getStateOptions2();
        //objWTC2.state = 'CO';
        objWTC2.acct.BillingStreet = 'New Street';
        objWTC2.acct.ShippingCountryCode = 'INDIA';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.objCase.Batch_Code__c = '12988';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        
        system.assert(ApexPages.hasMessages());
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forInvalidBatchCode*********************************');
        //objWTC2.getstate();
        //objWTC2.setstate('NY');
        //objWTC2.enableEnglish();
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.PersonEmail = 'b@test.org';
        objWTC2.confirmEmail = 'b@test.org';
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = 'New Street';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        //List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        objWTC2.acct.BillingCountryCode = 'US';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        //objWTC2.state = 'NY';
        objWTC2.acct.BillingStateCode = 'NY';
        objWTC2.objCase.Batch_Code__c = '12988';
         //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        Test.stopTest();
        
        system.assert(ApexPages.hasMessages());
    }
    static testMethod void forErrorData()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forErrorData*********************************');
        //objWTC1.enableFrench();
        //objWTC1.getstate();
        //objWTC1.setstate('******************************************************************************************************');
        objWTC1.personBillingStreet2 = '*************************************************************************************************';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = 'Joe';
        objWTC1.acct.LastName = 'Bob';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.acct.PersonEmail = 'b@test.org';
        objWTC1.confirmEmail = 'b@test.org';
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = '******';
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingCountryCode = '*****';
        objWTC1.acct.BillingPostalCode = 'yt99999999tttt';
        objWTC1.acct.BillingStreet = '**************************************************************************************';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '1233';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
        //objWTC1.registrationSaveAndAddAttachment();
        }
        system.assert(ApexPages.hasMessages());
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forErrorData*********************************');
        //objWTC2.enableEnglish();
        //objWTC2.getstate();
        //objWTC2.setstate('******************************************************************************************************');
        objWTC2.personBillingStreet2 = '*****************************************************************************************************';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.PersonEmail = 'b@test.org';
        objWTC2.acct.BillingPostalCode = 'yt99999999tttt';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.confirmEmail = 'b@test.org';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'CAN';
        //List<selectOption> stateOption = objWTC2.getStateOptions2();
        //objWTC2.state = '******';
        objWTC2.acct.BillingCountryCode = 'CA';
        objWTC2.acct.BillingStateCode = '*********';
        objWTC2.acct.BillingStreet = '***yt99999999tttt*yt99999999ttttyt99999999ttttyt99999999ttttyt99999999ttttyt99999999tttt**';
        objWTC2.acct.ShippingCountryCode = 'INDIA';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.objCase.Batch_Code__c = '1233';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
       // objWTC2.registrationSaveAndAddAttachment();
        }
        
        system.assert(ApexPages.hasMessages());
        
        system.runas(objUser) 
        {
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
        system.debug('forErrorData*********************************');
        //objWTC2.enableEnglish();
        //objWTC2.getstate();
        //objWTC2.setstate('******************************************************************************************************');
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.personBillingStreet2 = '**yt99999999ttttyt99999999ttttyt99999999ttttyt99999999ttttyt99999999ttttyt99999999tttt****';
        objWTC2.acct.FirstName = 'Joe';
        objWTC2.acct.LastName = 'Bob';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.PersonEmail = 'b@test.org';
        objWTC2.confirmEmail = 'b@test.org';
        objWTC2.acct.BillingPostalCode = 'yt99999999tttt';
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.acct.BillingStreet = '********************************************************************************';
        //List<selectOption> country2 = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'USA';
        // List<selectOption> stateOption2 = objWTC2.getStateOptions2();
        objWTC2.acct.BillingCountryCode = 'US';
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        //objWTC2.state = '******';
        objWTC2.acct.BillingStateCode = '*********';
        objWTC2.objCase.Batch_Code__c = '1233';
        // objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
        //objWTC2.registrationSaveAndAddAttachment();
        }
        Test.stopTest();
        system.assert(ApexPages.hasMessages());
    }
    
    static testMethod void forBillingState()
    {
        Test.startTest();
        testData_for_WebToCaseForFastSlowCookerControllerTest();
        
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC1 = new WebToCaseForFastSlowCookerController();
        system.debug('forExistingAccount*********************************');
        //objWTC1.setstate('4');
        //objWTC1.enableFrench();
        objWTC1.personBillingStreet2 = 'New Street';
        objWTC1.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC1.acct.FirstName = acct.FirstName;
        objWTC1.acct.LastName = acct.LastName;
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.PersonEmail = acct.PersonEmail;
        objWTC1.acct.BillingStreet = 'New Street';
        objWTC1.acct.RecordTypeId = personAccount.Id;
        objWTC1.confirmEmail = acct.PersonEmail;
        //List<selectOption> country2 = objWTC1.getCountriesSelectList();
        //objWTC1.country = 'CAN';
        //List<selectOption> stateOption2 = objWTC1.getStateOptions2();
        //objWTC1.state = '4';
        objWTC1.acct.BillingCountryCode = 'CA';
        objWTC1.acct.BillingStateCode = '4';
        objWTC1.acct.BillingPostalCode = '111111';
        objWTC1.acct.ShippingCountryCode = 'INDIA';
        objWTC1.acct.BillingCity = 'testCity';
        objWTC1.objCase.Batch_Code__c = '1234';
        //objWTC1.objCase.Original_PO_CASE_del__c = '7284';
        objWTC1.registrationSave();
       // objWTC1.registrationSaveAndAddAttachment();
        
        
        
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','CA');
        pageRef.getParameters().put('language','eng');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC2 = new WebToCaseForFastSlowCookerController();
         system.debug('forExistingAccount*********************************');
        //objWTC2.setstate('9');
        //objWTC2.enableEnglish();
        objWTC2.personBillingStreet2 = 'New Street';
        objWTC2.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC2.acct.FirstName = acct.FirstName;
        objWTC2.acct.LastName = acct.LastName;
        objWTC2.acct.PersonEmail = acct.PersonEmail;
        objWTC2.acct.BillingPostalCode = '111111';
        objWTC2.acct.BillingStreet = 'New Street';
        objWTC2.acct.RecordTypeId = personAccount.Id;
        objWTC2.acct.BillingCity = 'testCity';
        objWTC2.confirmEmail = acct.PersonEmail;
        objWTC2.acct.BillingCountryCode = 'CA';
        //List<selectOption> country = objWTC2.getCountriesSelectList();
        //objWTC2.country = 'CAN';
        //List<selectOption> stateOption = objWTC2.getStateOptions2();
        //objWTC2.state = '9';
        objWTC2.acct.BillingStateCode = '9';
        objWTC2.acct.ShippingCountryCode = 'INDIA';
        objWTC2.objCase.Batch_Code__c = '1234';
        //objWTC2.objCase.Original_PO_CASE_del__c = '1234';
        objWTC2.registrationSave();
       // objWTC2.registrationSaveAndAddAttachment();
        
 
        
        pageRef = Page.WebToCaseForFastSlowCooker;
        pageRef.getParameters().put('param','US');
        Test.setCurrentPage(pageRef);
        
        WebToCaseForFastSlowCookerController objWTC3 = new WebToCaseForFastSlowCookerController();
        system.debug('forExistingAccount*********************************');
        //objWTC3.getstate();
        //objWTC3.setstate('5');
        //objWTC3.enableEnglish();
        objWTC3.objCase.Product_Sub_Category__c = 'PRESSURE COOKERS';
        objWTC3.personBillingStreet2 = 'New Street';
        objWTC3.acct.FirstName = acct.FirstName;
        objWTC3.acct.LastName = acct.LastName;
        objWTC3.acct.RecordTypeId = personAccount.Id;
        objWTC3.acct.PersonEmail = acct.PersonEmail;
        objWTC3.confirmEmail = acct.PersonEmail;
        objWTC3.acct.BillingPostalCode = '111111';
        objWTC3.acct.BillingCity = 'testCity';
        objWTC3.acct.BillingCountryCode = 'US';
        //List<selectOption> country3 = objWTC3.getCountriesSelectList();
        //objWTC3.country = 'USA';
        //List<selectOption> stateOption3 = objWTC3.getStateOptions2();
        //List<SelectOption> whereDoyouPurchase = objWTC.whereDidYouPurchaseFrom;
        //objWTC2.objCase.Purchased_From__c = 'Amazon';
        //objWTC3.state = '6';
        objWTC3.acct.BillingStateCode = '6';
        objWTC3.acct.BillingStreet = 'New Street';
        objWTC3.objCase.Batch_Code__c = '1234';
        objWTC3.registrationSave();
        //objWTC3.registrationSaveAndAddAttachment();
        
        Test.stopTest();
    }
    
    static testMethod void testMethodProductRegistrationControllerNegativeTest1(){
		Test.starttest();
	         pageRef = Page.WebToCaseForFastSlowCooker;
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
		        accountObj.BillingPostalCode = '800002';
		        accountObj.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        accountObj.BillingCountryCode = 'US';
		        accountObj.BillingStateCode = 'CO';
		     insert accountObj;
	         
	        
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         	
	         	//Set regirnCode = 'CAN'
	         	System.currentPageReference().getParameters().put('param', 'CA');
		        
		        WebToCaseForFastSlowCookerController objWTC3 = new WebToCaseForFastSlowCookerController();
		     	objWTC3.acct = accountObj;
		     	objWTC3.dummyAccount = accountObj;
		        objWTC3.personBillingStreet2 = '123 test street 2';
		        objWTC3.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        //objWTC3.selectedSubCategory = 'I dont see my product';
		        objWTC3.objCase.Batch_Code__c = '1234';
		        objWTC3.objCase.Purchased_From__c ='Amazon';
		        objWTC3.objCase.Purchase_Date__c = Date.today();
		        objWTC3.objCase.Type='RMA';
		        //objWTC3.comments = 'For Inquiry';
		        
		        //objWTC3.fetchProducts();
		        objWTC3.registrationSave();
		        
		        //When personalEmail!=confirmEmail
		        objWTC3.confirmEmail = 'raveena@persistent.co.in';
		        objWTC3.registrationSave();
		        
		        //BillingStreet
		        objWTC3.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        objWTC3.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)134 KENT ST. (CONF.COURT MALL)';
		        objWTC3.registrationSave();
		        
		        //Billing postal code
		        objWTC3.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        //System.currentPageReference().getParameters().put('param', 'CA');
		        //objWTC3.URL = 'CA';
		        accountObj.BillingPostalCode = '8 002';
		        objWTC3.dummyAccount.BillingCountryCode = 'CAN';
		        objWTC3.dummyAccount.BillingStateCode = 'NL';
		        objWTC3.registrationSave();
		        
		        //PurchasedDate
		        accountObj.BillingPostalCode = '800002';
		        objWTC3.objCase.Purchase_Date__c = Date.today().addDays(1);
		        objWTC3.registrationSave();
		        
		        
		        objWTC3.isSuccess = true;
		        objWTC3.upload();
		Test.stoptest();
		// Verify response received 
	   // System.assertEquals(true, success);
	}
}