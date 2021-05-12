({
    doInit : function(component, event, helper) {    
        component.set("v.isLoad",true);
        var selectedRecords = component.get("v.saveInAccount");
        var selectedRecordstr=JSON.stringify(selectedRecords);
        console.log('selectedRecordstr>>>>>>',selectedRecordstr);
        
        var selectedRecords1 = component.get("v.saveInAsset");
        var selectedRecordstr1=JSON.stringify(selectedRecords1);
        console.log('selectedRecordstr>>>>>>',selectedRecordstr1);
    } ,                            
    
    purchaseEdit : function(component, event, helper) { 
        alert('purchaseEdit');
    },
    deliveryEdit : function(component, event, helper) {  
        alert('deliveryEdit');
    },
    back : function(component, event, helper) {   
        alert('back');
    },
    submitClaim : function(component, event, helper) { 
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.submitClaim");
        action.setParams(	{ 
                            acct : component.get("v.saveInAccount"),
            				asset :  component.get("v.saveInAsset") 
        					}
                        );
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                 console.log("From server: " + response.getReturnValue());
               
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})