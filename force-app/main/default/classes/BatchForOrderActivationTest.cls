@isTest
public with sharing class BatchForOrderActivationTest {
    
     static testMethod void testMethodBatchForOrderActivationTest(){
     	
     	//Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        Order orderObj = new Order();
        orderObj.AccountId =objAcc.Id;
        orderObj.ActivatedByPartner__c = true;
       //orderObj.StatusCode = 'D';
         orderObj.status = 'open';
        orderObj.EffectiveDate = Date.today();
       insert orderObj;
         orderObj.StatusCode = 'D';
         orderObj.Status = 'Draft';
		update orderObj;
       
       String batchExecute = Database.executeBatch(new BatchForOrderActivation(), 10);
     	
     }
    
}