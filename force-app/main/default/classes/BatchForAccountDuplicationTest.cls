@isTest
public class BatchForAccountDuplicationTest {
    static testMethod void testBatchForAccountDuplication(){
        
        
        //Insert Account            
        Account objAcc = TestDataFactory.createAccountRecord('firstName','lastName', true);
        objAcc.firstName = 'firstName1';
        objAcc.PersonEmail = 'PersonEmail@x.com';
        objAcc.Phone = '12356';
        objAcc.DataAreaID__c='BUS';
        //objAcc.LastModifiedDate = Datetime.now();
        upsert objAcc;
        
        Test.startTest();
        Id batchInstanceId = Database.executeBatch(new BatchForAccountDuplication(), 200);
       
		System.debug(batchInstanceId);
		//System.abortJob(batchInstanceId);
        Test.stopTest();
    }
}