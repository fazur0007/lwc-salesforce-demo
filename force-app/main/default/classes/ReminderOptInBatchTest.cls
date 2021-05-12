/**
* This is the text class for ReminderOptInBatch
* @author deepak_tomar@persistent.com
* @version 1.0
* @since April 17, 2018
*/

@isTest
public class ReminderOptInBatchTest {
    
    @testsetup
    static void setup(){
        createAccount('ABC', 'abc@example.com');
    }

    public static void createAccount(String lname, String email){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = lname;
        record.firstName = 'firstName';
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = email;
        record.TerritoryAssigned__c = false;
        record.SendNLReminderEmail__c = false;
        record.Subscribe_to_our_newsletter__c = false;
        record.MkgOptEmailSent__c = System.Now().addDays(-7);

        insert record;
    }

    static testMethod void ReminderOptInBatch(){
        Test.startTest();
        //ReminderOptInBatch batch = new ReminderOptInBatch();
        Id batchId = Database.executeBatch(new ReminderOptInBatch('USD'));
        Test.stopTest();
        
        Account acc = [SELECT Id, SendNLReminderEmail__c 
                        FROM Account 
                        WHERE Subscribe_to_our_newsletter__c = false 
                        AND MkgOptEmailSent__c = N_DAYS_AGO:7
                        LIMIT 1];
        
        System.assertEquals(acc.SendNLReminderEmail__c, true);
    }

    static testmethod void schedulableBatchTest() {
        Test.startTest();
        ReminderOptInBatch batch = new ReminderOptInBatch('USD');
        String jobID = System.schedule('Schedule for all records Test ' + System.now(), '0 0 15 * * ?', batch);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
    /*static testmethod void scheduleBatchTest() {
        Test.startTest();
        ReminderOptInBatch.scheduleBatch();
        Test.stopTest();
    }*/
}