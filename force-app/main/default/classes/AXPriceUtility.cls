public with sharing class AXPriceUtility {
    
    public static map<String, PriceWrapper> getXmlResponse(list<sObject> items , Account b2BAccount) {
        
        /*getting values from Custom Settings*/
        String contentType;
        String method;
        String username;
        String password;
        String requestURL;
        Map<String, PriceAPI__c> settings = PriceAPI__c.getAll();
        contentType = settings.get('ContentType').Value__c;
        method = settings.get('method').Value__c;
        username = settings.get('Username').Value__c;
        password = settings.get('Password').Value__c;
        requestURL = settings.get('RequestURL').Value__c; 
        
        
        map<String, PriceWrapper> idToPricewrapperMap = new map<String, PriceWrapper>();
        String namespace;
        String statusMessage;
        String body = createBody(items, b2BAccount);
        Http h = new Http();
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = ApplicationLiterals.BASIC + EncodingUtil.base64Encode(headerValue);
        HttpRequest req = new HttpRequest();
        req.setHeader(ApplicationLiterals.Authorization, authorizationHeader);
        req.setEndpoint(requestURL);
        req.setTimeout(120000);
        req.setMethod(method);
        req.setHeader(ApplicationLiterals.CONTENT_TYPE_FOR_PRICE_API, contentType);
        
        Blob myBlob = Blob.valueof(body);
        req.setBodyAsBlob(myBlob);
        HttpResponse res = h.send(req);
        if(res.getStatusCode()==200){
            Dom.Document doc = new Dom.Document();
            doc.load(res.getBodyAsBlob().toString());     
            Dom.XMLNode SalesPriceLookupsRequestContract = doc.getRootElement();
            Dom.XmlNode[] SalesPriceLookupRequestContractElements = SalesPriceLookupsRequestContract.getChildElements();
            namespace = SalesPriceLookupsRequestContract.getNamespaceFor('ns');
            for(Dom.XmlNode node : SalesPriceLookupRequestContractElements){
                PriceWrapper pWrapper =  createPriceWrapper(node, namespace);
                idToPricewrapperMap.put(pWrapper.CustRef, pWrapper);
            }
        }else if(res.getStatusCode() != 429){
        	
        	
        	/* error will be logged only for invalid requests (status code 400). responses with status code 429 should be proceed again*/
            if(String.valueOf(items.getSObjectType()).equalsIgnoreCase('OrderItem')){
                Order orderRecordFirst;
                if(((Order) items[0].getSObject('Order')) != null){
                  orderRecordFirst = (Order) items[0].getSObject('Order');
                }
                if(orderRecordFirst != null){
                  Error_Log__c error  = new Error_Log__c(
                      Error_Message__c = System.Label.PriceAPIErrorLog +res.getStatusCode(),
                      Type__c = ApplicationLiterals.ERROR_LOG_TYPE,
                      Order__c = orderRecordFirst.Id
                  );
                  list<Error_Log__c> errorList = new list<Error_Log__c>();
                  errorList.add(error); 
                  ID jobID = System.enqueueJob(new PriceAPIErrorLog(errorList));
                }
                
                
            }else if(String.valueOf(items.getSObjectType()).equalsIgnoreCase('RMA_Product__c')){
                Case caseRecord;
                if(((Case) items[0].getSObject('Case__r')) != null){
                  caseRecord = (Case) items[0].getSObject('Case__r');
                }
                if(caseRecord != null){
                  Error_Log__c error  = new Error_Log__c(
                      Error_Message__c = System.Label.PriceAPIErrorLog +res.getStatusCode(),
                      Type__c = ApplicationLiterals.ERROR_LOG_TYPE,
                      Case__c = caseRecord.Id
                  );
                  list<Error_Log__c> errorList = new list<Error_Log__c>();
                  errorList.add(error); 
                  ID jobID = System.enqueueJob(new PriceAPIErrorLog(errorList));
                }
                
            }else if(String.valueOf(items.getSObjectType()).equalsIgnoreCase('Receiving__c')){
			      Case caseRecord;
			      if(((Case) items[0].getSObject('Case__r')) != null){
			        caseRecord = (Case) items[0].getSObject('Case__r');
			      }
			      
		          /*for(sObject receivingRecords : items){
		              receivingRecords.put('ErrorOccurredWhileCalculatingPrice__c', true);
		          }*/
		            
		            if(caseRecord != null){
		               Error_Log__c error  = new Error_Log__c(
		                  Error_Message__c = System.Label.PriceAPIErrorLog +res.getStatusCode(),
		                  Type__c = ApplicationLiterals.ERROR_LOG_TYPE,
		                  Case__c = caseRecord.Id
		              );
		              list<Error_Log__c> errorList = new list<Error_Log__c>();
		              errorList.add(error); 
		              ID jobID = System.enqueueJob(new PriceAPIErrorLog(errorList));
		            }
            }
        }
        return idToPricewrapperMap;
        
    }  
    
    private static PriceWrapper createPriceWrapper(Dom.XmlNode node, String namespace){
        Double CostPrice = Double.valueOf(node.getChildElement('CostPrice', namespace).getText());
        String DiscDescription = node.getChildElement('DiscDescription', namespace).getText();
        String CustRef = node.getChildElement('CustRef', namespace).getText();
        Double DiscPercent = Double.valueOf(node.getChildElement('DiscPercent', namespace).getText());
        Integer IsTaxExempt = Integer.valueOf(node.getChildElement('IsTaxExempt', namespace).getText());
        Integer IsUnitPrice = Integer.valueOf(node.getChildElement('IsUnitPrice', namespace).getText());
        String ItemId = node.getChildElement('ItemId', namespace).getText();
        Double RetailPrice = Double.valueOf(node.getChildElement('RetailPrice', namespace).getText());
        Double SalesPrice = Double.valueOf(node.getChildElement('SalesPrice', namespace).getText());
        String StatusCode = node.getChildElement('StatusCode', namespace).getText();
        return  new PriceWrapper(CostPrice, DiscDescription, DiscPercent, IsTaxExempt, IsUnitPrice, ItemId, RetailPrice, SalesPrice, StatusCode,CustRef);
    }
    
    
    private static String createBody(list<sObject> items , Account b2BAccount){
        
        
        String body = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<SalesPriceLookupsRequestContract>';
            
        String sObjectType = String.valueOf(items.getSObjectType());
            
        if(sObjectType.equalsIgnoreCase('OrderItem')){
            String transType='S';
            if(b2BAccount != null && b2BAccount.BusinessUnitFormula__c != null && b2BAccount.BusinessUnitFormula__c != ''){
            	body = body + '<CompanyId>' +b2BAccount.BusinessUnitFormula__c  +'</CompanyId>';
            }else{
            	body = body + '<CompanyId></CompanyId>';
            }
            /* can put this for loop in method if you want*/
            for(sObject orderItemRecord : items){
                Date shipDate;
                Date orderDate = Date.today();
                Order orderRecord = (Order) orderItemRecord.getSObject('Order');
                if(orderRecord != null && orderRecord.get('RequestedShipDate__c') != null){
                    shipDate = (Date) orderRecord.get('RequestedShipDate__c');
                }
                
                String accountNumber='';
                String invoiceNumber='';
                String itemNumber='';
                String receivedQuantity='';
                String CustRef = String.valueOf(orderItemRecord.get('Id'));
                if(b2BAccount != null && b2BAccount.get('VendAccount__c') != null && b2BAccount.get('VendAccount__c') != ''){
                    accountNumber = String.valueOf(b2BAccount.get('VendAccount__c'));
                }
                if(orderItemRecord != null && orderItemRecord.get('AX_Item_Number__c') != null && orderItemRecord.get('AX_Item_Number__c') != ''){
                    itemNumber = String.valueOf(orderItemRecord.get('AX_Item_Number__c'));
                }
                if(orderItemRecord != null && orderItemRecord.get('Quantity') != null && orderItemRecord.get('Quantity') != ''){
                    receivedQuantity = String.valueOf(orderItemRecord.get('Quantity'));
                }
               
                String orderDateText = createTextFromDate(orderDate);
                String requestedShipDateText = createTextFromDate(shipDate);
                
                body = body +createGenericBodyForXmlRequest(accountNumber, '', itemNumber, orderDateText, receivedQuantity, requestedShipDateText, transtype,CustRef);
            }
            
        }else if(sObjectType.equalsIgnoreCase('RMA_Product__c')){
            
            String transType='C';
            Case caseRecordFirst;
            Account accountRecordFirst;
            if(((Case)items[0].getSObject('Case__r')) != null){
              caseRecordFirst = (Case) items[0].getSObject('Case__r');
            }
            if(caseRecordFirst != null && ((Account)caseRecordFirst.getSObject('Account')) != null){
              accountRecordFirst = (Account) caseRecordFirst.getSObject('Account');
            }
            if(accountRecordFirst != null && accountRecordFirst.BusinessUnitFormula__c != null && accountRecordFirst.BusinessUnitFormula__c != ''){
            	body = body + '<CompanyId>' +accountRecordFirst.BusinessUnitFormula__c  +'</CompanyId>';
            }else{
            	body = body + '<CompanyId></CompanyId>';
            }
            for(sObject rmaProductRecord : items){
                Date shipDate;
                Date orderDate;
                Case caseRecord;
                Product2 productRecord;
                Account accountRecord;
                
                if(((Case)rmaProductRecord.getSObject('Case__r')) != null){
                  caseRecord = (Case) rmaProductRecord.getSObject('Case__r');
                }
                if(((Product2)rmaProductRecord.getSObject('Product__r')) != null){
                  productRecord = (Product2) rmaProductRecord.getSObject('Product__r');
                }
                if(caseRecord != null && ((Account)caseRecord.getSObject('Account')) != null){
                   accountRecord = (Account) caseRecord.getSObject('Account');
                }
                orderDate =Date.today();
                shipDate = Date.today();
                
                String accountNumber='';
                String invoiceNumber='';
                String itemNumber='';
                String receivedQuantity='';
                String CustRef = String.valueOf(rmaProductRecord.get('Id'));
                 
                if(accountRecord != null && accountRecord.get('VendAccount__c') != null && accountRecord.get('VendAccount__c') != ''){
                    accountNumber = String.valueOf(accountRecord.get('VendAccount__c'));
                }
                if(caseRecord != null && caseRecord.get('Purchase_Invoice_No__c') != null && caseRecord.get('Purchase_Invoice_No__c') != ''){
                    invoiceNumber = String.valueOf(caseRecord.get('Purchase_Invoice_No__c'));
                }
                if(productRecord != null && productRecord.get('AX_Item_Number__c') != null && productRecord.get('AX_Item_Number__c') != ''){
                    itemNumber = String.valueOf(productRecord.get('AX_Item_Number__c'));
                }
                if(rmaProductRecord != null && rmaProductRecord.get('Quantity__c') != null && rmaProductRecord.get('Quantity__c') != ''){
                    receivedQuantity = String.valueOf(rmaProductRecord.get('Quantity__c'));
                }
                
                String orderDateText = createTextFromDate(orderDate);
                String requestedShipDateText=createTextFromDate(shipDate);
                
                body = body +createGenericBodyForXmlRequest(accountNumber,invoiceNumber, itemNumber, orderDateText, receivedQuantity, requestedShipDateText, transtype,CustRef);
            
            }
        }else if(sObjectType.equalsIgnoreCase('Receiving__c')){
            String transType='C';
            Case caseRecordFirst;
            Account accountRecordFirst;
            
            if(((Case) items[0].getSObject('Case__r')) != null){
              caseRecordFirst = (Case) items[0].getSObject('Case__r');
            }
            if(caseRecordFirst != null && ((Account) caseRecordFirst.getSObject('Account')) != null){
              accountRecordFirst = (Account) caseRecordFirst.getSObject('Account');
            }
            
            if(accountRecordFirst != null && accountRecordFirst.BusinessUnitFormula__c != null && accountRecordFirst.BusinessUnitFormula__c != ''){
            	body = body + '<CompanyId>' +accountRecordFirst.BusinessUnitFormula__c  +'</CompanyId>';
            }else{
            	body = body + '<CompanyId></CompanyId>';
            }
            
            for(sObject receivingRecord : items){
                Date shipDate;
                Date orderDate;
                Case caseRecord;
                Account accountRecord;
                Product2 productRecord;
                
                if(((Case) receivingRecord.getSObject('Case__r')) != null){
                  caseRecord = (Case) receivingRecord.getSObject('Case__r');
                }
                if(caseRecord != null && ((Account) caseRecord.getSObject('Account')) != null){
                  accountRecord = (Account) caseRecord.getSObject('Account');
                }
                
                if(((Product2) receivingRecord.getSObject('Received_Product__r')) != null){
                  productRecord = (Product2) receivingRecord.getSObject('Received_Product__r');
                }
                orderDate = Date.today();
                shipDate = Date.today();
                /*if(caseRecord != null && caseRecord.CreatedDate != null){
                    orderDate = ((DateTime)caseRecord.get('CreatedDate')).date();
                }else{
                    orderDate = Date.Today();
                }
                
                
                /*if(caseRecord != null && caseRecord.ClosedDate != null){
                    shipDate = ((DateTime)caseRecord.get('ClosedDate')).date();
                }else{
                    shipDate = Date.Today();
                }*/
                
                String accountNumber='';
                String invoiceNumber='';
                String itemNumber='';
                String receivedQuantity='';
                
                String orderDateText = createTextFromDate(orderDate);
                String requestedShipDateText=createTextFromDate(shipDate);
                
                String CustRef = String.valueOf(receivingRecord.get('Id'));
                if(receivingRecord != null && receivingRecord.get('AXAccountNumber__c') != null && receivingRecord.get('AXAccountNumber__c') != ''){
                    accountNumber = String.valueOf(receivingRecord.get('AXAccountNumber__c'));
                }
                if(caseRecord != null && caseRecord.get('Purchase_Invoice_No__c') != null && caseRecord.get('Purchase_Invoice_No__c') != ''){
                    invoiceNumber = String.valueOf(caseRecord.get('Purchase_Invoice_No__c'));
                }
                if(productRecord != null && productRecord.get('AX_Item_Number__c') != null && productRecord.get('AX_Item_Number__c') != ''){
                    itemNumber = String.valueOf(productRecord.get('AX_Item_Number__c'));
                }
                if(receivingRecord != null && receivingRecord.get('Received_Qty__c') != null && receivingRecord.get('Received_Qty__c') != ''){
                    receivedQuantity = String.valueOf(receivingRecord.get('Received_Qty__c'));
                }
                
                body = body +createGenericBodyForXmlRequest(accountNumber ,invoiceNumber, itemNumber, orderDateText, receivedQuantity, requestedShipDateText, transtype,CustRef); 

            }
        }   
            
        body = body +'</SalesPriceLookupsRequestContract>';
        System.debug('###BODY : ' +body);
        return body;
    }
    
    public static String createTextFromDate(Date dateValue){
    	
    	
        String returnDateValue;
        if(dateValue != null){
           Datetime datetimevalue = datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
           returnDateValue = datetimevalue.format('yyyy-MM-dd');
        }
        return returnDateValue;
        
    }
    
    private static String createGenericBodyForXmlRequest(String custId, String invoiceId, String itemId, String orderDate, String quantity, String reqShipDate,
                                                        String transtype,String CustRef){
        String body='';
        
        
        body = body +
        '<SalesPriceLookupRequestContract>';
         
        if(custId != null && custId != ''){
            body = body +'<CustAccount>' +custId +'</CustAccount>';
        }
        if(CustRef != null && CustRef != ''){
            body = body +'<CustRef>' +CustRef +'</CustRef>';
        }
        if(invoiceId != null && invoiceId != ''){
            body = body +'<InvoiceId>' +invoiceId +'</InvoiceId>';
        }
        if(itemId != null && itemId != ''){
            body = body +'<ItemId>' +itemId +'</ItemId>';
        }
        if(orderDate != null && orderDate != ''){
            body = body +'<OrderDate>'+orderDate+'</OrderDate>';
        }
        if(quantity != null && quantity != ''){
            body = body +'<Qty>'+quantity+'</Qty>';
        }
        if(reqShipDate != null && reqShipDate != ''){
            body = body +'<RequestedShipDate>'+reqShipDate +'</RequestedShipDate>';
        }
        if(transType != null && transType != ''){
            body = body +'<TransType>' +transType +'</TransType>';
        }

        body = body +'</SalesPriceLookupRequestContract>';
        
        return body;
    }
    
    public class PriceWrapper{
        public Double CostPrice;
        public String DiscDescription;
        public Double DiscPercent;
        public Integer IsTaxExempt;
        public Integer IsUnitPrice;
        public String ItemId;
        public Double RetailPrice;
        public Double SalesPrice;
        public String StatusCode;
        public String CustRef;
      
        public PriceWrapper(Double CostPrice, String DiscDescription, Double DiscPercent, Integer IsTaxExempt, Integer IsUnitPrice, String ItemId, 
                                Double RetailPrice, Double SalesPrice, String StatusCode,String CustRef){
            this.CostPrice = CostPrice;
            this.DiscDescription = DiscDescription;
            this.DiscPercent = DiscPercent;
            this.IsTaxExempt = IsTaxExempt;
            this.IsUnitPrice = IsUnitPrice;
            this.ItemId = ItemId;
            this.RetailPrice= RetailPrice;
            this.SalesPrice = SalesPrice;
            this.StatusCode = StatusCode;
            this.CustRef = CustRef;
        } 
              
    }
}