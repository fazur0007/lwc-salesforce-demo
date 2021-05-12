@isTest public class Ltng_NewOrderCommunity_Test

{
    
            /*@isTest static void testRestServices()
            {
        System.runAs(createTestUser()){
        Test.startTest();
        testMethodNewOrderCtrl();
        Test.stopTest();
        }}*/
    @isTest static void testCreateOrderWithoutAccountRequiredDetails() {
        list<Order> orderList = new list<Order>();
            Pricebook2 pricebookRecord1 = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Sale'
        );
        update pricebookRecord1;
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Finished good Pricebook', isActive=true, Region__c='USA', Type__c='Sale', Brand__c='Breville');
        insert pricebookRecord;
        RecordType businessAccRecType = [SELECT SobjectType,
                                                Id,
                                                DeveloperName
                                        FROM RecordType
                                        WHERE DeveloperName = 'Business_Account'
                                            AND SobjectType ='Account'
                                        LIMIT 1 ];

        Account testAccount1 = new Account();
        testAccount1.recordTypeId = businessAccRecType.Id;
        testAccount1.Name = 'Business Account';
        testAccount1.ShippingStreet= '33 Lincoln Street';
        testAccount1.ShippingCity = 'London';
        testAccount1.ShippingPostalCode = 'E8WH11';
        testAccount1.ShippingCountryCode= 'CA';
        testAccount1.ShippingStateCode ='NT';
        testAccount1.Type = 'Authorized Service Center';
        insert testAccount1;
    
        Contact con = TestDataFactory.createContact(testAccount1.Id, 'Test Last Name', true);

        Profile profile =[Select Id From Profile Where Name = 'Breville Partner User'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Partner User';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.ContactId = con.Id;
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;

        System.runAs(testUser){
            try{
                Ltng_NewOrderCommunity.doInit();
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Script-thrown exception');
            }
        }
    }
    @isTest static void runAsPartnerUser() {
        list<Order> orderList = new list<Order>();
            Pricebook2 pricebookRecord1 = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Sale'
        );
        update pricebookRecord1;
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Finished good Pricebook', isActive=true, Region__c='USA', Type__c='Sale', Brand__c='Breville');
        insert pricebookRecord;
        RecordType businessAccRecType = [SELECT SobjectType,
                                                Id,
                                                DeveloperName
                                        FROM RecordType
                                        WHERE DeveloperName = 'Business_Account'
                                            AND SobjectType ='Account'
                                        LIMIT 1 ];

        Account testAccount1 = new Account();
        testAccount1.recordTypeId = businessAccRecType.Id;
        testAccount1.Name = 'Business Account';
        testAccount1.ShippingStreet= '33 Lincoln Street';
        testAccount1.ShippingCity = 'London';
        testAccount1.ShippingPostalCode = 'E8WH11';
        testAccount1.ShippingCountryCode= 'CA';
        testAccount1.ShippingStateCode ='NT';
        testAccount1.Type = 'Authorized Service Center';
        testAccount1.Business_Email__c = 'test@breville1.com';
        testAccount1.Phone = '1234566';
        insert testAccount1;
  
        Contact con = TestDataFactory.createContact(testAccount1.Id, 'Test Last Name', true);

        Profile profile =[Select Id From Profile Where Name = 'Breville Partner User'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Partner User';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.ContactId = con.Id;
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;

        System.runAs(testUser){
            Ltng_NewOrderCommunity.doInit();
        }
    }
    @isTest static void testMethodNewOrderCtrl()
    {
        list<Order> orderList = new list<Order>();
        Pricebook2 pricebookRecord1 = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Sale'
        );
        update pricebookRecord1;
        Pricebook2 pricebookRecord = new Pricebook2(Name='USA Finished good Pricebook', isActive=true, Region__c='USA', Type__c='Sale', Brand__c='Breville');
        insert pricebookRecord;
        
        Pricebook2 wholeSalePB = new Pricebook2(Name='USA WholeSale good Pricebook', isActive=true, Region__c='USA', Type__c='Sale', Brand__c='Breville');
        insert wholeSalePB;
        // account
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
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
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        accountRecord.phone = '1234567890';
        accountRecord.PersonEmail = 'NikhilAccount@test.com';
        accountRecord.Finished_Good_Pricebook__c = pricebookRecord.Id;
        insert accountRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', true);
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'abc', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Finished_Good__c = true;
        productRecord.SKU__c = 'abc';
        insert productRecord;
        
        PricebookEntry stdPBEntry = new PricebookEntry(Pricebook2Id = pricebookRecord1.Id, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert stdPBEntry;
        
        PricebookEntry fgPBEntry = new PricebookEntry(Pricebook2Id = wholeSalePB.Id, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert fgPBEntry;
        
        PricebookEntry wsPBEntry = new PricebookEntry(Pricebook2Id = pricebookRecord.Id, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        Insert wsPBEntry;
        
        Ltng_NewOrderCommunity.getFinishGoodProducts(accountRecord);
        Ltng_NewOrderCommunity.doSearchFinishedGoodProds(wholeSalePB.Id,'abc','SKU__C');
        
        //insert Service Account
        
        Account ServiceCentreAccount = TestDataFactory.createAccountRecord('Service_Centre DE', 'BDE','servicecentre_usa@example.com','7896541233');
        ServiceCentreAccount.BillingPostalCode = '440022';
        ServiceCentreAccount.ShippingPostalCode = '440022';
               
        insert ServiceCentreAccount;
        
        //Insert Contact
        Contact contactRecord = TestDataFactory.createContact(ServiceCentreAccount.Id, 'palekar998', true);
       
        //promotion creation
        Datetime currentTime = Datetime.now();
        Promotion__c objPromotion = new Promotion__c(isActive__c=true,PromoDispName__c='TestPromoTestClass',Promotion_Name__c='TestPromoTestClass',Start_Date_Time__c=currentTime,End_Date_Time__c=currentTime.AddDays(2));
        insert objPromotion;
        
        Offer_Product__c ObjOfferProduct = new Offer_Product__c(isActive__c=true,Product__c=productRecord.Id,Promotion__c=objPromotion.Id,Promotional_Pricing__c=12);
        insert ObjOfferProduct;
        Id pricebookId = pricebookRecord1.Id;
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productRecord.id, UnitPrice = 1249.0, IsActive = true);
        //Insert standardPrice;
        system.debug('standardPrice:'+standardPrice);
        RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Order' AND Name='Order'];
        //System.debug('Record Id : '+pricebookRecord.Id);
        Order orderRecord1 = TestDataFactory.createOrderRecord(accountRecord.Id,'Open', Date.today(), 1, pricebookRecord1.Id, recordTypeRecord.Id, 'Sale',
                                                               '', 'Breville','USD');
        orderRecord1.OrderSubcategory__c = 'Employee Sale';
        // orderRecord1.Shipping_Method__c = 'UPS 2ND DAY';
        orderRecord1.Country__c='USA';
        orderRecord1.Shipping_Method__c=null;
        //orderRecord1.OrderCustomerType__c = 'B2C';
        orderRecord1.Type = 'Sale';
        // orderRecord1.Shipping_Method__c='UPS 2ND';
        orderList.add(orderRecord1);
        insert orderList;
        PricebookEntry pricebookEntryRecord1 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord1.Id and Product2.SKU__c='abc' limit 1];
        OrderItem orderItemRecord = TestDataFactory.createOrderItemRecord(pricebookEntryRecord1.Id, orderRecord1.Id, 1, 100, true);
        
        Ltng_NewOrderCommunity.doInit();
        
        Ltng_NewOrderCommunity.getBrands('USA');
        Ltng_NewOrderCommunity.getBrands('USD');
        Ltng_NewOrderCommunity.getBrands('CAD');
        Ltng_NewOrderCommunity.getBrands('GBP');
        Ltng_NewOrderCommunity.getBrands('EUR');
        Ltng_NewOrderCommunity.getBrands('AUD');
        
        Ltng_NewOrderCommunity.getOrderTypes();
        Ltng_NewOrderCommunity.getOrderRecordDetails(orderRecord1.Id);
        Ltng_NewOrderCommunity.getStandardPriceBooks(orderRecord1.Id);
       
        
        String jsonString = '[]';
        Ltng_NewOrderCommunity.doSave(orderList[0].Id,jsonString);
        Ltng_NewOrderCommunity.doGetOrderItem(orderList[0].Id);
        Ltng_NewOrderCommunity.save(accountRecord.Id,'Breville','Sale','USD','Account',false,'USA',false,'', accountRecord.Id, 'Carrier Return','','');
        Ltng_NewOrderCommunity.save(caseRecord.Id,'Breville','Sale','USD','Case',false,'USA',false,'', accountRecord.Id, 'Carrier Return','',''); 
        Ltng_NewOrderCommunity.calcPPriceforB2COrder(orderList[0]);
        
        //Insert FG-Product
        Product2 productRecord1 = TestDataFactory.createProduct('Product 1234','PN2','1234', true, false);
        productRecord1.AX_Item_Number__c = 'Test1234';
        productRecord1.SKU__c ='abc';
        productRecord1.AX_Unique_ID__c = 'BUSTest1234';
        productRecord1.Finished_Good__c= True;
        productRecord1.Spare_Part__c = False;
        productRecord1.Accessory__c = False;
        productRecord1.Warranty_In_Months__c= 12;
        productRecord1.CurrencyIsoCode = 'USD';
        productRecord1.Product_Type__c = 'FG';
        productRecord1.MAP__c = 200; 
        productRecord1.Serviceable__c = true;
        productRecord1.Description = 'abc';
        productRecord1.Name = 'PN2';
        productRecord1.Quantity_Available__c = 22;
        productRecord1.Service_Charge__c = 12;
        productRecord1.Available_Date__c = '12/12/2020';
        productRecord1.Substitution_Number__c = '1234';
        productRecord1.Spare_Parts_Use_External__c = true;
        productRecord1.Spare_Parts_Use_Internal__c = false;
        productRecord1.AlternativeProduct__c = productRecord.Id;
        //productRecord1.AlternativeProduct__r.Name = '';
        productRecord1.Available_To_Sell__c = true;
        productRecord1.AX_Reserved_Inventory__c = 123;
        productRecord1.Product_Type__c = 'AC';
        insert productRecord1;
        
        
        //Insert Parts-Products
        List<Product2> partsList = new List<Product2>();
        Product2 part1 = new Product2(Name='BesXL997',AX_Item_Number__c = 'BesXL997', AX_Unique_ID__c = 'BUSBesXL997', Finished_Good__c= False,Spare_Part__c = True,CurrencyIsoCode = 'USD',MAP__c = 10, IsActive = True);
        partsList.add(part1);
        Product2 part2 = new Product2(Name='BesXL998',AX_Item_Number__c = 'BesXL998',AX_Unique_ID__c = 'BUSBesXL998', Finished_Good__c= False,Spare_Part__c = True,CurrencyIsoCode = 'USD',MAP__c = 20, IsActive = True);
        partsList.add(part2);  
        Product2 part3 = new Product2(Name='BesXL999',AX_Item_Number__c = 'BesXL999',AX_Unique_ID__c= 'BUSBesXL999', Finished_Good__c= False,Spare_Part__c = True,CurrencyIsoCode = 'USD',MAP__c = 30, IsActive = True);
        partsList.add(part3);  
        insert partsList;
        
        //Insert BOM records
        List<BillOfMaterial__c> bomList = new List<BillOfMaterial__c>();
        BillOfMaterial__c objBom1 = new BillOfMaterial__c(Parts__c = part1.Id, PrimaryProduct__c = productRecord1.Id, UniqueId__c = productRecord1.AX_Unique_ID__c + part1.AX_Unique_ID__c, isActive__c = true);
        bomList.add(objBom1);
        BillOfMaterial__c objBom2 = new BillOfMaterial__c(Parts__c = part2.Id, PrimaryProduct__c = productRecord1.Id, UniqueId__c = productRecord1.AX_Unique_ID__c + part2.AX_Unique_ID__c, isActive__c = true);
        bomList.add(objBom2);        
        insert bomList;
        
        List<Id> bomListId = new List<Id>();
        bomListId.add(objBom1.Id);
        bomListId.add(objBom2.Id);
        
        Ltng_NewOrderCommunity.getPriceBookEntryList(orderList,bomListId);
        Ltng_NewOrderCommunity.getPriceBooks(orderItemRecord.OrderId,bomListId);
        Ltng_NewOrderCommunity.doSearch(orderList[0].Id,'PN1','Name',bomListId,true);
        Ltng_NewOrderCommunity.doSearch(orderList[0].Id,'PN1','Name',bomListId,false);
        try{
            Ltng_NewOrderCommunity.createOrderAccount(ServiceCentreAccount, 'Sale', 'Breville', true, 'USA', false, '', '','123');
        }catch(Exception e) {
            System.assertEquals(e.getMessage(), 'Script-thrown exception');
        }
        
        
        //standard Pricebook
        Id standardPricebookId = Test.getStandardPricebookId();
        system.debug('STANDARD PRICEBOOK ID IS '+standardPricebookId);
        
        //pricebook
        
        system.debug(' PRICEBOOK ID IS '+pricebookRecord.Id);
        Pricebook2 pricebookRecord3 = [select id from Pricebook2 where Brand__c='Breville' AND Type__c='Sale' AND Region__c='USA' limit 1];
        Pricebook2 standardPricebook = [SELECT Id from Pricebook2 WHERE IsStandard=true LIMIT 1];
        PricebookEntry pricebookEntryRecord2 = new PricebookEntry();
        pricebookEntryRecord2.Product2Id = productRecord1.Id;
        pricebookEntryRecord2.Pricebook2Id = standardPricebook.Id;
        pricebookEntryRecord2.ServiceCharge__c = 10;
        pricebookEntryRecord2.FreightCharge__c = 10;
        pricebookEntryRecord2.InspectionCharge__c = 10;
        pricebookEntryRecord2.Refurb_Fee__c = 10;
        pricebookEntryRecord2.InspectionCharge__c = 10;
        pricebookEntryRecord2.LaborCharge__c = 10;
        pricebookEntryRecord2.Tier2InspectionCharge__c = 10;
        pricebookEntryRecord2.Tier2LaborCharge__c = 10;
        pricebookEntryRecord2.Tier3LaborCharge__c = 10;
        pricebookEntryRecord2.Tier4LaborCharge__c = 10;
        pricebookEntryRecord2.UnitPrice = 10;
        pricebookEntryRecord2.IsActive = true;
        pricebookEntryRecord2.CurrencyIsoCode = 'USD';
        insert pricebookEntryRecord2;
        
        //Insert standardPrice1;
        
        //PricebookEntry pricebookEntryRecord2 =  [select id from PricebookEntry where Pricebook2Id=:pricebookRecord1.Id and Product2.SKU__c='PN2' limit 1];
    
        
    }

    
    
    private static User createTestUser(){
        Profile profile =[Select Id From Profile Where Name = 'System Administrator'];
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