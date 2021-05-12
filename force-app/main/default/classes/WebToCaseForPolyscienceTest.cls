@isTest
private class WebToCaseForPolyscienceTest{
	
    static testMethod void allMethodsTest(){   
		PageReference pageRef = Page.NewOrder;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('param', 'USA');
		ApexPages.CurrentPage().getparameters().put('language', 'en');
		
		Test.startTest();
	
		//Insert account		
		Account accountRecord = TestDataFactory.createAccountRecord('Nikhil Palekar998', 'BUS','nikhil998@example.com','9527785432');
        insert accountRecord;
        ApexPages.CurrentPage().getparameters().put('acct', 'accountRecord');
        
        //Insert case 
		Case caseRecord = TestDataFactory.createCase('Open','USD',null,accountRecord.Id,false);
		caseRecord.Type = 'Support & Service';
		caseRecord.Product_Sub_Category__c='abc';
		caseRecord.Purchased_From__c='def';
		caseRecord.Purchase_Date__c= Date.today();
		insert caseRecord;
		
		WebToCaseForPolyScience testRecord = new WebToCaseForPolyScience();
		testRecord.fetchProducts();
		
		testRecord.registrationSave();
		
		testRecord.acct.FirstName = 'FirstName';
		testRecord.acct.LastName = 'LastName';
		testRecord.acct.PersonEmail = 'nikhil998@example.com';
		testRecord.confirmEmail = 'nikhil998@example.com';
		testRecord.registrationSave();
		
		testRecord.acct.BillingCountryCode = 'US';
		testRecord.comments = 'comments';
		testRecord.registrationSave();
		
		testRecord.acct.BillingStreet = 'BillingStreet';
		testRecord.registrationSave();
		
		testRecord.objCase.Purchase_Date__c = Date.today();
		testRecord.objCase.Type = 'Type';
		testRecord.registrationSave();
		
		
		testRecord.objCase.Type = 'Distribution Inquiry';
		testRecord.registrationSave();
		
		testRecord.objCase.Type = 'Support & Service';
		testRecord.registrationSave();
		
		testRecord.objCase.Type = 'Order Issue';
		testRecord.registrationSave();
		
		Test.stopTest();
		
    }
    
    static testMethod void testMethodProductRegistrationControllerNegativeTest1(){
		Test.starttest();
	         PageReference pageRef = Page.NewOrder;
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
		        
		        WebToCaseForPolyScience testRecord = new WebToCaseForPolyScience();
		     	testRecord.acct = accountObj;
		     	testRecord.dummyAccount = accountObj;
		        testRecord.personBillingStreet2 = '123 test street 2';
		        testRecord.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        testRecord.selectedSubCategory = 'I dont see my product';
		        testRecord.objCase.Batch_Code__c = null;
		        testRecord.objCase.Purchased_From__c ='Amazon';
		        testRecord.objCase.Purchase_Date__c = Date.today();
		        testRecord.objCase.Type='RMA';
		        testRecord.comments = 'For Inquiry';
		        
		        testRecord.fetchProducts();
		        testRecord.registrationSave();
		        
		        //When personalEmail!=confirmEmail
		        testRecord.confirmEmail = 'raveena@persistent.co.in';
		        testRecord.registrationSave();
		        
		        //BillingStreet
		        testRecord.confirmEmail = 'raveena_ajwani@persistent.co.in';
		        testRecord.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)134 KENT ST. (CONF.COURT MALL)';
		        testRecord.registrationSave();
		        
		        //Billing postal code
		        testRecord.dummyAccount.BillingStreet = '134 KENT ST. (CONF.COURT MALL)';
		        //System.currentPageReference().getParameters().put('param', 'CA');
		        //testRecord.URL = 'CA';
		        accountObj.BillingPostalCode = '8 002';
		        testRecord.dummyAccount.BillingCountryCode = 'CAN';
		        testRecord.dummyAccount.BillingStateCode = 'NL';
		        testRecord.registrationSave();
		        
		        //PurchasedDate
		        accountObj.BillingPostalCode = '800002';
		        testRecord.objCase.Purchase_Date__c = Date.today().addDays(1);
		        testRecord.registrationSave();
		        
		        
		Test.stoptest();
		// Verify response received 
	   // System.assertEquals(true, success);
	}
}