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
private class CreateShipmentHandlerTest {

    public static Account testAccount,testAccount2 , testAcc3, testAccount3, testAccount4;
    public static Contact testContact ;
    public static Case testCase,testCase2 ,testCase3, testCase4,testCase5 ;
    public static CanadaPostWebServiceHelp__c objCanadaPostWebServHelp;
    public static EmailTemplate template1;

    public static void init()
    {
        RecordType personAccRecType = [SELECT SobjectType,
                                              Id,
                                              DeveloperName
                                         FROM RecordType
                                        WHERE DeveloperName = 'PersonAccount'
                                          AND SobjectType ='Account'
                                        LIMIT 1 ];

        RecordType businessAccRecType = [SELECT SobjectType,
                                                Id,
                                                DeveloperName
                                           FROM RecordType
                                          WHERE DeveloperName = 'Business_Account'
                                            AND SobjectType ='Account'
                                          LIMIT 1 ];

        testAccount = new Account();
        testAccount.recordTypeId = personAccRecType.Id;
        testAccount.FirstName = 'SFDC';
        testAccount.LastName = 'Axel';
        testAccount.personBirthDate = Date.newInstance(1980,5,11);
        testAccount.personMailingStreet = '33 Lincoln Street';
        testAccount.personMailingCity = 'London';
        testAccount.personMailingPostalCode = 'E8 WH1';
        testAccount.personMailingCountryCode = 'CA';
        testAccount.personEmail = 'axel@sales.com';
        testAccount.personHomePhone = '+44 (1234) 788145';
        testAccount.personMobilePhone = '+44 (1234) 963371';
        testAccount.ShippingStreet= '33 Lincoln Street';
        testAccount.ShippingCity = 'London';
        testAccount.ShippingPostalCode = 'E8WH11';
        testAccount.ShippingCountryCode= 'CA';
        testAccount.ShippingStateCode ='NT';
        insert testAccount;

       /* testAcc3 = new Account();
        testAcc3 .recordTypeId = personAccRecType.Id;
        testAcc3 .FirstName = 'SFDC';
        testAcc3 .LastName = 'Axel';
        testAcc3 .personBirthDate = Date.newInstance(1980,5,11);
        testAcc3 .personMailingStreet = '33 Lincoln Street';
        testAcc3 .personMailingCity = 'London';
        testAcc3 .personMailingPostalCode = 'E8 WH1';
        testAcc3 .personMailingCountry = 'GB';
        testAcc3 .personEmail = '';
        testAcc3 .personHomePhone = '+44 (1234) 788145';
        testAcc3 .personMobilePhone = '+44 (1234) 963371';

        insert testAcc3 ;
        */

        testAccount2 = new Account();
        testAccount2 .recordTypeId = personAccRecType.Id;
        testAccount2 .FirstName = '';
        testAccount2 .LastName = 'Axel';
        testAccount2 .personBirthDate = Date.newInstance(1980,5,11);
        testAccount2 .personMailingStreet = '33 Lincoln Street';
        testAccount2 .personMailingCity = 'London';
        testAccount2 .personMailingPostalCode = 'E8 WH1';
        testAccount2 .personMailingCountryCode = 'CA';
        testAccount2 .personEmail = '';
        testAccount2 .personHomePhone = '+44 (1234) 788145';
        testAccount2 .personMobilePhone = '+44 (1234) 963371';
        insert testAccount2;

        testAccount3 = new Account();
        testAccount3.recordTypeId = businessAccRecType.Id;
        testAccount3.Name = System.label.DRPAccount;
        testAccount3.ShippingStreet= '33 Lincoln Street';
        testAccount3.ShippingCity = 'London';
        testAccount3.ShippingPostalCode = 'E8WH11';
        testAccount3.ShippingCountryCode= 'CA';
        testAccount3.ShippingStateCode ='NT';
        testAccount3.Type = 'Authorized Service Center';
        insert testAccount3;

        testAccount4 = new Account();
        testAccount4.recordTypeId = businessAccRecType.Id;
        testAccount4.Name = 'Business Account';
        testAccount4.ShippingStreet= '33 Lincoln Street';
        testAccount4.ShippingCity = 'London';
        testAccount4.ShippingPostalCode = 'E8WH11';
        testAccount4.ShippingCountryCode= 'CA';
        testAccount4.ShippingStateCode ='NT';
        testAccount4.Type = 'Authorized Service Center';
        insert testAccount4;

        testContact =[Select Id from Contact Limit 1];

        Product2 objPrd = new Product2();
        objPrd.SKU__c = 'Test';
        objPrd.Weight__c = 1.0;
        objPrd.Height__c = 1.0;
        objPrd.Length__c = 1.0;
        objPrd.Width__c = 1.0 ;
        objPrd.Dimensions__c = 'Test';
        objPrd.Name = 'Test';
        objPrd.Breville_US_Product__c = true;
       // objPrd.Country_Code__c = 'CAN'
        insert objPrd;

        RecordType caseRecord = [SELECT id,
                                        Name
                                   FROM RecordType
                                  WHERE SobjectType = 'Case'
                                    AND isActive = true
                                    AND DeveloperName = 'New_Case'];

        testCase = new Case();
        testCase.RecordTypeId = caseRecord.Id;
        testCase.Status = 'Open';
        testCase.Type = 'Feedback';
        testCase.Origin = 'Phone';
        testCase.AccountId = testAccount.Id;
        testCase.ContactId = testContact.Id;
        testCase.Complaint_Code__c = 'Frothing/Steaming';
        testCase.Subject = 'Test Subject';
        testCase.Order_Date__c = Date.newInstance(1980,5,11) ;
        testCase.Order_Ship_Date__c = Date.newInstance(1980,8,11) ;
        insert testCase;

        testCase2 = new Case();
        testCase2.RecordTypeId = caseRecord.Id;
        testCase2 .Status = 'Open';
        testCase2 .Type = 'Feedback';
        testCase2 .Origin = 'Phone';
        testCase2 .AccountId = testAccount2.Id;
        testCase2 .ContactId = testContact.Id;
        testCase2 .Complaint_Code__c = 'Frothing/Steaming';
        testCase2 .Subject = 'Test Subject';
        testCase2 .Order_Date__c = Date.newInstance(1980,5,11) ;
        testCase2 .Order_Ship_Date__c = Date.newInstance(1980,8,11) ;
        testCase2.Product__c = objPrd.Id;
        insert testCase2;

        testCase4 = new Case();
        testCase4.RecordTypeId = caseRecord.Id;
        testCase4.Status = 'Open';
        testCase4.Type = 'Feedback';
        testCase4.Origin = 'Phone';
        testCase4.AccountId = testAccount2.Id;
        testCase4.ContactId = testContact.Id;
        testCase4.Complaint_Code__c = 'Frothing/Steaming';
        testCase4.Subject = 'Test Subject';
        testCase4.Service_Center__c = testAccount3.Id;
        testCase4.Order_Date__c = Date.newInstance(1980,5,11) ;
        testCase4.Order_Ship_Date__c = Date.newInstance(1980,8,11) ;
        insert testCase4;

       /*  testCase3 = new Case();
        testCase3 .Status = 'Open';
        testCase3 .Type = 'Feedback';
        testCase3 .Origin = 'Phone';
        testCase3 .AccountId = testAcc3.Id;
        testCase3 .ContactId = testContact.Id;
        testCase3 .Complaint_Code__c = 'Frothing/Steaming';
        testCase3 .Subject = 'Test Subject';
        testCase3 .Order_Date__c = Date.newInstance(1980,5,11) ;
        testCase3 .Order_Ship_Date__c = Date.newInstance(1980,8,11) ;
        testCase3.Product__c = objPrd.Id;
        insert testCase3;*/

        List<Case>  lstCase4 = [select CaseNumber
                                  from Case
                                 where Id = :testCase4.Id LIMIT 1];

        objCanadaPostWebServHelp = new CanadaPostWebServiceHelp__c();
        objCanadaPostWebServHelp.Name = lstCase4[0].CaseNumber;
        insert objCanadaPostWebServHelp;

    }

    // Create Shipment Test
     static testMethod void CreateShipmentTest() {

        // TO DO: implement unit test
        Test.startTest();
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
         pageRef.getParameters().put('id',testCase.id);
         Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);

      // Test.startTest();
      //  Test.setMock(HttpCalloutMock.class , new MockHttpResponseGenerator());
        objHandler.init();
        //CreateShipmentButtonHandler.CreateShipment(testCase.Id);
        Test.stopTest();
    }

     static testMethod void CreateShipmentTestMethod1() {

        // TO DO: implement unit test
        Test.startTest();
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
        pageRef.getParameters().put('id',testCase4.id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);
        objHandler.init();

        Test.stopTest();
    }

   /*  static testMethod void CreateShipmentTest4() {
        // TO DO: implement unit test
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
         pageRef.getParameters().put('id',testCase3.id);
         Test.setCurrentPage(pageRef);
         ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class , new MockHttpResponseGenerator());
        objHandler.init();
        //CreateShipmentButtonHandler.CreateShipment(testCase.Id);
        Test.stopTest();
    }*/

    static testMethod void CreateShipmentTest2() {
        // TO DO: implement unit test
       Test.startTest();
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
         pageRef.getParameters().put('id',testCase2.id);
         Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);

       // Test.setMock(HttpCalloutMock.class , new MockHttpResponseGenerator());
        objHandler.init();
      //  CreateShipmentButtonHandler.CreateShipment(testCase2 .Id);
        Test.stopTest();
        
         objHandler.getShipmentPDfFromLink('TestLink',testCase2.id);
         
    }

    static testMethod void CreateShipmentTestMethod2() {
        // TO DO: implement unit test
       Test.startTest();
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
         pageRef.getParameters().put('id',testCase4.id);
         pageRef.getParameters().put('pdflink',objCanadaPostWebServHelp.id);
         Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);

       // Test.setMock(HttpCalloutMock.class , new MockHttpResponseGenerator());
        objHandler.init();
      //  CreateShipmentButtonHandler.CreateShipment(testCase2 .Id);
        Test.stopTest();
        
         objHandler.getShipmentPDfFromLink(objCanadaPostWebServHelp.id,testCase4.id);
         
    }


 /*  static testMethod void CreateShipmentTest4() {
        // TO DO: implement unit test
        Test.startTest();
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
         pageRef.getParameters().put('id',testCase2.id);
         pageRef.getParameters().put('pdflink','Testparameter');
         Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);
        
       
      //  Test.setMock(HttpCalloutMock.class , new MockHttpResponseGenerator());
        objHandler.init();
      //  CreateShipmentButtonHandler.CreateShipment(testCase2 .Id);
        Test.stopTest();
    }*/

    static testMethod void CreateShipmentTest3() {
        // TO DO: implement unit test
       Test.startTest();
        init();
        Pagereference pageRef = Page.CreateShipmentPopUp;
         //pageRef.getParameters().put('id',testCase2.id);
         Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(new Case());
        CreateShipmentHandler objHandler = new CreateShipmentHandler(sc);
        try
        {
       // Test.startTest();
       // Test.setMock(HttpCalloutMock.class , new MockHttpResponseGenerator());
        objHandler.init();
        
      //  CreateShipmentButtonHandler.CreateShipment(testCase2 .Id);
        } catch(Exception e)
        {
        }
        Test.stopTest();
    }
    
    
}