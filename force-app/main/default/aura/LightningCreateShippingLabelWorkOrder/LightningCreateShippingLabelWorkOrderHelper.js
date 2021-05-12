({
    doInitOperations : function(component,event,helper){
        helper.apex(component,helper,'initLoadConfig',{ workingObjectId : component.get("v.recordId") })
        .then(function(result){
            console.log(JSON.stringify(result));
            component.set("v.configDetails",result);
            component.set("v.showLoader",false);
            if(result.errorMessage){
                helper.errorUtil(component,'Error',result.errorMessage,'error');
            }
        });
    },
    doCancel : function (component,event,helper){
        component.set("v.isCreateLabelIntiate",false);
    },
    doCreateReturnLabel : function(component,event,helper){
        component.set("v.showLoader",true);
        var configDetails = component.get("v.configDetails");
        helper.apex(component,helper,'initiateCreateReturnShipmate',{
            workingObjectId : component.get("v.recordId"),
            caseRecordId : configDetails.workOrder[0].CaseId,
            returnLabelFor : component.get("v.returnLabelFor"),
            isValid : component.get("v.isValid")
        })
        .then(function(result){
            console.log("doCreateReturnLabel***"+JSON.stringify(result));
            component.set("v.shipmentDetails",result);
            component.set("v.configShipmentDetails",result);
            component.set("v.dimension",JSON.parse(result.dimension));
            component.set("v.isCreateLabelIntiate",result.isCreateLabelIntiate);
            component.set("v.shipmateSet",result.shipmateSet);
            component.set("v.shipmentSetting",result.shipmentSetting);
            component.set("v.showLoader",false);
            //component.find("selectedServiceType").set("v.value", result.shipmentSetting.ServiceType__c);
            if(result.errorMessage){
                helper.errorUtil(component,'Error',result.errorMessage,'error');
            }
        });
    },
    doCreateOutboundLabel : function(component,event,helper){
        component.set("v.showLoader",true);
        var configDetails = component.get("v.configDetails");
        helper.apex(component,helper,'initiateCreateOutboundShipmate',{
            workingObjectId : component.get("v.recordId"),
            caseRecordId : configDetails.workOrder[0].CaseId, 
            returnLabelFor : component.get("v.returnLabelFor"),
            isValid : component.get("v.isValid")
        })
        .then(function(result){
            console.log("doCreateOutboundLabel***"+JSON.stringify(result));
            component.set("v.shipmentDetails",result);
            component.set("v.configShipmentDetails",result);
            component.set("v.dimension",JSON.parse(result.dimension));
            component.set("v.isCreateLabelIntiate",result.isCreateLabelIntiate);
            component.set("v.shipmateSet",result.shipmateSet);
            component.set("v.shipmentSetting",result.shipmentSetting);
            component.set("v.showLoader",false);
            //component.find("selectedServiceType").set("v.value", result.shipmentSetting.ServiceType__c);
            if(result.errorMessage){
                helper.errorUtil(component,'Error',result.errorMessage,'error');
            }
        });
    },
    errorUtil : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 1000',
            key: 'error_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    }, 
    apex : function( component,helper, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                    reject( callbackResult.getError()[0].message);
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    },
    navigationUtil : function(component,actionName,objectApiName,recordId){
        var navLink = component.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: actionName,
                objectApiName: objectApiName,
                recordId : recordId
            },
        };
        navLink.navigate(pageRef, true);
    },
    doCreateReturnShipmate : function(component,event,helper){
        //console.log("****shipmentSetting***"+JSON.stringify(component.get("v.shipmentSetting")));
        //console.log("****shipmateSet***"+JSON.stringify(component.get("v.shipmateSet")));
        component.set("v.showLoader",true);
        var configDetails = component.get("v.configDetails");
        var shipmentDetails = component.get("v.shipmentDetails");
        var landedCost = component.find("Landed_Cost").get("v.value");
        if(landedCost && landedCost > 0){
            helper.apex(component,helper,'createReturnShipmate',{
                workingObjectId : component.get("v.recordId"),
                caseRecordId : configDetails.workOrder[0].CaseId,
                locationId : shipmentDetails.locationId,             
                shipmentSetting : JSON.stringify(component.get("v.shipmentSetting")),
                shipmateSet     : JSON.stringify(component.get("v.shipmateSet")),
                createBoxOrder : component.get("v.createBoxOrder"),
                workingObject : component.get("v.workingObject"),
                isReturn : shipmentDetails.isReturn,
                returnDescriptionCls : component.get("v.returnDescriptionCls"),
                returnLabelFor : component.get("v.returnLabelFor"),
                refNumber : component.get("v.refNumber"),            
                selectedShippingCarrier : component.get("v.selectedShippingCarrier"),
                selectedServiceType : component.get("v.selectedServiceType"),
                Landed_Cost : component.find("Landed_Cost").get("v.value"),
                dimension_weight  : component.find("dimension_weight").get("v.value"),
                dimension_length  : component.find("dimension_length").get("v.value"),
                dimension_width   : component.find("dimension_width").get("v.value"),
                dimension_height  : component.find("dimension_height").get("v.value")
            })
            .then(function(result){
                //console.log("api****"+JSON.stringify(result));
                return helper.apex(component,helper,'processBulkShipment',{
                    workingObjectId : component.get("v.recordId"),
                    caseRecordId : configDetails.workOrder[0].CaseId,
                    bulkShipmentId : result.bulkShipmentId,             
                    shipmateSet     : JSON.stringify(component.get("v.shipmateSet")),
                    isSuccess : result.isSuccess,
                    returnLabelFor : component.get("v.returnLabelFor"),
                });
            })
            .then(function(result){
                console.log("api final ****"+JSON.stringify(result));
                if(result.errorMessage){
                    helper.errorUtil(component,'Error',result.errorMessage,'error');
                }
                if(result.ShipmentRecordCreatedSuccessfully){
                    helper.navigationUtil(component,"view","WorkOrder",component.get("v.recordId"));
                    helper.errorUtil(component,'Shipment Success Message!',result.ShipmentRecordCreatedSuccessfully,'success');
                }
                component.set("v.showLoader",false);
            });
        }else{
            helper.errorUtil(component,'Landed Cost Warning',"Landed Cost is required!",'warning');
        }
    },
    doSelectShippingCarrier : function(component,event,helper){ 
        var configDetails = component.get("v.configDetails");
        var shipmentDetails = component.get("v.shipmentDetails");
        helper.apex(component,helper,'setShipmentSettingFromCarrier',{ 
            caseRecordId : configDetails.workOrder[0].CaseId,
            returnLabelFor : component.get("v.returnLabelFor"),
            selectedShippingCarrier : component.find('selectedShippingCarrier').get('v.value'),
            locationId : shipmentDetails.locationId,
            shipmateSet     : JSON.stringify(component.get("v.shipmateSet")),
            shipmentSetting : JSON.stringify(component.get("v.shipmentSetting"))
        })
        .then(function(result){
            console.log(JSON.stringify(result));
            component.set("v.isValid",result.isValid);
            component.set("v.shipmateSet",result.shipmateSet);
            component.set("v.shipmentSetting",result.shipmentSetting);
            component.set("v.dimension",JSON.parse(result.dimension));
            component.set("v.showLoader",false);
            if(result.errorMessage){
                helper.errorUtil(component,'Error',result.errorMessage,'error');
            }
        });
    }
})