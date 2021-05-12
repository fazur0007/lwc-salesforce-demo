@isTest
private without sharing class PreChatOfflineControllerTest {

	static testMethod void testMethodToCraeteNewAccountAndAsset(){
		Test.starttest();
		 	PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
	         preChatOfflineController.acct.FirstName = 'Joe';
		     preChatOfflineController.acct.LastName = 'Bob';
	         preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	         preChatOfflineController.acct.Phone = '986733450';
	         
	         preChatOfflineController.objCase.Type ='Feedback';
	         preChatOfflineController.objCase.Subject ='Summary';
        	 preChatOfflineController.description = 'Test Description Test Description Test Description Test Description Test Description ';
	         
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 1); 
	}
	 
	static testMethod void testMethodToCreateAssetForExistingAccount(){
		Account accNew = new Account();
	    accNew.FirstName = 'Joe';
	    accNew.LastName = 'Bob';
        accNew.PersonEmail = 'raveena_ajwani@persistent.co.in';
        accNew.Phone = '986733450';
	    upsert  accNew;
	       
		Test.starttest();
		 	PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
	         preChatOfflineController.acct.FirstName = 'Joe';
		     preChatOfflineController.acct.LastName = 'Bob';
	         preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	         
			 preChatOfflineController.objCase.Type ='Feedback';
	         preChatOfflineController.objCase.Subject ='Summary';	
	         preChatOfflineController.description = 'Test Description Test Description Test Description Test Description Test Description ';         
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 1);   
	}
	
	static testMethod void testMethodForRequiredFieldFirstName(){
			       
		Test.starttest();
		 	PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
		     preChatOfflineController.acct.LastName = 'Bob';
	         preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	         
			 preChatOfflineController.objCase.Type ='Feedback';
	         preChatOfflineController.objCase.Subject ='Summary';	
	                  
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 0);   
	}
	
	static testMethod void testMethodForRequiredFieldLastName(){
		Test.starttest();
		 	PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
		      preChatOfflineController.acct.FirstName = 'Joe';
	         preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	         
			 preChatOfflineController.objCase.Type ='Feedback';
	         preChatOfflineController.objCase.Subject ='Summary';	
	                  
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 0);   
	}
	
	static testMethod void testMethodForRequiredFieldPersonalEmail(){
		Test.starttest();
		 	PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
		      preChatOfflineController.acct.FirstName = 'Joe';
	          preChatOfflineController.acct.LastName = 'Bob';
	         
			 preChatOfflineController.objCase.Type ='Feedback';
	         preChatOfflineController.objCase.Subject ='Summary';	
	                  
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 0);   
	}

	static testMethod void testMethodForRequiredFieldTypeName(){
		Test.starttest();
		 	 PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
		      preChatOfflineController.acct.FirstName = 'Joe';
	          preChatOfflineController.acct.LastName = 'Bob';
	          preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	         preChatOfflineController.objCase.Subject ='Summary';	
	                  
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 0);   
	}
	
  static testMethod void testMethodForRequiredSubject(){
		Test.starttest();
		 	 PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
		      preChatOfflineController.acct.FirstName = 'Joe';
	          preChatOfflineController.acct.LastName = 'Bob';
	          preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	         preChatOfflineController.objCase.Type ='Feedback';
	                  
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 0);   
	}
	
	static testMethod void testMethodForRequiredCaseNumber(){
		Test.starttest();
		 	 PageReference pageRef = Page.LiveChatPreChatOffline;
	         Test.setCurrentPage(pageRef);
	         pageRef.getParameters().put('brand', 'Breville');
	         pageRef.getParameters().put('param', 'US');
	         
	         PreChatOfflineController preChatOfflineController = new PreChatOfflineController();
	         preChatOfflineController.dohaveCaseNo= true;
		      preChatOfflineController.acct.FirstName = 'Joe';
	          preChatOfflineController.acct.LastName = 'Bob';
	          preChatOfflineController.acct.PersonEmail = 'raveena_ajwani@persistent.co.in';
	                  
	         preChatOfflineController.savecase();
	   Test.stoptest();
	   // Verify case is created 
	    Integer i = [SELECT COUNT() FROM Case];
        System.assertEquals(i, 0);   
	}
	
}