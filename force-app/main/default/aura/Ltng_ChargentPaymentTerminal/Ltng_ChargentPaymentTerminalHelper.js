({
    apexUtil : function(component, apexMethod, params,helper ) {
        return new Promise( $A.getCallback( function( resolve , reject,helper ) { 
            var action = component.get("c."+apexMethod+"");
            action.setParams( params );
            action.setCallback( this , function(response) {
                if(response.getState()=='SUCCESS') {
                    console.log("response.getReturnValue" + response.getReturnValue());
                    resolve( response.getReturnValue() );
                }
                console.log("response.getState " +response.getState());
                if(response.getState()=='ERROR') { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: response.getError()[0].message,
                        duration:' 1000',
                        key: 'error_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.showLoader",false);
                    //errorUtil(component,'Error',response.getError()[0].message,'error');
                    reject( response.getError());
                }
            });
            $A.enqueueAction( action );
        }));    
    },
    showModalHelper : function(component, event, helper,paymentId) {
        console.log("INSIDE showModalHelper ONE");
        helper.paymentRedirection(component,"view","ChargentOrders__ChargentOrder__c",paymentId);
        console.log("INSIDE showModalHelper TWO");
        /*
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            alert(response);
            if(response){  
                
                workspaceAPI.getAllTabInfo().then(function(response) {                
                    workspaceAPI.openSubtab({ 
                        parentTabId: response[0].tabId,
                        url: '/lightning/r/ChargentOrders__ChargentOrder__c/'+paymentId+'/view',
                        focus: true
                    }).then(function(response) {  
                        workspaceAPI.setTabHighlighted({
                            tabId: response,
                            highlighted: true,
                            options: {
                                pulse: true,
                                state: "success"
                            }
                        });
                        workspaceAPI.refreshTab({
                            tabId: response[0].tabId,
                            includeAllSubtabs: true
                        });
                    }).catch(function(error) {
                        console.log(error);
                    });                
                })
                .catch(function(error) {
                    console.log(error);
                }); 
            }else{
                helper.paymentRedirection(component,"view","ChargentOrders__ChargentOrder__c",component.get("v.recordId"));
                //helper.paymentRedirection(component, event, helper,paymentId);
            }       
        })
        .catch(function(error) {
            console.log(error);
        }); 
        */
    },
    paymentRedirection : function(component,actionName,objectApiName,recordId){
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
    navigationUtil : function(component, event, helper, paymentId) {
        var navLink = component.find("navLink");
        navLink.generateUrl(pageRef).then($A.getCallback(function(a) {
            component.set("v.url", a ? a : "#");
        }), $A.getCallback(function(error) {
            component.set("v.url", "#");
        }));
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'ChargentOrders__ChargentOrder__c',
                recordId : paymentId 
            },
        };
        navLink.navigate(pageRef, true);
        $A.get('e.force:refreshView').fire();
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
})