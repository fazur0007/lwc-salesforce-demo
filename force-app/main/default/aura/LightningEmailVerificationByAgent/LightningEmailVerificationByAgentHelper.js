({
    doInit : function(component, event, helper) {
        helper.apexUtil(component,helper,'doSendVerifyEmail',{
            recordId : component.get("v.recordId")
        })
        .then(function(result){
            console.log(JSON.stringify(result));
            if(result.Result === "Success"){
                component.set("v.objectConfig",result.UserDetails);
                helper.errorUtil(component,'Account','Verification link has been sent','success');
                component.set("v.showSucess",true);
                component.set("v.showLoader",false);
            }else if(result.Result === "Error"){
                helper.errorUtil(component,'Account',result.UserDetails,'warning');
                helper.navigationUtil(component,"view","Account",component.get("v.recordId"));
                component.set("v.showLoader",false);
            }
        })
    },
    apexUtil : function(component,helper, apexMethod, params ) {
        return new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexMethod+"");
            action.setParams( params );
            action.setCallback( this , function(response) {
                if(response.getState()=='SUCCESS') {
                    resolve( response.getReturnValue() );
                }else if(response.getState()=='ERROR') {    
                    helper.errorUtil(component,'Error',response.getError()[0].message,'error');   
                    helper.navigationUtil(component,"view","Account",component.get("v.recordId")); 
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