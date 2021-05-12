@isTest
public with sharing class UtilityTest {
    
    static testMethod void testextractIds(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;
    	sObject[] objs = new sObject[]{objAcc};
    	//objs.add(objAcc);
    	Set<Id> ids = Utility.extractIds(objs,'Id');
    }
    
    static testMethod void testextractStrings(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc; 
    	sObject[] objs = new sObject[]{objAcc};
    	//objs.add(objAcc);
    	Set<String> strings = Utility.extractStrings(objs,'Name');
    }
    
    static testMethod void testfetchLanguageCodeFromCountryCode(){
    	String language = Utility.fetchLanguageCodeFromCountryCode('USD');
    }
    
    static testMethod void testfindExistingAccountWithID(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc; 
    	Account newAccount = Utility.findExistingAccountWithID(objAcc.Id);
    }
    
    static testMethod void testcreateContactRecord(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc; 
    	Contact newContact = Utility.createContactRecord(objAcc.id, 'john','doe', 'johndoe@gmail.com');
    }
    
    static testMethod void testcreateAccountRecord(){
    	Account newAccount = Utility.createAccountRecord('john','doe', 'johndoe@gmail.com');
        
    }
    
    static testMethod void testcreateUserRecord(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc; 
    	User newUser = Utility.createUserRecord('Breville Customer Community', 'USD', 'johndoe@gmail.com');
    	Contact newContact = Utility.createContactRecord(objAcc.id, 'john','doe', 'johndoe@gmail.com');
    	newUser.ContactId = newContact.id;
    	//insert newUser;
    	//newUser = Utility.updateUser(newUser, 'john','doe', 'johndoe@gmail.com');	
    }
    
    static testMethod void testcreateUserFromAuthProvider(){
    	User newUser = Utility.createUserRecord('Breville Customer Community','USD', 'johndoe@gmail.com');
    }
    
   /* static testMethod void testcreateAccountFromSupport(){
    	ID recordTypeRecord = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    	Account newAccount = Utility.createAccountFromSupport('john','doe', '1234', 'UNITED STATES', recordTypeRecord);
    }*/
    
   /* static testMethod void testcreateCaseFromSupport(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;
        
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
    	ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
    	Case newCase = Utility.createCaseFromSupport(objAcc , 'RMA', '', recordTypeRecord);
    }*/
    
   /* static testMethod void testcreateCaseFromSupportwithContact(){
    	Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;
        
        Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        //insert contactObj;
        
    	ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
    	Case newCase = Utility.createCaseFromSupport(contactObj.id, objAcc.id, 'RMA', '', recordTypeRecord);
    }*/
    
    static testMethod void testMethodUsedForAEM()
    {
        List<Product2> prodList  = new List<Product2>();
        Product2 prodRec = TestDataFactory.createProduct('ProductNamee','SKUU', true, true, false, 12, false, false);
        prodRec.Product_Sub_Family__c = 'Blenders';
        prodRec.AX_Items_PLM_Status__c = '02-abc';
        prodRec.Country_Code__c = 'USA';
        prodRec.IsActive = true;
        prodRec.Exclude_from_Sync__c = false;
        
        prodList.add(prodRec);
        
         Product2 prodRec2 = TestDataFactory.createProduct('ProductNamee','SKUU', true, true, false, 12, false, false);
        prodRec2.Product_Sub_Family__c = 'Blenders';
        prodRec2.AX_Items_PLM_Status__c = '02-abc';
        prodRec2.Country_Code__c = 'DE';
        prodRec2.IsActive = true;
        prodRec2.brand__c = 'Sage';
        prodRec2.Exclude_from_Sync__c = false;
        prodRec2.ProdCatEN__c = 'Prod Cat EN';
        prodRec2.ProdCatDE__c = 'Prod Cat DE';
        prodRec2.ProdCatIT__c = 'Prod Cat IT';
        prodRec2.ProdCatES__c= 'Prod Cat ES';
        prodRec2.ProdCatNL__c = 'Prod Cat NL';
        prodRec2.ProdCatFR__c = 'Prod Cat FR';
        prodRec2.Remanufactured__c = true;
        prodRec2.DescriptionEN__c = 'DescriptionEN__c';
		prodRec2.DescriptionNL__c = 'DescriptionNL__c';
		prodRec2.DescriptionFR__c= 'DescriptionFR__c';
		prodRec2.DescriptionDE__c= 'DescriptionDE__c';
		prodRec2.DescriptionIT__c= 'DescriptionIT__c';
		prodRec2.DescriptionES__c= 'DescriptionES__c';
        prodRec2.Accessory__c = False;
        prodRec2.Marketing_Item__c = False;
         prodList.add(prodRec2);
        
         Product2 prodRec3 = TestDataFactory.createProduct('ProductNamee','SKUU', true, true, false, 12, false, false);
        prodRec3.Product_Sub_Family__c = 'Blenders';
        prodRec3.AX_Items_PLM_Status__c = '02-abc';
        prodRec3.Country_Code__c = 'DE';
        prodRec3.IsActive = true;
        prodRec3.brand__c = 'Sage';
        prodRec3.Exclude_from_Sync__c = false;
        prodRec3.ProdCatEN__c = 'Prod Cat EN';
        prodRec3.ProdCatDE__c = 'Prod Cat DE';
        prodRec3.ProdCatIT__c = 'Prod Cat IT';
        prodRec3.ProdCatES__c= 'Prod Cat ES';
        prodRec3.ProdCatNL__c = 'Prod Cat NL';
        prodRec3.ProdCatFR__c = 'Prod Cat FR';
        prodRec3.Remanufactured__c = true;
        prodRec3.Description_LP__c = 'Description_LP__c';
        prodRec3.Accessory__c = False;
        prodRec3.Marketing_Item__c = False;
		 prodList.add(prodRec3);
        
        Product2 prodRec4 = TestDataFactory.createProduct('ProductNamee','SKUU', true, true, false, 12, false, false);
        prodRec4.Product_Sub_Family__c = 'Blenders';
        prodRec4.AX_Items_PLM_Status__c = '02-abc';
        prodRec4.Country_Code__c = 'CAN';
        prodRec4.IsActive = true;
        prodRec4.brand__c = 'Breville';
        prodRec4.Exclude_from_Sync__c = false;
        prodRec4.ProdCatFR__c = 'Prod Cat FR';
      	prodRec4.Remanufactured__c = true;
		prodRec4.Description_LP2__c = 'Description_LP2__c';
        prodRec4.Accessory__c = False;
        prodRec4.Marketing_Item__c = False;
        
        Product2 prodRec5 = TestDataFactory.createProduct('ProductNamee','SKUU', true, true, false, 12, false, false);
        prodRec5.Product_Sub_Family__c = 'Blenders';
        prodRec5.AX_Items_PLM_Status__c = '02-abc';
        prodRec5.Country_Code__c = 'CAN';
        prodRec5.IsActive = true;
        prodRec5.brand__c = 'Breville';
        prodRec5.Exclude_from_Sync__c = false;
        prodRec5.ProdCatFR__c = 'Prod Cat FR1';
      	prodRec5.Remanufactured__c = true;
        prodRec5.Description = 'Description';
        prodRec5.Accessory__c = False;
        prodRec5.Marketing_Item__c = False;
        
        Product2 prodRec6 = TestDataFactory.createProduct('ProductNamee','SKUU', true, true, false, 12, false, false);
        prodRec6.Product_Sub_Family__c = 'Blenders';
        prodRec6.AX_Items_PLM_Status__c = '02-abc';
        prodRec6.Country_Code__c = 'DE';
        prodRec6.IsActive = true;
        prodRec6.brand__c = 'Sage';
        prodRec6.Exclude_from_Sync__c = false;
        prodRec6.ProdCatEN__c = 'Prod Cat EN';
        prodRec6.ProdCatDE__c = 'Prod Cat DE';
        prodRec6.ProdCatIT__c = 'Prod Cat IT';
        prodRec6.ProdCatES__c = 'Prod Cat ES';
        prodRec6.ProdCatNL__c = 'Prod Cat NL';
        prodRec6.ProdCatFR__c = 'Prod Cat FR';
      	prodRec6.Remanufactured__c = true;
        prodRec6.Description = 'Description';
        prodRec6.Accessory__c = False;
        prodRec6.Marketing_Item__c = False;
		
		prodList.add(prodRec5);
        insert prodList;
        
        Set<String> plmStatusNotStartsWith = new Set<String>{'01%', '00%', '99%','04%'};
        Utility.getPickValues(new Case(),'Type',null);
        Utility.fetchProductSubcategories('USA','Sage','01%',null);
        Utility.fetchProducts('USA', 'Blenders', 'z', plmStatusNotStartsWith,'', null, 'en');
        Utility.fetchProducts('USA', 'Blenders', 'Breville', 'aa','', null);
        Utility.fetchAllProducts('USA', 'Breville', '01%', null, null, null);
        Utility.fetchAllProducts('CAN', 'Breville', '', '', null, ''); 
        Utility.fetchProducts('CAN', 'Prod Cat FR', 'Breville', plmStatusNotStartsWith, '', null, 'fr');
        Utility.fetchProducts('CAN', 'Prod Cat FR1', 'Breville', plmStatusNotStartsWith, '', null, 'fr');
        Utility.fetchAllProducts('DE', 'Sage', '', '', null, ''); 
        Utility.fetchAllProducts('USA', 'Sage', '01%', null, null); 
         Utility.fetchProductSubcategories('USA','Breville',plmStatusNotStartsWith,null,'en');
        Utility.fetchProducts('DE', 'Prod Cat DE', 'Sage', plmStatusNotStartsWith,'', null, 'de');
        Utility.fetchProducts('DE', 'Prod Cat EN', 'Sage', plmStatusNotStartsWith,'', null, 'en');
        Utility.fetchProducts('DE', 'Prod Cat IT', 'Sage', plmStatusNotStartsWith,'', null, 'it');
        Utility.fetchProducts('DE', 'Prod Cat ES', 'Sage', plmStatusNotStartsWith,'', null, 'es');
        Utility.fetchProducts('DE', 'Prod Cat FR', 'Sage', plmStatusNotStartsWith,'', null, 'fr');
        Utility.fetchProducts('DE', 'Prod Cat NL', 'Sage', plmStatusNotStartsWith,'', null, 'nl');
        Utility.fetchProducts('DE', 'Blenders', 'Sage', plmStatusNotStartsWith,'', null, 'hindi');
        Utility.fetchAllProducts('CAN', 'Breville', '01%','', null, 'fr');
        Utility.fetchAllProducts('CAN',  'Breville', '01%','', null, 'en');
         Utility.fetchAllProducts('DE', 'Sage', '01%', '', null, 'de');
        Utility.fetchProductSubcategories('DE','Sage',plmStatusNotStartsWith,null,'de');
        Utility.fetchProductSubcategories('DE','Sage',plmStatusNotStartsWith,null,'it');
        Utility.fetchProductSubcategories('DE','Sage',plmStatusNotStartsWith,null,'es');
		Utility.fetchProductSubcategories('DE','Sage',plmStatusNotStartsWith,null,'nl');
        Utility.fetchProductSubcategories('DE','Sage',plmStatusNotStartsWith,null,'hindi');
        Utility.currencyBasedRegions('USA');
        Utility.fetchCurrencyCodeFromEPRegion('USA');
        Utility.fetchBusinessUnitEPRegion('USA');
        Utility.fetchBusinessUnitFromCurrencyCode('USD');
        Utility.fetchRegionCodeFromEPRegion('USA');
        Utility.fetchLanguageCodeFromCountryCode('USA');
        Utility.validateEmail('testmail@gmail.com','testmail@gmail.com');
        Utility.validateEmail('testmail','testmail');
        Utility.validateEmail('testmail@gmail.com','testmail1@gmail.com');
        Utility.isValidEmail('testmail@gmail.com');
        Utility.regionBased('USD');
        Utility.fetchCaseTypes('Case Type To Ignore');
        Utility.validateBillingStreet('Denkmaschinenstrasse 1024');
        Utility.validatePostalCode(' ', 'CAN');
        Utility.validatePurchaseDate(Date.today() + 1);
        Utility.fetchAllLiteralValue('Product_Registration2');
        Utility.findExistingAccount('jhilik_gandhi@persistent.com');
        Utility.findExistingAccount(new Set<String> { 'jhilik_gandhi@persistent.com' });
        Utility.isBatchRunning('NotifyMeBatch');
        //Utility.createRegionToPricebookMap(new List<String>('US'));
        //Utility.createRegionToWholesalePricebookMap(new List<String>('US'), new List<String>('Breville'));
        Utility.fetchPurchasedFrom('Amazon');
        User userRec = new TestObjects().getUser(false);
        insert userRec;
        Utility.updateUser(userRec, 'Test', 'Test', 'test@example.com');
    }
    
    static testMethod void testisDuplicateAsset(){
        Product2 product = new Product2(Name= '.505-239',Description = '28L ALL SS TANK IN SS CASE  PACKAGED', SKU__c='.505-239',Warranty_In_Months__c=15,
                                        Extended_Warranty_in_months__c=3,Always_in_Warranty__c=true,AX_Item_Number__c = 'TestAXNumber',IsActive = true, 
                                        Spare_Part__c = false, Accessory__c =false, Finished_Good__c = true,Country_Code__c='USA',Exclude_from_Sync__c = false, 
                                        Brand__c='Breville', Serial_Required_for_Registration__c = true); 
        insert product; 
        
        RecordType personAccountRecordType=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']; 
        Account acc = new Account();
        acc.FirstName = 'Joe';
        acc.LastName = 'Bob';
        acc.PersonEmail = 'test@example.com';
        acc.RecordTypeId = personAccountRecordType.Id;
        insert acc;
        
        Asset ast=new Asset();
        ast.Name= 'Test 123';
        ast.AccountId = acc.Id;
        ast.Batch_Code__c = '1720';
        ast.Product2Id = product.Id;
        insert ast;
        
        Test.startTest();
    	Boolean isDuplicateAst = Utility.isDuplicateAsset(acc.Id, product.AX_Item_Number__c, '1720');
        Test.stopTest();
        
        System.assertEquals(true, isDuplicateAst);
    }
    
    static testMethod void testsendTemplateEmail(){
        List<User> userList = [Select Id, Name, Alias from User Where Alias='Jhil'];
        Utility.sendTemplateEmail(userList, 'test_email_template', null, false, 'askus@brevilleusa.com');
    }
    
    static testMethod void testCreateUpdateAccount() {
        Account objAcc = new Account();
        objAcc.Name = 'Joe';
        insert objAcc;
        Case cse = TestDataFactory.createCase(objAcc.Id, 'Phone', 'Open', 'Test Case', 'USD', true);
        Set<String> caseNumberSet = new Set<String>();
        caseNumberSet.add(cse.CaseNumber);
        Utility.createUpdateAccount(objAcc, objAcc, '221 B, Baker Street', 'USD');
        Utility.createUpdateAccount(objAcc, objAcc, 'USD');
        Utility.createCaseMap(caseNumberSet);
        
        Account objAcc2 = new Account();
        objAcc2.Name = 'Joe';
        objAcc2.Type = 'Authorized Service Center';
        insert objAcc2;
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(objAcc2.Id);
        Utility.getPartnerUserIdByAccountId(accIdSet);
    }

	static testMethod void testCreateRegionToPricebookMap() {
        Map<String, String> regionSet = new Map<String, String>();
        regionSet.put('USD', 'USA');
     	set<String> tempRegionSet = new set<String>();
        tempRegionSet.addAll(regionSet.values());
       
        set<String> brandSet = new set<String>();
        brandSet.add('Breville');
        
        Account accountRecord = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BUS','nikhil998@example.com','9527785432');
        accountRecord.BillingCity = 'Colma';
        accountRecord.BillingPostalCode = '94014';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingStreet = '1000 El Camino Real';
        accountRecord.BillingStateCode = 'CA';
        accountRecord.ShippingCountryCode = 'US';
        accountRecord.ShippingCity = 'Colma';
        accountRecord.ShippingPostalCode = '94014';
        accountRecord.ShippingStateCode = 'CA';
        insert accountRecord;
        
        Case cseRec = new Case();
        cseRec.AccountId = accountRecord.Id;
        insert cseRec;
        
		Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
		ServiceCentreAccount.BillingPostalCode = '440022';
		ServiceCentreAccount.ShippingPostalCode = '440022';
		insert ServiceCentreAccount;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
 		standardPricebook.Region__c = 'USA';
        standardPricebook.Brand__c = 'Breville';
        standardPricebook.Type__c = 'Wholesale';
        Update standardPricebook;

        WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(null, accountRecord.Id, 'USD', standardPricebook.Id, ServiceCentreAccount.Id, 'workorder1@example.com','440022');
		
        Utility.createRegionToPricebookMap(tempRegionSet);
        Utility.createRegionToWholesalePricebookMap(tempRegionSet, brandSet);
        Utility.createBoxOrderRecordFromCase(cseRec.Id);
    }
    
    @isTest
    static void testCreateUserShare() {
        Account accountRecord = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BUS','nikhil998@example.com','9527785432');
        insert accountRecord;
        System.assertNotEquals(null, Utility.createUserShare(accountRecord.Id, UserInfo.getUserId()));
    }
    
    @isTest
    static void testCreateUpdateAccount2() {
        Account accountRecord = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BUS','nikhil998@example.com','9527785432');
        insert accountRecord;
        
        Account updatedAccount = Utility.createUpdateAccount(null, accountRecord, 'Fleet Street', 'USD', 'English');
        
        System.assertEquals('English', updatedAccount.PreferredLanguage__c);
    }
    
    @isTest
    static void testToJustIncreaseCoverage() {
        Map<String, Id> regionMap = Utility.createRegionToPricebookMap( new set<String> {'AUS', 'UK', 'USA'});
        
        map<String, map<String, Id>> regionbrandmap = Utility.createRegionToWholesalePricebookMap(new set<String> {'AUS', 'UK', 'USA'}, new set<String> {'Breville', 'PolyScience', 'Sage'});
        
        String currencyCode = Utility.fetchCurrencyCodeFromCountry('US');
        
        String regionCode = Utility.fetchRegionCodeFromCountry('US');
        
        map<String,String> fieldMapping = Utility.getOrderFieldMappingForCase();
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        insert caseRecord;
        
        // System.assertNotEquals(null, Utility.createOrder(caseRecord));
        List<Account> accs = Utility.fetchAccountDetailsFromRegion('US');
        
        Boolean isValid = Utility.validatePurchaseDate(Date.today(), 'US');
        
        Date testDate1 = Utility.convertDateToRegionSpecific(Datetime.now(), 'US');
        
        Boolean isCountryValid = Utility.countryValidation('US', 'US');
        
        String currencyCode1 = Utility.fetchCurrencyCodeFromEPRegionAPI('US');
        
        String businessUnit = Utility.fetchBusinessUnitEPRegionAPI('US');
        
        String regionCode1 = Utility.fetchRegionCodeFromEPRegionAPI('US');
        
        List<SelectOption> options = Utility.getBusinessUnits();
        
        System.assertEquals('French', Utility.getLanguageFromLanguageCode('fr'));
        System.assertEquals('German', Utility.getLanguageFromLanguageCode('de'));
        System.assertEquals('Italian', Utility.getLanguageFromLanguageCode('it'));
        System.assertEquals('English', Utility.getLanguageFromLanguageCode('en'));
        System.assertEquals('Dutch', Utility.getLanguageFromLanguageCode('nl'));
        System.assertEquals('Spanish', Utility.getLanguageFromLanguageCode('es'));
        System.assertEquals('Portuguese', Utility.getLanguageFromLanguageCode('pt'));
        
        System.assertEquals('fr', Utility.getLanguageCodeFromLanguage('French'));
        System.assertEquals('de', Utility.getLanguageCodeFromLanguage('German'));
        System.assertEquals('it', Utility.getLanguageCodeFromLanguage('Italian'));
        System.assertEquals('en', Utility.getLanguageCodeFromLanguage('English'));
        System.assertEquals('nl', Utility.getLanguageCodeFromLanguage('Dutch'));
        System.assertEquals('es', Utility.getLanguageCodeFromLanguage('Spanish'));
        System.assertEquals('pt', Utility.getLanguageCodeFromLanguage('Portuguese'));
        
        String businessUnit2 = Utility.fetchBusinessUnitFromCountryCode('US');
        
        Boolean isProduction = Utility.isProductionOrg();
    }
    
    @isTest
    static void testIsAvailableToSell() {
        insert new InventorySetting__c(AXAccounts__c='CUS30006');
        Order orderObj = new Order(AX_Order_Account__c = 'CUS30006', Type='Accommodation');
        Product2 productObj = new Product2(AX_Reserved_Inventory__c = 3, Available_To_Sell__c = false);
        Test.startTest();
        System.assert(Utility.isAvailableToSell(orderObj, productObj));
        Test.stopTest();
    }
}