global class BulkRMAAutoShipmateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable,Database.Stateful{
	
	private Id UPSbulkShipmentId;
	private Id FedExbulkShipmentId;
	private Id MCbulkShipmentId;
	private Id UPScustomAddressSourceID;
	private Id FedExcustomAddressSourceID;
	private Id MCcustomAddressSourceID;
	private String returnDescription = system.Label.RMAReturnDescription;
	private String workingObject = 'Case';
	global BulkRMAAutoShipmateBatch(){
        // Batch Constructor
    }
    global static void schduleBatch(){
        BulkRMAAutoShipmateBatch bulkshipmentbatch = new BulkRMAAutoShipmateBatch();
        String sch = '0 0 * * * ?';
        String jobID = system.schedule('BulkRMAAutoShipmateBatch Job',sch, bulkshipmentbatch);
    } 
    
    global void execute(SchedulableContext sc) {
        //check if alreay one batch is runnning then return this batch from execution
        if(!Utility.isBatchRunning('BulkRMAAutoShipmateBatch')){
            Database.executeBatch(this, 50); 
        }
    }
    // Start Method
	global Database.QueryLocator start(Database.BatchableContext BC){
		
		String query = 'SELECT Id,RecordType.Name, Country__c, Pickup_Address_1__c, Pickup_Address_2__c, Pickup_City__c, Pickup_Postal_Code__c,CaseNumber,'
						+'AccountId,ContactId,currencyISOCode,Company_Name__c,'
						+'Pickup_State__c,Pickup_Country__c, Purchase_Invoice_No__c,Service_Center__c,Product__r.Dimensions__c,Product__r.Weight__c,'
						+'Service_Center__r.Name,Service_Center__r.ShippingCountryCode, Service_Center__r.ShippingStateCode,'
						+'Service_Center__r.ShippingCity, Service_Center__r.ShippingStreet, Service_Center__r.ShippingPostalCode,'
						+'Service_Center__r.Business_Email__c, Service_Center__r.Phone, Service_Center__r.Company_Name__c,'
						+'Service_Center__r.Residential_Address__c,Service_Center__r.Name__c,'
						+'Return_Address__c,Consignee_Contact_Name__c, Consignee_Phone__c, Consignee_Email__c FROM Case '
						+'WHERE RecordType.Name=\'RMA\' AND RMAStatus__c = \'Scheduled For Label Generation\'';
    	return Database.getQueryLocator(query);
    }
  
  	// Execute Logic
	global void execute(Database.BatchableContext BC, List<Case>cases){
        /*try{
        	
        }catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		ErrorLog.LogErrorActivity(ex, 'BulkRMAAutoShipmateBatch -execute ',true,
    								ApplicationLiterals.RMA_SHIPPING_ERROR,null,caseRecordId,null);
    		
    	}*/
  		// Logic to be Executed batch wise 
  		map<Id,Case> RMACaseById = new   map<Id,Case>();
  		map<Id,list<RMA_Product__c>> RMAProductByCaseId = new   map<Id,list<RMA_Product__c>>();
  		
  		map<String,ShipmentSetting__c> shipmentSettingsByReturnAddress = new map<String,ShipmentSetting__c>();
  		
  		map<Id,zkups__UPSShipmatePreference__c> UPSshipmatePreferencesById  = new map<Id,zkups__UPSShipmatePreference__c>();
  		map<Id,zkfedex__ShipmatePreference__c> FedExshipmatePreferencesById  = new map<Id,zkfedex__ShipmatePreference__c>();
  		map<Id,zkmulti__MCShipmate_Preference__c> MCshipmatePreferencesById = new map<Id,zkmulti__MCShipmate_Preference__c>();
  		
  		set<String> returnAdds = new Set<String>();
  		list<UPSShipmateWrapper> UPSShipmates = new list<UPSShipmateWrapper>();
  		list<FedExShipmateWrapper> FedExShipmates = new list<FedExShipmateWrapper>();
  		list<MCShipmateWrapper> MCShipmates = new list<MCShipmateWrapper>();
  		list<Error_Log__c> errorLogs = new list<Error_Log__c>();
  		for(Case RMA : cases){ 
            RMA.RMAStatus__c = 'Shipping Label Generation is In Progress';
  			RMACaseById.put(RMA.Id,RMA);
  			returnAdds.add(RMA.Return_Address__c);
  		}
  		
  		for( RMA_Product__c RMAPro : [SELECT Id, Name, Product__c, Quantity__c, Price__c, Case__c, Product__r.Country_of_Manufacture__c,
  										Product__r.Width__c,Product__r.Height__c,Product__r.Length__c,Product__r.Landed_Cost__c,
  										Product__r.Dimensions__c,Product__r.Weight__c,Product__r.DimensionUnits__c,Product__r.WeightUnits__c,
  										Product__r.Description FROM RMA_Product__c
  										WHERE Case__c IN :RMACaseById.keySet() ]){
  											
  			if(!RMAProductByCaseId.containsKey(RMAPro.Case__c)){
  				RMAProductByCaseId.put(RMAPro.Case__c,new list<RMA_Product__c>());
  			}
  			RMAProductByCaseId.get(RMAPro.Case__c).add(RMAPro);
  		}
  		//get shipment Setings
  		shipmentSettingsByReturnAddress = ShipmateUtility.getShipmentSettings(returnAdds);
		System.System.debug('shipmentSettingsByReturnAddress ::::: '+ shipmentSettingsByReturnAddress);
  		for(ShipmentSetting__c shipmateSet :shipmentSettingsByReturnAddress.values()){ 
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
			System.System.debug('MCshipmatePreferencesById ::::: '+ MCshipmatePreferencesById);
		}
  		if(!FedExshipmatePreferencesById.isEmpty()){
  			FedExshipmatePreferencesById = ShipmateUtility.getFedExShipmentPreferences(FedExshipmatePreferencesById.keySet());
  		}
  		ShipmentSetting__c shipmateSet;
  		for(Case RMA : cases){
  			if(shipmentSettingsByReturnAddress.containsKey(RMA.Return_Address__c)){
  				shipmateSet = shipmentSettingsByReturnAddress.get(RMA.Return_Address__c);
  				if(shipmentSettingsByReturnAddress.get(RMA.Return_Address__c).ShipmateApp__c == 'UPS'){
                    processUPSBulkShipment(UPSShipmates,RMA,RMAProductByCaseId.get(RMA.Id),
                    					UPSshipmatePreferencesById.get(shipmateSet.UPSShipmatePreference__c),shipmateSet);
                }else if(shipmentSettingsByReturnAddress.get(RMA.Return_Address__c).ShipmateApp__c == 'Multi Carrier' && shipmateSet.ShipmatePreference__c != null){
					processMCBulkShipment(MCShipmates,RMA,RMAProductByCaseId.get(RMA.Id),
                							MCshipmatePreferencesById.get(shipmateSet.ShipmatePreference__c),shipmateSet);
                }else if(shipmentSettingsByReturnAddress.get(RMA.Return_Address__c).ShipmateApp__c == 'FedEx'){
                	processFedExBulkShipment(FedExShipmates,RMA,RMAProductByCaseId.get(RMA.Id),
                    					FedExshipmatePreferencesById.get(shipmateSet.FedExShipmatePreference__c),shipmateSet);
                }
  			}else{
  				//Log error no shipment prerfer found
  				//log a error record 
            	errorLogs.add(ErrorLog.logErrorActivity('BulkRMAAutoShipmateBatch excute method', 
                                                'NO  shipmate setting found for return address','BulkRMAAutoShipmateBatch',false,
                                                 ApplicationLiterals.RMA_SHIPPING_ERROR,RMA.Id,RMA.Id,null));
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
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting UPS queued shipments',
	                                                    results[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedShipments[i].get('Case__c')),String.valueOf(queuedShipments[i].get('Case__c')),null); 
	                errorLogs.add(error);
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
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting UPS queued shipments',
	                                                    queuedPackagesResults[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedPackages[i].get('zkups__QueuedShipment__c')),null,null); 
	                errorLogs.add(error);
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
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting FedEx queued shipments',
	                                                    results[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedShipments[i].get('Case__c')),String.valueOf(queuedShipments[i].get('Case__c')),null); 
	                errorLogs.add(error);
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
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting FedEx queued Packages shipments',
	                                                    queuedPackagesResults[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(queuedPackages[i].get('zkfedex__QueuedShipment__c')),null,null); 
	                errorLogs.add(error);
	            }
	        }
  		}
  		
		System.System.debug('MCShipmates ::::: '+ MCShipmates);
  		if(MCShipmates != null && !MCShipmates.isEmpty()){
        
  			list<zkmulti__MCShipment__c> mcShipments = new list<zkmulti__MCShipment__c>();
			list<zkmulti__MCPackage__c> mcPackages = new list<zkmulti__MCPackage__c>();
			list<zkmulti__MCCustoms_Item__c> mcCustomsItems = new list<zkmulti__MCCustoms_Item__c>();
			List<zkmulti__MCShipment_Special_Services__c> shipmentSpecialServices = new List<zkmulti__MCShipment_Special_Services__c>();
			
  			for(MCShipmateWrapper MCWrap : MCShipmates ){
  				mcShipments.add(MCWrap.mcShipment);
  			}
  			System.System.debug('mcShipments ::::: '+ mcShipments);
  			Database.SaveResult[] mcShipmentsResults = Database.insert(mcShipments, false);
	        for (Integer i = 0; i < mcShipments.size(); i++) {
	            if (! mcShipmentsResults[i].isSuccess()) {
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while updating Multi Carrier shipments',
	                                                    mcShipmentsResults[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(mcShipments[i].get('Case__c')),
	                                                String.valueOf(mcShipments[i].get('Case__c')),null); 
	                errorLogs.add(error);
	            }
	        }
  			
  			for(MCShipmateWrapper MCWrap : MCShipmates ){
  				if(MCWrap.mcShipment.Id != null){
	  				MCWrap.mcPackage.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
	  				mcPackages.add(MCWrap.mcPackage);
	  				
	  				if(MCWrap.mcShipment.zkmulti__Carrier__c == 'UPS'){
	  					MCWrap.specialServices.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
	  					shipmentSpecialServices.add(MCWrap.specialServices);
	  				}
  				}
  			}
  			
  			Database.SaveResult[] mcPackagesResults = Database.insert(mcPackages, false);
  			for (Integer i = 0; i < mcPackages.size(); i++) {
	            if (! mcPackagesResults[i].isSuccess()) {
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting UPS queued packages',
	                                                    mcPackagesResults[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(mcPackages[i].get('zkmulti__Queued_Shipment__c')),null,null); 
	                errorLogs.add(error);
	            }
	        }
	        
            if(shipmentSpecialServices.size() > 0){
				Database.SaveResult[] mcSpecialServicesResult = Database.insert(shipmentSpecialServices, false);
                for (Integer i = 0; i < shipmentSpecialServices.size(); i++) {
                    if (! mcSpecialServicesResult[i].isSuccess()) {
                        Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting UPS special services',
                                                            mcSpecialServicesResult[i].errors[0].getMessage(), 
                                                        'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
                                                        String.valueOf(shipmentSpecialServices[i].get('zkmulti__Shipment__c')),null,null); 
                        errorLogs.add(error);
                    }
                }
            }
	        
            for(MCShipmateWrapper MCWrap : MCShipmates ){
	        	if(MCWrap.mcShipment.Id != null){
	        		MCWrap.mcCustomsItem.zkmulti__Shipment__c = MCWrap.mcShipment.Id;
  					mcCustomsItems.add(MCWrap.mcCustomsItem);
	        	}
  				
  			}
            
	        Database.SaveResult[] mcCustomsItemsResults = Database.insert(mcCustomsItems, false);
  			for (Integer i = 0; i < mcCustomsItems.size(); i++) {
	            if (! mcCustomsItemsResults[i].isSuccess()) {
	                Error_Log__c error = ErrorLog.logErrorActivity('Error while inserting MC Customs Items',
	                                                    mcCustomsItemsResults[i].errors[0].getMessage(), 
	                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
	                                                String.valueOf(mcCustomsItems[i].get('zkmulti__Shipment__c')),null,null); 
	                errorLogs.add(error);
	            }
	        }
  				
  		}
  		
		System.System.debug('cases ::::: '+ cases);
  		//update the RMA to in progress
  		Database.SaveResult[] casesToUpdate = Database.update(cases, false);
  		for (Integer i = 0; i < casesToUpdate.size(); i++) {
            if (! casesToUpdate[i].isSuccess()) {
                Error_Log__c error = ErrorLog.logErrorActivity('Error while updating Cases',
                                                    casesToUpdate[i].errors[0].getMessage(), 
                                                'BulkRMAAutoShipmateBatch-execute method',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
                                                'Case',null,null); 
                errorLogs.add(error);
            }
        }
  		
  		
  		if(!errorLogs.isEmpty()){
  			insert errorLogs;
  		}
 
	}
 
	global void finish(Database.BatchableContext BC){
		System.System.debug('MCbulkShipmentId ::::: '+ MCbulkShipmentId);
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
	private void processUPSBulkShipment(list<UPSShipmateWrapper> UPSShipmates,Case RMACase,list<RMA_Product__c> RMAProducts,
																			zkups__UPSShipmatePreference__c shipmatePref,
																			ShipmentSetting__c shipmateSet){
		
		if(UPSbulkShipmentId == null || UPScustomAddressSourceID == null){
			//Create a  bulk shipment record
			zkups__BulkShipment__c bulkShipment =  ShipmateUtility.createUPSBulkShipmate(shipmatePref,true);
			
            UPSbulkShipmentId = bulkShipment.Id;
            zkups__CustomAddressSource__c customAddressSource = ShipmateUtility.getUPSCustomAddressSource('Case');
            UPScustomAddressSourceID = customAddressSource.Id;
		}
		//create queued shipmates
		for(RMA_Product__c RMAProduct : RMAProducts){
			
			ShipmateUtility.DimensionBean dimension = getDimension(RMAProduct,shipmateSet);
			Decimal declaredValue = RMAProduct.Product__r.Landed_Cost__c;  //RMAProduct.Price__c != null ? RMAProduct.Price__c : RMAProduct.Product__r.Landed_Cost__c;
			for(Integer i=1;i<=RMAProduct.Quantity__c;i++){
				zkups__QueuedShipment__c queuedShipment = 
				ShipmateUtility.createUPSQueuedShipment(shipmatePref,workingObject,RMACase.Id,RMACase,shipmateSet,
																							UPSbulkShipmentId,true, false, 
																							returnDescription,UPScustomAddressSourceID, null);
	            zkups__QueuedPackage__c queuedPackage = ShipmateUtility.createUPSQueuedPackage(null,declaredValue,dimension,false);
	            UPSShipmates.add(new UPSShipmateWrapper(queuedShipment,queuedPackage));
			}
			
		}
	}
    
	private void processFedExBulkShipment(list<FedExShipmateWrapper> FedExShipmates,Case RMACase,list<RMA_Product__c> RMAProducts,
																			zkfedex__ShipmatePreference__c shipmatePref,
																			ShipmentSetting__c shipmateSet){
		
		if(FedExbulkShipmentId == null || FedExcustomAddressSourceID == null){
			//Create a  bulk shipment record
			zkfedex__BulkShipment__c bulkShipment =  ShipmateUtility.createFedExBulkShipmate(shipmatePref,true);
			
            FedExbulkShipmentId = bulkShipment.Id;
            zkfedex__CustomAddressSource__c customAddressSource = ShipmateUtility.getFedExCustomAddressSource('Case');
            FedExcustomAddressSourceID = customAddressSource.Id;
		}
		//create queued shipmates
		for(RMA_Product__c RMAProduct : RMAProducts){
			ShipmateUtility.DimensionBean dimension = getDimension(RMAProduct,shipmateSet);
			if(dimension != null){
				Decimal declaredValue = RMAProduct.Product__r.Landed_Cost__c;  //RMAProduct.Price__c != null ? RMAProduct.Price__c : RMAProduct.Product__r.Landed_Cost__c;
				for(Integer i=1;i<=RMAProduct.Quantity__c;i++){
					zkfedex__QueuedShipment__c queuedShipment = 
					ShipmateUtility.createFedExQueuedShipment(shipmatePref,workingObject,RMACase.Id,RMACase,shipmateSet,
																								FedExbulkShipmentId,true, false, 
																								returnDescription,FedExcustomAddressSourceID, null);
		            zkfedex__QueuedPackage__c queuedPackage = ShipmateUtility.createFedExQueuedPackage(null,declaredValue,dimension,false);
		            FedExShipmates.add(new FedExShipmateWrapper(queuedShipment,queuedPackage));
				}
			}
		}

	}
	private void processMCBulkShipment(list<MCShipmateWrapper> MCShipmates,Case RMACase,list<RMA_Product__c> RMAProducts,
																		zkmulti__MCShipmate_Preference__c shipmatePref,
																		ShipmentSetting__c shipmateSet){
		if(MCbulkShipmentId == null || MCcustomAddressSourceID == null){
			//Create a  bulk shipment record
			zkmulti__MCBulk_Shipment__c bulkShipment =  ShipmateUtility.createMCBulkShipmate(shipmatePref,true);
            MCbulkShipmentId = bulkShipment.Id; 
            zkmulti__MCCustom_Address_Source__c customAddressSource = ShipmateUtility.getMCCustomAddressSource('Case');
            MCcustomAddressSourceID = customAddressSource.Id;
		}
		System.System.debug('MCcustomAddressSourceID ::::: '+ MCcustomAddressSourceID);
		//create queued shipmates
		for(RMA_Product__c RMAProduct : RMAProducts){
			ShipmateUtility.DimensionBean dimension = getDimension(RMAProduct,shipmateSet);
			Decimal declaredValue = RMAProduct.Product__r.Landed_Cost__c; //RMAProduct.Price__c != null ? RMAProduct.Price__c : RMAProduct.Product__r.Landed_Cost__c;
            if(dimension != null) {
                for(Integer i=1;i<=RMAProduct.Quantity__c;i++){
                    zkmulti__MCShipment__c mcShipment = ShipmateUtility.createMCShipment(shipmatePref,workingObject,RMACase.Id,
                                                                            RMACase,shipmateSet,MCbulkShipmentId,
                                                                        true, false,returnDescription,MCcustomAddressSourceID, shipmateSet.ServiceType__c, RMACase.CaseNumber);                                 
                    //Create Queue package
                    zkmulti__MCPackage__c mcPackage = ShipmateUtility.createMCPackage(null,shipmateSet,declaredValue,dimension,false);
                    zkmulti__MCCustoms_Item__c mcCustomsItem = ShipmateUtility.createMCCustomsItem(mcShipment.Id,shipmateSet,1.0, 
                                                            RMAProduct.Product__r.Landed_Cost__c,RMACase.currencyISOCode,false,
                                                            RMAProduct.Product__r.Country_of_Manufacture__c,
                                                            RMAProduct.Product__r.Description);
                    
                    zkmulti__MCShipment_Special_Services__c shipmentSS = new zkmulti__MCShipment_Special_Services__c(
                        zkmulti__IntlReturnCustomsReturnType__c = '9', // 9 - Print Return Label
                        zkmulti__IntlReturnCustomsReturnDescription__c = 'Description'
                    );
                    MCShipmates.add(new MCShipmateWrapper(mcShipment,mcPackage,mcCustomsItem, shipmentSS));
                }
            }
		}
		System.System.debug('MCShipmates ::::: '+ MCShipmates);
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
	private  ShipmateUtility.DimensionBean getDimension(RMA_Product__c RMAProduct,ShipmentSetting__c shipmateSet){
		ShipmateUtility.DimensionBean dimension = new ShipmateUtility.DimensionBean(); 
		if(RMAProduct.Product__r.Length__c != null && RMAProduct.Product__r.Width__c != null && RMAProduct.Product__r.Height__c != null){
			dimension = new ShipmateUtility.DimensionBean(
                RMAProduct.Product__r.Length__c,RMAProduct.Product__r.Width__c,
                RMAProduct.Product__r.Height__c,RMAProduct.Product__r.Weight__c,shipmateSet,
                RMAProduct.Product__r.DimensionUnits__c,RMAProduct.Product__r.WeightUnits__c
            );
			dimension.checkForUnitConversion();
	        dimension.sortTheDimension();
		}else if(RMAProduct.Product__r.Dimensions__c != null && RMAProduct.Product__r.Dimensions__c != ''){
    		dimension = new ShipmateUtility.DimensionBean(RMAProduct.Product__r.Dimensions__c,RMAProduct.Product__r.Weight__c,shipmateSet,
    					RMAProduct.Product__r.DimensionUnits__c,RMAProduct.Product__r.WeightUnits__c);
    		
			dimension.checkForUnitConversion();
	        dimension.sortTheDimension();
		}
        	
	    return dimension;
    }
    
    
}