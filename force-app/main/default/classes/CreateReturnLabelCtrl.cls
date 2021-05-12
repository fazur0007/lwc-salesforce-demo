public without sharing class CreateReturnLabelCtrl {
	
	public Case caseRecord 							{get;set;}
	public Id caseRecordId 							{get;set;}
    public String workingObject 					{get;set;}
    public Id workingObjectId 						{get;set;}
    public String refNumber							{get;set;}
    public String returnDescriptionCls 				{get;set;}
    public ShipmentSetting__c shipmateSet 			{get;set;}
    public Boolean isSuccess 						{get;set;}
    public Boolean isValid   						{get;set;}
    public String returnLabelFor   					{get;set;}
    public boolean createBoxOrder					{get;set;}
    public Boolean isReturn 						{get;set;}
    public ShipmateUtility.DimensionBean dimension 	{get;set;}
    private Id bulkShipmentId = null;
    private id queuedShipmentId = null;
    private map<Id,ShipmentSetting__c> shipmateSetById;
    public Boolean isCreateLabelIntiate 			{get;set;}
    public String serviceType						{get;set;}
    public String selectedShippingCarrier			{get;set;}
    //Place holder for setting shipping method
    public ShipmentSetting__c shipmentSetting		{get;set;}
    public boolean hasWorkOrder {get;set;} 
    public list<SelectOption> shippingCarriers		{get;set;}
    private Id locationId = null;
    
    public CreateReturnLabelCtrl(){
        isSuccess = false;
        isValid = false;
        isCreateLabelIntiate = false;
        createBoxOrder = false;
        shipmentSetting = new ShipmentSetting__c();
        shippingCarriers = new List<SelectOption>();
        
        
    }
    
    public void initiateCreateReturnShipmate(){
    	
    	try{
    		isReturn = true;
	    	isCreateLabelIntiate = true;
	    	caseRecord = getCaseDetails();
	    	if(returnLabelFor == 'Service Center'){
	        	locationId = caseRecord.Service_Center__c;
	        }else if(returnLabelFor == 'Return Location'){
	        	locationId = caseRecord.ReturnLocation__c;
	        }
	    	validateCaseBeforShipment();
			shipmateSetById = ShipmateUtility.getShipmentSettings(locationId);
	    	if(shipmateSetById != null && !shipmateSetById.isEmpty()){
	    		//if only settings found then make the first one as default
	    		if(shipmateSetById.size() == 1){
	    			shipmateSet = shipmateSetById.values().get(0);
	    			//Adding option for user to select shipping method
		    		shipmentSetting.ShippingCarrier__c = shipmateSet.ShippingCarrier__c; 
		    		shipmentSetting.ServiceType__c = shipmateSet.ServiceType__c;
			    	getDimension();
			        
	    		}else{
	    			//multiple option found show  option to users
	    			isValid = false;
	    			selectedShippingCarrier = '';
	    			shippingCarriers.add(new SelectOption('','--None--',true));
	    			for(ShipmentSetting__c setting : shipmateSetById.values()){
	    				shippingCarriers.add(new SelectOption(setting.id,setting.ShippingCarrier__c ));
	    			}
	    			//work around to initiate with any one shipping
	    			//shipmateSet = shipmateSetById.values().get(0);
	    			getDimension();
	    		}
	    		
	    		
	    	}else{
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Shipping_Preference_found));
	    	}
	    	
	    	
    	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateReturnShipmate ',true,
    								ApplicationLiterals.RMA_SHIPPING_ERROR,workingObjectId,caseRecordId,null);
    	}
    	
    }
    
    public void initiateCreateOutboundShipmate(){
    	
     	try{
     		isReturn = false;
	    	isCreateLabelIntiate = true;
	    	caseRecord = getCaseDetails();
	    	if(returnLabelFor == 'Service Center'){
	        	locationId = caseRecord.Service_Center__c;
	        }else if(returnLabelFor == 'Return Location'){
	        	locationId = caseRecord.ReturnLocation__c;
	        }
	    	validateCaseBeforShipment();
	    	shipmateSetById = ShipmateUtility.getShipmentSettings(locationId);
	    	//shipmateSet = ShipmateUtility.getShipmentSetting(locationId);
	    	if(shipmateSetById != null && !shipmateSetById.isEmpty()){
	    		//if only settings found then make the first one as default
	    		if(shipmateSetById.size() == 1){
	    			shipmateSet = shipmateSetById.values().get(0);
	    			//Adding option for user to select shipping method
		    		shipmentSetting.ShippingCarrier__c = shipmateSet.ShippingCarrier__c;
		    		shipmentSetting.ServiceType__c = shipmateSet.ServiceType__c;
			    	getDimension();
			        
	    		}else{
	    			//multiple option found show  option to users
	    			isValid = false;
	    			selectedShippingCarrier = '';
	    			shippingCarriers.add(new SelectOption('','--None--',true));
	    			for(ShipmentSetting__c setting : shipmateSetById.values()){
	    				shippingCarriers.add(new SelectOption(setting.id,setting.ShippingCarrier__c ));
	    			}
	    			//work around to initiate with any one shipping
	    			//shipmateSet = shipmateSetById.values().get(0);
	    			getDimension();
	    		}
	    		
	    	}else{
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Shipping_Preference_found));
	    	}
     	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateOutboundShipmate ',true,
    								ApplicationLiterals.RMA_SHIPPING_ERROR,workingObjectId,caseRecordId,null);
    		
    	}
    	
    }
    public void setShipmentSettingFromCarrier(){
    	if(selectedShippingCarrier != null && selectedShippingCarrier != '' && shipmateSetById.containsKey(selectedShippingCarrier)){
    		isValid = true;
    		shipmateSet = shipmateSetById.get(selectedShippingCarrier);
    		shipmentSetting.ShippingCarrier__c = shipmateSet.ShippingCarrier__c;
		    shipmentSetting.ServiceType__c = shipmateSet.ServiceType__c;
		    getDimension();
    	}else{
    		isValid = false;
    	}
    }
    public Case getCaseRecord() {
        return caseRecord;
    }
    
	private void validateCaseBeforShipment( ){
        String errorMessage = System.Label.PleaseSelect +' ';
        isValid = true;
        if(locationId == null ){
             errorMessage += System.Label.ServiceCenter +' ';
             isValid = false;
        }
        if(caseRecord.Product__c == null ){
             errorMessage += (!isValid ? ', ' : '')+ System.Label.ProductLabel;
             isValid = false;
        }
        if(!isValid){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage+'.'));
           
        }

    }
    
    private void processUPSShiping(){
		//getShipment Preference
        zkups__UPSShipmatePreference__c shipmatePref = ShipmateUtility.getUPSShipmentPreference(shipmateSet.UPSShipmatePreference__c);
        
        if(shipmatePref != null){
            //create bulkShipment
           	dimension.checkForUnitConversion();
            dimension.sortTheDimension();
          	zkups__BulkShipment__c bulkShipment =  ShipmateUtility.createUPSBulkShipmate(shipmatePref,true);
            bulkShipmentId = bulkShipment.Id;
            //create queued shipmate record
            zkups__CustomAddressSource__c customAddressSource = ShipmateUtility.getUPSCustomAddressSource(workingObject);
           	
            zkups__QueuedShipment__c queuedShipment = ShipmateUtility.createUPSQueuedShipment(shipmatePref, workingObject,
            												workingObjectId,caseRecord,shipmateSet,bulkShipment.Id,
                                                         	isReturn, true, returnDescriptionCls,customAddressSource.Id, serviceType);
             queuedShipmentId = queuedShipment.Id;
            //Create Queue package
         	
            
            zkups__QueuedPackage__c queuedPackage = ShipmateUtility.createUPSQueuedPackage(queuedShipment.Id, caseRecord.Product__r.Landed_Cost__c,
            															dimension,true); 
        } 
        
    }
    private void processFedExShiping(){
		//getShipment Preference
        zkfedex__ShipmatePreference__c shipmatePref = ShipmateUtility.getFedExShipmentPreference(shipmateSet.FedExShipmatePreference__c);
        if(shipmatePref != null){
            //create bulkShipment
           	dimension.checkForUnitConversion();
            dimension.sortTheDimension();
          	zkfedex__BulkShipment__c bulkShipment =  ShipmateUtility.createFedExBulkShipmate(shipmatePref,true);
            bulkShipmentId = bulkShipment.Id;
            //create queued shipmate record
            zkfedex__CustomAddressSource__c customAddressSource = ShipmateUtility.getFedExCustomAddressSource(workingObject);
            
            zkfedex__QueuedShipment__c queuedShipment = ShipmateUtility.createFedExQueuedShipment(shipmatePref, workingObject,
            												workingObjectId,caseRecord,shipmateSet,bulkShipment.Id,
                                                         	isReturn, true, returnDescriptionCls,customAddressSource.Id, serviceType);
             queuedShipmentId = queuedShipment.Id;
            //Create Queue package
         	
            
            zkfedex__QueuedPackage__c queuedPackage = ShipmateUtility.createFedExQueuedPackage(queuedShipment.Id, caseRecord.Product__r.Landed_Cost__c,
            															dimension,true); 
        } 
        
    }
    private  void getDimension(){
    	if(caseRecord.Product__r.Length__c != null && caseRecord.Product__r.Width__c != null && caseRecord.Product__r.Height__c != null){
    		dimension = new ShipmateUtility.DimensionBean(

                caseRecord.Product__r.Length__c,caseRecord.Product__r.Width__c,
                caseRecord.Product__r.Height__c,caseRecord.Product__r.Weight__c,shipmateSet,
                caseRecord.Product__r.DimensionUnits__c,caseRecord.Product__r.WeightUnits__c
            );
    	}else if(caseRecord.Product__r.Dimensions__c != null && caseRecord.Product__r.Dimensions__c != ''){
    		dimension = new ShipmateUtility.DimensionBean(caseRecord.Product__r.Dimensions__c,caseRecord.Product__r.Weight__c,shipmateSet,
    														caseRecord.Product__r.DimensionUnits__c,caseRecord.Product__r.WeightUnits__c);
    		
    	}
    }
    
    private void processMCShiping(){
        //getShipment Preference
        zkmulti__MCShipmate_Preference__c shipmatePref = ShipmateUtility.getMCShipmentPreference(shipmateSet.ShipmatePreference__c);
        if(shipmatePref != null){
            //create bulkShipment
            dimension.checkForUnitConversion();
            dimension.sortTheDimension();
			zkmulti__MCBulk_Shipment__c bulkShipment =  ShipmateUtility.createMCBulkShipmate(shipmatePref,true);
			System.debug(' processMCShipping->bulkShipment ::::: '+ bulkShipment);
            bulkShipmentId = bulkShipment.Id; 
            //create queued shipmate record
          	zkmulti__MCCustom_Address_Source__c customAddressSource = ShipmateUtility.getMCCustomAddressSource(workingObject);
            
            zkmulti__MCShipment__c mcShipment = ShipmateUtility.createMCShipment(shipmatePref, workingObject,workingObjectId,
            													caseRecord,shipmateSet,bulkShipment.Id,
                                                                isReturn, true, returnDescriptionCls,
                                                                customAddressSource.Id, serviceType, refNumber);
            queuedShipmentId = mcShipment.Id;
            
			if(mcShipment.zkmulti__Carrier__c == 'UPS'){
				zkmulti__MCShipment_Special_Services__c shipmentSS = new zkmulti__MCShipment_Special_Services__c(
				    zkmulti__Shipment__c = mcShipment.Id,
				    zkmulti__IntlReturnCustomsReturnType__c = '9', // 9 - Print Return Label
				    zkmulti__IntlReturnCustomsReturnDescription__c = 'Description'
				);
				insert shipmentSS;
			}
            
            //Create Queue package
            zkmulti__MCPackage__c mcPackage = ShipmateUtility.createMCPackage(mcShipment.Id,shipmateSet,
            																		caseRecord.Product__r.Landed_Cost__c,dimension,true);
            
    		
    		/*W-000236 Changes*/
    		if(!(mcShipment.zkmulti__Sender_Country__c == mcShipment.zkmulti__Recipient_Country__c)) {
    			zkmulti__MCCustoms_Item__c mcCustomItems = new zkmulti__MCCustoms_Item__c();
    			if(returnLabelFor == 'Return Location'){
    			
    				mcCustomItems = ShipmateUtility.createMCCustomsItem(mcShipment.Id,shipmateSet,1,caseRecord.Product__r.Landed_Cost__c,
    													caseRecord.currencyISOCode,true, caseRecord.Product__r.Country_of_Manufacture__c,
    													caseRecord.Product__r.Description);
    			}
    			else{
    				mcCustomItems = ShipmateUtility.createMCCustomsItem(mcShipment.Id,shipmateSet,1, 
    													caseRecord.Product__r.Landed_Cost__c,caseRecord.currencyISOCode,true,
    													caseRecord.Product__r.Country_of_Manufacture__c,
    													caseRecord.Product__r.Description);
    			}
    		}
        } 
    }
    
    public void createReturnShipmate(){
    	try{
    		
    		//Case Service Center shouldn't be blank
	        isSuccess = false;
	        if(locationId != null){
	            //shipmateSet = ShipmateUtility.getShipmentSetting(caseRecord.Service_Center__c);
	            if(shipmateSet != null){
	            	serviceType = shipmentSetting.ServiceType__c;
	            	if(createBoxOrder && caseRecord.Product__r.Service_Return_Box__c != null){
		            	Utility.createBoxOrderRecordFromCase(caseRecord.Id);
		            }
	                if(shipmateSet.ShipmateApp__c == ApplicationLiterals.SHIPMATE_APP_NAME){
	                    processUPSShiping();
	                    isSuccess = true;
	                }else if(shipmateSet.ShipmateApp__c == ApplicationLiterals.MULTI_CARRIER_NAME){
	                	processMCShiping();
	                	isSuccess = true;
	                }else if(shipmateSet.ShipmateApp__c == 'FedEx'){
	                	processFedExShiping();
	                	isSuccess = true;
	                }
	            }else{
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Shipping_Preference_found));
	            }
	        }else{
	             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PleaseSelectServiceCenter));
	        }
    	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateOutboundShipmate ',true,
    								ApplicationLiterals.RMA_SHIPPING_ERROR,workingObjectId,caseRecordId,null);
    	}
    }
    
    public void processBulkShipment(){
		System.debug('::::: INSIDE processBulkShipment() :::::');
    	try{
    		if(!isSuccess && bulkShipmentId != null){
            	return;
	        }
	        if(shipmateSet.ShipmateApp__c == ApplicationLiterals.SHIPMATE_APP_NAME){
	        	
	            String batchId =  ShipmateUtility.processUPSBulkShipment(bulkShipmentId,false);
				List<zkups__QueuedShipmentStatus__c> successList = new List<zkups__QueuedShipmentStatus__c>();
	            List<zkups__QueuedShipmentStatus__c> errorsList =  new List<zkups__QueuedShipmentStatus__c>();
	            
	            for(zkups__QueuedShipmentStatus__c queuedStatus : [SELECT zkups__StatusMessage__c,zkups__Shipment__c,
	             													zkups__QueuedShipment__r.WorkOrder__c,zkups__Status__c
											                        FROM zkups__QueuedShipmentStatus__c
											                        WHERE zkups__BatchId__c = :batchId  
											                        LIMIT 5]){
					if(queuedStatus.zkups__Status__c == ApplicationLiterals.SHIPMATE_STATUS_ERROR){
						errorsList.add(queuedStatus);
					}else if(queuedStatus.zkups__Status__c == ApplicationLiterals.SHIPMATE_SUCCESS ){
						successList.add(queuedStatus);
					}
	            }
	            if ( ! errorsList.isEmpty() ) {
	                        
	                String errorMessage = '';
	                for (zkups__QueuedShipmentStatus__c err : errorsList) {
	                    errorMessage = errorMessage + err.zkups__StatusMessage__c ;
	                }
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Validation Error: ' + errorMessage));
	                isSuccess = false;
	                getDimension();
	            
	            }else if(!successList.isEmpty()){
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.ShipmentRecordCreatedSuccessfully));
	            }else{
	            	isSuccess = false;
	            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown Error : Please contact System Adminstrator'));
	            	Error_Log__c error = ErrorLog.logErrorActivity('processUPSBulkShipment',
                                                    				'No queued Shipment Status record found', 
                                               	 					'CreateReturnLabelCtrl -processBulkShipment',true,
                                               	 					ApplicationLiterals.RMA_SHIPPING_ERROR
                                               						,workingObjectId,caseRecordId,null); 
                    getDimension();
	            }
	            
	        }else if(shipmateSet.ShipmateApp__c == 'FedEx'){
	            String batchId =  ShipmateUtility.processFedExBulkShipment(bulkShipmentId,false);
				List<zkfedex__QueuedShipmentStatus__c> successList = new List<zkfedex__QueuedShipmentStatus__c>();
	            List<zkfedex__QueuedShipmentStatus__c> errorsList =  new List<zkfedex__QueuedShipmentStatus__c>();
	            for(zkfedex__QueuedShipmentStatus__c queuedStatus : [SELECT zkfedex__StatusMessage__c,zkfedex__Shipment__c,
	             														zkfedex__QueuedShipment__r.WorkOrder__c,zkfedex__Status__c
											                        FROM zkfedex__QueuedShipmentStatus__c
											                        WHERE zkfedex__BatchId__c = :batchId  
											                        LIMIT 5]){
					if(queuedStatus.zkfedex__Status__c == ApplicationLiterals.SHIPMATE_STATUS_ERROR){
						errorsList.add(queuedStatus);
					}else if(queuedStatus.zkfedex__Status__c == ApplicationLiterals.SHIPMATE_SUCCESS ){
						successList.add(queuedStatus);
					}
	            }
	            if ( ! errorsList.isEmpty() ) {
	                String errorMessage = '';
	                for (zkfedex__QueuedShipmentStatus__c err : errorsList) {
	                    errorMessage = errorMessage + err.zkfedex__StatusMessage__c ;
	                }
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Validation Error: ' + errorMessage));
	                getDimension();
	                isSuccess = false;
	            
	            }else if(!successList.isEmpty()){
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.ShipmentRecordCreatedSuccessfully));
	            }else{
	            	getDimension();
	            	isSuccess = false;
	            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown Error : Please contact System Adminstrator'));
	            	Error_Log__c error = ErrorLog.logErrorActivity('processFedExBulkShipment',
                                                    				'No queued Shipment Status record found', 
                                               	 					'CreateReturnLabelCtrl -processBulkShipment',true,
                                               	 					ApplicationLiterals.RMA_SHIPPING_ERROR
                                               						,workingObjectId,caseRecordId,null);
                                     
	            }
	        }else if(shipmateSet.ShipmateApp__c == ApplicationLiterals.MULTI_CARRIER_NAME){
	        	
				String batchId =  ShipmateUtility.processMCBulkShipment(bulkShipmentId,false);
				System.debug(' batchId ::::: '+ batchId);
	        	/*List<zkmulti__MCQueued_Shipment_Status__c> successList = new List<zkmulti__MCQueued_Shipment_Status__c>();
	           	List<zkmulti__MCQueued_Shipment_Status__c> errorsList =  new List<zkmulti__MCQueued_Shipment_Status__c>();
	            for(zkmulti__MCQueued_Shipment_Status__c queuedStatus : [SELECT zkmulti__Status_Message__c,zkmulti__Queued_Shipment__r.WorkOrder__c,
	            																zkmulti__Shipment__c,zkmulti__Status__c
													                        FROM zkmulti__MCQueued_Shipment_Status__c
													                        WHERE zkmulti__BatchId__c = :batchId  
													                      LIMIT 5]){*/
				/*List<zkmulti__MCBulk_Shipment_Status__c> successList = new List<zkmulti__MCBulk_Shipment_Status__c>();
	           	List<zkmulti__MCBulk_Shipment_Status__c> errorsList =  new List<zkmulti__MCBulk_Shipment_Status__c>();
	           	List<zkmulti__MCBulk_Shipment_Status__c> bulkShipmentStatusList = [SELECT zkmulti__Status_Message__c, zkmulti__Status__c, zkmulti__Bulk_Shipment__c
																		FROM zkmulti__MCBulk_Shipment_Status__c
																		WHERE zkmulti__BatchId__c = :batchId LIMIT 5];*/
	            List<zkmulti__Shipment_Status__c> successList = new List<zkmulti__Shipment_Status__c>();
	           	List<zkmulti__Shipment_Status__c> errorsList =  new List<zkmulti__Shipment_Status__c>();
	           	List<zkmulti__Shipment_Status__c> bulkShipmentStatusList = [SELECT zkmulti__Status_Message__c, zkmulti__Status__c, zkmulti__Bulk_Shipment__c
																		FROM zkmulti__Shipment_Status__c
																		WHERE zkmulti__Batch_Id__c = :batchId LIMIT 5];
				System.debug(' bulkShipmentStatusList ::::: '+ bulkShipmentStatusList);
	            for(zkmulti__Shipment_Status__c queuedStatus : bulkShipmentStatusList){
					if(queuedStatus.zkmulti__Status__c == ApplicationLiterals.SHIPMATE_STATUS_ERROR){
						errorsList.add(queuedStatus);
					}else if(queuedStatus.zkmulti__Status__c == ApplicationLiterals.SHIPMATE_SUCCESS ){
						successList.add(queuedStatus);
					}
	           	}
				if ( ! errorsList.isEmpty() ) {
				            
				    String errorMessage = '';
				    for (zkmulti__Shipment_Status__c err : errorsList) {
				        errorMessage = errorMessage + err.zkmulti__Status_Message__c ;
				    }
				    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ValidationError + errorMessage));
				    isSuccess = false;
				    getDimension();
				
				}else if( ! successList.isEmpty() ){
				    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.ShipmentRecordCreatedSuccessfully));
				}else{
					getDimension();
					isSuccess = false;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown Error : Please contact System Adminstrator'));
					Error_Log__c error = ErrorLog.logErrorActivity('processMultiCarrierShipment',
                                                    				'No Shipment Status record found', 
                                               	 					'CreateReturnLabelCtrl -processBulkShipment',true,
                                               	 					ApplicationLiterals.RMA_SHIPPING_ERROR
                                               						,workingObjectId,caseRecordId,null);
				}
        	}
        	
    	}catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		ErrorLog.LogErrorActivity(ex, 'CreateReturnLabelCtrl -initiateCreateOutboundShipmate ',true,
    								ApplicationLiterals.RMA_SHIPPING_ERROR,workingObjectId,caseRecordId,null);
    		
    	}
       
    }
    
   
    
    public  Case getCaseDetails(){
    	String referenceField = 'Service_Center__r.';
    	if(returnLabelFor == 'Service Center'){
	        referenceField = 'Service_Center__r.';
	    }else if(returnLabelFor == 'Return Location'){
	    	referenceField = 'ReturnLocation__r.';
	    }
    	String queryStrng = 'SELECT  Id, Account.BillingCountryCode, Customer_Ship_City__c,Product__r.Dimensions__c,'
        						+'Product__r.Weight__c,currencyISOCode,Company_Name__c,'
        						+'Product__r.Country_of_Manufacture__c,Product__r.Description,'
                                +'Product__r.Width__c,Product__c, Product__r.Name,Product__r.Height__c,Product__r.Length__c,'
                                +'Product__r.DimensionUnits__c,Product__r.WeightUnits__c,Product__r.Service_Return_Box__c,' 
                                +'Product__r.Landed_Cost__c,Customer_Ship_Country__c, Customer_Email__c, Customer_Name__c,'
                                +'Customer_Phone__c, Customer_Ship_State__c, Customer_Ship_Address__c,'
                                +'Customer_Ship_Zip__c,Residential_Address__c,AccountId,ContactId,CaseNumber,'
                                +'RecordType.Name,ReturnLabelFor__c,ReturnLocation__c,Service_Center__c,'+referenceField+'Name__c,'
                                +referenceField+'ShippingCountryCode,'+referenceField+'ShippingStateCode,'+referenceField+'ShippingCity,'
                                +referenceField+'ShippingState,'+referenceField+'ShippingCountry,'
                                +referenceField+'ShippingStreet,'+referenceField+'ShippingPostalCode,'+referenceField+'Business_Email__c,'
                                +referenceField+'Phone,'+referenceField+'Residential_Address__c,'+referenceField+'AccountStateFormula__c,'
                                +referenceField+'Company_Name__c,'+referenceField+'Name,'+referenceField+'BusinessName__c '
                                +' FROM Case WHERE  Id =:caseRecordId LIMIT 1';
                                      
      Case currentCase = Database.query(queryStrng);
                   
      return currentCase;
   }
   
   public void cancel(){
   		isCreateLabelIntiate = false;
   }
}