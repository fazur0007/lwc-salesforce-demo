/**

 */
@isTest
private class PaymentsRecordBatchTest {

    static testMethod void positiveBatchTest() {

        Account objAcc = new Account();
        objAcc.LastName = 'Test Account';
        objAcc.FirstName = 'Test Account';
        insert objAcc;

        Order objOrder = new Order();
        objOrder.AccountId = objAcc.Id;
        objOrder.Source__c = 'Argo';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today()+1;
        objOrder.CC_Authorization_ID__c = 'Text';
        objOrder.Payment_Occurrence__c = 6;
        objOrder.IsProcessed__c = false;
        objOrder.Status = 'Open';
        insert objOrder;

        list<Account> lstAcc = [Select Id, PersonContactId From Account Where Id =: objAcc.Id];
        list<Contact> lstCon = [Select Id From Contact Where Id =: lstAcc[0].PersonContactId];

        pymt__Settings__c objPaymentSettings = new pymt__Settings__c();
        objPaymentSettings.Name = 'Payment settings';
        insert objPaymentSettings; 

        pymt__Processor_Connection__c  objProcessorCon = new pymt__Processor_Connection__c ();
        objProcessorCon.Name = 'PayPal 3';
        objProcessorCon.pymt__PaymentConnect_Setup__c = objPaymentSettings.Id;
        insert objProcessorCon;

        pymt__PaymentX__c objPayment = new pymt__PaymentX__c();
        objPayment.pymt__Transaction_Type__c = 'Payment';
        objPayment.pymt__Transaction_Id__c = objOrder.CC_Authorization_ID__c;
        objPayment.pymt__Status__c = 'Completed';
        objPayment.pymt__Date__c = system.today();
        objPayment.pymt__Processor_Connection__C = objProcessorCon.Id;
        objPayment.Order__c = objOrder.Id;
        objPayment.pymt__Contact__c = lstCon[0].Id;
        objPayment.pymt__Card_Type__c = 'Visa';
        insert objPayment;

        Contact objContact = new Contact();
        objContact.LastName = 'test';
        objContact.Phone = '1234567891';
        //objContact.AccountId = objAcc.Id;
        insert objContact;

        RecordType paymentMethodRtype = [Select Id
                              from RecordType 
                             where DeveloperName = 'PayPal_Transaction_Reference' 
                               and SobjectType = 'pymt__Payment_Method__c'];

        pymt__Payment_Method__c objpymtPaymentMethod = new pymt__Payment_Method__c();
        objpymtPaymentMethod.RecordTypeId = paymentMethodRtype.Id;
        objpymtPaymentMethod.Name = 'Transaction Reference';
        objpymtPaymentMethod.pymt__Contact__c = objContact.Id;
        insert objpymtPaymentMethod;

        Test.startTest();
        Database.executeBatch(new PaymentsRecordBatch(), 200);
        Test.stopTest();
        
        list<pymt__PaymentX__c> lstPayment = [Select Id From pymt__PaymentX__c];
        
        system.assertEquals(lstPayment.size(), 6);
    }
    
    static testMethod void positiveBatchNoCardTypeTest() {

        Account objAcc = new Account();
        objAcc.LastName = 'Test Account';
        objAcc.FirstName = 'Test Account';
        insert objAcc;

        Order objOrder = new Order();
        objOrder.AccountId = objAcc.Id;
        objOrder.Source__c = 'Argo';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today()+1;
        objOrder.CC_Authorization_ID__c = 'Text';
        objOrder.Payment_Occurrence__c = 5;
        objOrder.IsProcessed__c = false;
        objOrder.Status = 'Open';
        insert objOrder;

        list<Account> lstAcc = [Select Id, PersonContactId From Account Where Id =: objAcc.Id];
        list<Contact> lstCon = [Select Id From Contact Where Id =: lstAcc[0].PersonContactId];

        pymt__Settings__c objPaymentSettings = new pymt__Settings__c();
        objPaymentSettings.Name = 'Payment settings';
        insert objPaymentSettings; 

        pymt__Processor_Connection__c  objProcessorCon = new pymt__Processor_Connection__c ();
        objProcessorCon.Name = 'PayPal 3';
        objProcessorCon.pymt__PaymentConnect_Setup__c = objPaymentSettings.Id;
        insert objProcessorCon;

        pymt__PaymentX__c objPayment = new pymt__PaymentX__c();
        objPayment.pymt__Transaction_Type__c = 'Authorization';
        objPayment.pymt__Transaction_Id__c = objOrder.CC_Authorization_ID__c;
        objPayment.pymt__Status__c = 'Authorized';
        objPayment.pymt__Date__c = system.today();
        objPayment.pymt__Processor_Connection__C = objProcessorCon.Id;
        objPayment.Order__c = objOrder.Id;
        objPayment.pymt__Contact__c = lstCon[0].Id;
        insert objPayment;

        Contact objContact = new Contact();
        objContact.LastName = 'test';
        objContact.Phone = '1234567891';
        //objContact.AccountId = objAcc.Id;
        insert objContact;

        RecordType paymentMethodRtype = [Select Id
                              from RecordType 
                             where DeveloperName = 'PayPal_Transaction_Reference' 
                               and SobjectType = 'pymt__Payment_Method__c'];

        pymt__Payment_Method__c objpymtPaymentMethod = new pymt__Payment_Method__c();
        objpymtPaymentMethod.RecordTypeId = paymentMethodRtype.Id;
        objpymtPaymentMethod.Name = 'Transaction Reference';
        objpymtPaymentMethod.pymt__Contact__c = objContact.Id;
        insert objpymtPaymentMethod;

        Test.startTest();
        Database.executeBatch(new PaymentsRecordBatch(), 200);
        Test.stopTest();
        
        list<pymt__PaymentX__c> lstPayment = [Select Id From pymt__PaymentX__c];
        
        system.assertEquals(lstPayment.size(), 1);

    }
}