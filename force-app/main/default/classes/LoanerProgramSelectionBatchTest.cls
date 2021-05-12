@isTest
public with sharing class LoanerProgramSelectionBatchTest {
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
        insert ln;
        
    }
    
      static testMethod void testMethodsubscriptionSave(){
        List<Loaner_Program__c> lpList = [SELECT Id,Name, Active__c, ProgramName__c,Product__c,Product__r.Quantity_Available__c,
                                          Run_Selection_Process__c FROM Loaner_Program__c where Active__c=true];
         
        String action = EncodingUtil.base64Encode(Blob.valueOf('emp'));
          
        PageReference pageRef = Page.RejectLoanerProgramOrder;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', lpList[0].id);
        pageRef.getParameters().put('pgm', 'Control_Freak');
        
    	Test.startTest();
        LoanerProgramSelectionBatch Lp=new LoanerProgramSelectionBatch();
    	//Lp.execute(null, lpList); 
    	ID batchprocessid = Database.executeBatch(Lp);

	    Test.stopTest();
      }
    
}