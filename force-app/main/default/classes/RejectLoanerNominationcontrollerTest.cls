@isTest
public class RejectLoanerNominationcontrollerTest {
    
    
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
        lp.SuccessMessage__c='Success_Message';
        insert lp;
        
        Loaner_Nomination__c loanerNomWithNominationApplied= new Loaner_Nomination__c();
        loanerNomWithNominationApplied.Status__c='Order Created-Quote Sent';
        loanerNomWithNominationApplied.Account__c=Acc.id;
        loanerNomWithNominationApplied.Loaner_Program__c=lp.id;
        insert loanerNomWithNominationApplied;
        
        
        Loaner_Nomination__c loanerNomWithOfferAccepted= new Loaner_Nomination__c();
        loanerNomWithOfferAccepted.Status__c='Trial Offer Accepted';
        loanerNomWithOfferAccepted.Account__c=Acc.id;
        loanerNomWithOfferAccepted.Loaner_Program__c=lp.id;
        insert loanerNomWithOfferAccepted;
        
        
        Loaner_Nomination__c loanerNomWithOfferRejected= new Loaner_Nomination__c();
        loanerNomWithOfferRejected.Status__c='Trial Offer Rejected';
        loanerNomWithOfferRejected.Account__c=Acc.id;
        loanerNomWithOfferRejected.Loaner_Program__c=lp.id;
        insert loanerNomWithOfferRejected;
        
        Loaner_Nomination__c loanerNomWithLinkExpired= new Loaner_Nomination__c();
        loanerNomWithLinkExpired.Status__c='Selected for Program';
        loanerNomWithLinkExpired.Account__c=Acc.id;
        loanerNomWithLinkExpired.Loaner_Program__c=lp.id;
        loanerNomWithLinkExpired.Link_Expiration_date__c=Date.today().addDays(-10);
        insert loanerNomWithLinkExpired;
        
        Loaner_Nomination__c loanerNomWithTrialEndPurchase= new Loaner_Nomination__c();
        loanerNomWithTrialEndPurchase.Status__c='Trial End- Purchase';
        loanerNomWithTrialEndPurchase.Account__c=Acc.id;
        loanerNomWithTrialEndPurchase.Loaner_Program__c=lp.id;
        insert loanerNomWithTrialEndPurchase;
        
        Loaner_Nomination__c loanerNomWithTrialEndReturn= new Loaner_Nomination__c();
        loanerNomWithTrialEndReturn.Status__c='Trial End- Return';
        loanerNomWithTrialEndReturn.Account__c=Acc.id;
        loanerNomWithTrialEndReturn.Loaner_Program__c=lp.id;
        insert loanerNomWithTrialEndReturn;
            
        String loanerNominationId=loanerNomWithOfferRejected.id;
        
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
        order.CurrencyIsoCode='USD';
        order.LoanerProgram__c=lp.Id;
        order.Status='Open';
        order.Type='Loaner Program Sale';
        order.Loaner_Nomination__c=loanerNomWithNominationApplied.Id;
        insert order;
    }
    
    @istest
    public static void RejectLoanerNominationWithNominationApplied(){
        
        Loaner_Program__c loanerPgm=[Select Id from Loaner_Program__c];
        Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Order Created-Quote Sent'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        //rejectLN.loanerNomIdVal='a4C2C000000J61GUAS';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        Test.starttest();
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        Loaner_Nomination__c loanerNomUpdated=[Select Id,Status__c from Loaner_Nomination__c limit 1];
        System.assertEquals('Trial Offer Rejected',loanerNomUpdated.Status__c, 'Rejected');
    }
    
     //commented code
    @istest
    public static void RejectWithErrorInOrder(){
        
        Loaner_Program__c loanerPgm=[Select Id from Loaner_Program__c];
        Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Order Created-Quote Sent'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        Test.starttest();
        RejectLoanerNominationController.AccId='0012C00000MVglM';
        rejectLN.init();
        //LoanerProgramUtility loanerPgmUtility= new LoanerProgramUtility();
        //LoanerProgramUtility.cancelOrder(loanerNom.Id,'Control_Freak','Loaner Program Sale');
        //rejectLN.cancelOrder();
        Test.stopTest();
        Order order=[Select Id,AccountId,LoanerProgram__c,Status,type FROM Order];
        System.assertEquals('Cancelled', order.Status, 'Order Cancelled');
       
    }
    
    @istest
    public static void RejectWithErrorInLoanerNomination(){
        
        Loaner_Program__c loanerPgm=[Select Id from Loaner_Program__c];
        Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Order Created-Quote Sent'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        Test.starttest();
        RejectLoanerNominationController.LoanerProgramId='a4B2C0000009Rm2';
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        Order order=[Select Id,AccountId,LoanerProgram__c,Status,type FROM Order];
        System.assertEquals('Cancelled', order.Status, 'Order Cancelled');
    } 
    //till here
    
    @istest
    public static void RejectLoanerNominationWithTrialOfferAccepted(){
        Loaner_Program__c loanerPgm=[Select Id from Loaner_Program__c];
        Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Trial Offer Accepted'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        Test.starttest();
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        system.assertEquals(true, rejectLN.showMessage);
    }
    
    @istest
    public static void RejectLoanerNominationWithTrialOfferRejected(){
        
        Loaner_Program__c loanerPgm=[Select Id from Loaner_Program__c];
        Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Trial Offer Rejected'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        Test.starttest();
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        //System.assertEquals('Your Nomination have already been Rejected',rejectLN.messageForLoanerNomination, 'Already Made Payment');
        system.assertEquals(true, rejectLN.showMessage);
    }
    
    @istest
    public static void RejectLoanerNominationWithLinkExpired(){
        
        Loaner_Nomination__c loanerNom=[Select Id,Status__c,Link_Expiration_date__c from Loaner_Nomination__c where Status__c = 'Selected for Program' ];
        system.debug('loanerNom '+loanerNom);
       
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        Test.starttest();
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        
        //System.assertEquals('Your Payment Link Has been expired',rejectLN.messageForLoanerNomination, 'Already Made Payment');
        system.assertEquals(true, rejectLN.showMessage);
        
    }
    
    
    @istest
    public static void ReturnLoanerNominationWithTrialEndReturn(){
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
        lp.SuccessMessage__c='Success_Message';
        insert lp;
        
        Loaner_Nomination__c ln= new Loaner_Nomination__c();
        ln.Status__c='Trial End - Quote Generated';
        ln.Account__c=Acc.id;
        ln.Loaner_Program__c=lp.id;
        insert ln;
        String loanerNominationId=ln.id;
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        pageRef.getParameters().put('loanerNominationId',loanerNominationId);
        pageRef.getParameters().put('type','Return');
        
        Test.setCurrentPage(pageRef);
        Id loanId=ln.Id;
        Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
        string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',key,Blob.valueOf(loanId)));
        String encodedId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=ln.Id;
        rejectLN.pgmName='Control_Freak';
        //rejectLN.loanerNomIdVal='a4C2C000000J61GUAS';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        pageRef.getParameters().put('type','Return');
        
        Test.starttest();
        rejectLN.init();
        rejectLN.TrialEndReturn();
        Test.stopTest();
       System.assertEquals(true ,rejectLN.showMessageForReturn, 'Returned');
        
    }
     @istest
    public static void RejectLoanerTrialEndPurches(){
         Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Trial End- Purchase'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        pageRef.getParameters().put('type', 'return');
        
        Test.starttest();
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        //System.assertEquals('Your Nomination have already been Rejected',rejectLN.messageForLoanerNomination, 'Already Made Payment');
        system.assertEquals(true, rejectLN.showMessageForReturn);
    }
      @istest
    public static void RejectLoanerTrialEndReturn(){
         Loaner_Nomination__c loanerNom=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Trial End- Return'];
        
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        String loanerNominationId=loanerNom.id;
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
        RejectLoanerNominationController rejectLN = new RejectLoanerNominationController();
        rejectLN.loanerNomId=loanerNom.Id;
        rejectLN.pgmName='Control_Freak';
        pageRef.getParameters().put('id',loanerNominationId);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        pageRef.getParameters().put('type', 'return');
        
        Test.starttest();
        rejectLN.init();
        //rejectLN.cancelOrder();
        Test.stopTest();
        //System.assertEquals('Your Nomination have already been Rejected',rejectLN.messageForLoanerNomination, 'Already Made Payment');
        system.assertEquals(true, rejectLN.showMessageForReturn);
    }
}