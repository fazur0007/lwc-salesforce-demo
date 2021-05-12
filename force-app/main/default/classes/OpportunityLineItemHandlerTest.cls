/*
OpportunityLineItemHandlerTest is a test class for OpportunityLineItemHandler.
* Version       Author             Date                   Description
*  1.0        Yogesh Sharma      02/02/2017             Initial Draft
*/
@isTest
private class OpportunityLineItemHandlerTest {
  //test method with positive data opp record type forecast
  static testMethod void testPositive(){
      RecordType objRecordType = [SELECT Id FROM RecordType WHERE Name=:system.label.Label_Forecast limit 1];
      RecordType objRecordTypeAcc = [SELECT Id FROM RecordType WHERE Name=:'Business Account' limit 1];
      Account objAccount = new Account();
      objAccount.Name='Test Account';
      objAccount.RecordTypeId= objRecordTypeAcc.Id;
      insert objAccount;
      
      Opportunity objOpp = new Opportunity();
      objOpp.Name ='Test Opportunity';
      objOpp.RecordTypeId= objRecordType.Id;
      objOpp.AccountId= objAccount.Id;
      objOpp.CloseDate= date.today();
      objOpp.StageName = system.label.Label_Forecast;
      insert objOpp;

      Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
      for(Product2 prod: lstProd) {
          prod.CanUseQuantitySchedule = true;
      }
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, objOpp.id, 400, 20, 1);
        insert lstOI;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOIDup = TestDataFactory.createOLItem(pbe.Id, objOpp.id, 400, 20, 200);
        try{
            insert lstOIDup;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(system.label.Label_Exist) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
  }

   //negative testing data opp record type Budget
   static testMethod void testNegative(){
        RecordType objRecordType = [SELECT Id FROM RecordType 
                                    WHERE Name=:system.label.Label_Budget limit 1];
        RecordType objRecordTypeAcc = [SELECT Id FROM RecordType 
                                    WHERE Name=:'Business Account' limit 1];
        Account objAccount = new Account();
        objAccount.Name='Test Account';
        objAccount.RecordTypeId= objRecordTypeAcc.Id;
        insert objAccount;
    
        Opportunity objOpp = new Opportunity();
        objOpp.Name ='Test Opportunity';
        objOpp.RecordTypeId= objRecordType.Id;
        objOpp.AccountId= objAccount.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName = system.label.Label_Forecast;
        insert objOpp;

        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
       for(Product2 prod: lstProd) {
          prod.CanUseQuantitySchedule = true;
      }
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, objOpp.id, 400, 20, 1);
        insert lstOI;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOIDup = TestDataFactory.createOLItem(pbe.Id, objOpp.id, 400, 20, 200);
        try{
            insert lstOIDup;
            List<OpportunityLineItem> lstOLI=[select Id from OpportunityLineItem 
                                         where PriceBookEntryId =: lstOIDup[0].PriceBookEntryId];
            System.AssertEquals(201, lstOLI.size());
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(system.label.Label_Exist) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        } 
    }
}