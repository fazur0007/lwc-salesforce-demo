@isTest
public with sharing class NewOrderCtrlTest 
{    
    static testMethod void testMethodNewOrderCtrl1(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        insert accountRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = productRecord.id, UnitPrice = 1250.0, IsActive = true);
        insert standardPriceNew;
        
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        //System.debug('Record Id : '+pricebookRecord.Id);
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
       // orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderRecord1.Country__c='USA';
        orderRecord1.Shipping_Method__c=null;
       // orderRecord1.Shipping_Method__c='UPS 2ND';
        orderList.add(orderRecord1);
        
        Test.startTest();
        
        insert orderList;
        
        
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', orderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('recordId', caseRecord.id);
        ApexPages.CurrentPage().getparameters().put('idParam', orderRecord1.id );
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', orderRecord1.currencyISOCode);
        ApexPages.CurrentPage().getparameters().put('retURL', orderRecord1.id );
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(orderRecord1);   
        NewOrderCtrl newOrderCtrlRecord1 = new NewOrderCtrl(sc);
        newOrderCtrlRecord1.brand = 'Breville';
        newOrderCtrlRecord1.orderType = 'Sale';
        
        newOrderCtrlRecord1.getBrands() ;
        newOrderCtrlRecord1.getOrderTypes() ;
        newOrderCtrlRecord1.save();
        
        newOrderCtrlRecord1.isPortalUser=true;
        newOrderCtrlRecord1.isEmpPortalUser=true;
        newOrderCtrlRecord1.orderType = 'Sample';
        newOrderCtrlRecord1.checkPriceBookForOrder(orderRecord1);
        
        newOrderCtrlRecord1.orderType = 'Employee Sale';
        newOrderCtrlRecord1.checkPriceBookForOrder(orderRecord1);
        
        newOrderCtrlRecord1.orderType = 'Specialty Roaster';
        newOrderCtrlRecord1.checkPriceBookForOrder(orderRecord1);
        
        
        newOrderCtrlRecord1.orderType = 'Repair Replacement';
        newOrderCtrlRecord1.checkPriceBookForOrder(orderRecord1);
		//newOrderCtrlRecord1.createOrderAccount(accountRecord);
		PageReference pageReference = newOrderCtrlRecord1.cancel();
        
        Test.stopTest();
        
    }
    
    static testMethod void testMethodNewOrderCtrl2(){
        list<WorkOrder> workOrderList = new list<WorkOrder>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        update accountRecord;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
       // caseRecord.Service_Center__c = ServiceCentreAccount.Id; 
        caseRecord.Service_Center__c = null;
        update caseRecord;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale');
        insert pricebookRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = productRecord.id, UnitPrice = 1250.0, IsActive = true);
        insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(caseRecord.id, accountRecord.Id, 'USD', pricebookRecord.id, 
                                                                           ServiceCentreAccount.Id, 'workorder3@example.com','440022');
        workOrderRecord1.FirstName__c = 'Nikhil';
        workOrderRecord1.LastName__c = 'Palekar998';
        workOrderRecord1.Email__c = 'nikhilPalekar998@example.com';
        workOrderList.add(workOrderRecord1);
        
        Test.startTest();
        
        insert workOrderList;
        
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        //System.debug('Case Id : '+caseRecord.id);
        ApexPages.CurrentPage().getparameters().put('Id', workOrderRecord1.id);
       // ApexPages.CurrentPage().getparameters().put('recordId', caseRecord.id);
        //ApexPages.CurrentPage().getparameters().put('idParam', caseRecord.id );
        ApexPages.CurrentPage().getparameters().put('retURL', workOrderRecord1.id );
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', workOrderRecord1.currencyISOCode);
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(workOrderRecord1);   
        NewOrderCtrl newOrderCtrlRecord1 = new NewOrderCtrl(sc);
        newOrderCtrlRecord1.brand = 'Breville';
        newOrderCtrlRecord1.orderType = 'Work Order';
        
        newOrderCtrlRecord1.getBrands() ;
        newOrderCtrlRecord1.getOrderTypes() ;
        
        newOrderCtrlRecord1.save();
        
        newOrderCtrlRecord1.orderType = 'Repair Replacement';
        
        workOrderRecord1.Status = 'Unrepairable';
        workOrderRecord1.CaseId = caseRecord.id;
        newOrderCtrlRecord1.save();
        
        Test.stopTest();
        
    }
    
    static testMethod void testMethodNewOrderCtrl3(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        update accountRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale');
        insert pricebookRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = productRecord.id, UnitPrice = 1250.0, IsActive = true);
        insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
       // orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderList.add(orderRecord1);
        
        Test.startTest();
        
        insert orderList;
        
        //Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', orderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('recordId', accountRecord.id);
        ApexPages.CurrentPage().getparameters().put('idParam', accountRecord.id );
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', orderRecord1.currencyISOCode);
        ApexPages.CurrentPage().getparameters().put('retURL', orderRecord1.id );
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(orderRecord1);   
        NewOrderCtrl newOrderCtrlRecord1 = new NewOrderCtrl(sc);
        newOrderCtrlRecord1.brand = 'Breville';
        newOrderCtrlRecord1.orderType = 'Sale';
        
        newOrderCtrlRecord1.getBrands() ;
        newOrderCtrlRecord1.getOrderTypes() ;
        
        newOrderCtrlRecord1.save();
        
        Test.stopTest();
        
    }
    
    
    static testMethod void testMethodNewOrderCtrl4(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'AU';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NSW';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'AU';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NSW';
        accountRecord.ShippingStreet = 'ghi';
        update accountRecord;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre AUS', 'BAU','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        //Case caseRecord = new Case(Origin='Email', Subject='Subject 99', Status='Open', CurrencyISOCode='AUD', Warranty__c ='In Warranty' , Purchase_Date__c= Date.today()-10);
        //insert caseRecord;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'AUD', true);
        //caseRecord.Service_Center__c = ServiceCentreAccount.Id;
        update caseRecord;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='AUS Wholesale Pricebook', isActive=true, Region__c='AUS', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry();
        standardPriceNew.pricebook2Id = pricebookRecord.id;
        standardPriceNew.product2id = productRecord.id;
        standardPriceNew.unitprice = 1250.0;
        standardPriceNew.isactive = true;
        insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '411111111111111', 'Breville','AUD');
        //TestDataFactory.createWorkOrderRecord(caseRecord.id, accountRecord.Id, 'AUD', pricebookRecord.id, ServiceCentreAccount.Id, 'workorder3@example.com','440022');
       	orderRecord1.OrderSubcategory__c =  'Employee Sale';
        orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderList.add(orderRecord1);
        
        Test.startTest();
        
        insert orderRecord1;
        
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', orderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('recordId', accountRecord.id);
        ApexPages.CurrentPage().getparameters().put('idParam', accountRecord.id );
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', orderRecord1.currencyISOCode);
        ApexPages.CurrentPage().getparameters().put('retURL', orderRecord1.id );
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(orderRecord1);   
        NewOrderCtrl newOrderCtrlRecord1 = new NewOrderCtrl(sc);
        newOrderCtrlRecord1.brand = 'Breville';
        newOrderCtrlRecord1.orderType = 'Sale';
        
        newOrderCtrlRecord1.getBrands() ;
        newOrderCtrlRecord1.getOrderTypes();
        newOrderCtrlRecord1.copyBrevilleOfficeAddressAsShipping(orderRecord1, accountRecord);
        
        newOrderCtrlRecord1.save();
        
        Test.stopTest();
        
    }
    
    static testMethod void testMethodNewOrderCtrl5(){
        list<WorkOrder> workOrderList = new list<WorkOrder>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        update accountRecord;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        caseRecord.Service_Center__c = ServiceCentreAccount.Id;
        update caseRecord;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale');
        insert pricebookRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry();
        standardPriceNew.pricebook2Id = pricebookRecord.id;
        standardPriceNew.product2id = productRecord.id;
        standardPriceNew.unitprice = 1250.0;
        standardPriceNew.isactive = true;
        insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(caseRecord.id, accountRecord.Id, 'USD', pricebookRecord.id, 
                                                                           ServiceCentreAccount.Id, 'workorder3@example.com','440022');
        workOrderRecord1.FirstName__c = 'Nikhil';
        workOrderRecord1.LastName__c = 'Palekar998';
        workOrderRecord1.Email__c = 'nikhilPalekar998@example.com';
        workOrderList.add(workOrderRecord1);
        
        Test.startTest();
        
        insert workOrderList;
        
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', workOrderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('recordId', caseRecord.id);
        ApexPages.CurrentPage().getparameters().put('idParam', accountRecord.id);
        ApexPages.CurrentPage().getparameters().put('retURL', workOrderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', workOrderRecord1.currencyISOCode);
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(workOrderRecord1);   
        NewOrderCtrl newOrderCtrlRecord1 = new NewOrderCtrl(sc);
        newOrderCtrlRecord1.brand = 'Breville';
        newOrderCtrlRecord1.orderType = 'Work Order';
        
        newOrderCtrlRecord1.getBrands();
        newOrderCtrlRecord1.getOrderTypes();
        newOrderCtrlRecord1.orderTypeChange();
        newOrderCtrlRecord1.getOrderDeliveryOptions();
        
        newOrderCtrlRecord1.save();
        Test.stopTest();
    }
    
    static testMethod void testSaveMethod(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'AU';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NSW';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'AU';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NSW';
        accountRecord.ShippingStreet = 'ghi';
        update accountRecord;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre AUS', 'BAU','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        //Case caseRecord = new Case(Origin='Email', Subject='Subject 99', Status='Open', CurrencyISOCode='AUD', Warranty__c ='In Warranty' , Purchase_Date__c= Date.today()-10);
        //insert caseRecord;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'AUD', true);
        //caseRecord.Service_Center__c = ServiceCentreAccount.Id;
        update caseRecord;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='AUS Wholesale Pricebook', isActive=true, Region__c='AUS', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry();
        standardPriceNew.pricebook2Id = pricebookRecord.id;
        standardPriceNew.product2id = productRecord.id;
        standardPriceNew.unitprice = 1250.0;
        standardPriceNew.isactive = true;
        insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '411111111111111', 'Breville','AUD');
        //TestDataFactory.createWorkOrderRecord(caseRecord.id, accountRecord.Id, 'AUD', pricebookRecord.id, ServiceCentreAccount.Id, 'workorder3@example.com','440022');
       	orderRecord1.OrderSubcategory__c =  'Employee Sale';
        orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderList.add(orderRecord1);
        
        Test.startTest();
        
        insert orderRecord1;
        
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', orderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('recordId', caseRecord.id);
        ApexPages.CurrentPage().getparameters().put('idParam', orderRecord1.id );
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', orderRecord1.currencyISOCode);
        ApexPages.CurrentPage().getparameters().put('retURL', orderRecord1.id );
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(orderRecord1);   
        
          
        NewOrderCtrl newOrderCtrl = new NewOrderCtrl(sc);
        newOrderCtrl.brand = 'Breville';
        newOrderCtrl.orderType = 'Sale';
        newOrderCtrl.getBrands() ;
        newOrderCtrl.getOrderTypes();
        newOrderCtrl.save();
        
        Test.stopTest();
        
    }
    
    static testMethod void testSaveMethod1(){
        list<Order> orderList = new list<Order>();
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'AU';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NSW';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'AU';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NSW';
        accountRecord.ShippingStreet = 'ghi';
        update accountRecord;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre AUS', 'BAU','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
        ServiceCentreAccount.Type = 'Authorized Service Center';
        insert ServiceCentreAccount;
        
        //Case caseRecord = new Case(Origin='Email', Subject='Subject 99', Status='Open', CurrencyISOCode='AUD', Warranty__c ='In Warranty' , Purchase_Date__c= Date.today()-10);
        //insert caseRecord;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'AUD', true);
        //caseRecord.Service_Center__c = ServiceCentreAccount.Id;
        update caseRecord;
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='AUS Wholesale Pricebook', isActive=true, Region__c='AUS', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,true);
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry();
        standardPriceNew.pricebook2Id = pricebookRecord.id;
        standardPriceNew.product2id = productRecord.id;
        standardPriceNew.unitprice = 1250.0;
        standardPriceNew.isactive = true;
        insert standardPriceNew;
        
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
                                                               '411111111111111', 'Breville','AUD');
        //TestDataFactory.createWorkOrderRecord(caseRecord.id, accountRecord.Id, 'AUD', pricebookRecord.id, ServiceCentreAccount.Id, 'workorder3@example.com','440022');
       	orderRecord1.OrderSubcategory__c =  'Employee Sale';
        orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderList.add(orderRecord1);
        
        Test.startTest();
        
        insert orderRecord1;
        
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord.Id and Product2.SKU__c='PN1' limit 1];
        
        PageReference pageRef = Page.NewOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('Id', orderRecord1.id);
        ApexPages.CurrentPage().getparameters().put('recordId', caseRecord.id);
        ApexPages.CurrentPage().getparameters().put('idParam', orderRecord1.id );
        ApexPages.CurrentPage().getparameters().put('currencyISOCode', orderRecord1.currencyISOCode);
        ApexPages.CurrentPage().getparameters().put('retURL', orderRecord1.id );
        // pageRef.getParameters().put('recordId', caseRecord.id);
        // pageRef.getParameters().put('retURL', caseRecord.id );
        
        ApexPages.StandardController sc = new ApexPages.standardController(orderRecord1);   
        NewOrderCtrl newOrderCtrlRecord1 = new NewOrderCtrl(sc);
        newOrderCtrlRecord1.brand = 'Breville';
        newOrderCtrlRecord1.getBrands() ;
        newOrderCtrlRecord1.getOrderTypes();
        newOrderCtrlRecord1.copyBrevilleOfficeAddressAsShipping(orderRecord1, accountRecord);
        newOrderCtrlRecord1.save();
        
        
        Test.stopTest();
        
    }
}