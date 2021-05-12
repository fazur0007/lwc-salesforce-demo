@isTest
public with sharing class SignUpForLoanerProgramControllerTest {
    @testSetup
    public static void setupData() {
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        insert objProd;  
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = objProd.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = objProd.id, UnitPrice = 1250.0, IsActive = true);
        insert standardPriceNew;
        
        Loaner_Program__c lp = new Loaner_Program__c();
        lp.Active__c= true;
        lp.Product__c=objProd.id;
        lp.PriceBook__c=pricebookRecord.id;
        lp.PriceBookEntryId__c='01u2C0000093EyOQAU';
        lp.ProgramName__c = 'Control_Freak';
        lp.Run_Selection_Process__c =true;
        lp.Initial_Amount__c=100;
        lp.SuccessMessage__c='Success_Message';
        insert lp;
        
    }
    
    static testMethod void testMethodsubscriptionSave(){
        Account objAcc = new Account();
        objAcc.FirstName='Testing';
        objAcc.LastName='Acc';
        objAcc.PersonEmail='Testing@gmail.com';
        objAcc.Agreed_for_Opt_in__c=true;
        objAcc.Phone = '43534545';
        objAcc.BillingCountryCode = 'US';
        objAcc.BillingStreet = '23 maitreya';
        objAcc.BillingCity = 'LA';
        objAcc.BillingStateCode = 'CA';
        objAcc.BillingPostalCode ='470027' ;
        
        Account Acc = new Account();
        Acc.FirstName='SF Testing';
        Acc.LastName='Acc';
        Acc.PersonEmail='Test@gmail.com';
        Acc.Agreed_for_Opt_in__c=true;
        Acc.Phone = '43534545';
        Acc.BillingCountryCode = 'US';
        Acc.BillingStreet = '23 maitreya';
        Acc.BillingCity = 'LA';
        Acc.BillingStateCode = 'CA';
        Acc.BillingPostalCode ='470027' ;
        insert Acc;
        
        PageReference pageRef = Page.SignUpForLoanerProgram;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('language', 'en_US');
        pageRef.getParameters().put('pgm', 'Control_Freak');
        pageRef.getParameters().put('param', 'US');
        
        SignUpForLoanerProgramController sign = new SignUpForLoanerProgramController();
        
        sign.regionCode = 'US';
        sign.currencyCode = 'USD';
        sign.lang = 'en_US';
        sign.program = 'Control_Freak';
        
        Test.starttest();
        
        sign.checkRequiredFields();
        sign.dummyAccount =objAcc;
        sign.checkRequiredFields();
        sign.subscriptionSave();
        sign.dummyAccount= Acc;
        sign.subscriptionSave();
        
        Test.stopTest();
    }
}