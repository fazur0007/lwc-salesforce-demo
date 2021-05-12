/**
* Test class for Send Quote Controller.
* 
* Functionality :
* (1) Method to test the Creation of payment records for order.
* (2) Method to test if breville email template was sent with order line item to customer.
* (3) Method to test if polyscience email template was sent with order line item to customer.
* 
* Version       Author        Last Modified Date(MM/DD/YYYY)        Description 
*  1.0        Yogesh Sharma          12/15/2015                    Initial Draft
 */
@isTest
private class SendQuoteControllerTest {
/*
* Method to test if polyscience email template was sent with order line item to 
* customer(Person email Id). Also if payment record was created for order object
*/
	static testMethod void positiveTestBreville() {

		TestObjects testDataClassObj = new TestObjects();
        Account accObject = new Account();
        accObject.FirstName = 'Test';
        accObject.LastName = 'Test';
        accObject.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        accObject.PersonEmail = 'john@gmail.com';
        insert accObject;
		
		Pricebook2 brevillePB = new Pricebook2();
		brevillePB.Name = 'Breville';
		brevillePB.IsActive = true;
		insert brevillePB;

		Pricebook2 polySciencePB = new Pricebook2();
		polySciencePB.Name = 'PolyScience';
		polySciencePB.IsActive = true;
		insert polySciencePB;

		Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
		orderObj.Pricebook2Id = brevillePB.Id;
		orderObj.Status = 'Open';
		orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
		//BillToContact.Email,
		//orderObj.BillToContactId = billingConObj.id;
		//Account.PersonContactId,
		orderObj.IsCalculated__c=true;
		orderObj.Type = 'Sale';
		orderObj.Shipping_Method__c = 'UPS GROUND';
		orderObj.Type = 'Accommodation';
		orderObj.CC_Authorization_ID__c = '1324';
		orderObj.AdvanceShippingStatus__c = null;
		insert orderObj;

		Test.startTest();

		PageReference sendQuotePage = Page.WebToCase;
		sendQuotePage.getParameters().put('id',orderObj.Id);
		Test.setCurrentPageReference(sendQuotePage);

		ApexPages.StandardController sc = new ApexPages.standardController(new Order());
		SendQuoteController objHandler = new SendQuoteController(sc);

		objHandler.init();
		orderObj.Type = 'Sale';
		upsert orderObj;
		
		objHandler.init();

		
		Test.stopTest();
		

	}//End of positiveTestBreville
/*
* Method to test if Breville email template was sent with order line item to 
* customer(Person email Id). Also if payment record was created for order object
*/
	static testMethod void positiveTestPolyScience() {

        TestObjects testDataClassObj = new TestObjects();
        Account accObject = testDataClassObj.getAccount(true);
        Contact billingConObj = testDataClassObj.getContact(accObject.Id, true);

		
        Pricebook2 brevillePB = new Pricebook2();
        brevillePB.Name = 'Breville';
        brevillePB.IsActive = true;
        insert brevillePB;

        Pricebook2 polySciencePB = new Pricebook2();
        polySciencePB.Name = 'PolyScience';
        polySciencePB.IsActive = true;
        insert polySciencePB;

        Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
        orderObj.Pricebook2Id = polySciencePB.Id;
        orderObj.Status = 'Open';
        orderObj.Type = 'Accommodation';
		orderObj.CC_Authorization_ID__c = '1324';
		orderObj.AdvanceShippingStatus__c = null;
        orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
        insert orderObj;

        Test.startTest();

        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',orderObj.Id);
        Test.setCurrentPageReference(sendQuotePage);

        ApexPages.StandardController sc = new ApexPages.standardController(new Order());
        SendQuoteController objHandler = new SendQuoteController(sc);

        objHandler.init();

        Test.stopTest();
        pymt__PaymentX__c payment = new pymt__PaymentX__c(
                Name = 'Scheduled Payment',
                pymt__Shipping__c = 0, // optional
                pymt__Currency_ISO_Code__c = 'USD', 
                pymt__Account__c = orderObj.AccountId,
                pymt__Contact__c = billingConObj.id); 
         
         insert payment;

        list<pymt__PaymentX__c> paymentList = [Select Id,
                                                      Name,
                                                      pymt__Account__c,
                                                      pymt__Contact__c,
                                                      pymt__Shipping__c
                                                 From pymt__PaymentX__c];

        list<Order> listOrder = [Select Id,
                                        Name,
                                        OrderNumber,
                                        AccountId,
                                        BillToContactId,
                                        Shipping_Amount__c,
                                        PaymentId__c
                                   From Order];

       system.assertEquals(paymentList.size(), 1);

        //system.assertEquals(paymentList[0].Name, listOrder[0].OrderNumber);

        //system.assertEquals(paymentList[0].pymt__Shipping__c,listOrder[0].Shipping_Amount__c);

        //system.assertEquals(paymentList[0].pymt__Account__c, listOrder[0].AccountId);

        //system.assertEquals(paymentList[0].pymt__Contact__c, listOrder[0].BillToContactId);

        //system.assertEquals(listOrder[0].PaymentId__c, paymentList[0].Id);
    }//End of positiveTestPolyScience
/*
* Method to test if breville email template was sent with order line item to 
* customer(Bill to contact email Id). Also if payment record was created for 
* order object
*/
    static testMethod void emailIdNullTestForBreville() {

        TestObjects testDataClassObj = new TestObjects();
        Account accObject = testDataClassObj.getAccount(true);
        Contact billingConObj = testDataClassObj.getContact(accObject.Id, true);

        Pricebook2 brevillePB = new Pricebook2();
        brevillePB.Name = 'Breville';
        brevillePB.IsActive = true;
        insert brevillePB;

        Pricebook2 polySciencePB = new Pricebook2();
        polySciencePB.Name = 'PolyScience';
        polySciencePB.IsActive = true;
        insert polySciencePB;

        Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
        orderObj.Pricebook2Id = brevillePB.Id;
        orderObj.Status = 'Open';
        orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
        orderObj.BillToContactId = billingConObj.Id;
        insert orderObj;
        system.debug('++++++++++++++++++++++++++++++++++++'+orderObj.AccountId);

        Test.startTest();

        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',orderObj.Id);
        Test.setCurrentPageReference(sendQuotePage);

        ApexPages.StandardController sc = new ApexPages.standardController(new Order());
        SendQuoteController objHandler = new SendQuoteController(sc);

        objHandler.init();

      
        
        Test.stopTest();
        
        
          pymt__PaymentX__c payment = new pymt__PaymentX__c(
                Name = 'Scheduled Payment',
                pymt__Shipping__c = 0, // optional
                pymt__Currency_ISO_Code__c = 'USD', 
                pymt__Account__c = orderObj.AccountId,
                pymt__Contact__c = billingConObj.id); 
         
         insert payment;
        

        list<pymt__PaymentX__c> paymentList = [Select Id,
                                                      Name,
                                                      pymt__Account__c,
                                                      pymt__Contact__c,
                                                      pymt__Shipping__c
                                                 From pymt__PaymentX__c];

        list<Order> listOrder = [Select Id,
                                        Name,
                                        OrderNumber,
                                        AccountId,
                                        BillToContactId,
                                        Shipping_Amount__c,
                                        PaymentId__c
                                   From Order];

        system.assertEquals(paymentList.size(), 1);

        //system.assertEquals(paymentList[0].Name, listOrder[0].OrderNumber);

        //system.assertEquals(paymentList[0].pymt__Shipping__c,listOrder[0].Shipping_Amount__c);

        //system.assertEquals(paymentList[0].pymt__Account__c, listOrder[0].AccountId);

        //system.assertEquals(paymentList[0].pymt__Contact__c, listOrder[0].BillToContactId);

        //system.assertEquals(listOrder[0].PaymentId__c, paymentList[0].Id);
    }//End of emailIdNullTestForBreville
/*
* Method to test if polyscience email template was sent with order line item to 
* customer(Bill to contact email Id). Also if payment record was created for 
* order object
*/
    static testMethod void emailIdNullTestForPolyScience() {

        TestObjects testDataClassObj = new TestObjects();
        Account accObject = testDataClassObj.getAccount(true);
        Contact billingConObj = testDataClassObj.getContact(accObject.Id, true);

        Pricebook2 brevillePB = new Pricebook2();
        brevillePB.Name = 'Breville';
        brevillePB.IsActive = true;
        insert brevillePB;

        Pricebook2 polySciencePB = new Pricebook2();
        polySciencePB.Name = 'PolyScience';
        polySciencePB.IsActive = true;
        insert polySciencePB;

        Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
        orderObj.Pricebook2Id = polySciencePB.Id;
        orderObj.Status = 'Open';
        orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
        orderObj.BillToContactId = billingConObj.Id;
        insert orderObj;

        Test.startTest();

        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',orderObj.Id);
        Test.setCurrentPageReference(sendQuotePage);

        ApexPages.StandardController sc = new ApexPages.standardController(new Order());
        SendQuoteController objHandler = new SendQuoteController(sc);

        objHandler.init();

        Test.stopTest();
        pymt__PaymentX__c payment = new pymt__PaymentX__c(
                Name = 'Scheduled Payment',
                pymt__Shipping__c = 0, // optional
                pymt__Currency_ISO_Code__c = 'USD', 
                pymt__Account__c = orderObj.AccountId,
                pymt__Contact__c = billingConObj.id); 
         
         insert payment;

        list<pymt__PaymentX__c> paymentList = [Select Id,
                                                      Name,
                                                      pymt__Account__c,
                                                      pymt__Contact__c,
                                                      pymt__Shipping__c
                                                 From pymt__PaymentX__c];

        list<Order> listOrder = [Select Id,
                                        Name,
                                        OrderNumber,
                                        AccountId,
                                        BillToContactId,
                                        Shipping_Amount__c,
                                        PaymentId__c
                                   From Order];

        system.assertEquals(paymentList.size(), 1);

         //system.assertEquals(paymentList[0].Name, listOrder[0].OrderNumber);

        //system.assertEquals(paymentList[0].pymt__Shipping__c,listOrder[0].Shipping_Amount__c);

        //system.assertEquals(paymentList[0].pymt__Account__c, listOrder[0].AccountId);

        //system.assertEquals(paymentList[0].pymt__Contact__c, listOrder[0].BillToContactId);

        //system.assertEquals(listOrder[0].PaymentId__c, paymentList[0].Id);
    }//End of emailIdNullTestForPolyScience
/*
* Method to test no email template was sent with order line item to customer.
* Also no payment record was created for order object.
*/
    static testMethod void emailIdNullTestForOrder() {

        TestObjects testDataClassObj = new TestObjects();
        Account accObject = testDataClassObj.getAccount(true);
        //accObject.PersonEmail = 'john@gmail.com';
        //upsert accObject;
        Contact billingConObj = testDataClassObj.getContact(accObject.Id, true);
		//billingConObj.Email = 'john@gmail.com';
		//upsert billingConObj;
		
		Pricebook2 brevillePB = new Pricebook2();
		brevillePB.Name = 'Breville';
		brevillePB.IsActive = true;
		insert brevillePB;

		Pricebook2 polySciencePB = new Pricebook2();
		polySciencePB.Name = 'PolyScience';
		polySciencePB.IsActive = true;
		insert polySciencePB;

		Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
		orderObj.Pricebook2Id = brevillePB.Id;
		orderObj.Status = 'Open';
		orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
		//BillToContact.Email,
		orderObj.BillToContactId = billingConObj.id;
		//Account.PersonContactId,
		orderObj.IsCalculated__c=true;
		orderObj.Type = 'Sale';
		orderObj.Shipping_Method__c = null;
		
		insert orderObj;
        
        Test.startTest();

        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',null);
        Test.setCurrentPageReference(sendQuotePage);

        ApexPages.StandardController sc = new ApexPages.standardController(orderObj);
        SendQuoteController objHandler = new SendQuoteController(sc);

        objHandler.init();

        Test.stopTest();
       

        list<pymt__PaymentX__c> paymentList = [Select Id,
                                                      Name,
                                                      pymt__Account__c,
                                                      pymt__Contact__c,
                                                      pymt__Shipping__c
                                                 From pymt__PaymentX__c];

        list<Order> listOrder = [Select Id,
                                        Name,
                                        OrderNumber,
                                        AccountId,
                                        BillToContactId,
                                        Shipping_Amount__c,
                                        PaymentId__c
                                   From Order];

        system.assertEquals(paymentList.size(), 0);
        //system.assertEquals(listOrder.size(), 0);
    }//End of emailIdNullTestForOrder
/*
* Method to test if no email template was sent with order line item to 
* customer(As bill to contact email id is null).
* But payment record was created for order object.
*/
    static testMethod void negativeTest() {

        TestObjects testDataClassObj = new TestObjects();
        Account accObject = testDataClassObj.getAccount(true);
        Contact billingConObj = testDataClassObj.getContact(accObject.Id, true);
        billingConObj.Email = null;
        update billingConObj;

        Pricebook2 brevillePB = new Pricebook2();
        brevillePB.Name = 'Breville';
        brevillePB.IsActive = true;
        insert brevillePB;

        Pricebook2 polySciencePB = new Pricebook2();
        polySciencePB.Name = 'PolyScience';
        polySciencePB.IsActive = true;
        insert polySciencePB;

        Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
        orderObj.Pricebook2Id = polySciencePB.Id;
        orderObj.Status = 'Open';
        orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
        orderObj.BillToContactId = billingConObj.Id;
        insert orderObj;

        Test.startTest();

        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',orderObj.Id);
        Test.setCurrentPageReference(sendQuotePage);

        ApexPages.StandardController sc = new ApexPages.standardController(new Order());
        SendQuoteController objHandler = new SendQuoteController(sc);

        objHandler.init();

        Test.stopTest();
        pymt__PaymentX__c payment = new pymt__PaymentX__c(
                Name = 'Scheduled Payment',
                pymt__Shipping__c = 0, // optional
                pymt__Currency_ISO_Code__c = 'USD', 
                pymt__Account__c = orderObj.AccountId,
                pymt__Contact__c = billingConObj.id); 
         
         insert payment;

        list<pymt__PaymentX__c> paymentList = [Select Id,
                                                      Name,
                                                      pymt__Account__c,
                                                      pymt__Contact__c,
                                                      pymt__Shipping__c
                                                 From pymt__PaymentX__c];

        list<Order> listOrder = [Select Id,
                                        Name,
                                        OrderNumber,
                                        AccountId,
                                        BillToContactId,
                                        Shipping_Amount__c,
                                        PaymentId__c
                                   From Order];

        system.assertEquals(paymentList.size(), 1);

         //system.assertEquals(paymentList[0].Name, listOrder[0].OrderNumber);

        //system.assertEquals(paymentList[0].pymt__Shipping__c,listOrder[0].Shipping_Amount__c);

        //system.assertEquals(paymentList[0].pymt__Account__c, listOrder[0].AccountId);

        //system.assertEquals(paymentList[0].pymt__Contact__c, listOrder[0].BillToContactId);

        //system.assertEquals(listOrder[0].PaymentId__c, paymentList[0].Id);
    }//End of negativeTest
    
    static testMethod void testSendQuoteForEmpPortal(){
    	TestObjects testDataClassObj = new TestObjects();
        Account accObject = new Account();
        accObject.FirstName = 'Test';
        accObject.LastName = 'Test';
        accObject.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        accObject.PersonEmail = 'test@example.com';
        insert accObject;
		
		Pricebook2 brevillePB = new Pricebook2();
		brevillePB.Name = 'Breville';
		brevillePB.IsActive = true;
		insert brevillePB;

		Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
		orderObj.Pricebook2Id = brevillePB.Id;
		orderObj.Status = 'Open';
		//orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
		//BillToContact.Email,
		//orderObj.BillToContactId = billingConObj.id;
		//Account.PersonContactId,
		orderObj.IsCalculated__c=true;
		orderObj.Type = 'Employee Sale';
		orderObj.Shipping_Method__c = 'UPS GROUND';
		orderObj.AdvanceShippingStatus__c = null;
		

	//	Test.startTest();

		insert orderObj;
        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',orderObj.Id);
        Test.setCurrentPageReference(sendQuotePage);
		ApexPages.StandardController sc = new ApexPages.standardController(new Order());
		SendQuoteController objHandler = new SendQuoteController(sc);

		System.assert(objHandler.initPaymentForEmpPortal()!=null);
		
	//			
		//Test.stopTest();
    }
    
    static testMethod void testSendQuoteForEmpPortalExp(){
    	TestObjects testDataClassObj = new TestObjects();
        Account accObject = new Account();
        accObject.FirstName = 'Test';
        accObject.LastName = 'Test';
        accObject.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        accObject.PersonEmail = 'test@example.com';
        insert accObject;
		
		Pricebook2 brevillePB = new Pricebook2();
		brevillePB.Name = 'Breville';
		brevillePB.IsActive = true;
		insert brevillePB;

		Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
		orderObj.Pricebook2Id = brevillePB.Id;
		orderObj.Status = 'Open';
		//orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
		//BillToContact.Email,
		//orderObj.BillToContactId = billingConObj.id;
		//Account.PersonContactId,
		orderObj.IsCalculated__c=true;
		orderObj.Type = 'Employee Sale';
		orderObj.Shipping_Method__c = 'UPS GROUND';
		orderObj.AdvanceShippingStatus__c = null;
	
		Test.startTest();

		insert orderObj;
		ApexPages.StandardController sc = new ApexPages.standardController(new Order());
		SendQuoteController objHandler = new SendQuoteController(sc);
		System.assert(objHandler.initPaymentForEmpPortal()==null);
		Test.stopTest();
    }
    
    static testMethod void testSendQuoteForEmpPortalAccNoEmail(){
    	TestObjects testDataClassObj = new TestObjects();
        Account accObject = new Account();
        accObject.FirstName = 'Test';
        accObject.LastName = 'Test';
        accObject.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        accObject.PersonEmail = '';
        insert accObject;
		
		Pricebook2 brevillePB = new Pricebook2();
		brevillePB.Name = 'Breville';
		brevillePB.IsActive = true;
		insert brevillePB;

		Order orderObj = testDataClassObj.getOrder(accObject.Id, false);
		orderObj.Pricebook2Id = brevillePB.Id;
		orderObj.Status = 'Open';
		//orderObj.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId(); 
		//BillToContact.Email,
		//orderObj.BillToContactId = billingConObj.id;
		//Account.PersonContactId,
		orderObj.IsCalculated__c=true;
		orderObj.Type = 'Employee Sale';
		orderObj.Shipping_Method__c = 'UPS GROUND';
		orderObj.AdvanceShippingStatus__c = null;
	
		Test.startTest();

		insert orderObj;
        PageReference sendQuotePage = Page.WebToCase;
        sendQuotePage.getParameters().put('id',orderObj.Id);
        Test.setCurrentPageReference(sendQuotePage);
		ApexPages.StandardController sc = new ApexPages.standardController(new Order());
		SendQuoteController objHandler = new SendQuoteController(sc);

		System.assert(objHandler.initPaymentForEmpPortal()==null);
		Test.stopTest();
    }
}//End of class