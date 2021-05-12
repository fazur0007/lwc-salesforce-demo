({
    doLoadData : function(component,event,helper){
        helper.apex(component,helper,'doGetConfigDetails',{ recordId : component.get("v.recordId") })
        .then(function(result){
            console.log("******result******"+JSON.stringify(result));
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
    fetchDepValues: function(component, ListOfDependentFields) {
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        component.set("v.listDependingValues", dependentFields);        
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
    }
})