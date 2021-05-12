/*
TestDataFactory is a utility class to be used in test class name 'ProductHandlerTest'
* Version       Author             Date                  Description 
*  1.0        Yogesh Sharma      05/24/2016             Initial Draft
*/

//@isTest
public with sharing class TestDataFactory {
    //create product records
     //create product records
    public static list<Product2> createProductList(String ProdName, integer intCount,
                                                Boolean AvailableSell) {
                                                
    list<Product2> lstProduct = new list<Product2>();
        for(Integer i=0;i<intCount;i++) {
            Product2 objProd = new Product2(Name= ProdName+''+i,
                                            Available_To_Sell__c=AvailableSell,
                                            AX_Item_Number__c='abcd1234');
            lstProduct.add(objProd);
        }// end for
        return lstProduct;
    }// end method
    
     // create Opportunityline item record
    public static list<OpportunityLineItem> createOLItem(Id PriceBookId, Id OppId, 
                                                    Integer Qty, decimal unitPr,integer intCount){
        list <OpportunityLineItem> listOIInsert= new list<OpportunityLineItem>();
            for(integer i=0;i<intCount;i++){
                OpportunityLineItem objOI = new OpportunityLineItem(PriceBookEntryId =PriceBookId, OpportunityId=OppId,
                                                 Quantity= Qty, UnitPrice= unitPr);
                listOIInsert.add(objOI);
            }
        return listOIInsert;                    
    }// end method
    
    public static list<Product2> createProductList(String ProdName, integer intCount, String axItemNumber,
                                                Boolean AvailableSell) {
                                                
    list<Product2> lstProduct = new list<Product2>();
        for(Integer i=0;i<intCount;i++) {
            Product2 objProd = new Product2(Name= ProdName+''+i,
                                            Available_To_Sell__c=AvailableSell,AX_Item_Number__c=axItemNumber);
            lstProduct.add(objProd);
        }// end for
        return lstProduct;
    }// end method

    //create order records
   public static list<Order> createOrder(Id AccId, String StrStatus, 
                                    Date EffectiveDateDt, Id ContId,integer intCount){
        list <Order> listOrderInsert= new list<Order>(); 
        for(integer i=0;i<intCount;i++){
            Order objOrder = new Order(AccountId =AccId, Status= StrStatus, 
                                            EffectiveDate= EffectiveDateDt,ContractId= ContId);
            listOrderInsert.add(objOrder);
        }//end for
        return listOrderInsert; 
    }// end method

    // create OrderItem record
    public static list<OrderItem> createOrderItem(Id PriceBookId, Id OrderId, 
                                                    Integer Qty, decimal unitPr,integer intCount){
        list <OrderItem> listOIInsert= new list<OrderItem>();
            for(integer i=0;i<intCount;i++){
                OrderItem objOI = new OrderItem(PriceBookEntryId =PriceBookId, OrderId=OrderId,
                                                 Quantity= Qty, UnitPrice= unitPr);
                listOIInsert.add(objOI);
            }
        return listOIInsert;                    
    }// end method
    
    // create OrderItem record
    public static OrderItem createOrderItemRecord(Id PriceBookId, Id OrderId, 
                                                    Integer Qty,decimal unitPr, Boolean insertRecord){
                OrderItem objOI = new OrderItem(PriceBookEntryId =PriceBookId, OrderId=OrderId,Quantity= Qty,UnitPrice =unitPr );
        if(insertRecord){
            insert objOI;
        }
        return objOI;                 
    }// end method
    
    // create OrderItem record
    public static WorkOrderLineItem createWorkOrderLineItemRecord(Id PriceBookId, Id OrderId, 
                                                    Integer Qty,decimal unitPr, Boolean insertRecord){
                WorkOrderLineItem workOrderLineItemObj = new WorkOrderLineItem(PriceBookEntryId =PriceBookId, WorkOrderId=OrderId,Quantity= Qty,UnitPrice =unitPr );
        if(insertRecord){
            insert workOrderLineItemObj;
        }
        return workOrderLineItemObj;                 
    }// end method

    // create Accounts 
    public static list<Account> createAccount(String strName,integer intCount){
        list <Account> listAccInsert= new list<Account>();
        for(integer i=0;i<intCount;i++){
            Account objAcc = new Account(Name = strName+i);
            listAccInsert.add(objAcc);
        }
        return listAccInsert;
    } // end method
    
    // create Account record
    public static Account createAccountRecord(String strName, Boolean insertRecord){
        Account objAcc = new Account(Name = strName);
        if(insertRecord){
            insert objAcc;
        }
        return objAcc;
    } // end method
    
    // create Account record
    public static Account createAccountRecord(String firstname,String lastname, Boolean insertRecord){
        Account objAcc = new Account(firstName = firstname, lastName = lastname);
        if(insertRecord){
            insert objAcc;
        }
        return objAcc;
    } // end method
    
     // create Account record with currency and billing city
    public static Account createAccountRecord(String strName,String currencyIsocode,String billingcity, Boolean insertRecord){
        Account objAcc = new Account(Name = strName, CurrencyIsoCode=currencyIsocode,BillingCity=billingcity );
        if(insertRecord){
            insert objAcc;
        }
        return objAcc;
    } // end method


    //Create Contract record
    public static list<Contract> createContract(Id AccId,integer intCount, Date StartDate,
                                                Integer ContractTerm, String strStatus){
        list <Contract> listContractInsert= new list<Contract>();
        for(integer i=0;i<intCount;i++){
            Contract objContract = new Contract(AccountId = AccId, StartDate= StartDate,
                                                ContractTerm= ContractTerm, Status= strStatus);
            listContractInsert.add(objContract);
        }
        return listContractInsert;
    } // end method
    
    
    //Create User record
    public static User createUser(String profileName, String roleName, String curerncyISOCode, Boolean insertRecord){
        
        Profile profile = [SELECT Id, Name FROM Profile where Name =: profileName LIMIT 1];
        UserRole userRole = [SELECT Id, Name FROM UserRole where Name =: roleName LIMIT 1];
        User userRecord = new User();
        userRecord.UserName = 'TestUser' + String.valueOf(Datetime.now().getTime()) + '_' + UserInfo.getOrganizationId() + '@breville.com.test';
        userRecord.profileId = profile.Id;
        userRecord.Alias = 'a';
        userRecord.CommunityNickname = 'b';
        userRecord.Email = 'c@example.com';
        userRecord.CurrencyIsoCode = curerncyISOCode;
        userRecord.LastName = 'test';
        userRecord.TimeZoneSidKey = 'GMT';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.EmailEncodingKey = 'ISO-8859-1';
        userRecord.LanguageLocaleKey = 'en_US';
        //userRecord.UserRole
        
        if(insertRecord){
            insert userRecord;
        }
       	
        return userRecord;
    } //method end
    
    public static WorkOrder createWorkOrder(String postalCode, String currencyCode, Boolean insertRecord){
        WorkOrder workOrder = new WorkOrder();
        workOrder.PostalCode = postalCode;
        workOrder.currencyISOCode = currencyCode;
        if(insertRecord){
            insert workOrder;
        }
        return workOrder;
    } 
    
     //create product record
    public static Product2 createProduct(String ProdName,Boolean AvailableSell, Boolean insertRecord ) {
                                                
            Product2 objProd = new Product2(Name= ProdName,Available_To_Sell__c=AvailableSell);
            if(insertRecord){
            	insert objProd;
        }
        return objProd;
    }// end method
    
    //create Case record
    public static Case createCase(String status,String currencyIsoCode, String qcAlertId ,String accId,  Boolean insertRecord ) {
                                                
            Case caseObj = new Case(Status=status,CurrencyIsoCode=currencyIsoCode,QC_Alert__c=qcAlertId,accountId=accId);
            if(insertRecord){
            insert caseObj;
        }
        return caseObj;
    }// end method
    
    //create Asset record
    public static Asset createAsset(String name,Date purchasedate,String batchCode,Id productid ,Id acctId,Integer warranty, Boolean insertRecord ) {
                                                
            Asset assetobj = new Asset(Name=name,PurchaseDate=purchasedate,Batch_Code__c=batchCode,AccountId = acctId, Product2Id = productid, Warranty_In_Months__c = warranty);
            if(insertRecord){
            insert assetobj;
        }
        return assetobj;
    }// end method
    
    
    
    //create Attachment record
    public static Attachment createAtachment(String attachmentName,Blob attachmentBody,String parentId, Boolean insertRecord ) {
        
            Attachment objAttach = new Attachment(Name=attachmentName,Body=attachmentBody,ParentId=parentId);
            if(insertRecord){
            insert objAttach;
        }
        return objAttach;
    }// end method
    
    //create QC Alert record
    public static QCAlert__c createQCAlert(String alertDetails,String review, Boolean insertRecord ) {
                                                
            QCAlert__c  qcAlertObj = new QCAlert__c (QCAlertDetails__c=alertDetails,ExpectedReview__c=review);
            if(insertRecord){
            insert qcAlertObj;
        }
        return qcAlertObj;
    }// end method
    
      //create QC Alert record with complaint code parameters
    public static QCAlert__c createQCAlert(String alertDetails,String review,String currencyIsoCode,Id Product,String complaintCode,String channel, Boolean insertRecord ) {
                                                
            QCAlert__c  qcAlertObj = new QCAlert__c (QCAlertDetails__c=alertDetails,ExpectedReview__c=review, Product__c=Product, CurrencyIsoCode=currencyIsoCode, Complaint_Code__c=complaintCode,	Channel__c=channel);
            if(insertRecord){
            insert qcAlertObj;
        }
        return qcAlertObj;
    }// end method
    
    //create QC Location record
    public static QCLocation__c createQCLocation(String accountId,String region,Id Product,String qcAlertId, Boolean insertRecord ) {
                                                
            QCLocation__c  qcLocationtObj = new QCLocation__c (ReturnLocation__c=accountId,Region__c=region,QCAlert__c=qcAlertId,Product__c=Product);
            if(insertRecord){
            insert qcLocationtObj;
        }
        return qcLocationtObj;
    }// end method
    
     //create QC Location record with product parameters
    public static QCLocation__c createQCLocation(String accountId,String region,String qcAlertId,Id productId, Boolean active,String returnLocation,String batchCode, Boolean insertRecord ) {
                                                
            QCLocation__c  qcLocationtObj = new QCLocation__c (ReturnLocation__c=accountId,Region__c=region,QCAlert__c=qcAlertId);
            qcLocationtObj.StartDate__c = Date.today();
            qcLocationtObj.Product__c = productId;
            qcLocationtObj.QCAlert__c = qcAlertId;
            qcLocationtObj.Batch_Code_From__c = batchCode;
            qcLocationtObj.Batch_Code_To__c = batchCode;
            qcLocationtObj.IsActive__c = active;
            if(insertRecord){ 
            		insert qcLocationtObj;
        }
        return qcLocationtObj;
    }// end method
    
     public static Knowledge_Base__c createknowledgeBase(String title, String description,String region,String productId, String docType,String bucket , String etag ,  String fileKey ,Boolean insertRecord){
        Knowledge_Base__c knowledgeBase = new Knowledge_Base__c();
        knowledgeBase.Title__c = title;
        knowledgeBase.Description__c = description;
        knowledgeBase.Region__c = region;
        knowledgeBase.Product__c = productId;
        knowledgeBase.DocType__c=  docType;
        knowledgeBase.Bucket__c =  bucket;
        knowledgeBase.ETag__c =  etag;
        knowledgeBase.FileKey__c =  fileKey;
        if(insertRecord){
            insert knowledgeBase;
        }
        
        return knowledgeBase;
    } 
    
    //Create Case
    public static Case createCase(Id accountId, String origin, String Status, String Subject, String currencyISOCode, Boolean insertRecord){
    	Case caseRecord = new Case(Origin=origin, Subject=subject,Status=status, AccountId=accountId, CurrencyISOCode=currencyISOCode);
    	if(insertRecord)
    		insert caseRecord;
    	return caseRecord;
    }
    //Create case with complaint code parameters
     public static Case createCase(Id accountId, String origin, String Status, String Subject, String currencyISOCode,Id Product, String caseType, String complaintCode, String Batchcode, Boolean insertRecord){
    	Case caseRecord = new Case(Origin=origin, Subject=subject,Status=status, AccountId=accountId, CurrencyISOCode=currencyISOCode, Type=caseType,Product__c = Product, Complaint_Code__c = complaintCode,Batch_Code__c=Batchcode);
    	if(insertRecord)
    		insert caseRecord;
    	return caseRecord;
    }
    
    //Create case with purchase date and warranty parameters
     public static Case createCase(Id accountId, String origin, String Status, String Subject, String currencyISOCode,Id Product, String caseType, String complaintCode, String Batchcode, Date purchaseDate, String warrantystatus, Boolean insertRecord){
    	Case caseRecord = new Case(Origin=origin, Subject=subject,Status=status, AccountId=accountId, CurrencyISOCode=currencyISOCode, Type=caseType,Product__c = Product, Complaint_Code__c = complaintCode,Batch_Code__c=Batchcode,Warranty__c = warrantystatus ,Purchase_Date__c=purchaseDate);
    	if(insertRecord)
    		insert caseRecord;
    	return caseRecord;
    }
    
    //create Contact
    public static Contact createContact(Id accountId, String lastNname, Boolean insertRecord){
    	Contact contactRecord = new Contact(AccountId=accountId, LastName=lastNname);
    	if(insertRecord)
    		insert contactRecord;
    	return contactRecord;
    }
    
    //create B2B account
    public static Contact createContact(Id accountId, String lastNname, String phonenumber, Boolean insertRecord){
    	Contact contactRecord = new Contact(AccountId=accountId, Phone=phonenumber, LastName=lastNname);
    	if(insertRecord)
    		insert contactRecord;
    	return contactRecord;
    }
    
    //create Product
    public static Product2 createProduct(String name, String SKU, String axItemNumber, Boolean AvailableSell, Boolean insertRecord){
    	Product2 productRecord = new Product2(Name=name, SKU__c=SKU, AX_Item_Number__c=axItemNumber, Available_To_Sell__c=AvailableSell);
    	if(insertRecord)
    		insert productRecord;
    	return productRecord;
    }
    
    //create Product with other parameters
    public static Product2 createProduct(String name, String SKU,  Boolean finishedGood, Boolean Remanufactured, Boolean Sparepart, Integer warranty,Boolean joeProduct, Boolean insertRecord){
    	Product2 productRecord = new Product2(Name=name, SKU__c=SKU, Finished_Good__c=finishedGood, Remanufactured__c = Remanufactured, Spare_Part__c=Sparepart,Warranty_In_Months__c=warranty,Joe_Product__c=joeProduct);
    	if(insertRecord)
    		insert productRecord;
    	return productRecord;
    }
    
    //create Order 
    
    public static Order createOrderRecord(Id AccId, String StrStatus, 
                                    Date EffectiveDateDt,integer intCount, Id pricebookId, Id recordTypeRecord, String orderType,
                                    String CCAuthorizationID, String source, String currencyISOCode){
        Order orderRecord = new Order(AccountId =AccId, Status= StrStatus, 
                                            EffectiveDate= EffectiveDateDt, Pricebook2Id=pricebookId, RecordTypeId=recordTypeRecord, type=orderType,
                                            CC_Authorization_ID__c=CCAuthorizationID, Source__c=source, CurrencyISOCode=currencyISOCode, AX_Order_Account__c = '', Sent_to_AX__c = null, Channel__c = 'ECOMM');
        return orderRecord; 
    }
    
    //create Order with dynamic field updates
     public static Order createOrderRecordDynamic(Id AccId, String StrStatus, 
                                    Date EffectiveDateDt,integer intCount, Id pricebookId, Id recordTypeRecord, String orderType,
                                    String CCAuthorizationID, String source, String currencyISOCode, String axOrderAccount, Date sentToAX, String channel){
        Order orderRecord = new Order(AccountId =AccId, Status= StrStatus, 
                                            EffectiveDate= EffectiveDateDt, Pricebook2Id=pricebookId, RecordTypeId=recordTypeRecord, type=orderType,
                                            CC_Authorization_ID__c=CCAuthorizationID, Source__c=source, CurrencyISOCode=currencyISOCode, AX_Order_Account__c = axOrderAccount, Sent_to_AX__c = sentToAX, Channel__c = channel);
        return orderRecord; 
    }
    
     
    
    //create Shipping Amount
    public static ShippingAmount__c createShippingAmount(String currencyISOCode, Double shippingAmmount, String shippingMethod, Double maxAmount, boolean shippingChargeApplicable, String orderType, boolean insertRecord){
    	ShippingAmount__c shippingAmountRecord = new ShippingAmount__c(CurrencyIsoCode=currencyISOCode, ShippingAmount__c=shippingAmmount, Shipping_Method__c=shippingMethod, MaxAmount__c=maxAmount, ShippingChargeAlwaysApplicable__c=shippingChargeApplicable, OrderType__c=orderType );
    	if(insertRecord)
    		insert shippingAmountRecord;
    	return shippingAmountRecord;
    }
    
    //create Acoount Record
    public static Account createAccountRecord(String name, String dataAreaId, String businessEmail, String phone){
    	Account accountRecord = new Account(Name=name, DataAreaID__c=dataAreaId, Business_Email__c=businessEmail, Phone=phone);
    	return accountRecord;
    }
    
    //create Work Order record
    public static WorkOrder createWorkOrderRecord(Id caseId, Id accountId, String currencyCode, Id pricebookId, Id serviceCentreId, String email, String postalCode){
        WorkOrder workOrderRecord = new WorkOrder(CaseId=caseId, AccountId=accountId,CurrencyIsoCode=currencyCode,Pricebook2Id =pricebookId,ServiceCentre__c=serviceCentreId,Email__c=email, PostalCode=postalCode); 
        return workOrderRecord;
    } 
    
    //create pricebook entry record
    public static PricebookEntry cretaePricebookEntryRecord(Id Pricebook, Id productId, String CurrencyIsoCode, Decimal ServiceCharge, Decimal FreightCharge, Decimal InspectionCharge, Decimal LaborCharge, Decimal UnitPrice){
    	PricebookEntry record = new PricebookEntry(Pricebook2Id = Pricebook, Product2Id =  productId, CurrencyIsoCode = CurrencyIsoCode, ServiceCharge__c = ServiceCharge, FreightCharge__c = FreightCharge, InspectionCharge__c = InspectionCharge, LaborCharge__c = LaborCharge, UnitPrice = UnitPrice);
    	return record;
    }
    
    //create workorder line item record
    public static WorkOrderLineItem createWorkOrderLineItemRecord(Id PriceBookId, Id OrderId, 
                                                    Integer Qty,decimal unitPr, String itemType, Boolean insertRecord){
                WorkOrderLineItem workOrderLineItemObj = new WorkOrderLineItem(PriceBookEntryId =PriceBookId, WorkOrderId=OrderId,Quantity= Qty,UnitPrice =unitPr, Type__c = itemType );
        if(insertRecord){
            insert workOrderLineItemObj;
        }
        return workOrderLineItemObj;                 
    }
    
    //create Troubleshoot flow mapping record
    public static Trouble_Shoot_Flow_Mapping__c createTroubleshootFlowMappingRecord( Id productId, String category, String subCategory, String flowName, String complaintCode){
    	Trouble_Shoot_Flow_Mapping__c record = new Trouble_Shoot_Flow_Mapping__c(Product__c = productId, Product_Category__c = category, Product_Sub_Category__c = subCategory, Flow_Name__c = flowName, Complaint_Code__c = complaintCode);
    	return record;
    }
    
    //create Receiving record
    public static Receiving__c createReceivingRecord(Id caseId){
    	Receiving__c record = new Receiving__c(Case__c = caseId);
    	return record;
    }
    
    //create tax rate Record
    public static Tax_Rate__c createTaxRateRecord(String Name, String CurrencyCode, Decimal combinedSalesTax, Decimal combinedServiceTax, boolean insertRecord){
    	Tax_Rate__c record = new tax_rate__c(Name=name, CurrencyIsoCode=CurrencyCode, Combined_Rate__c=combinedSalesTax, CombinedUseTaxRate__c=combinedServiceTax);
    	if(insertRecord)
    		insert record;
    	return record;	
    }
    
    
    
    //Create PriceAPI__c custom settings
    public static List<PriceAPI__c> createPriceAPICustomSettings()
    {
    	List<PriceAPI__c>  allSettings = new List<PriceAPI__c>();
    	PriceAPI__c settings = new PriceAPI__c();
    	settings.Name = 'ContentType';
    	settings.Value__c =  'application/soap+xml';
		allSettings.add(settings);
		
		settings = new PriceAPI__c();
    	settings.Name = 'method';
    	settings.Value__c =  'POST';
		allSettings.add(settings);
		
		settings = new PriceAPI__c();
    	settings.Name = 'Password';
    	settings.Value__c =  'Breville@123';
		allSettings.add(settings);
		
		settings = new PriceAPI__c();
    	settings.Name = 'RequestURL';
    	settings.Value__c =  'https://brevilleustrial112205.jitterbit.net/BrevilleGlobalPOCLocal/SalesPriceLookupBulk';
		allSettings.add(settings);
		
		settings = new PriceAPI__c();
    	settings.Name = 'Username';
    	settings.Value__c =  'sfadmin';
		allSettings.add(settings);
		
		settings = new PriceAPI__c();
    	settings.Name = 'PriceCalculationMaxAttempts';
    	settings.Value__c =  '3';
		allSettings.add(settings);
		
		insert allSettings;
		
		return allSettings;
    }
    
    /*
    //Create myBrevilleSettings__c custom settings
    public static List<myBrevilleSettings__c> createMyBrevilleCustomSettings()
    {
    	List<myBrevilleSettings__c>  allSettings = new List<myBrevilleSettings__c>();
    	myBrevilleSettings__c settings = new myBrevilleSettings__c();
    	settings.Name = 'ClientId';
    	settings.Value__c =  '3MVG9Vik22TUgUpism4E5ptB5QqMALUAW1FKNL1tp7ybndy3sOc.sIok31x5rJ843Ak.kgqIestKr1sfRY22n';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = '	redirectURI';
    	settings.Value__c =  'http://psldevint-brevilleusa.cs19.force.com/myBrevilleSite/myBrevilleTestPage';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = 'startURL';
    	settings.Value__c =  'https://psldevint-plsdevbreville.cs19.force.com/mybreville/services/oauth2/authorize';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = 'logoutURL';
    	settings.Value__c =  'https://psldevint-plsdevbreville.cs19.force.com/mybreville/secur/logout.jsp';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = 'communityName';
    	settings.Value__c =  'mybreville';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = 'regexPassword';
    	settings.Value__c =  '((?=.*\\d)(?=.*[a-zA-Z])[0-9a-zA-Z@#;$%].{8,30})';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = 'nameRegex';
    	settings.Value__c =  '^[A-Za-z]+$';
		allSettings.add(settings);
		
		settings = new myBrevilleSettings__c();
    	settings.Name = 'supportPageURL';
    	settings.Value__c =  'https://psldevint-plsdevbreville.cs19.force.com/mybreville/apex/myBrevilleSupport';
		allSettings.add(settings);
		
		insert allSettings;
		
		return allSettings;
    }
    */
    
    //Shipment settings 
    public static ShipmentSetting__c createShipmentSettings(String returnAddress,Id returnLocation,Id upsPref,String shipmateApp)
    {
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = returnAddress;
    	shipmentSetting.ReturnLocation__c = returnLocation;
    	shipmentSetting.UPSShipmatePreference__c = upsPref;
    	shipmentSetting.ShipmateApp__c = shipmateApp;
    	return shipmentSetting;
    	
    }
    
    public static ShipmentSetting__c createFedExShipmentSettings(String returnAddress,Id returnLocation,Id fedexPref,String shipmateApp)
    {
    	ShipmentSetting__c shipmentSetting = new ShipmentSetting__c();
    	shipmentSetting.ReturnAddress__c = returnAddress;
    	shipmentSetting.ReturnLocation__c = returnLocation;
    	shipmentSetting.FedExShipmatePreference__c = fedexPref;
    	shipmentSetting.ShipmateApp__c = shipmateApp;
    	return shipmentSetting;
    	
    }
    
    
    
    
}// end class