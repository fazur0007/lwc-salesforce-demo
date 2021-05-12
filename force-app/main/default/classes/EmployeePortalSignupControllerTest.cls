@istest
public without sharing class EmployeePortalSignupControllerTest {
	
    static testMethod void testMethodNewEmpSignup(){
    	insert EmployeePortalTestDataFactory.createCustomSettings();
    	EmployeePortalSignupController ctlr = new EmployeePortalSignupController();
    	String email = 'test@brevilleusa.com';
        ctlr.dummyAccount = EmployeePortalTestDataFactory.createAccountRecord(email);
    	ctlr.confirmEmail  = email;
    	ctlr.registrationSave();
    	Account acc = [select ID, FirstName, LastName from Account where FirstName = 'TestFname' and lastname = 'TESTLNAME' ];
    	System.assertNotEquals(null, acc.ID );
    }
    
    static testMethod void testMethodEmpAlreadyReg(){
        testMethodNewEmpSignup();
    	EmployeePortalSignupController ctlr = new EmployeePortalSignupController();
    	String email = 'test@brevilleusa.com';
        ctlr.dummyAccount = EmployeePortalTestDataFactory.createAccountRecord(email);
    	ctlr.confirmEmail  = email;
    	ctlr.registrationSave();
    	
    	System.assertNotEquals(true, ctlr.isSuccess );
    }
    
    static testMethod void testMethodEmpDiffEmail(){
        insert EmployeePortalTestDataFactory.createCustomSettings();
    	EmployeePortalSignupController ctlr = new EmployeePortalSignupController();
    	String email = 'test@brevilleusa.com';
        ctlr.dummyAccount = EmployeePortalTestDataFactory.createAccountRecord(email);
    	ctlr.confirmEmail  = 'tst@brevilleusa.com';
    	ctlr.registrationSave();
    	System.assertNotEquals(true, ctlr.isSuccess );
    }
    
    static testMethod void testMethodInsuffFieldsData(){
        insert EmployeePortalTestDataFactory.createCustomSettings();
    	EmployeePortalSignupController ctlr = new EmployeePortalSignupController();
    	String email = 'test@brevilleusa.com';
        
    	ctlr.registrationSave();
    	System.assertNotEquals(true, ctlr.isSuccess );
    }
}