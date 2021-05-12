public class AccountDeDuplicateProcess {
       
    static Map<String, Merged_Account__c> emailMergedAccountMap = new Map<String, Merged_Account__c>();
    static final String ONE_RECORD_HAS_CHILDREN = '1 Record has children and others do not have children - Record With Children';
    static final String MANY_RECORDS_HAS_CHILDREN = 
        'Multiple records have children - Latest Modified Record or Record with Latest Modified Children';
    static final String SINGLE_RECORD_WITH_CHILDREN = 'Single Record with Children';
    static final String RECORDS_WITHOUT_CHILDREN = 'No Record has Children';

    static final Integer ASSET_PRIORITY = 1;
    static final Integer ORDER_PRIORITY = 2;
    static final Integer WORK_ORDER_PRIORITY = 3;
    static final Integer CASE_PRIORITY = 4;
    static final Integer ACCOUNT_NAME_PRIORITY = 5;
    static final Integer ACCOUNT_ADDRESS_PRIORITY = 6;
    static final Integer ACCOUNT_PHONE_PRIORITY = 7;
    static final Integer ACCOUNT_LAST_MODIFIED_DATE_PRIORITY = 8;
    static Boolean MERGE_DUPLICATE_ACCOUNTS = false; 
   
    @TestVisible
    private static void mergeRecords (Merged_Account__c recMergeAccount, 
                                      Account master, List<Account> duplicateRecords)
    {
        Account masterRec = new Account();
        masterRec.Id = master.Id;
        System.debug ('Master Account: ' + recMergeAccount.Email__c);

        Integer loopCount = (Integer) Math.ceil(duplicateRecords.size()/2.0);
        for (Integer i = 0; i < loopCount; i++) {
            // Merge can happen only on 3 records - start
            List<Account> recordsTobeProcessed = new List<Account>();
      if (duplicateRecords.size() > 0)
                recordsTobeProcessed.add(duplicateRecords.remove(0));
            if (duplicateRecords.size() > 0)
                recordsTobeProcessed.add(duplicateRecords.remove(0));
            // Merge can happen only on 3 records - End
            try {
                List<Database.MergeResult> mergeResults = Database.merge(masterRec, recordsTobeProcessed, true);
                String mergeRecordIds = '';
                String relatedRecordIds = '';
                Integer successRecordCount = 0;
                String errorMessage;
                for (Database.MergeResult res: mergeResults)
                {
//                    System.debug ('MergeResult: ' + res);
                    for (String mergeRecordId : res.getMergedRecordIds())
                        mergeRecordIds += mergeRecordId + ',';
                    for (String relatedRecordId : res.getUpdatedRelatedIds())
                        relatedRecordIds += relatedRecordId + ',';
                    if (res.getErrors() != null)
                    {
                        for (Database.Error err : res.getErrors())
                        {
                            if (String.isBlank(errorMessage))
                                errorMessage += err.getStatusCode() + '||' + err.getMessage();
                            else
                                errorMessage += '\n' + err.getStatusCode() + '||' + err.getMessage();
                        }
                    }
                    if (res.isSuccess())
                        successRecordCount++;
                }
                if (mergeRecordIds.length() > 0)
                {
                    String recMergeRecordIds = '';
                    if (i > 0)
                        recMergeRecordIds = recMergeAccount.Duplicate_Account_Ids__c;
                    recMergeRecordIds += mergeRecordIds;
                    if (recMergeRecordIds.length() > 2048)
                        recMergeAccount.Duplicate_Account_Ids__c = recMergeRecordIds.left(2048);
                    else
                        recMergeAccount.Duplicate_Account_Ids__c = recMergeRecordIds;
                }
                if (relatedRecordIds.length() > 0)
                {
                    String recRelatedRecordIds = '';
                    if (i > 0)
                        recRelatedRecordIds = recMergeAccount.Related_Record_Ids__c;
                    recRelatedRecordIds += relatedRecordIds;
                    
                    if (recRelatedRecordIds.length() > 2048)
                        recMergeAccount.Related_Record_Ids__c = recRelatedRecordIds.left(2048);
                    else
                        recMergeAccount.Related_Record_Ids__c = recRelatedRecordIds;
                }
                if (String.isNotBlank(errorMessage)) {
                    String recErrorMessage = '';
                    if (i > 0)
                        recErrorMessage = recMergeAccount.Merge_Error_Message__c;
                    recErrorMessage += errorMessage;
                    recMergeAccount.Merge_Error_Message__c = recErrorMessage;
                }
                String recMergeStatus = '';
                if (i > 0) 
                    recMergeStatus = recMergeAccount.Merge_Status__c;
                if (successRecordCount == mergeResults.size()) {
                    if (String.isBlank (recMergeStatus) || 
                        (String.isNotBlank (recMergeStatus) && recMergeStatus.equalsIgnoreCase('Success')))
                      recMergeAccount.Merge_Status__c = 'Success';
                    else
                        recMergeAccount.Merge_Status__c = 'Partial Error';
                }
                else if (successRecordCount == 0) {
                    if (String.isBlank (recMergeStatus) || 
                        (String.isNotBlank (recMergeStatus) && recMergeStatus.equalsIgnoreCase('Error')))
                      recMergeAccount.Merge_Status__c = 'Error';
                    else
                        recMergeAccount.Merge_Status__c = 'Partial Error';
                }
                else 
                    recMergeAccount.Merge_Status__c = 'Partial Error';
            } catch (Exception ex)
            {
                System.debug ('Exception: ' + ex.getMessage()); 
                recMergeAccount.Merge_Status__c = 'Error';
                String errorMessage = ex.getLineNumber() + '||' + ex.getTypeName() + '||' + 
                        ex.getCause() + '||' + ex.getMessage() + '||\n' + ex.getStackTraceString();
                if (i > 0) {
                    String recErrorMessage = recMergeAccount.Merge_Error_Message__c + errorMessage;
                    if (recErrorMessage.length() > 512)
                        recMergeAccount.Merge_Error_Message__c = recErrorMessage.left(512);
                    else
                        recMergeAccount.Merge_Error_Message__c = recErrorMessage; 
                } else {
                    if (errorMessage.length() > 512)
                      recMergeAccount.Merge_Error_Message__c = errorMessage.left(512);
                    else
                        recMergeAccount.Merge_Error_Message__c = errorMessage; 
                }
            }
        }
        System.debug ('recMergeAccount: ' + recMergeAccount);
        return;
    }
    
    private static void mergeAccountRecords (Merged_Account__c recMergeAccount, 
                                             AccountPriorityData masterAccountData,
                                             List<Account> duplicateAccountsWithNoChildren, 
                                             List<Account> duplicateAccountsWithChildren)
    {
        if ((duplicateAccountsWithChildren == null || duplicateAccountsWithChildren.isEmpty()) &&
            (duplicateAccountsWithNoChildren == null || duplicateAccountsWithNoChildren.isEmpty()))
        {
            recMergeAccount.Merge_Warning_Message__c = SINGLE_RECORD_WITH_CHILDREN;
            recMergeAccount.Merge_Status__c = 'Skipped';
            recMergeAccount.Master_Account_Id__c = masterAccountData.account.Id;
        }
        else {
            if (duplicateAccountsWithChildren == null || duplicateAccountsWithChildren.isEmpty())
            {
                if (masterAccountData.priority < ACCOUNT_NAME_PRIORITY)
                  recMergeAccount.Master_Record_Chosen_Reason__c = ONE_RECORD_HAS_CHILDREN;
                else
                    recMergeAccount.Master_Record_Chosen_Reason__c = RECORDS_WITHOUT_CHILDREN;
            }
            else {
                recMergeAccount.Master_Record_Chosen_Reason__c = MANY_RECORDS_HAS_CHILDREN;
            }
            List<Account> duplicateAccounts = new List<Account>();
            if(!duplicateAccountsWithChildren.isEmpty())
                duplicateAccounts.addAll(duplicateAccountsWithChildren);
            if(!duplicateAccountsWithNoChildren.isEmpty())
                duplicateAccounts.addAll(duplicateAccountsWithNoChildren);
            if (Test.isRunningTest() || MERGE_DUPLICATE_ACCOUNTS)
	            mergeRecords (recMergeAccount, masterAccountData.account, duplicateAccounts);
        }
    }
    
    public static void execute (List<Merged_Account__c> recList) {

        for (Merged_Account__c rec: recList)
        {
            emailMergedAccountMap.put(rec.Email__c, rec);
        }
        System.debug ('RecList: ' + recList);
        List<String> businessUnitList = new List<String>();
        
        for (Customer_Community_Settings__mdt config:
        	 [SELECT Id, Label, DeveloperName, Value__c from Customer_Community_Settings__mdt 
                  WHERE DeveloperName IN ('DeDuplication_Business_Unit_List', 'Merge_Duplicate_Accounts')])
        {
            if (config == null || String.isBlank(config.Value__c))
                continue;
            if (config.DeveloperName.equalsIgnoreCase ('DeDuplication_Business_Unit_List'))
            	businessUnitList.addAll(config.Value__c.split(','));
            else if (config.Value__c.equalsIgnoreCase('TRUE'))
                MERGE_DUPLICATE_ACCOUNTS = true;
        }
        
        if (Test.isRunningTest() || businessUnitList.isEmpty())
            businessUnitList.add('BUS');
            
        AccountPriorityData masterAccountPriorityData;
        List<Account> duplicateAccountsWithNoChildren = new List<Account>();
        List<Account> duplicateAccountsWithChildren = new List<Account>();
        List<Merged_Account_Data__c> mergeAccountDataList = new List<Merged_Account_Data__c>();
        String prevEmail;
       
        for (Account acct: 
             [SELECT CurrencyIsoCode, Id, LastModifiedDate, Owner.UserName, PersonEmail, CreatedBy.UserName, 
              LastModifiedBy.Username, FirstName, LastName, BillingStreet, BillingPostalCode, Phone,
              (Select Id, LastModifiedDate from Cases), (Select Id, LastModifiedDate from Orders), 
              (Select Id,LastModifiedDate from Assets), (Select Id, LastModifiedDate from WorkOrders),
              (Select Id from Users) 
              FROM Account WHERE PersonEmail =: emailMergedAccountMap.keySet() AND BusinessUnitFormula__c =: businessUnitList
              ORDER by PersonEmail ASC, LastModifiedDate DESC])
        {
            System.debug (acct.PersonEmail + ': ' + acct);
            if (prevEmail != null && !prevEmail.equalsIgnoreCase(acct.PersonEmail))
            {
                mergeAccountRecords (emailMergedAccountMap.get(prevEmail), masterAccountPriorityData, 
                                     duplicateAccountsWithNoChildren, duplicateAccountsWithChildren);
                Merged_Account__c recMergeAccount = emailMergedAccountMap.get(prevEmail);
                recMergeAccount.Processed__c = true;
                recMergeAccount.Master_Account_Id__c = masterAccountPriorityData.account.Id;
                recMergeAccount.Master_Record_Chosen_Priority__c = masterAccountPriorityData.priority;
                masterAccountPriorityData = null;
                duplicateAccountsWithNoChildren.clear();
                duplicateAccountsWithChildren.clear();
//                mergeAccountDataList.clear();
            }
      
            AccountPriorityData currAccountPriorityData = getPriorityDataforAccount (acct);
            currAccountPriorityData.data.Merged_Account__c = emailMergedAccountMap.get(acct.PersonEmail).Id;
            mergeAccountDataList.add(currAccountPriorityData.data);
            
            prevEmail = acct.PersonEmail;
            
            if (currAccountPriorityData.data.Has_Community_User__c)
                continue;

            Integer currAccountPriority = currAccountPriorityData.priority;
            sObject currAccountChildData = currAccountPriorityData.priorityChild;
            
            if (masterAccountPriorityData == null)
            {
                masterAccountPriorityData = new AccountPriorityData();
                masterAccountPriorityData.account = acct;
                masterAccountPriorityData.priority = currAccountPriority;
                masterAccountPriorityData.priorityChild = currAccountChildData;
                continue;
            }

            sObject masterAccountChildData = masterAccountPriorityData.priorityChild;
            
            if (currAccountPriority >= ACCOUNT_NAME_PRIORITY)
            {
                if (masterAccountPriorityData.priority < currAccountPriority ||
                    (masterAccountPriorityData.priority == currAccountPriority && 
                     masterAccountPriorityData.account.LastModifiedDate >= acct.LastModifiedDate))
                {
                    duplicateAccountsWithNoChildren.add(acct);
                }
                else
                {
                    duplicateAccountsWithNoChildren.add(masterAccountPriorityData.account);
                    masterAccountPriorityData.account = acct;
                    masterAccountPriorityData.priority = currAccountPriority;
                    masterAccountPriorityData.priorityChild = currAccountChildData;
                    
                }
            }
            else {
        DateTime currAccountPriorityChildLastModifiedDate, masterAccountPriorityChildLastModifiedDate;
                if (currAccountChildData != null)
                  currAccountPriorityChildLastModifiedDate = (DateTime) currAccountChildData.get('LastModifiedDate');
                if (masterAccountChildData != null)
                  masterAccountPriorityChildLastModifiedDate = (DateTime) masterAccountChildData.get('LastModifiedDate');                
                
                if (masterAccountPriorityData.priority < currAccountPriority || 
                    (masterAccountPriorityData.priority == currAccountPriority && 
                     masterAccountPriorityChildLastModifiedDate != null &&
                     masterAccountPriorityChildLastModifiedDate >= currAccountPriorityChildLastModifiedDate))
                {
                    duplicateAccountsWithChildren.add(acct);
                }
                else
                {
                    duplicateAccountsWithChildren.add(masterAccountPriorityData.account);
//                    masterAccountPriorityData = currAccountPriorityData;
                    masterAccountPriorityData.account = acct;
                    masterAccountPriorityData.priority = currAccountPriority;
                    masterAccountPriorityData.priorityChild = currAccountChildData;
                }
            }
        }
        
        Merged_Account__c recMergeAccount = emailMergedAccountMap.get(prevEmail);
        mergeAccountRecords (emailMergedAccountMap.get(prevEmail), masterAccountPriorityData, 
                             duplicateAccountsWithNoChildren, duplicateAccountsWithChildren);

        recMergeAccount.Processed__c = true;
        recMergeAccount.Master_Account_Id__c = masterAccountPriorityData.account.Id;
        recMergeAccount.Master_Record_Chosen_Priority__c = masterAccountPriorityData.priority;
    insert mergeAccountDataList;
        update emailMergedAccountMap.values();
    }
    
    class AccountPriorityData 
    {
        public Integer priority {get;set;}
        public Account account {get;set;}
        public sObject priorityChild {get;set;}
        public Merged_Account_Data__c data {get;set;}
    }
    
    private static sObject getLatestModifiedData (List<sObject> recList) {
    sObject priorityRecord;
    DateTime latestModifiedDate = null;
        for (sObject rec : recList)
        {
            DateTime recLastModifiedDate = (DateTime) rec.get('LastModifiedDate');
            if (latestModifiedDate == null || latestModifiedDate < recLastModifiedDate)
            {
                latestModifiedDate = recLastModifiedDate;
                priorityRecord = rec;
            }
        }
        return priorityRecord; 
    }
    
    private static DateTime getLastModifiedDate (sObject record)
    {
        DateTime LastModifiedDate = (DateTime) record.get('LastModifiedDate');
        return LastModifiedDate;
    }
    
    private static AccountPriorityData getPriorityDataforAccount (Account acct) {
        AccountPriorityData data = new AccountPriorityData();
        List<Case> cases = acct.Cases;
        List<Order> orders = acct.Orders;
        List<Asset> assets = acct.Assets;
        List<WorkOrder> workOrders = acct.WorkOrders;
        List<User> users = acct.Users;
        Merged_Account_Data__c accountData = new Merged_Account_Data__c();

        accountData.Asset_Count__c = assets.size();
        accountData.Order_Count__c = orders.size();
        accountData.WorkOrder_Count__c = workOrders.size();
        accountData.Case_Count__c = cases.size();
        accountData.Account_ID__c = acct.Id;
        accountData.Account_Last_Modified_Date__c = acct.LastModifiedDate;
        accountData.Has_Community_User__c = users.size() > 0;
        
        if (assets.size () > 0)
        {
            data.priority = ASSET_PRIORITY;
            data.priorityChild = getLatestModifiedData (assets);
            accountData.Asset_s_Latest_Modified_Date__c = getLastModifiedDate(data.priorityChild);
        }
        if (orders.size () > 0)
        {
            sObject orderData = getLatestModifiedData (orders);
            if (data.priority == null)
            {
              data.priority = ORDER_PRIORITY;
                data.priorityChild = orderData;
            }
            accountData.Order_s_Latest_Modified_Date__c = getLastModifiedDate(orderData);
        }
        if (workOrders.size () > 0)
        {
            sObject workOrderData = getLatestModifiedData (workOrders);
            if (data.priority == null)
            {
              data.priority = WORK_ORDER_PRIORITY;
                data.priorityChild = workOrderData;
            }
            accountData.WorkOrder_s_Latest_Modified_Date__c = getLastModifiedDate(workOrderData);
        }
        if (cases.size () > 0)
        {
            sObject caseData = getLatestModifiedData (cases);
            if (data.priority == null)
            {
              data.priority = CASE_PRIORITY;
                data.priorityChild = caseData;
            }
            accountData.Case_s_Latest_Modified_Date__c = getLastModifiedDate(caseData);
        }

        if (String.isNotBlank(acct.BillingStreet) && String.isNotBlank(acct.BillingPostalCode))
        {
            data.priority = data.priority == null ? ACCOUNT_ADDRESS_PRIORITY : data.priority;
            accountData.Billing_Address_Populated__c = true;
        }
        
        if (String.isNotBlank(acct.Phone))
        {
            accountData.Phone_Populated__c = true;
            data.priority = data.priority == null ? ACCOUNT_PHONE_PRIORITY : data.priority;
        }

        data.priority = data.priority == null ? ACCOUNT_LAST_MODIFIED_DATE_PRIORITY : data.priority;
        accountData.Account_Priority__c = data.priority;
        data.data = accountData;
        System.debug ('Account Priority Data: ' + data); 
        return data;
    }
}