/* Controller associated with pages rendering the survey.
* Used by SurveyPage, ResultsPage, TakeSurvey
*/
global virtual without sharing class ViewSurveyController {
    public String  qQuestion                      	{get; set;}
    public Boolean qRequired                      	{get; set;}
    public String  qChoices                       	{get; set;}
    public String surveyName                      	{get; set;}
    public String surveyHeader						{get; set;}
    public String surveyId                          {get; 
                                                     set{
                                                         this.surveyId = value;
                                                         init();
                                                     }
                                                    }   
    public String renderSurveyPreview				{get; set;}  
    public String questionName                		{get; set;}  
    public String questionType                  	{get; set;}
    public Boolean questionRequired             	{get; set;}
    public List<SelectOption> singleOptions   		{get; set;} 
    public List<SFQuestion> allQuestions        	{get; set;}
    public List<String> responses               	{get; set;}
    public Integer allQuestionsSize             	{get; set;}
    public String  templateURL                		{get; set;}
    public String  surveyThankYouText         		{get; set;}
    public String surveyContainerCss 				{get; set;}
    public String surveyThankYouURL          		{get; set;}
    public String accId	                    		{get; set;}
    public String orderId 							{get; set;}
    public String anonymousAnswer 					{get; set;}
    public List<SelectOption> anonymousOrUser 		{get; set;}
    public Boolean isInternal 						{get; set;}
    public String baseURL 							{get; set;}
    public String brand								{get; set;}
    
    public String userId							{get; set;}
    public String userName							{get; set;}
    public String surveyTakerId 					{get; set;}
    public Boolean thankYouRendered					{get; set;}
    public List<String> newOrder 					{get; set;}
    private String orderCurrency = 'USD';
    final private String defaultBrand = 'Breville';
    public string code {get; set;}
    public String lang;
    public String regionCode{get;set;}
    public String param {get; set;}
    /* Retrieves the list of questions, the survey name, after retrieving the 
necessary parameters from the url.
*/
    //------------------------------------------------------------------------------// 
    public ViewSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        surveyId = Apexpages.currentPage().getParameters().get('id');
        accId   = Apexpages.currentPage().getParameters().get('aId');
        orderId = Apexpages.currentPage().getParameters().get('oId'); 
        
        if(accId ==null || accId.length()<15){
            accId = 'none';
        }
        if(orderId ==null || orderId.length()<15){
            orderId = 'none';
        }           
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        
        init();
        
        // code for set language        
        param = ApexPages.currentPage().getParameters().get('param');
        lang = ApexPages.currentPage().getParameters().get('language');
        if(lang != null && lang != ''){
            if(lang.equalsIgnoreCase('fr')){
                if(param == 'CA'){
                    code= 'fr_CA';
                }else{
                    code = lang;
                }
            }else if(lang.equalsIgnoreCase('de')){
                code = lang;
            }else if(lang.equalsIgnoreCase('it')){
                code = lang;
            }
        }else{
            code = System.Label.Default_LanguageCode;
        }
        
        // code for set language END
    } 
    
    public ViewSurveyController(viewShareSurveyComponentController controller)
    {
        surveyId = Apexpages.currentPage().getParameters().get('id');
        accId = Apexpages.currentPage().getParameters().get('aId');
        orderId = Apexpages.currentPage().getParameters().get('oId');
        brand = ApexPages.currentPage().getParameters().get('brand');
        if(brand == null || brand =='')
            brand = defaultBrand;
        
        if(accId ==null || accId.length()<15){
            accId = 'none';
        }
        if(orderId ==null || orderId.length()<15){
            orderId = 'none';
        }       
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        init();
    }
    
    
    public void init()
    {
        if (surveyId != null){ 
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SFQuestion>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            anonymousOrUser = new List<SelectOption>();
            anonymousOrUser.add(new SelectOption('Anonymous',System.Label.LABS_SF_Anonymous));
            anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
            anonymousAnswer = 'Anonymous';
            isInternal =true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;
            
            userId = UserInfo.getUserId();
            userName = UserInfo.getName();
            
            String profileId = UserInfo.getProfileId();
            try
            {
                Profile p = [select Id, UserType from Profile where Id=:profileId];
                if (p.UserType == 'Guest')
                {
                    isInternal = false;
                }
                else
                {
                    isInternal = true;
                }
            }
            catch (Exception e){
                isInternal = false;
            }
            thankYouRendered = false;
        }       
    }
    
    
    
    
    
    //----------------------------------------------------------------------------//    
    
    /* Called during the setup of the page. 
Retrieve questions and responses from DB and inserts them in 2 lists. */
    public Integer setupQuestionList(){
        
        getAQuestion();
        return allQuestions.size();
    }
    
    
    /** Sets the survey's name variable
*  param: sID   The survey ID as specified in the DB
*/
    public void setSurveyNameAndThankYou(String sId){
        Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, thankYouLink__c, Survey_Header__c, Survey_Container_CSS__c FROM Survey__c WHERE Id =:sId];
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null)
        {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyThankYouURL = s.thankYouLink__c;
        surveyContainerCss = s.Survey_Container_CSS__c;
    }
    
    //------------------------------------------------------------------------------//   
    public Pagereference updateSurveyName(){
        Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
        s.Name = surveyName;
        try{
            update s;
        }catch (Exception e){
            Apexpages.addMessages(e);
        }
        return null;
    } 
    
    //------------------------------------------------------------------------------//      
    public Pagereference updateSurveyThankYouAndLink(){
        Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
        s.thankYouText__c = surveyThankYouText;
        s.thankYouLink__c = surveyThankYouURL;
        try{
            update s;
        }catch(Exception e){
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    //------------------------------------------------------------------------------//    
    /** When requested from the page - when the user clicks on 'Update Order' -
this function will reorganize the list so that it is displayed in the new order
*/
    public Pagereference refreshQuestionList(){
        setupQuestionList();
        return null;
    }
    
    
    
    //------------------------------------------------------------------------------//      
    
    
    
    //------------------------------------------------------------------------------//    
    private static boolean checkRequired(String response, Survey_Question__c question){
        if(question.Required__c == true){
            if(response == null || response =='NO RESPONSE')
                return false;
        }
        return true;
    } 
    
    /** Redirects the page that displays the detailed results of the survey, 
from all users who took the survey.
*/
    public PageReference resultPage() {
        return new PageReference('/apex/ResultsPage?id='+surveyId);
    }
    
    
    //------------------------------------------------------------------------------//  
    
    //------------------------------------------------------------------------------//  
    
    /** 
*/
    public List<String> getResponses() {
        List<SurveyQuestionResponse__c> qr = [Select Survey_Question__c, SurveyTaker__c, Response__c, Name From SurveyQuestionResponse__c limit 100];
        List<String> resp = new List<String>();
        for (SurveyQuestionResponse__c r : qr) {
            resp.add(r.Response__c);
        }
        
        return resp;
    }  
    
    
    
    /** Fills up the List of questions to be displayed on the Visualforce page
*/   
    public List<SFQuestion> getAQuestion() {
        qQuestion = '';
        qChoices ='';
        
        List<Survey_Question__c> allQuestionsObject = 
            [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
             s.OrderNumber__c, s.Name, s.Choices__c 
             From Survey_Question__c s 
             WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
        System.debug(allQuestionsObject);
        allQuestions = new List<SFQuestion>();
        
        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
        for (Survey_Question__c q : allQuestionsObject){ 
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0) {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
            }
            old_OrderNumber = q.OrderNumber__c;
            SFQuestion theQ = new SFQuestion(q);
            allQuestions.add(theQ);
        }
        allQuestionsSize = allQuestions.size();
        return allQuestions;
    }   
    
    public void submitResults()
    {
        try {
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
            System.debug('Here 1');
            for (SFQuestion q : allQuestions) {
                System.debug('Here 2');
                SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
                if (q.renderSelectRadio == 'true') {
                    
                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_fill_out_all_required_fields));
                        return;
                    }
                    
                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } else if (q.renderFreeText == 'true') {
                    if (q.required && q.choices == '') {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_fill_out_all_required_fields));
                        return;
                    }
                    System.debug('*****Select Radio ' + q.choices);
                    
                    sqr.Response__c = q.choices;
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } else if (q.renderSelectCheckboxes == 'true') {
                    if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_fill_out_all_required_fields));
                        return;
                    }
                    
                    for (String opt : q.selectedOptions) {
                        sqr = new SurveyQuestionResponse__c();
                        if (opt == '' || opt == null) {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    }
                } else if (q.renderSelectRow == 'true') {
                    if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_fill_out_all_required_fields));
                        return;
                    }
                    
                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            }
            if(AddSurveyTaker())
            {
                System.debug('Here 3');
                for (SurveyQuestionResponse__c sqr : sqrList)
                {
                    sqr.CurrencyIsoCode = orderCurrency;
                    sqr.SurveyTaker__c = surveyTakerId;
                }
                System.debug('Here 4');
                insert sqrList;
                thankYouRendered=true;
            }
        }catch(Exception e){
            if(isInternal) {
                Apexpages.addMessages(e);
            }else{
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Some_error_occured_while_saving_response));
            }
        }
        
    }
    
    
    private Boolean AddSurveyTaker()
    {
        String userId;
        if (surveyId == null) {
            return false;
        }
        if(accId.toUpperCase() =='NONE'|| accId.length()<5)
            accId = null;    
        if(orderId.toUpperCase() =='NONE'|| orderId.length()<5)
            orderId = null;         
        if (anonymousAnswer != 'Anonymous') {
            userId = UserInfo.getUserId();
        } else {
            userId = null;
        }
        
        if(accId != null && orderId != null) {
            List<Order> orderList = [Select Id, AccountId, CurrencyIsoCode From Order Where AccountId = :accId AND Id = :orderId];
            if(orderList == null || orderList.size() == 0) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Invalid_Account_or_Order_Id));
                return false;
            }
            orderCurrency = orderList[0].CurrencyIsoCode;
        } else {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Invalid_Account_or_Order_Id));
            return false;
        }
        if(orderId != null || accId != null) {
            List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Account__c, Case__c, Order__c, User__c From SurveyTaker__c Where Order__c=:orderId and Survey__c=:surveyId and Account__c = :accId];
            if(check != null && check.size()>0){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));
                
                return false;       
            }
        }
        
        SurveyTaker__c st = new SurveyTaker__c();
        st.Order__c = orderId;
        st.Survey__c = surveyId;
        st.Taken__c = 'false';
        st.Account__c = accId;
        st.User__c = userId;
        st.CurrencyIsoCode = orderCurrency;
        insert st;  
        surveyTakerId = st.Id;
        return true;    
    }
}