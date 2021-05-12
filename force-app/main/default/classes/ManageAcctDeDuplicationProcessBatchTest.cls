@isTest
global class ManageAcctDeDuplicationProcessBatchTest {

    static void createDuplicatePersonAccounts(Integer recordCount, List<String> emailList, boolean shouldCreateCaseRecords) {
        createDuplicatePersonAccounts(recordCount, emailList, shouldCreateCaseRecords, false, false, false);
    }
    
    static void createDuplicatePersonAccounts(
        Integer recordCount, List<String> emailList, boolean shouldCreateCaseRecords,
        boolean shouldCreateOrders, boolean shouldCreateAssets, boolean shouldCreateWorkOrders) 
    {
        
        Id personAccountRecordTypeId = [select id from RecordType where name='Person Account'].Id;
        List<Account> accountList = new List<Account>();
        Integer counter = 0;
        for (String email: emailList)
        {
            for (Integer i = 0; i < recordCount; i++)
            {
                Account acct = new Account();
                acct.recordTypeId = personAccountRecordTypeId;
                acct.LastName = email.substringBefore('@') + (i + 1);
                acct.PersonEmail = email;
                acct.CurrencyIsoCode='USD';
                accountList.add(acct);
            }
        }
        insert accountList;
        if (shouldCreateAssets || shouldCreateCaseRecords || shouldCreateOrders|| shouldCreateWorkOrders)
        {
            Product2 recProduct = createProduct();
            PricebookEntry pbEntry = [Select Id from PricebookEntry];
            List<Case> caseList;
            
            if (shouldCreateCaseRecords)
                caseList = createCases (accountList);
            
            if (shouldCreateWorkOrders)
                createWorkOrders(accountList, recProduct, caseList); 
            
            if (shouldCreateOrders)
                createOrders(accountList, pbEntry);

            if (shouldCreateAssets)
                createAssets(accountList, recProduct);       
        }
    }
    
    static List<Case> createCases (List<Account> accountList) {
        List<Case> caseList = new List<Case>();
        for (Account acct: accountList)
        {
            Case recCase = new Case();
            recCase.AccountId = acct.Id;
            recCase.Subject = 'Test Case';
            recCase.Description = 'Test Case Description';
            recCase.Origin = 'Web Inquiry';
            caseList.add(recCase);
        }
        insert caseList;
        return caseList;
    }

    static Product2 createProduct () {
        Product2 product = new Product2();
        product.Name = 'TestProd';
        product.IsActive = true;
        product.Description = 'Coffee beans';
        product.AX_Item_Number__c = 'SP0000031';
        product.AX_Unique_ID__c='BUSSP0000031';
        product.SKU__c = 'TestProd';
        product.Serviceable__c = true;
        insert product;

        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.UnitPrice = 10;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = product.Id;
        insert pbEntry;
        return product;
    }
    
    static void createOrders (List<Account> accountList, PricebookEntry pbEntry) {
        
        List<Order> orderList = new List<Order>();
        for (Account acct: accountList)
        {
            Order recOrder = new Order();
            recOrder.AccountId = acct.Id;
            recOrder.EffectiveDate = System.today();
            recOrder.Status = 'Open';
            recOrder.Pricebook2Id = Test.getStandardPricebookId();
            recOrder.ShippingCountryCode = 'US';
            orderList.add(recOrder);
        }
        insert orderList;

        List<OrderItem> orderItemsList = new List<OrderItem> ();
    for (Order recOrder: orderList)
        {
            OrderItem recOrderItem = new OrderItem();
            recOrderItem.OrderId = recOrder.Id;
            recOrderItem.PricebookEntryId = pbEntry.Id;
            recOrderItem.UnitPrice = 10;
            recOrderItem.Quantity = 1;
            orderItemsList.add(recOrderItem);
        }
        insert orderItemsList;   
    }
    
    static void createAssets (List<Account> accountList, Product2 recProduct) {
        List<Asset> assetsList = new List<Asset>();
        for (Account acct: accountList)
        {
            Asset recAsset = new Asset();
            recAsset.Name = acct.LastName;
            recAsset.AccountId = acct.Id;
            recAsset.Product2Id = recProduct.Id;
            assetsList.add(recAsset);
        }
        insert assetsList;
    }

    static void createWorkOrders (List<Account> accountList, Product2 recProduct, List<Case> caseList) {
        Id workOrderRecordTypeId = [select Id from RecordType where name='Work Order'].Id;
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        for (Account acct: accountList)
        {
            Id caseId;
            for (Case recCase : caseList)
            {
                if (recCase.AccountId == acct.Id)
                {
                    caseId = recCase.Id;
                    break;
                }
            }
            WorkOrder recWO = new WorkOrder();
            recWO.AccountId = acct.Id;
            recWO.Pricebook2Id = Test.getStandardPricebookId();
            recWO.Product__c = recProduct.Id;
            recWO.CaseId = caseId;
            recWO.Email__c = acct.PersonEmail;
            workOrderList.add(recWO);
        }
        insert workOrderList;
    }
    
    @isTest
    global static void testWithoutChildren () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(3, emailList, false);
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 1);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }
    
    @isTest
    global static void testWithCases () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(80, emailList, true);
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 1);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }

    @isTest
    global static void testWithOrders () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
    createDuplicatePersonAccounts(3, emailList, false, true, false, false);       
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 1);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }

    @isTest
    global static void testWithWorkOrders () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
    createDuplicatePersonAccounts(3, emailList, true, false, false, true);       
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 1);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }
    
        @isTest
    global static void testforSingleRecord () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(1, emailList, false);
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 1);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }
    
    @isTest
    global static void testSingleRecordWithChildren () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(1, emailList, true);
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 1);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }

    @isTest
    global static void testWithAllTypeChildren () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(2, emailList, true, true, true, true);
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 2);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }
    
    @isTest
    global static void testRecordsWithAndWithOutChildRecords () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(2, emailList, true);
        createDuplicatePersonAccounts(1, emailList, false);
        
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 2);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }
    
    @isTest
    global static void testOneWithChildAndOneWithoutChildren () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        createDuplicatePersonAccounts(1, emailList, true);
        createDuplicatePersonAccounts(1, emailList, false);
        
        // Associate the callout with a mock response
        Test.startTest();
        Merged_Account__c mergeAcctRec = new Merged_Account__c();
        mergeAcctRec.Email__c = email;
        insert mergeAcctRec;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 2);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
//        System.assertEquals(1, accountList.size(), 'Number of Person Accounts do not match');        
    }
    
    
    @isTest
    global static void testWith2differentEmails () {
        String email = 'testDeduplicate@process.com';
        List<String> emailList = new List<String>();
        emailList.add(email);
        emailList.add('testDeduplicate@process.com1');
        emailList.add('testDeduplicate@process.com2');
        createDuplicatePersonAccounts(2, emailList, true);
        
        // Associate the callout with a mock response
        Test.startTest();
        List<Merged_Account__c> mergeAccountRecordList = new List<Merged_Account__c>();
        for (Integer i = 0; i < 3; i++)
        {
            Merged_Account__c mergeAcctRec = new Merged_Account__c();
            if (i == 0)
              mergeAcctRec.Email__c = email;
            else
                mergeAcctRec.Email__c = email + i;
            mergeAccountRecordList.add(mergeAcctRec);
        }
        insert mergeAccountRecordList;
        Id batchId = Database.executeBatch(new ManageAccountDeDuplicationProcessBatch(), 3);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, PersonEmail from Account];
 //       System.assertEquals(3, accountList.size(), 'Number of Person Accounts do not match');        
    }
}