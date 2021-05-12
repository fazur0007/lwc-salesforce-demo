@isTest
public class WebToCaseControllerWebTest {
	static testMethod void testMethodWebToCaseControllerPositiveTest(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'en-US' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.dummyAccount.FirstName = 'Joe';
		        webToCaseControllerObj.dummyAccount.LastName = 'Bob';
		        webToCaseControllerObj.dummyAccount.BillingStreet = '123 test st';
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
        		webToCaseControllerObj.dummyAccount.BillingCity = 'Denver';
		        webToCaseControllerObj.dummyAccount.BillingPostalCode = '80002';
		        webToCaseControllerObj.dummyAccount.PersonEmail = 'test@example.com';
		        webToCaseControllerObj.dummyAccount.BillingCountryCode = 'US';
		        webToCaseControllerObj.dummyAccount.BillingStateCode = 'CA';
		        
       			//webToCaseControllerObj.acct.BillingStateCode = 'CA';
				//webToCaseControllerObj.acct.BillingCountryCode = 'US';
		       // webToCaseControllerObj.acct.BillingStateCode = '440012';
		        webToCaseControllerObj.dummyAccount.Phone = '9999999999';
		        webToCaseControllerObj.confirmEmail = 'test@example.com';
		        webToCaseControllerObj.selectedSubCategory = 'I dont see my product';
		        webToCaseControllerObj.objCase.Batch_Code__c = '1720';
		        webToCaseControllerObj.objCase.Purchased_From__c = 'test';
		        webToCaseControllerObj.objCase.Purchase_Date__c = date.today();
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = 'Original_PO_CASE_del__c';
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Support & Service';
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        
        		//webToCaseControllerObj.validateCountry();
		        webToCaseControllerObj.registrationSave();
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
    
   static testMethod void testMethodWebToCaseControllerMissingFieldsTest(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'en-US' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
        		webToCaseControllerObj.dummyAccount.BillingCountryCode = 'US';
		        PageReference p = webToCaseControllerObj.registrationSave();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(null, p);
	}
	
	
	static testMethod void testMethod1(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'en-US' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		       WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.acct.FirstName = 'Joe';
		        webToCaseControllerObj.acct.LastName = 'Bob';
		        webToCaseControllerObj.acct.BillingStreet = null;
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj.acct.BillingCity = '1235';
		        webToCaseControllerObj.acct.BillingState = 'CO';
		        webToCaseControllerObj.acct.BillingPostalCode = '1234';
		        webToCaseControllerObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.acct.BillingCountryCode = 'US';
		        webToCaseControllerObj.acct.BillingStateCode = null;
		        webToCaseControllerObj.acct.Phone = null;
		        webToCaseControllerObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.selectedSubCategory = 'I dont see my product';
		        webToCaseControllerObj.objCase.Batch_Code__c = '1720';
		        webToCaseControllerObj.objCase.Purchased_From__c = 'test';
		        webToCaseControllerObj.objCase.Purchase_Date__c = date.today();
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = 'Original_PO_CASE_del__c';
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Distribution Inquiry';
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        
		        webToCaseControllerObj.registrationSave();
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethod2(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		       WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.acct.FirstName = 'Joe';
		        webToCaseControllerObj.acct.LastName = 'Bob';
		        webToCaseControllerObj.acct.BillingStreet = '123 test st';
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj.acct.BillingCity = 'Denver';
		        webToCaseControllerObj.acct.BillingState = 'CO';
		        webToCaseControllerObj.acct.BillingPostalCode = '80002';
		        webToCaseControllerObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.acct.BillingCountryCode = 'US';
		        webToCaseControllerObj.acct.BillingStateCode = '440012';
		        webToCaseControllerObj.acct.Phone = '986733450';
		        webToCaseControllerObj.confirmEmail = 'ravina_ajwani@persistent.co.in';
		        webToCaseControllerObj.selectedSubCategory = 'I dont see my product';
		        webToCaseControllerObj.objCase.Batch_Code__c = '1720';
		        webToCaseControllerObj.objCase.Purchased_From__c = 'test';
		        webToCaseControllerObj.objCase.Purchase_Date__c = date.today();
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = 'Original_PO_CASE_del__c';
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Order Issue';
       			webToCaseControllerObj.objCase.Product_Sub_Category__c = ''; 
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        
       			
		        webToCaseControllerObj.registrationSave();
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
    static testMethod void testMethodCase(){
        
        
        
       Test.starttest(); 
         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
         pageRef.getParameters().put('param', 'CA');
	     pageRef.getParameters().put('language', 'it');
	         
        WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
        webToCaseControllerObj.objCase.Type = 'Order Issue';
        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = '';
       	
        webToCaseControllerObj.setRequiredFields();
        webToCaseControllerObj.Upload();
        Test.stoptest();
       
    }
    
    
	static testMethod void testMethod3(){
		
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'CA');
        	 pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('language', 'fr');
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		       WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.acct.FirstName = 'Joe';
		        webToCaseControllerObj.acct.LastName = 'Bob';
		        webToCaseControllerObj.acct.BillingStreet = '123 test st';
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj.acct.BillingCity = 'Denver';
		        webToCaseControllerObj.acct.BillingState = 'CO';
		        webToCaseControllerObj.acct.BillingPostalCode = '80002 ';
		        webToCaseControllerObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.acct.BillingCountryCode = 'US';
		        webToCaseControllerObj.acct.BillingStateCode = '440012';
		        webToCaseControllerObj.acct.Phone = '986733450';
		        webToCaseControllerObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.selectedSubCategory = 'I dont see my product';
		        webToCaseControllerObj.objCase.Batch_Code__c = '1234';
		        webToCaseControllerObj.objCase.Purchased_From__c = 'test';
		        webToCaseControllerObj.objCase.Purchase_Date__c = date.today();
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = 'Original_PO_CASE_del__c';
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Order Issue';
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        
		        webToCaseControllerObj.registrationSave();
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethod4(){
		
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'CA');
        	 pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('language', 'fr');
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		       WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.acct.FirstName = 'Joe';
		        webToCaseControllerObj.acct.LastName = 'Bob';
		        webToCaseControllerObj.acct.BillingStreet = '123 test st';
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj.acct.BillingCity = 'Denver';
		        webToCaseControllerObj.acct.BillingState = 'CO';
		        webToCaseControllerObj.acct.BillingPostalCode = '80002 ';
		        webToCaseControllerObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.acct.BillingCountryCode = 'US';
		        webToCaseControllerObj.acct.BillingStateCode = '440012';
		        webToCaseControllerObj.acct.Phone = '986733450';
		        webToCaseControllerObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.selectedSubCategory = 'I dont see my product';
		        webToCaseControllerObj.objCase.Batch_Code__c = '1720';
		        webToCaseControllerObj.objCase.Purchased_From__c = 'test';
		        webToCaseControllerObj.objCase.Purchase_Date__c = date.today();
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = null;
		       
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Order Issue';
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        
		        webToCaseControllerObj.registrationSave();
		        
		        webToCaseControllerObj.objCase.Product_Sub_Category__c = null;
		        webToCaseControllerObj.setRequiredFields();
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethod5(){
		
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'CA');
        	 pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('language', 'fr');
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		       WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.acct.FirstName = 'Joe';
		        webToCaseControllerObj.acct.LastName = 'Bob';
		        webToCaseControllerObj.acct.BillingStreet = '123 test st';
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj.acct.BillingCity = 'Denver';
		        webToCaseControllerObj.acct.BillingState = 'CO';
		        webToCaseControllerObj.acct.BillingPostalCode = '80002 ';
		        webToCaseControllerObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.acct.BillingCountryCode = 'US';
		        webToCaseControllerObj.acct.BillingStateCode = '440012';
		        webToCaseControllerObj.acct.Phone = '986733450';
		        webToCaseControllerObj.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.selectedSubCategory = 'I dont see my product';
		        webToCaseControllerObj.objCase.Batch_Code__c = '1720';
		        webToCaseControllerObj.objCase.Purchased_From__c = null;
		        webToCaseControllerObj.objCase.Purchase_Date__c = null;
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = null;
		       
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Support & Service';
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        webToCaseControllerObj.objCase.Product_Sub_Category__c = null;
		        webToCaseControllerObj.registrationSave();
		        webToCaseControllerObj.setRequiredFields();
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethod6(){
		
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'CA');
        	 pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('language', 'fr');
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		       WebToCaseControllerWeb webToCaseControllerObj = new WebToCaseControllerWeb();
		     	webToCaseControllerObj.acct.FirstName = 'Joe';
		        webToCaseControllerObj.acct.LastName = 'Bob';
		        webToCaseControllerObj.acct.BillingStreet = '123 test st';
		        webToCaseControllerObj.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj.acct.BillingCity = 'Denver';
		        webToCaseControllerObj.acct.BillingState = 'CO';
		        webToCaseControllerObj.acct.BillingPostalCode = '80002 ';
		        webToCaseControllerObj.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj.acct.BillingCountryCode = 'US';
		        webToCaseControllerObj.acct.BillingStateCode = '440012';
		        webToCaseControllerObj.acct.Phone = '986733450';
		        webToCaseControllerObj.confirmEmail = 'ravina_ajwani@persistent.co.in';
		        webToCaseControllerObj.selectedSubCategory = null;
		        webToCaseControllerObj.objCase.Batch_Code__c = '1720';
		        webToCaseControllerObj.objCase.Purchased_From__c = 'test';
		        webToCaseControllerObj.objCase.Purchase_Date__c = date.today();
		        webToCaseControllerObj.objCase.Original_PO_CASE_del__c = 'Original_PO_CASE_del__c';
		       
		        webToCaseControllerObj.comments = 'For Inquiry';
		        webToCaseControllerObj.objCase.Type = 'Support & Service';
		        Account accountObj = TestDataFactory.createAccountRecord('Joe', true);
		        Attachment attachmentObj = TestDataFactory.createAtachment('Test Attachment',Blob.valueOf('Test Data for Attachment') ,accountObj.Id,true);
		        webToCaseControllerObj.Attachbody = attachmentObj.Body;
		        webToCaseControllerObj.Attachname = attachmentObj.Name;
		        
		        webToCaseControllerObj.registrationSave();
		        
		        webToCaseControllerObj.registrationSaveAndAddAttachment();
		        webToCaseControllerObj.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethodWebToCaseControllerNegativeTest(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        WebToCaseControllerWeb webToCaseControllerObj1 = new WebToCaseControllerWeb();
		     	webToCaseControllerObj1.acct.FirstName = null;
		        webToCaseControllerObj1.acct.LastName = null;
		        webToCaseControllerObj1.acct.BillingStreet = null;
		        webToCaseControllerObj1.personBillingStreet2 = null;
		        webToCaseControllerObj1.acct.BillingCity = null;
		        webToCaseControllerObj1.acct.BillingState = null;
		        webToCaseControllerObj1.acct.BillingPostalCode = null;
		        webToCaseControllerObj1.acct.PersonEmail = null;
		        webToCaseControllerObj1.acct.BillingCountryCode = null;
		        webToCaseControllerObj1.acct.BillingStateCode = null;
		        webToCaseControllerObj1.acct.Phone = null;
		        webToCaseControllerObj1.confirmEmail = null;
		        webToCaseControllerObj1.selectedSubCategory = null;
		        webToCaseControllerObj1.objCase.Batch_Code__c = null;
		        webToCaseControllerObj1.objCase.Purchased_From__c =null;
		        webToCaseControllerObj1.objCase.Purchase_Date__c = null;
		        webToCaseControllerObj1.objCase.Original_PO_CASE_del__c = null;
		        webToCaseControllerObj1.objCase.Type = null;
		        webToCaseControllerObj1.comments = null;
		        webToCaseControllerObj1.Attachbody = null;
		        webToCaseControllerObj1.Attachname = null;
		        
		        webToCaseControllerObj1.registrationSave();
		        webToCaseControllerObj1.registrationSaveAndAddAttachment();
		        webToCaseControllerObj1.Upload();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
    
    	static testMethod void testMethodWebToCaseControllerValidateCountryTest(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         
		        WebToCaseControllerWeb webToCaseControllerObj1 = new WebToCaseControllerWeb();
		     	webToCaseControllerObj1.acct.FirstName = null;
		        webToCaseControllerObj1.acct.LastName = null;
		        webToCaseControllerObj1.acct.BillingStreet = null;
		        webToCaseControllerObj1.personBillingStreet2 = null;
		        webToCaseControllerObj1.acct.BillingCity = null;
		        webToCaseControllerObj1.acct.BillingState = null;
		        webToCaseControllerObj1.acct.BillingPostalCode = null;
		        webToCaseControllerObj1.acct.PersonEmail = null;
		        webToCaseControllerObj1.acct.BillingCountryCode = null;
		        webToCaseControllerObj1.acct.BillingStateCode = null;
		        webToCaseControllerObj1.acct.Phone = null;
		        webToCaseControllerObj1.confirmEmail = null;
		        webToCaseControllerObj1.selectedSubCategory = null;
		        webToCaseControllerObj1.objCase.Batch_Code__c = null;
		        webToCaseControllerObj1.objCase.Purchased_From__c =null;
		        webToCaseControllerObj1.objCase.Purchase_Date__c = null;
		        webToCaseControllerObj1.objCase.Original_PO_CASE_del__c = null;
		        webToCaseControllerObj1.objCase.Type = null;
		        webToCaseControllerObj1.comments = null;
		        webToCaseControllerObj1.Attachbody = null;
		        webToCaseControllerObj1.Attachname = null;
		        
		        webToCaseControllerObj1.validateCountry();
		        
		Test.stoptest();
		// Verify response received 
	    System.assertEquals(true, success);
	}
	
	static testMethod void testMethodProductRegistrationControllerNegativeTest1(){
		Test.starttest();
	         PageReference pageRef = Page.WebToCase;
	         Test.setCurrentPage(pageRef);
	         
	         pageRef.getParameters().put('param', 'US');
	         pageRef.getParameters().put('language', 'fr' );
	         
	         Product2 product = TestDataFactory.createProduct('Prod', false, true);
		     Account accountObj = new Account();
		     accountObj.FirstName = 'Joe';
		     accountObj.LastName = 'Bob';
		        accountObj.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        //accountObj.BillingCountry = 'US';
		        accountObj.BillingCity = 'CHARLOTTETOWN';
		        //accountObj.BillingState = 'CO';
		        accountObj.BillingPostalCode = '800002';
		        accountObj.PersonEmail = 'raveena_ajwani@persistent.co.in';
		        accountObj.BillingCountryCode = 'US';
		        accountObj.BillingStateCode = 'CO';
		     insert accountObj;
	         
	        
	         Test.setMock(HttpCalloutMock.class, new GoogleReCaptchaCtrlTest.ExampleCalloutMock());
			 GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			 //Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
	         	
	         	//Set regirnCode = 'CAN'
	         	System.currentPageReference().getParameters().put('param', 'CA');
		        
		        WebToCaseControllerWeb webToCaseControllerObj1 = new WebToCaseControllerWeb();
		     	webToCaseControllerObj1.acct = accountObj;
		     	webToCaseControllerObj1.dummyAccount = accountObj;
		        webToCaseControllerObj1.personBillingStreet2 = '123 test street 2';
		        webToCaseControllerObj1.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj1.selectedSubCategory = 'I dont see my product';
        		webToCaseControllerObj1.selectedProduct = product.Id;
		        webToCaseControllerObj1.objCase.Batch_Code__c = null;
		        webToCaseControllerObj1.objCase.Purchased_From__c ='Amazon';
		        webToCaseControllerObj1.objCase.Purchase_Date__c = Date.today();
		        webToCaseControllerObj1.objCase.Type='Other';
		        webToCaseControllerObj1.comments = 'For Inquiry';
		        
		        webToCaseControllerObj1.fetchProducts();
           		webToCaseControllerObj1.viewSuccessMessage();
		        webToCaseControllerObj1.registrationSave();
		        
		        //When personalEmail!=confirmEmail
		        webToCaseControllerObj1.confirmEmail = 'raveena@persistent.co.in';
		        webToCaseControllerObj1.registrationSave();
		        
		        //BillingStreet
		        webToCaseControllerObj1.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        webToCaseControllerObj1.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)134 KENT ST. (CONF.COURT MALL)';
		        webToCaseControllerObj1.registrationSave();
		        
		        //Billing postal code
		        webToCaseControllerObj1.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        //System.currentPageReference().getParameters().put('param', 'CA');
		        //webToCaseControllerObj1.URL = 'CA';
		        accountObj.BillingPostalCode = '8 002';
		        webToCaseControllerObj1.dummyAccount.BillingCountryCode = 'CA';
		        webToCaseControllerObj1.dummyAccount.BillingStateCode = 'NL';
		        webToCaseControllerObj1.registrationSave();
		        
		        //PurchasedDate
		        accountObj.BillingPostalCode = '800002';
		        webToCaseControllerObj1.objCase.Purchase_Date__c = Date.today().addDays(1);
		        webToCaseControllerObj1.registrationSave();
		        
		        
		Test.stoptest();
		// Verify response received 
	   // System.assertEquals(true, success);
	}
}