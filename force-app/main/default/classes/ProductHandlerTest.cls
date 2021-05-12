@isTest
private class ProductHandlerTest {

    // to test the positive scenario to set the field value as true
    static testMethod void testAvailableForTrueValue() {
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

       // Insert Contract
        List<Contract> lstContract= TestDataFactory.createContract(
                            lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        insert lstContract;

        //Insert Contract
        list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;

        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'BOV845BSSUSC', false);
        insert lstProd;

        Id standardPriceBookId = Test.getStandardPricebookId();

        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
         lstOrder[0].Type = 'Sale';
        insert lstOrder;

        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, lstOrder[0].id, 400, 20, 1);
        insert lstOI;

        //update order status to order pending
        Order objOrder= [select id from Order limit 1];
        objOrder.Status =system.label.Order_Pending;
        update objOrder;
		
		Test.startTest();
        //update products field value to true
        list<Product2> lstPd=[select Id,Available_To_Sell__c from Product2 where Id =:lstProd[0].id limit 1];
        lstPd[0].Available_To_Sell__c=true;
        update lstPd;

        list<OrderItem> lstOIAssert = [select Available_To_Sell__c from OrderItem where Id IN:lstOI 
                                        and Available_To_Sell__c=true];
            
        //system.assertEquals(lstOIAssert[0].Available_To_Sell__c,true); // single test
        //system.assertEquals(lstOIAssert.size(),200);// bulk test
        Test.stopTest();
    }// end method

    // to test the positive scenario to set the field value as false
    static testMethod void testAvailableForFalseValue() {
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

       // Insert Contract
        List<Contract> lstContract= TestDataFactory.createContract(
                            lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        insert lstContract;

        //Insert Contract
        list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;

        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200,'BOV845BSSUSC', true);
        insert lstProd;

        Id standardPriceBookId = Test.getStandardPricebookId();

        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
         lstOrder[0].Type = 'Sale';
        insert lstOrder;

        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, lstOrder[0].id, 400, 20, 1);
        insert lstOI;

        Order objOrder= [select id from Order limit 1];
        objOrder.Status =System.label.Open;
        update objOrder;
		
		Test.startTest();
        list<Product2> lstPd=[select Id,Available_To_Sell__c from Product2 where Id =:lstProd[0].id limit 1];
        lstPd[0].Available_To_Sell__c=false;
        update lstPd;

        list<OrderItem> lstOIAssert = [select Available_To_Sell__c from OrderItem where Id IN:lstOI 
                                        and Available_To_Sell__c=false];

        //system.assertEquals(lstOIAssert[0].Available_To_Sell__c,false);// single test
        //system.assertEquals(lstOIAssert.size(),200);// bulk test
        Test.stopTest();
    }// end method

    // to test the negative scenario if the status of order is 'Order Shipped'
    static testMethod void testNegativeStatusScenario() {
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

       // Insert Contract
        List<Contract> lstContract= TestDataFactory.createContract(
                            lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        insert lstContract;

        //Insert Contract
        list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;

        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200,'BOV845BSSUSC', true);
        insert lstProd;

        Id standardPriceBookId = Test.getStandardPricebookId();

        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Sale';
        insert lstOrder;

        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, lstOrder[0].id, 400, 20, 1);
        insert lstOI;

        Order objOrder= [select id from Order limit 1];
        objOrder.Status ='Order Shipped';
        update objOrder;
		
		Test.startTest();
        list<Product2> lstPd=[select Id,Available_To_Sell__c from Product2 where Id =:lstProd[0].id limit 1];
        lstPd[0].Available_To_Sell__c=false;
        update lstPd;

        list<OrderItem> lstOIAssert = [select Available_To_Sell__c from OrderItem where Id IN:lstOI 
                                        and Available_To_Sell__c=false];

        //system.assertEquals(lstOIAssert.size(),0);// bulk test
        Test.stopTest();
    }// end method
}//end class