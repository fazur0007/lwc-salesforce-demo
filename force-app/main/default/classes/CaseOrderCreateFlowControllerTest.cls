@isTest
private class CaseOrderCreateFlowControllerTest {

    static testMethod void caseOrderCreateFlowTest() {

        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        insert objAcc;
        RecordType recordType = [select Id,
                                        Name
                                   From RecordType
                                   where DeveloperName =: 'New_Case'
                                   and SobjectType =: 'Case'];
        System.debug('recordType :: '+recordType);

        RecordType recordTypeOrder1 = [select Id,
                                              Name
                                         From RecordType
                                        where DeveloperName =: 'MasterOrder'
                                          and SobjectType =: 'Order'];

        Case objCase = new Case();
        objCase.AccountId = objAcc.Id;
        objCase.Status = 'Open';
        objCase.Origin = 'Email';
        objCase.CurrencyIsoCode = 'USD';
        objCase.Complaint_Code__c = 'Circulation';
        objCase.Subject = 'Hey there';
        objCase.RecordTypeId = recordtype.Id;
        objCase.Warranty__c = 'In Warranty';
        insert objCase;

        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 brevillePB = new Pricebook2();
        brevillePB.Name = 'Breville CAN Pricebook';
        brevillePB.IsActive = true;
        insert brevillePB;

        Order objOrder = new Order();
        objOrder.AccountId = objAcc.Id;
        objOrder.Case__c = objCase.Id;
        objOrder.RecordTypeId = recordTypeOrder1.Id;
        objOrder.Channel__c = 'CCC';
        objOrder.Source__c = 'Breville';
        objOrder.Status = 'Open';
        objOrder.Type = 'Sale';
        objOrder.EffectiveDate = system.today();
        objOrder.Pricebook2Id = brevillePB.Id;
        insert objOrder;

        CaseOrderCreateFlowController objController = new CaseOrderCreateFlowController();

        PageReference casePage = Page.CaseOrderCreateFlow;
        PageReference finishPage = Page.FinishPage;

        test.startTest();
        Test.setCurrentPageReference(casePage);
        System.currentPageReference().getParameters().put('id', objCase.Id);
        Test.setCurrentPageReference(finishPage);
        System.currentPageReference().getParameters().put('id', objCase.Id);
        PageReference returnValue = objController.getOrderId();
        
        System.assertEquals(returnValue != null, true);
        
        
        test.stopTest();
    }
}