public with sharing class NewOrderCtrl {
    
    public String orderType             {get;set;}
    public String brand                 {get;set;}
    public Case caseRec               {get;set;}
    public String returnURL            {get;set;}
    public boolean showBrandSelection      {get;set;}
    private Boolean showSampleOrder;
    private Boolean isNOTServicable;
    private boolean accomodationNOTAvailable;
    private String idParam = null;
    private String accountId = null;
    String objectType=null;
    private Boolean isAUSB2COrder;
    private Boolean isWorkOrderPresent = false;
    
    String currecnyCode;
    @testVisible Boolean isPortalUser;
    User currentUser;
    String region;
    String profile;
    
    //Id serviceOrderId;
    public String selectedDeliveryOption  {get;set;}
    public Boolean isEmpPortalUser {get;set;}
    
    public NewOrderCtrl(ApexPages.StandardController controller){
        currecnyCode = ApexPages.currentPage().getParameters().get('currencyISOCode');
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        idParam = ApexPages.currentPage().getParameters().get('recordId');
        
        region = Utility.regionBased(currecnyCode);
        currentUser = [SELECT id, IsPortalEnabled, AccountID, DefaultCurrencyIsoCode, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        isPortalUser = currentUser.IsPortalEnabled;
        profile = currentUser.Profile.Name;
        orderType = '';
        brand = '';
        isNOTServicable = true;
        accomodationNOTAvailable = true;
        showSampleOrder = false;
        showBrandSelection = true;
        isAUSB2COrder = false;
        
        if(!(idParam != null && idParam != '')){
            idParam = currentUser.AccountID;
        }
        if(idParam != null && idParam != ''){
            objectType = Id.valueOf(idParam).getSObjectType().getDescribe().getName();
        }
        
        list<All_Literal__mdt> brandSelection = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName = 'HideBrandSelectionForB2CAUS'];
        
        if(objectType=='Case'){
            list<Case> caseList = [SELECT id, Product__c, Product__r.Serviceable__c, Warranty__c, AccountId, Account.RecordTypeId, Account.RecordType.DeveloperName,
                                   Service_Center__c, ReturnLocation__c
                                   FROM Case WHERE Id =: idParam];
            if(caseList != null && caseList.size() > 0){
                if(caseList[0].Product__c != null && caseList[0].Product__r.Serviceable__c && caseList[0].Service_Center__c != null){
                    isNOTServicable = false;
                }
                list<All_Literal__mdt> literalRecList = [SELECT Value__c FROM All_Literal__mdt WHERE DeveloperName = 'AllowAccommodationWithoutReturnCenter'];
                if((caseList[0].ReturnLocation__c != null && caseList[0].Warranty__c != null && caseList[0].Warranty__c != '' &&
                    (caseList[0].Warranty__c.equalsIgnoreCase('In Warranty') || caseList[0].Warranty__c.equalsIgnoreCase('Extended Warranty') )) || 
                   (literalRecList != null && literalRecList.size() > 0 && Boolean.valueOf(literalRecList[0].Value__c))){
                       accomodationNOTAvailable = false;
                   }
                if(caseList[0].AccountId != null && caseList[0].Account.RecordTypeId != null && caseList[0].Account.RecordType.DeveloperName != null 
                   && caseList[0].Account.RecordType.DeveloperName != '' && caseList[0].Account.RecordType.DeveloperName.equalsIgnoreCase('Business_Account') && !isPortalUser){ 
                       showSampleOrder = true;
                   }else if(brandSelection[0].Value__c.equalsIgnoreCase('Yes') && caseList[0].AccountId != null && caseList[0].Account.RecordTypeId != null && 
                            caseList[0].Account.RecordType.DeveloperName != null && caseList[0].Account.RecordType.DeveloperName != '' && 
                            caseList[0].Account.RecordType.DeveloperName.equalsIgnoreCase('PersonAccount')){
                                /* to hide brands for B2c order for AUS */
                                if(currecnyCode != null && currecnyCode != '' && currecnyCode == 'AUD'){
                                    isAUSB2COrder = true;
                                }
                            }
                list<WorkOrder> workOrderList = [select id from WorkOrder where Case.id = :caseList[0].id];
                if(workOrderList != null && workOrderList.size() > 0){
                    isWorkOrderPresent = true;
                }
                else{
                    isWorkOrderPresent = false;
                }                
            }                  
        }else if(objectType=='Account'){
            list<Account> accountList = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Account WHERE Id =: idParam];
            if(accountList != null && accountList.size() > 0 && accountList[0].RecordTypeId != null && accountList[0].RecordType.DeveloperName != null 
               && accountList[0].RecordType.DeveloperName != '' && accountList[0].RecordType.DeveloperName.equalsIgnoreCase('Business_Account') && !isPortalUser){
                   showSampleOrder = true;
               }else if(brandSelection[0].Value__c.equalsIgnoreCase('Yes') && accountList != null && accountList.size() > 0 && accountList[0].RecordTypeId != null && 
                        accountList[0].RecordType.DeveloperName != null && accountList[0].RecordType.DeveloperName != '' && 
                        accountList[0].RecordType.DeveloperName.equalsIgnoreCase('PersonAccount')){
                            /* to hide brands for B2c order for AUS */
                            if(currecnyCode != null && currecnyCode != '' && currecnyCode == 'AUD'){
                                isAUSB2COrder = true;
                            }
                        }
            
        }
        //CHecking it is B2B account OR AUS B2C Order
        if(showSampleOrder || isAUSB2COrder){
            if(currecnyCode != null && currecnyCode != ''){
                if(!(currecnyCode.equalsIgnoreCase('USD') || currecnyCode.equalsIgnoreCase('CAD'))){
                    if(currecnyCode.equalsIgnoreCase('GBP') || currecnyCode.equalsIgnoreCase('EUR') || currecnyCode.equalsIgnoreCase('CHF') ){
                        brand = 'Sage';
                    }else{
                        brand = 'Breville';
                    }
                    showBrandSelection = false;
                }
            }
        }
        checkUser();
    }
    
    public List<SelectOption> getBrands() {
        List<SelectOption> options = new List<SelectOption>(); 
        if(showBrandSelection){
            /* updated order type logic*/
            Set<String> brandSet = new Set<String>();
            for(Pricebook2 pricebook : [SELECT Id, Brand__c, Region__c FROM Pricebook2 WHERE Region__c =: region AND Brand__c != NULL]){
                if(!brandSet.contains(pricebook.Brand__c)){
                    options.add(new SelectOption(pricebook.Brand__c, pricebook.Brand__c));
                    brandSet.add(pricebook.Brand__c);
                }
            }
            return options;
        }else{
            return null;
        }
        
    }
    public List<SelectOption> getOrderTypes() {
        //Boolean showSampleOrder = false;
        List<SelectOption> options = new List<SelectOption>(); 
        if(isPortalUser && profile == 'Employee Portal Community'){
            options.add(new SelectOption('Employee Sale','Internal Employee Sale'));
        }else if(isPortalUser && profile == 'Specialty Roaster Community'){
            options.add(new SelectOption('Specialty Roaster','Specialty Roaster'));
        }else{
            options.add(new SelectOption('Sale','Sale'));
        }
        if(!isPortalUser){
            //boolean accomodationNOTAvailable = true;
            //boolean isNOTServicable = true;
            if(objectType=='Case'){
                //Below options should only be available when 'New Order' is clicked from Case screen
                options.add(new SelectOption('Accommodation', 'Accommodation', accomodationNOTAvailable));
                options.add(new SelectOption('Repair Replacement', 'Repair Replacement'));
                options.add(new SelectOption('Work Order', 'Work Order', isNOTServicable));   
            }
            if(objectType=='Account'){
                options.add(new SelectOption('Employee Sale','Internal Employee Sale'));
                if(region == 'AUS' || region == 'NZ') {
                    options.add(new SelectOption('Retail Employee Sales','Retail Employee Sales'));
                    options.add(new SelectOption('Partner & Associate Sales','Partner & Associate Sales'));
                    options.add(new SelectOption('Retail Event Sales','Retail Event Sales'));
                }
                if(region == 'AUS') {
                    options.add(new SelectOption('Holiday Promo','Holiday Promo'));
                    options.add(new SelectOption('Event Sales Coffee','Event Sales Coffee'));
                }
            }
        }
        if(showSampleOrder){
            options.add(new SelectOption('Sample','Sample')); 
        }
        return options; 
    }
    
    public PageReference save() {
        PageReference redirect = null;
        if((brand != null && brand != '' && orderType != null && orderType != '')){
            if(orderType == 'Work Order'){
                Case caseRecord = getCase(getWorkOrderFieldMappingForCase(), '');
                if(caseRecord != null){
                    if(caseRecord.Service_Center__c == null){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please assign Service Center to the Case'));
                        return null;
                    }
                    WorkOrder workorder = createWorkOrder(caseRecord);
                    if(workorder != null){
                        redirect = new ApexPages.StandardController(workorder).view();
                        redirect.setRedirect(true);
                        return redirect;
                    }
                    return null;              
                }
            }else if(orderType == 'Sale' || orderType == 'Sample' || orderType == 'Accommodation' || orderType == 'Employee Sale' 
                     || orderType == 'Repair Replacement' || orderType == 'Retail Employee Sales' || orderType == 'Partner & Associate Sales'
                     || orderType == 'Retail Event Sales' || orderType == 'Holiday Promo' || orderType == 'Specialty Roaster' || orderType ==  'Event Sales Coffee'){
                         if(objectType=='Account'){
                             Account accountRecord= getAccount(getOrderFieldMappingForAccount());
                             if(accountRecord != null){
                                 if(accountRecord.BillingCity != null && accountRecord.BillingCity != '' && 
                                    accountRecord.BillingCountryCode != null && accountRecord.BillingCountryCode != '' &&
                                    ((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR' || 
                                      accountRecord.CurrencyIsoCode == 'CHF') ||
                                     (accountRecord.BillingStateCode != null && accountRecord.BillingStateCode != '')) &&
                                    (((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR') && 
                                      accountRecord.BillingCountryCode=='IE') || 
                                     (accountRecord.BillingPostalCode != null && accountRecord.BillingPostalCode != '')) &&
                                    accountRecord.BillingStreet != null && accountRecord.BillingStreet != '' &&
                                    accountRecord.ShippingCountryCode != null && accountRecord.ShippingCountryCode != '' &&
                                    accountRecord.ShippingCity != null && accountRecord.ShippingCity != '' &&
                                    ((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR' || 
                                      accountRecord.CurrencyIsoCode == 'CHF') || 
                                     (accountRecord.ShippingStateCode != null && accountRecord.ShippingStateCode != '')) &&
                                    accountRecord.ShippingStreet != null && accountRecord.ShippingStreet != '' &&
                                    (((accountRecord.CurrencyIsoCode == 'GBP' || accountRecord.CurrencyIsoCode == 'EUR') &&
                                      accountRecord.ShippingCountryCode=='IE') ||
                                     (accountRecord.ShippingPostalCode != null && accountRecord.ShippingPostalCode != ''))){
                                         
                                         Order orderRecord = createOrderAccount(accountRecord);
                                         if(orderRecord != null){
                                             //old code>>>
                                             /*String url = System.Url.getSalesforceBaseURL().toExternalForm() +
Site.getPathPrefix() +'/_ui/busop/orderitem/SelectSearch?addTo='+orderRecord.id +'&retURL=%'+orderRecord.id; */
                                             
                                             //new changes for work ticket W-000287 starts from here //
                                             String url = '';
                                             if(isPortalUser)
                                             {
                                                 url = System.Url.getSalesforceBaseURL().toExternalForm() +
                                                     Site.getPathPrefix() +'/_ui/busop/orderitem/SelectSearch?addTo='+orderRecord.id +'&retURL=%'+orderRecord.id;
                                             }else{
                                                 url = System.Url.getSalesforceBaseURL().toExternalForm() +  Site.getPathPrefix() + '/apex/AddOrderProduct?id='+orderRecord.id ;
                                             }   
                                             //new changes for work ticket W-000287 ends here //      
                                             redirect = new PageReference(url);
                                             redirect.setRedirect(true);
                                             return redirect;
                                         }
                                         
                                     }else{
                                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter complete Billing and Shipping Address'));
                                     }
                             }
                         }else{
                             Case caseRecord = getCase(getOrderFieldMappingForCase(), 
                                                       ' Service_Center__c, Service_Center__r.Type, Priority, QC_Alert__c, QC_Alert__r.RecordTypeId, QC_Alert__r.RecordType.DeveloperName, ');
                             if(caseRecord != null){
                                 if(caseRecord.AccountId != null &&
                                    caseRecord.Account.BillingCity != null && caseRecord.Account.BillingCity != '' &&
                                    caseRecord.Account.BillingCountryCode != null && caseRecord.Account.BillingCountryCode != '' &&
                                    ((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR' || caseRecord.CurrencyIsoCode == 'CHF') || 
                                     (caseRecord.Account.BillingStateCode != null && caseRecord.Account.BillingStateCode != '')) &&
                                    (((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR') && caseRecord.Account.BillingCountryCode=='IE') || 
                                     (caseRecord.Account.BillingPostalCode != null && caseRecord.Account.BillingPostalCode != '')) &&
                                    caseRecord.Account.BillingStreet != null && caseRecord.Account.BillingStreet != '' &&
                                    caseRecord.Account.ShippingCountryCode != null && caseRecord.Account.ShippingCountryCode != '' &&
                                    caseRecord.Account.ShippingCity != null && caseRecord.Account.ShippingCity != '' &&
                                    ((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR' || caseRecord.CurrencyIsoCode == 'CHF') || 
                                     (caseRecord.Account.ShippingStateCode != null && caseRecord.Account.ShippingStateCode != '')) &&
                                    (((caseRecord.CurrencyIsoCode == 'GBP' || caseRecord.CurrencyIsoCode == 'EUR') && caseRecord.Account.ShippingCountryCode=='IE') || 
                                     (caseRecord.Account.ShippingPostalCode != null && caseRecord.Account.ShippingPostalCode != ''))){
                                         Order orderRecord = createOrder(caseRecord);
                                         if(orderRecord != null){
                                             /*old logic: 
String url = System.Url.getSalesforceBaseURL().toExternalForm()+ 
Site.getPathPrefix() +'/_ui/busop/orderitem/SelectSearch?addTo='+orderRecord.id +'&retURL=%'+orderRecord.id; */
                                             
                                             //new changes for work ticket W-000287 starts here //  
                                             String url = '';
                                             if(isPortalUser)
                                             {
                                                 url = System.Url.getSalesforceBaseURL().toExternalForm() +
                                                     Site.getPathPrefix() +'/_ui/busop/orderitem/SelectSearch?addTo='+orderRecord.id +'&retURL=%'+orderRecord.id;
                                             }else{
                                                 url = System.Url.getSalesforceBaseURL().toExternalForm() +  Site.getPathPrefix() + '/apex/AddOrderProduct?id='+orderRecord.id ;
                                             } 
                                             //new changes for work ticket W-000287 ends here //          
                                             redirect = new PageReference(url);
                                             redirect.setRedirect(true);
                                             return redirect;
                                         }
                                         
                                     }else{
                                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter complete Billing and Shipping Address'));
                                     }
                             }
                         }
                     }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select \'Brand\' and \'Type\' to proceed'));
        }
        return null;
    }
    private Case getCase(map<String,String> fieldMapping, String extraFields){
        
        List<String> caseFields = fieldMapping.values();
        String soql = '' 
            + ' select '+ extraFields + String.join(caseFields, ',') 
            + ' from Case'
            + ' where id =:idParam';
        list<Case> caseList = Database.query(soql);
        if(caseList != null && caseList.size() > 0){
            return caseList[0];
        }
        return null;
    }
    private Account getAccount(map<String,String> fieldMapping){
        
        List<String> accountFields = fieldMapping.values();
        String soql = ''
            + ' select ' + String.join(accountFields, ',')
            + ' from Account'
            + ' where id =:idParam';
        list<Account> accountList = Database.query(soql);
        if(accountList != null && accountList.size() > 0){
            return accountList[0];
        }
        return null;
    }
    
    private WorkOrder createWorkOrder(Case caseRecord){
        WorkOrder workorder = new WorkOrder();
        map<String,String> workOrderFieldMapping = getWorkOrderFieldMappingForCase();
        String caseField = '';
        for(String workOrderField : workOrderFieldMapping.keySet()){
            caseField = workOrderFieldMapping.get(workOrderField);
            if(!caseField.contains('.')){
                workorder.put(workOrderField,caseRecord.get(caseField));
            }else{
                String[] referenceFields = caseField.split('\\.');
                workorder.put(workOrderField,caseRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        //,City,Country,CountryCode,PostalCode,State,StateCode,Street
        list<Account> workOrderAccount = [select id,FirstName,LastName,PersonEmail,Phone from Account where id=:workorder.AccountId];
        if(workOrderAccount != null && workOrderAccount.size()>0){
            workorder.FirstName__c = workOrderAccount[0].FirstName;
            workorder.LastName__c = workOrderAccount[0].LastName;
            workorder.Email__c = workOrderAccount[0].PersonEmail;
            workorder.Phone__c = workOrderAccount[0].Phone;
        }
        //checkServicePriceForWorkOrder(workorder);
        
        workorder.Brand__c = brand;
        
        RecordType recordTypeWorkOrder = [SELECT ID FROM RecordType WHERE Name='Work Order' AND sobjecttype = 'WorkOrder' LIMIT 1][0];
        workOrder.RecordTypeId = recordTypeWorkOrder.Id;
        list<MasterTaxData__mdt> masterTaxDataList = [SELECT DeveloperName, IsZip2TaxApplicable__c, AddressFieldOnOrder__c, AddressFieldOnWorkOrder__c,TaxOnASC__c, 
                                                      CacheDurationInDays__c FROM MasterTaxData__mdt WHERE DeveloperName =: currecnyCode];
        if(masterTaxDataList != null && masterTaxDataList.size() > 0){
            MasterTaxData__mdt masterTaxDataRecord = masterTaxDataList[0];
            if(masterTaxDataRecord.TaxOnASC__c){
                try{
                    list<Account> accountList= [SELECT Id, BillingPostalCode, BillingStateCode, BillingCountryCode FROM Account WHERE Id =: workOrder.ServiceCentre__c];
                    if(accountList != null && accountList.size() > 0){
                        TaxRate taxRateRecord = new TaxRate();
                        taxRateRecord.filterWorkOrders(workOrder, accountList[0]);
                    }
                    insert workorder;
                    return workorder;
                }catch(System.DmlException ex){
                    System.debug(ex.getDmlMessage(0));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0)));
                    return null;
                }
            }
            else{
                try{
                    list<Account> accountList= [SELECT Id, BillingPostalCode, BillingStateCode, BillingCountryCode FROM Account WHERE Id =: workOrder.AccountId];
                    if(accountList != null && accountList.size() > 0){
                        TaxRate taxRateRecord = new TaxRate();
                        taxRateRecord.filterWorkOrders(workOrder, accountList[0]);
                    }
                    
                    insert workorder;
                    return workorder;
                }catch(System.DmlException ex){
                    System.debug(ex.getDmlMessage(0));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0)));
                    return null;
                }
                
                
            }
        }
        return null;
    }
    private Order createOrder(Case caseRecord){
        Order orderRecord = new Order();
        map<String,String> OrderFieldMapping = getOrderFieldMappingForCase();
        String caseField = '';
        for(String orderField : OrderFieldMapping.keySet()){
            caseField = OrderFieldMapping.get(orderField);
            if(!caseField.contains('.')){
                orderRecord.put(orderField,caseRecord.get(caseField));
            }else{
                String[] referenceFields = caseField.split('\\.');
                orderRecord.put(orderField,caseRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        //QC_Alert__c, QC_Alert__r.RecordTypeId, QC_Alert__r.RecordType.DeveloperName,
        if(caseRecord.Priority != null && caseRecord.Priority.equalsIgnoreCase('Recall') && caseRecord.QC_Alert__c != null && caseRecord.QC_Alert__r.RecordTypeId != null 
           && caseRecord.QC_Alert__r.RecordType.DeveloperName != null && caseRecord.QC_Alert__r.RecordType.DeveloperName.equalsIgnoreCase('Recall')){
               orderRecord.Recall_Fasttrack__c = true;
           }
        orderRecord.put('EffectiveDate',Date.today());
        orderRecord.put('Type',orderType);
        orderRecord.status='Open';
        orderRecord.Brand__c = brand;
        
        String currencyCode = (String) caseRecord.get('CurrencyIsoCode');
        
        TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(orderRecord);
        
        checkPriceBookForOrder(orderRecord);
        
        if(orderRecord.PriceBook2Id == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Required pricebook not available.'));
            return null;
        }
        if(orderType != null && orderType != null && orderType.equalsIgnoreCase('Repair Replacement')){
            list<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder WHERE Status = 'Unrepairable' AND CaseId =: caseRecord.Id ];
            if(workOrderList != null && workOrderList.size() > 0 ){
                orderRecord.ServiceOrder__c = workOrderList[0].Id;
            }
        }
        
        if(region != null){
            orderRecord.Country__c = region;
        }     
        try{
            insert orderRecord;
        }catch(System.DmlException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0)));
            return null;
        }        
        return orderRecord;
    }
    private Order createOrderAccount(Account accountRecord){
        Order orderRecord = new Order();
        map<String,String> OrderFieldMapping = getOrderFieldMappingForAccount();
        String accountField = '';
        for(String orderField : OrderFieldMapping.keySet()){
            accountField = OrderFieldMapping.get(orderField);
            if(!accountField.contains('.')){
                orderRecord.put(orderField,accountRecord.get(accountField));
            }else{
                String[] referenceFields = accountField.split('\\.');
                orderRecord.put(orderField,accountRecord.getSobject(referenceFields[0]).get(referenceFields[1]));
            }
            
        }
        orderRecord.put('EffectiveDate',Date.today());
        orderRecord.put('Type',orderType);
        
        orderRecord.status='Open';
        orderRecord.Brand__c = brand;
        String currencyCode = (String) accountRecord.get('CurrencyIsoCode');
        
        TaxRate taxRateRecord = new TaxRate();
        taxRateRecord.filterOrders(orderRecord);
        
        checkPriceBookForOrder(orderRecord);
        
        if(orderRecord.PriceBook2Id == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Required pricebook not available.'));
            return null;
        }
        
        if(region != null){
            orderRecord.Country__c = region;
        } 
        //For Employee Portal User, check if Delivery option is Breville Corporate Office, mark deliver_Breville_Office__c field on order.
        if(isEmpPortalUser){
            if(selectedDeliveryOption != null && selectedDeliveryOption !=''){
                if(selectedDeliveryOption == 'breville_office' && region !=null){
                    List<Account> corporateOfficeList = Utility.fetchAccountDetailsFromRegion(region);
                    if(corporateOfficeList != null && corporateOfficeList.size() > 0){
                        orderRecord.deliver_Breville_Office__c = true;
                        orderRecord = copyBrevilleOfficeAddressAsShipping(orderRecord, corporateOfficeList[0]);
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.no_breville_office_for_region));
                        return null;
                    }
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.select_delivery_option));
                return null;
            }
        }
        try{
            insert orderRecord;
        }catch(System.DmlException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0)));
            return null;
        }        
        return orderRecord;
    }
    
    
    public PageReference cancel(){    
        PageReference pageRef = new PageReference(returnURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public map<String,String> getOrderFieldMappingForCase(){
        map<String,String> orderFieldMap = new  map<String,String>();
        orderFieldMap.put('AccountId','AccountId');
        orderFieldMap.put('BillToContactId','ContactId');
        orderFieldMap.put('BillingCity','Account.BillingCity');
        orderFieldMap.put('BillingCountryCode','Account.BillingCountryCode');
        orderFieldMap.put('BillingPostalCode','Account.BillingPostalCode');
        orderFieldMap.put('BillingStateCode','Account.BillingStateCode');
        orderFieldMap.put('BillingStreet','Account.BillingStreet');
        orderFieldMap.put('ShippingCountryCode','Account.ShippingCountryCode');
        orderFieldMap.put('ShippingCity','Account.ShippingCity');
        orderFieldMap.put('ShippingPostalCode','Account.ShippingPostalCode');
        orderFieldMap.put('ShippingStateCode','Account.ShippingStateCode');
        orderFieldMap.put('ShippingStreet','Account.ShippingStreet');
        orderFieldMap.put('Status','Status');
        orderFieldMap.put('Case__c','Id');
        orderFieldMap.put('CurrencyIsoCode','CurrencyIsoCode');
        orderFieldMap.put('Ship_To_Name__c','Account.Name');
        orderFieldMap.put('Tax_Exempt_Order__c','Account.IsTaxExempted__c');
        orderFieldMap.put('AX_Order_Account__c', 'Account.VendAccount__c');
        orderFieldMap.put('Return_Product_Received__c', 'RA_Delivered__c');
        return orderFieldMap;
    }
    public map<String,String> getOrderFieldMappingForAccount(){
        map<String,String> orderFieldMap = new  map<String,String>();
        orderFieldMap.put('AccountId','Id');
        orderFieldMap.put('BillToContactId','PersonContactId');
        orderFieldMap.put('BillingCity','BillingCity');
        orderFieldMap.put('BillingCountryCode','BillingCountryCode');
        orderFieldMap.put('BillingPostalCode','BillingPostalCode');
        orderFieldMap.put('BillingStateCode','BillingStateCode');
        orderFieldMap.put('BillingStreet','BillingStreet');
        orderFieldMap.put('ShippingCountryCode','ShippingCountryCode');
        orderFieldMap.put('ShippingCity','ShippingCity');
        orderFieldMap.put('ShippingPostalCode','ShippingPostalCode');
        orderFieldMap.put('ShippingStateCode','ShippingStateCode');
        orderFieldMap.put('ShippingStreet','ShippingStreet');
        orderFieldMap.put('CurrencyIsoCode','CurrencyIsoCode');
        orderFieldMap.put('Ship_To_Name__c','Name');
        orderFieldMap.put('Tax_Exempt_Order__c','IsTaxExempted__c');
        orderFieldMap.put('AX_Order_Account__c', 'VendAccount__c');
        
        return orderFieldMap;
    }
    public map<String,String> getWorkOrderFieldMappingForCase(){
        map<String,String> orderFieldMap = new  map<String,String>();
        orderFieldMap.put('AccountId','AccountId');
        orderFieldMap.put('ContactId','ContactId');
        orderFieldMap.put('City','Account.BillingCity');
        orderFieldMap.put('CountryCode','Account.BillingCountryCode');
        orderFieldMap.put('PostalCode','Account.BillingPostalCode');
        orderFieldMap.put('StateCode','Account.BillingStateCode');
        orderFieldMap.put('Street','Account.BillingStreet');
        orderFieldMap.put('ServiceCentre__c','Service_Center__c');
        orderFieldMap.put('ServicePricebook__c','Service_Center__r.ServicePriceBook__c');
        orderFieldMap.put('Product__c','Product__c');
        orderFieldMap.put('Description','Description');
        orderFieldMap.put('Subject','Subject');
        orderFieldMap.put('ComplaintCode__c','Complaint_Code__c');
        orderFieldMap.put('Sub_Complaint_Code__c','Sub_Complaint_Code__c');
        orderFieldMap.put('Secondary_Sub_Complaint_Code__c','Secondary_Sub_Complaint_Code__c');
        
        orderFieldMap.put('CaseId','Id');
        orderFieldMap.put('CaseNumber__c','CaseNumber'); 
        orderFieldMap.put('CurrencyIsoCode','CurrencyIsoCode');
        orderFieldMap.put('AssetId','AssetId');
        orderFieldMap.put('PurchaseDate__c','Purchase_Date__c');
        orderFieldMap.put('Serial__c','Serial__c');
        orderFieldMap.put('BatchCode__c','Batch_Code__c');
        return orderFieldMap;
    }
    
    public void checkPriceBookForOrder(Order orderRecord){
        
        /* assingning pricebook of Account on User in case of ASC orders else assigning default pricebook */
        String typeOfOrder = '';
        Boolean isB2BOrder = false;
        
        if(orderRecord != null && orderRecord.AccountId != null){
            Account orderAccount = [SELECT Id, RecordTypeId  FROM Account WHERE Id =: orderRecord.AccountId];
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            if(orderAccount.RecordTypeId != personAccountRecordTypeId){
                isB2BOrder = true;
            }
        }
        if(isPortalUser){
            orderRecord.CreatedFromPortal__c = true;
            if(orderType.equalsIgnoreCase('Sample')){
                typeOfOrder = 'Sample';
            }else if(orderType.equalsIgnoreCase('Employee Sale')){
                typeOfOrder = 'Employee Sale';  
            }else if(orderType.equalsIgnoreCase('Specialty Roaster')){
                typeOfOrder = 'Specialty Roaster';  
            }else{
                typeOfOrder = 'Wholesale';
            }
        }else{
            if(isB2BOrder){
                if(orderType.equalsIgnoreCase('Sample')){
                    typeOfOrder = 'Sample';
                }else{
                    typeOfOrder = 'Wholesale';
                }
            }else{
                typeOfOrder = orderType;
            }
        }
        if(orderType.equalsIgnoreCase('Repair Replacement')){
            typeOfOrder = 'Accommodation';
        }
        if(typeOfOrder != null && typeOfOrder != ''){
            List<Pricebook2> pricebookList = [SELECT Id, Brand__c, Region__c, Type__c FROM Pricebook2 
                                              WHERE Region__c =: region AND Brand__c =: brand AND Type__c =: typeOfOrder];
            for(Pricebook2 p : pricebookList){
            }
            if(pricebookList != null && pricebookList.size() > 0){
                orderRecord.PriceBook2Id = pricebookList[0].Id;
            }
        }
        
    }
    
    public void orderTypeChange(){
        if (orderType == 'Work Order'){ 
            if(isWorkOrderPresent){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Work Order already present for this case.'));
            }
        }
    }
    
    public List<SelectOption> getOrderDeliveryOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('breville_office', 'Breville Corporate Office'));
        options.add(new SelectOption('other','Other Address'));
        return options; 
    }
    
    private void checkUser(){
        isEmpPortalUser =  isPortalUser && (profile == 'Employee Portal Community');
    }
    
    @testVisible private Order copyBrevilleOfficeAddressAsShipping(Order orderRecord, Account accRecord){
        if(orderRecord!= null || accRecord!= null){
            orderRecord.ShippingStreet = accRecord.ShippingStreet ;
            orderRecord.ShippingCity = accRecord.ShippingCity ;
            orderRecord.ShippingStateCode = accRecord.ShippingStateCode ;
            orderRecord.ShippingPostalCode = accRecord.ShippingPostalCode ;
            orderRecord.ShippingCountryCode = accRecord.ShippingCountryCode ;
        }
        return orderRecord;
    }
}