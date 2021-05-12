@isTest
public class AXPriceUtilityTest {
@testSetup
    public static void setupData() {
        List<PriceAPI__c>  allSettings = TestDataFactory.createPriceAPICustomSettings();
        
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test1234', 100);
        lstAcc[0].VendAccount__c='CUS00000';
        lstAcc[0].CurrencyIsoCode = 'USD';
        lstAcc[0].DataAreaID__c='BUS';
        insert lstAcc;
        
        // Insert Contract
        List<Contract> lstContract= TestDataFactory.createContract(
        lstAcc[0].id, 5, Date.Today(), 3, 'Draft');
        lstContract[0].CurrencyIsoCode='USD';
        insert lstContract;
        
        //Insert Contract
        list<Contract> lstCon=[select Id from contract where Id=:lstContract[0].id];
        lstCon[0].Status='Activated';
        update lstCon;
        
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, 'BOV845BSSUSC', false);
        lstProd[0].CurrencyIsoCode = 'USD';
        lstProd[0].AX_Item_Number__c='234567';
        insert lstProd;
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Order
        List<Order> lstOrder = TestDataFactory.createOrder(lstAcc[0].Id, 'Open', date.today(), lstCon[0].id, 1);
        lstOrder[0].Pricebook2Id=standardPriceBookId;
        lstOrder[0].Type = 'Sale';
        date dt = date.today().addDays(10);
        lstOrder[0].RequestedShipDate__c = dt;
        lstOrder[0].CurrencyIsoCode = 'USD';
        insert lstOrder;
        List<Order> OID = [select id from Order];
        System.debug('aID '+OID);
        
        //Insert PriceBook
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true , CurrencyIsoCode = 'USD');
        insert pbe;
        
        //Insert OrderLineItems
        List<OrderItem> lstOI = TestDataFactory.createOrderItem(pbe.Id, OID[0].id, 400, 20, 1);
        insert lstOI;
        System.debug('lstOI#########'+lstOI);
        system.debug('rma product#####'+lstOI[0].getSObject('order'));
        
        //Insert Case
        List<case> listCase = new List<case>();
        Case lstCase = TestDataFactory.createCase(lstAcc[0].Id, 'Phone', 'Open', 'Test RMA USD', 'USD', false);
        lstCase.AccountId=lstAcc[0].Id;
        lstCase.Purchase_Invoice_No__c='12345';
        listCase.add(lstCase);
        insert listCase;
        List<Case> cID = [select id from Case];
        System.debug('aID '+cID);
        
        
        
        //Insert RMA Product
        List<RMA_Product__c> lstRMA = new List<RMA_Product__c>(); 
        RMA_Product__c rm = new RMA_Product__c(Case__c = lstCase.Id , Order__c =OID[0].id ,Quantity__c=200,CurrencyIsoCode='USD');
        rm.Case__c=lstCase.Id;
        rm.Product__c=lstProd[0].Id;
 		insert rm;
        lstRMA.add(rm);
        
        system.debug('rma product detail'+rm.getSObject('Case__r'));
        Case caseRecord=lstCase;
        System.debug('Case Record'+caseRecord.get('AccountId'));
        
        
        //Insert Receiving
        List<Receiving__c> lstRc = new List<Receiving__c>(); 
        Receiving__c Rcv = TestDataFactory.createReceivingRecord(cID[0].id);
        Rcv.CurrencyIsoCode ='USD';
        //Rcv.Account__c = lstAcc[0].Id;
        Rcv.Case__c=lstCase.Id;
       // Rcv.Return_Location__c = 'DHL GERMANY';
         Rcv.Return_Location__c = 'USA PRC';
        Rcv.Received_PDC__c = '1234';
        Rcv.Received_Product__c =lstProd[0].id;
        Rcv.Received_Qty__c=1;
        Rcv.AX_Warehouse__c='236';
        insert Rcv;
        lstRc.add(Rcv);
    }
  
    @isTest
    public static  void testPriceAPI()
    {
        List<Account> lstAcc = [Select Id,VendAccount__c,DataAreaID__c, BusinessUnitFormula__c from Account Where DataAreaID__c='BUS'];
        List<OrderItem> lstOI= [Select Id,OrderId,Order.Id,Order.RequestedShipDate__c,Order.CurrencyIsoCode,AX_Item_Number__c,Quantity From OrderItem Where UnitPrice= 20];
        List<RMA_Product__c> lstRMA = [Select Id,Case__c, Product__c,Case__r.CurrencyIsoCode,Case__r.Purchase_Invoice_No__c,Case__r.Id,Product__r.Id,Product__r.AX_Item_Number__c,Quantity__c,Case__r.AccountID, Case__r.Account.Name,Case__r.Account.BusinessUnitFormula__c, Case__r.Account.VendAccount__c,Case__r.Account.DataAreaID__c From RMA_PRoduct__c Where Quantity__c=200];
        List<Receiving__c> lstRc = [select Id,Case__c,Received_Qty__c,AXAccountNumber__c,Case__r.Purchase_Invoice_No__c, Case__r.Id,Case__r.CurrencyIsoCode,Case__r.AccountId,Case__r.Account.BusinessUnitFormula__c,Received_Product__c,Received_Product__r.Id,Received_Product__r.AX_Item_Number__c From Receiving__c];
        //select Id,Case__c,Received_Qty__c,Account__c,Account__r.Id,AXAccountNumber__c,Case__r.Purchase_Invoice_No__c,Account__r.DataAreaID__c, Case__r.Id,Case__r.CurrencyIsoCode,Case__r.AccountId,Received_Product__c,Received_Product__r.Id,Received_Product__r.AX_Item_Number__c From Receiving__c 
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchRMAMockImpl(200,lstRMA[0].id));
        AXPriceUtility.getXmlResponse(lstOI, lstAcc[0]);
        AXPriceUtility.getXmlResponse(lstRc, lstAcc[0]);
        AXPriceUtility.getXmlResponse(lstRMA, lstAcc[0]);
        test.stopTest();
        
    }
}