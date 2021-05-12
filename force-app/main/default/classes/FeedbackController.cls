public without sharing class FeedbackController {
    public Customer_Feedback__c feedback {get; set;}
    public String reason {get; set;}
    public String errorColor {get; set;}
    public String errorMsg {get; set;}
    public boolean showPageBlock {get; set;}
    public String displayEmail {get; set;}
    public String displayPhone {get; set;}
    public String code{get; set;}
    
    public FeedbackController(){
    	List<Customer_Feedback__c> feedbackToCheckResubmit = new List<Customer_Feedback__c>();
        feedback = new Customer_Feedback__c();
        List<Case> caseMatchingRecords = new List<Case>();
        List<Integer> allRatings = new List<Integer>(); 
        Transient Integer loopVariable = 1;
        String cid='';
        reason='';
        errorMsg='';
        errorColor='';
        showPageBlock=true;
        cid=ApexPages.currentPage().getParameters().get('cid'); 
        String lang = ApexPages.currentPage().getParameters().get('language');
        if(lang != null && lang != ''){
			if(lang.equalsIgnoreCase('fr')){
				code = lang;
			}
        }
        //checking for blank or null cid
        if(cid != null && cid!=''){
            caseMatchingRecords = [select id,CurrencyIsoCode from Case where id=:cid];
            
            //to check whether cid is correct or not
            if(caseMatchingRecords !=null && caseMatchingRecords.size()!=0){
            	
            	//set language
		        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c,Currency__c From Region_Specific__mdt 
		            											Where Currency__c=:caseMatchingRecords[0].CurrencyIsoCode];
		    	if(lang != null && lang != ''){
		    		if(lang.equalsIgnoreCase('fr')){
		    			code = lang;
		    		}else if(regionSpecific.Currency__c == 'CAD'){
		    			code = 'en_CA';
		    		}else{
		    			code = regionSpecific.LanguageCode__c;
		    		}
		    	}else{
		    		code = Label.Default_LanguageCode;
		    	}
            	
                feedbackToCheckResubmit = [select id from Customer_Feedback__c where Case__c=:cid limit 1]; 
                // to check if feedback is already submitted when customer click on feedback link again
                if(feedbackToCheckResubmit != null && feedbackToCheckResubmit.size()!=0){
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.AlreadySubmitted));
                	showPageBlock=false;
                }else{
                    //getting max rating value from metadata
                    allRatings=getRatingValues();
                }
            }else{
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
        		showPageBlock=false;
            }
        }else{
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
        	showPageBlock=false;
        }
    }
    
    public void saveFeedback(){
    	List<Customer_Feedback__c> feedbackToCheckResubmit = new List<Customer_Feedback__c>();
    	String cid=ApexPages.currentPage().getParameters().get('cid');
     	feedbackToCheckResubmit = [select id from Customer_Feedback__c where Case__c=:cid limit 1]; 
        //to restrict customer to submit feedback when customer click on Back again
        if(feedbackToCheckResubmit != null && feedbackToCheckResubmit.size()!=0){
        	errorColor='greenMsg';
            errorMsg=System.Label.AlreadySubmitted;
            showPageBlock=false;
        }else{
            feedback.case__c = cid;
            //to validate form and de-select select list 
            if(feedback.Did_we_meet_your_expectation__c=='Yes' || feedback.Did_we_meet_your_expectation__c==null)
            	feedback.Expectation_not_met_due_to__c = '';
            else if(feedback.Expectation_not_met_due_to__c=='Other' && reason != null && reason != ''){
            	if(reason.length() > 245){
            		reason = reason.left(245);
            	}
            	feedback.Expectation_not_met_due_to__c = 'Other : ' + reason;
            }
            if(feedback.Would_you_like_our_member_to_contact__c=='No' || feedback.Would_you_like_our_member_to_contact__c==null){
            	feedback.Method_of_contact__c='';
				feedback.Phone_Number__c='';
				feedback.Email__c='';            	
            }
            
            if(feedback.Was_the_wait_time_acceptable__c=='Yes' || feedback.Was_the_wait_time_acceptable__c==null)
            	feedback.Wait_Time__c='';
            //to check atleast 1 question is submitted.
            if(feedback.Did_we_meet_your_expectation__c=='No' && feedback.Expectation_not_met_due_to__c=='Other : '+reason && reason==''){
            	errorMsg=System.Label.expectation_not_met_reason;
            	errorColor='redMsg';
            }
            else if(feedback.Would_you_like_our_member_to_contact__c == 'Yes' && feedback.Method_of_contact__c=='Phone' && feedback.Phone_Number__c==''){
    			errorMsg=System.Label.EmailOrPhone;
    			errorColor='redMsg';
    			//feedback.Method_of_contact__c='Phone';
    		}else if(feedback.Would_you_like_our_member_to_contact__c == 'Yes' && feedback.Method_of_contact__c=='Email' && feedback.Email__c==''){
    			errorColor='redMsg';
    			errorMsg=System.Label.EmailOrPhone;
    			//feedback.Method_of_contact__c='Email';
    		}else if(feedback.Did_we_meet_your_expectation__c==null && feedback.Expectation_not_met_due_to__c=='' && feedback.Happy_with_your_Breville_product__c==null
    			&& feedback.Was_the_wait_time_acceptable__c==null && feedback.Wait_Time__c=='' && feedback.How_satisfied_are_you_with_Service__c==null 
    			&& feedback.Any_comments_for_Management_team__c=='' && feedback.Would_you_like_our_member_to_contact__c==null && feedback.Method_of_contact__c=='' ){
    						
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.QuestionValidation));
    		} 
    		else{
    			try{
    				//inserting the feedback
            		insert feedback;
	            }catch(DMLException e){
	            	//to show error in submitting feedback
	            	ErrorLog.logErrorActivity(e,'problem in inserting a feedback record',true,'Error');
	               	showPageBlock=false;
	               	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.SubmitError));
	            }
	            showPageBlock=false;
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.ThanksForFeedback));
        	}
        }                              
    }
    
    //following are the methods to get the select list options  
    public List<SelectOption> getExpectation(){
    	return Utility.getPickValues(new Customer_Feedback__c(),'Did_we_meet_your_expectation__c',null);
    }
    public List<SelectOption> getTimeAcceptable(){
    	return Utility.getPickValues(new Customer_Feedback__c(),'Was_the_wait_time_acceptable__c',null);
    }
    public List<SelectOption> getExpectationNotmet(){
    	return Utility.getPickValues(new Customer_Feedback__c(),'Expectation_not_met_due_to__c',null);
    }
    public List<SelectOption> getWaitingTime(){
    	return Utility.getPickValues(new Customer_Feedback__c(),'Wait_Time__c',null);
    }
    public List<SelectOption> getMemberToContact(){
    	return Utility.getPickValues(new Customer_Feedback__c(),'Would_you_like_our_member_to_contact__c',null);
    }
    public List<SelectOption> getMethodOfContact(){
    	return Utility.getPickValues(new Customer_Feedback__c(),'Method_of_contact__c',null);
    }
    
    //to get the ratings from custom metadata
    List<Integer> getRatingValues(){
    	List<Integer> allRatings = new List<Integer>();
    	All_Literal__mdt literal = [select Value__c from All_Literal__mdt where DeveloperName='FeedbackMaxRating' LIMIT 1];
        Integer maxRating=0;
        maxRating = Integer.valueOf(literal.Value__c);
        Transient Integer loopVariable = 1;
        for(loopVariable=maxRating;loopVariable>=1;loopVariable--){
            allRatings.add(loopVariable);
        }
        return allRatings;
    }
    
    public List<SelectOption> getRadioItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Integer> allRatings = getRatingValues();
        Transient Integer loopVariable = 1;
        for (Integer a : allRatings) {
            String val=String.valueOf(a);
             options.add(new SelectOption(val,''));
        }
         return options; 
    }
}