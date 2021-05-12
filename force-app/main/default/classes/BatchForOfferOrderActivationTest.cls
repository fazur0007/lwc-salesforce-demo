@isTest
public with sharing class BatchForOfferOrderActivationTest {
    
     static testMethod void testMethodBatchForOfferOrderActivationTest(){
       
       //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        Order orderObj = new Order();
        orderObj.AccountId =objAcc.Id;
        orderObj.Offer_Activation_Date__c = system.today();
        orderObj.Status = 'Open';
        orderObj.Source__c = 'GWP';
        orderObj.EffectiveDate = system.today();
        insert orderObj;
        
        String batchExecute = Database.executeBatch(new BatchForOfferOrderActivation(), 10);
       
        list<Order> OrderList = [SELECT Id, Source__c FROM Order WHERE Id = :orderObj.Id];
	    System.assertEquals(OrderList[0].Source__c, 'GWP');
	    
     }
    
}