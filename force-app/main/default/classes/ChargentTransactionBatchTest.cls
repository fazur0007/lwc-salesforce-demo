@isTest(SeeAllData=true)
public with sharing class ChargentTransactionBatchTest {
    
    static testMethod void testMethodChargentTransactionBatch(){
        /*
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'test Account';
        insert objAcc;
        
        //Insert Pricebook2
        Pricebook2 objPricebook2 = new Pricebook2();
        objPricebook2 = [select id from Pricebook2 where IsStandard=true];
        
         //Insert Order         
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2.Id); 
        insert orderObj;
        
        //Insert Case   
        Case caseObj = new Case(Status='Open',CurrencyIsoCode='USD',accountId=objAcc.Id);
        insert caseObj;
        
        //Insert WorkOrder          
        WorkOrder workOrderObj = new WorkOrder(CaseId=caseObj.Id, AccountId=objAcc.Id,CurrencyIsoCode='USD',Pricebook2Id = objPricebook2.Id,ServiceCentre__c=objAcc.Id);        
        insert workOrderObj;    
        
        //Insert ChargentOrders__Transaction__c
        ChargentOrders__Transaction__c chargentOrdersTransactionObj = new ChargentOrders__Transaction__c();
        chargentOrdersTransactionObj.Order__c = orderObj.Id;
        chargentOrdersTransactionObj.WorkOrder__c = workOrderObj.Id ;
        chargentOrdersTransactionObj.Batch_Processing_Action__c = 'Capture';
        chargentOrdersTransactionObj.CC_Auth_Exp__c = date.today() ;        
        //chargentOrdersTransactionObj.ChargentOrders__Order__c = '' ;
            
        List<ChargentOrders__Transaction__c> chargentOrdersTransactionList = new List<ChargentOrders__Transaction__c>();
        chargentOrdersTransactionList.add(chargentOrdersTransactionObj);
        insert chargentOrdersTransactionList;
        */
        
        	String query = 'SELECT Id, ChargentOrders__Order__c, Batch_Processing_Action__c, Order__c, WorkOrder__c, '
            			+ 'Order__r.OwnerId, WorkOrder__r.OwnerId, CC_Auth_Exp__c '
            			+ 'FROM ChargentOrders__Transaction__c '
            			+ 'WHERE (ChargentOrders__Type__c  = \'Authorization\' '
            			+ 'AND (( Batch_Processing_Action__c  IN (\'Capture\',\'Void\') '
            			+ 'AND Scheduled_Payment_Date__c <= TODAY) OR (CC_Auth_Exp__c <= TODAY ))) '
            			+ 'OR (ChargentOrders__Type__c  = \'Charge\' '
            			+ 'AND Batch_Processing_Action__c = \'Refund\' '
            			+ 'AND Scheduled_Payment_Date__c <= TODAY)';
            ChargentTransactionBatch chargentTransactionBatchObj = new ChargentTransactionBatch(query);
            //system.schedule('Test', '0 0 0 15 12 ? 2016', new ChargentTransactionBatch());
            Database.executeBatch(chargentTransactionBatchObj);
        	Test.startTest();
        	ChargentTransactionBatch.schduleBatch();
        	Test.stopTest();
    } 
    
    static testMethod void testMethodChargentTransactionBatch1(){
    	    	
       ChargentTransactionBatch chargentTransactionBatchObj = new ChargentTransactionBatch();
       Database.executeBatch(chargentTransactionBatchObj); 
    }
}