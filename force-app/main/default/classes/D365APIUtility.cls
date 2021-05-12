/**
 * @File Name          : D365APIUtility.cls
 * @Description        : 
 **/
public class D365APIUtility {
    
    public enum Action {
        ProcessReceiving,
        CompleteRMA
    }
    
    public static Map <String, TradeAgreementPriceResponse> getTradeAgreementPrice(list <sObject> items, Account b2bAccount) {
        Map <String, TradeAgreementPriceResponse> itemNumberTapMap = new Map <String, TradeAgreementPriceResponse> ();
        List <TradeAgreementPriceResponse> tapList = new List <TradeAgreementPriceResponse> ();

        OAuth2 objAuthenticationInfo = authenticate();
        
        String requestString = createRequestBody(items, b2bAccount);

        Http httpCon = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:TradeAgreement');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + objAuthenticationInfo.access_token);
        req.setBody(requestString);
        HttpResponse resp = new HttpResponse();

        resp.setStatusCode(0);
        
        resp = httpCon.send(req);
        System.debug(resp.getBody());
        if (resp.getStatusCode() == 200 && String.isNotBlank(resp.getBody())) {
            System.debug(resp.getBody());
            tapList = (List <TradeAgreementPriceResponse> ) System.JSON.deserialize(resp.getBody(), List <TradeAgreementPriceResponse>.class);
            System.debug(tapList);
        }

        if (String.isBlank(resp.getBody())) {

        } else {
            for (TradeAgreementPriceResponse tapResp: tapList) {
                itemNumberTapMap.put(tapResp.ItemID, tapResp);
            }
        }
        return itemNumberTapMap;
    }
    
    public static void processRMA(Set<Id> ids) {
        List<Receiving__c> receivingRecords = getReceivingRecords(ids);

        List<RMARequest> requests = new List<RMARequest>();

        Map<Id, List<Receiving__c>> receivingByCaseId = new Map<Id, List<Receiving__c>>();
        
        for (Receiving__c receivingRecord : receivingRecords) {
            if (receivingByCaseId.containsKey(receivingRecord.Case__c)) {
                receivingByCaseId.get(receivingRecord.Case__c).add(receivingRecord);
            } else {
                receivingByCaseId.put(receivingRecord.Case__c, new List<Receiving__c> { receivingRecord });
            }
        }
        
        Map<Id, Case> cases = new Map<Id, Case> (getCaseRecords(receivingByCaseId.keySet()));
        
        for (Id caseId : receivingByCaseId.keySet()) {
            RMARequest requestObj = new RMARequest();
            requests.add(requestObj);
            List<Receiving__c> receivings = receivingByCaseId.get(caseId);
            
            Case caseRecord = cases.get(caseId);
            
            D365Mapping__mdt mapping = Utility.D365Map.get(caseRecord.CurrencyIsoCode);
            
            String warehouseId = '';
            if (caseRecord.ReturnLocation__c != null) {
                warehouseId = caseRecord.ReturnLocation__r.Warehouse_ID__c;
            } else if (mapping != null) {
                warehouseId = mapping.DefaultWarehouseId__c;
            }
            
            requestObj.RMANumber = caseRecord.Case_Number_Ext__c;
            requestObj.RMAClaimDate = caseRecord.CreatedDate.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T');
            requestObj.CurrencyCode = caseRecord.CurrencyIsoCode;
            requestObj.ReturnReasonCodeId = (caseRecord.Return_Reason_Code__c == null ? 'W' : caseRecord.Return_Reason_Code__c);
            requestObj.WarehouseID = warehouseId;
            requestObj.RMAComplete = (caseRecord.RMA_Type__c == 'Destroy in Field') ? '1' : '0';
            requestObj.LegalEntity = mapping.BusinessUnit__c;
            requestObj.ExternalClaimNumber = caseRecord.RTV__c;
            
            setRequestAddress(requestObj, caseRecord);
            
            requestObj.RMALineList = new List<RMALineItem>();
            for (Integer index = 0; index < receivings.size(); index++) {
                Receiving__c receivingRecord = receivings[index];
                RMALineItem lineItem = new RMALineItem();
                lineItem.LineNumber = index + 1;
                lineItem.ItemNumber = receivingRecord.Received_AX_Item_Number__c;
                lineItem.SFRecordID = receivingRecord.Id;
                lineItem.DispositionCode = receivingRecord.Disposition_Code__c;
                lineItem.WarehouseLocation = (caseRecord.Warehouse_Location__c == null ? 'QCV-01': caseRecord.Warehouse_Location__c);
                lineItem.PDC = receivingRecord.Received_PDC__c;
                lineItem.SerialNumber = receivingRecord.Breville_Serial__c;
                lineItem.ClaimPrice = receivingRecord.RMACalculatedUnitPrice__c;
                lineItem.RetailPrice = receivingRecord.RMACalculatedUnitPrice__c;
                
                if (caseRecord.Orders__r.size() > 0) {
                    lineItem.ClaimPrice = 0;
                    lineItem.RetailPrice = 0;
                    lineItem.LineTaxAmount = 0;
                    lineItem.LineLevelDiscount = 0;
                } else if (caseRecord.Order__c != null && caseRecord.AssetId != null) {
                    if ( caseRecord.FG_Refund_Amount__c == null) {
                        lineItem.ClaimPrice = caseRecord.Asset.Order_Product__r.UnitPrice;
                        if (!caseRecord.Order__r.PricesInclusiveOfTaxes__c) {
                            lineItem.ClaimPrice += (caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c == null ? 0 : caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c / caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Quantity);
                        }
                    } else {
                        lineItem.ClaimPrice = caseRecord.FG_Refund_Amount__c;
                    }
                    lineItem.RetailPrice = caseRecord.Asset.Order_Product__r.ListPrice;
                    lineItem.LineTaxAmount = (caseRecord.Asset.Order_Product__r.Line_Item_Tax__c == null ? 0 : caseRecord.Asset.Order_Product__r.Line_Item_Tax__c / caseRecord.Asset.Order_Product__r.Quantity);
                    lineItem.LineLevelDiscount = (caseRecord.Asset.Order_Product__r.ListPrice + (caseRecord.Order__r.PricesInclusiveOfTaxes__c ? 0 : lineItem.LineTaxAmount)) - caseRecord.FG_Refund_Amount__c;
                }
                
                lineItem.setScale(2);
                requestObj.RMALineList.add(lineItem);
                
                if (caseRecord.Order__c != null && caseRecord.AssetId != null && caseRecord.ExtendedWarranty__c != null) {
                    RMALineItem ewLineItem = new RMALineItem();
                    ewLineItem.LineNumber = index + 2;
                    ewLineItem.ItemNumber = caseRecord.ExtendedWarranty__r.AX_Item_Number__c;
                    ewLineItem.SFRecordID = String.valueOf(caseRecord.AssetId);
                    ewLineItem.DispositionCode = '2';
                    ewLineItem.WarehouseLocation = caseRecord.Warehouse_Location__c;
                    if (caseRecord.EW_Refund_Amount__c == null) {
                        ewLineItem.ClaimPrice =  caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.UnitPrice;
                        if (!caseRecord.Order__r.PricesInclusiveOfTaxes__c) {
                            ewLineItem.ClaimPrice += (caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c == null ? 0 : caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c / caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Quantity);
                        }
                    } else {
                        ewLineItem.ClaimPrice = caseRecord.EW_Refund_Amount__c;
                    }
                    ewLineItem.RetailPrice = caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.ListPrice;
                    ewLineItem.LineTaxAmount = (caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c == null ? 0 : 
                    caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c / caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.Quantity);
                    ewLineItem.LineLevelDiscount = (caseRecord.Asset.Product_Extended_warranty__r.Warranty_order_product__r.ListPrice + (caseRecord.Order__r.PricesInclusiveOfTaxes__c ? 0 : ewLineItem.LineTaxAmount)) - caseRecord.EW_Refund_Amount__c;
                    
                    ewLineItem.setScale(2);
                    requestObj.RMALineList.add(ewLineItem);
                }
            }
        }
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('_rmaList', requests);
        
        List<ProcessRMAResponse> responses = callProcessRMA(requestMap);
        
        List<Receiving__c> receivingsToUpdate = new List<Receiving__c>();
        Map<String, Case> casesToUpdate = new Map<String, Case>();
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();
        Integer errorCount = 0;
        
        for (ProcessRMAResponse response : responses) {
            if (String.isNotBlank(response.Error) ) {
                String errorString = response.Error;
                if (response.RMAResponseLineList != null && response.RMAResponseLineList.size() > 0) {
                    for (RMALineItem lineItem : response.RMAResponseLineList) {
                        if (String.isNotBlank(lineItem.Error)) {
                            if (String.isNotBlank(lineItem.D365RMANumber) 
                                && String.isNotBlank(lineItem.D365OrignalCreateDateTime) 
                                && lineItem.Error.startsWith('Duplicate return line found for sales force id')) {
                                casesToUpdate.put(response.RMANumber, new Case(Case_Number_Ext__c = response.RMANumber, D365RMANumber__c = lineItem.D365RMANumber));
                                
                                Datetime recordSentDate = Datetime.valueOf(lineItem.D365OrignalCreateDateTime.replace('T', ' ').replace('Z', ''));
                                if (lineItem.SFRecordID instanceOf Id && Id.valueOf(lineItem.SFRecordID).getSobjectType() == Receiving__c.SobjectType) {
                                    receivingsToUpdate.add(new Receiving__c(Id = lineItem.SFRecordID, Sent_to_AX__c = recordSentDate));
                                }
                            } else {
                                errorCount++;
                                errorString += '\n\r ' + lineItem.Error;
                            }
                        }
                    }
                } else {
                    errorCount++;
                }
                if (errorCount > 0) {
                    errorLogs.add(ErrorLog.logErrorActivity('', errorString, 'D365APIUtility.processRMA', false, 'API Error', response.RMANumber));
                }
            } else {
                casesToUpdate.put(response.RMANumber, new Case(Case_Number_Ext__c = response.RMANumber, D365RMANumber__c = response.D365RMANumber));
                if (response.RMAResponseLineList != null) {
                    for (RMALineItem lineItem : response.RMAResponseLineList) {
                        if (lineItem.SFRecordID instanceOf Id && Id.valueOf(lineItem.SFRecordID).getSobjectType() == Receiving__c.SobjectType) {
                            receivingsToUpdate.add(
                                new Receiving__c(Id = lineItem.SFRecordID, Sent_to_AX__c = Datetime.now())
                            );
                        }
                    }
                }
            }
        }
        
        if (!errorLogs.isEmpty()) {
            insert errorLogs;
        }
        
        if (!receivingsToUpdate.isEmpty()) {
            update receivingsToUpdate;
        }
        
        if (!casesToUpdate.isEmpty()) {
            upsert casesToUpdate.values() Case_Number_Ext__c;
        }
    }
    
    public static void completeRMA(Set<Id> ids) {
        List<Case> caseRecords = getCaseRecords(ids);
        
        List<RMARequest> requests = new List<RMARequest>();

        for (Case caseRecord : caseRecords) {
            RMARequest requestObj = new RMARequest();
            requests.add(requestObj);
            
            D365Mapping__mdt mapping = Utility.D365Map.get(caseRecord.CurrencyIsoCode);
            
            String warehouseId = '';
            if (caseRecord.ReturnLocation__c != null) {
                warehouseId = caseRecord.ReturnLocation__r.Warehouse_ID__c;
            } else if (mapping != null) {
                warehouseId = mapping.DefaultWarehouseId__c;
            }
            
            requestObj.RMANumber = caseRecord.Case_Number_Ext__c;
            requestObj.RMAClaimDate = caseRecord.CreatedDate.format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T');
            requestObj.CurrencyCode = caseRecord.CurrencyIsoCode;
            requestObj.ReturnReasonCodeId = (caseRecord.Return_Reason_Code__c == null ? 'W' : caseRecord.Return_Reason_Code__c);
            requestObj.WarehouseID = warehouseId;
            requestObj.RMAComplete = '1';
            requestObj.RMACompleteNoLines = '1';
            requestObj.LegalEntity = mapping.BusinessUnit__c;
            requestObj.ExternalClaimNumber = caseRecord.RTV__c;
            
            setRequestAddress(requestObj, caseRecord);
            
        }
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('_rmaList', requests);
        
        List<ProcessRMAResponse> responses = callProcessRMA(requestMap);
                
        List<Receiving__c> receivingsToUpdate = new List<Receiving__c>();
        List<Case> casesToUpdate = new List<Case>();
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();
        
        for (ProcessRMAResponse response : responses) {
            if (String.isNotBlank(response.Error) ) {
                errorLogs.add(ErrorLog.logErrorActivity('', response.Error, 'D365APIUtility.completeRMA', false, 'API Error', response.RMANumber));
            } else {
                casesToUpdate.add(
                    new Case(Case_Number_Ext__c = response.RMANumber, D365RMANumber__c = response.D365RMANumber, IsRMAComplete__c = true));
            }
        }
        
        if (!errorLogs.isEmpty()) {
            insert errorLogs;
        }
        
        if (!casesToUpdate.isEmpty()) {
            upsert casesToUpdate Case_Number_Ext__c;
        }
    }
    
    public static OAuth2 authenticate() {
        
        Http h = new Http();
        
        HttpRequest reqAccess = new HttpRequest();
        reqAccess.setEndpoint('callout:D365Login');
        reqAccess.setMethod('POST');
        
        String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}' + 
                         '&client_secret={!$Credential.Password}&resource=' + Utility.D365Setting.ResourceURL__c + 
                         '&content=application/json; charset=utf-8&Content-Type=application/x-www-form-urlencoded';
        reqAccess.setBody(reqbody);
        
        HttpResponse res = new HttpResponse();

        if (!Test.isRunningTest()) {
            res = h.send(reqAccess);
        } else {
            res.setStatusCode(200);
            res.setBody('{"StatusCode":"200","token_type": "tokentype","expires_in": "","ext_expires_in":"","expires_on":"","not_before":"","resource":"","access_token":"accesstoken"}');
        }
        if (res.getStatusCode() != 200) {
            Error_Log__c error = ErrorLog.logErrorActivity('Unknown Response from D365 login call', '', 'D365APIUtility.authenticate', false, 'API Error');
            insert error;
            return null;
        }
        OAuth2 objAuthenticationInfo = (OAuth2) JSON.deserialize(res.getbody(), OAuth2.class);

        return objAuthenticationInfo;
    }
    
    private static List<ProcessRMAResponse> callProcessRMA(Map<String, Object> requestMap) {
        
        OAuth2 objAuthenticationInfo = authenticate();
        
        List<ProcessRMAResponse> responses = new List<ProcessRMAResponse>();
        
        String requestBody = (String) JSON.serialize(requestMap, true);
        System.debug('request ::::: ' + requestBody);
        
        Http httpCon = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ProcessRMA');
        req.setMethod('POST');
        req.setHeader('content', 'application/json; charset=utf-8');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Bearer ' + objAuthenticationInfo.access_token);
        req.setTimeout(120000);
        req.setBody(requestBody);
        
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(0);

        resp = httpCon.send(req);
        if (resp.getStatusCode() == 200 && String.isNotBlank(resp.getBody())) {
            System.debug(resp.getBody());
            responses = (List <ProcessRMAResponse> ) System.JSON.deserialize(resp.getBody(), List <ProcessRMAResponse>.class);
        } else {
            insert ErrorLog.logErrorActivity('Unknown Response from RMA JSON Service', '', 'D365APIUtility.callProcessRMA',false, 'API Error');
        }
        System.debug(JSON.serializePretty(responses));
        
        return responses;
    }

    private static String createRequestBody(list <sObject> items, Account b2bAccount) {
        Map <String, List <TradeAgreementPriceRequest>> tapMap = new Map <String, List <TradeAgreementPriceRequest>> ();
        List <TradeAgreementPriceRequest> tapRequestList = new List <TradeAgreementPriceRequest> ();
        String sObjectType = String.valueOf(items.getSObjectType());
        if (sObjectType.equalsIgnoreCase('OrderItem')) {
            for (sObject orderItemRecord: items) {
                Date shipDate;
                String currencyCode;
                Order orderRecord = (Order) orderItemRecord.getSObject('Order');
                if (orderRecord != null) {

                    if (orderRecord.get('RequestedShipDate__c') != null) {
                        shipDate = (Date) orderRecord.get('RequestedShipDate__c');
                    }
                    if (orderRecord.get('CurrencyIsoCode') != null) {
                        currencyCode = (String) orderRecord.get('CurrencyIsoCode');
                    }
                }

                String accountNum = '';
                String invoiceNumber = '';
                String itemID = '';
                String quantity = '';
                String legalEntity = '';

                if (b2BAccount != null) {

                    if (b2BAccount.get('VendAccount__c') != null && b2BAccount.get('VendAccount__c') != '') {
                        accountNum = String.valueOf(b2BAccount.get('VendAccount__c'));
                    }
                    if (b2BAccount.get('DataAreaID__c') != null && b2BAccount.get('DataAreaID__c') != '') {
                        legalEntity = String.valueOf(b2bAccount.get('DataAreaID__c'));
                    }
                }
                if (orderItemRecord != null && orderItemRecord.get('AX_Item_Number__c') != null && orderItemRecord.get('AX_Item_Number__c') != '') {
                    itemID = String.valueOf(orderItemRecord.get('AX_Item_Number__c'));
                }
                if (orderItemRecord != null && orderItemRecord.get('Quantity') != null && orderItemRecord.get('Quantity') != '') {
                    quantity = String.valueOf(orderItemRecord.get('Quantity'));
                }

                String priceDate = AXPriceUtility.createTextFromDate(shipDate);

                TradeAgreementPriceRequest tapRec = new TradeAgreementPriceRequest(itemID, priceDate, quantity, '1', 'ea', legalEntity, currencyCode, accountNum);
                tapRequestList.add(tapRec);
            }

        } else if (sObjectType.equalsIgnoreCase('RMA_Product__c')) {
            for (sObject rmaProductRecord: items) {
                Date orderDate = Date.today();
                Case caseRecord;
                Product2 productRecord;
                Account accountRecord;
                String legalEntity = '';
                String currencyCode;

                if (((Case) rmaProductRecord.getSObject('Case__r')) != null) {
                    caseRecord = (Case) rmaProductRecord.getSObject('Case__r');
                }

                if (caseRecord != null && caseRecord.get('CurrencyIsoCode') != null) {
                    currencyCode = (String) caseRecord.get('CurrencyIsoCode');
                }

                if (((Product2) rmaProductRecord.getSObject('Product__r')) != null) {
                    productRecord = (Product2) rmaProductRecord.getSObject('Product__r');
                }

                String accountNum = '';
                String itemId = '';
                String quantity = '';
                String CustRef = String.valueOf(rmaProductRecord.get('Id'));

                accountRecord = caseRecord.Account;
                if (b2bAccount != null) {
                    accountRecord = b2bAccount;
                }

                if (accountRecord != null) {
                    if (accountRecord.get('VendAccount__c') != null && accountRecord.get('VendAccount__c') != '') {
                        accountNum = String.valueOf(accountRecord.get('VendAccount__c'));
                    }
                    if (accountRecord.get('DataAreaID__c') != null && accountRecord.get('DataAreaID__c') != '') {
                        legalEntity = String.valueOf(accountRecord.get('DataAreaID__c'));
                    }
                }

                if (productRecord != null && productRecord.get('AX_Item_Number__c') != null && productRecord.get('AX_Item_Number__c') != '') {
                    itemId = String.valueOf(productRecord.get('AX_Item_Number__c'));
                }
                if (rmaProductRecord != null && rmaProductRecord.get('Quantity__c') != null && rmaProductRecord.get('Quantity__c') != '') {
                    quantity = String.valueOf(rmaProductRecord.get('Quantity__c'));
                }

                String priceDate = AXPriceUtility.createTextFromDate(orderDate);

                TradeAgreementPriceRequest tapRec = new TradeAgreementPriceRequest(itemID, priceDate, quantity, '1', 'ea', legalEntity, currencyCode, accountNum);
                tapRequestList.add(tapRec);
            }
        } else if (sObjectType.equalsIgnoreCase('Receiving__c')) {

            for (sObject receivingRecord: items) {
                Date orderDate;
                Case caseRecord;
                Account accountRecord;
                Product2 productRecord;
                String currencyCode = '';
                String legalEntity = '';

                if (((Case) receivingRecord.getSObject('Case__r')) != null) {
                    caseRecord = (Case) receivingRecord.getSObject('Case__r');
                }

                if (caseRecord != null && caseRecord.get('CurrencyIsoCode') != null) {
                    currencyCode = (String) caseRecord.get('CurrencyIsoCode');
                }


                if (accountRecord != null) {

                    if (accountRecord.get('DataAreaID__c') != null && accountRecord.get('DataAreaID__c') != '') {
                        legalEntity = String.valueOf(accountRecord.get('DataAreaID__c'));
                    }
                }

                if (((Product2) receivingRecord.getSObject('Received_Product__r')) != null) {
                    productRecord = (Product2) receivingRecord.getSObject('Received_Product__r');
                }
                orderDate = Date.today();

                String accountNum = '';
                String invoiceNumber = '';
                String itemID = '';
                String quantity = '';

                String priceDate = AXPriceUtility.createTextFromDate(orderDate);

                String CustRef = String.valueOf(receivingRecord.get('Id'));
                if (receivingRecord != null && receivingRecord.get('AXAccountNumber__c') != null && receivingRecord.get('AXAccountNumber__c') != '') {
                    accountNum = String.valueOf(receivingRecord.get('AXAccountNumber__c'));
                }
                if (caseRecord != null && caseRecord.get('Purchase_Invoice_No__c') != null && caseRecord.get('Purchase_Invoice_No__c') != '') {
                    invoiceNumber = String.valueOf(caseRecord.get('Purchase_Invoice_No__c'));
                }
                if (productRecord != null && productRecord.get('AX_Item_Number__c') != null && productRecord.get('AX_Item_Number__c') != '') {
                    itemID = String.valueOf(productRecord.get('AX_Item_Number__c'));
                }
                if (receivingRecord != null && receivingRecord.get('Received_Qty__c') != null && receivingRecord.get('Received_Qty__c') != '') {
                    quantity = String.valueOf(receivingRecord.get('Received_Qty__c'));
                }
                if (caseRecord != null) {
                    legalEntity = caseRecord.Account.DataAreaID__c;
                }

                TradeAgreementPriceRequest tapRec = new TradeAgreementPriceRequest(itemID, priceDate, quantity, '1', 'ea', legalEntity, currencyCode, accountNum);
                tapRequestList.add(tapRec);
            }
        }

        tapMap.put('_itemList', tapRequestList);
        String request = (String) JSON.serialize(tapMap);
        System.debug('request ::::: ' + request);
        return request;
    }
    
    private static void setRequestAddress(RMARequest requestObj, Case caseRecord) {
        if (caseRecord.RecordType.Name == 'RMA') {
            requestObj.LocationID = caseRecord.Account.LocationId__c;
            requestObj.AccountNumber = caseRecord.Account_Number__c;
        } else {
            
            requestObj.BillToAddress = new AddressCls();
            requestObj.ShipToAddress = new AddressCls();
            
            if (caseRecord.Orders__r.size() > 0) {
                Order acccomodationOrder = caseRecord.Orders__r[0];
                
                requestObj.AccountNumber = acccomodationOrder.AX_Order_Account__c;
                requestObj.BillToAddress.BillToCustomerNumber = acccomodationOrder.AX_Order_Account__c;
                requestObj.ShipToAddress.BillToCustomerNumber = acccomodationOrder.AX_Order_Account__c;
                
                System.Address billingAddress = caseRecord.Account.BillingAddress;
                System.Address shippingAddress = caseRecord.Account.ShippingAddress;
                copyAddress(billingAddress, requestObj.BillToAddress, caseRecord.Account, null);
                copyAddress(shippingAddress, requestObj.ShipToAddress, caseRecord.Account, null);
            
            } else if (caseRecord.Order__c != null) {
                requestObj.OriginalSalesOrder = caseRecord.Order__r.OrderNumber;
                requestObj.AccountNumber = caseRecord.Order__r.AX_Order_Account__c;
                requestObj.BillToAddress.BillToCustomerNumber = caseRecord.Order__r.AX_Order_Account__c;
                requestObj.ShipToAddress.BillToCustomerNumber = caseRecord.Order__r.AX_Order_Account__c;
                
                System.Address billingAddress = caseRecord.Order__r.BillingAddress;
                System.Address shippingAddress = caseRecord.Order__r.ShippingAddress;
                Contact shipToContact = caseRecord.Order__r.ShipToContact;
                if (shipToContact == null) {
                    shipToContact = caseRecord.Order__r.BillToContact;
                }
                billingAddress = billingAddress == null ? caseRecord.Account.BillingAddress : billingAddress;
                shippingAddress = shippingAddress == null ? caseRecord.Account.ShippingAddress : shippingAddress;
                copyAddress(billingAddress, requestObj.BillToAddress, caseRecord.Account, caseRecord.Order__r.BillToContact);
                copyAddress(shippingAddress, requestObj.ShipToAddress, caseRecord.Account, shipToContact);
            }
        }
    }
    
    private static void copyAddress(System.Address sourceAddress, AddressCls destAddress, Account accObj, Contact contactObj) {
        
        if (contactObj != null) {
            destAddress.Contact = contactObj.Name;
            destAddress.Email = contactObj.Email;
            destAddress.Name = contactObj.Name;
            destAddress.Phone =  contactObj.Phone;
        } else {
            destAddress.Contact = accObj.Name;
            destAddress.Email = accObj.PersonEmail;
            destAddress.Name = accObj.Name;
            destAddress.Phone =  accObj.Phone;
        } 
        destAddress.Address1 = sourceAddress.street;
        destAddress.City = sourceAddress.city;
        destAddress.Country = sourceAddress.country;
        destAddress.PostalCode = sourceAddress.postalcode;
        destAddress.State = sourceAddress.state;
    }
    
    private static List<Receiving__c> getReceivingRecords(Set<Id> ids) {
        return [SELECT Id, 
            Received_AX_Item_Number__c, 
            RMACalculatedUnitPrice__c, 
            Disposition_Code__c, 
            Received_PDC__c, 
            Breville_Serial__c,
            Case__c
        FROM Receiving__c WHERE Id IN :ids];
    }
    
    private static List<Case> getCaseRecords(Set<Id> ids) {
        return [SELECT Id,
            Complaint_Code__c,
            RecordType.Name,
            Account.Name,
            Account.ShippingAddress,
            Account.BillingAddress,
            Account.Phone,
            Account.PersonEmail,
            Account_Number__c,
            Case_Number_Ext__c,
            CreatedDate,
            CurrencyIsoCode,
            Return_Reason_Code__c,
            ReturnLocation__r.Warehouse_ID__c,
            ReceivingComplete__c ,
            Account.DataAreaID__c,
            Warehouse_Location__c,
            RMA_Type__c,
            RTV__c,
            FG_Refund_Amount__c,
            EW_Refund_Amount__c,
            Account.LocationId__c,
            Order__r.OrderNumber,
            Order__r.AX_Order_Account__c,
            Order__r.PricesInclusiveOfTaxes__c,
            Order__r.BillingAddress,
            Order__r.ShippingAddress,
            Order__r.BillToContactId,
            Order__r.BillToContact.Name,
            Order__r.BillToContact.Email,
            Order__r.BillToContact.Phone,
            Order__r.ShipToContactId,
            Order__r.ShipToContact.Name,
            Order__r.ShipToContact.Email,
            Order__r.ShipToContact.Phone,
            Order__r.Channel__c, 
            Order__r.Source__c,
            Product__c,
            Product__r.AX_Item_Number__c,
            AssetId,
            Asset.Order_Product__r.UnitPrice,
            Asset.Order_Product__r.ListPrice,
            Asset.Order_Product__r.Quantity,
            Asset.Order_Product__r.Line_Item_Tax__c,
            Asset.Order_Product__r.Line_Item_Discount__c,
            ExtendedWarranty__c,
            ExtendedWarranty__r.AX_Item_Number__c,
            Asset.Product_Extended_warranty__r.Parent_order_product__c, 
            Asset.Product_Extended_warranty__r.Parent_order_product__r.UnitPrice, 
            Asset.Product_Extended_warranty__r.Parent_order_product__r.ListPrice, 
            Asset.Product_Extended_warranty__r.Parent_order_product__r.Quantity, 
            Asset.Product_Extended_warranty__r.Parent_order_product__r.Line_Item_Tax__c,
            Asset.Product_Extended_warranty__r.Parent_order_product__r.Line_Item_Discount__c,
            Asset.Product_Extended_warranty__r.Warranty_order_product__c, 
            Asset.Product_Extended_warranty__r.Warranty_order_product__r.UnitPrice, 
            Asset.Product_Extended_warranty__r.Warranty_order_product__r.ListPrice, 
            Asset.Product_Extended_warranty__r.Warranty_order_product__r.Quantity, 
            Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Tax__c,
            Asset.Product_Extended_warranty__r.Warranty_order_product__r.Line_Item_Discount__c,
            Asset.Extended_Warranty_Product__c,
            (SELECT AX_Order_Account__c FROM Orders__r WHERE Type = 'Accommodation' LIMIT 1)
        FROM Case WHERE Id IN :ids];
    }

    public class OAuth2 {

        public String token_type {
            get;
            set;
        }
        public String expires_in {
            get;
            set;
        }
        public String ext_expires_in {
            get;
            set;
        }
        public String expires_on {
            get;
            set;
        }
        public String not_before {
            get;
            set;
        }
        public String resource {
            get;
            set;
        }
        public String access_token {
            get;
            set;
        }
    }
    public class TradeAgreementPriceResponse {

        public String id;
        public String ItemID;
        public Decimal Price;
        public Decimal Quantity;
        public String UnitID;
        public String PriceDate;
        public String LegalEntity;
        public String CurrencyCode;

        public TradeAgreementPriceResponse(String id, String ItemID, Decimal Price, Decimal Quantity, String UnitID, String PriceDate, String LegalEntity, String CurrencyCode) {
            this.id = id;
            this.ItemID = ItemID;
            this.Price = Price;
            this.Quantity = Quantity;
            this.UnitID = UnitID;
            this.PriceDate = PriceDate;
            this.LegalEntity = LegalEntity;
            this.CurrencyCode = CurrencyCode;
        }
    }

    public class TradeAgreementPriceRequest {

        String ItemID;
        String PriceDate;
        String Quantity;
        String ModuleType;
        String UnitID;
        String LegalEntity;
        String CurrencyCode;
        String AccountNum;

        public TradeAgreementPriceRequest(String ItemID, String PriceDate, String Quantity, String ModuleType, String UnitID, String LegalEntity, String CurrencyCode, String AccountNum) {

            this.ItemID = ItemID;
            this.PriceDate = PriceDate;
            this.Quantity = Quantity;
            this.ModuleType = ModuleType;
            this.UnitID = UnitID;
            this.LegalEntity = LegalEntity;
            this.CurrencyCode = CurrencyCode;
            this.AccountNum = AccountNum;
        }
    }

    public class RMALineItem {
        Decimal LineNumber;
        String ItemNumber;
        String SFRecordID;
        Decimal ClaimPrice;
        Decimal RetailPrice;
        Decimal LineTaxAmount;
        Decimal LineLevelDiscount;
        String DispositionCode;
        String WarehouseLocation;
        String PDC;
        String SerialNumber;
        String Error;
        String D365RMANumber;
        String D365OrignalCreateDateTime;
        String D365ReturnSalesId;
        
        public void setScale(Integer scale) {
            this.ClaimPrice = (this.ClaimPrice != null ? this.ClaimPrice.setScale(scale) : null);
            this.RetailPrice = (this.RetailPrice != null ? this.RetailPrice.setScale(scale) : null);
            this.LineTaxAmount = (this.LineTaxAmount != null ? this.LineTaxAmount.setScale(scale) : null);
            this.LineLevelDiscount = (this.LineLevelDiscount != null ? this.LineLevelDiscount.setScale(scale) : null);
        }
    }

    public class RMARequest {
        String AccountNumber;
        String RMANumber;
        String RMAClaimDate;
        String LocationID;
        String OriginalSalesOrder;
        String ExternalClaimNumber;
        String CurrencyCode;
        String ReturnReasonCodeId;
        String Site;
        String WarehouseID;
        String RMAComplete;
        String RMACompleteNoLines;
        String LegalEntity;
        String SalesOrigin;
        String POType;
        List <RMALineItem> RMALineList;
        AddressCls BillToAddress;
        AddressCls ShipToAddress;
        
        public RMARequest() {
            this.Site = '1';
            this.SalesOrigin = 'SF';
            this.POType = 'RMA';
        }
    }
    
    public class AddressCls {
        String Address1;
        String Address2;
        String BillToCustomerNumber;
        String City;
        String Contact;
        String Country;
        String Email;
        String Name;
        String Phone;
        String PostalCode;
        String ShipToCode;
        String State;
    }
    
    public class ProcessRMAResponse {
        List<RMALineItem> RMAResponseLineList;
        String AccountNumber;
        String OriginalSalesOrder;
        String ExternalClaimNumber;
        String ImportDate;
        String RMANumber;
        String D365RMANumber;
        String D365ReturnSalesId;
        String WMSJournalId;
        String PackingSlipId;
        String InvoiceId;
        Decimal RMAComplete;
        Long D365RecId;
        String Error;
    }
    
    public class ProcessRMA implements Queueable, Database.AllowsCallouts {
        Set<Id> ids;
        Action act;
        
        public ProcessRMA(Set<Id> ids, Action act) {
            this.ids = ids;
            this.act = act;
        }
        
        public void execute(QueueableContext ctx) {
            switch on this.act {
                when CompleteRMA {
                    completeRMA(ids);
                }
                when else {
                    processRMA(ids);
                }
            }
        }
    }
}