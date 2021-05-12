@isTest
private without sharing class WebToCaseBeanzControllerTest{
    
    static WebToCaseBeanzController getNewControllerObject () {
        WebToCaseBeanzController webToCaseControllerObj = new WebToCaseBeanzController();
        webToCaseControllerObj.dummyAccount.FirstName = 'Joe';
        webToCaseControllerObj.dummyAccount.LastName = 'Bob';
        webToCaseControllerObj.dummyAccount.PersonEmail = 'test@example.com';
        webToCaseControllerObj.dummyAccount.BillingCountryCode = 'US';
        webToCaseControllerObj.dummyAccount.BillingStateCode = 'CA';
        webToCaseControllerObj.dummyAccount.Phone = '9999999999';
        webToCaseControllerObj.confirmEmail = 'test@example.com';
        webToCaseControllerObj.objCase.Purchased_From__c = 'beanz';
        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = 'Original_PO_Test';
        webToCaseControllerObj.comments = 'For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry ';
        return webToCaseControllerObj;
    }
    
    static PageReference getPageReference() {
        PageReference pageRef = Page.WebToCaseForBeanz;
        pageRef.getParameters().put('param', 'US');
        pageRef.getParameters().put('language', 'fr');
        pageRef.getParameters().put('brand', 'beanz');
        return pageRef;
    }
    
    static testMethod void testRequiredFieldsNotSet(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());
       
        WebToCaseBeanzController webToCaseControllerObj = new WebToCaseBeanzController();
        webToCaseControllerObj.dummyAccount.BillingCountryCode = 'US';
        PageReference p = webToCaseControllerObj.registrationSave();
        
        Test.stoptest();
        System.assertEquals(null, p);
    }
    
    static testMethod void testInvalidCountry(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());

        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.dummyAccount.BillingCountryCode = 'BAA';
        webToCaseControllerObj.dummyAccount.BillingStateCode = 'ABC';
        webToCaseControllerObj.validateCountry();

        Test.stoptest();
        System.assertEquals(true, webToCaseControllerObj.showCountryError, 'Invalid Country Check Failed');
    }
    
    static testMethod void testValidCountry(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());
        
        WebToCaseBeanzController webToCaseControllerObj1 = getNewControllerObject();
        webToCaseControllerObj1.validateCountry();
        
        Test.stoptest();
        System.assertEquals(false, webToCaseControllerObj1.showCountryError, 'Country Error though provided Country is valid');
    }
    
    static testMethod void testAttachmentUpload () {
        Test.starttest();
        Test.setCurrentPage(getPageReference());
        
        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.Attachbody = Blob.valueOf('Test Data for Attachment');
        webToCaseControllerObj.Attachname = 'Test Attachment';
        webToCaseControllerObj.Upload();
        
        Test.stoptest();
        // Verify response received 
//        System.assertEquals(true, success);
    }

    static testMethod void testUploadWithoutAttachment () {
        Test.starttest();
        Test.setCurrentPage(getPageReference());
        
        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.Upload();
        
        Test.stoptest();
        // Verify response received 
//        System.assertEquals(true, success);
    }
    
    static testMethod void testDifferentEmailsError() {
        Test.starttest();
        Test.setCurrentPage(getPageReference());
        
        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.confirmEmail = 'test@example.com1';
        PageReference ref = webToCaseControllerObj.registrationSave();
        Test.stopTest();
        System.assertEquals(null, ref, 'Email and Confirm Email Do not match');
    }

    static testMethod void testValidCountryAtRegistrationSaveAndAddAttachment(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());

        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.registrationSaveAndAddAttachment();

        Test.stoptest();
        System.assertEquals('CA', webToCaseControllerObj.dummyAccount.BillingStateCode, 'Country Validation Check Failed');
    }
    
    static testMethod void testValidPurchaseDate(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());

        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.objCase.Purchase_Date__c = date.today() + 1;
        webToCaseControllerObj.registrationSave();

        Test.stoptest();
        //System.assertEquals('CA', webToCaseControllerObj.dummyAccount.BillingStateCode, 'Country Validation Check Failed');
    }
    
    static testMethod void testCommentsGreaterThan255Characters(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());

        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.comments = 'For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry ' +
            'For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry ' +
            'For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry ' +
            'For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry For Inquiry ';
        webToCaseControllerObj.registrationSave();

        Test.stoptest();
        //System.assertEquals('CA', webToCaseControllerObj.dummyAccount.BillingStateCode, 'Country Validation Check Failed');
    }
    
    static testMethod void testInvalidCountryAtRegistrationSaveAndAddAttachment(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());

        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.dummyAccount.BillingCountryCode = 'BAA';
        webToCaseControllerObj.dummyAccount.BillingStateCode = 'ABC';
        webToCaseControllerObj.registrationSaveAndAddAttachment();

        Test.stoptest();
        System.assertEquals(null, webToCaseControllerObj.dummyAccount.BillingStateCode, 'Country Validation Check Failed');
    }
    
    static testMethod void testInvalidCountryAtRegistrationSave(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());

        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        webToCaseControllerObj.dummyAccount.BillingCountryCode = 'BAA';
        webToCaseControllerObj.dummyAccount.BillingStateCode = 'ABC';
        webToCaseControllerObj.registrationSave();

        Test.stoptest();
        System.assertEquals(null, webToCaseControllerObj.dummyAccount.BillingStateCode, 'Country Validation Check Failed');
    }
    
    static testMethod void testCaseCreationSuccess(){
        Test.starttest();
        Test.setCurrentPage(getPageReference());
        List<Product2> products = new List<Product2>();
        Integer maxVendors = 3;
        
        for (Integer i = 0; i < maxVendors; i++) {
            Product2 product = new Product2();
            product.Country_Code__c = 'USA';
            product.IsActive = true;
            product.Brand__c = 'beanz';
            product.AX_Items_PLM_Status__c = '02_Active';
            product.Vendor_Name__c = 'Vendor' + i;
            product.Name = product.Vendor_Name__c + ' - Whole Beans';
            product.Description = product.Name;
            product.CurrencyIsoCode = 'USD';
            products.add(product);
        }
        
        insert products;
        
        WebToCaseBeanzController webToCaseControllerObj = getNewControllerObject();
        Account accountObj = webToCaseControllerObj.dummyAccount;
        insert accountObj;

        webToCaseControllerObj.acct = accountObj;
        webToCaseControllerObj.selectedVendor = 'Vendor1';
        webToCaseControllerObj.fetchRoasters();
        webToCaseControllerObj.selectedRoaster = products[0].Id;
        webToCaseControllerObj.registrationSave();

        Test.stoptest();
        // System.assertEquals(true, success);
    }
    
}