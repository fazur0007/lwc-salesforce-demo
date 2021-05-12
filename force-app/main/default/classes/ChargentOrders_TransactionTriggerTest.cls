@isTest(SeeAllData=true)
private class ChargentOrders_TransactionTriggerTest {

    static testMethod void myUnitTest() {
    	list<Order> orderList = new list<Order>();
    	list<WorkOrder> workOrderList = new list<WorkOrder>();
    	list<ChargentOrders__Transaction__c> transactionList = new list<ChargentOrders__Transaction__c>();
    	
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
		ServiceCentreAccount.BillingPostalCode = '440022';
		ServiceCentreAccount.ShippingPostalCode = '440022';
		insert ServiceCentreAccount;
		Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
		Contact contactRecord = TestDataFactory.createContact(accountRecord.Id, 'NikhilContact99', true);
		Pricebook2 pricebookRecord =  [select id from Pricebook2 where Region__c='USA' and Type__c='Wholesale' limit 1];
		Product2 productRecord = TestDataFactory.createProduct('Product 998', true, true);
		productRecord.AX_Item_Number__c = '1234';
		productRecord.Serviceable__c = true;
		update productRecord;
		
		RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
		Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
																	'411111111111111', 'Breville','USD');
		orderRecord1.OrderSubcategory__c = 'Employee Sale';
		orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
		orderList.add(orderRecord1);
		
		WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(null, accountRecord.Id, 'USD', pricebookRecord.Id, ServiceCentreAccount.Id, 'workorder1@example.com','440022');
		list<Case> caseList = [select id, CaseNumber from Case where Subject='subject 99' limit 1];
		workOrderRecord1.CaseNumber__c = String.valueOf(caseList[0].CaseNumber);
		workOrderRecord1.InspectionCharge__c = 10;
		workOrderRecord1.LaborCharge__c = 20;
		workOrderRecord1.FreightCharge__c = 30;
		workOrderRecord1.FlatServiceCharge__c = 40;
		workOrderRecord1.Discounted_Inspection_Charge__c = 8;
		workOrderRecord1.Discounted_Labor_Charge__c = 18;
		workOrderRecord1.Discounted_Freight_Charge__c = 27;
		workOrderRecord1.Discounted_Flat_Service_Charge__c = 36;
		workOrderRecord1.product__c = productRecord.Id;
		workOrderList.add(workOrderRecord1);
		//insert workOrderRecord1;
		
		test.startTest();
		
		insert orderList;
		insert workOrderList;
		ChargentOrders__ChargentOrder__c chargentOrderRecord = new ChargentOrders__ChargentOrder__c();
		chargentOrderRecord.Order__c = orderRecord1.Id;
		chargentOrderRecord.WorkOrder__c = workOrderRecord1.Id;
		insert chargentOrderRecord;
		
		ChargentOrders__Transaction__c transactionRecord = new ChargentOrders__Transaction__c();
		transactionRecord.ChargentOrders__Order__c = chargentOrderRecord.Id;
		transactionRecord.ChargentOrders__Type__c = 'Authorization';
		transactionRecord.ChargentOrders__Gateway_Date__c = Date.today();
		transactionRecord.ChargentOrders__Gateway_ID__c = null;
		transactionRecord.CC_Auth_Exp__c = Date.today();
        transactionRecord.ChargentOrders__Response_Status__c='Approved';
		transactionList.add(transactionRecord);
		/*
		ChargentOrders__Transaction__c transactionRecord2 = new ChargentOrders__Transaction__c();
		transactionRecord2.ChargentOrders__Order__c = chargentOrderRecord.Id;
		transactionRecord2.ChargentOrders__Type__c = 'Charge';
		transactionRecord.ChargentOrders__Gateway_Date__c = Date.today();
		transactionRecord.ChargentOrders__Gateway_ID__c = null;
		transactionRecord.CC_Auth_Exp__c = Date.today();
		transactionList.add(transactionRecord2);
		*/
		insert transactionList;
		test.stopTest();
		
    }
    
    static testMethod void changeLNStatus() {
    	list<Order> orderList = new list<Order>();
    	list<WorkOrder> workOrderList = new list<WorkOrder>();
    	list<ChargentOrders__Transaction__c> transactionList = new list<ChargentOrders__Transaction__c>();
    	
        Account Acc = new Account();
        Acc.FirstName='SF Testing';
        Acc.LastName='Acc';
        Acc.PersonEmail='Test@gmail.com';
        Acc.Agreed_for_Opt_in__c=true;
        Acc.Phone = '43534545';
        Acc.BillingCountryCode = 'US';
        Acc.BillingStreet = '23 maitreya';
        Acc.BillingCity = 'LA';
        Acc.BillingStateCode = 'CA';
        Acc.BillingPostalCode ='470027' ;
        insert Acc;
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre USA', 'BUS','servicecentre_usa@example.com','7896541233');
		ServiceCentreAccount.BillingPostalCode = '440022';
		ServiceCentreAccount.ShippingPostalCode = '440022';
		insert ServiceCentreAccount;
        
        Case caseRecord = TestDataFactory.createCase(Acc.Id, 'Email','Open','Subject 99', 'USD', true);
		//Contact contactRecord = TestDataFactory.createContact(Acc.Id, 'NikhilContact99', true);
        
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        objProd.Dimensions__c = '11 1/2 X 9 1/8 X 16 3/8';
        objProd.Weight__c = 12.0;
        objProd.Length__c = 12.0;
        objProd.Height__c = 12.0;
        objProd.Width__c = 12.0;
        objProd.Country_of_Manufacture__c='CN';
        objProd.Landed_Cost__c=222;
        objProd.Description='Test Data';
        objProd.Quantity_Available__c = 34;
        objProd.AX_Item_Number__c = '1234';
		objProd.Serviceable__c = true;
        insert objProd;  
        
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', isActive=true, Region__c='USA', Type__c='Wholesale',Brand__c='Breville');
        insert pricebookRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = objProd.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        PricebookEntry standardPriceNew = new PricebookEntry(Pricebook2Id = pricebookRecord.id, Product2Id = objProd.id, UnitPrice = 1250.0, IsActive = true);
        insert standardPriceNew;
		
		RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
		
        Loaner_Program__c lp = new Loaner_Program__c();
        lp.Active__c= true;
        lp.Product__c=objProd.id;
        lp.PriceBook__c=pricebookRecord.id;
        //lp.PriceBookEntryId__c='01u2C0000093EyOQAU';
        lp.PriceBookEntryId__c=standardPrice.Id;
        lp.ProgramName__c = 'Control_Freak';
        lp.Run_Selection_Process__c =true;
        lp.Initial_Amount__c=100;
        insert lp;
        
        Loaner_Nomination__c loaner= new Loaner_Nomination__c();
        loaner.Status__c='Order Created-Quote Sent';
        loaner.Account__c=Acc.id;
        loaner.Loaner_Program__c=lp.id;
        loaner.Link_Expiration_date__c = system.today() -8;
        insert loaner;
        
        Order ordrObj = TestDataFactory.createOrderRecord(Acc.Id,'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
																	'411111111111111', 'Breville','USD');
        
        //Order ordrObj = new Order();
        ordrObj.AccountId =Acc.Id;
        ordrObj.LoanerProgram__c =lp.id;
        ordrObj.Loaner_Nomination__c = loaner.id;
        ordrObj.Status = 'Open';
        ordrObj.type='Loaner Program Sale';
        ordrObj.EffectiveDate =system.today()-8;
       	orderList.add(ordrObj);
		
		WorkOrder workOrderRecord1 = TestDataFactory.createWorkOrderRecord(null, Acc.Id, 'USD', pricebookRecord.Id, ServiceCentreAccount.Id, 'workorder1@example.com','440022');
		list<Case> caseList = [select id, CaseNumber from Case where Subject='subject 99' limit 1];
		workOrderRecord1.CaseNumber__c = String.valueOf(caseList[0].CaseNumber);
		workOrderRecord1.InspectionCharge__c = 10;
		workOrderRecord1.LaborCharge__c = 20;
		workOrderRecord1.FreightCharge__c = 30;
		workOrderRecord1.FlatServiceCharge__c = 40;
		workOrderRecord1.Discounted_Inspection_Charge__c = 8;
		workOrderRecord1.Discounted_Labor_Charge__c = 18;
		workOrderRecord1.Discounted_Freight_Charge__c = 27;
		workOrderRecord1.Discounted_Flat_Service_Charge__c = 36;
		workOrderRecord1.product__c = objProd.Id;
		workOrderList.add(workOrderRecord1);
		
		test.startTest();
		
		insert orderList;
        
		insert workOrderList;
		ChargentOrders__ChargentOrder__c chargentOrderRecord = new ChargentOrders__ChargentOrder__c();
		chargentOrderRecord.Order__c = ordrObj.Id;
		chargentOrderRecord.WorkOrder__c = workOrderRecord1.Id;
		insert chargentOrderRecord;
		
		ChargentOrders__Transaction__c transactionRecord = new ChargentOrders__Transaction__c();
		transactionRecord.ChargentOrders__Order__c = chargentOrderRecord.Id;
		transactionRecord.ChargentOrders__Type__c = 'Authorization';
		transactionRecord.ChargentOrders__Gateway_Date__c = Date.today();
		transactionRecord.ChargentOrders__Gateway_ID__c = null;
		transactionRecord.CC_Auth_Exp__c = Date.today();
		transactionList.add(transactionRecord);
		
		insert transactionList;
		
		test.stopTest();
		
		
		
    }
    
}