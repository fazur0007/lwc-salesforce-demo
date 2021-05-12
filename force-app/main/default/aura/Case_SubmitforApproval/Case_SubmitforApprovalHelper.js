({
    doInit : function(component, event, helper) {
        helper.apexUtil(component,'getCaseConfigData',{ recordId : component.get("v.recordId")})
        .then(function(result){
            component.set("v.caseconfig",result);
            window.caseconfig = result;
            console.log(JSON.stringify(caseconfig));
            component.set("v.showLoader",false);
            if(caseconfig.PriceCalculationRequired__c){                
                helper.errorUtil(component,'Cases','Please calculate/recalculate price.','error');
                helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
            }else{
                if(caseconfig.Warranty__c === "" || (caseconfig.Warranty__c !== "" && caseconfig.Warranty__c == "Out of Warranty")){                    
                    helper.apexUtil(component,'updateCaseExtendWarranty',{ recordId : component.get("v.recordId")})
                    .then(function(result){
                        helper.errorUtil(component,'Cases','Case has been updated successfully','success');
                        helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
                    });
                }else{                    
                    helper.errorUtil(component,'Cases','Not Applicable on current Warranty Status','error');
                    helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
                }
            }
        })
        .catch(function(error) {
            helper.errorUtil(component,'Error',error,'error');
            console.log("error::"+JSON.stringify(error));
            component.set("v.showLoader",false);
            helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
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
                    helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
                    
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
            duration:'1000',
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
    },
})