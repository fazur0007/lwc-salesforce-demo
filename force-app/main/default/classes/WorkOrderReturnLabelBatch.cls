global class WorkOrderReturnLabelBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable,Database.Stateful{
	
	private Id UPSbulkShipmentId;
	private Id FedExbulkShipmentId;
	private Id MCbulkShipmentId;
	private Id UPScustomAddressSourceID;
	private Id FedExcustomAddressSourceID;
	private Id MCcustomAddressSourceID;
	private String returnDescription = system.Label.RMAReturnDescription;
	private String workingObject = 'WorkOrder';
	public static String schduleBatchName = 'WorkOrderReturnLabelBatch';

	global WorkOrderReturnLabelBatch(){
        // Batch Constructor
    }
    global static void schduleBatch(){
        WorkOrderReturnLabelBatch bulkshipmentbatch = new WorkOrderReturnLabelBatch();
        String sch = '0 0 * * * ?';
        String jobID = system.schedule(schduleBatchName + ' Job', sch, bulkshipmentbatch);
    } 
    
    global void execute(SchedulableContext sc) {
        //check if alreay one batch is runnning then return this batch from execution
        if(!Utility.isBatchRunning('WorkOrderReturnLabelBatch')){
            Database.executeBatch(this, 1); 
        }
    }
    // Start Method
	global Database.QueryLocator start(Database.BatchableContext BC){
		
		String query = 'SELECT Id,ServiceCentre__c,CaseId,Activated__c,CreateBoxOrder__c, WorkOrderNumber FROM WorkOrder '
						+' WHERE RA_Tracking__c = null AND AutoReturnLabelStatus__c = \'Scheduled\' AND CC_Authorization_ID__c != null';
    	return Database.getQueryLocator(query);
    }
  
  	// Execute Logic
	global void execute(Database.BatchableContext BC, List<WorkOrder> workorders){
        System.debug('INSIDE EXECUTE workorders ::::: '+ workorders);
  		set<Id> caseIds = new set<Id>();
  		map<Id,list<RMA_Product__c>> RMAProductByCaseId = new   map<Id,list<RMA_Product__c>>();
  		
  		map<String,ShipmentSetting__c> shpmntStngsByRtrnLocIds = new map<String,ShipmentSetting__c>();
  		
  		map<Id,zkups__UPSShipmatePreference__c> UPSshipmatePreferencesById  = new map<Id,zkups__UPSShipmatePreference__c>();
  		map<Id,zkfedex__ShipmatePreference__c> FedExshipmatePreferencesById  = new map<Id,zkfedex__ShipmatePreference__c>();
  		map<Id,zkmulti__MCShipmate_Preference__c> MCshipmatePreferencesById = new map<Id,zkmulti__MCShipmate_Preference__c>();
  		
  		set<Id> returnLocations = new Set<Id>();
  		
  		list<UPSShipmateWrapper> UPSShipmates = new list<UPSShipmateWrapper>();
  		list<FedExShipmateWrapper> FedExShipmates = new list<FedExShipmateWrapper>();
  		list<MCShipmateWrapper> MCShipmates = new list<MCShipmateWrapper>();
  		
  		
  		list<Error_Log__c> errorLogs = new list<Error_Log__c>();
  		for(WorkOrder workorder : workorders){ 
  			returnLocations.add(workorder.ServiceCentre__c);
  			caseIds.add(workorder.CaseId);
  			workorder.AutoReturnLabelStatus__c = 'Processed';
  			if(workorder.CreateBoxOrder__c){
  				try{
					  Utility.createBoxOrderRecordFromCase(workorder.CaseId);
  				}catch(DMLException e){
					errorLogs.add(ErrorLog.logErrorActivity('error while creating box order',
	                                                    'error while creating box order', 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR));
					//errorLogs.add(error);
  				}
  			}
  		}
  		
  		//get case details
  		map<Id,Case> caseByCaseId = new map<Id,Case>([SELECT  Id, Customer_Ship_City__c,Product__r.Dimensions__c,Product__r.Weight__c,currencyISOCode,
  														Company_Name__c,
						                                Product__r.Width__c,Product__c, Product__r.Name,Product__r.Height__c,Product__r.Length__c,
						                                Product__r.DimensionUnits__c,Product__r.WeightUnits__c,Product__r.Service_Return_Box__c, 
						                                Product__r.Landed_Cost__c,Customer_Ship_Country__c, Customer_Email__c, Customer_Name__c,
						                                Customer_Phone__c, Customer_Ship_State__c, Customer_Ship_Address__c,
						                                Customer_Ship_Zip__c,Residential_Address__c,AccountId,ContactId,CaseNumber,
						                                RecordType.Name,ReturnLabelFor__c,ReturnLocation__c,Service_Center__c,
						                                Product__r.Country_of_Manufacture__c, Product__r.Description,
						                                Service_Center__r.ShippingCountryCode,Service_Center__r.ShippingStateCode,
						                                Service_Center__r.ShippingCity,
						                                Service_Center__r.ShippingState,Service_Center__r.ShippingCountry,
						                                Service_Center__r.ShippingStreet,Service_Center__r.ShippingPostalCode,
						                                Service_Center__r.Business_Email__c,
						                                Service_Center__r.Phone,Service_Center__r.Residential_Address__c,
						                                Service_Center__r.AccountStateFormula__c,Service_Center__r.Name__c,
						                                Service_Center__r.Company_Name__c,Service_Center__r.Name,Service_Center__r.BusinessName__c 
					                                FROM Case WHERE  Id IN:caseIds ]);
		
  		//get shipment Setings
  		shpmntStngsByRtrnLocIds = ShipmateUtility.getShpmntStngsByRtrnLocIds(returnLocations);
  		
  		for(ShipmentSetting__c shipmateSet :shpmntStngsByRtrnLocIds.values()){ 
  			if(shipmateSet.ShipmatePreference__c != null){
  				MCshipmatePreferencesById.put(shipmateSet.ShipmatePreference__c,null);
  			}else if(shipmateSet.UPSShipmatePreference__c != null){
  				UPSshipmatePreferencesById.put(shipmateSet.UPSShipmatePreference__c,null);
  			}else if(shipmateSet.FedExShipmatePreference__c != null){
  				FedExshipmatePreferencesById.put(shipmateSet.FedExShipmatePreference__c,null);
  			} 
  		}
  		if(!UPSshipmatePreferencesById.isEmpty()){
  			UPSshipmatePreferencesById = ShipmateUtility.getUPSShipmentPreferences(UPSshipmatePreferencesById.keySet());
  		}
  		if(!MCshipmatePreferencesById.isEmpty()){
  			MCshipmatePreferencesById = ShipmateUtility.getMCShipmentPreferences(MCshipmatePreferencesById.keySet());
  		}
  		if(!FedExshipmatePreferencesById.isEmpty()){
  			FedExshipmatePreferencesById = ShipmateUtility.getFedExShipmentPreferences(FedExshipmatePreferencesById.keySet());
  		}
  		
  		ShipmentSetting__c shipmateSet;
  		
  		for(WorkOrder workorder : workorders){ 
  			
  			Case caseRec = caseByCaseId.get(workorder.CaseId);
  			
  			if(shpmntStngsByRtrnLocIds.containsKey(workorder.ServiceCentre__c)){
  				shipmateSet = shpmntStngsByRtrnLocIds.get(workorder.ServiceCentre__c);
  				if(shipmateSet.ShipmateApp__c == 'UPS'){
                    processUPSBulkShipment(UPSShipmates,caseRec,workorder.Id,
                    					UPSshipmatePreferencesById.get(shipmateSet.UPSShipmatePreference__c),shipmateSet);
                }else if(shipmateSet.ShipmateApp__c == 'Multi Carrier'){
					processMCBulkShipment(MCShipmates,caseRec,workorder.Id,
                							MCshipmatePreferencesById.get(shipmateSet.ShipmatePreference__c),shipmateSet, workorder.WorkOrderNumber);
                }else if(shipmateSet.ShipmateApp__c == 'FedEx'){
                	processFedExBulkShipment(FedExShipmates,caseRec,workorder.Id,
                    					FedExshipmatePreferencesById.get(shipmateSet.FedExShipmatePreference__c),shipmateSet);
                }
  			}else{
  				//Log error no shipment prerfer found
  				//log a error record 
            	errorLogs.add(ErrorLog.logErrorActivity('WorkOrderReturnLabelBatch excute method', 
                                                'NO  shipmate setting found for return address','WorkOrderReturnLabelBatch',false,
                                                 ApplicationLiterals.RMA_SHIPPING_ERROR,workorder.Id,workorder.Id,null));
  			}
  		}
  		if(UPSShipmates != null && !UPSShipmates.isEmpty()){
  			list<zkups__QueuedShipment__c> queuedShipments = new list<zkups__QueuedShipment__c>();
			list<zkups__QueuedPackage__c> queuedPackages = new list<zkups__QueuedPackage__c>();
  			for(UPSShipmateWrapper UPSWrap : UPSShipmates ){
  				queuedShipments.add(UPSWrap.queuedShipment);
  			}
  			
  			Database.SaveResult[] results = Database.insert(queuedShipments, false);
	        for (Integer i = 0; i < queuedShipments.size(); i++) {
	            if (! results[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting UPS queued shipments',
	                                                    results[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedShipments[i].get('Case__c')),String.valueOf(queuedShipments[i].get('Case__c')),null)); 
	                //errorLogs.add(error);
	            }
	        }
	          			
  			for(UPSShipmateWrapper UPSWrap : UPSShipmates ){
  				if(UPSWrap.queuedShipment.Id != null){
	  				UPSWrap.queuedPackage.zkups__QueuedShipment__c = UPSWrap.queuedShipment.Id;
  				}
  				queuedPackages.add(UPSWrap.queuedPackage);
  			}
  			Database.SaveResult[] queuedPackagesResults = Database.insert(queuedPackages, false);
  			for (Integer i = 0; i < queuedPackages.size(); i++) {
	            if (! queuedPackagesResults[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting UPS queued shipments',
	                                                    queuedPackagesResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedPackages[i].get('zkups__QueuedPackage__c')),null,null)); 
	                //errorLogs.add(error);
	            }
	        }
  		}
  		if(FedExShipmates != null && !FedExShipmates.isEmpty()){
  			list<zkfedex__QueuedShipment__c> queuedShipments = new list<zkfedex__QueuedShipment__c>();
			list<zkfedex__QueuedPackage__c> queuedPackages = new list<zkfedex__QueuedPackage__c>();
  			for(FedExShipmateWrapper FedExWrap : FedExShipmates ){
  				queuedShipments.add(FedExWrap.queuedShipment);
  			}
  			Database.SaveResult[] results = Database.insert(queuedShipments, false);
	        for (Integer i = 0; i < queuedShipments.size(); i++) {
	            if (! results[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting FedEx queued shipments',
	                                                    results[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedShipments[i].get('Case__c')),String.valueOf(queuedShipments[i].get('Case__c')),null)); 
	                //errorLogs.add(error);
	            }
	        }
	          			
  			for(FedExShipmateWrapper FedExWrap : FedExShipmates ){
  				if(FedExWrap.queuedShipment.Id != null){
	  				FedExWrap.queuedPackage.zkfedex__QueuedShipment__c = FedExWrap.queuedShipment.Id;
  				}
  				queuedPackages.add(FedExWrap.queuedPackage);
  			}
  			Database.SaveResult[] queuedPackagesResults = Database.insert(queuedPackages, false);
  			for (Integer i = 0; i < queuedPackages.size(); i++) {
	            if (! queuedPackagesResults[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting FedEx queued Packages shipments',
	                                                    queuedPackagesResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedPackages[i].get('zkfedex__QueuedPackage__c')),null,null)); 
	                //errorLogs.add(error);
	            }
	        }
  		}
  		
  		if(MCShipmates != null && !MCShipmates.isEmpty()){
        
  			list<zkmulti__MCShipment__c> mcQueuedShipments = new list<zkmulti__MCShipment__c>();
			list<zkmulti__MCPackage__c> mcQueuedPackages = new list<zkmulti__MCPackage__c>();
			list<zkmulti__MCCustoms_Item__c> mcQueuedPackageItems = new list<zkmulti__MCCustoms_Item__c>();
			list<zkmulti__MCShipment_Special_Services__c> mcSpecialServices = new list<zkmulti__MCShipment_Special_Services__c>();
  			for(MCShipmateWrapper MCWrap : MCShipmates ){
  				mcQueuedShipments.add(MCWrap.mcShipment);
  			}
  			//insert mcQueuedShipments;
  			Database.SaveResult[] mcQueuedShipmentsResults = Database.insert(mcQueuedShipments, false);
	        for (Integer i = 0; i < mcQueuedShipments.size(); i++) {
	            if (! mcQueuedShipmentsResults[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting Multi Carrier queued shipments',
	                                                    mcQueuedShipmentsResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(mcQueuedShipments[i].get('Case__c')),
	                                                String.valueOf(mcQueuedShipments[i].get('Case__c')),null)); 
	                //errorLogs.add(error);
	            }
	        }
  			
  			for(MCShipmateWrapper MCWrap : MCShipmates ){
  				if(MCWrap.mcShipment.Id != null){
	  				MCWrap.mcPackage.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
					mcQueuedPackages.add(MCWrap.mcPackage);
					MCWrap.mcCustomsItem.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
					mcQueuedPackageItems.add(MCWrap.mcCustomsItem);
					  
					if(MCWrap.mcShipment.zkmulti__Carrier__c == 'UPS'){
						MCWrap.specialServices.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
						mcSpecialServices.add(MCWrap.specialServices);
					}
  				}
  			}
			
  			Database.SaveResult[] mcQueuedPackagesResults = Database.insert(mcQueuedPackages, false);
  			for (Integer i = 0; i < mcQueuedPackages.size(); i++) {
	            if (! mcQueuedPackagesResults[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting Multi Carrier packages',
	                                                    mcQueuedPackagesResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                'zkmulti__MCPackage__c ',null,null)); 
	                //errorLogs.add(error);
	            }
	        }
	        
	        /*for(MCShipmateWrapper MCWrap : MCShipmates ){
	        	if(MCWrap.mcShipment.Id != null){
	        		MCWrap.mcCustomsItem.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
  					mcQueuedPackageItems.add(MCWrap.mcCustomsItem);
	        	}
			  }*/
			  
  			//insert mcQueuedPackageItems;
	        Database.SaveResult[] mcQueuedPackageItemsResults = Database.insert(mcQueuedPackageItems, false);
  			for (Integer i = 0; i < mcQueuedPackageItems.size(); i++) {
	            if (! mcQueuedPackageItemsResults[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting Multi Carrier Customs items',
	                                                    mcQueuedPackageItemsResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                'MC Customs Item',null,null)); 
	                //errorLogs.add(error);
	            } 
			}
			  
  			//insert specialServices;
	        Database.SaveResult[] mcSpecialServicesResults = Database.insert(mcSpecialServices, false);
  			for (Integer i = 0; i < mcSpecialServices.size(); i++) {
	            if (! mcSpecialServicesResults[i].isSuccess()) {
	                errorLogs.add(ErrorLog.logErrorActivity('Error while inserting Multi Carrier Special Services',
													mcSpecialServicesResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                'MC Special Services',null,null)); 
	                //errorLogs.add(error);
	            } 
			}
  		}
  		
  		//update the RMA to in progress
  		List<WorkOrder> woList = new List<WorkOrder> ();
  		for(WorkOrder woRec : workorders){
  			if(woRec.RA_Tracking__c != null || woRec.RA_Tracking__c !=''){
  				woRec.Activated__c  = true;
  			}
  			woList.add(woRec);
  		}
  		
  		//update workorders
		Database.SaveResult[] woListUpdateResults = Database.update(woList, false);
		for (Integer i = 0; i < woList.size(); i++) {
	        if (! woListUpdateResults[i].isSuccess()) {
	            errorLogs.add(ErrorLog.logErrorActivity('Error while Updating Work Orders',
	                                                woListUpdateResults[i].errors[0].getMessage(), 
	                                                'WorkOrderReturnLabelBatch-execute method',false, 'ERROR while updating WorkOrders',
	                                                'Work Order',null,null)); 
	            //errorLogs.add(error);
	        }
	    }

  		if(!errorLogs.isEmpty()){
			try {
				insert errorLogs;
			} catch(exception ex){
				ErrorLog.LogErrorActivity(ex,'Error while execution WorkOrderReturnLabelBatch',true,'Error');
			}
  		}
 
	}
 
	global void finish(Database.BatchableContext BC){
		
        // Logic to be Executed at finish
        if(!Test.isRunningTest()){
        	if(UPSbulkShipmentId != null){
        		ShipmateUtility.processUPSBulkShipment(UPSbulkShipmentId, true);
        	}
	        if(MCbulkShipmentId != null){
	        	ShipmateUtility.processMCBulkShipment(MCbulkShipmentId, true);
	        }
	        if(FedExbulkShipmentId != null){
	        	ShipmateUtility.processFedExBulkShipment(FedExbulkShipmentId, true);
	        }
        }
        
	}
	private void processUPSBulkShipment(list<UPSShipmateWrapper> UPSShipmates,Case caseRec,Id workOrderid,
																			zkups__UPSShipmatePreference__c shipmatePref,
																			ShipmentSetting__c shipmateSet){
		
		if(UPSbulkShipmentId == null || UPScustomAddressSourceID == null){
			//Create a  bulk shipment record
			zkups__BulkShipment__c bulkShipment =  ShipmateUtility.createUPSBulkShipmate(shipmatePref,true);
			
            UPSbulkShipmentId = bulkShipment.Id;
            zkups__CustomAddressSource__c customAddressSource = ShipmateUtility.getUPSCustomAddressSource('WorkOrder');
            UPScustomAddressSourceID = customAddressSource.Id;
		}
		//create queued shipmates
			
		ShipmateUtility.DimensionBean dimension = getDimension(caseRec,shipmateSet);
		Decimal declaredValue = caseRec.Product__r.Landed_Cost__c;
		zkups__QueuedShipment__c queuedShipment = 
		ShipmateUtility.createUPSQueuedShipment(shipmatePref,workingObject,workOrderid,caseRec,shipmateSet,
																							UPSbulkShipmentId,true, false, 
																							returnDescription,UPScustomAddressSourceID, null);
	    zkups__QueuedPackage__c queuedPackage = ShipmateUtility.createUPSQueuedPackage(null,declaredValue,dimension,false);
	    UPSShipmates.add(new UPSShipmateWrapper(queuedShipment,queuedPackage));
	}

	private void processFedExBulkShipment(list<FedExShipmateWrapper> FedExShipmates,Case caseRec,Id workOrderid,
																			zkfedex__ShipmatePreference__c shipmatePref,
																			ShipmentSetting__c shipmateSet){
		
		if(FedExbulkShipmentId == null || FedExcustomAddressSourceID == null){
			//Create a  bulk shipment record
			zkfedex__BulkShipment__c bulkShipment =  ShipmateUtility.createFedExBulkShipmate(shipmatePref,true);
            FedExbulkShipmentId = bulkShipment.Id;
            zkfedex__CustomAddressSource__c customAddressSource = ShipmateUtility.getFedExCustomAddressSource('WorkOrder');
            FedExcustomAddressSourceID = customAddressSource.Id;
		}
		
		ShipmateUtility.DimensionBean dimension = getDimension(caseRec,shipmateSet);
		Decimal declaredValue = caseRec.Product__r.Landed_Cost__c;
		zkfedex__QueuedShipment__c queuedShipment = 
		ShipmateUtility.createFedExQueuedShipment(shipmatePref,workingObject,workOrderid,caseRec,shipmateSet,
																					FedExbulkShipmentId,true, false, 
																					returnDescription,FedExcustomAddressSourceID, null);
        zkfedex__QueuedPackage__c queuedPackage = ShipmateUtility.createFedExQueuedPackage(null,declaredValue,dimension,false);
        FedExShipmates.add(new FedExShipmateWrapper(queuedShipment,queuedPackage));
	}

	private void processMCBulkShipment(list<MCShipmateWrapper> MCShipmates,Case caseRec,Id workOrderid,
																		zkmulti__MCShipmate_Preference__c shipmatePref,
																		ShipmentSetting__c shipmateSet, String workOrderNumber){
		if(MCbulkShipmentId == null || MCcustomAddressSourceID == null){
			//Create a  bulk shipment record
			zkmulti__MCBulk_Shipment__c bulkShipment =  ShipmateUtility.createMCBulkShipmate(shipmatePref,true);
            MCbulkShipmentId = bulkShipment.Id; 
            zkmulti__MCCustom_Address_Source__c customAddressSource = ShipmateUtility.getMCCustomAddressSource('WorkOrder');
            MCcustomAddressSourceID = customAddressSource.Id;
		}
		
		//create queued shipmates
	
		ShipmateUtility.DimensionBean dimension = getDimension(caseRec,shipmateSet);
		if (dimension != null) {
			Decimal declaredValue = caseRec.Product__r.Landed_Cost__c;
			                                                 
			zkmulti__MCShipment__c mcShipment = ShipmateUtility.createMCShipment(shipmatePref, workingObject, workOrderid,
																					caseRec, shipmateSet, MCbulkShipmentId,
																					true, false, returnDescription, 
																					MCcustomAddressSourceID, shipmateSet.ServiceType__c, workOrderNumber);
		
			zkmulti__MCPackage__c mcPackage = ShipmateUtility.createMCPackage(null,shipmateSet,declaredValue,dimension,false);
			zkmulti__MCCustoms_Item__c mcCustomsItem = ShipmateUtility.createMCCustomsItem(mcShipment.Id,shipmateSet, 1.0, 
															caseRec.Product__r.Landed_Cost__c,caseRec.currencyISOCode,false,
															caseRec.Product__r.Country_of_Manufacture__c,
															caseRec.Product__r.Description);
															
			
			zkmulti__MCShipment_Special_Services__c shipmentSS = new zkmulti__MCShipment_Special_Services__c(
						zkmulti__IntlReturnCustomsReturnType__c = '9', // 9 - Print Return Label
						zkmulti__IntlReturnCustomsReturnDescription__c = 'Description'
					); 
			MCShipmates.add(new MCShipmateWrapper(mcShipment, mcPackage, mcCustomsItem,shipmentSS));
		}
		
	}
	
	public class UPSShipmateWrapper{
		zkups__QueuedShipment__c queuedShipment;
		zkups__QueuedPackage__c queuedPackage;
		
		public UPSShipmateWrapper(zkups__QueuedShipment__c queuedShipment,zkups__QueuedPackage__c queuedPackage){
			this.queuedShipment = queuedShipment;
			this.queuedPackage = queuedPackage;
		}
	}
	public class FedExShipmateWrapper{
		zkfedex__QueuedShipment__c queuedShipment;
		zkfedex__QueuedPackage__c queuedPackage;
		
		public FedExShipmateWrapper(zkfedex__QueuedShipment__c queuedShipment,zkfedex__QueuedPackage__c queuedPackage){
			this.queuedShipment = queuedShipment;
			this.queuedPackage = queuedPackage;
		}
	}
	
	public class MCShipmateWrapper{
		zkmulti__MCShipment__c mcShipment;
		zkmulti__MCPackage__c mcPackage; 
        zkmulti__MCCustoms_Item__c mcCustomsItem;
        zkmulti__MCShipment_Special_Services__c specialServices;
        
        public MCShipmateWrapper(zkmulti__MCShipment__c mcShipment,zkmulti__MCPackage__c mcPackage,
        							zkmulti__MCCustoms_Item__c mcCustomsItem,
        							zkmulti__MCShipment_Special_Services__c specialServices){
        	this.mcShipment = mcShipment;
			this.mcPackage = mcPackage;
			this.mcCustomsItem = mcCustomsItem;
			this.specialServices = specialServices;
        }
	}
	
	private  ShipmateUtility.DimensionBean getDimension(Case caseRec,ShipmentSetting__c shipmateSet){
		ShipmateUtility.DimensionBean dimension;
		if(caseRec.Product__r.Length__c != null && caseRec.Product__r.Width__c != null && caseRec.Product__r.Height__c != null){
			dimension = new ShipmateUtility.DimensionBean(
                caseRec.Product__r.Length__c,caseRec.Product__r.Width__c,
                caseRec.Product__r.Height__c,caseRec.Product__r.Weight__c,shipmateSet,
                caseRec.Product__r.DimensionUnits__c,caseRec.Product__r.WeightUnits__c
            );
		}else if(caseRec.Product__r.Dimensions__c != null && caseRec.Product__r.Dimensions__c != ''){
    		dimension = new ShipmateUtility.DimensionBean(caseRec.Product__r.Dimensions__c,caseRec.Product__r.Weight__c,shipmateSet,
    					caseRec.Product__r.DimensionUnits__c,caseRec.Product__r.WeightUnits__c);
    		
    	}
		if(dimension != null) {
    		dimension.checkForUnitConversion();
        	dimension.sortTheDimension();
		}
    	return dimension;
    }
}