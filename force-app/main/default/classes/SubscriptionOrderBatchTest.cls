@istest
public class SubscriptionOrderBatchTest {
 
    @TestSetup
    public static void setupData(){
   
     Subscription__c subscriptionOrderData = new Subscription__c(Gift_Code__c='Testclass', 
                                                                 Pause_Duration_In_Days__c='testclass' , 
                                                                 Unit_Price__c=0987,
                                                                 Status__c='Active',
                                                                 Iteration_Count__c=123,
                                                                 Maximum_iterations__c=456
                                                                 );
     insert subscriptionOrderData;
    }
    
    public static testmethod void SubscriptionOrderTestMethod(){
     
        Test.startTest();
            System.schedule('Test SubscriptionOrderBatch', '0 0 23 * * ?',new SubscriptionSchedule() );
        Test.stopTest();
        
         Subscription__c subscriptionOrder  = [select Gift_Code__c,Maximum_iterations__c,Iteration_Count__c, Pause_Duration_In_Days__c from Subscription__c ];
          system.assertEquals('Testclass', subscriptionOrder.Gift_Code__c);
    }
}