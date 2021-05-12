@isTest
private class ProductRegistrationForJoeJuicerTest {

    static Account account;
    static Warranty__c warranty;
    static RecordType personAccount;
    static Product2 product;

    private static void testData_for_ProductRegistrationForJoeJuicerTest()
    {
        personAccount=[Select Id 
                       From RecordType
                       where sObjectType = 'Account' and Name = 'Person Account' and IsActive= True];
        
        //Create an Account Record
        account=new Account();
        account.RecordTypeId=personAccount.Id;
        account.FirstName='test1';
        account.LastName='test2';
        account.BillingCity='Pune';
        account.BillingCountryCode='US';
        account.BillingPostalCode='411007';
        account.BillingStateCode='AL';
        account.BillingStreet='Laxmi Road';
        insert account;
        
        //Create a Product Record
        product=new Product2();
        product.SKU__c='TG870190';  //required
        product.Name='Product name';
        product.IsActive= true;
        product.Name='Product name';
        product.Description='Product description';
        product.Serial_Required_for_Registration__c= true;
        product.Finished_Good__c= true;
        product.Accessory__c = false;
        product.Joe_Product__c = true;
        product.Product_Classification__c='S';
        product.Spare_Part__c= false;
        product.Family='PSA';
        product.Product_Sub_Family__c = 'Blenders';
        insert product;
        //What about that parent_SKU_field which is lookup to product
                                
        //Create a Warranty record
        warranty=new Warranty__c();
        warranty.Warranty_Owner__c=account.Id;  //master to account
        warranty.Product__c=product.Id;     // lookup to product
        warranty.Product_Category__c='GRILLS';
        warranty.Where_did_you_purchase__c='Other';
        warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
        warranty.Serial__c='15';
        insert warranty;
   
    }
    
    static testMethod void forExistingAccount()
    {
         testData_for_ProductRegistrationForJoeJuicerTest();
         
         Pagereference pageref=page.ProductRegistrationForJoeJuicer;
         Test.setCurrentPage(pageref);
         
         ProductRegistrationForJoeJuicer objPRFP=new ProductRegistrationForJoeJuicer();
         objPRFP.acct=new Account();
         objPRFP.warranty=new Warranty__c();
         objPRFP.selectedSubCategory=  product.Product_Sub_Family__c;
         List<SelectOption> productSubCategory=objPRFP.productSubCategories;
         List<SelectOption> productt=objPRFP.products;
         List<String> requiredSerial=objPRFP.requiredSerials;
         List<SelectOption> purchaseFrom = objPRFP.whereDidYouPurchaseFrom;
         List<SelectOption> hearFrom = objPRFP.howDidYouHearAboutUs;

         objPRFP.warranty.Warranty_Owner__c=account.Id;
         objPRFP.warranty.Product__c=product.Id;
         objPRFP.warranty.Product_Category__c='Product category';
         objPRFP.whereDidYouPurchase='Other';
         objPRFP.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
         objPRFP.warranty.Serial__c='15'; 
         
         objPRFP.acct.FirstName='ptest1';
         objPRFP.acct.LastName='ptest2';
         objPRFP.acct.BillingStreet='MG Road';
         objPRFP.acct.BillingCity='Pimpalner';
         objPRFP.acct.BillingStateCode='AB';
         objPRFP.acct.BillingPostalCode='411007';
         objPRFP.acct.BillingCountryCode='CA';
         objPRFP.acct.PersonEmail='a.a@a.com';
         objPRFP.acct.Phone='3126459871';
         objPRFP.acct.Gender__c='Female';
         objPRFP.confirmEmail='a.a@a.com';
         objPRFP.getIsSuccess();
         objPRFP.registrationSave();
         
         Warranty__c warrantychk=[Select Warranty_Owner__c,
                                         Id
                                  From Warranty__c limit 1];
         system.assertEquals(account.Id, warrantychk.Warranty_Owner__c);
         
         Pagereference pageref1=page.productRegistrationForJoeJuicer;
         Test.setCurrentPage(pageref1);
        
         ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
         objPRFP1.acct=new Account();
         objPRFP1.warranty=new Warranty__c();
         objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
         List<String> requiredSerial1=objPRFP1.requiredSerials;
         List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
         List<SelectOption> productt1=objPRFP1.products;
         List<SelectOption> purchaseFrom2 = objPRFP1.whereDidYouPurchaseFrom;
         List<SelectOption> hearFrom2 = objPRFP1.howDidYouHearAboutUs;

         objPRFP1.warranty.Warranty_Owner__c=account.Id;
         objPRFP1.warranty.Product__c=product.Id;
         objPRFP1.warranty.Product_Category__c='Product category';
         objPRFP1.whereDidYouPurchase='Other';
         objPRFP1.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
         objPRFP1.warranty.Serial__c='15'; 
        
         objPRFP1.acct.FirstName='ptest1';
         objPRFP1.acct.LastName='ptest2';
         objPRFP1.acct.BillingStreet='MG Road';
         objPRFP1.acct.BillingCity='Pimpalner';
         objPRFP1.acct.BillingStateCode='AB';
         objPRFP1.acct.BillingPostalCode='411007';
         objPRFP1.acct.BillingCountryCode='CA';
         objPRFP1.acct.PersonEmail='biraris.p@a.com';
         objPRFP1.acct.Phone='3126459871';
         objPRFP1.acct.Gender__c='Female';
         objPRFP1.confirmEmail='biraris.s@a.com';
         objPRFP1.getIsSuccess();
         objPRFP1.registrationSave();
         
         Pagereference pageref2=page.productRegistrationForJoeJuicer;
         Test.setCurrentPage(pageref2);
        
         ProductRegistrationForJoeJuicer objPRFP2=new ProductRegistrationForJoeJuicer();
         objPRFP2.acct=new Account();
         objPRFP2.warranty=new Warranty__c();
         objPRFP2.selectedSubCategory=product.Product_Sub_Family__c;
         List<String> requiredSerial2=objPRFP2.requiredSerials;
         List<SelectOption> productSubCategory2=objPRFP2.productSubCategories;
         List<SelectOption> productt2=objPRFP2.products;
         List<SelectOption> purchaseFrom3 = objPRFP2.whereDidYouPurchaseFrom;
         List<SelectOption> hearFrom3 = objPRFP2.howDidYouHearAboutUs;

         objPRFP2.warranty.Warranty_Owner__c=account.Id;
         objPRFP2.warranty.Product__c=product.Id;
         objPRFP2.warranty.Product_Category__c='Product category';
         objPRFP2.whereDidYouPurchase='Other';
         objPRFP2.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
         objPRFP2.warranty.Serial__c='15'; 
        
         objPRFP2.acct.FirstName='Aaditya';
         objPRFP2.acct.LastName='Birla';
         objPRFP2.acct.BillingStreet='Main Road';
         objPRFP2.acct.BillingCity='Delhi';
         objPRFP2.acct.BillingStateCode='AB';
         objPRFP2.acct.BillingPostalCode='411007';
         objPRFP2.acct.BillingCountryCode='CA';
         objPRFP2.acct.PersonEmail='biraris.p@a.com';
         objPRFP2.acct.Phone='3126221321';
         objPRFP2.acct.Gender__c='Female';
         objPRFP2.confirmEmail='biraris.p@a.com';
         objPRFP2.getIsSuccess();
         objPRFP2.registrationSave();
         
    }
    
    static testMethod void forInvalidEmailAddress()
    {
        testData_for_ProductRegistrationForJoeJuicerTest();
        
        Pagereference pageref1=page.productRegistrationForJoeJuicer;
        Test.setCurrentPage(pageref1);
        
        ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
        objPRFP1.acct=new Account();
        objPRFP1.warranty=new Warranty__c();
        objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
        List<String> requiredSerial1=objPRFP1.requiredSerials;
        List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
        List<SelectOption> productt1=objPRFP1.products;
        List<SelectOption> purchaseFrom = objPRFP1.whereDidYouPurchaseFrom;
        List<SelectOption> hearFrom = objPRFP1.howDidYouHearAboutUs;

        objPRFP1.warranty.Warranty_Owner__c=account.Id;
        objPRFP1.warranty.Product__c=product.Id;
        objPRFP1.warranty.Product_Category__c='Product category';
        objPRFP1.whereDidYouPurchase='Other';
        objPRFP1.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
        objPRFP1.warranty.Serial__c='15'; 
        objPRFP1.acct.FirstName='Tina';
        objPRFP1.acct.LastName='Birla';
        objPRFP1.acct.BillingStreet='MG Road';
        objPRFP1.acct.BillingCity='Pimpalner';
        objPRFP1.acct.BillingStateCode='AL';
        objPRFP1.acct.BillingPostalCode='411007';
        objPRFP1.acct.BillingCountryCode='US';
        objPRFP1.acct.PersonEmail='b.aa.com';
        objPRFP1.acct.Phone='3126459871';
        objPRFP1.acct.Gender__c='Female';
        objPRFP1.confirmEmail='a.a@aaa.com';
        objPRFP1.registrationSave();
    }
    
    static testMethod void forInvalidPostalCode()
    {
        
        testData_for_ProductRegistrationForJoeJuicerTest();
        
        Pagereference pageref1=page.productRegistrationForJoeJuicer;
        Test.setCurrentPage(pageref1);
        
        ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
        objPRFP1.acct=new Account();
        objPRFP1.warranty=new Warranty__c();
        objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
        List<String> requiredSerial1=objPRFP1.requiredSerials;
        List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
        List<SelectOption> productt1=objPRFP1.products;
        List<SelectOption> purchaseFrom = objPRFP1.whereDidYouPurchaseFrom;
        List<SelectOption> hearFrom = objPRFP1.howDidYouHearAboutUs;

        objPRFP1.warranty.Warranty_Owner__c=account.Id;
        objPRFP1.warranty.Product__c=product.Id;
        objPRFP1.warranty.Product_Category__c='Product category';
        objPRFP1.whereDidYouPurchase='Other';
        objPRFP1.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
        objPRFP1.warranty.Serial__c='15'; 
        objPRFP1.acct.FirstName='Tina';
        objPRFP1.acct.LastName='Birla';
        objPRFP1.acct.BillingStreet='MG Road';
        objPRFP1.acct.BillingCity='Surat';
        objPRFP1.acct.BillingStateCode='AB';
        objPRFP1.acct.BillingPostalCode='007';
        objPRFP1.acct.BillingCountryCode='CA';
        objPRFP1.acct.PersonEmail='p.n@a.com';
        objPRFP1.acct.Phone='3126459871';
        objPRFP1.acct.Gender__c='Female';
        objPRFP1.confirmEmail='p.n@a.com';
        objPRFP1.registrationSave();
        
     }
     
    static testMethod void forInvalidBillingStreet()
    {       
        testData_for_ProductRegistrationForJoeJuicerTest();
        
        Pagereference pageref1=page.productRegistrationForJoeJuicer;
        Test.setCurrentPage(pageref1);
        
        ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
        objPRFP1.acct=new Account();
        objPRFP1.warranty=new Warranty__c();
        objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
        List<String> requiredSerial1=objPRFP1.requiredSerials;
        List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
        List<SelectOption> productt1=objPRFP1.products;
        List<SelectOption> purchaseFrom = objPRFP1.whereDidYouPurchaseFrom;
        List<SelectOption> hearFrom = objPRFP1.howDidYouHearAboutUs;

        objPRFP1.warranty.Warranty_Owner__c=account.Id;
        objPRFP1.warranty.Product__c=product.Id;
        objPRFP1.warranty.Product_Category__c='Product category';
        objPRFP1.whereDidYouPurchase='Other';
        objPRFP1.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
        objPRFP1.warranty.Serial__c='15'; 
        
        objPRFP1.acct.FirstName='Tina';
        objPRFP1.acct.LastName='Birla';
        objPRFP1.acct.BillingStreet='ABCABCABCABCABCABCABCABCABCABCABC';
        objPRFP1.acct.BillingCity='Surat';
        objPRFP1.acct.BillingStateCode='AB';
        objPRFP1.acct.BillingPostalCode='007';
        objPRFP1.acct.BillingCountryCode='CA';
        objPRFP1.acct.PersonEmail='pp.n@a.com';
        objPRFP1.acct.Phone='3126459871';
        objPRFP1.acct.Gender__c='Female';
        objPRFP1.confirmEmail='pp.n@a.com';
        objPRFP1.registrationSave();
        
     }
  
     static testMethod void forInvalidBillingState()
     {
         testData_for_ProductRegistrationForJoeJuicerTest();
         
         User objUser = [ Select Id,FirstName
                          FROM User
                          WHERE  UserType =: 'Guest' limit 1];
                     
        System.runAs(objUser) {
        //  system.debug('~~~obj'+objUser.UserType);
        
            Pagereference pageref1=page.productRegistrationForJoeJuicer;
            Test.setCurrentPage(pageref1);
        
            ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
            objPRFP1.acct=new Account();
            objPRFP1.warranty=new Warranty__c();
            objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
            List<String> requiredSerial1=objPRFP1.requiredSerials;
            List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
            List<SelectOption> productt1=objPRFP1.products;
            List<SelectOption> purchaseFrom = objPRFP1.whereDidYouPurchaseFrom;
            List<SelectOption> hearFrom = objPRFP1.howDidYouHearAboutUs;

            objPRFP1.warranty.Warranty_Owner__c=account.Id;
            objPRFP1.warranty.Product__c=product.Id;
            objPRFP1.warranty.Product_Category__c='Product category';
            objPRFP1.whereDidYouPurchase='Other';
            objPRFP1.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
            objPRFP1.warranty.Serial__c='15'; 
            objPRFP1.acct.FirstName='Tina';
            objPRFP1.acct.LastName='Birla';
            objPRFP1.acct.BillingStreet='ABC';
            objPRFP1.acct.BillingCity='Balhane';
            objPRFP1.acct.BillingStateCode='AB';
            objPRFP1.acct.BillingPostalCode='007111';
            objPRFP1.acct.BillingCountryCode='CA';
            objPRFP1.acct.PersonEmail='ppp.n@a.com';
            objPRFP1.acct.Phone='3126459871';
            objPRFP1.acct.Gender__c='Female';
            objPRFP1.confirmEmail='ppp.n@a.com';
            objPRFP1.registrationSave();
         
         
            Pagereference pageref2=page.productRegistrationForJoeJuicer;
            Test.setCurrentPage(pageref2);
        
            ProductRegistrationForJoeJuicer objPRFP2=new ProductRegistrationForJoeJuicer();
            objPRFP2.acct=new Account();
            objPRFP2.warranty=new Warranty__c();
            objPRFP2.selectedSubCategory=product.Product_Sub_Family__c;
            List<String> requiredSerial2=objPRFP2.requiredSerials;
            List<SelectOption> productSubCategory2=objPRFP2.productSubCategories;
            List<SelectOption> productt2=objPRFP2.products;
            List<SelectOption> purchaseFrom2 = objPRFP2.whereDidYouPurchaseFrom; 
            List<SelectOption> hearFrom2 = objPRFP2.howDidYouHearAboutUs;

            objPRFP2.warranty.Warranty_Owner__c=account.Id;
            objPRFP2.warranty.Product__c=product.Id;
             objPRFP2.warranty.Product_Category__c='Product category';
            objPRFP2.whereDidYouPurchase='Other';
            objPRFP2.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
            objPRFP2.warranty.Serial__c='15'; 
            objPRFP2.acct.FirstName='Tina';
            objPRFP2.acct.LastName='Birla';
            objPRFP2.acct.BillingStreet='ABC';
            objPRFP2.acct.BillingCity='Balhane';
            objPRFP2.acct.BillingStateCode='AL';
            objPRFP2.acct.BillingPostalCode='007111';
            objPRFP2.acct.BillingCountryCode='US';
            objPRFP2.acct.PersonEmail='ppp.n@a.com';
            objPRFP2.acct.Phone='3126459871';
            objPRFP2.acct.Gender__c='Female';
            objPRFP2.confirmEmail='ppp.n@a.com';
            objPRFP2.registrationSave();
        }
     }   
     
      static testMethod void forInvalidPhone()
     {
         
         User objUser = [ Select u.UserType 
                          From User u 
                          WHERE u.id =: UserInfo.getUserId()];
                     
        System.runAs(objUser) {
        //  system.debug('~~~obj'+objUser.UserType);
                     
            testData_for_ProductRegistrationForJoeJuicerTest();
        
            Pagereference pageref1=page.productRegistrationForJoeJuicer;
            Test.setCurrentPage(pageref1);
        
            ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
            objPRFP1.acct=new Account();
            objPRFP1.warranty=new Warranty__c();
            objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
            List<String> requiredSerial1=objPRFP1.requiredSerials;
            List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
            List<SelectOption> productt1=objPRFP1.products;
            List<SelectOption> purchaseFrom = objPRFP1.whereDidYouPurchaseFrom;
            List<SelectOption> hearFrom = objPRFP1.howDidYouHearAboutUs;

            objPRFP1.warranty.Warranty_Owner__c=account.Id;
            objPRFP1.warranty.Product__c=product.Id;
            objPRFP1.warranty.Product_Category__c='Product category';
            objPRFP1.whereDidYouPurchase='Other';
            objPRFP1.warranty.Web_Purchase_Date__c = Date.parse('08/05/2014');
            objPRFP1.warranty.Serial__c='15';          
            objPRFP1.acct.FirstName='Tina';
            objPRFP1.acct.LastName='Birla';
            objPRFP1.acct.BillingStreet='ABC';
            objPRFP1.acct.BillingCity='mum';
            objPRFP1.acct.BillingStateCode='AB';
            objPRFP1.acct.BillingPostalCode='007111';
            objPRFP1.acct.BillingCountryCode='CA';
            objPRFP1.acct.PersonEmail='ppp.n@a.com';
            objPRFP1.acct.Phone='312645';
            objPRFP1.acct.Gender__c='Female';
            objPRFP1.confirmEmail='ppp.n@a.com';
            objPRFP1.registrationSave();
        }
     }
     
     static testMethod void forInvalidData()
     {
        testData_for_ProductRegistrationForJoeJuicerTest();
        
        Pagereference pageref1=page.productRegistrationForJoeJuicer;
        Test.setCurrentPage(pageref1);
        
        ProductRegistrationForJoeJuicer objPRFP1=new ProductRegistrationForJoeJuicer();
        objPRFP1.acct=new Account();
        objPRFP1.warranty=new Warranty__c();
        objPRFP1.selectedSubCategory=product.Product_Sub_Family__c;
        List<String> requiredSerial1=objPRFP1.requiredSerials;
        List<SelectOption> productSubCategory1=objPRFP1.productSubCategories;
        List<SelectOption> productt1=objPRFP1.products; 
        List<SelectOption> purchaseFrom = objPRFP1.whereDidYouPurchaseFrom;
        List<SelectOption> hearFrom = objPRFP1.howDidYouHearAboutUs;
        objPRFP1.registrationSave();
        
     }
      

}