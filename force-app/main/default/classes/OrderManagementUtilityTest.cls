@istest
public class OrderManagementUtilityTest {
    
    @TestSetup
    public static void setup(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        //Create Account
        Account acc = new Account();
        acc.RecordTypeID = recordTypeId;
        acc.FirstName = 'Test';
        acc.LastName = 'Breville Customer';
        acc.Industry = 'Technology';
        acc.Phone = '12345667890';
        acc.BillingCountryCode = 'AU';
        acc.BillingStreet = 'Noida';
        acc.Billing_Street_Line_1__c = '';
        acc.BillingCity = 'Noida';
        acc.BillingStateCode = 'NSW';
        acc.BillingPostalCode = '123456'; 
        acc.CurrencyIsoCode = 'AUD';
        insert acc;
        
        //Create Contact
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.AccountId = acc.PersonContactId;
        insert con;
        
        //Create PriceBook
        Pricebook2 pb2 = new Pricebook2(
            Name = 'Testbook');
        insert pb2;
        
        Pricebook2 pricebookRecord = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Brand__c='Breville',
            Region__c = 'USA',
            Type__c='Sale'
        );
        update pricebookRecord;
        
        //Create Product
        Product2 prod2 = new Product2(
            Name = 'prod1',
            Family = 'Terminal',
            AX_Item_Number__c = 'BFP560SIL');
        insert prod2;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookRecord.Id, Product2Id = prod2.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice1;
        
        
        //insert pricebook entry
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = prod2.id, UnitPrice = 1249.0, IsActive = true);
        Insert standardPrice;
        
        //Create and Insert Asset
        Asset ass = new Asset(
            Name = 'Test Asset',
            Status = 'Installed',
            AccountId = acc.Id,
            InstallDate = System.Today(),
            Product2Id = prod2.Id,
            UsageEndDate = System.Today(),
            PurchaseDate = System.Today(), 
            SerialNumber = '214234523',
            Selected_Offer_Line_Item__c = 'AusMothersDay',
            Offer_Code_Applied__c = 'AusMday2021'
        );
        insert ass;
        
        //Create Offer
        Offer__c offer = new Offer__c(
            MultipleProducts__c = ';BFP560SIL;',
            matchOfferCode__c = true,
            OfferCode__c  = 'AusMday2021',
            CurrencyIsoCode = 'AUD',
            Active__c = true,
            SequentialCounter__c = 1,
            TotalLengthofOfferCode__c = 11,
            PurchaseStartDate__c = system.today(),
            MatchOfferfromNCharacter__c = 1
        );
        insert offer; 
        
        //Create Offer Order
        Offer_Order__c offerOrder = new Offer_Order__c(
            Offer__c = offer.Id,
            ActivateOrderOnNDay__c = 4,
            AX_Order_Account__c = 'Test'
        );
        insert offerOrder;
        
        //Create Offer Order Items
        Offer_Order_Items__c OfferOrderItem = new Offer_Order_Items__c(
            Offer_Order__c = offerOrder.Id,
            PriceBookEntryId__c = standardPrice.Id,
            Quantity__c = 1 
        );
        insert OfferOrderItem;
        
        //Create Order 	
        Order SourceOrder = new Order(
            AccountId = acc.Id,
            Source__c = 'Breville',
            Type = 'Sale',
            Brand__c = 'Test',
            Asset__c = ass.Id,
            AppliedOfferCode__c = '101',
            ExactOfferCode__c = '101',
            PriceBook2Id = pricebookRecord.Id,
            Shipping_Method__c = 'LOCAL',
            AX_Order_Account__c = 'Test',
            OverrideAXAccNum__c = true,
            EffectiveDate = system.today(),
            Status = 'Open'
        );
        insert SourceOrder;
        
        //Create Subscription
        Subscription__c subscript = new Subscription__c(
            Account__c = acc.Id,
            Asset__c = ass.Id,
            Unit_Price__c = 2,
            Gift_Code__c = 'AusMothersDay',
            Product__c = prod2.id,
            Quantity__c= 2,
            Source_order__c = SourceOrder.Id
        );
        insert subscript;
    }
    
    public static testmethod void createOrderRecordTestMethod(){
        
        Test.startTest();
        Account acc = [SELECT FirstName,Name,Industry,Phone,BillingCountryCode,BillingStreet,Billing_Street_Line_1__c,BillingCity,BillingStateCode,ShippingCountryCode,BillingPostalCode FROM Account WHERE FirstName='Test' LIMIT 1];
        Contact con = [SELECT FirstName,LastName,AccountId from Contact where FirstName = 'Test' limit 1];
        Asset asst = [SELECT Id,Where_did_you_purchase__c,Batch_Code__c,Offer_Code_Applied__c,CreatedDate,Name,Status,AccountId,InstallDate,Product2Id,UsageEndDate,PurchaseDate,SerialNumber FROM Asset WHERE Name='Test Asset' LIMIT 1];
        Product2 prod = [select id,AX_Item_Number__c from Product2 where Name = 'prod1' limit 1];
        List<PricebookEntry> pbez = [SELECT ID, Product2Id, Pricebook2.isStandard, Pricebook2.isActive, CurrencyIsoCode, isActive FROM PricebookEntry];
        Offer_Order__c OfferOrder = [select id,Offer__r.OfferCode__c,ActivateOrderOnNDay__c,CurrencyIsoCode,AX_Order_Account__c from Offer_Order__c limit 1];
        Subscription__c currSubscriptionRecord = [select Account__c,Unit_Price__c,Gift_Code__c,Product__c,Quantity__c,Source_order__c,Subscription_Shipping_Address__c,Maximum_iterations__c,Iteration_Count__c,Next_Run_Date__c,Frequency_Duration__c,Frequency_Type__c,Last_Run_Date__c from Subscription__c limit 1]; 
        List<Offer__c> offerRecord = [select MultipleProducts__c,matchOfferCode__c,OfferCode__c,Active__c,SequentialCounter__c,TotalLengthofOfferCode__c from Offer__c];
        Map<Id, List<Offer__c>> assetToOfferMap = new Map<Id, List<Offer__c>>();
        assetToOfferMap.put(asst.Id, offerRecord);
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Id p = [select id from profile where name='Breville External Identity'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p,IsActive =true,
                             ContactId = con.Id,Community_Email_Verified__c = true,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com',
                             Exp_ID__c='brevilleENAU');
        insert user;
        
        // Cover OrderManagementUtility Class
        OrderManagementUtility.createOrderRecord(acc, con.Id, asst, 'test', 'Breville', pbez[0].Id, offerOrder);     
        OrderManagementUtility.createSubscriptionOrder(currSubscriptionRecord.Id);
        
        //Cover OfferRedemptionUtility class
        OfferRedemptionUtility.isOfferCodeValid('BFP560SIL', 'AUD','AusMday2021');
        OfferRedemptionUtility.isOfferCodeValid('BFP560SIL', 'AUD', asst, acc);
        OfferRedemptionUtility.validBatchCodeDateForApplyingOffer(1, 2, 3);
        OfferRedemptionUtility.getOfferForProduct('BFP560SIL', 'AUD');
        OfferRedemptionUtility.getOffersForProduct('BFP560SIL', 'AUD');
        offerRecord[0].matchOfferCode__c = false;
        update offerRecord;
        OfferRedemptionUtility.getOfferForProduct('BFP560SIL', 'AUD',system.today());
        OfferRedemptionUtility.getOfferForProduct('BFP560SIL', 'AUD', asst, acc);
        OfferRedemptionUtility.applicableOffersOnPage(offerRecord, true);
        OfferRedemptionUtility.validPurchaseDateForApplyingOffer(system.today(), system.today(), system.today());
        OfferRedemptionUtility.GenerateOfferCodeFormat(offerRecord[0]);
        OfferRedemptionUtility.createOrderFromOfferOnAsset(assetToOfferMap);
        Test.stopTest();
    }
}