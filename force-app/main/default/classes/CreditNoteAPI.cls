@RestResource(urlMapping='/CreditNoteService/*')
global without sharing class CreditNoteAPI {
    
   private static final String SALESORIGIN_SF = 'SF';
    
    global class RequestWrapper{
        global String PurchaseOrder;
        global String InvoiceNumber;
        global String RMANumber;
        global Decimal TotalInvoiceAmount;
        global String SalesOrigin;
        global String ConsumerOrder;
        global String D365OrderNumber;
        global String BusinessUnit;
    } 
    
    global class ResponseWrapper {
        public Boolean isSuccess;
        public String error;
        public ResponseWrapper(String error) {
            this.error = error;
            this.isSuccess = false;
        }
        public ResponseWrapper() {
            this.isSuccess = true;
        }
    }
    
    @HttpPost
    global static List<ResponseWrapper> doPost() {
        
        Datetime startTime = Datetime.now();
        String type = 'Success';
        
        RestRequest req = RestContext.request;
        List<RequestWrapper> requests = (List<RequestWrapper>) JSON.deserialize(req.requestBody.toString(), List<RequestWrapper>.class);
        System.debug(requests);
        
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        if (requests == null || requests.isEmpty()) {
            type = 'Fail';
            responses.add(new ResponseWrapper('Body cannot be empty.'));
        } else {
            responses = validateAndProcessRequest(requests);
        }
        
        Datetime endTime = Datetime.now();
        
        if (!Test.isRunningTest()) {
            postToSlack(requests, responses);
        }
        
        return responses;
    }
    
    private static List<ResponseWrapper> validateAndProcessRequest(List<RequestWrapper> requests) {
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        
        Set<String> rmaNumbers = new Set<String>();
        Set<String> orderIds = new Set<String>();
        Set<String> workOrderNumbers = new Set<String>();
        Set<String> purchaseOrders = new Set<String>();
        Map<String,Id> webID = new Map<String,Id>();
        Map<String, RequestWrapper> recordInvoiceMap = new Map<String, RequestWrapper>();
        
        for (RequestWrapper request : requests) {
            String uniqueWebOrderNumber = request.BusinessUnit.toUpperCase() + request.PurchaseOrder;
            ResponseWrapper response;
            if (String.isBlank(request.RMANumber) && String.isBlank(request.PurchaseOrder) ) {
                response = new ResponseWrapper('Please provide either Case Id or Order Id.');
            } else if (String.isBlank(request.InvoiceNumber)) {
                response = new ResponseWrapper('Invoice number is required.');
            } else {
                response = new ResponseWrapper();
                if (String.isNotBlank(request.RMANumber)) {
                    addToCollections(recordInvoiceMap, rmaNumbers, 'RMANumber', request.RMANumber, request);
                } else  if (String.isNotBlank(request.SalesOrigin)) {
                    if (request.SalesOrigin.equalsIgnoreCase(SALESORIGIN_SF) && String.isNotBlank(request.PurchaseOrder)
                        && request.PurchaseOrder.startsWith('WO')) {
                            addToCollections(recordInvoiceMap, workOrderNumbers, 'WorkOrder', request.PurchaseOrder, request);
                           } else if (request.SalesOrigin.equalsIgnoreCase(SALESORIGIN_SF)) {
                            if (!(request.PurchaseOrder instanceOf Id)) {
                                response = new ResponseWrapper('PurchaseOrder is an invalid Salesforce Id.');
                            } else {
                                addToCollections(recordInvoiceMap, orderIds, 'PurchaseOrder', request.PurchaseOrder, request);
                            }
                        } else {
                            if(String.isNotBlank(request.ConsumerOrder)){                        
                                if (!(request.ConsumerOrder instanceOf Id)) {
                                    response = new ResponseWrapper('ConsumerOrder is an invalid Salesforce Id.');
                                } else {
                                    addToCollections(recordInvoiceMap, orderIds, 'ConsumerOrder', request.ConsumerOrder, request);
                                   
                                }
                            }
                            else {
                                addToCollections(recordInvoiceMap, purchaseOrders, 'PurchaseOrder', uniqueWebOrderNumber, request);
                            }
                        }
                }
            }
            responses.add(response);
        }
        
        System.debug(JSON.serializePretty(requests));
        
        Map<Id, String> errorsMap = new Map<Id, String>();
        Map<String, Case> caseByRMANumber = new Map<String,Case>();
        Map<Id, Case> caseByIDs = new Map<Id,Case>();
        
        if (!rmaNumbers.isEmpty()) {
            caseByIDs = new Map<Id,Case>([SELECT Id, Case_Number_Ext__c, Status FROM Case WHERE Case_Number_Ext__c IN :rmaNumbers]);
            List<Case> casesToUpdate = new List<Case>();
            
            for (Case caseObj : caseByIDs.values()) {
                caseByRMANumber.put(caseObj.Case_Number_Ext__c, caseObj);
                if (recordInvoiceMap.containsKey(caseObj.Case_Number_Ext__c)) {
                    caseObj.Status = 'Closed';
                    RequestWrapper req = recordInvoiceMap.get(caseObj.Case_Number_Ext__c);
                    caseObj.InvoiceNumber__c = req.InvoiceNumber;
                    caseObj.Credit_Invoice_Amount__c = req.TotalInvoiceAmount;
                    caseObj.RMA_Status__c = 'Credit Complete';
                    casesToUpdate.add(caseObj);
                }
            }
            
            saveRecords(casesToUpdate, errorsMap);
        }
      Map<String, Order> uniqueWebOrderNumbers = new Map<String, Order>();
        Map<Id, Order> ordersByIds = new Map<Id,Order>();
        Map<Id, Set<Id>> orderItemIdsByOrderMap = new Map<Id, Set<Id>>();
        
                              
       
        if((orderIds.size()>0 && orderIds!= null) || (purchaseOrders.size()>0 && purchaseOrders!= null)) {
                        ordersByIds = new Map<Id, Order>([SELECT Id,OrderNumber, Magic_Order_ID__c, Status,WebSiteOrderNumber__c,WebSiteUniqueOrderNumber__c, (SELECT Id, LineStatus__c FROM OrderItems) FROM Order WHERE Id IN :orderIds OR WebSiteUniqueOrderNumber__c IN : purchaseOrders]);
                                
            List<Order> ordersToUpdate = new List<Order>();
            List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
            
            for (Order orderObj : ordersByIds.values()) {
                                     
                if (recordInvoiceMap.containsKey(orderObj.Id) || recordInvoiceMap.containsKey(orderObj.WebSiteUniqueOrderNumber__c)) {
                    RequestWrapper req = new RequestWrapper();
                                     
                    if(recordInvoiceMap.containsKey(orderObj.WebSiteUniqueOrderNumber__c)){
                       
                        webID.put(orderObj.WebSiteUniqueOrderNumber__c , orderObj.Id); 
                        req =recordInvoiceMap.get(orderObj.WebSiteUniqueOrderNumber__c);
                                          }
                    else{
                        req = recordInvoiceMap.get(orderObj.Id);
                    }
                        if (req != null) {
                            orderObj.AX_Order_ID__c = req.InvoiceNumber;
                            orderObj.TotalInvoiceAmount__c = req.TotalInvoiceAmount;
                            if (orderObj.Status.equalsIgnoreCase('Order Shipped')) {
                                orderObj.Status = 'Invoiced';
                            }
                            ordersToUpdate.add(orderObj);
                                                       
                            for (OrderItem orderItemObj : orderObj.OrderItems) {
                                OrderItem updatedOrderItem = new OrderItem(Id = orderItemObj.Id, ExternalInvoiceID__c = req.InvoiceNumber);
                                if (orderItemObj.LineStatus__c == 'Shipped') {
                                    updatedOrderItem.LineStatus__c = 'Invoiced';
                                }
                                orderItemsToUpdate.add(updatedOrderItem);
                            }
                            orderItemIdsByOrderMap.put(orderObj.Id, new Map<Id, OrderItem>(orderObj.OrderItems).keySet());
                        }
                    }
                }   
                
                saveRecords(ordersToUpdate, errorsMap);
                saveRecords(orderItemsToUpdate, errorsMap);
            }
            
            Map<String, WorkOrder> workOrdersByNumber = new Map<String, WorkOrder>();
            Map<Id, WorkOrder> workOrderByIds = new Map<Id,WorkOrder>();
            if (!workOrderNumbers.isEmpty()) {
                workOrderByIds = new Map<Id, WorkOrder>([SELECT Id, WorkOrderNumber FROM WorkOrder WHERE WorkOrderNumber IN :workOrderNumbers]);
                List<WorkOrder> wosToUpdate = new List<WorkOrder>();
                
                for (WorkOrder wo : workOrderByIds.values()) {
                    workOrdersByNumber.put(wo.WorkOrderNumber, wo);
                    if (recordInvoiceMap.containsKey(wo.WorkOrderNumber)) {
                        RequestWrapper req = recordInvoiceMap.get(wo.WorkOrderNumber);
                        wo.ExternalInvoiceId__c = req.InvoiceNumber;
                        wo.External_Order_Id__c = req.D365OrderNumber;
                        wosToUpdate.add(wo);
                    }
                }
                
                saveRecords(wosToUpdate, errorsMap);
            }
            
            for (Integer index = 0; index < responses.size(); index++) {
                RequestWrapper request = requests[index];
                ResponseWrapper response = responses[index];
                
                if (response.isSuccess) {
                    if (String.isNotBlank(request.RMANumber)) {
                        if ((String.isNotBlank(request.RMANumber) && !caseByRMANumber.containsKey(request.RMANumber))) {
                            response.isSuccess = false;
                            response.error = 'RMA record could not be found.';
                        } else {
                            Id caseId = caseByRMANumber.get(request.RMANumber).Id;
                            if (errorsMap.containsKey(caseId)) {
                                response.isSuccess = false;
                                response.error = errorsMap.get(caseId);
                            }
                        }
                    } else if (String.isNotBlank(request.SalesOrigin)) {
                        if (request.SalesOrigin.equalsIgnoreCase(SALESORIGIN_SF ) && String.isNotBlank(request.PurchaseOrder)
                        && request.PurchaseOrder.startsWith('WO')) {
                            if (!workOrdersByNumber.containsKey(request.PurchaseOrder)) {
                                    response.isSuccess = false;
                                    response.error = 'Work Order record could not be found.';
                                } else {
                                    Id woId = workOrdersByNumber.get(request.PurchaseOrder).Id;
                                    if (errorsMap.containsKey(woId)) {
                                        response.isSuccess = false;
                                        response.error = errorsMap.get(woId);
                                    }
                                }
                            } else if (!request.SalesOrigin.equalsIgnoreCase(SALESORIGIN_SF)) {
                           
                                String webSiteUniqueOrderNumber = request.BusinessUnit.toUpperCase() + request.PurchaseOrder;
                                String orderID = request.ConsumerOrder ;
                                if ( String.isNotBlank(orderID) ) {
                                    if (!ordersByIds.containsKey(orderID)) {
                                        response.isSuccess = false;
                                        response.error = 'Web Order record could not be found.';
                                        continue;
                                    }
                                } else if (!webId.containsKey(webSiteUniqueOrderNumber)) {
                                    response.isSuccess = false;
                                    response.error = 'Web Order record could not be found.';
                                    continue;
                                } else {
                                    orderID = webID.get(webSiteUniqueOrderNumber);
                                }
                                if (errorsMap.containsKey(orderID)) {
                                    response.isSuccess = false;
                                    response.error = errorsMap.get(orderID);
                                }
                            }
                        else {
                            String orderID = request.SalesOrigin == SALESORIGIN_SF ? request.PurchaseOrder : request.ConsumerOrder;
                            if ((String.isNotBlank(orderID) && !ordersByIds.containsKey(orderID))) {
                                response.isSuccess = false;
                                response.error = 'Order record could not be found.';
                            } else {
                                if (errorsMap.containsKey(orderId)) {
                                    response.isSuccess = false;
                                    response.error = errorsMap.get(orderId);
                                } else {
                                    for (Id orderItemId : orderItemIdsByOrderMap.get(orderId) ) {
                                        if (errorsMap.containsKey(orderItemId)) {
                                            response.isSuccess = false;
                                            response.error = errorsMap.get(orderItemId);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            return responses;
        }
        
        private static void saveRecords(List<Sobject> records,  Map<Id, String> errorsMap) {
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            dmlOption.OptAllOrNone = false;
            
            List<Database.SaveResult> results = Database.update(records, dmlOption);
            
            for (Integer index = 0; index < results.size(); index++) {
                Database.SaveResult result = results[index];
                if (!result.isSuccess()) {
                    SObject record = records[index];
                    String errorStr = '';
                    for (Database.Error error : result.getErrors()) {
                        errorStr +=  error.getFields() + ' ' + error.getStatusCode() + ' ' + error.getMessage() + ' ';
                    }
                    errorsMap.put(record.Id, errorStr);
                }
            }
            System.debug(errorsMap);
        }
        
        private static void addToCollections(Map<String, RequestWrapper> recordInvoiceMap, Set<String> dataSet, String param, String value, RequestWrapper request) {
            if (String.isNotBlank(value)) {
                dataSet.add(value);
                recordInvoiceMap.put(value, request);
            }
        }
        
        private static void postToSlack(List<RequestWrapper> requests, List<ResponseWrapper> responses) {
            SlackUtility.SlackPost post = new SlackUtility.SlackPost(true);
            if (requests == null || requests.isEmpty()) {
                post.isSuccess = false;
                post.text = 'Request body is empty.';
            } else {
                List<SlackUtility.SlackField> fields = new List<SlackUtility.SlackField>();
                for (Integer i = 0; i < requests.size(); i++) {
                    RequestWrapper request = requests[i];
                    ResponseWrapper response = responses[i];
                    if (post.isSuccess && response.isSuccess == false) {
                        post.isSuccess = false;
                    }
                    fields.add(
                        new SlackUtility.SlackField(JSON.serialize(request), JSON.serialize(response))
                    );
                }
                post.fields = fields;
            }
            SlackUtility.postToSlack('X810', post);
        }
    }