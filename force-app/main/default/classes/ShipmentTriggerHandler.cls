public without sharing class ShipmentTriggerHandler{
     
    
    public static void UPSPopulateTheCaseIdFromWorkOrder(list<zkups__UPSShipment__c> shipments){
      set<Id> workOrderIds = new set<Id>();
        for (zkups__UPSShipment__c shipment : shipments) {
          if (shipment.WorkOrder__c != null )
            workOrderIds.add(shipment.WorkOrder__c);
        }
        map<Id,WorkOrder> workorderById = new map<Id,WorkOrder>([SELECT Id,CaseId 
                                      FROM WorkOrder 
                                      WHERE ID IN:workOrderIds]);
         
        for (zkups__UPSShipment__c shipment : shipments) {
          if (shipment.WorkOrder__c != null && workorderById.containsKey(shipment.WorkOrder__c )){
            shipment.zkups__Case__c = workorderById.get(shipment.WorkOrder__c).CaseId;
          } 
        }
         
    }
    public static void UPSPopulateTrackingDetailsInCaseAndWorkOrder(list<zkups__UPSShipment__c> shipments,
                                                    map<Id,zkups__UPSShipment__c> oldMap,Boolean isInsert) {
        try{
                
            list<SObject> sObjects = new list<SObject>();
            list<Case> caseForQCCounterUpdate = new list<Case>();
            set<Id> caseIds = new set<Id>();
            for (zkups__UPSShipment__c shipment : shipments) {
              if (shipment.zkups__SsProcessReturnShipment__c  && (shipment.Case__c != null || shipment.zkups__Case__c != null))
                caseIds.add(shipment.Case__c != null ? shipment.Case__c : shipment.zkups__Case__c);
            }
            map<Id,Case> caseById = new map<Id,Case>([SELECT Id, RA_Tracking__c,QC_Alert__c,Service_Center__c,RecordType.Name,RMAStatus__c 
                                  FROM Case WHERE Id IN:caseIds]);
             String oldTrackingIds;
             String newTrackingIds;
             Integer tackingIdfieldLength = Schema.SObjectType.Case.fields.RA_Tracking__c.getLength(); 
            for (zkups__UPSShipment__c shipment : shipments) {
                 
                 
                 //if return shipment
                 if( (isInsert || (shipment.zkups__StatusDescription__c != oldMap.get(shipment.Id).zkups__StatusDescription__c ))){
                            
                    if(shipment.zkups__SsProcessReturnShipment__c){
                      if (shipment.Case__c != null || shipment.zkups__Case__c != null ) {
                          Case caseRec = new Case(Id = shipment.Case__c != null ? shipment.Case__c : shipment.zkups__Case__c );
                          caseRec.RA_Tracking_Status__c = shipment.zkups__StatusDescription__c;
                          
                          //This case is only valid for RAMA
                          if(caseById != null && caseById.containsKey(caseRec.Id)){
                            if(isInsert && caseById.get(caseRec.Id).QC_Alert__c != null && caseById.get(caseRec.Id).Service_Center__c != null){
                              caseForQCCounterUpdate.add(caseById.get(caseRec.Id));
                            }
                            oldTrackingIds = caseById.get(caseRec.Id).RA_Tracking__c;
                            if(oldTrackingIds == null){
                              oldTrackingIds = '';
                            }
                            if(!oldTrackingIds.contains(shipment.zkups__MasterTrackingId__c)){
                              newTrackingIds = oldTrackingIds+(oldTrackingIds != '' ? ',' :'') + shipment.zkups__MasterTrackingId__c;
                              //check if it is below 255 characher le
                              caseRec.RA_Tracking__c  = newTrackingIds.length() <= tackingIdfieldLength ? 
                                      newTrackingIds : shipment.zkups__MasterTrackingId__c;
                            }
                            if(isInsert && caseById.get(caseRec.Id).RecordType.Name == 'RMA'){
                              caseRec.RMAStatus__c = 'Shipping Label Generated';
                              caseRec.Return_Carrier__c  = shipment.zkups__Carrier__c;
                              caseRec.Return_Tracking__c = caseRec.RA_Tracking__c;
                            }
                            
                          }
                          caseRec.RA_Delivered__c = shipment.zkups__Delivered__c;
                          caseRec.RA_Return_Date__c = shipment.zkups__ActualDeliveryDate__c;
                          sObjects.add(caseRec);
                      }
                      //check workorder also
                      if (shipment.WorkOrder__c != null ) {
                          WorkOrder workOrderRec= new WorkOrder(Id = shipment.WorkOrder__c);
                          workOrderRec.RA_Tracking_Status__c = shipment.zkups__StatusDescription__c;
                          workOrderRec.RA_Tracking__c = shipment.zkups__MasterTrackingId__c;
                          workOrderRec.RA_Delivered__c = shipment.zkups__Delivered__c;
                          workOrderRec.RA_Return_Date__c = shipment.zkups__ActualDeliveryDate__c;
                          sObjects.add(workOrderRec); 
                      }
                      
                    }else{
                      
                     if (shipment.WorkOrder__c != null ) {
                          WorkOrder workOrderRec= new WorkOrder(Id = shipment.WorkOrder__c);
                          workOrderRec.OutboundTrackingStatus__c   = shipment.zkups__StatusDescription__c;
                          workOrderRec.OutboundTracking__c = shipment.zkups__MasterTrackingId__c;
                          workOrderRec.OutboundDelivered__c = shipment.zkups__Delivered__c;
                          workOrderRec.OutboundDeliveryDate__c = shipment.zkups__ActualDeliveryDate__c;
                          sObjects.add(workOrderRec); 
                      }
                   }     
                    
                 } 
            }
        
            Database.SaveResult[] results = Database.update(sObjects, false);
            //handle error
            checkForErrors(results,sObjects);
            updateQCLocationCounter(caseForQCCounterUpdate);
        }catch(Exception ex){
          
            ErrorLog.LogErrorActivity(ex,'UPS ShipmentTriggerHandler',true,ApplicationLiterals.RMA_SHIPPING_ERROR);
            
        }
       
    }
     public static void FedExPopulateTheCaseIdFromWorkOrder(list<zkfedex__Shipment__c> shipments){
      set<Id> workOrderIds = new set<Id>();
        for (zkfedex__Shipment__c shipment : shipments) {
          if (shipment.WorkOrder__c != null )
            workOrderIds.add(shipment.WorkOrder__c);
        }
        map<Id,WorkOrder> workorderById = new map<Id,WorkOrder>([SELECT Id,CaseId 
                                      FROM WorkOrder 
                                      WHERE ID IN:workOrderIds]);
         
        for (zkfedex__Shipment__c shipment : shipments) {
          if (shipment.WorkOrder__c != null && workorderById.containsKey(shipment.WorkOrder__c )){
            shipment.Case__c = workorderById.get(shipment.WorkOrder__c).CaseId;
          } 
        }
         
    }
    public static void FedExPopulateTrackingDetailsInCaseAndWorkOrder(list<zkfedex__Shipment__c> shipments,
                                                    map<Id,zkfedex__Shipment__c> oldMap,Boolean isInsert) {
        
        try{
                
            list<SObject> sObjects = new list<SObject>();
            list<Case> caseForQCCounterUpdate = new list<Case>();
            set<Id> caseIds = new set<Id>();
            for (zkfedex__Shipment__c shipment : shipments) {
              if (shipment.zkfedex__SsProcessReturnShipment__c  && shipment.Case__c != null )
                caseIds.add(shipment.Case__c );
            }
            map<Id,Case> caseById = new map<Id,Case>([SELECT Id, RA_Tracking__c,QC_Alert__c,Service_Center__c,RecordType.Name,RMAStatus__c 
                                  						FROM Case 
                                  						WHERE Id IN:caseIds]);
            String oldTrackingIds;
            String newTrackingIds;
            Integer tackingIdfieldLength = Schema.SObjectType.Case.fields.RA_Tracking__c.getLength(); 
            for (zkfedex__Shipment__c shipment : shipments) {
                 
                 
                 if( shipment.zkfedex__MasterTrackingId__c != null && (isInsert 
                 				|| (shipment.zkfedex__StatusDescription__c != oldMap.get(shipment.Id).zkfedex__StatusDescription__c ) 
                 				|| (oldMap.get(shipment.Id).zkfedex__MasterTrackingId__c == null))){
                    
                    if(shipment.zkfedex__SsProcessReturnShipment__c){
                      if (shipment.Case__c != null  ) {
                      	
                          Case caseRec = new Case(Id = shipment.Case__c );
                          caseRec.RA_Tracking_Status__c = shipment.zkfedex__StatusDescription__c;
                          
                          //This case is only valid for RAMA
                          if(caseById != null && caseById.containsKey(caseRec.Id)){
                            
                            if(isInsert && caseById.get(caseRec.Id).QC_Alert__c != null && caseById.get(caseRec.Id).Service_Center__c != null){
                              caseForQCCounterUpdate.add(caseById.get(caseRec.Id));
                            }
                            oldTrackingIds = caseById.get(caseRec.Id).RA_Tracking__c;
                            if(oldTrackingIds == null){
                              oldTrackingIds = '';
                            }
                          
                            if(!oldTrackingIds.contains(shipment.zkfedex__MasterTrackingId__c)){
                              newTrackingIds = oldTrackingIds+(oldTrackingIds != '' ? ',' :'') + shipment.zkfedex__MasterTrackingId__c;
                              //check if it is below 255 characher le
                              caseRec.RA_Tracking__c  = newTrackingIds.length() <= tackingIdfieldLength ? 
                                      newTrackingIds : shipment.zkfedex__MasterTrackingId__c;
                            }
                            if(caseById.get(caseRec.Id).RecordType.Name == 'RMA' 
                            		&& (isInsert || oldMap.get(shipment.Id).zkfedex__MasterTrackingId__c == null)){
                              caseRec.RMAStatus__c = 'Shipping Label Generated';
                              caseRec.Return_Carrier__c  = shipment.zkfedex__Carrier__c;
                              caseRec.Return_Tracking__c = caseRec.RA_Tracking__c;
                            }
                            
                          }
                          caseRec.RA_Delivered__c = shipment.zkfedex__Delivered__c;
                          caseRec.RA_Return_Date__c = shipment.zkfedex__ActualDeliveryDate__c;
                          sObjects.add(caseRec);
                      }
                      //check workorder also
                      if (shipment.WorkOrder__c != null ) {
                          WorkOrder workOrderRec= new WorkOrder(Id = shipment.WorkOrder__c);
                          workOrderRec.RA_Tracking_Status__c = shipment.zkfedex__StatusDescription__c;
                          workOrderRec.RA_Tracking__c = shipment.zkfedex__MasterTrackingId__c;
                          workOrderRec.RA_Delivered__c = shipment.zkfedex__Delivered__c;
                          workOrderRec.RA_Return_Date__c = shipment.zkfedex__ActualDeliveryDate__c;
                          sObjects.add(workOrderRec); 
                      }
                      
                    }else{
                      
                     if (shipment.WorkOrder__c != null ) {
                          WorkOrder workOrderRec= new WorkOrder(Id = shipment.WorkOrder__c);
                          workOrderRec.OutboundTrackingStatus__c   = shipment.zkfedex__StatusDescription__c;
                          workOrderRec.OutboundTracking__c = shipment.zkfedex__MasterTrackingId__c;
                          workOrderRec.OutboundDelivered__c = shipment.zkfedex__Delivered__c;
                          workOrderRec.OutboundDeliveryDate__c = shipment.zkfedex__ActualDeliveryDate__c;
                          sObjects.add(workOrderRec); 
                      }
                   }     
                    
                 } 
            }
        
            Database.SaveResult[] results = Database.update(sObjects, false);
            //handle error
            checkForErrors(results,sObjects);
            updateQCLocationCounter(caseForQCCounterUpdate);
        }catch(Exception ex){
          
            ErrorLog.LogErrorActivity(ex,'FedEx ShipmentTriggerHandler',true,ApplicationLiterals.RMA_SHIPPING_ERROR);
            
        }
       
    }
    public static void MCSPopulateTheCaseIdFromWorkOrder(list<zkmulti__MCShipment__c> shipments){
      set<Id> workOrderIds = new set<Id>();
        for (zkmulti__MCShipment__c shipment : shipments) {
          if (shipment.WorkOrder__c != null )
            workOrderIds.add(shipment.WorkOrder__c);
        }
        map<Id,WorkOrder> workorderById = new map<Id,WorkOrder>([SELECT Id,CaseId 
                                      FROM WorkOrder 
                                      WHERE ID IN:workOrderIds]);
        
        for (zkmulti__MCShipment__c shipment : shipments) {
          if (shipment.WorkOrder__c != null && workorderById.containsKey(shipment.WorkOrder__c )){
            shipment.Case__c = workorderById.get(shipment.WorkOrder__c).CaseId;
          } 
        }
         
    }
    
    public static void MCPopulateTrackingDetailsInCaseAndWorkOrder(list<zkmulti__MCShipment__c> shipments,
                                                    map<Id,zkmulti__MCShipment__c> oldMap,Boolean isInsert) {
        
            list<SObject> sObjects = new list<SObject>();
            list<Case> caseForQCCounterUpdate = new list<Case>();
            set<Id> caseIds = new set<Id>();
            for (zkmulti__MCShipment__c shipment : shipments) {
              if (shipment.Case__c != null )
                caseIds.add(shipment.Case__c );
            }
            map<Id,Case> caseById = new map<Id,Case>([SELECT Id, RA_Tracking__c,QC_Alert__c,Service_Center__c,RecordType.Name FROM Case WHERE Id IN:caseIds]);
             String oldTrackingIds;
             String newTrackingIds;
             Integer tackingIdfieldLength = Schema.SObjectType.Case.fields.RA_Tracking__c.getLength();
            for (zkmulti__MCShipment__c shipment : shipments) {
                 
                 //if return shipment
                 //if( (isInsert || (shipment.zkmulti__Status_Description__c != oldMap.get(shipment.Id).zkmulti__Status_Description__c ) )){
                 if( (isInsert || (shipment.zkmulti__Status_Description__c != oldMap.get(shipment.Id).zkmulti__Status_Description__c ) || (shipment.zkmulti__Tracking_Number__c != oldMap.get(shipment.Id).zkmulti__Tracking_Number__c ))){
                            
                    if(shipment.zkmulti__Return_Shipment__c){
                      if (shipment.Case__c != null ) {
                          Case caseRec = new Case(Id = shipment.Case__c);
                          if(shipment.zkmulti__Status_Description__c != null && shipment.zkmulti__Tracking_Stage__c != null && shipment.zkmulti__Tracking_Stage__c.containsIgnoreCase(System.Label.In_Transit_Status)){
                            caseRec.RA_Tracking_Status__c = shipment.zkmulti__Tracking_Stage__c + ' '+ shipment.zkmulti__Status_Description__c;
                          } else {
                            caseRec.RA_Tracking_Status__c = shipment.zkmulti__Status_Description__c;
                          }
                          
                          if(caseById != null && caseById.containsKey(caseRec.Id)){
                            if(isInsert && caseById.get(caseRec.Id).QC_Alert__c != null && caseById.get(caseRec.Id).Service_Center__c != null){
                              caseForQCCounterUpdate.add(caseById.get(caseRec.Id));
                            }
                            oldTrackingIds = caseById.get(caseRec.Id).RA_Tracking__c;
                            if(oldTrackingIds == null){
                              oldTrackingIds = '';
                            }
                            if(shipment.zkmulti__Tracking_Number__c != null && !oldTrackingIds.contains(shipment.zkmulti__Tracking_Number__c)){
                              newTrackingIds = oldTrackingIds+(oldTrackingIds != '' ? ',':'') + shipment.zkmulti__Tracking_Number__c;
                              //check if it is below 255 characher le
                              caseRec.RA_Tracking__c  = newTrackingIds.length() <= tackingIdfieldLength ? 
                                      newTrackingIds : shipment.zkmulti__Tracking_Number__c;
                            }
                            if(isInsert && caseById.get(caseRec.Id).RecordType.Name == 'RMA'){
                              caseRec.RMAStatus__c = 'Shipping Label Generated';
                              caseRec.Return_Carrier__c  = shipment.zkmulti__Carrier__c;
                              caseRec.Return_Tracking__c = caseRec.RA_Tracking__c;
                            }
                            
                          }
                          caseRec.RA_Delivered__c = shipment.zkmulti__Delivered__c;
                          caseRec.RA_Return_Date__c = shipment.zkmulti__Delivery_Date__c;
                          sObjects.add(caseRec);
                      }
                      //check workorder also
                      if (shipment.WorkOrder__c != null ) {
                          WorkOrder workOrderRec= new WorkOrder(Id = shipment.WorkOrder__c);
                          if(shipment.zkmulti__Status_Description__c != null && shipment.zkmulti__Tracking_Stage__c != null && shipment.zkmulti__Tracking_Stage__c.containsIgnoreCase(System.Label.In_Transit_Status)){
                            workOrderRec.RA_Tracking_Status__c = shipment.zkmulti__Tracking_Stage__c + ' '+ shipment.zkmulti__Status_Description__c;
                          } else {
                            workOrderRec.RA_Tracking_Status__c = shipment.zkmulti__Status_Description__c;
                          }
                          //workOrderRec.RA_Tracking_Status__c = shipment.zkmulti__Status_Description__c;
                          workOrderRec.RA_Tracking__c = shipment.zkmulti__Tracking_Number__c;
                          workOrderRec.RA_Delivered__c = shipment.zkmulti__Delivered__c;
                          workOrderRec.RA_Return_Date__c = shipment.zkmulti__Delivery_Date__c;
                          sObjects.add(workOrderRec); 
                      }
                    }else {
                      
                      WorkOrder workOrderRec= new WorkOrder(Id = shipment.WorkOrder__c);
                        if(shipment.zkmulti__Status_Description__c != null && shipment.zkmulti__Tracking_Stage__c != null && shipment.zkmulti__Tracking_Stage__c.containsIgnoreCase(System.Label.In_Transit_Status)){
                          workOrderRec.OutboundTrackingStatus__c = shipment.zkmulti__Tracking_Stage__c + ' '+ shipment.zkmulti__Status_Description__c;
                        } else {
                          workOrderRec.OutboundTrackingStatus__c = shipment.zkmulti__Status_Description__c;
                        }
                        //workOrderRec.OutboundTrackingStatus__c = shipment.zkmulti__Status_Description__c;
                        workOrderRec.OutboundTracking__c = shipment.zkmulti__Tracking_Number__c;
                        workOrderRec.OutboundDelivered__c = shipment.zkmulti__Delivered__c;
                        workOrderRec.OutboundDeliveryDate__c = shipment.zkmulti__Delivery_Date__c;
                        sObjects.add(workOrderRec); 
                    }    
                    
                 }  
            }
        try{
            Database.SaveResult[] results = Database.update(sObjects, false);
            //handle error
            checkForErrors(results,sObjects);
            
            updateQCLocationCounter(caseForQCCounterUpdate);
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex,'MC ShipmentTriggerHandler',true,ApplicationLiterals.RMA_SHIPPING_ERROR);
        }
       
    }
    public static void  checkForErrors(Database.SaveResult[] results,list<SObject> sObjects){
        list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
        for (Integer i = 0; i < sObjects.size(); i++) {
            if (! results[i].isSuccess()) {
                
                String msg = '';
                msg += 'RA Tracking Status = ' + sObjects[i].get('RA_Tracking_Status__c')  + '\n';
                msg += 'RA Tracking = ' + sObjects[i].get('RA_Tracking__c') + '\n\n';
                msg += 'RA_Return_Date__c  = ' + sObjects[i].get('RA_Return_Date__c ') + '\n\n';
                msg += results[i].errors[0].getMessage();
                
                Error_Log__c error = ErrorLog.logErrorActivity(System.Label.ErrorLoadingUpsTrackingData,
                                                    msg, 
                                                'ShipmentTriggerHandler-UpdateRelatedCaseFromUps',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
                                                String.valueOf(sObjects[i].get('Id')),String.valueOf(sObjects[i].get('Id')),null); 
                errorLogs.add(error);
            }
        }
        insert  errorLogs;
    }
    public static void updateQCLocationCounter(list<Case> caseForQCCounterUpdate){
      
      set<String> qcAlertAndReturLocationCompositeKeys = new set<String>();
      for(Case caseRec : caseForQCCounterUpdate){
        qcAlertAndReturLocationCompositeKeys.add(caseRec.QC_Alert__c+''+caseRec.Service_Center__c);
      }
      
      map<String,QCLocation__c> qcLocationsByCompositeKey = new map<String,QCLocation__c>();
      
      for(QCLocation__c qcLoc : [SELECT Id, Count__c, QCAlertReturnLocationCompositeKey__c 
                    FROM QCLocation__c 
                    WHERE QCAlertReturnLocationCompositeKey__c IN :qcAlertAndReturLocationCompositeKeys]){
          qcLocationsByCompositeKey.put(qcLoc.QCAlertReturnLocationCompositeKey__c,qcLoc);            
      }
      String compositeKey = '';
      for(Case caseRec : caseForQCCounterUpdate){
        
        compositeKey = caseRec.QC_Alert__c+''+caseRec.Service_Center__c;
        if(qcLocationsByCompositeKey.containsKey(compositeKey)){
          if(qcLocationsByCompositeKey.get(compositeKey).Count__c != null){
            qcLocationsByCompositeKey.get(compositeKey).Count__c = qcLocationsByCompositeKey.get(compositeKey).Count__c + 1;
          }else{
            qcLocationsByCompositeKey.get(compositeKey).Count__c = 1;
          }
        }
      }
      list<QCLocation__c> qcLocationsForUpdate = qcLocationsByCompositeKey.values();
      if(qcLocationsForUpdate != null && !qcLocationsForUpdate.isEmpty()){
        Database.SaveResult[] results = Database.update(qcLocationsForUpdate, false);
        list<Error_Log__c> errorLogs = new list<Error_Log__c>(); 
          for (Integer i = 0; i < qcLocationsForUpdate.size(); i++) {
              if (! results[i].isSuccess()) {
                  
                  String msg = '';
                  msg += results[i].errors[0].getMessage();
                  Error_Log__c error = ErrorLog.logErrorActivity(System.Label.QCLocationCounterUpdate +' ',
                                                        msg, 
                                                    'ShipmentTriggerHandler-updateQCLocationCounter',false, ApplicationLiterals.RMA_SHIPPING_ERROR,
                                                    String.valueOf(qcLocationsForUpdate[i].get('Id')),
                                                    String.valueOf(qcLocationsForUpdate[i].get('Id')),null); 
                  errorLogs.add(error);
              }
          }
          insert  errorLogs;
      }
                    
      
      
    }

}