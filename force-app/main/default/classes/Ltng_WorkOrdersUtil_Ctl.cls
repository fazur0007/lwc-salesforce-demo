public class Ltng_WorkOrdersUtil_Ctl {
    @AuraEnabled
    public static String activateWorkOrder(String recordId) {
        String successorErrorMessage = '';
        try {
            WorkOrder workOrderRec = [Select Id, AmountPayablebyCustomer__c, CC_Authorization_ID__c, Activated__c, ServiceType__c From WorkOrder Where Id =: recordId];
            User usr = [SELECT Id, IsPortalEnabled FROM User where Id =: UserInfo.getUserId()];
            if (usr.IsPortalEnabled || workOrderRec.AmountPayablebyCustomer__c == 0 || (!usr.IsPortalEnabled && workOrderRec.AmountPayablebyCustomer__c > 0 && workOrderRec.CC_Authorization_ID__c != null && workOrderRec.CC_Authorization_ID__c != '')) {
                system.debug('workOrderRec.ServiceType__c:'+ workOrderRec.ServiceType__c);
                if (string.IsBlank(workOrderRec.ServiceType__c)) {
                    successorErrorMessage = 'Please Select Service Type before activating';
                }
                else {
                    update new WorkOrder(
                        Id = recordId,
                        Activated__c = true
                    );
                    successorErrorMessage = 'success';
                }
            }
            else {
                successorErrorMessage = 'Payment is required on this Work Order';
            }

        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return successorErrorMessage;
    }
    @AuraEnabled
    public static Map < String, Object > sendQuote(String recordId) {
        Map < String, Object > maoOfObjects = new Map < String, Object > ();

        WorkOrder workOrderRec;
        boolean isReturnBoxNeeded;
        maoOfObjects.put('createReturnLabel', 'No');
        maoOfObjects.put('createBoxOrder', 'No');
        maoOfObjects.put('hidePanels', true);
        maoOfObjects.put('createOrderPanel', false);
        maoOfObjects.put('quoteSent', false);

        if (!Test.isRunningTest()) {
            workOrderRec = [Select Id, AccountId, Account.PersonEmail, ContactId, IsCalculated__c, Email__c, Product__r.Service_Return_Box__c
                from WorkOrder Where Id =: recordId limit 1
            ];
        }
        else {
            workOrderRec = [Select Id, AccountId, Account.PersonEmail, ContactId, IsCalculated__c, Email__c, Product__r.Service_Return_Box__c
                from WorkOrder limit 1
            ];
        }
        maoOfObjects.put('workOrderRec', workOrderRec);
        if (workOrderRec.Product__r.Service_Return_Box__c != null) {
            isReturnBoxNeeded = true;
        }
        else {
            isReturnBoxNeeded = false;
        }
        maoOfObjects.put('isReturnBoxNeeded', isReturnBoxNeeded);
        return maoOfObjects;
    }
    public static void sendQuoteUtil(String createReturnLabel, WorkOrder workOrderRec) {
        Boolean hasError = false;
        if (!hasError) {
            //workOrderRec.Email__c = null;

            if (workOrderRec.AccountId != null && !String.isBlank(workOrderRec.Account.PersonEmail)) {
                workOrderRec.Email__c = workOrderRec.Account.PersonEmail;
            }
            else if (workOrderRec.ContactId != null && workOrderRec.Contact.Email != null) {
                workOrderRec.Email__c = workOrderRec.Contact.Email;
            }

            if (string.IsBlank(workOrderRec.Email__c)) {
                throw new AuraHandledException(System.Label.Send_Quote_Pop_Up_Email_Message);
            }
            ChargentPaymentTerminalExtn ChargentPaymentTerminalExtnInstance = new ChargentPaymentTerminalExtn(workOrderRec.Id);
            ChargentOrders__ChargentOrder__c newChargentOrder = ChargentPaymentTerminalExtnInstance.chargentOrder;
            //newChargentOrder.ChargentOrders__Gateway__c='a1o290000005gV4';
            insert newChargentOrder;

            ChargentOrders__Payment_Request__c newPaymentRequest = new ChargentOrders__Payment_Request__c();
            newPaymentRequest.ChargentOrders__Payment_Request_Transaction_Type__c = Label.Payment_Request_Type;
            newPaymentRequest.ChargentOrders__Billing_Contact__c = workOrderRec.ContactId;
            newPaymentRequest.ChargentOrders__ChargentOrder__c = newChargentOrder.Id;
            insert newPaymentRequest;

            if (createReturnLabel.equalsIgnoreCase('Yes')) {
                workOrderRec.AutoReturnLabelStatus__c = 'Scheduled';
            }

            workOrderRec.PaymentId__c = newPaymentRequest.Id;
            workOrderRec.Send_Quote__c = true;
        }
    }
    @AuraEnabled
    public static Map < String, Object > submitResponse(String recordId, String createReturnLabel, String createBoxOrder, Boolean createOrderPanel, Boolean quoteSent, Boolean hidePanels) {
        
        try {
            Map < String, Object > maoOfObjects = new Map < String, Object > ();
            WorkOrder workOrderRec = [Select Id, AccountId, Account.PersonEmail, ContactId, IsCalculated__c, Email__c,
                Product__r.Service_Return_Box__c,CreateBoxOrder__c
                from WorkOrder Where Id =: recordId limit 1
            ];        
            sendQuoteUtil(createReturnLabel, workOrderRec);
            if (createBoxOrder == 'Yes') {
                workOrderRec.CreateBoxOrder__c = true;
            }
            update workOrderRec;
            maoOfObjects.put('createReturnLabel', 'No');
            maoOfObjects.put('createBoxOrder', 'No');
            maoOfObjects.put('hidePanels', false);
            maoOfObjects.put('createOrderPanel', false);
            maoOfObjects.put('quoteSent', true);
            maoOfObjects.put('workOrderRec', workOrderRec);
            return maoOfObjects;
        }catch (Exception ex) {            
            ErrorLog.LogErrorActivity(ex, 'Send Quote', true, 'SendQuoteOnWorkOrderController Error', null, recordId, null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static String submitforWorkOrderApproval(String recordId){
        try{
            update new WorkOrder (
                Id = recordId,
                Activated__c = true
            );
        return 'Success';
        }Catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}