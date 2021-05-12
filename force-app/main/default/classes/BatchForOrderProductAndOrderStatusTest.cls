@isTest
public class BatchForOrderProductAndOrderStatusTest {
 static testMethod void TestMethod1(){
     
      List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS00000';
        lstAcc[0].DataAreaID__c='BDE';
        insert lstAcc;
     
     List<Contract> lstContract= TestDataFactory.createContract(
            lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        lstContract[0].CurrencyIsoCode='EUR';
        insert lstContract;
      list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;
     
     List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'BOV845BSSUSC', false);
        lstProd[0].CurrencyIsoCode = 'EUR';
        insert lstProd;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Sale';
        lstOrder[0].Brand__c='Sage';
        date dt = date.today().addDays(10);
        lstOrder[0].RequestedShipDate__c = dt;
        lstOrder[0].CurrencyIsoCode = 'EUR';
        insert lstOrder;
        List<Order> OID = [select id from Order];
        System.debug('aID '+OID);
        
        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'EUR');
        insert pbe;
        
        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, OID[0].id, 400, 20, 1);
        insert lstOI;
     OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pbe.Id, lstOrder[0].Id, 1, 100, true);
     
     orderItemRecord.Linestatus__c = 'Invoiced';
     
      OrderItemTriggerHandler.afterTriggerRun = true;
     update orderItemRecord;
     
    // lstOrder[0].Shipping_Method__c = 'FX-GND';
      lstOrder[0].Sent_to_AX__c=system.now();
       lstOrder[0].status = 'Order Generated';
     update lstOrder[0];
      lstOrder[0].AX_Order_ID__C='CUS60118';
     lstOrder[0].status = 'Order Shipped';
       update lstOrder[0];
     
     String batchExecute = Database.executeBatch(new BatchForOrderProductAndOrderStatusUpdate(), 1);
 }
    static testmethod void schedulerTest() {
        Test.startTest();

        BatchForOrderProductAndOrderStatusUpdate.scheduleBatch();

        Test.stopTest();
    }
}