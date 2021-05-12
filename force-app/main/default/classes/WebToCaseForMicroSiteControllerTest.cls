/** 
 *  Test class for Web To Case For Breville MicroSite controller.
 *
 *  Version         Author           Last Modified Date (MM/DD/YYYY)         Description 
 *    1.0        Yogesh Sharma               12/10/2015                     Initial Draft
 */
@isTest
private class WebToCaseForMicroSiteControllerTest {
/*
  static Account account;
  static Product2 product;
  static Case case1;
  static RecordType personAccount, caseRecord;
  static User userObj;

    static void testData_for_WebToCaseForBrevilleMicroSiteTest() {
      personAccount = [Select Id 
                         From RecordType
                        where sObjectType = 'Account'
                          and Name = 'Person Account'
                          and IsActive= True];

       //Create an Account Record
      account=new Account();
      account.RecordTypeId=personAccount.Id;
      account.FirstName='Punam';
      account.LastName='Biraris';
      insert account;

      //Create a Product Record
      product=new Product2();
      product.SKU__c='.BES870XL';  //required
      product.Name='Product name';
      product.IsActive= true;
      product.Description='Product description';
      product.Finished_Good__c= true;
      product.Product_Classification__c='S';
      product.Spare_Part__c= false;
      product.Family='PSA';
      product.Breville_US_Product__c = true;
      product.Espresso_Microsite__c = true;
      insert product;

      caseRecord = [SELECT id,
                           Name
                      FROM RecordType
                     WHERE SobjectType = 'Case'
                       and isActive = true
                       and DeveloperName = 'New_Case'];

      //Create a Case Record

      case1=new case();
      case1.RecordTypeId = caseRecord.Id;
      case1.AccountId=account.Id;
      case1.Product__c=product.Id;         //lookup to product
      insert case1;

      userObj=[Select Id,FirstName
                 FROM User
               WHERE  UserType =: 'Guest' limit 1];
    }

    static testMethod void forNewAccount() {

      testData_for_WebToCaseForBrevilleMicroSiteTest();
      system.runAs(userObj)
      {
        Pagereference pageref=page.WebToCaseForBrevilleMicroSite;
        Test.setCurrentPage(pageref);

        WebToCaseForBrevilleMicroSiteController objWTCFP=new WebToCaseForBrevilleMicroSiteController();
        objWTCFP.acct=new Account();
        objWTCFP.objCase=new Case();

        List<SelectOption> productt=objWTCFP.products;
        List<SelectOption> casetype=objWTCFP.getCaseTypes();

        objWTCFP.objCase.Product__c=product.Id;
        objWTCFP.objCase.AccountId=account.Id;
        objWTCFP.acct.FirstName='sandy';
        objWTCFP.acct.LastName='Tani';
        objWTCFP.acct.PersonEmail='sandt.t@g.com';
        objWTCFP.confirmEmail='sandt.t@g.com';
        objWTCFP.acct.Phone='1236547891';
        objWTCFP.getIsSuccess();
        objWTCFP.registrationSave();
          
       /* Case caseChk=[Select Id,
                             AccountId
                        From Case 
                       limit 1];
        system.assertEquals(account.Id, caseChk.AccountId);*/
 /*     }

      Pagereference pageref2=page.WebToCaseForBrevilleMicroSite;
      Test.setCurrentPage(pageref2);

      WebToCaseForBrevilleMicroSiteController objWTCFP2=new WebToCaseForBrevilleMicroSiteController();
      objWTCFP2.acct=new Account();
      objWTCFP2.objCase=new Case();

      List<SelectOption> productt2=objWTCFP2.products;
      List<SelectOption> casetype2=objWTCFP2.getCaseTypes();

      objWTCFP2.objCase.Product__c=product.Id;
      objWTCFP2.objCase.AccountId=account.Id;
      objWTCFP2.acct.FirstName='Punam';
      objWTCFP2.acct.LastName='shrivastav';
      objWTCFP2.acct.PersonEmail='biraris.pn@g.com';
      objWTCFP2.confirmEmail='biraris.pn@g.com';
      objWTCFP2.acct.Phone='1236547891';
      objWTCFP2.comments='For Inquiry And Helpline support';

      objWTCFP2.getIsSuccess();
      objWTCFP2.registrationSave();

      Pagereference pageref1=page.WebToCaseForBrevilleMicroSite;
      Test.setCurrentPage(pageref1);

      WebToCaseForBrevilleMicroSiteController objWTCFP1=new WebToCaseForBrevilleMicroSiteController();
      objWTCFP1.acct=new Account();
      objWTCFP1.objCase=new Case();

      List<SelectOption> productt1=objWTCFP1.products;
      List<SelectOption> casetype1=objWTCFP1.getCaseTypes();

      objWTCFP1.objCase.Product__c=product.Id;
      objWTCFP1.objCase.AccountId=account.Id;
      objWTCFP1.acct.FirstName='sandip';
      objWTCFP1.acct.LastName='Biraris';
      objWTCFP1.acct.PersonEmail='biraris.pn@g.com';
      objWTCFP1.confirmEmail='biraris.pn@g.com';
      objWTCFP1.acct.Phone='7711445566';
      objWTCFP1.comments='gogoa';

      objWTCFP1.getIsSuccess();
      objWTCFP1.registrationSave();

    }
    static testMethod void forInvalidEmail() {

      testData_for_WebToCaseForBrevilleMicroSiteTest();
      Pagereference pageref=page.WebToCaseForBrevilleMicroSite;
      Test.setCurrentPage(pageref);

      WebToCaseForBrevilleMicroSiteController objWTCFP=new WebToCaseForBrevilleMicroSiteController();
      objWTCFP.acct=new Account();
      objWTCFP.objCase=new Case();

      List<SelectOption> productt=objWTCFP.products;
      List<SelectOption> caseType=objWTCFP.getCaseTypes();

      objWTCFP.objCase.Product__c=product.Id;
      objWTCFP.objCase.AccountId=account.Id;
      objWTCFP.acct.FirstName='sandy';
      objWTCFP.acct.LastName='Tani';
      objWTCFP.acct.Phone='1236547891';
      objWTCFP.acct.PersonEmail='sandt.t@g.com';
      objWTCFP.confirmEmail='b.bb@b.com';
      objWTCFP.comments='hi';

      objWTCFP.registrationSave();  

      Pagereference pageref1=page.WebToCaseForBrevilleMicroSite;
      Test.setCurrentPage(pageref1);

      WebToCaseForBrevilleMicroSiteController objWTCFP1=new WebToCaseForBrevilleMicroSiteController();
      objWTCFP1.acct=new Account();
      objWTCFP1.objCase=new Case();

      List<SelectOption> productt1=objWTCFP1.products;
      List<SelectOption> caseType1=objWTCFP1.getCaseTypes();

      objWTCFP1.objCase.Product__c=product.Id;
      objWTCFP1.objCase.AccountId=account.Id;
      objWTCFP1.acct.FirstName='sandy';
      objWTCFP1.acct.LastName='Tani';
      objWTCFP1.acct.Phone='1236547891';
      objWTCFP1.acct.PersonEmail='sand.com';
      objWTCFP1.confirmEmail='sand.com';
      objWTCFP1.comments='For Inquiry';

      objWTCFP1.registrationSave();  
    }

    static testMethod void forInvalidData() {

       testData_for_WebToCaseForBrevilleMicroSiteTest();
       system.runAs(userObj) {
	        Pagereference pageref=page.WebToCaseForBrevilleMicroSite;
	        Test.setCurrentPage(pageref);

	        WebToCaseForBrevilleMicroSiteController objWTCFP=new WebToCaseForBrevilleMicroSiteController();
	        objWTCFP.acct=new Account();
	        objWTCFP.objCase=new Case();

	        List<SelectOption> productt=objWTCFP.products;
	        List<SelectOption> caseType=objWTCFP.getCaseTypes();

	        objWTCFP.comments='ForInquiryForInquiryForInquiryForInquiry';

	        objWTCFP.registrationSave();
      }
      system.assert(ApexPages.hasMessages());
     }*/
}