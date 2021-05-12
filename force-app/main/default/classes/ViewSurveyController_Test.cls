@istest
private class ViewSurveyController_Test{
    @testSetup
    private static void setupData() {
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        objAcc.PO_Box_APO_Foreign__c = true;
        insert objAcc;
        
        Id objPricebook2 = Test.getStandardPricebookId();
        
        //Insert Order    		
		Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2); 
		orderObj.Type = 'Sale';
		orderObj.Shipping_Method__c = 'STANDARD';
		insert orderObj;   
    }
    
    private static Testmethod void testViewSurveyController() {
        List<Account> accList = [Select Id from Account where Name='Account1'];
        List<Order> odrList = [Select Id from Order];
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.currentPage().getParameters().put('aid', accList[0].id);
        Apexpages.currentPage().getParameters().put('oid', odrList[0].id);
        Apexpages.currentPage().getParameters().put('Brand', 'Breville');
        Apexpages.currentPage().getParameters().put('language', 'fr');
        Apexpages.currentPage().getParameters().put('param', 'CA');
        
        Apexpages.Standardcontroller stc;
        viewShareSurveyComponentController vscc = new viewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(stc); 
        Test.startTest();
        ViewSurveyController vsc1 = new ViewSurveyController(vscc);
        String name = vsc.questionName;
        String type = vsc.questionType;
        Boolean req = vsc.questionRequired;
        Boolean qreq = vsc.qRequired;
        vsc.init();
        vsc.refreshQuestionList();
        vsc.resultPage();
        vsc.getResponses();
        Test.stopTest();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);


        vsc.submitResults();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.thankYouRendered);


        //test something
    }
    
    private static Testmethod void testLanguageDe(){
        Apexpages.currentPage().getParameters().put('language', 'de');
        Apexpages.Standardcontroller stc;
        viewShareSurveyComponentController vscc = new viewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(stc);         
        ViewSurveyController vsc1 = new ViewSurveyController(vscc);
        
    }
    private static Testmethod void testLanguageIt(){
        Apexpages.currentPage().getParameters().put('language', 'it');
        Apexpages.Standardcontroller stc;
        viewShareSurveyComponentController vscc = new viewShareSurveyComponentController();
        ViewSurveyController vsc = new ViewSurveyController(stc);         
        ViewSurveyController vsc1 = new ViewSurveyController(vscc);
        
    }


    private static Testmethod void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);

    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }


}