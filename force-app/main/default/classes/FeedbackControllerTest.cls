@isTest
private class FeedbackControllerTest {

    static testMethod void testFeedbackController() {
        
        Account accountRecord = new Account();
        accountRecord.lastName = 'Palekar';
        insert accountRecord;
        
        Case caseRecord = new Case();
        caseRecord.status='Open';
        caseRecord.Origin='Email';
        caseRecord.type='Feedback';
        caseRecord.account=accountRecord;
        caseRecord.CurrencyIsoCode='USD';
        caseRecord.Complaint_Code__c='Circulation';
        caseRecord.subject='abc';
        insert caseRecord;

        test.startTest();
        ApexPages.currentPage().getParameters().put('cid',caseRecord.id);
        FeedbackController fCon = new FeedbackController();                
        fCon.saveFeedback();
        fCon.saveFeedback();
        fCon.getExpectation();
        fCon.getTimeAcceptable();
        fCon.getWaitingTime();
        fCon.getMemberToContact();
        fCon.getExpectationNotmet();
        fCon.getMethodOfContact();
        fCon.getRadioItems();
        
        ApexPages.currentPage().getParameters().put('cid',accountRecord.id);
        FeedbackController fCon2 = new FeedbackController();
        fCon2.saveFeedback();
        
        ApexPages.currentPage().getParameters().put('cid',caseRecord.id);
        FeedbackController fCon3 = new FeedbackController();
        fCon3.saveFeedback();
        
        ApexPages.currentPage().getParameters().put('cid',null);
        FeedbackController fCon4 = new FeedbackController();
        fCon4.saveFeedback();
        
        test.stopTest();
    }
}