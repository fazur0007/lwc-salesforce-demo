public without sharing class CaseAutoCloseDispositionController {
    
    public String customerResponse{get; set;}
    public String closeCaseResponse{get; set;}
    public String caseId;
    public String errorColor {get; set;}
    public String errorMsg {get; set;}
    public boolean showPageBlock {get; set;}
    public boolean showOrderWorkOrderBlock {get; set;}
    public list<Order> orderList;
    public list<WorkOrder> workOrderList;
    public boolean showSubmitButton {get; set;}
    public String OrderWorkOrderResponse{get; set;}
    public boolean showComment{get; set;}
    public String comment{get; set;}
    public String code{get; set;}
    public String orderNumber {get; set;}
    public String workOrderNumber {get; set;}
    list<case> caseList = new list<case>();
    
    public CaseAutoCloseDispositionController(){
        caseId = ApexPages.currentPage().getParameters().get('cid');
        errorMsg='';
        errorColor='';
        showPageBlock=true;
        showOrderWorkOrderBlock = false;
        showSubmitButton = true;
        showComment = false;
        
        if(caseId != null && caseId != ''){
            caseList = [SELECT Id, Status,OwnerId,CurrencyIsoCode FROM Case where Id = :caseId limit 1];
            String lang = ApexPages.currentPage().getParameters().get('language');
            if(caseList != null && caseList.size() > 0){
            	Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c,Currency__c From Region_Specific__mdt 
        											Where Currency__c=:caseList[0].CurrencyIsoCode];
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
                list<Task> taskList = [SELECT Id FROM Task WHERE WhatId = :caseId AND Subject = :System.Label.Case_Auto_Close_Subject limit 1];
                
                orderList = [SELECT Id, Status, OrderNumber FROM Order WHERE Case__c = :caseId AND 
                			Status IN :ApplicationLiterals.CASEAUTOCLOSEDISPOSITION_ORDER_STATUS limit 1];
            	workOrderList = [SELECT Id, Status, WorkOrderNumber FROM WorkOrder where CaseId = :caseId AND Activated__c = false AND 
            				Status NOT IN :ApplicationLiterals.CASEAUTOCLOSEDISPOSITION_WORKORDER_STATUS limit 1];
            	
            	if(orderList != null && orderList.size() > 0){
            		orderNumber = orderList[0].OrderNumber;
            	}
            	if(workOrderList != null && workOrderList.size() > 0){
            		workOrderNumber = workOrderList[0].WorkOrderNumber;
            	}
                
                if(taskList != null && taskList.size() > 0){
                    /* if customer have already submitted the response */
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.Already_Submitted));
                    showPageBlock = false;
                }else if(caseList != null && caseList.size() > 0 && caseList[0].Status == 'Closed'){
                    
                    /* if case is already Hard Closed */
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
                    showPageBlock = false;
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
                 showPageBlock = false;
            }
        }else{
            
            /* show error if invalid case id is specified */
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
            showPageBlock = false;
        }
    }
    
    public void saveResponse(){
        if(customerResponse != null && customerResponse != ''){
            /* create task for the case*/
            Task taskToSave = new Task();
            taskToSave.WhatId = caseId;
            taskToSave.Subject = System.Label.Case_Auto_Close_Subject;
            taskToSave.ownerId = caseList[0].OwnerId;
            
            try{
                // inserting a Task to save the response from customer
                
                if(customerResponse.equals('Hold your case open')){
                	updateCase(caseId, customerResponse);
                    taskToSave.Description = System.Label.Hold_your_case_open;
                    if(comment != null && comment != ''){
	                    try{
	                    	/*insert case comment if available*/
		                	CaseComment commentRecord = new CaseComment();
		                	commentRecord.parentId = caseId;
		                	commentRecord.CommentBody= comment;
		                	insert commentRecord;
		                }catch(Exception ex){
		                	ErrorLog.logErrorActivity(ex, 'While inserting Comment from CaseAutoCloseDispositionController, method saveResponse', true, 'Error');
		                }
                    }
                    insert taskToSave;
                }else if(customerResponse.equals('Request a follow up from your support rep')){
                	updateCase(caseId, customerResponse);
                    taskToSave.Description = System.Label.Request_a_follow_up_from_your_support_rep;
                    insert taskToSave;
                }else if(customerResponse.equals('Close the case, everything is working')){
                	
                	if((orderList != null && orderList.size() > 0) || (workOrderList != null && workOrderList.size() > 0)){
                		
                		/* update case and cancel order if any*/
                		if(orderList != null && orderList.size() > 0){
                			updateCaseOrderWorkOrder(caseId,orderList[0].Id,null,customerResponse, caseList[0].OwnerId);
                		}
                		/* update case and cancel work order if any*/
                		if(workOrderList != null && workOrderList.size() > 0){
                			updateCaseOrderWorkOrder(caseId,null,workOrderList[0].Id,customerResponse, caseList[0].OwnerId);
                		}
                	}else{
                		updateCaseOrderWorkOrder(caseId,null, null,customerResponse, caseList[0].OwnerId);
                	}
                	
                }else if(customerResponse.equals('I do not have the product any longer')){
                	updateCase(caseId, customerResponse);
                    taskToSave.Description = System.Label.I_do_not_have_the_product_any_longer;
                    insert taskToSave;
                }
                
            }catch(Exception ex){
                ErrorLog.logErrorActivity(ex, 'While inserting Task from CaseAutoCloseDispositionController, method saveResponse', true, 'Error');
            }
            
            // to show success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.Thank_you_for_submitting_the_response));
            showPageBlock = false;
            
        }else{
            
            // to show error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select any option.'));
        }
    }
    
    public List<SelectOption> getOptionsList(){
    	return Utility.getPickValues(new case(),'CaseAutoCloseDisposition__c',null);
    }
    public List<SelectOption> getOptionsListAboutCase(){
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('Yes', System.Label.Yes));
        options.add(new selectOption('No', System.Label.No));
        return options;
    }
    
    //System.Label.Close_the_case_everything_is_working
    public void showOrderWorkOrderQuestion(){
        if(customerResponse.equals('Close the case, everything is working')){
            if((orderList != null && orderList.size() > 0) || workOrderList != null && workOrderList.size() > 0){
                showOrderWorkOrderBlock = true;
                showComment = false;
                showSubmitButton = true;
            }else{
            	showComment = false;
            	showSubmitButton = false;
            }
        }else if(customerResponse.equals('Hold your case open')){
        	showComment = true;
        	showOrderWorkOrderBlock = false;
        	showSubmitButton = false;
        }else{
        	showOrderWorkOrderBlock = false;
        	showComment = false;
        	showSubmitButton = false;
        }
    }
    
    public void validateResponse(){
    	if(OrderWorkOrderResponse == 'Yes'){
    		showSubmitButton = false;
    	}else if(OrderWorkOrderResponse == 'No'){
    		showSubmitButton = true;
    	}
    }
    
    @future
    public static void updateCaseOrderWorkOrder(Id caseId, Id orderId, Id workOrderId, String customerResponse, Id ownerId){
    	try{
    		Case updateCase = new Case(Id=caseId, Status='Closed', CaseAutoCloseDisposition__c = customerResponse);
    		update updateCase;
    		if(orderId != null || workOrderId != null){
	    		if(orderId != null){
					updateOrder(orderId,caseId, ownerId);
	    		}
	    		if(workOrderId != null){
					updateWorkOrder(workOrderId,caseId, ownerId);
	    		}
    		}else{
    			Task taskToSave = new Task();
		        taskToSave.WhatId = caseId;
		        taskToSave.Subject = System.Label.Case_Auto_Close_Subject;
		        taskToSave.Description = System.Label.Close_the_case_everything_is_working;
		        taskToSave.ownerId = ownerId;
		        insert taskToSave;
    		}
    	}catch(Exception e){
    		ErrorLog.logErrorActivity(e, 'While updating Case from CaseAutoCloseDispositionController, method saveResponse', true, 'CaseAutoCloseDisposition');
    	}
    }
    
    public static void updateOrder(Id orderId, Id caseId, Id ownerId){
    	Order updateOrder = new Order(Id=orderId, Status='Cancelled',Cancel_date__c=Date.today());
    	Task taskToSave = new Task();
        taskToSave.WhatId = caseId;
        taskToSave.Subject = System.Label.Case_Auto_Close_Subject;
        taskToSave.ownerId = ownerId;
    	try{
			update updateOrder;
			 taskToSave.Description = System.Label.Close_the_case_everything_is_working;
    	}catch(Exception ex){
    		ErrorLog.logErrorActivity(ex, 'While updating Order from CaseAutoCloseDispositionController, method saveResponse', true, 'CaseAutoCloseDisposition');
    		
    		taskToSave.Description = System.Label.Close_the_case_everything_is_working +' ' +System.Label.Steps_After_Closing_Case;
    	}
    	insert taskToSave;
    }
    
    public static void updateWorkOrder(Id workOrderId, Id caseId, Id ownerId){
    	WorkOrder updateWrokOrder = new WorkOrder(Id=workOrderId, Status='Cancelled',EndDate=Date.today());
    	Task taskToSave = new Task();
        taskToSave.WhatId = caseId;
        taskToSave.Subject = System.Label.Case_Auto_Close_Subject;
        taskToSave.ownerId = ownerId;
    	try{
			update updateWrokOrder;
			 taskToSave.Description = System.Label.Close_the_case_everything_is_working;
    	}catch(Exception ex){
    		ErrorLog.logErrorActivity(ex, 'While updating WorkOrder from CaseAutoCloseDispositionController, method saveResponse', true, 'CaseAutoCloseDisposition');
    		
    		taskToSave.Description = System.Label.Close_the_case_everything_is_working +' ' +System.Label.Steps_After_Closing_Case;
    	}
    	insert taskToSave;
    }
    
    
    
    @future
    public static void updateCase(Id caseId, String customerResponse){
    	try{
    		Case updateCase = new Case(Id=caseId, Status='Open', CaseAutoCloseDisposition__c = customerResponse);
    		update updateCase;
    	}catch(Exception e){
    		ErrorLog.logErrorActivity(e, 'While updating Case from CaseAutoCloseDispositionController, method saveResponse', true, 'CaseAutoCloseDisposition');
    	}
    }
    
}