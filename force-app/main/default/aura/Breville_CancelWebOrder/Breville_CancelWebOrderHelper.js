({
    apexUtil : function(component, apexMethod, params ) {
        return new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexMethod+"");
            action.setParams( params );
            action.setCallback( this , function(response) {
                if(response.getState()=='SUCCESS') {
                    resolve( response.getReturnValue() );
                }
                if(response.getState()=='ERROR') {                    
                    reject( response.getError());
                }
            });
            $A.enqueueAction( action );
        }));    
    },
    toastAlert : function(component,variant,title,mode,message){
        component.find('notifLib').showToast({
            "variant":variant,
            "title": title,
            "mode":mode,
            "message": message
        });
        component.set("v.showLoader",false);        
    },
    showNoticeUtil : function(component,variant,header,message){
        component.find('notifLib').showNotice({
            "variant":variant,
            "header": header,
            "message":message,
        });
        component.set("v.showLoader",false);
    },
    refreshUtil : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        component.set("v.showLoader",false);
    },
    openSubtabUtil : function(component,variant,title,mode,message){
        var paymentUrl = "/apex/ChargentPaymentTerminal?order_id=" + orderDetails.Id;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {            
            if(response){
                workspaceAPI.openSubtab({
                    url: paymentUrl,
                    focus: true
                }).then(function(response) {
                    workspaceAPI.getAllTabInfo()
                    .then(function(response) {
                        console.log("complete tab info"+JSON.stringify(response));
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.setTabHighlighted({
                                tabId: focusedTabId,
                                highlighted: true,
                                options: {
                                    pulse: true,
                                    state: "success"
                                }
                            });
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    });                    
                })
                .catch(function(error) {
                    console.log(error);
                });
            }else{
                window.location.href = paymentUrl;
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    showModalHelper : function(component, event, helper) {
        component.set("v.showLoader",true);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            console.log("is in console ??"+response);
            if(response){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    $A.createComponent("c:Ltng_ChargentPaymentTerminal", {recordId : component.get("v.recordId")},function(result, status) {
                        if (status === "SUCCESS") {
                            component.find('overlayLibDemo').showCustomModal({
                                header: "Payment Edit",
                                body: result, 
                                showCloseButton: true,
                                cssClass: "mymodal", 
                            });
                            component.set("v.showLoader",false);
                        }                               
                    });
                    console.log('refreshed item :: '+JSON.stringify(response));
                    var focusedTabId = response.tabId;
                    workspaceAPI.refreshTab({
                        tabId: focusedTabId,
                        includeAllSubtabs: true
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });                
            }else{
                $A.createComponent("c:Ltng_ChargentPaymentTerminal", {recordId : component.get("v.recordId")},function(result, status) {
                    if (status === "SUCCESS") {
                        component.find('overlayLibDemo').showCustomModal({
                            header: "Payment Edit",
                            body: result, 
                            showCloseButton: true,
                            cssClass: "mymodal", 
                        });
                        component.set("v.showLoader",false);
                    }                               
                }); 
            }            
        })
        .catch(function(error) {
            console.log(error);
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
})