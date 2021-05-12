@isTest public class Ltng_ChargentPaymentTerminal_Test {
    @isTest static void testRestServices() {
        System.runAs(createTestUser()) {
            Test.startTest();
            testGetOrderDetails();
            //testOrganizationUtilMethods();
            testConstructors();
            Test.stopTest();
        }
    }
    @isTest static void testGetOrderDetails() {
        list < Order > orderList = new list < Order > ();

        ShippingAmount__c shippingAmmountRecord1 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND', 75, true, 'Employee Sale', true);
        ShippingAmount__c shippingAmmountRecord2 = TestDataFactory.createShippingAmount('USD', 50, 'UPS GRD', 75, true, 'Sale', true);
        ShippingAmount__c shippingAmmountRecord3 = TestDataFactory.createShippingAmount('USD', 50, 'UPS 2ND', 75, true, 'Sale', true);

        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount Palekar99', true);
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email', 'Open', 'Subject 99', 'USD', true);
        Contact contactRecord = TestDataFactory.createContact(accountRecord.Id, 'NikhilContact99', true);
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Wholesale Pricebook', 
            isActive=true, Region__c='USA', 
            Type__c='Wholesale',Brand__c='Breville'
            
        );
        insert pricebookRecord;

        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999', true, true);



        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Order'
            AND Name = 'Order'
        ];


        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id, 'Open', Date.today(), 1, pricebookRecord.Id, recordTypeRecord.Id, 'Sale',
            '411111111111111', 'Breville', 'USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
        orderRecord1.Shipping_Method__c = 'UPS 2ND';
        orderList.add(orderRecord1);

        insert orderList;

        ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c(Order__c=orderList[0].Id,ChargentOrders__Account__c=accountRecord.Id,
                           CurrencyIsoCode='USD',ChargentOrders__Invoice_Number__c='00205531', ChargentOrders__Tax__c=5, ChargentOrders__Shipping__c=7,
                           ChargentOrders__Charge_Amount__c=-100,ChargentOrders__Subtotal__c=50);
            //insert newChargentOrder;

        Ltng_ChargentPaymentTerminal.getOrderDetails(orderList[0].Id);
        
        Ltng_ChargentPaymentTerminal.createPaymentTerminal(newChargentOrder);

    }
    @isTest static void testConstructors() {
        Ltng_ChargentPaymentTerminal chargentPaymentTerminal = new Ltng_ChargentPaymentTerminal();
        Ltng_ChargentPaymentTerminal.getOrderDetails(null);
        Ltng_ChargentPaymentTerminal.populateChargentOrderFromSFOrder(null, null);
        //Ltng_ChargentPaymentTerminal.populateCurreny(null); 
        Ltng_ChargentPaymentTerminal.populateChargentOrderFromWorkOrder(null, null);
        //Ltng_ChargentPaymentTerminal.mapFieldValues(null,null,null);
        Ltng_ChargentPaymentTerminal.getOrderFieldMappingForOrder();
        Ltng_ChargentPaymentTerminal.getWorkOrderFieldMappingForOrder();
        //Ltng_ChargentPaymentTerminal.getDefaultGetWayId(null);
        //Ltng_ChargentPaymentTerminal.createPaymentTerminal(null);
    }
    private static User createTestUser() {
        Profile profile = [Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Admin';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        return testUser;
    }
}