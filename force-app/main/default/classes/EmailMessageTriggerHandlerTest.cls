@isTest(SeeAllData = true)
public with sharing class EmailMessageTriggerHandlerTest {
	
	static testMethod void testMethodEmailMessageTriggerHandler(){
		
		//Insert Account   
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        //Insert Case   
        Case testCase = new Case();
        testCase.Status = 'Open';
        testCase.AccountId = testAccount.Id;
        testCase.RecordTypeId = caseRmaRecordTypeId;
        testCase.currencyISOcode = 'USD';
        testCase.Country__c = 'USA';
        insert testcase; 
        
        
        //Insert EmailMessage   
        EmailMessage testEmailMessage = new EmailMessage();
        testEmailMessage.ParentId = testCase.Id;
        testEmailMessage.FromAddress = 'test@Example.com';
        testEmailMessage.Incoming = true;
        testEmailMessage.ToAddress= 'askus@brevilleusa.com' ;
        testEmailMessage.Subject = null;
        testEmailMessage.TextBody =null;
        testEmailMessage.HtmlBody = null;
        insert testEmailMessage;
        
}

static testMethod void testMethodEmailMessageTriggerHandler1(){
		
		//Insert Account   
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        //Insert Case   
        Case testCase = new Case();
        testCase.Status = 'Open';
        testCase.AccountId = testAccount.Id;
        testCase.RecordTypeId = caseRmaRecordTypeId;
        testCase.currencyISOcode = 'CAD';
        testCase.Country__c = 'CAN';
        insert testcase; 
        
        
        //Insert EmailMessage   
        EmailMessage testEmailMessage = new EmailMessage();
        testEmailMessage.ParentId = testCase.Id;
        testEmailMessage.FromAddress = 'test@abc.org';
        testEmailMessage.Incoming = true;
        testEmailMessage.ToAddress= 'askus@brevilleusa.com' ;
        testEmailMessage.Subject = null;
        testEmailMessage.TextBody =null;
        testEmailMessage.HtmlBody = null;
        insert testEmailMessage;
        
}
		static testMethod void testMethod1(){
				
				//Insert Account   
				Account testAccount = new Account();
		        testAccount.Name = 'Test Account';
		        insert testAccount;
		        
		        //Insert Case   
		        Case testCase = new Case();
		        testCase.Status = 'Open';
		        testCase.AccountId = testAccount.Id;
		        insert testcase; 
		        
		        //Insert EmailMessage   
		        
		        EmailMessage testEmailMessage1 = new EmailMessage();
		        testEmailMessage1.ParentId = testCase.Id;
		        testEmailMessage1.FromAddress = 'test@abc.org';
		        testEmailMessage1.Incoming = true;
		        testEmailMessage1.ToAddress= 'askus@brevilleusa.com' ;
		        testEmailMessage1.Subject = 'ref:_';
		        testEmailMessage1.TextBody =null;
		        testEmailMessage1.HtmlBody = null;
		        insert testEmailMessage1;
		        
		}
		
		static testMethod void testMethod2(){
		
		//Insert Account   
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
         Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        //Insert Case   
        Case testCase = new Case();
        testCase.Status = 'Open';
        testCase.AccountId = testAccount.Id;
        testCase.RecordTypeId = caseRmaRecordTypeId;
        testCase.currencyISOcode = 'USD';
        testCase.Country__c = 'USA';
        insert testcase; 
        
        //Insert EmailMessage   
        
        EmailMessage testEmailMessage2 = new EmailMessage();
        testEmailMessage2.ParentId = testCase.Id;
        testEmailMessage2.FromAddress = 'test@abc.org';
        testEmailMessage2.Incoming = true;
        testEmailMessage2.ToAddress= 'askus@brevilleusa.com' ;
        testEmailMessage2.Subject = null;
        testEmailMessage2.TextBody ='ref:_';
        testEmailMessage2.HtmlBody = null;
        insert testEmailMessage2;
			
		}		
		static testMethod void testMethod3(){
		
		//Insert Account   
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
         Id caseRmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
        
        //Insert Case   
        Case testCase = new Case();
        testCase.Status = 'Open';
        testCase.AccountId = testAccount.Id;
        testCase.RecordTypeId = caseRmaRecordTypeId;
        testCase.currencyISOcode = 'USD';
        testCase.Country__c = 'USA';
        insert testcase; 
        
        //Insert EmailMessage   
        
        EmailMessage testEmailMessage3 = new EmailMessage();
        testEmailMessage3.ParentId = testCase.Id;
        testEmailMessage3.FromAddress = 'test@abc.org';
        testEmailMessage3.Incoming = false;
        testEmailMessage3.ToAddress= 'askus@brevilleusa.com' ;
        testEmailMessage3.Subject = null;
        testEmailMessage3.TextBody =null;
        testEmailMessage3.HtmlBody = 'ref:_';
        insert testEmailMessage3;
		}
}