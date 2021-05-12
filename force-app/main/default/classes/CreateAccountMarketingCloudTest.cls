@IsTest
public class CreateAccountMarketingCloudTest {
    @isTest
	public static void testPageLoad()
    {
        
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = 'TestProdregwocon213';
        record.firstName = 'firstName';
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = 'testemailprodregx321@yahoo.com';
        record.TerritoryAssigned__c = false;
        record.SendNLReminderEmail__c = false;
        record.Subscribe_to_our_newsletter__c = false;
        record.MkgOptEmailSent__c = System.Now();

        insert record;
        PageReference thankYouForCreatingAccount = Page.Thank_You_For_CreatingAccount;
        Test.setCurrentPage(thankYouForCreatingAccount );
         // Put p, q into the current page Parameters
        Blob p = blob.valueof(record.Id);
        Blob q = blob.valueof('productregistration');
        Blob r = blob.valueof('beanz');
        
        ApexPages.currentPage().getParameters().put('p', EncodingUtil.base64Encode(p));
        ApexPages.currentPage().getParameters().put('q', EncodingUtil.base64Encode(q));
        ApexPages.currentPage().getParameters().put('r', EncodingUtil.base64Encode(r));
        CreateAccountMarketingCloudController obj = new CreateAccountMarketingCloudController();
        obj.init();
    }
}