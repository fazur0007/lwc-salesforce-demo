@isTest
public with sharing class pageControllerTest {
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
        ln.Status__c = 'Order Created-Quote Sent';
        insert ln;
        
        Order orderObj = new Order();
        orderObj.AccountId =Acc.Id;
        orderObj.LoanerProgram__c =lp.id;
        orderObj.Loaner_Nomination__c = ln.id;
        orderObj.Status = 'Open';
        orderObj.type='Loaner Program Sale';
        orderObj.EffectiveDate =system.today()-9;
        insert orderObj;
        
 	    Loaner_Nomination__c lnn= new Loaner_Nomination__c();
        lnn.Status__c='Nomination Applied';
        lnn.Account__c=Acc.id;
        lnn.Loaner_Program__c=lp.id;
        lnn.Link_Expiration_date__c = system.today() -8;
        lnn.Status__c = 'Trial Offer Accepted';
        insert lnn;
        
        Order ordObj = new Order();
        ordObj.AccountId =Acc.Id;
        ordObj.LoanerProgram__c =lp.id;
        ordObj.Loaner_Nomination__c = lnn.id;
        ordObj.Status = 'Open';
        ordObj.type='Loaner Program Sale';
        ordObj.EffectiveDate =system.today()-8;
        insert ordObj;
                
        Loaner_Nomination__c loaner= new Loaner_Nomination__c();
        loaner.Status__c='Nomination Applied';
        loaner.Account__c=Acc.id;
        loaner.Loaner_Program__c=lp.id;
        loaner.Link_Expiration_date__c = system.today() -8;
        loaner.Status__c = 'Trial Offer Rejected';
        insert loaner;
        
        Order ordrObj = new Order();
        ordrObj.AccountId =Acc.Id;
        ordrObj.LoanerProgram__c =lp.id;
        ordrObj.Loaner_Nomination__c = loaner.id;
        ordrObj.Status = 'Open';
        ordrObj.type='Loaner Program Sale';
        ordrObj.EffectiveDate =system.today()-8;
        insert ordrObj;
        
        Loaner_Nomination__c loanerNomination= new Loaner_Nomination__c();
        loanerNomination.Status__c='Nomination Applied';
        loanerNomination.Account__c=Acc.id;
        loanerNomination.Loaner_Program__c=lp.id;
        loanerNomination.Link_Expiration_date__c = system.today() -8;
        insert loanerNomination;
        
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
        
        Loaner_Nomination__c loanerNomWithOrderQuoteSent= new Loaner_Nomination__c();
        loanerNomWithOrderQuoteSent.Status__c='Order Created-Quote Sent';
        loanerNomWithOrderQuoteSent.Account__c=Acc.id;
        loanerNomWithOrderQuoteSent.Loaner_Program__c=lp.id;
        insert loanerNomWithOrderQuoteSent;
        
        Loaner_Nomination__c loanerNomWithEndQuoteGenerated= new Loaner_Nomination__c();
        loanerNomWithEndQuoteGenerated.Status__c='Trial End - Quote Generated';
        loanerNomWithEndQuoteGenerated.Account__c=Acc.id;
        loanerNomWithEndQuoteGenerated.Loaner_Program__c=lp.id;
        insert loanerNomWithEndQuoteGenerated;
    }
    static testMethod void testMethodRejection(){
        Loaner_Nomination__c loanerNom=[Select Id from Loaner_Nomination__c where Status__c = 'Order Created-Quote Sent' AND Link_Expiration_date__c != null ];
        Loaner_Nomination__c loarNo=[Select Id from Loaner_Nomination__c where Status__c = 'Trial Offer Accepted' ];
        Loaner_Nomination__c lNo=[Select Id from Loaner_Nomination__c where Status__c = 'Trial Offer Rejected' ];
        Loaner_Nomination__c loanerNomination=[Select Id from Loaner_Nomination__c where Status__c = 'Nomination Applied' ];
        Loaner_Nomination__c loanerNomPurchase=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Trial End- Purchase'];
        Loaner_Nomination__c loanerNomReturn=[Select Id,Status__c from Loaner_Nomination__c where Status__c = 'Trial End- Return'];
        Loaner_Nomination__c loanerNomOrderQuoteSent=[Select Id from Loaner_Nomination__c where Status__c = 'Order Created-Quote Sent' AND Link_Expiration_date__c = null ];
        Loaner_Nomination__c loanerNomWEndQuoteGenerated=[Select Id from Loaner_Nomination__c where Status__c = 'Trial End - Quote Generated' ];
    
        Test.startTest();
        
        PageReference pageRef2 = Page.SitePayment;
        Test.setCurrentPage(pageRef2);
        Id loanId2=lNo.Id;
        pageRef2.getParameters().put('pgm', 'Control_Freak');
        pageRef2.getParameters().put('id',loanId2);
        pageController pgContr2 = new pageController();
        pgContr2.currentRecordId = loanId2;
        pgContr2.checkExpiration();
        system.assertEquals(true, pgContr2.message);
        
        PageReference pageRef = Page.SitePayment;
        Test.setCurrentPage(pageRef);
        Id loanId=loanerNom.Id;
        pageRef.getParameters().put('pgm', 'Control_Freak');
        pageRef.getParameters().put('id',loanId);
        pageController pgContr = new pageController();
        pgContr.currentRecordId = loanerNom.Id;
        pgContr.checkExpiration();
        system.assertEquals(true, pgContr.message);
        
        PageReference pageRef1 = Page.SitePayment;
        Test.setCurrentPage(pageRef1);
        Id loanId1=loarNo.Id;
        pageRef1.getParameters().put('pgm', 'Control_Freak');
        pageRef1.getParameters().put('id',loanId1);
        pageController pgContr1 = new pageController();
        pgContr1.currentRecordId = loanId1;
        pgContr1.checkExpiration();
        system.assertEquals(true, pgContr1.message);
        
        PageReference pageReference = Page.SitePayment;
        Test.setCurrentPage(pageReference);
        Id loanerNominationId=loanerNomination.Id;
        pageReference.getParameters().put('pgm', 'Control_Freak');
        pageReference.getParameters().put('id',loanerNominationId);
        pageController pageCntrl = new pageController();
        pageCntrl.currentRecordId = loanerNominationId;
        pageCntrl.checkExpiration();
        system.assertEquals(false, pageCntrl.message);
        
        PageReference pageReferencePurchase = Page.SitePayment;
        Test.setCurrentPage(pageReferencePurchase);
        Id loanerNominationIdPurchase=loanerNomPurchase.Id;
        pageReferencePurchase.getParameters().put('pgm', 'Control_Freak');
        pageReferencePurchase.getParameters().put('id',loanerNominationIdPurchase);
        pageController pageCntrlPurchase = new pageController();
        pageCntrlPurchase.currentRecordId = loanerNominationIdPurchase;
        pageCntrlPurchase.checkExpiration();
        system.assertEquals(true, pageCntrlPurchase.message);
        
        PageReference pageReferenceReturn = Page.SitePayment;
        Test.setCurrentPage(pageReferenceReturn);
        Id loanerNominationIdReturn=loanerNomReturn.Id;
        pageReferenceReturn.getParameters().put('pgm', 'Control_Freak');
        pageReferenceReturn.getParameters().put('id',loanerNominationIdReturn);
        pageController pageCntrlReturn = new pageController();
        pageCntrlReturn.currentRecordId = loanerNominationIdReturn;
        pageCntrlReturn.checkExpiration();
        system.assertEquals(true, pageCntrlReturn.message);
        
         PageReference pageReferenceerror = Page.SitePayment;
        Test.setCurrentPage(pageReferenceerror);
        Id loanerNominationIderror=loanerNomReturn.Id;
        pageReferenceerror.getParameters().put('pgm', 'Control_Freak');
        pageReferenceerror.getParameters().put('id',loanerNominationIderror);
        pageController pageCntrlerror = new pageController();
        pageCntrlerror.currentRecordId = '0012C00000MVglM';
        pageCntrlerror.LoanerProgramId = '0012C00000YUglM';
        pageCntrlerror.checkExpiration();
        
        PageReference pageReferencOrderQuoteSent = Page.SitePayment;
        Test.setCurrentPage(pageReferencOrderQuoteSent);
        Id lnOrderQuoteSentID=loanerNomOrderQuoteSent.Id;
        pageReferencOrderQuoteSent.getParameters().put('pgm', 'Control_Freak');
        pageReferencOrderQuoteSent.getParameters().put('id',lnOrderQuoteSentID);
        pageController pageCntrlOrderQuoteSent = new pageController();
        pageCntrlOrderQuoteSent.currentRecordId = lnOrderQuoteSentID;
        pageCntrlOrderQuoteSent.checkExpiration();
        system.assertEquals(true, pageCntrlOrderQuoteSent.showTnCForLNStatus);
        
        PageReference pageReferencEndQuoteGenerated = Page.SitePayment;
        Test.setCurrentPage(pageReferencEndQuoteGenerated);
        Id loanerNomWEndQuoteGeneratedID=loanerNomWEndQuoteGenerated.Id;
        pageReferencEndQuoteGenerated.getParameters().put('pgm', 'Control_Freak');
        pageReferencEndQuoteGenerated.getParameters().put('id',loanerNomWEndQuoteGeneratedID);
        pageController pageCntrlEndQuoteGenerated = new pageController();
        pageCntrlEndQuoteGenerated.currentRecordId = loanerNomWEndQuoteGeneratedID;
        pageCntrlEndQuoteGenerated.checkExpiration();
        system.assertEquals(false, pageCntrlEndQuoteGenerated.showTnCForLNStatus);
        
        Test.stopTest();
    }

}