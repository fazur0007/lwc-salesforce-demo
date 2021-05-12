@isTest(SeeAllData=false)

public with sharing class AttachmentTriggerHandlerTest 
{
     /*static void Utility()
       {
            Test.starttest();
            String region = Utility.regionBased('USD');
            System.assertEquals('USA',region);
            Test.stoptest();
                
        }*/
        
       static testMethod void testsendAttachemntToS3()
        {   
            Test.setMock(HttpCalloutMock.class, new MockCreateContentResponder());
            
            Test.starttest();
            DataCreationUtility.DataCreate(); 
            List<Attachment> attachmentList = [select Id from Attachment];
            Test.stoptest();
            
            System.assertEquals(0,[select count() from Attachment]);
            System.assertEquals(1,[select count() from Knowledge_Base__c]);
        }
        
        static testMethod void testSendAttachmentLimitError()
        {   
            DataCreationUtility.DataCreate(); 
            List<Attachment> attachmenttest = [Select Id,Name, Parentid from Attachment];
            List<EmailMessage> Email = [Select Id, ParentId From EmailMessage where Id=:attachmenttest[0].Parentid];
            map<Id, Id> emailMessageIdToAttachment = new Map<Id, Id>();
            emailMessageIdToAttachment.put(Email[0].Id,Email[0].ParentId);
            
            Test.starttest();
            AttachmentTriggerHandler.sendAttachmentLimitError(attachmenttest,emailMessageIdToAttachment);
            System.assertEquals(0,[select count() from Attachment]);
            Test.stoptest();
        }
        
         static testMethod void testAssociateAttachmentMultiCarrier(){
        	
        	Test.setMock(HttpCalloutMock.class, new MockCreateContentResponder());
        	
        	//Insert Account    		
		 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
	        insert objAcc;
        	
        	//Insert Contact
       		 Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
             
        	RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
            Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
	        caseObj.RecordTypeId = recordTypeRecord.id;
	        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
	        caseObj.Purchase_Invoice_No__c = 'TT01' ;
	        caseObj.currencyISOCode='USD';
	        caseObj.ContactId=contactObj.Id;
	        caseObj.Service_Center__c=null;
	        caseObj.Product__c=null;
            caseObj.Shipment_Email_Sent__c=false;
	        insert caseObj;
	        
	        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
	        objProd.CurrencyIsoCode = 'USD';
	        objProd.Serviceable__c = true;
	        insert objProd;  
	        
	        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        workOrderObj.CaseId = caseObj.id;
	        insert workOrderObj;
	        
	        
	        zkmulti__MCShipment__c objzkupsMCShipmentc = new zkmulti__MCShipment__c();
	        objzkupsMCShipmentc.zkmulti__Recipient_Company__c='abc';
	        objzkupsMCShipmentc.zkmulti__Recipient_Phone__c='1254345121';
	        objzkupsMCShipmentc.zkmulti__Recipient_Street__c='pune';
	        objzkupsMCShipmentc.zkmulti__Recipient_State_Province__c='maha';
	        objzkupsMCShipmentc.zkmulti__Recipient_Country__c='india';
	        objzkupsMCShipmentc.zkmulti__Recipient_City__c='pune';
	        objzkupsMCShipmentc.zkmulti__Recipient_Zip_Postal_Code__c='424306';
	        objzkupsMCShipmentc.zkmulti__Weight_Units__c='45';
	        objzkupsMCShipmentc.zkmulti__Return_Shipment__c =true;
	        objzkupsMCShipmentc.Case__c = caseObj.id;
	        objzkupsMCShipmentc.zkmulti__Status_Description__c = 'TestStatus';
	        objzkupsMCShipmentc.zkmulti__Tracking_Number__c = 'TestMaster';
	        objzkupsMCShipmentc.WorkOrder__c = workOrderObj.id;
	        objzkupsMCShipmentc.zkmulti__Label_Image_Type__c = 'PNG';
	        insert objzkupsMCShipmentc;
	        
	        
	        DataCreationUtility.DataCreate(); 
            
            String text = 'Random Text';
            Blob body = Blob.valueOf(text);
            
            Attachment attachment = new Attachment();
            attachment.Name = 'Attachment';
            attachment.Parentid = objzkupsMCShipmentc.id;
            attachment.Body = body;
            insert attachment;
            
            List<Attachment> attachmenttest = [Select Id,Name, Parentid,Body,BodyLength from Attachment where Parentid=:objzkupsMCShipmentc.id];
	        
	        Test.starttest();
            AttachmentTriggerHandler.associateAttachmentToCaseOrWorkOrder(attachmenttest);
            
            Task task = AttachmentTriggerHandler.createTask(objAcc.Id, contactObj.Id, attachment.id, 'Call','USD', 'In Warranty', 'R1000101010', 'NameTest','streettest',
            			'citytest','statetest', '445001', '9873785465', 'testname@example.com','testname@example.com','Breville','Authorizes Service Center', 'Fedex');
            Test.stoptest();
        	
        }
    
    	static testMethod void testAssociateAttachmentUPS(){
        	
        	Test.setMock(HttpCalloutMock.class, new MockCreateContentResponder());
        	
        	//Insert Account    		
		 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
	        insert objAcc;
        	
        	//Insert Contact
       		 Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        	RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
            Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
	        caseObj.RecordTypeId = recordTypeRecord.id;
	        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
	        caseObj.Purchase_Invoice_No__c = 'TT01' ;
	        caseObj.currencyISOCode='USD';
	        caseObj.ContactId=contactObj.Id;
	        caseObj.Service_Center__c=null;
	        caseObj.Product__c=null;
            caseObj.Shipment_Email_Sent__c=false;
	        insert caseObj;
	        
	        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
	        objProd.CurrencyIsoCode = 'USD';
	        objProd.Serviceable__c = true;
	        insert objProd;  
	        
	        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        workOrderObj.CaseId = caseObj.id;
	        insert workOrderObj;
	        
	        
	        zkups__UPSShipment__c objzkUpsShipment = new zkups__UPSShipment__c();
	        objzkUpsShipment.zkups__RecipientCompany__c='abc';
	        objzkUpsShipment.zkups__RecipientPhone__c='1254345121';
	        objzkUpsShipment.zkups__RecipientStreet__c='pune';
	        objzkUpsShipment.zkups__RecipientState__c='maha';
	        objzkUpsShipment.zkups__RecipientCountry__c='india';
	        objzkUpsShipment.zkups__RecipientCity__c='pune';
	        objzkUpsShipment.zkups__RecipientState__c='424306';
	        objzkUpsShipment.zkups__WeightUnits__c='45';
	        objzkUpsShipment.zkups__SsProcessReturnShipment__c =false;
	        objzkUpsShipment.Case__c = caseObj.id;
	        objzkUpsShipment.zkups__StatusDescription__c = 'TestStatus';
	        objzkUpsShipment.zkups__MasterTrackingId__c = 'TestMaster';
	        objzkUpsShipment.WorkOrder__c = workOrderObj.id;
	        objzkUpsShipment.zkups__LabelImageType__c = 'PNG';
	        insert objzkUpsShipment;
	        
	        
	        DataCreationUtility.DataCreate(); 
            
            String text = 'Random Text';
            Blob body = Blob.valueOf(text);
            
            Attachment attachment = new Attachment();
            attachment.Name = 'Attachment';
            attachment.Parentid = objzkUpsShipment.id;
            attachment.Body = body;
            insert attachment;
            
            List<Attachment> attachmenttest = [Select Id,Name, Parentid,Body,BodyLength from Attachment where Parentid=:objzkUpsShipment.id];
	        
	        Test.starttest();
            AttachmentTriggerHandler.associateAttachmentToCaseOrWorkOrder(attachmenttest);
            
            Task task = AttachmentTriggerHandler.createTask(objAcc.Id, contactObj.Id, attachment.id, 'Call','USD', 'In Warranty', 'R1000101010', 'NameTest','streettest',
            			'citytest','statetest', '445001', '9873785465', 'testname@example.com','testname@example.com','Breville','Authorizes Service Center', 'Fedex');
            Test.stoptest();
        	
        }
        
    	static testMethod void testAssociateAttachmentFedex(){
        	
        	Test.setMock(HttpCalloutMock.class, new MockCreateContentResponder());
        	
        	//Insert Account    		
		 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
	        insert objAcc;
        	
        	//Insert Contact
       		 Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
            
        	RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='New Case'];
            Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
	        caseObj.RecordTypeId = recordTypeRecord.id;
	        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
	        caseObj.Purchase_Invoice_No__c = 'TT01' ;
	        caseObj.currencyISOCode='USD';
	        caseObj.ContactId=contactObj.Id;
	        caseObj.Service_Center__c=null;
	        caseObj.Product__c=null;
	        insert caseObj;
	        
	        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
	        objProd.CurrencyIsoCode = 'USD';
	        objProd.Serviceable__c = true;
	        insert objProd;  
	        
	        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'USD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        workOrderObj.CaseId = caseObj.id;
	        insert workOrderObj;
	        
	        
	        zkfedex__Shipment__c objzkFedexShipment = new zkfedex__Shipment__c();
	        objzkFedexShipment.zkfedex__RecipientCompany__c='abc';
	        objzkFedexShipment.zkfedex__RecipientPhone__c='1254345121';
	        objzkFedexShipment.zkfedex__RecipientStreet__c='pune';
	        objzkFedexShipment.zkfedex__RecipientState__c='maha';
	        objzkFedexShipment.zkfedex__RecipientCountry__c='india';
	        objzkFedexShipment.zkfedex__RecipientCity__c='pune';
	        objzkFedexShipment.zkfedex__RecipientPostalCode__c='424306';
	        objzkFedexShipment.zkfedex__WeightUnits__c='45';
	        objzkFedexShipment.zkfedex__SsProcessReturnShipment__c =true;
	        objzkFedexShipment.Case__c = caseObj.id;
	        objzkFedexShipment.zkfedex__StatusDescription__c = 'TestStatus';
	        objzkFedexShipment.zkfedex__MasterTrackingId__c = 'TestMaster';
	        objzkFedexShipment.WorkOrder__c = workOrderObj.id;
	        objzkFedexShipment.zkfedex__LabelImageType__c = 'PNG';
	        insert objzkFedexShipment;
	        
	        
	        DataCreationUtility.DataCreate(); 
            
            String text = 'Random Text';
            Blob body = Blob.valueOf(text);
            
            Attachment attachment = new Attachment();
            attachment.Name = 'Attachment';
            attachment.Parentid = objzkFedexShipment.id;
            attachment.Body = body;
            insert attachment;
            
            List<Attachment> attachmenttest = [Select Id,Name, Parentid,Body,BodyLength from Attachment where Parentid=:objzkFedexShipment.id];
	        
	        Test.starttest();
            AttachmentTriggerHandler.associateAttachmentToCaseOrWorkOrder(attachmenttest);
            
            Task task = AttachmentTriggerHandler.createTask(objAcc.Id, contactObj.Id, attachment.id, 'Call','USD', 'In Warranty', 'R1000101010', 'NameTest','streettest',
            			'citytest','statetest', '445001', '9873785465', 'testname@example.com','testname@example.com','Breville','Authorizes Service Center', 'Fedex');
            Test.stoptest();
        	
        }
        static testMethod void testAssociateAttachment1(){
        	
        	Test.setMock(HttpCalloutMock.class, new MockCreateContentResponder());
        	
        	//Insert Account    		
		 	Account objAcc = TestDataFactory.createAccountRecord('Account1', 'BUS', 'test@email.com', '123456');
	        insert objAcc;
        	
        	//Insert Contact
       		 Contact contactObj = TestDataFactory.createContact(objAcc.Id, 'testLastName', true);
        
        	RecordType recordTypeRecord = [SELECT id, Name, SobjectType FROM RecordType WHERE SobjectType='Case' AND Name='RMA'];
            Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false);  
	        caseObj.RecordTypeId = recordTypeRecord.id;
	        caseObj.RMAStatus__c = 'Scheduled For Label Generation';
	        caseObj.Purchase_Invoice_No__c = 'TT01' ;
	        caseObj.currencyISOCode = 'AUD';
	        caseObj.Country__c = 'AUS';
	        caseObj.ContactId=contactObj.Id;
	        caseObj.Service_Center__c=null;
	        caseObj.Product__c=null;
	        insert caseObj;
	        
	        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
	        objProd.CurrencyIsoCode = 'AUD';
	        objProd.Serviceable__c = true;
	        objProd.Brand__c = 'Breville';
	        insert objProd;  
	        
	        WorkOrder workOrderObj = TestDataFactory.createWorkOrder('1234', 'AUD', false);
	        workOrderObj.Product__c = objProd.id;
	        workOrderObj.BatchCode__c = '1234';
	        workOrderObj.PurchaseDate__c = Date.today();
	        workOrderObj.CaseNumber__c = '461346';
	        workOrderObj.FirstName__c = 'Joe';
	        workOrderObj.LastName__c = 'John';
	        workOrderObj.Email__c = 'John@gmail.com';
	        workOrderObj.CaseId = caseObj.id;
	        insert workOrderObj;
	        
	        
	        zkmulti__MCShipment__c objzkupsMCShipmentc = new zkmulti__MCShipment__c();
	        objzkupsMCShipmentc.zkmulti__Recipient_Company__c='abc';
	        objzkupsMCShipmentc.zkmulti__Recipient_Phone__c='1254345121';
	        objzkupsMCShipmentc.zkmulti__Recipient_Street__c='pune';
	        objzkupsMCShipmentc.zkmulti__Recipient_State_Province__c='maha';
	        objzkupsMCShipmentc.zkmulti__Recipient_Country__c='india';
	        objzkupsMCShipmentc.zkmulti__Recipient_City__c='pune';
	        objzkupsMCShipmentc.zkmulti__Recipient_Zip_Postal_Code__c='424306';
	        objzkupsMCShipmentc.zkmulti__Weight_Units__c='45';
	        objzkupsMCShipmentc.zkmulti__Return_Shipment__c =true;
	        objzkupsMCShipmentc.Case__c = caseObj.id;
	        objzkupsMCShipmentc.zkmulti__Status_Description__c = 'TestStatus';
	        objzkupsMCShipmentc.zkmulti__Tracking_Number__c = 'TestMaster';
	        objzkupsMCShipmentc.WorkOrder__c = workOrderObj.id;
	        objzkupsMCShipmentc.zkmulti__Label_Image_Type__c = 'PDF';
	        insert objzkupsMCShipmentc;
	        
	       
	        DataCreationUtility.DataCreate(); 
            
            String text = 'Random Text';
            Blob body = Blob.valueOf(text);
            
            Attachment attachment = new Attachment();
            attachment.Name = 'Attachment';
            attachment.Parentid = objzkupsMCShipmentc.id;
            attachment.Body = body;
            insert attachment;
            
            List<Attachment> attachmenttest = [Select Id,Name, Parentid,Body,BodyLength from Attachment where Parentid=:objzkupsMCShipmentc.id];
	        
	        Test.starttest();
            AttachmentTriggerHandler.associateAttachmentToCaseOrWorkOrder(attachmenttest);
	      
            Task task = AttachmentTriggerHandler.createTask(objAcc.Id, contactObj.Id, attachment.id, 'Call','USD','In Warranty', 'R1000101010', 'NameTest','streettest',
            			'citytest','statetest', '445001', '9873785465', 'testname@example.com','testname@example.com','Breville','Authorize Service Center', 'Fedex');
            Test.stoptest();
        	
        }
        
        
        class MockCreateContentResponder implements HttpCalloutMock 
        {
            public HttpResponse respond(HttpRequest request) 
            {
                HttpResponse response = new HttpResponse();
                response.setHeader('Etag','akdfa6a6adfafdafdadf5655afdaf');
                response.setHeader('key','test/test2');
                response.setStatusCode(200);
                return response;
            }
        }
        
    }