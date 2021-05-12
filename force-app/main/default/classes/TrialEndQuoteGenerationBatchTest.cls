@isTest
public class TrialEndQuoteGenerationBatchTest {

    @istest
    public static void generateQuoteForLoanerNom(){
        
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
        
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        objProd.Quantity_Available__c=10;
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
        lp.Program_Validity__c=0;
        insert lp;
        
        Integer days=Integer.valueOf(lp.Program_Validity__c);
        Loaner_Nomination__c ln= new Loaner_Nomination__c();
        ln.Status__c='Trial In Progress';
        ln.Account__c=Acc.id;
        ln.Loaner_Program__c=lp.id;
        insert ln;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        
        Order order = TestDataFactory.createOrderRecord(Acc.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Loaner Program Sale',
                                                               '', 'Breville','USD');
        
        order.Country__c='USA';
        order.BillingCity = 'Miami';
        order.BillingCountryCode = 'ES';
        order.BillingPostalCode = '33190';
        order.BillingStreet = 'Calle de Claudio Coello, 65';
        order.ShippingCountryCode = 'ES';
        order.ShippingCity = 'Miami';
        order.ShippingPostalCode = '28001';
        order.ShippingStreet = 'Calle de Claudio Coello, 65';
        order.Shipping_Method__c='TMS';
        order.Pricebook2Id = pricebookRecord.id;
        order.AccountId=Acc.Id;
        order.Channel__c='CCC';
        order.Source__c='Breville';
      
        order.EndDate=Date.today();
        order.CurrencyIsoCode='USD';
        order.LoanerProgram__c=lp.Id;
        order.Status='Open';
        order.Type='Loaner Program Sale';
        order.Loaner_Nomination__c=ln.Id;
        insert order;
        
        Test.starttest();
        TrialEndQuoteGenerationBatch trialEndQuote=new TrialEndQuoteGenerationBatch();
    	ID batchprocessid = Database.executeBatch(trialEndQuote);
        test.stopTest();
        Order orderDetails=[Select PaymentId__c,Loaner_Nomination__c,Loaner_Nomination__r.TrialEnd_PayLink__c from Order];
       // System.assertNotEquals(null, orderDetails.Loaner_Nomination__r.TrialEnd_PayLink__c);
      // 	System.assertNotEquals(null, orderDetails.PaymentId__c);
        
    }
    
    @istest
    public static void generateQuoteForLoanerNomErrorLog(){
        
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
        
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        objProd.Quantity_Available__c=10;
        TrialEndQuoteGenerationBatch.AccId='0012C00000MVglM';
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
        lp.Program_Validity__c=0;
        insert lp;
        
        Integer days=Integer.valueOf(lp.Program_Validity__c);
        Loaner_Nomination__c ln= new Loaner_Nomination__c();
        ln.Status__c='Trial In Progress';
        ln.Account__c=Acc.id;
        ln.Loaner_Program__c=lp.id;
        TrialEndQuoteGenerationBatch.LoanerProgramId='a4B2C0000009Rm2';
        insert ln;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        
        Order order = TestDataFactory.createOrderRecord(Acc.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Loaner Program Sale',
                                                               '', 'Breville','USD');
        
        order.Country__c='USA';
        order.BillingCity = 'Miami';
        order.BillingCountryCode = 'ES';
        order.BillingPostalCode = '33190';
        order.BillingStreet = 'Calle de Claudio Coello, 65';
        order.ShippingCountryCode = 'ES';
        order.ShippingCity = 'Miami';
        order.ShippingPostalCode = '28001';
        order.ShippingStreet = 'Calle de Claudio Coello, 65';
        order.Shipping_Method__c='TMS';
        order.Pricebook2Id = pricebookRecord.id;
        order.AccountId=Acc.Id;
        order.Channel__c='CCC';
        order.Source__c='Breville';
      
        order.EndDate=Date.today();
        order.CurrencyIsoCode='USD';
        order.LoanerProgram__c=lp.Id;
        order.Status='Open';
        order.Type='Loaner Program Sale';
        order.Loaner_Nomination__c=ln.Id;
        insert order;
        
        Test.starttest();
        TrialEndQuoteGenerationBatch trialEndQuote=new TrialEndQuoteGenerationBatch();
    	ID batchprocessid = Database.executeBatch(trialEndQuote);
        test.stopTest();
        Order orderDetails=[Select PaymentId__c,Loaner_Nomination__c,Loaner_Nomination__r.TrialEnd_PayLink__c from Order];
       // System.assertNotEquals(null, orderDetails.Loaner_Nomination__r.TrialEnd_PayLink__c);
      // 	System.assertNotEquals(null, orderDetails.PaymentId__c);
        
    }
    
    static testmethod void testTrialEndQuoteGenerationBatchSchedulable() {
        Test.startTest();
        TrialEndQuoteGenerationBatch teg= new TrialEndQuoteGenerationBatch();
        String jobID = System.schedule('Schedule for all records Test ' + System.now(), '0 0 15 * * ?', teg);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}