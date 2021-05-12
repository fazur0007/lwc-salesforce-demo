@isTest
public with sharing class OrderRejectionBatchForLoanerTest {

    @testSetup
    public static void setupData() {
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
        objProd.Quantity_Available__c = 34;
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
        //lp.PriceBookEntryId__c='01u2C0000093EyOQAU';
        lp.PriceBookEntryId__c=standardPrice.Id;
        lp.ProgramName__c = 'Control_Freak';
        lp.Run_Selection_Process__c =true;
        lp.Initial_Amount__c=100;
        insert lp;
        
        Loaner_Nomination__c ln= new Loaner_Nomination__c();
        ln.Status__c='Nomination Applied';
        ln.Account__c=Acc.id;
        ln.Loaner_Program__c=lp.id;
        ln.Link_Expiration_date__c = system.today() - 8;
        insert ln;
        
        Loaner_Nomination__c lnn= new Loaner_Nomination__c();
        //lnn.Status__c='Nomination Applied';
        lnn.Account__c=Acc.id;
        lnn.Loaner_Program__c=lp.id;
        lnn.Link_Expiration_date__c = system.today() + 1;
        insert lnn;
        
        Order orderObj = new Order();
        orderObj.AccountId =Acc.Id;
        orderObj.LoanerProgram__c =lp.id;
        orderObj.Loaner_Nomination__c = ln.id;
        orderObj.Status = 'Open';
        orderObj.type='Loaner Program Sale';
        orderObj.EffectiveDate =system.today()-9;
        insert orderObj;
        
        /*Order ordObj = new Order();
        ordObj.AccountId =Acc.Id;
        ordObj.LoanerProgram__c =lp.id;
        ordObj.Loaner_Nomination__c = lnn.id;
        ordObj.Status = 'Open';
        ordObj.type = 'Loaner Program Sale';
        ordObj.EffectiveDate =system.today()+9;
        insert ordObj;*/
    }
    
    static testMethod void testMethodRejection(){
        Test.startTest();
        String batchExecute = Database.executeBatch(new OrderRejectionBatchForLoaner(), 10);
       	Test.stopTest();
        Order order=[Select Id,AccountId,LoanerProgram__c,Status,type FROM Order];
        System.assertEquals('Cancelled', order.Status, 'Order Cancelled');
    }
    static testmethod void testOrderRejectionBatchForLoanerSchedulable() {
        Test.startTest();
        OrderRejectionBatchForLoaner orbl= new OrderRejectionBatchForLoaner();
        String jobID = System.schedule('Schedule for all records Test ' + System.now(), '0 0 15 * * ?', orbl);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    static testMethod void orderRejectionErrorInOrder(){
        Test.startTest();
        /*Loaner_Nomination__c lnRec = new Loaner_Nomination__c();
        List<Loaner_Nomination__c> lnList = new List<Loaner_Nomination__c>{lnRec};
        OrderRejectionBatchForLoaner rejectionBatchInstace = new OrderRejectionBatchForLoaner();
        rejectionBatchInstace.LoanerNomListToUpdate = lnList;
        Account acc = [Select Id from Account Where FirstName='SF Testing'];*/
        OrderRejectionBatchForLoaner.AccountId= '0012C00000MVglM';
        //delete acc;
        String batchExecute = Database.executeBatch(new OrderRejectionBatchForLoaner(), 10);
       	Test.stopTest();
        List<Error_Log__c> errLog=[Select Id FROM Error_Log__c];
        System.assertEquals(0, errLog.size());
    }
    
    static testMethod void orderRejectionErrorInLoanerNom(){
        Test.startTest();
        OrderRejectionBatchForLoaner.LoanerProgramId= 'a4B2C0000009Rm2';
        String batchExecute = Database.executeBatch(new OrderRejectionBatchForLoaner(), 10);
       	Test.stopTest();
        List<Error_Log__c> errLog=[Select Id FROM Error_Log__c];
        System.assertEquals(0, errLog.size());
    }
    
}