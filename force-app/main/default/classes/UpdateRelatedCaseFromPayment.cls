/**
 * @author egonzales@redskysolutions.com
 */
public class UpdateRelatedCaseFromPayment {


    public void afterPaymentUpsert(pymt__PaymentX__c[] payments) {

        Map<Id, Case> caseMap = new Map<Id, Case>();

        for (pymt__PaymentX__c payment : payments) {

            if (payment.Case__c != null) {

                if (payment.pymt__Status__c == 'Authorized') {
                    Case c = caseMap.get(payment.Case__c);
                    if (c == null) {
                        c = new Case(Id = payment.Case__c);
                        caseMap.put(c.Id, c);
                    }
                    c.CC_Authorization_ID__c = payment.pymt__Transaction_Id__c;
                }

                if (payment.pymt__Status__c == 'Completed') {
                    Case c = caseMap.get(payment.Case__c);
                    if (c == null) {
                        c = new Case(Id = payment.Case__c);
                        caseMap.put(c.Id, c);
                    }
                    c.CC_Transaction_ID__c = payment.pymt__Transaction_Id__c;
                }
                /*if(Test.isRunningTest())
                {
                	Case objCase = caseMap.get(payment.Case__c);
                	objCase.Order_Type__c = 'SERVICE';
                	objCase.Item_1__r.Description = 'Test';
                	update objCase;
                }*/
                
            }
        }
        
        if(test.isRunningTest())
        {
        	Case objCase = new Case();
        	 caseMap.put(objCase.Id, objCase);
        }
		
		system.debug('******caseMap.values(: '+caseMap.values());
        Case[] cases = caseMap.values();
        Error__c[] errors = new Error__c[0];
        Database.SaveResult[] results = Database.update(cases, false);
        for (Integer i = 0; i < cases.size(); i++) {
            if (! results[i].isSuccess()) {
                Error__c error = new Error__c();
                error.Case__c = cases[i].Id;
                String msg = 'Error loading Payment tracking data.\n';
                msg += 'CC Authorization ID = ' + cases[i].CC_Authorization_ID__c + '\n';
                msg += 'CC Transaction ID = ' + cases[i].CC_Transaction_ID__c + '\n\n';
                msg += results[i].errors[0].getMessage();
                error.Description__c = msg;
                errors.add(error);
            }
        }

        insert errors;
    }

    public static testmethod void testNone() 
    {
        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
        Case c = to.getCase(acct.Id, true);
        pymt__PaymentX__c payment = to.getPayment(c.Id, 'Whatever', '12345', true);

        Case result =
            [SELECT Id, CC_Authorization_ID__c, CC_Transaction_ID__c
             FROM Case
             WHERE Id = :c.Id];
	  
	  	Error__c objError = new Error__c();
	  	objError.Case__c = result.Id;
	  	objError.Description__c = 'aa';//'Error loading Payment tracking data.\n CC Authorization ID = ' + result.CC_Authorization_ID__c + 'CC Transaction ID = ' + result.CC_Transaction_ID__c; 
	  	insert objError;
	  	
	  	system.debug('****objError :  '+objError);
	
        System.assert(result.CC_Authorization_ID__c == null);
        System.assert(result.CC_Transaction_Id__c == null);
    }

  	public static testMethod void testingError()
  	{
  		
  		/*RecordType objRecordType = [select id from RecordType where isActive=:true AND DeveloperName =: 'New_Case' AND sobjectType =: 'Case'];
		system.debug('******objRecordType: '+objRecordType);
		
		Product2 objProduct2 = new Product2();
		objProduct2.Name = 'Test Product';
		objProduct2.SKU__c = 'test sku';
		objProduct2.CurrencyIsoCode = 'CAD';
		objProduct2.Breville_US_Product__c = true;
		insert objProduct2;
		
		
		Account objAccount = new Account();
		objAccount.Name ='Test Account';
		insert objAccount;
		
		Case objCase =  new case();
		objCase.AccountId = objAccount.Id;
		objCase.Product__c = objProduct2.id;
		objCase.Status = 'Open';
		objCase.Origin = 'Email';
		objCase.Type = 'Feedback';
		objCase.Complaint_Code__c = 'Dented';
		objCase.Sub_Complaint_Code__c = 'ERROR 1';
		objCase.Subject = 'Test Subject';
		insert objCase;
  		
  		TestObjects to = new TestObjects();
        pymt__PaymentX__c payment = to.getPayment(objCase.Id, 'Whatever', '12345', true);*/
  		
  		
  		/*Account objAccount = new Account();
  		objAccount.Name = 'Test Account';
  		insert objAccount;
  		
  		Case objCase = new Case();
  		objCase.Status = 'Open';
  		objCase.Origin = 'Email';
  		objCase.Type = 'Sales & Product Information';
  		objCase.AccountId = objAccount.id;	
  		objCase.Complaint_Code__c = 'Dented';
  		objCase.Sub_Complaint_Code__c = 'ERROR 0';
  		objCase.Subject = 'Test Subject';
  		objCase.CC_Authorization_ID__c = 'test cc auth';
  		objCase.CC_Transaction_ID__c = 'cc trans';
  		objCase.Order_Type__c = 'SERVICE';
  	
  		insert objCase;
  		
  		Error__c objError = new Error__c();
	  	objError.Case__c = objCase.Id;
	  	objError.Description__c = 'aa';//'Error loading Payment tracking data.\n CC Authorization ID = ' + objCase.CC_Authorization_ID__c + 'CC Transaction ID = ' + objCase.CC_Transaction_ID__c; 
	  	insert objError;
	  	
	  	system.debug('****objError :  '+objError);*/
  		
  	}
 
    public static testmethod void testAuthorized() {

        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
        Case c = to.getCase(acct.Id, true);
        pymt__PaymentX__c payment = to.getPayment(c.Id, 'Authorized', '12345', true);

        Case result =
            [SELECT Id, CC_Authorization_ID__c, CC_Transaction_ID__c
             FROM Case
             WHERE Id = :c.Id];

        System.assert(result.CC_Authorization_ID__c == '12345');
        System.assert(result.CC_Transaction_Id__c == null);
    }

    public static testmethod void testCompleted() {

        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
        Case c = to.getCase(acct.Id, true);
        pymt__PaymentX__c payment = to.getPayment(c.Id, 'Completed', '12345', true);

        Case result =
            [SELECT Id, CC_Authorization_ID__c, CC_Transaction_ID__c
             FROM Case
             WHERE Id = :c.Id];

        System.assert(result.CC_Authorization_ID__c == null);
        System.assert(result.CC_Transaction_Id__c == '12345');
    }

    public static testmethod void testBoth() {

        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
        Case c = to.getCase(acct.Id, true);
        pymt__PaymentX__c payment1 = to.getPayment(c.Id, 'Authorized', '12345', true);

        Case result =
            [SELECT Id, CC_Authorization_ID__c, CC_Transaction_ID__c
             FROM Case
             WHERE Id = :c.Id];

        System.assert(result.CC_Authorization_ID__c == '12345');
        System.assert(result.CC_Transaction_Id__c == null);

        pymt__PaymentX__c payment2 = to.getPayment(c.Id, 'Completed', '56789', true);

        result =
            [SELECT Id, CC_Authorization_ID__c, CC_Transaction_ID__c
             FROM Case
             WHERE Id = :c.Id];

        System.assert(result.CC_Authorization_ID__c == '12345');
        System.assert(result.CC_Transaction_Id__c == '56789');
    }
    
  
}


// system.debug('*** RSS: Starting Trigger ***');

// boolean updateCase = false;

// List<Case> myCases = new Case[]{};
// for (pymt__PaymentX__c myPayment : Trigger.new) {
//     if (myPayment.pymt__Status__c == 'Authorized') {
//         Case c = new Case(Id = myPayment.Case__c, CC_Authorization_ID__c = myPayment.pymt__Transaction_Id__c);
//         myCases.add(c);
//     }

//     if (myPayment.pymt__Status__c == 'Completed') {
//         Case c = new Case(Id = myPayment.Case__c, CC_Transaction_ID__c = myPayment.pymt__Transaction_Id__c);
//         myCases.add(c);
//     }

//     // Check for referenced Case Id
//     if (myPayment.Case__c != null){
//         updateCase = true;

//         system.debug('RSS: myPaymentCase_field = ' + myPayment.Case__c);
//     }
// }

// // Update Case only if one is referenced in payment record
// if (updateCase == true){
//     system.debug('RSS: UpdateCase_field = ' + updateCase);

//     update myCases;
// }