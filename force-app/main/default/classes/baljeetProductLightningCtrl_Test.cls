@isTest
public class baljeetProductLightningCtrl_Test {
    @testSetup 
    
    static void setup(){
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
        //Create Opportuninty
        /*Opportunity testOpportunity = new Opportunity(
            StageName = 'Sourcing Demand',
            CloseDate = Date.newInstance(2025,12,31),
            AccountId = acc.Id,
            Name = 'Test Opportunity Triggers',
            Pricebook2Id=pb2.id
        );
        insert testOpportunity;*/
        
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
       //     ExactOfferCode__c = 'AusMothersDay',
            Selected_Offer_Line_Item__c = 'AusMothersDay'
        );
        insert ass;
        //Create Offer
        Offer__c offer = new Offer__c(
            MultipleProducts__c = ';BFP560SIL;',
            matchOfferCode__c = false,
            OfferCode__c  = 'AusMday2021',
            CurrencyIsoCode = 'AUD',
            Active__c = true,
            SequentialCounter__c = 1,
            TotalLengthofOfferCode__c = 1
        );
        insert offer; 
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
    @isTest 
    static void testMethod1(){
        
        Account acc = [SELECT FirstName,Industry,Phone,BillingCountryCode,BillingStreet,Billing_Street_Line_1__c,BillingCity,BillingStateCode,BillingPostalCode FROM Account WHERE FirstName='Test' LIMIT 1];
        Contact con = [SELECT FirstName,LastName,AccountId from Contact where FirstName = 'Test' limit 1];
        Asset asst = [SELECT Id,Where_did_you_purchase__c,Batch_Code__c,Name,Status,AccountId,InstallDate,Product2Id,UsageEndDate,PurchaseDate,SerialNumber FROM Asset WHERE Name='Test Asset' LIMIT 1];
        Product2 prod = [select id,AX_Item_Number__c from Product2 where Name = 'prod1' limit 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      //  System.assertEquals(documents.size(), 1);
        string prodStr = prod.Id;
        string contentDoc = documents[0].Id;
        String assetString = JSON.serialize(asst);
        String acctString = JSON.serialize(acc);
        ContentDocumentLink cdl = [Select id FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id and ContentDocumentId = : documents[0].Id LIMIT 1];
        ProductRegistrationLightningController.cloneAndInsertContentDocumentLinkRecord(String.valueof(acc.Id),String.valueof(documents[0].Id));
        
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Id p = [select id from profile where name='Breville External Identity'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p,IsActive =true,
                             ContactId = con.Id,Community_Email_Verified__c = true,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com',
                             Exp_ID__c='brevilleENAU');
        
        insert user;
           
        
        system.runAs(user) {
            ProductRegistrationLightningController.getProductRegistrationSummaryDetails(acc.Id, asst.Id);
            ProductRegistrationLightningController.getCurrentUser();
            ProductRegistrationLightningController.getOffers('AusMday2022');
            ProductRegistrationLightningController.getProductSummaryDetails(assetString);
            ProductRegistrationLightningController.getCountryFieldValue('AusMday2022');
            ProductRegistrationLightningController.getStateFieldValue();
            ProductRegistrationLightningController.getStates('Australia', 'Account', 'BillingCountryCode', 'BillingStateCode');
            ProductRegistrationLightningController.getProductRelateToSubProduct('Cookers');
            ProductRegistrationLightningController.getDependentMap(new Case(),'Country__c', 'Purchased_From__c');
            ProductRegistrationLightningController.deleteAttachment(contentDoc);
            ProductRegistrationLightningController.getGiftProducts(asst, prodStr,'AusMday2022');
            ProductRegistrationLightningController.submitClaim(acctString, assetString, contentDoc,'AusMday2022');

            ProductRegistrationLightningController.fetchAccountId();
            ProductRegistrationLightningController.getStatesWithStateCodes('Australia','Account','BillingCountryCode', 'BillingStateCode');
            ProductRegistrationLightningController.ItemWrapper wrap= new ProductRegistrationLightningController.ItemWrapper();
            wrap.value ='Test';
            wrap.label ='Test';
            wrap.disabled = false;
            ProductRegistrationLightningController.ProductWrapper prodwrap= new ProductRegistrationLightningController.ProductWrapper();
            prodwrap.value ='Test';
            prodwrap.label ='Test';
            prodwrap.disabled = false;
            
            ProductRegistrationLightningController.PicklistEntryWrapper pickListwrap= new ProductRegistrationLightningController.PicklistEntryWrapper();
            pickListwrap.active ='Test';
            pickListwrap.defaultValue ='Test';
            pickListwrap.value = 'false';
            try{ProductRegistrationLightningController.deleteAttachment(acc.Id);}
            catch(exception ex){}
            try{
            ProductRegistrationLightningController.submitClaim(JSON.serialize(new Account()), assetString, contentDoc,'AusMday2022');
            }catch(exception ex){}
            
           
        }
        try{
            ProductRegistrationLightningController.submitClaim(acctString, assetString, contentDoc,'AusMday2022');
        }catch(exception ex){}
        
    }
    
    
    
    @isTest 
    public static void OfferredemptionutilityisOfferCodeValid(){
        Account acc = [SELECT FirstName,Industry,Phone,BillingCountryCode,BillingStreet,Billing_Street_Line_1__c,BillingCity,BillingStateCode,BillingPostalCode,CurrencyIsoCode FROM Account WHERE FirstName='Test' LIMIT 1];
        Contact con = [SELECT FirstName,LastName,AccountId from Contact where FirstName = 'Test' limit 1];
        Asset asst = [SELECT Id,Where_did_you_purchase__c,Batch_Code__c,Name,Status,AccountId,InstallDate,Product2Id,UsageEndDate,PurchaseDate,SerialNumber FROM Asset WHERE Name='Test Asset' LIMIT 1];
        Product2 prod = [select id,AX_Item_Number__c from Product2 where Name = 'prod1' limit 1];
        Pricebook2 pb = [select id from Pricebook2 where name='Testbook' limit 1];
        PricebookEntry pbe= [select id from PricebookEntry where Product2Id = :prod.id and Pricebook2Id = :pb.Id limit 1];
        Date todayDate = System.Date.today();
         Offer__c offer = new Offer__c(
            MultipleProducts__c = ';BFP560SIL;',
            matchOfferCode__c = false,             
            OfferCode__c  = 'AusMday2022',
            CurrencyIsoCode = 'AUD',
            Active__c = true,
            SequentialCounter__c = 1,
            TotalLengthofOfferCode__c = 1,
             PurchaseStartDate__c =todayDate,
             PurchaseEndDate__c = todayDate.addDays(20)
        );
        insert offer;
        
        Offer_order__c offerOrder = new Offer_order__c(
            Offer__c= offer.Id,
            PriceBook__c= pb.Id
        );
        
        insert offerOrder;
        
        Offer_Order_Items__c objLineItem = new Offer_Order_Items__c(
            Offer_Order__c = offerOrder.Id,
            Quantity__c = 1,
            Product__c= prod.Id,
            PriceBook__c= pb.Id,
            PriceBookEntryId__c= pbe.Id,
            Subscription_Frequency__c = 'Day',
            Subscription_frequency_Duration__c = 2
        );        
        insert objLineItem;
        Map<Id, List<Offer__c>> mapInput = new Map<Id, List<Offer__c>>();   
        List<Offer__c> lstOffer = new List<Offer__c>();
        lstOffer.Add(offer);
        mapInput.put(asst.Id,lstOffer);
        
        asst.Selected_Offer_Line_Item__c = objLineItem.Id;
        update asst;
            
        OfferRedemptionUtility.isOfferCodeValid(prod.AX_Item_Number__c, acc.CurrencyIsoCode, 'AusMday2022');
        OfferRedemptionUtility.getOfferForProduct(prod.AX_Item_Number__c, acc.CurrencyIsoCode);
        OfferRedemptionUtility.validBatchCodeDateForApplyingOffer(2,4,3);
        OfferRedemptionUtility.createOrderFromOfferOnAsset(mapInput);
        OfferRedemptionUtility.isOfferCodeValid(prod.AX_Item_Number__c, acc.CurrencyIsoCode,asst,acc);
        OfferRedemptionUtility.getOfferForProduct(prod.AX_Item_Number__c, acc.CurrencyIsoCode,System.Date.today());
        OfferRedemptionUtility.getOfferForProduct(prod.AX_Item_Number__c, acc.CurrencyIsoCode,asst,acc);
        
        OfferRedemptionUtility.validPurchaseDateForApplyingOffer(System.Date.today(),todayDate.addDays(5),todayDate.addDays(3));
        OfferRedemptionUtility.applicableOffersOnPage(lstOffer,false);
    }
    
}