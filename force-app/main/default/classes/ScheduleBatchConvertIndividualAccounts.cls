global class ScheduleBatchConvertIndividualAccounts{
/* implements Schedulable {
    global Boolean apexTestMode = false;
    global void execute(SchedulableContext sc) {
        
        BatchConvertIndividualAccounts b = new BatchConvertIndividualAccounts(this.apexTestMode);
        Database.executeBatch(b);
    }
    
    
    private static testMethod void testBatchConvertIndividualAccounts() {
        Account account;
        Contact contact;
        
        Contact[] contacts = [Select id from Contact where lastname like 'ApexConvert%' ];
        if (contacts.size() > 0) delete contacts;
        Account[] accounts = [Select id from Account where name like '%ApexConvert%' ];
        if (accounts.size() > 0) delete accounts;
        
        account = new Account(
                    Name = 'Merge1 ApexConvertToPersonAccountTest',
                    pymt__Convert_To_Person_Account__c = true 
                     );
        insert account;
        
        contact = new Contact( 
                    FirstName = 'Merge1',
                    LastName = 'ApexConvertToPersonAccountTest',
                    email = 'merge1@apextest.com',
                    AccountId = account.Id
                     );
        insert contact;

        // Account with no contact
        account = new Account(
                    Name = 'Merge2 ApexConvertToPersonAccountTest',
                    pymt__Convert_To_Person_Account__c = true 
                     );
        insert account;
                
        // Account with error from previous run
        account = new Account(
                    Name = 'Merge3 ApexConvertToPersonAccountTest',
                    pymt__Convert_To_Person_Account__c = true ,
                    Conversion_Attempt__c = 'ERROR_DURING_UPDATE'                   
                     );
        insert account;
        contact = new Contact( 
                    FirstName = 'Merge3',
                    LastName = 'ApexConvertToPersonAccountTest',
                    email = 'merge1@apextest.com',
                    AccountId = account.Id
                     );
        insert contact;
                        
        Test.startTest();
            String scheduledTime = '0 0 0 3 9 ? '+ String.valueOf(Date.today().addYears(1).year());
            
            // Schedule the test job
            ScheduleBatchConvertIndividualAccounts job = new ScheduleBatchConvertIndividualAccounts();
            job.apexTestMode = true;            
            String jobId = System.schedule('testBatchConvertIndividualAccounts', scheduledTime, job);
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger WHERE id = :jobId];
            System.assert(ct.TimesTriggered ==0, 'Expected to find batch job queued but not yet triggered');
        
        Test.stopTest();
            
    
    }   */
}