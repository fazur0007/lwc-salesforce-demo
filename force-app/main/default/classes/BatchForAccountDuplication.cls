global class BatchForAccountDuplication implements Database.Batchable<sObject>{
    DateTime lastCheckDate;
    
    //constructor to get last check date from metadata
    global BatchForAccountDuplication(){
       List<All_Literal__mdt> literalList = [select Value__c from All_Literal__mdt where DeveloperName='LastCheckDate' LIMIT 1];
            if(literalList != null)
                lastCheckDate = DateTime.valueOf(literalList.get(0).Value__c);
            System.debug(lastCheckDate);
       }
    
    /*
    global void execute(SchedulableContext SC){
        Database.executeBatch(new BatchForAccountDuplication(), 5);
    }
    */
   
   //start method to return new account list  
   global Database.QueryLocator start(Database.BatchableContext BC){
       String query='select id,firstName,lastName,PersonEmail,CreatedDate,Phone from Account where LastModifiedDate >:lastCheckDate';
       return Database.getQueryLocator(query);
   }
   
   //execute method of batch that will insert duplicates record into Duplicate Account object.
   global void execute(Database.BatchableContext BC,List<Account> newAccountsList){
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<String> mobileSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Map<String,Account> oldAccountsMap = new Map<String,Account>();
        List<DuplicateAccount__c> duplicateAccountsList = new List<DuplicateAccount__c>();
        
        //to get sets of all the FirstName, LastName, Email and Mobile of New Accounts
        for(Account newAccount : newAccountsList){
            String key='';
            if(newAccount.firstName != null && newAccount.firstName != '')
                firstNameSet.add(newAccount.firstName);
            if(newAccount.lastName != null && newAccount.lastName != '')
                lastNameSet.add(newAccount.lastName);
            if(newAccount.Phone != null && newAccount.Phone != '')
                mobileSet.add(newAccount.Phone);
            if(newAccount.PersonEmail != null && newAccount.PersonEmail != '')
                emailSet.add(newAccount.PersonEmail);
        }
        
        //to get old accounts having firstName,lastName,PersonEmail,CreatedDate,Phone in Sets of New Accounts
        List<Account> oldAccountsList = [select id,
                                                firstName,
                                                lastName,
                                                PersonEmail,
                                                CreatedDate,
                                                Phone 
                                        from Account 
                                        where CreatedDate <:lastCheckDate OR
                                                firstName IN :firstNameSet OR
                                                lastName IN :lastNameSet OR
                                                Phone IN :mobileSet OR
                                                PersonEmail IN :emailSet order by CreatedDate desc];

       if(oldAccountsList != null){
        
            //Map having key as String(firstName+lastName+mobile+email) and Account as value
            for(Account oldAccount : oldAccountsList){
                String key='';
                if(oldAccount.firstName != null && oldAccount.firstName != '')
                    key += oldAccount.firstName;
                if(oldAccount.lastName != null && oldAccount.lastName != '')
                    key += oldAccount.lastName;
                if(oldAccount.Phone != null && oldAccount.Phone != '')
                    key += oldAccount.Phone;
                if(oldAccount.PersonEmail != null && oldAccount.PersonEmail != '')
                    key += oldAccount.PersonEmail;
                oldAccountsMap.put(key,oldAccount); 
            }
            
            //to check whether new account is duplicate or not.
            for(Account newAccount : newAccountsList){
                String key='';
                if(newAccount.firstName != null && newAccount.firstName != '')
                    key += newAccount.firstName;
                if(newAccount.lastName != null && newAccount.lastName != '')
                    key += newAccount.lastName;
                if(newAccount.Phone != null && newAccount.Phone != '')
                    key += newAccount.Phone;
                if(newAccount.PersonEmail != null && newAccount.PersonEmail != '')
                    key += newAccount.PersonEmail;
                    
                if(oldAccountsMap.containsKey(key) && oldAccountsMap.get(key).id != newAccount.id){
                    DuplicateAccount__c duplicateAccount = new DuplicateAccount__c();
                    duplicateAccount.Account__c = newAccount.id;
                    duplicateAccount.MasterAccount__c = oldAccountsMap.get(key).id;
                    duplicateAccountsList.add(duplicateAccount);
                }    
            }
            
            //inserting duplicate accounts
            if(duplicateAccountsList.size()>0){
                try{
                    insert duplicateAccountsList;
                }catch(DMLException e){
                    ErrorLog.logErrorActivity(e,'problem in inserting duplicate accounts',true,'Error');
                }
            }
        }
   }
 
   global void finish(Database.BatchableContext BC){
        /*
        literal.Value__c = DateTime.now();
        update literal;
        */
   }
    //end of class
}