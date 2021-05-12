@isTest
public class OrderandQuoteCreationBatchForLoanerTest {
    
    @testSetup
    static void setUpData() {
        
        List<Loaner_Nomination__c> loanerNominations=new List<Loaner_Nomination__c>();
        
        //Inserting Account
        Account accountRec = new Account();
        accountRec.FirstName='Testing';
        accountRec.LastName='Account';
        accountRec.PersonEmail='Testing@gmail.com';
        accountRec.Phone = '43534545';
        accountRec.BillingCountryCode = 'US';
        accountRec.BillingStreet = '23 maitreya';
        accountRec.BillingCity = 'LA';
        accountRec.BillingStateCode = 'CA';
        accountRec.BillingPostalCode ='470027' ;
        insert accountRec;
        
        //Inserting Product
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        objProd.MAP__c=500;
        insert objProd;  
        
        
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = objProd.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = objProd.id, UnitPrice = 1250.0, IsActive = true);
        insert standardPriceNew;
        
        String Id=String.valueOf(standardPriceNew.Id);
        Loaner_Program__c lp = new Loaner_Program__c();
        lp.Active__c= true;
        lp.Product__c=objProd.id;
        lp.PriceBook__c=pricebookRecord.id;
        lp.PriceBookEntryId__c=Id;
        lp.ProgramName__c = 'Control_Freak';
        lp.Run_Selection_Process__c =true;
        lp.Initial_Amount__c=100;
        insert lp;
        
        //Inserting Loaner Nominations
       	Loaner_Nomination__c loanerNom=new Loaner_Nomination__c();
	    loanerNom.Account__c=accountRec.Id;
	    loanerNom.Loaner_Program__c=lp.Id;
	    loanerNom.Status__c='Selected for Program';
	   	loanerNom.Country_Code__c = 'US';
	   	loanerNom.Street__c = '23 maitreya'; 
	   	loanerNom.City__c ='LA';
	   	loanerNom.Postal_Code__c ='470027'; 
        loanerNominations.add(loanerNom) ;
        
        insert loanerNominations;
        
        
    }
	
    
    
    @isTest
    public static void OrderCreationForLoanerNomination(){
       
        test.startTest();
        Database.executeBatch(new OrderandQuoteCreationBatchForLoaner(), 200);
        test.stopTest();
        List<Loaner_Nomination__c> loanerNomination=[SELECT Id, Name, CurrencyIsoCode, Account__c,Account__r.Name,Account__r.PersonEmail, 
                                               Email__c, Loaner_Program__c, Status__c, Country_Code__c,Loaner_Program__r.Product__c,
                                               Street__c, City__c, State_Code__c, Postal_Code__c,Acceptance_Email_check__c ,
                                               Loaner_Program__r.PriceBook__c,Loaner_Program__r.Initial_Amount__c,Loaner_Program__r.PriceBookEntryId__c
                                               FROM Loaner_Nomination__c];
    }
    
    
    
    
    @isTest
    public static void loanerNominationWithInvalidStateCode(){
       
        Account acc=[Select Id,Name,PersonEmail from Account];
        Product2 product = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        product.Country_of_Manufacture__c='CN';
        product.Landed_Cost__c=222;
        product.Description='Test Data';
        insert product;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry priceBookEntry = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = product.id, UnitPrice = 350.0, IsActive = true);
        insert priceBookEntry;
        
        String pbId=String.valueOf(priceBookEntry.Id);
        Loaner_Program__c loanerPgm = new Loaner_Program__c();
        loanerPgm.Active__c= true;
        loanerPgm.Product__c=product.id;
        loanerPgm.PriceBook__c=pricebookRecord.id;
        loanerPgm.PriceBookEntryId__c=pbId;
        loanerPgm.ProgramName__c = 'Control_Freak';
        loanerPgm.Run_Selection_Process__c =true;
        loanerPgm.Initial_Amount__c=100;
        insert loanerPgm;
        
        
         //Inserting Loaner Nominations
       	Loaner_Nomination__c loanerNomination=new Loaner_Nomination__c();
	    loanerNomination.Account__c=acc.Id;
	    loanerNomination.Loaner_Program__c=loanerPgm.Id;
	    loanerNomination.Status__c='Selected for Program';
	   	loanerNomination.Country_Code__c = 'US';
	   	loanerNomination.Street__c = '23 land maitreya'; 
	   	loanerNomination.City__c ='LA';
	   	loanerNomination.Postal_Code__c ='470027'; 
        loanerNomination.State_Code__c ='09887456321';
        insert loanerNomination;
        
        test.startTest();
        Database.executeBatch(new OrderandQuoteCreationBatchForLoaner(), 200);
        test.stopTest();
        List<Loaner_Nomination__c> loanerNomination1=[SELECT Id, Status__c FROM Loaner_Nomination__c];
        String status=loanerNomination1[0].Status__c;
       
       }
    
    @isTest
    public static void loanerProgramWithoutInitialAmount(){
       
        Account acc=[Select Id,Name,PersonEmail from Account];
        Product2 product = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        product.Country_of_Manufacture__c='CN';
        product.Landed_Cost__c=222;
        product.Description='Test Data';
        product.MAP__c=500;
        insert product;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry priceBookEntry = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = product.id, UnitPrice = 350.0, IsActive = true);
        insert priceBookEntry;
        
        String pbId=String.valueOf(priceBookEntry.Id);
        Loaner_Program__c loanerPgm = new Loaner_Program__c();
        loanerPgm.Active__c= true;
        loanerPgm.Product__c=product.id;
        loanerPgm.PriceBook__c=pricebookRecord.id;
        loanerPgm.PriceBookEntryId__c=pbId;
        loanerPgm.ProgramName__c = 'Control_Freak';
        loanerPgm.Run_Selection_Process__c =true;
        insert loanerPgm;
        
        
         //Inserting Loaner Nominations
       	Loaner_Nomination__c loanerNomination=new Loaner_Nomination__c();
	    loanerNomination.Account__c=acc.Id;
	    loanerNomination.Loaner_Program__c=loanerPgm.Id;
	    loanerNomination.Status__c='Selected for Program';
	   	loanerNomination.Country_Code__c = 'US';
	   	loanerNomination.Street__c = '23 land maitreya'; 
	   	loanerNomination.City__c ='LA';
	   	loanerNomination.Postal_Code__c ='470027'; 
        insert loanerNomination;
        
        test.startTest();
        Database.executeBatch(new OrderandQuoteCreationBatchForLoaner(), 200);
        test.stopTest();
        List<Loaner_Nomination__c> loanerNomination1=[SELECT Id, Status__c FROM Loaner_Nomination__c];
        String status=loanerNomination1[0].Status__c;
                
       }

}