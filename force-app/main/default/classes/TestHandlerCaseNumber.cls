@isTest

private class TestHandlerCaseNumber 
{
	static Attachment objAttachment;
	static Case objCase;
	static HandlerCaseNumber objHandlerCaseNumber;
    private static Attachment  myUnitTest() 
    {
        Pagereference pageref =  page.CaseNumber;
        test.setCurrentPage(pageref);
        
        objHandlerCaseNumber = new HandlerCaseNumber();
        objHandlerCaseNumber.resultFileSize = 0;
        //objHandlerCaseNumber.searchCase();
        
        Account objAccount = new Account();
        objAccount.LastName = 'Biraris';
        insert objAccount;
        
        Product2 objProduct = new Product2();
        objProduct.SKU__c = '.004-300040';
        objProduct.Name = 'Test Product';
        objProduct.Description ='Test des';
        objProduct.Breville_US_Product__c =  true;
        insert objProduct;
        
        RecordType objrecordType = [Select IsActive,SobjectType, 
                                           Id,DeveloperName 
                                    From RecordType 
                                    where DeveloperName=: 'New_Case' AND IsActive =: true AND SobjectType =: 'Case'];
        
        list<case> lstCase = new list<case>();
        
        objCase = new Case();
        objCase.RecordTypeId =objrecordType.Id;

        objCase.Status = 'Open';
        objCase.Origin = 'Wnb Inquiry';
        objCase.Type = 'Order Issue';
        objCase.AccountId = objAccount.Id;
        objCase.Complaint_Code__c = 'Questions & Feedback';
        objCase.Sub_Complaint_Code__c = 'Other';
        objCase.Subject = 'Unique Subject';
        objCase.Product__c = objProduct.Id;
        lstCase.add(objCase);
        if(lstCase.size() > 0 && lstCase != null)
        {
            insert lstCase;
        }
        
        system.debug('!!!!!!!!!lstCase'+lstCase);
        Case objectCase = [Select Subject, 
                                Product__r.Description, 
                                CaseNumber, 
                                Account.Name, 
                                AccountId 
                                From Case 
                                WHERE Subject =: 'Unique Subject'];
      
        system.debug('!!@objectCase'+objectCase);
         
         
                                
        objHandlerCaseNumber.caseNumber = objectCase.CaseNumber;
         
        objHandlerCaseNumber.blnIsShow = true;
        objHandlerCaseNumber.searchCase();
        objHandlerCaseNumber.strAccountId = objAccount.LastName;
        objHandlerCaseNumber.strProduct = objProduct.Description;
        objHandlerCaseNumber.strCaseNumber = objCase.CaseNumber;
        objHandlerCaseNumber.strSubject = objCase.Subject;
         
        list<Attachment> lstCaseAttachment = new list<Attachment>();  
        objAttachment = new Attachment();
        //objHandlerCaseNumber.osize = 153000;
        //objHandlerCaseNumber.Upload();
        objAttachment.Body =blob.valueOf('MyOver');
        objAttachment.Name = 'Test Att';
        objAttachment.ParentId = objCase.id;
        lstCaseAttachment.add(objAttachment);
        if(lstCaseAttachment.size() > 0 && lstCaseAttachment != null)
        {
            insert lstCaseAttachment;
        }
        objHandlerCaseNumber.blnIsAttach = false;
        objHandlerCaseNumber.blnIsSucess = true;
       //insert lstCaseAttachment;
        objHandlerCaseNumber.Upload();
        
        List<Attachment> attachments=[select id, name from Attachment where ParentId=:objCase.id];
        
        objHandlerCaseNumber.strComment = 'abc';
        CaseComment objCaseComment = new CaseComment();
        objCaseComment.CommentBody =  objHandlerCaseNumber.strComment;
        objCaseComment.ParentId = objCase.id; 
        insert objCaseComment;
        //objHandlerCaseNumber.searchCase();
        
        objHandlerCaseNumber.blnIsSucess = true;
        objHandlerCaseNumber.blnIsAttach = true;
        objAttachment = new Attachment();
        objAttachment.Body =blob.valueOf('MyOver');
        objAttachment.Name = 'Test Att';
        objAttachment.ParentId = objCase.id;
        objHandlerCaseNumber.resultFileSize= 1;
        objHandlerCaseNumber.Upload();
        
        objHandlerCaseNumber.blnIsShow= false;
        objHandlerCaseNumber.blnIsSucess = true;
        objHandlerCaseNumber.blnSubmit = false; 
        objHandlerCaseNumber.submitCase();
        
        objHandlerCaseNumber.blnSubmit = true; 
        objHandlerCaseNumber.submitCase();
        objHandlerCaseNumber.blnIsAttach = false;
        objHandlerCaseNumber.submitSaveAndAddAttachment();
        
        
        return objAttachment;
    }
       static  testMethod void anotherCondition()  
       {
       	    myUnitTest();
			//HandlerCaseNumber objHandlerCaseNumber = new HandlerCaseNumber();
			system.debug('!!!!!!!!!objCase'+objCase);
			string caseNumberWOBVL;
			if(objHandlerCaseNumber.caseNumber != '')
			{
	         string caseNumber = objHandlerCaseNumber.caseNumber;
	         system.debug('!!!!!!!!!!!!!caseNumber'+caseNumber);
	         if(caseNumber.contains('BVL'))
	         {
	            caseNumberWOBVL = caseNumber.remove('BVL-');
	         }
			objHandlerCaseNumber.caseNumber = '';
			objHandlerCaseNumber.blnIsShow = true;
			objHandlerCaseNumber.searchCase();
         
			objHandlerCaseNumber.blnIsSucess = true;
			objHandlerCaseNumber.submitCase();
						        
			objHandlerCaseNumber.blnIsAttach = true;
			objHandlerCaseNumber.Upload();
			objHandlerCaseNumber.blnIsShow= false;
			objHandlerCaseNumber.blnIsSucess = true;
			objHandlerCaseNumber.blnSubmit = false; 
						        
			objHandlerCaseNumber.submitSaveAndAddAttachment();
						        
			objHandlerCaseNumber.caseNumber = caseNumberWOBVL;
			objHandlerCaseNumber.blnIsShow = true;
			objHandlerCaseNumber.searchCase();
			 
			objHandlerCaseNumber.blnIsSucess = true;
			objHandlerCaseNumber.blnIsAttach = true;
			objHandlerCaseNumber.Upload();
						        
			objHandlerCaseNumber.blnIsShow= false;
			objHandlerCaseNumber.blnIsSucess = true;
			objHandlerCaseNumber.blnSubmit = false; 
			objHandlerCaseNumber.submitCase();
			objHandlerCaseNumber.submitSaveAndAddAttachment();
						        
						        
			objHandlerCaseNumber.caseNumber = caseNumberWOBVL;
			objHandlerCaseNumber.blnIsShow = true;
			objHandlerCaseNumber.searchCase();
						         
			objHandlerCaseNumber.blnIsSucess = true;
			objHandlerCaseNumber.blnIsAttach = true;
			objHandlerCaseNumber.Upload();
						        
			objHandlerCaseNumber.blnIsShow= false;
			objHandlerCaseNumber.blnIsSucess = true;
			objHandlerCaseNumber.blnSubmit = false; 
			objHandlerCaseNumber.submitCase();
			objHandlerCaseNumber.submitSaveAndAddAttachment();
			
			String caseNumberAppended = '100'+caseNumberWOBVL;			        
			objHandlerCaseNumber.caseNumber = caseNumberAppended;
			objHandlerCaseNumber.blnIsShow = false;
			objHandlerCaseNumber.searchCase();
			
			String caseNumberWOBVLSTR;
	         if(caseNumber.contains('BVL'))
	         {
	            caseNumberWOBVLSTR = caseNumber.remove('BVL-00');
	         }
	         
	         objHandlerCaseNumber.caseNumber = caseNumberWOBVLSTR;
	         objHandlerCaseNumber.blnIsShow= false;
	         objHandlerCaseNumber.searchCase();
			}
    }
    static  testMethod void falseCondition()  
       {
         myUnitTest();
     
         //HandlerCaseNumber objHandlerCaseNumber = new HandlerCaseNumber();
         objHandlerCaseNumber.caseNumber = '';
         objHandlerCaseNumber.searchCase();

         objHandlerCaseNumber.caseNumber = objHandlerCaseNumber.caseNumber;
         objHandlerCaseNumber.searchCase();
         
         objHandlerCaseNumber.caseNumber = objHandlerCaseNumber.caseNumber;
         objHandlerCaseNumber.submitCase();
         
         objHandlerCaseNumber.caseNumber = '';
         objHandlerCaseNumber.submitCase();
         
         
         objHandlerCaseNumber.caseNumber = '';
         objHandlerCaseNumber.submitSaveAndAddAttachment();
         
         objHandlerCaseNumber.blnIsShow= true;
          objHandlerCaseNumber.strComment = '';
         objHandlerCaseNumber.submitCase();
         
         objHandlerCaseNumber.blnIsShow= true;
          objHandlerCaseNumber.strComment = '';
         objHandlerCaseNumber.submitSaveAndAddAttachment();
         
         system.debug('!!!!!!!!!!!objHandlerCaseNumber.caseNumber'+objHandlerCaseNumber.caseNumber);
         if(objHandlerCaseNumber.caseNumber != '')
         {
         string caseNumberWOBVL;
         string caseNumber = objHandlerCaseNumber.caseNumber;
         system.debug('***********caseNumber'+caseNumber);
         if(caseNumber.contains('BVL'))
         {
         	caseNumberWOBVL = caseNumber.remove('BVL-');
         }
          objHandlerCaseNumber.caseNumber = caseNumberWOBVL;
           objHandlerCaseNumber.blnIsShow= false;
         objHandlerCaseNumber.searchCase();
         
         String caseNumberAppended = '100'+caseNumberWOBVL;
         objHandlerCaseNumber.caseNumber = caseNumberAppended;
         objHandlerCaseNumber.blnIsShow= false;
         objHandlerCaseNumber.searchCase();
         
         objHandlerCaseNumber.caseNumber = objHandlerCaseNumber.caseNumber;
         objHandlerCaseNumber.blnIsShow= false;
         objHandlerCaseNumber.searchCase();
         
         String caseNumberWOBVLSTR;
         if(caseNumber.contains('BVL'))
         {
            caseNumberWOBVLSTR = caseNumber.remove('BVL-00');
         }
         
         objHandlerCaseNumber.caseNumber = caseNumberWOBVLSTR;
         objHandlerCaseNumber.blnIsShow= false;
         objHandlerCaseNumber.searchCase();
         }
          objAttachment.Body =blob.valueOf('');
	      objAttachment.Name = '';
	      objHandlerCaseNumber.Upload();
        
    }
    
    static testMethod void testMethod1(){
    	Pagereference pageref =  page.CaseNumber; 
        test.setCurrentPage(pageref);
        
        objHandlerCaseNumber = new HandlerCaseNumber();
        objHandlerCaseNumber.resultFileSize = 0;
                                
        objHandlerCaseNumber.caseNumber = 'BVL-00667170';
        objHandlerCaseNumber.searchCase();
        
        objHandlerCaseNumber.caseNumber = 'R10000';
        objHandlerCaseNumber.searchCase();
        
        objHandlerCaseNumber.caseNumber = null;
        objHandlerCaseNumber.searchCase();
        
        objHandlerCaseNumber.blnIsShow = false;
        PageReference pg =  objHandlerCaseNumber.submitSaveAndAddAttachment();
        
        objHandlerCaseNumber.blnIsShow = true;
        objHandlerCaseNumber.strComment = '';
        PageReference pg1 =  objHandlerCaseNumber.submitSaveAndAddAttachment();
    }
    
    static testmethod void test()
    {
        Account objAccount = new Account();
        objAccount.LastName = 'Biraris';
        insert objAccount;
        
        Product2 objProduct = new Product2();
        objProduct.SKU__c = '.004-300040';
        objProduct.Name = 'Test Product';
        objProduct.Description ='Test des';
        objProduct.Breville_US_Product__c =  true;
        insert objProduct;
        
        RecordType objrecordType = [Select IsActive,SobjectType, 
                                           Id,DeveloperName 
                                    From RecordType 
                                    where DeveloperName=: 'New_Case' AND IsActive =: true AND SobjectType =: 'Case'];
        
        list<case> lstCase = new list<case>();
        
        objCase = new Case();
        objCase.RecordTypeId =objrecordType.Id;

        objCase.Status = 'Open';
        objCase.Origin = 'Wnb Inquiry';
        objCase.Type = 'Order Issue';
        objCase.AccountId = objAccount.Id;
        objCase.Complaint_Code__c = 'Questions & Feedback';
        objCase.Sub_Complaint_Code__c = 'Other';
        objCase.Subject = 'Unique Subject';
        objCase.Product__c = objProduct.Id;
       
        insert ObjCase;
        
        
        Case caseRec = [select id, CaseNumber from case where id = :ObjCase.Id];
        system.debug('!!!!!!!!!lstCase'+caseRec.CaseNumber);
        objHandlerCaseNumber = new HandlerCaseNumber();
        objHandlerCaseNumber.caseNumber = caseRec.CaseNumber;
        objHandlerCaseNumber.searchCase();
        
        objHandlerCaseNumber = new HandlerCaseNumber();
        objHandlerCaseNumber.caseNumber = '00667170';
        objHandlerCaseNumber.searchCase();

        
    }
    
}