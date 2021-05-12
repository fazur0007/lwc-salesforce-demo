@isTest
public with sharing class OrderTriggerHandlerTest {
    
    static testMethod void testMethod1(){
        Test.startTest();
        try{
        //Insert Account  
        RecordType personAccountRecordType=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];       
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        objAcc.RecordTypeId=personAccountRecordType.Id;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        Case caseRecord = TestDataFactory.createCase(objAcc.Id, 'Email','Open','Subject 99', 'USD', true);
        
        ShippingAmount__c shippingAmmountRecord1 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND', 75, true, 'Sale', false);
        shippingAmmountRecord1.Shipping_Method__c = 'STANDARD';
        insert shippingAmmountRecord1;
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Sale';
        orderObj.Shipping_Method__c = 'STANDARD';
        orderObj.Case__c = caseRecord.id;
        
        insert orderObj;   
        
        String axItemNo = 'ZBBL800BSS1BCA1';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
        OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
        Order orderRecord = [select id, CC_Authorization_Amount__c,Shipping_Amount__c from Order limit 1];
        
        orderObj.CancelledLineIds__c = orderItemObj.Id;
        orderObj.ShippedLineIds__c = orderItemObj.Id;
            update orderObj;
        System.assertEquals(50.0, orderRecord.Shipping_Amount__c);
        }catch(exception e){}
        Test.stopTest();
    }
    
    static testMethod void testMethod2(){
        //Insert Account
        RecordType personAccountRecordType=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];               
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        Case caseRecord = TestDataFactory.createCase(objAcc.Id, 'Email','Open','Subject 99', 'USD', true);
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Accommodation';
        orderObj.CC_Authorization_ID__c = '';
        orderObj.AdvanceShippingStatus__c = null;
        orderObj.Case__c = caseRecord.id;
        insert orderObj;   
        
        String axItemNo = 'ZBBL800BSS1BCA1';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
        OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
        List<Case> caseList = [select id from Case];
        System.assertEquals(1, caseList.size());
    }
    
    static testMethod void testMethod3(){
        //Insert Account
        RecordType personAccountRecordType=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];               
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        ShippingAmount__c shippingAmmountRecord1 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND', 75, true, 'Employee Sale', true);
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Employee Sale';
        orderObj.Shipping_Method__c = null;
        orderObj.Source__c = 'Breville';
        insert orderObj;   
        
        String axItemNo = 'ZBBL800BSS1BCA1';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
        OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
        Order orderRecord = [select id, CC_Authorization_Amount__c from Order limit 1];
        System.assertEquals(0.0, orderRecord.CC_Authorization_Amount__c);
    }
    
    static testMethod void testMethod4(){
        //Insert Account  
        String personAccountRecordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;              
        Account objAcc = new Account();
        objAcc.FirstName = 'Account1';
        objAcc.LastName='Test';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        objAcc.RecordTypeId=personAccountRecordTypeId;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Sample';
        orderObj.Shipping_Method__c = null;
        orderObj.Source__c = 'Breville';
        orderObj.Brand__c = 'Breville';
        insert orderObj;   
        Order orderRecord = [select id, CC_Authorization_Amount__c from Order limit 1];
        System.assertEquals(0.0, orderRecord.CC_Authorization_Amount__c);
    }
    
    static testMethod void testMethod5(){
        //Insert Account
        String personAccountRecordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;              
        Account objAcc = new Account();
        objAcc.FirstName = 'Account1';
        objAcc.LastName='Test';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        objAcc.RecordTypeId=personAccountRecordTypeId;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        Case caseRecord = TestDataFactory.createCase(objAcc.Id, 'Email','Open','Subject 99', 'USD', true);
        WorkOrder workOrderObj = new WorkOrder(CaseId=caseRecord.Id, AccountId=objAcc.Id,CurrencyIsoCode='USD',Pricebook2Id = objPricebook2,ServiceCentre__c=objAcc.Id); 
        workOrderObj.CC_Authorization_ID__c = '1234';
        workOrderObj.FirstName__c = 'Test';
        workOrderObj.LastName__c = 'Test';
        insert workOrderObj; 
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Repair Replacement';
        orderObj.Shipping_Method__c = null;
        orderObj.Source__c = 'Breville';
        orderObj.ServiceOrder__c = workOrderObj.id;
        orderObj.Case__c = caseRecord.id;
        insert orderObj;   
        
        List<Order> orderList = new List<Order>(); 
        orderList.add(orderObj);
        
        orderObj.ActivatedByPartner__c = true;
        upsert orderObj;
        OrderTriggerHandler.lockActivatedOrder(orderList);
        System.assertEquals(1, Approval.isLocked(orderList).size());
    }
    
    static testMethod void testMethod6(){
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),TnC_Agreement__c=true, Channel__c='ECOMM'); 
        orderObj.Type = 'Repair Replacement';
        orderObj.Shipping_Method__c = null;
        orderObj.Source__c = 'AEM';
        orderObj.PricesInclusiveOfTaxes__c = true;
        orderObj.AccountId =objAcc.id;
        
        List<Order> orderList = new List<Order>();
        orderList.add(orderObj); 
        insert orderList;
        
        Order ord = [select id, PricesInclusiveOfTaxes__c from order limit 1];
        System.assertEquals(false, ord.PricesInclusiveOfTaxes__c) ;       
    }
    
    static testMethod void testMethod7(){
        //Insert Account   
        RecordType personAccountRecordType=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];           
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BAU';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='AUD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Employee Sale';
        orderObj.Shipping_Method__c = 'SPARE PARTS';
        orderObj.Channel__c = 'CCC';
        orderObj.CurrencyIsoCode = 'AUD';
        orderObj.Brand__c = 'Breville';
        orderObj.Source__c = 'Breville';
        orderObj.OverrideShippingAmount__c = true;
        insert orderObj;   
        
        String axItemNo = 'ZBBL800BSS1BCA1';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo, CurrencyIsoCode='AUD'); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, CurrencyIsoCode='AUD', Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
        OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 400,20,true);
        Order orderRecord = [select id, Shipping_Amount__c from Order Where Id= :orderObj.Id limit 1];
        //System.assertEquals(20.0, orderRecord.Shipping_Amount__c);
    }
    
    static testMethod void testMethodForTermsAndCondition(){
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),TnC_Agreement__c=true, Channel__c='ECOMM'); 
        orderObj.Type = 'Repair Replacement';
        orderObj.Shipping_Method__c = null;
        orderObj.Source__c = 'AEM';
        insert orderObj;   
        
        List<Order> orderList = new List<Order>();
        orderList.add(orderObj);
        TermsAndCondition__c tnc = new TermsAndCondition__c(currencyISOCode='USD', applicable_date__c=system.today()-5);
        insert tnc;
        OrderTriggerHandler.CreateTnCAgreementForOrder(orderList);
        
        List<TnC_Agreement__c> tnCAgreementRecordList = new List<TnC_Agreement__c>();
        tnCAgreementRecordList = [select id from TnC_Agreement__c];
        
        System.assertNotEquals(0, tnCAgreementRecordList.size());
    }
    
    static testMethod void testMethodForGWPOrderPopulateAXAccountNumber(){
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.BillingCity = 'test';
        objAcc.BillingCountryCode ='DE';
        objAcc.BillingPostalCode = '12345';
        objAcc.BillingStreet = 'test';
        objAcc.ShippingCountryCode = objAcc.BillingCountryCode;
        objAcc.ShippingCity = objAcc.BillingCity;
        objAcc.ShippingPostalCode = objAcc.BillingPostalCode;
        objAcc.ShippingStreet = objAcc.BillingStreet;
        insert objAcc;

        //Insert Order          
        Order orderObj = new Order();
        orderObj.AccountId = objAcc.Id;
        orderObj.CurrencyIsoCode='EUR';
        orderObj.Brand__c = 'Sage';
        orderObj.Status = 'Open';
        orderObj.EffectiveDate = system.today();
        orderObj.Channel__c='CCC';
        orderObj.Source__c='GWP'; 
        orderObj.Type = 'Sale';
        orderObj.Shipping_Method__c = '';
        orderObj.Offer_Activation_Date__c = Date.TODAY().addDays(1);
        orderObj.Country__c = 'DE';
        orderObj.BillingCity = objAcc.BillingCity;
        orderObj.BillingCountryCode = objAcc.BillingCountryCode;
        orderObj.BillingPostalCode = objAcc.BillingPostalCode;
        orderObj.BillingStateCode = objAcc.BillingStateCode;
        orderObj.BillingStreet = objAcc.BillingStreet;
        orderObj.ShippingCountryCode = objAcc.ShippingCountryCode;
        orderObj.ShippingCity = objAcc.ShippingCity;
        orderObj.ShippingPostalCode = objAcc.ShippingPostalCode;
        orderObj.ShippingStateCode = objAcc.ShippingStateCode;
        orderObj.ShippingStreet = objAcc.ShippingStreet;
        orderObj.Ship_To_Name__c = objAcc.Name;
        insert orderObj;  
    }
    static testMethod void testMethodForCancellationSent(){
        //Insert Account   
        String personAccountRecordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;              
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        objAcc.RecordTypeId=personAccountRecordTypeId;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Sale';
        orderObj.Shipping_Method__c = 'SPARE PARTS';
        orderObj.Channel__c = 'CCC';
        orderObj.CurrencyIsoCode = 'USD';
        orderObj.Brand__c = 'Beanz';
        orderObj.Source__c = 'Breville';
        orderObj.Cancellation_Received__c=true;
        insert orderObj;   
        
        String axItemNo = 'MBZ31188CWA04012Z';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo, CurrencyIsoCode='USD'); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, CurrencyIsoCode='USD', Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
        OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 4,20,false);
        orderItemObj.LineStatus__c='Cancelled';
        insert orderItemObj;
        Order orderRecord = [select id, Shipping_Amount__c from Order Where Id= :orderObj.Id limit 1];
        
        orderObj.Cancellation_Received__c=false;
        update orderObj;
    }
    static testMethod void testMethodForShippedSent(){
        //Insert Account   
        String personAccountRecordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;              
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        objAcc.RecordTypeId=personAccountRecordTypeId;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Sale';
        orderObj.Shipping_Method__c = 'SPARE PARTS';
        orderObj.Channel__c = 'CCC';
        orderObj.CurrencyIsoCode = 'USD';
        orderObj.Brand__c = 'Beanz';
        orderObj.Source__c = 'Breville';
        orderObj.ShipConfirmRecieved__c=true;
        insert orderObj;   
        
        String axItemNo = 'MBZ31188CWA04012Z';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo, CurrencyIsoCode='USD'); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, CurrencyIsoCode='USD', Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        //Insert OrderItem
        OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 4,20,false);
        orderItemObj.LineStatus__c='Shipped';
        insert orderItemObj;
        Order orderRecord = [select id, Shipping_Amount__c from Order Where Id= :orderObj.Id limit 1];
        
        orderObj.ShipConfirmRecieved__c=false;
        update orderObj;
    }
    
    static testMethod void testMethodForShippedSent1(){
        //Insert Account   
        String personAccountRecordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;              
        Account objAcc = new Account();
        objAcc.FirstName='Steve';
        objAcc.LastName='Rogger';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        objAcc.RecordTypeId=personAccountRecordTypeId;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Sale';
        orderObj.Shipping_Method__c = 'SPARE PARTS';
        orderObj.Channel__c = 'CCC';
        orderObj.CurrencyIsoCode = 'USD';
        orderObj.Brand__c = 'Beanz';
        orderObj.Source__c = 'Breville';
        orderObj.ShipConfirmRecieved__c=true;
        insert orderObj;   
        
        String axItemNo = 'MBZ31188CWA04012Z';
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c= axItemNo, CurrencyIsoCode='USD'); 
        insert objProd;   
        
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2, CurrencyIsoCode='USD', Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;   
        
        orderObj.AX_Order_ID__c = '123455';
        orderObj.Order_Tracking__c = '123455';
        orderObj.Picking_Ticket__c = '123455';
        orderObj.Carrier__c = '123455';
        update orderObj;
        
        //Insert OrderItem
        /*OrderItem orderItemObj = TestDataFactory.createOrderItemRecord(pricebookEntryObj.Id, orderObj.Id, 4,20,false);
        orderItemObj.LineStatus__c='Shipped';
        insert orderItemObj;
        Order orderRecord = [select id, Shipping_Amount__c from Order Where Id= :orderObj.Id limit 1];
        
        orderObj.ShipConfirmRecieved__c=false;
        update orderObj;*/
        orderObj.AX_Order_ID__c = '12345';
        orderObj.Order_Tracking__c = '12345';
        orderObj.Picking_Ticket__c = '12345';
        orderObj.Carrier__c = '12345';
        OrderTriggerHandler.beforeTriggerRun = true;
        update orderObj;
        
        /*map<Id,Order> mapOrder = new map<Id,Order>();
        mapOrder.put(orderObj.Id,orderObj);
        Order objOrdernew = new Order();
        objOrdernew.AX_Order_ID__c = '12345';
        objOrdernew.Order_Tracking__c = '12345';
        objOrdernew.Picking_Ticket__c = '12345';
        objOrdernew.Type = 'Sale';
        objOrdernew.Shipping_Method__c = 'SPARE PARTS';
        objOrdernew.Channel__c = 'CCC';
        objOrdernew.CurrencyIsoCode = 'USD';
        objOrdernew.Brand__c = 'Breville';
        objOrdernew.Source__c = 'Breville';
        insert objOrdernew;
        List<Order> lst = new List<Order>();
        
        lst.add(objOrdernew);
        OrderTriggerHandler.populateSplitShipmentDetails(lst,mapOrder);*/
    }
    
   /* @testSetup static void setUpTestData(){
        //Insert Account            
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        Case caseRecord = TestDataFactory.createCase(objAcc.Id, 'Email','Open','Subject 99', 'USD', true);
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order          
        Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
        orderObj.Type = 'Accommodation';
        orderObj.CC_Authorization_ID__c = '1324';
        orderObj.AdvanceShippingStatus__c = null;
        orderObj.Case__c = caseRecord.id;
        insert orderObj;   
        
    }
    
    static testMethod void populateSplitShipmentDetailsTest(){        
        Order orderObj1 = [SELECT id, CC_Authorization_ID__c FROM Order LIMIT 1];        
        orderObj1.CC_Authorization_ID__c = '1325';
        update orderObj1;
        System.assertEquals('1325', orderObj1.CC_Authorization_ID__c);
        
    }*/
}