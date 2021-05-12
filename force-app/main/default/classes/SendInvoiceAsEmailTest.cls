@isTest(SeeAllData = true)
public with sharing class SendInvoiceAsEmailTest {
    
    static testMethod void testMethodSendInvoiceAsEmail(){
        
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'test Account';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        //Insert Pricebook2   
        Pricebook2 objPricebook2 = new Pricebook2();
        objPricebook2 = [select id from Pricebook2 where IsStandard=true];
        
        //Insert BilltoContact
        Contact objCon = new Contact();
        objCon.FirstName = 'Test';
        objCon.LastName = 'email';
        objCon.Email= 'mayuri_pungi@persistent.com';
        insert objCon;
        
         //Insert Order         
        Order orderObj = new Order(AccountId=objAcc.Id,AX_Order_ID__c='00213',BillToContactId=objCon.Id,CurrencyIsoCode='USD',Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2.Id); 
        orderObj.Type = 'Sale';
        insert orderObj;  
         
         //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        insert objProd;   
                            
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2.Id, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;  
        
        //Insert OrderItem
        OrderItem orderItemObj = new OrderItem(Description='Test Description',PriceBookEntryId =pricebookEntryObj.Id, OrderId=orderObj.Id,Quantity= 400,UnitPrice =20 );
        insert orderItemObj;
        
               
        
       Test.starttest();
      
       PageReference pageRef = Page.SendInvoiceEmail;
          pageRef.getParameters().put('id', orderObj.Id);
         Test.setCurrentPage(pageRef);
         ApexPages.StandardController sc = new ApexPages.standardController(orderObj);
         SendInvoiceAsEmail sendInvoiceAsEmailObj = new SendInvoiceAsEmail(sc);
 
  
       sendInvoiceAsEmailObj.getOrder();
       pageRef=sendInvoiceAsEmailObj.send(); 

        Test.stoptest();

}
}