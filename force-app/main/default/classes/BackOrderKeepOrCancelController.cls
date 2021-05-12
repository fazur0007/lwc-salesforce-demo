public without sharing class BackOrderKeepOrCancelController {
	public String customerResponse{get; set;}
  	public String orderID;
    public boolean showPageBlock {get; set;}
    public Order orderToUpdate ;
    public String code{get; set;}
    list<Order> orderList = new list<Order>();
    
    public BackOrderKeepOrCancelController(){
    	orderID = ApexPages.currentPage().getParameters().get('oid');
        showPageBlock=true;
        code='en';
        
        if(orderID != null && orderID != ''){
  			list<Task> taskList = [SELECT Id,description,Subject FROM Task WHERE WhatId = :orderID AND Subject = 'Customer Back Order Notification Response' limit 1];
  			orderList = [SELECT Id, Status, CustomerBackOrderResponse__c,OwnerId,CurrencyIsoCode FROM Order where Id = :orderID limit 1];
 			if(orderList != null && orderList.size() > 0){
 				String lang = ApexPages.currentPage().getParameters().get('language');
		    	Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c,Currency__c From Region_Specific__mdt 
		    											Where Currency__c=:orderList[0].CurrencyIsoCode];
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
	  			orderToUpdate = orderList[0];
	  		}else{
	      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
	     		showPageBlock=false;
	     		return;
	  		}
	  		if(orderList[0].Status == 'Cancelled'){
	        	/* if order is already cancelled */
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.Order_Already_Cancelled));
	      		showPageBlock=false;
	  		}else if(orderList[0].CustomerBackOrderResponse__c == true){
	  			/* if response is already submitted */
	  			
	       		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.Already_Submitted));
	      		showPageBlock=false;
	  		}
        }else{
          /* show error if invalid order id is specified */
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
          showPageBlock=false;
        }
  	}
  	
  	public void saveResponse(){
    	if(customerResponse != null && customerResponse != ''){
	    	/* create task for the order*/
	    	Task taskToSave = new Task();
	      	taskToSave.WhatId = orderId;
	      	taskToSave.Subject = System.Label.Back_Order_Notification_Subject;
	      	taskToSave.Status = 'Completed';
	      	taskToSave.OwnerId = orderList[0].OwnerId;
	      	
	      	try{
	        	/* updating order depending on the response of customer */
	        	if(customerResponse == 'No'){
	        		taskToSave.Description = System.Label.Back_Order_Cancel_Order;
        			orderToUpdate.Status = 'Cancelled';
					orderToUpdate.Cancel_date__c = Date.today();
					orderToUpdate.NextNotificationDate__c = null;
					orderToUpdate.ActivatedByPartner__c = false;
	        	}
	      	}catch(Exception ex){
	        	ErrorLog.logErrorActivity(ex, 'While inserting Task from BackOrderKeepOrCancelController, method saveResponse', true, 'Error');
	      	}
	      	
	      	try{
				orderToUpdate.CustomerBackOrderResponse__c = true;
    			update orderToUpdate;
    			/* inserting a Task to save the response from customer*/
    			if(customerResponse == 'No'){
    				insert taskToSave;
    			}
    		}catch(Exception e){
      			ErrorLog.logErrorActivity(e, 'While updating order status to Cancel from BackOrderKeepOrCancelController, method saveResponse', true, 'Error');
    		}
	      	
	      	/* to show success message*/
		    showPageBlock=false;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.Thank_you_for_submitting_the_response));
    	}else{
      		/* to show error message*/
        	showPageBlock=false;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.InvalidURL));
    	}
  	}
	public List<SelectOption> getOptionsList(){
	    List<selectOption> options = new List<selectOption>();
	    options.add(new selectOption('Yes', System.Label.BackOrderYes));
	    options.add(new selectOption('No', System.Label.BackOrderNo));
	    return options;
    }
}