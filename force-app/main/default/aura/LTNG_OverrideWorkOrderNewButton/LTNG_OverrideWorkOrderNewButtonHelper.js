({
    RecordTypeSelectorController: function(component, event, helper) {
        helper.apexUtil(component,'getConfigData',{ workOrderId : component.get("v.recordId")})
        .then(function(result){
            component.set("v.config",result);
            window.config = result;
            console.log("result::"+config.Status);
            component.set("v.showLoader",false);
            if(config.Status && ( config.Status == "Completed" || config.Status == "Closed" ||  config.Status == "Unrepairable")){
                helper.apexUtil(component,'createClaim',{ workOrderId : component.get("v.recordId")})
                .then(function(result){
                    console.log("result final ::"+JSON.stringify(result));
                    helper.errorUtil(component,'Claim has been created','Claim Id - '+result,'success');
                    helper.navigationUtil(component,"view","WorkOrder",result);
                })
            }else{
                helper.errorUtil(component,'Info','Claim can only be submitted for Closed/Completed Work Order','error');
                helper.navigationUtil(component,"view","WorkOrder",component.get("v.recordId"));
            }
        })
        .catch(function(error) {
            helper.errorUtil(component,'Error',error,'error');
            console.log("error::"+JSON.stringify(error));
            component.set("v.showLoader",false);
        });
    },
    apexUtil : function(component, apexMethod, params ) {
        return new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexMethod+"");
            action.setParams( params );
            action.setCallback( this , function(response) {
                if(response.getState()=='SUCCESS') {
                    resolve( response.getReturnValue() );
                }
                if(response.getState()=='ERROR') {      
                    helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                    reject( response.getError());
                    component.set("v.showLoader",false);
                }
            });
            $A.enqueueAction( action );
        }));    
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
        $A.get('e.force:refreshView').fire();
    }
});