@isTest
public class ProcessSplitPaymentBatchTest {
	@testSetup
    public static void setupData() {
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS00000';
        lstAcc[0].CurrencyIsoCode = 'USD';
        lstAcc[0].DataAreaID__c='BUS';
        insert lstAcc;
        
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'BOV845BSSUSC', false);
        lstProd[0].CurrencyIsoCode = 'USD';
        lstProd[0].AX_Item_Number__c='234567';
        insert lstProd;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'USD');
        insert pbe;
        
        Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        
        //Insert Order
        Order orderRec = TestDataFactory.createOrderRecord(lstAcc[0].Id, 'Open', date.today(), 1, standardPriceBookId,
                                                                 recordTypeId, 'Sale', 'test123', 'Breville', 'USD');
        date dt = date.today().addDays(10);
        orderRec.RequestedShipDate__c = dt;
        orderRec.ProcessSplitPayment__c=true;
        orderRec.Channel__c='CCC';
        orderRec.Country__c='USA';
        orderRec.Brand__c= 'Beanz';
        //orderRec.OwnerId= tUser.Id; //UserInfo.getUserId();
        insert orderRec;
        system.debug('orderRec'+orderRec);
        List<Order> OID = [select id from Order];
        System.debug('aID '+OID);
        
        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, orderRec.id, 400, 20, 3);
        lstOI[0].LineStatus__c='Shipped';
        lstOI[0].Payment_Processed__c = false;
        insert lstOI[0];
        
        lstOI[1].LineStatus__c='Shipped';
        lstOI[1].Payment_Processed__c = false;
        insert lstOI[1];

		lstOI[2].LineStatus__c='Cancelled';
        lstOI[2].Payment_Processed__c = false;
        insert lstOI[2];
        
        //Insert payment record
        ChargentOrders__ChargentOrder__c paymentRecord= new ChargentOrders__ChargentOrder__c();
        paymentRecord.Order__c=orderRec.Id;
        Double chargeAmount=30000.00;
        paymentRecord.ChargentOrders__Payment_Method__c='Credit Card';
        paymentRecord.ChargentOrders__Card_Type__c='Visa';
        paymentRecord.ChargentOrders__Card_Number__c='4111111111111111';
        paymentRecord.ChargentOrders__Card_Expiration_Month__c='08';
        paymentRecord.ChargentOrders__Card_Expiration_Year__c='2021';
        paymentRecord.ChargentOrders__Manual_Charge__c=true;
        paymentRecord.ChargentOrders__Charge_Amount__c=chargeAmount;
        paymentRecord.OwnerId = UserInfo.getUserId();
        insert paymentRecord;
        ChargentOrders__ChargentOrder__c paymRec = [Select Id, OwnerId,ChargentOrders__Charge_Amount__c From ChargentOrders__ChargentOrder__c Where Id= :paymentRecord.Id];
        system.debug('paymentRecord'+paymentRecord);
        
        //Insert transaction record
        ChargentOrders__Transaction__c transactionRecord= new ChargentOrders__Transaction__c();
		transactionRecord.ChargentOrders__Order__c=paymentRecord.Id;
        transactionRecord.ChargentOrders__Type__c  = 'Authorization';
        transactionRecord.ChargentOrders__Response_Status__c = 'Approved';     
        insert transactionRecord;
        
        ChargentOrders__Transaction__c transRec = [Select Id, ChargentOrders__Order__c, ChargentOrders__Order__r.OwnerId 
                                                   From ChargentOrders__Transaction__c Where Id= :transactionRecord.Id];
        system.debug('transactionRecord'+transactionRecord);
        system.debug('OwnerId'+transactionRecord.ChargentOrders__Order__r.OwnerId);
        system.debug('++transaction list'+[SELECT Id,ChargentOrders__Order__r.OwnerId
                                                                FROM ChargentOrders__Transaction__c 
                                                                WHERE ChargentOrders__Type__c  = 'Authorization' 
                                                                AND ChargentOrders__Response_Status__c = 'Approved']);
        
    }
    
    //method to test ProcessSplitPaymentBatch and chargent order batch flow
    static testMethod void testProcessSplitPaymentBatch(){
        Test.startTest();
        Order orderRec = [SELECT Id, Status, Type, ProcessSplitPayment__c, Charge_Shipping_Amount__c 
                          FROM Order WHERE ProcessSplitPayment__c= true LIMIT 1];
        ProcessSplitPaymentBatch paymentBatch= new ProcessSplitPaymentBatch();
        paymentBatch.errorMap.put(orderRec.Id, 'ErrorTest');
        Database.executeBatch(paymentBatch,1);
        Test.stopTest();
        ChargentOrderBatch orderBatchobj= new ChargentOrderBatch();
        Database.executeBatch(orderBatchobj);
        List<ChargentOrders__ChargentOrder__c> paymentRecords=[SELECT Id, ChargentOrders__Charge_Amount__c, Batch_Processing_Action__c,
                                                  Order__c, Order__r.OwnerId FROM ChargentOrders__ChargentOrder__c 
                                                  WHERE ChargentOrders__Manual_Charge__c = true];
        system.debug('paymentRecords'+paymentRecords);
    }
    
    //method to test chargent Order batch by schedulable
    static testmethod void testChargentOrderBatchSchedulable() {
        String query = 'SELECT Id, ChargentOrders__Charge_Amount__c, Batch_Processing_Action__c, '
            + 'Order__c, Order__r.OwnerId '
            + 'FROM ChargentOrders__ChargentOrder__c '
            + 'WHERE Batch_Processing_Action__c = \'Authorize\' ';
        ChargentOrderBatch orderBatch= new ChargentOrderBatch(query);
        Database.executeBatch(orderBatch,1);
        Test.startTest();
        ChargentOrderBatch.scheduleBatch();
        Test.stopTest();
    }
}