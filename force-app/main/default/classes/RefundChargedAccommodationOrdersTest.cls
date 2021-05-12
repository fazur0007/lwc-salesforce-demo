@isTest
public class RefundChargedAccommodationOrdersTest {
    @testSetup
    static void setUpData() {
        //Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
       
        Id objPricebook2 = Test.getStandardPricebookId();
        
        Case caseRecord = TestDataFactory.createCase(objAcc.Id, 'Email','Open','Subject 99', 'USD', true);
        
        ShippingAmount__c shippingAmmountRecord1 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND DAY', 75, true, 'Sale', false);
        shippingAmmountRecord1.Shipping_Method__c = 'STANDARD';
        insert shippingAmmountRecord1;
        
         //Insert Order    		
		Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Accommodation';
        orderObj.Channel__c = 'CCC';
        orderObj.CC_Transaction_ID__c = '3212';
        orderObj.CC_Authorization_ID__c = '3212';
        orderObj.Shipping_Method__c = 'STANDARD';
        orderObj.AdvanceShippingStatus__c = 'Received-Voided';
        orderObj.Case__c = caseRecord.id;
        insert orderObj;   
           
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        insert objProd;   
        					
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
     	OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
		Order orderRecord = [select id, CC_Authorization_Amount__c,Shipping_Amount__c from Order limit 1];
        System.assertEquals(0.0, orderRecord.Shipping_Amount__c);
    }
    
    static testMethod void testRefundChargedAccommodationOrders() {
        List<Id> orderIds = new List<Id>();
        for(Order odr : [SELECT Id FROM Order
                         WHERE Type = 'Accommodation'
                         AND CC_Transaction_ID__c != null 
                         AND CC_Authorization_ID__c != null
                         AND Channel__c = 'CCC' 
                         AND AdvanceShippingStatus__c = 'Received-Voided' LIMIT 50]) {
             orderIds.add(odr.Id);                
        }
        RefundChargedAccommodationOrders.findTransactions(orderIds);
    }
}