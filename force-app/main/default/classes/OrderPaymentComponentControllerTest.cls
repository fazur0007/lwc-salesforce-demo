@isTest
private class OrderPaymentComponentControllerTest{

      static testMethod void orderInsert() {
        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;

        Order objOrder = new Order();
        objOrder.AccountId = objAcc.Id;
        objOrder.Source__c = 'Argo';
        objOrder.EffectiveDate = system.today();
        objOrder.CC_Authorization_ID__c = 'Text';
        objOrder.Status = 'Open';
        objOrder.Type = 'Repair Replacement';
        insert objOrder;
        
        pymt__PaymentX__c objPayment = new pymt__PaymentX__c();
        objPayment.pymt__Card_Type__c= 'Visa';
        objPayment.pymt__Last_4_Digits__c = '8673';
        objPayment.pymt__Status__c = 'Completed';
        objPayment.Order__c=objOrder.Id;
        insert objPayment;
        
        OrderPaymentComponentController cntr =new OrderPaymentComponentController();
        cntr.orderId =objOrder.Id;
        Test.startTest();
        cntr.getPaymentRecord();
        Test.stopTest();
        
        //System.assertEquals(1,cntr.paymentList.size());
      }
      
      static testMethod void dateFormat() {
          OrderPaymentComponentController cntr =new OrderPaymentComponentController();
          cntr.date_time = DateTime.newInstance(1987, 1, 14, 23, 0, 3);
          dateTime dt= DateTime.newInstance(1987, 1, 14, 23, 0, 3);
         
          cntr.getFormatted();
          System.assertEquals(NULL,cntr.defined_format);
           
          
      } 
}