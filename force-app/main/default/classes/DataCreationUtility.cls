public with sharing class DataCreationUtility
{ 
    public static void DataCreate()
    { 
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Case testCase = new Case();
        testCase.Status = 'Open';
        testCase.AccountId = testAccount.Id;
        insert testcase; 
        
        EmailMessage testEmailMessage = new EmailMessage();
        testEmailMessage.ParentId = testCase.Id;
        insert testEmailMessage;
        
        Attachment testattach = new Attachment(); 
        testattach.ParentId= testEmailMessage.Id;
        testattach.Name ='Amazon.txt'; 
        Blob bodyBlob=Blob.valueOf('Amazon.txt'); 
        testattach.body=bodyBlob; 
        testattach.ContentType = 'application/msword'; 
        testattach.IsPrivate = false; 
        testattach.Description = 'Test'; 
        insert testattach;
    

    }
}