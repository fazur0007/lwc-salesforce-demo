@isTest
private class Chargent_APIUtility2Test {
    
    @testSetup 
    static void setup() {
    	//Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'test Account';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        //Insert Pricebook2   
        Id objPricebook2Id = Test.getStandardPricebookId();
        
        //Insert Order (with no product)    		
		Order orderObjWithNoProd = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2Id); 
		orderObjWithNoProd.Type = 'Sale';
		insert orderObjWithNoProd; 
        
        //Insert Order  		
		Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2Id); 
		orderObj.Type = 'Repair Replacement';
		insert orderObj;
        
        String axItemNo = 'ZBBL800BSS1BCA1';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c=axItemNo); 
        insert objProd;   
        					
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2Id, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;  
        
        //Insert OrderItem
     	OrderItem orderItemObj = new OrderItem(PriceBookEntryId =pricebookEntryObj.Id, OrderId=orderObj.Id,Quantity= 400,UnitPrice =20 );
     	insert orderItemObj;
        
        //Insert ChargentOrders
        ChargentOrders__ChargentOrder__c chargentOrderRecord = new ChargentOrders__ChargentOrder__c();
		chargentOrderRecord.Order__c = orderObj.Id;
		insert chargentOrderRecord;
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "success": true, "Transaction_id": "TRX-000000000" }');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    static testMethod void TestChargectAPIcallMethod() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ChargentOrders__ChargentOrder__c chargentOrderRecord = [Select id, Order__c, Order__r.OwnerId from ChargentOrders__ChargentOrder__c limit 1];
        Chargent_APIUtility2.chargectAPIcall(chargentOrderRecord.Id,chargentOrderRecord.Order__c,chargentOrderRecord.Order__r.OwnerId);
    	Test.stopTest();
    }
    
    static testMethod void TestActivateOrder_Positive() {
        Test.startTest();
        Order orderObj = [Select id from Order where type = 'Repair Replacement'];
        Boolean resp = Chargent_APIUtility2.activateOrder(orderObj.Id);
        System.assertEquals(true, resp);
        Test.stopTest();
    }
    
    static testMethod void TestActivateOrder_Negative() {
        Test.startTest();
        Order orderObjWithNoProd = [Select id from Order where type = 'Sale'];
        Boolean resp = Chargent_APIUtility2.activateOrder(orderObjWithNoProd.Id);
        System.assertEquals(false, resp);
        Test.stopTest();
    }
    
    static testMethod void TestchargectAPIcallWithCVVMethod() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ChargentOrders__ChargentOrder__c chargentOrderRecord = [Select id, Order__c, Order__r.OwnerId from ChargentOrders__ChargentOrder__c limit 1];
        String jsonchargentOrderParams= '{ "ObjectId":"'+chargentOrderRecord.Id+'","CardSecurity":123 }';
        Chargent_APIUtility2.chargectAPIcallWithCVV(jsonchargentOrderParams,chargentOrderRecord.Order__c,chargentOrderRecord.Order__r.OwnerId);
    	Test.stopTest();
    }
}